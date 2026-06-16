import 'package:drift/drift.dart';

import '../../app_database.dart';
import '../../lww.dart';
import '../../tables/pocket_ledger_tables.dart';

part 'monitoring_sessions_dao.g.dart';

@DriftAccessor(tables: [MonitoringSessions])
class MonitoringSessionsDao extends DatabaseAccessor<AppDatabase> with _$MonitoringSessionsDaoMixin {
  MonitoringSessionsDao(super.db);

  Future<MonitoringSessionRow?> findById(String id) =>
      (select(monitoringSessions)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<MonitoringSessionRow?> findBySyncId(String syncId) =>
      (select(monitoringSessions)..where((t) => t.syncId.equals(syncId))).getSingleOrNull();

  Future<List<MonitoringSessionRow>> pendingPush() =>
      (select(monitoringSessions)..where((t) => t.isDirty.equals(true))).get();

  Future<void> markClean(Iterable<String> syncIds) async {
    if (syncIds.isEmpty) return;
    await (update(monitoringSessions)..where((t) => t.syncId.isIn(syncIds))).write(
      const MonitoringSessionsCompanion(isDirty: Value(false)),
    );
  }

  Future<bool> upsertFromRemote(MonitoringSessionsCompanion remote) async {
    final syncId = remote.syncId.value;
    final existing = await findBySyncId(syncId);
    if (existing != null &&
        Lww.localShouldKeep(
          localUpdatedAtMs: existing.updatedAtMs,
          localIsDirty: existing.isDirty,
          remoteUpdatedAtMs: remote.updatedAtMs.value,
        )) {
      return false;
    }
    await into(monitoringSessions).insertOnConflictUpdate(
      remote.copyWith(isDirty: const Value(false)),
    );
    return true;
  }

  Future<int> maxUpdatedAt() async {
    final row = await (selectOnly(monitoringSessions)
          ..addColumns([monitoringSessions.updatedAtMs.max()]))
        .getSingle();
    return row.read(monitoringSessions.updatedAtMs.max()) ?? 0;
  }
}
