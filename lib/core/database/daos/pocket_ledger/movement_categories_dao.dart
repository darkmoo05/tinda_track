import 'package:drift/drift.dart';

import '../../app_database.dart';
import '../../lww.dart';
import '../../tables/pocket_ledger_tables.dart';

part 'movement_categories_dao.g.dart';

@DriftAccessor(tables: [MovementCategories])
class MovementCategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$MovementCategoriesDaoMixin {
  MovementCategoriesDao(super.db);

  Stream<List<MovementCategoryRow>> watchAll() {
    return (select(movementCategories)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<MovementCategoryRow?> findById(String id) => (select(
    movementCategories,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<MovementCategoryRow?> findBySyncId(String syncId) => (select(
    movementCategories,
  )..where((t) => t.syncId.equals(syncId))).getSingleOrNull();

  Future<void> upsertLocal(MovementCategoriesCompanion companion) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await into(movementCategories).insertOnConflictUpdate(
      companion.copyWith(
        isDirty: const Value(true),
        updatedAtMs: Value(now),
        createdAtMs: companion.createdAtMs.present
            ? companion.createdAtMs
            : Value(now),
      ),
    );
  }

  Future<void> softDelete(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (update(movementCategories)..where((t) => t.id.equals(id))).write(
      MovementCategoriesCompanion(
        isDeleted: const Value(true),
        isDirty: const Value(true),
        updatedAtMs: Value(now),
      ),
    );
  }

  Future<List<MovementCategoryRow>> pendingPush() =>
      (select(movementCategories)..where((t) => t.isDirty.equals(true))).get();

  Future<void> markClean(Iterable<String> syncIds) async {
    if (syncIds.isEmpty) return;
    await (update(movementCategories)..where((t) => t.syncId.isIn(syncIds)))
        .write(const MovementCategoriesCompanion(isDirty: Value(false)));
  }

  Future<bool> upsertFromRemote(MovementCategoriesCompanion remote) async {
    final existing = await findBySyncId(remote.syncId.value);
    if (existing != null &&
        Lww.localShouldKeep(
          localUpdatedAtMs: existing.updatedAtMs,
          localIsDirty: existing.isDirty,
          remoteUpdatedAtMs: remote.updatedAtMs.value,
        )) {
      return false;
    }
    await into(
      movementCategories,
    ).insertOnConflictUpdate(remote.copyWith(isDirty: const Value(false)));
    return true;
  }

  Future<int> maxUpdatedAt() async {
    final row = await (selectOnly(
      movementCategories,
    )..addColumns([movementCategories.updatedAtMs.max()])).getSingle();
    return row.read(movementCategories.updatedAtMs.max()) ?? 0;
  }
}
