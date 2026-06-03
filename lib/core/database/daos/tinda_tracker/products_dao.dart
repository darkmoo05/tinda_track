import 'package:drift/drift.dart';

import '../../app_database.dart';
import '../../lww.dart';
import '../../tables/tinda_tracker_tables.dart';

part 'products_dao.g.dart';

@DriftAccessor(tables: [Products])
class ProductsDao extends DatabaseAccessor<AppDatabase>
    with _$ProductsDaoMixin {
  ProductsDao(super.db);

  Stream<List<ProductRow>> watchAll({String? categoryId, bool? activeOnly}) {
    final q = select(products)..where((t) => t.isDeleted.equals(false));
    if (categoryId != null) q.where((t) => t.categoryId.equals(categoryId));
    if (activeOnly == true) q.where((t) => t.isActive.equals(true));
    q.orderBy([(t) => OrderingTerm.asc(t.name)]);
    return q.watch();
  }

  Future<ProductRow?> findById(String id) {
    return (select(products)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<ProductRow?> findBySyncId(String syncId) {
    return (select(
      products,
    )..where((t) => t.syncId.equals(syncId))).getSingleOrNull();
  }

  Future<ProductRow?> findBySku(String sku) {
    return (select(
      products,
    )..where((t) => t.sku.equals(sku))).getSingleOrNull();
  }

  Future<void> upsertLocal(ProductsCompanion companion) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final patched = companion.copyWith(
      isDirty: const Value(true),
      updatedAtMs: Value(now),
      createdAtMs: companion.createdAtMs.present
          ? companion.createdAtMs
          : Value(now),
    );
    await into(products).insertOnConflictUpdate(patched);
  }

  Future<void> softDelete(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (update(products)..where((t) => t.id.equals(id))).write(
      ProductsCompanion(
        isDeleted: const Value(true),
        isDirty: const Value(true),
        updatedAtMs: Value(now),
      ),
    );
  }

  /// Atomically adjusts `stock_in_base_unit` (positive = inflow, negative =
  /// outflow). Returns the new value. Marks the row dirty.
  Future<double> adjustStock(String productId, double delta) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    return transaction(() async {
      final row = await findById(productId);
      if (row == null) {
        throw StateError('Product $productId not found for stock adjustment');
      }
      final next = row.stockInBaseUnit + delta;
      await (update(products)..where((t) => t.id.equals(productId))).write(
        ProductsCompanion(
          stockInBaseUnit: Value(next),
          isDirty: const Value(true),
          updatedAtMs: Value(now),
        ),
      );
      return next;
    });
  }

  Future<List<ProductRow>> pendingPush() {
    return (select(products)..where((t) => t.isDirty.equals(true))).get();
  }

  Future<void> markClean(Iterable<String> syncIds) async {
    if (syncIds.isEmpty) return;
    await (update(products)..where((t) => t.syncId.isIn(syncIds))).write(
      const ProductsCompanion(isDirty: Value(false)),
    );
  }

  Future<bool> upsertFromRemote(ProductsCompanion remote) async {
    final existing = await findBySyncId(remote.syncId.value);
    if (existing != null &&
        Lww.localShouldKeep(
          localUpdatedAtMs: existing.updatedAtMs,
          localIsDirty: existing.isDirty,
          remoteUpdatedAtMs: remote.updatedAtMs.value,
        )) {
      return false;
    }
    var preserved = existing != null && !remote.imageLocalPath.present
        ? remote.copyWith(
            isDirty: const Value(false),
            imageLocalPath: Value(existing.imageLocalPath),
          )
        : remote.copyWith(isDirty: const Value(false));
    // Legacy server rows may have a server-generated id different from
    // the local id — pin to local PK so we update in place instead of
    // failing the UNIQUE(syncId) constraint with a duplicate insert.
    if (existing != null && existing.id != preserved.id.value) {
      preserved = preserved.copyWith(id: Value(existing.id));
    }
    await into(products).insertOnConflictUpdate(preserved);
    return true;
  }

  Future<int> maxUpdatedAt() async {
    final row = await (selectOnly(
      products,
    )..addColumns([products.updatedAtMs.max()])).getSingle();
    return row.read(products.updatedAtMs.max()) ?? 0;
  }
}
