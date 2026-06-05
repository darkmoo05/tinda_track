import '../remote/sync_logging.dart' as legacy_log;
import 'retry_policy.dart';
import 'sync_errors.dart';

/// Container for push data and post-acknowledgment cleaning callback.
class EntityPushPayload {
  final String entityKey;
  final List<Map<String, dynamic>> records;
  final Future<void> Function() onAck;

  const EntityPushPayload({
    required this.entityKey,
    required this.records,
    required this.onAck,
  });
}

/// Declarative description of how one synced entity (table) talks to its
/// backend counterpart. The generic [TRow] is the Drift row class (e.g.
/// `ChargeRow`); we deliberately stay row-typed instead of leaking
/// Companion types because every push payload is built from a *row*
/// already in the local DB.
///
/// All four DAO interactions are passed as closures so this engine has zero
/// compile-time dependency on any specific table or DAO — the bindings
/// file wires them together.
///
/// Example (see `bindings/pocket_ledger_bindings.dart`):
///
///   EntitySync&lt;ChargeRow&gt;(
///     entityKey: 'charges',
///     route: '/charges',
///     pendingPush: charges.pendingPush,
///     markClean: charges.markClean,
///     maxUpdatedAt: charges.maxUpdatedAt,
///     toRemoteJson: (row) => chargeToRemoteJson(row.toDomain()),
///     applyRemote: (json) async {
///       final companion = chargeCompanionFromRemoteJson(json);
///       return charges.upsertFromRemote(companion);
///     },
///     pushRemote: (payload) => ChargeRemoteRepository.instance.push(payload),
///     pullRemote: (deviceId, since) =>
///         ChargeRemoteRepository.instance.pull(deviceId: deviceId, since: since),
///   )
class EntitySync<TRow> {
  EntitySync({
    required this.entityKey,
    required this.route,
    required this.pendingPush,
    required this.markClean,
    required this.maxUpdatedAt,
    required this.toRemoteJson,
    required this.applyRemote,
    required this.pushRemote,
    required this.pullRemote,
    this.postPushHook,
  });

  /// Stable identifier for logs ("charges", "ledger_entries", …).
  final String entityKey;

  /// Server route base for logging ("/charges").
  final String route;

  /// Returns all locally-dirty rows that need to be pushed.
  final Future<List<TRow>> Function() pendingPush;

  /// Clears the dirty flag for [syncIds] after the server has acked them.
  final Future<void> Function(Iterable<String> syncIds) markClean;

  /// Highest `updated_at_ms` across this entity's rows (cursor source).
  final Future<int> Function() maxUpdatedAt;

  /// Encodes one row into the JSON shape `pushRemote` expects.
  final Map<String, dynamic> Function(TRow row) toRemoteJson;

  /// Decodes one server JSON record and applies LWW upsert via the DAO.
  /// Returns true if the row was written (remote won), false if the local
  /// copy was newer/dirty.
  final Future<bool> Function(Map<String, dynamic> json) applyRemote;

  /// HTTP push hook — true if the server accepted the batch, false otherwise.
  final Future<bool> Function(List<Map<String, dynamic>> payload) pushRemote;

  /// HTTP pull hook — returns the raw JSON list (may be empty).
  final Future<List<Map<String, dynamic>>> Function({
    required String deviceId,
    int? since,
  })
  pullRemote;

  /// Sync-id extractor for [markClean]. Defaults to a `syncId` getter via
  /// dynamic dispatch — adequate for every Drift row in this app since
  /// they all use the `SyncedRow` mixin. Override only if the row exposes
  /// the id under a different name.
  String _syncIdOf(TRow row) => (row as dynamic).syncId as String;

  /// Optional post-push hook for entities with embedded child rows
  /// (e.g. Sales → SaleItems): receives the rows the server just acked
  /// so the caller can mark their children clean too.
  final Future<void> Function(List<TRow> acked)? postPushHook;

  /// Builds the push payload and schedules post-push cleaning callback.
  Future<EntityPushPayload?> preparePush() async {
    final dirty = await pendingPush();
    if (dirty.isEmpty) return null;
    final payload = dirty.map(toRemoteJson).toList(growable: false);
    return EntityPushPayload(
      entityKey: entityKey,
      records: payload,
      onAck: () async {
        await markClean(dirty.map(_syncIdOf));
        if (postPushHook != null) {
          await postPushHook!(dirty);
        }
      },
    );
  }

  /// Reconciles pulled server records locally via last-write-wins rules.
  Future<EntityPullOutcome> processPull(List<Map<String, dynamic>> records) async {
    var conflicts = 0;
    var maxServerUpdatedAt = 0;
    for (final json in records) {
      try {
        final applied = await applyRemote(json);
        if (!applied) conflicts++;
        final v = json['updated_at_ms'] ?? json['updatedAtMs'];
        if (v is int && v > maxServerUpdatedAt) {
          maxServerUpdatedAt = v;
        } else if (v is num && v.toInt() > maxServerUpdatedAt) {
          maxServerUpdatedAt = v.toInt();
        }
      } catch (e) {
        legacy_log.logSyncFailure(
          '$route/pull[record]',
          SchemaSyncError('apply failed for $entityKey: $e', cause: e),
          op: 'pull',
        );
      }
    }
    return EntityPullOutcome(
      pulled: records.length,
      conflicts: conflicts,
      maxServerUpdatedAtMs: maxServerUpdatedAt,
    );
  }

  // ── Drivers ────────────────────────────────────────────────────────────────

  Future<int> push(RetryPolicy retry) async {
    final dirty = await pendingPush();
    if (dirty.isEmpty) return 0;
    final payload = dirty.map(toRemoteJson).toList(growable: false);
    final ok = await retry.run(() async {
      try {
        return await pushRemote(payload);
      } catch (e) {
        legacy_log.logSyncFailure('$route/push', e, op: 'push');
        rethrow;
      }
    });
    // BUG-6 fix: a `false` return is not silent success. The transport call
    // succeeded but the batch was rejected (e.g. server returned 207 with
    // per-row errors, or our remote wrapper translated a 4xx into `false`).
    // Rows stay dirty (we never call `markClean`); throwing here lets the
    // engine record the module-level push as failed so the UI surfaces it.
    if (!ok) {
      throw PushRejectedError(
        'pushRemote returned false for $entityKey ($route, '
        '${dirty.length} rows)',
      );
    }
    await markClean(dirty.map(_syncIdOf));
    if (postPushHook != null) await postPushHook!(dirty);
    return dirty.length;
  }

  Future<EntityPullOutcome> pull({
    required RetryPolicy retry,
    required String deviceId,
    int? since,
  }) async {
    final records = await retry.run(() async {
      try {
        return await pullRemote(deviceId: deviceId, since: since);
      } catch (e) {
        legacy_log.logSyncFailure('$route/pull', e, op: 'pull');
        rethrow;
      }
    });
    var conflicts = 0;
    var maxServerUpdatedAt = 0;
    for (final json in records) {
      try {
        final applied = await applyRemote(json);
        if (!applied) conflicts++;
        // BUG-2 fix: track the highest server `updated_at_ms` we actually saw
        // in this pull so the engine can advance the cursor based on what
        // the server returned — not on the local max, which would jump past
        // unseen rows when an entity's pull errored out earlier.
        final v = json['updated_at_ms'] ?? json['updatedAtMs'];
        if (v is int && v > maxServerUpdatedAt) {
          maxServerUpdatedAt = v;
        } else if (v is num && v.toInt() > maxServerUpdatedAt) {
          maxServerUpdatedAt = v.toInt();
        }
      } catch (e) {
        // Per-record failures must not abort the whole pull — log and skip.
        legacy_log.logSyncFailure(
          '$route/pull[record]',
          SchemaSyncError('apply failed for $entityKey: $e', cause: e),
          op: 'pull',
        );
      }
    }
    return EntityPullOutcome(
      pulled: records.length,
      conflicts: conflicts,
      maxServerUpdatedAtMs: maxServerUpdatedAt,
    );
  }
}

class EntityPullOutcome {
  const EntityPullOutcome({
    required this.pulled,
    required this.conflicts,
    this.maxServerUpdatedAtMs = 0,
  });
  final int pulled;
  final int conflicts;

  /// Highest `updated_at_ms` observed in the pulled record set. Zero when no
  /// rows were returned. Used by [SyncEngine] to advance the per-module
  /// pull cursor safely (only past rows we actually received).
  final int maxServerUpdatedAtMs;
}
