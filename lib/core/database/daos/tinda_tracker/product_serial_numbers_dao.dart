import 'package:drift/drift.dart';

import '../../app_database.dart';
import '../../lww.dart';
import '../../tables/tinda_tracker_tables.dart';

part 'product_serial_numbers_dao.g.dart';

@DriftAccessor(tables: [ProductSerialNumbers])
class ProductSerialNumbersDao extends DatabaseAccessor<AppDatabase>
    with _$ProductSerialNumbersDaoMixin {
  ProductSerialNumbersDao(super.db);

  Stream<List<ProductSerialNumberRow>> watchForProduct(String productId) {
    return (select(productSerialNumbers)
          ..where(
            (t) => t.productId.equals(productId) & t.isDeleted.equals(false),
          ))
        .watch();
  }

  Future<List<ProductSerialNumberRow>> listForProduct(String productId) {
    return (select(productSerialNumbers)..where(
          (t) => t.productId.equals(productId) & t.isDeleted.equals(false),
        ))
        .get();
  }

  Future<List<ProductSerialNumberRow>> listAvailableForProduct(String productId) {
    return (select(productSerialNumbers)..where(
          (t) => t.productId.equals(productId) & t.status.equals('AVAILABLE') & t.isDeleted.equals(false),
        ))
        .get();
  }

  Future<ProductSerialNumberRow?> findById(String id) {
    return (select(
      productSerialNumbers,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<ProductSerialNumberRow?> findBySyncId(String syncId) {
    return (select(
      productSerialNumbers,
    )..where((t) => t.syncId.equals(syncId))).getSingleOrNull();
  }

  Future<void> upsertLocal(ProductSerialNumbersCompanion companion) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final patched = companion.copyWith(
      isDirty: const Value(true),
      updatedAtMs: Value(now),
      createdAtMs: companion.createdAtMs.present
          ? companion.createdAtMs
          : Value(now),
    );
    await into(productSerialNumbers).insertOnConflictUpdate(patched);
  }

  Future<void> softDelete(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (update(productSerialNumbers)..where((t) => t.id.equals(id))).write(
      ProductSerialNumbersCompanion(
        isDeleted: const Value(true),
        isDirty: const Value(true),
        updatedAtMs: Value(now),
      ),
    );
  }

  Future<List<ProductSerialNumberRow>> pendingPush() {
    return (select(
      productSerialNumbers,
    )..where((t) => t.isDirty.equals(true))).get();
  }

  Future<void> markClean(Iterable<String> syncIds) async {
    if (syncIds.isEmpty) return;
    await (update(productSerialNumbers)..where((t) => t.syncId.isIn(syncIds)))
        .write(const ProductSerialNumbersCompanion(isDirty: Value(false)));
  }

  Future<bool> upsertFromRemote(ProductSerialNumbersCompanion remote) async {
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
    await into(productSerialNumbers).insertOnConflictUpdate(patched);
    return true;
  }

  Future<int> maxUpdatedAt() async {
    final row = await (selectOnly(
      productSerialNumbers,
    )..addColumns([productSerialNumbers.updatedAtMs.max()])).getSingle();
    return row.read(productSerialNumbers.updatedAtMs.max()) ?? 0;
  }
}
