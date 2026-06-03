import 'package:drift/drift.dart';

import '../../app_database.dart';
import '../../lww.dart';
import '../../tables/tinda_tracker_tables.dart';

part 'utang_records_dao.g.dart';

@DriftAccessor(tables: [UtangRecords])
class UtangRecordsDao extends DatabaseAccessor<AppDatabase>
    with _$UtangRecordsDaoMixin {
  UtangRecordsDao(super.db);

  Stream<List<UtangRecordRow>> watchForCustomer(String customerId) {
    return (select(utangRecords)
          ..where(
            (t) => t.customerId.equals(customerId) & t.isDeleted.equals(false),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.createdAtMs)]))
        .watch();
  }

  Stream<List<UtangRecordRow>> watchAll() {
    return (select(utangRecords)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAtMs)]))
        .watch();
  }

  Future<UtangRecordRow?> findById(String id) {
    return (select(
      utangRecords,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<UtangRecordRow?> findBySyncId(String syncId) {
    return (select(
      utangRecords,
    )..where((t) => t.syncId.equals(syncId))).getSingleOrNull();
  }

  Future<void> upsertLocal(UtangRecordsCompanion companion) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final patched = companion.copyWith(
      isDirty: const Value(true),
      updatedAtMs: Value(now),
      createdAtMs: companion.createdAtMs.present
          ? companion.createdAtMs
          : Value(now),
    );
    await into(utangRecords).insertOnConflictUpdate(patched);
  }

  Future<void> softDelete(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (update(utangRecords)..where((t) => t.id.equals(id))).write(
      UtangRecordsCompanion(
        isDeleted: const Value(true),
        isDirty: const Value(true),
        updatedAtMs: Value(now),
      ),
    );
  }

  Future<List<UtangRecordRow>> pendingPush() {
    return (select(utangRecords)..where((t) => t.isDirty.equals(true))).get();
  }

  Future<void> markClean(Iterable<String> syncIds) async {
    if (syncIds.isEmpty) return;
    await (update(utangRecords)..where((t) => t.syncId.isIn(syncIds))).write(
      const UtangRecordsCompanion(isDirty: Value(false)),
    );
  }

  Future<bool> upsertFromRemote(UtangRecordsCompanion remote) async {
    final existing = await findBySyncId(remote.syncId.value);
    if (existing != null &&
        Lww.localShouldKeep(
          localUpdatedAtMs: existing.updatedAtMs,
          localIsDirty: existing.isDirty,
          remoteUpdatedAtMs: remote.updatedAtMs.value,
        )) {
      return false;
    }
    final patched = (existing != null && existing.id != remote.id.value)
        ? remote.copyWith(id: Value(existing.id), isDirty: const Value(false))
        : remote.copyWith(isDirty: const Value(false));
    await into(utangRecords).insertOnConflictUpdate(patched);
    return true;
  }

  Future<int> maxUpdatedAt() async {
    final row = await (selectOnly(
      utangRecords,
    )..addColumns([utangRecords.updatedAtMs.max()])).getSingle();
    return row.read(utangRecords.updatedAtMs.max()) ?? 0;
  }
}
