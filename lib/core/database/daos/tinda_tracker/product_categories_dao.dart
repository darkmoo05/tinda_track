import 'package:drift/drift.dart';

import '../../app_database.dart';
import '../../tables/tinda_tracker_tables.dart';

part 'product_categories_dao.g.dart';

@DriftAccessor(tables: [ProductCategories])
class ProductCategoriesDao extends DatabaseAccessor<AppDatabase>
    with _$ProductCategoriesDaoMixin {
  ProductCategoriesDao(super.db);

  Stream<List<ProductCategoryRow>> watchAll() {
    return (select(productCategories)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<ProductCategoryRow?> findById(String id) {
    return (select(
      productCategories,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<ProductCategoryRow?> findBySyncId(String syncId) {
    return (select(
      productCategories,
    )..where((t) => t.syncId.equals(syncId))).getSingleOrNull();
  }

  Future<void> upsertLocal(ProductCategoriesCompanion companion) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final patched = companion.copyWith(
      isDirty: const Value(true),
      updatedAtMs: Value(now),
      createdAtMs: companion.createdAtMs.present
          ? companion.createdAtMs
          : Value(now),
    );
    await into(productCategories).insertOnConflictUpdate(patched);
  }

  Future<void> softDelete(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (update(productCategories)..where((t) => t.id.equals(id))).write(
      ProductCategoriesCompanion(
        isDeleted: const Value(true),
        isDirty: const Value(true),
        updatedAtMs: Value(now),
      ),
    );
  }

  Future<List<ProductCategoryRow>> pendingPush() {
    return (select(
      productCategories,
    )..where((t) => t.isDirty.equals(true))).get();
  }

  Future<void> markClean(Iterable<String> syncIds) async {
    if (syncIds.isEmpty) return;
    await (update(productCategories)..where((t) => t.syncId.isIn(syncIds)))
        .write(const ProductCategoriesCompanion(isDirty: Value(false)));
  }

  Future<bool> upsertFromRemote(ProductCategoriesCompanion remote) async {
    final existing = await findBySyncId(remote.syncId.value);
    if (existing != null &&
        existing.updatedAtMs > remote.updatedAtMs.value &&
        existing.isDirty) {
      return false;
    }
    // If a row already exists locally for this syncId but with a different
    // primary key (legacy server data with server-generated ids), update the
    // existing row in place rather than inserting a new one — inserting
    // would violate the UNIQUE(syncId) constraint and the dropdown would
    // never see the remote data. Force the companion's id to match local.
    final patched = (existing != null && existing.id != remote.id.value)
        ? remote.copyWith(id: Value(existing.id), isDirty: const Value(false))
        : remote.copyWith(isDirty: const Value(false));
    await into(productCategories).insertOnConflictUpdate(patched);
    return true;
  }

  Future<int> maxUpdatedAt() async {
    final row = await (selectOnly(
      productCategories,
    )..addColumns([productCategories.updatedAtMs.max()])).getSingle();
    return row.read(productCategories.updatedAtMs.max()) ?? 0;
  }
}
