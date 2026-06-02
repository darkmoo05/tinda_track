import 'package:drift/drift.dart';

import '../../app_database.dart';
import '../../lww.dart';
import '../../tables/tinda_tracker_tables.dart';

part 'shelf_locations_dao.g.dart';

@DriftAccessor(tables: [ShelfLocations])
class ShelfLocationsDao extends DatabaseAccessor<AppDatabase>
    with _$ShelfLocationsDaoMixin {
  ShelfLocationsDao(super.db);

  Stream<List<ShelfLocationRow>> watchAll() {
    return (select(shelfLocations)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<ShelfLocationRow?> findById(String id) {
    return (select(
      shelfLocations,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<ShelfLocationRow?> findBySyncId(String syncId) {
    return (select(
      shelfLocations,
    )..where((t) => t.syncId.equals(syncId))).getSingleOrNull();
  }

  Future<void> upsertLocal(ShelfLocationsCompanion companion) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final patched = companion.copyWith(
      isDirty: const Value(true),
      updatedAtMs: Value(now),
      createdAtMs: companion.createdAtMs.present
          ? companion.createdAtMs
          : Value(now),
    );
    await into(shelfLocations).insertOnConflictUpdate(patched);
  }

  Future<void> softDelete(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (update(shelfLocations)..where((t) => t.id.equals(id))).write(
      ShelfLocationsCompanion(
        isDeleted: const Value(true),
        isDirty: const Value(true),
        updatedAtMs: Value(now),
      ),
    );
  }

  Future<List<ShelfLocationRow>> pendingPush() {
    return (select(shelfLocations)..where((t) => t.isDirty.equals(true))).get();
  }

  Future<void> markClean(Iterable<String> syncIds) async {
    if (syncIds.isEmpty) return;
    await (update(shelfLocations)..where((t) => t.syncId.isIn(syncIds))).write(
      const ShelfLocationsCompanion(isDirty: Value(false)),
    );
  }

  Future<bool> upsertFromRemote(ShelfLocationsCompanion remote) async {
    final existing = await findBySyncId(remote.syncId.value);
    if (existing != null &&
        Lww.localShouldKeep(
          localUpdatedAtMs: existing.updatedAtMs,
          localIsDirty: existing.isDirty,
          remoteUpdatedAtMs: remote.updatedAtMs.value,
        )) {
      return false;
    }
    // Preserve the local-only imageLocalPath when applying a remote update —
    // the server payload never carries that column.
    var preserved = existing != null && !remote.imageLocalPath.present
        ? remote.copyWith(
            isDirty: const Value(false),
            imageLocalPath: Value(existing.imageLocalPath),
          )
        : remote.copyWith(isDirty: const Value(false));
    // If the local row has a different PK than what the server returned
    // (legacy data with server-generated ids), pin the companion's id to the
    // local id so insertOnConflictUpdate updates instead of inserting a
    // duplicate that would violate UNIQUE(syncId).
    if (existing != null && existing.id != preserved.id.value) {
      preserved = preserved.copyWith(id: Value(existing.id));
    }
    await into(shelfLocations).insertOnConflictUpdate(preserved);
    return true;
  }

  Future<int> maxUpdatedAt() async {
    final row = await (selectOnly(
      shelfLocations,
    )..addColumns([shelfLocations.updatedAtMs.max()])).getSingle();
    return row.read(shelfLocations.updatedAtMs.max()) ?? 0;
  }
}
