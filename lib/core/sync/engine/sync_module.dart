import 'entity_sync.dart';
import 'retry_policy.dart';

/// Groups every [EntitySync] that belongs to one logical module
/// (e.g. `pocket_ledger`, `tinda_tracker`).
///
/// A module is the smallest unit the [SyncEngine] schedules — it has one
/// `last_pulled_at_ms` cursor in `sync_state` and one row of UI status.
class SyncModule {
  SyncModule({required this.key, required this.entities});

  /// Stable module key matching the row in `sync_state`
  /// (e.g. `'pocket_ledger'`).
  final String key;

  /// Order matters only for logging — every entity runs concurrently in
  /// both push and pull.
  final List<EntitySync<dynamic>> entities;

  /// Pushes every entity's dirty rows. Returns total rows acked.
  Future<int> push(RetryPolicy retry) async {
    final counts = <int>[];
    for (final e in entities) {
      counts.add(await e.push(retry));
    }
    return counts.fold<int>(0, (a, b) => a + b);
  }

  /// Pulls every entity's deltas since [sinceMs]. Returns aggregate counts
  /// plus the highest server `updated_at_ms` observed across every entity
  /// (`maxServerUpdatedAtMs`) so the engine can advance its cursor safely.
  Future<EntityPullOutcome> pull({
    required RetryPolicy retry,
    required String deviceId,
    required int sinceMs,
  }) async {
    final since = sinceMs == 0 ? null : sinceMs;
    final outcomes = <EntityPullOutcome>[];
    for (final e in entities) {
      outcomes.add(await e.pull(retry: retry, deviceId: deviceId, since: since));
    }
    var pulled = 0;
    var conflicts = 0;
    var maxServer = 0;
    for (final o in outcomes) {
      pulled += o.pulled;
      conflicts += o.conflicts;
      if (o.maxServerUpdatedAtMs > maxServer) {
        maxServer = o.maxServerUpdatedAtMs;
      }
    }
    return EntityPullOutcome(
      pulled: pulled,
      conflicts: conflicts,
      maxServerUpdatedAtMs: maxServer,
    );
  }

  /// Highest `updated_at_ms` across all entities — the post-pull cursor.
  Future<int> maxUpdatedAt() async {
    final maxes = await Future.wait(entities.map((e) => e.maxUpdatedAt()));
    return maxes.fold<int>(0, (a, b) => a > b ? a : b);
  }

  /// Count of locally-dirty rows across every entity — drives "N pending"
  /// badges in the UI.
  Future<int> pendingCount() async {
    final counts = await Future.wait(
      entities.map((e) async => (await e.pendingPush()).length),
    );
    return counts.fold<int>(0, (a, b) => a + b);
  }
}
