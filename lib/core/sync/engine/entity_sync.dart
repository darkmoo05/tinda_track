import '../remote/sync_logging.dart' as legacy_log;
import 'retry_policy.dart';
import 'sync_errors.dart';

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
///   EntitySync<ChargeRow>(
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
    if (!ok) return 0;
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
    for (final json in records) {
      try {
        final applied = await applyRemote(json);
        if (!applied) conflicts++;
      } catch (e) {
        // Per-record failures must not abort the whole pull — log and skip.
        legacy_log.logSyncFailure(
          '$route/pull[record]',
          SchemaSyncError('apply failed for $entityKey: $e', cause: e),
          op: 'pull',
        );
      }
    }
    return EntityPullOutcome(pulled: records.length, conflicts: conflicts);
  }
}

class EntityPullOutcome {
  const EntityPullOutcome({required this.pulled, required this.conflicts});
  final int pulled;
  final int conflicts;
}
