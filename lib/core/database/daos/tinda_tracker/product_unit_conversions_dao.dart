import 'package:drift/drift.dart';

import '../../app_database.dart';
import '../../lww.dart';
import '../../tables/tinda_tracker_tables.dart';

part 'product_unit_conversions_dao.g.dart';

@DriftAccessor(tables: [ProductUnitConversions])
class ProductUnitConversionsDao extends DatabaseAccessor<AppDatabase>
    with _$ProductUnitConversionsDaoMixin {
  ProductUnitConversionsDao(super.db);

  Stream<List<ProductUnitConversionRow>> watchForProduct(String productId) {
    return (select(productUnitConversions)
          ..where(
            (t) => t.productId.equals(productId) & t.isDeleted.equals(false),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.conversionFactor)]))
        .watch();
  }

  Future<List<ProductUnitConversionRow>> listForProduct(String productId) {
    return (select(productUnitConversions)..where(
          (t) => t.productId.equals(productId) & t.isDeleted.equals(false),
        ))
        .get();
  }

  Future<ProductUnitConversionRow?> findById(String id) {
    return (select(
      productUnitConversions,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<ProductUnitConversionRow?> findBySyncId(String syncId) {
    return (select(
      productUnitConversions,
    )..where((t) => t.syncId.equals(syncId))).getSingleOrNull();
  }

  Future<void> upsertLocal(ProductUnitConversionsCompanion companion) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final patched = companion.copyWith(
      isDirty: const Value(true),
      updatedAtMs: Value(now),
      createdAtMs: companion.createdAtMs.present
          ? companion.createdAtMs
          : Value(now),
    );
    await into(productUnitConversions).insertOnConflictUpdate(patched);
  }

  Future<void> softDelete(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (update(productUnitConversions)..where((t) => t.id.equals(id))).write(
      ProductUnitConversionsCompanion(
        isDeleted: const Value(true),
        isDirty: const Value(true),
        updatedAtMs: Value(now),
      ),
    );
  }

  Future<List<ProductUnitConversionRow>> pendingPush() {
    return (select(
      productUnitConversions,
    )..where((t) => t.isDirty.equals(true))).get();
  }

  Future<void> markClean(Iterable<String> syncIds) async {
    if (syncIds.isEmpty) return;
    await (update(productUnitConversions)..where((t) => t.syncId.isIn(syncIds)))
        .write(const ProductUnitConversionsCompanion(isDirty: Value(false)));
  }

  Future<bool> upsertFromRemote(ProductUnitConversionsCompanion remote) async {
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
    await into(productUnitConversions).insertOnConflictUpdate(patched);
    return true;
  }

  Future<int> maxUpdatedAt() async {
    final row = await (selectOnly(
      productUnitConversions,
    )..addColumns([productUnitConversions.updatedAtMs.max()])).getSingle();
    return row.read(productUnitConversions.updatedAtMs.max()) ?? 0;
  }
}
