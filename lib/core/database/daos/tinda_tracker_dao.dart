import '../app_database.dart';
import 'tinda_tracker/customers_dao.dart';
import 'tinda_tracker/product_categories_dao.dart';
import 'tinda_tracker/product_unit_conversions_dao.dart';
import 'tinda_tracker/products_dao.dart';
import 'tinda_tracker/sale_items_dao.dart';
import 'tinda_tracker/sales_dao.dart';
import 'tinda_tracker/shelf_locations_dao.dart';
import 'tinda_tracker/stock_movements_dao.dart';
import 'tinda_tracker/utang_records_dao.dart';

/// Grouped facade DAO for the **tinda_tracker** module.
///
/// See [PocketLedgerDao] for the design rationale. This file follows the same
/// pattern: per-table DAOs remain the implementations, and atomic multi-table
/// operations (sales checkout, restock, etc.) live here behind named helpers.
class TindaTrackerDao {
  TindaTrackerDao(this._db)
    : productCategories = ProductCategoriesDao(_db),
      shelfLocations = ShelfLocationsDao(_db),
      products = ProductsDao(_db),
      productUnitConversions = ProductUnitConversionsDao(_db),
      stockMovements = StockMovementsDao(_db),
      customers = CustomersDao(_db),
      utangRecords = UtangRecordsDao(_db),
      sales = SalesDao(_db),
      saleItems = SaleItemsDao(_db);

  final AppDatabase _db;

  AppDatabase get database => _db;

  final ProductCategoriesDao productCategories;
  final ShelfLocationsDao shelfLocations;
  final ProductsDao products;
  final ProductUnitConversionsDao productUnitConversions;
  final StockMovementsDao stockMovements;
  final CustomersDao customers;
  final UtangRecordsDao utangRecords;
  final SalesDao sales;
  final SaleItemsDao saleItems;

  // ── Cross-table atomic writes ──────────────────────────────────────────────

  /// Commits a complete sale: the [Sale] header, all [SaleItem] lines, the
  /// corresponding [StockMovement] rows, and the atomic stock-on-hand
  /// deductions — all in one SQLite transaction.
  ///
  /// If any single write fails (e.g. a product is missing), the entire
  /// operation is rolled back so the database is never left half-committed.
  Future<void> commitSale({
    required SalesCompanion sale,
    required List<SaleItemsCompanion> items,
    required List<StockMovementsCompanion> movements,
    required Map<String, double> stockDeltasByProductId,
  }) {
    return _db.transaction(() async {
      await sales.upsertLocal(sale);
      // SaleItems is an outbox-style table (insert-only, no LWW).
      await saleItems.insertManyLocal(items);
      for (final mv in movements) {
        await stockMovements.insertLocal(mv);
      }
      for (final entry in stockDeltasByProductId.entries) {
        await products.adjustStock(entry.key, entry.value);
      }
    });
  }

  /// Restocks one product: records the stock movement and adjusts the
  /// on-hand quantity atomically.
  Future<void> commitRestock({
    required StockMovementsCompanion movement,
    required String productId,
    required double delta,
  }) {
    return _db.transaction(() async {
      await stockMovements.insertLocal(movement);
      await products.adjustStock(productId, delta);
    });
  }

  /// Soft-deletes a sale (LWW-synced) and **hard-deletes** its line items in
  /// one transaction. SaleItems is an outbox-style table that travels embedded
  /// in the parent Sale's remote payload, so a hard delete is correct — the
  /// next push will report the empty item list for this sale.
  ///
  /// **Does not** roll back stock — restocking belongs to a separate, audited
  /// flow because it's a real-world business event, not a sync correction.
  Future<void> softDeleteSale({required String saleId}) {
    return _db.transaction(() async {
      await sales.softDelete(saleId);
      await saleItems.deleteForSale(saleId);
    });
  }
}
