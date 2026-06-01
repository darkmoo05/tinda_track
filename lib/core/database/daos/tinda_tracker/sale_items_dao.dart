import 'package:drift/drift.dart';

import '../../app_database.dart';
import '../../tables/tinda_tracker_tables.dart';

part 'sale_items_dao.g.dart';

/// Sale line items. Not separately synced — they travel embedded in the
/// parent Sale's remote payload. The table still tracks `is_dirty` for an
/// outbox-style replay of inserts that failed mid-transaction.
@DriftAccessor(tables: [SaleItems])
class SaleItemsDao extends DatabaseAccessor<AppDatabase>
    with _$SaleItemsDaoMixin {
  SaleItemsDao(super.db);

  Stream<List<SaleItemRow>> watchForSale(String saleId) {
    return (select(saleItems)
          ..where((t) => t.saleId.equals(saleId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAtMs)]))
        .watch();
  }

  Future<List<SaleItemRow>> listForSale(String saleId) {
    return (select(saleItems)..where((t) => t.saleId.equals(saleId))).get();
  }

  Future<SaleItemRow?> findById(String id) {
    return (select(saleItems)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertLocal(SaleItemsCompanion companion) async {
    await into(
      saleItems,
    ).insert(companion.copyWith(isDirty: const Value(true)));
  }

  Future<void> insertManyLocal(List<SaleItemsCompanion> companions) async {
    if (companions.isEmpty) return;
    await batch((b) {
      b.insertAll(
        saleItems,
        companions
            .map((c) => c.copyWith(isDirty: const Value(true)))
            .toList(growable: false),
      );
    });
  }

  Future<void> deleteForSale(String saleId) async {
    await (delete(saleItems)..where((t) => t.saleId.equals(saleId))).go();
  }

  Future<List<SaleItemRow>> pendingPush() {
    return (select(saleItems)..where((t) => t.isDirty.equals(true))).get();
  }

  Future<void> markClean(Iterable<String> ids) async {
    if (ids.isEmpty) return;
    await (update(saleItems)..where((t) => t.id.isIn(ids))).write(
      const SaleItemsCompanion(isDirty: Value(false)),
    );
  }
}
