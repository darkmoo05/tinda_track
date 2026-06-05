import 'package:drift/drift.dart';

import '../../app_database.dart';
import '../../lww.dart';
import '../../tables/business_profiles_table.dart';

part 'business_profiles_dao.g.dart';

@DriftAccessor(tables: [BusinessProfiles])
class BusinessProfilesDao extends DatabaseAccessor<AppDatabase>
    with _$BusinessProfilesDaoMixin {
  BusinessProfilesDao(super.db);

  Stream<BusinessProfileRow?> watchActiveProfile() {
    return (select(businessProfiles)
          ..where((t) => t.isDeleted.equals(false))
          ..limit(1))
        .watchSingleOrNull();
  }

  Future<BusinessProfileRow?> getActiveProfile() {
    return (select(businessProfiles)
          ..where((t) => t.isDeleted.equals(false))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<BusinessProfileRow?> findById(String id) {
    return (select(
      businessProfiles,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<BusinessProfileRow?> findBySyncId(String syncId) {
    return (select(
      businessProfiles,
    )..where((t) => t.syncId.equals(syncId))).getSingleOrNull();
  }

  Future<void> upsertLocal(BusinessProfilesCompanion companion) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final patched = companion.copyWith(
      isDirty: const Value(true),
      updatedAtMs: Value(now),
      createdAtMs: companion.createdAtMs.present
          ? companion.createdAtMs
          : Value(now),
    );
    await into(businessProfiles).insertOnConflictUpdate(patched);
  }

  Future<void> softDelete(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (update(businessProfiles)..where((t) => t.id.equals(id))).write(
      BusinessProfilesCompanion(
        isDeleted: const Value(true),
        isDirty: const Value(true),
        updatedAtMs: Value(now),
      ),
    );
  }

  Future<List<BusinessProfileRow>> pendingPush() {
    return (select(
      businessProfiles,
    )..where((t) => t.isDirty.equals(true))).get();
  }

  Future<void> markClean(Iterable<String> syncIds) async {
    if (syncIds.isEmpty) return;
    await (update(businessProfiles)..where((t) => t.syncId.isIn(syncIds)))
        .write(const BusinessProfilesCompanion(isDirty: Value(false)));
  }

  Future<bool> upsertFromRemote(BusinessProfilesCompanion remote) async {
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
    await into(businessProfiles).insertOnConflictUpdate(patched);
    return true;
  }

  Future<int> maxUpdatedAt() async {
    final row = await (selectOnly(
      businessProfiles,
    )..addColumns([businessProfiles.updatedAtMs.max()])).getSingle();
    return row.read(businessProfiles.updatedAtMs.max()) ?? 0;
  }
}
