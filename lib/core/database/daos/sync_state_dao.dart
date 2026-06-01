import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/shared_tables.dart';

part 'sync_state_dao.g.dart';

/// Read/write helpers for the per-module `sync_state` row.
///
/// Module keys in use: `pocket_ledger`, `tinda_tracker`.
@DriftAccessor(tables: [SyncState])
class SyncStateDao extends DatabaseAccessor<AppDatabase>
    with _$SyncStateDaoMixin {
  SyncStateDao(super.db);

  Future<SyncStateRow?> read(String moduleKey) {
    return (select(
      syncState,
    )..where((t) => t.moduleKey.equals(moduleKey))).getSingleOrNull();
  }

  Stream<SyncStateRow?> watch(String moduleKey) {
    return (select(
      syncState,
    )..where((t) => t.moduleKey.equals(moduleKey))).watchSingleOrNull();
  }

  /// Updates the pull cursor after a successful delta pull.
  Future<void> setLastPulledAt(String moduleKey, int ms) {
    return (update(
      syncState,
    )..where((t) => t.moduleKey.equals(moduleKey))).write(
      SyncStateCompanion(
        lastPulledAtMs: Value(ms),
        updatedAtMs: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  /// Records a push attempt outcome.
  Future<void> recordPush({
    required String moduleKey,
    required bool success,
    String? error,
    int? pendingCount,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (update(
      syncState,
    )..where((t) => t.moduleKey.equals(moduleKey))).write(
      SyncStateCompanion(
        lastPushAttemptAtMs: Value(now),
        lastPushedAtMs: success ? Value(now) : const Value.absent(),
        lastPushError: Value(success ? null : error),
        pendingPushCount: pendingCount != null
            ? Value(pendingCount)
            : const Value.absent(),
        updatedAtMs: Value(now),
      ),
    );
  }
}
