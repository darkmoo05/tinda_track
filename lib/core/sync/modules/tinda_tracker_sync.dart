import 'dart:developer' as developer;

import '../../database/app_database.dart';
import '../../database/daos/tinda_tracker/customers_dao.dart';
import '../../database/daos/tinda_tracker/product_categories_dao.dart';
import '../../database/daos/tinda_tracker/product_unit_conversions_dao.dart';
import '../../database/daos/tinda_tracker/products_dao.dart';
import '../../database/daos/tinda_tracker/sale_items_dao.dart';
import '../../database/daos/tinda_tracker/sales_dao.dart';
import '../../database/daos/tinda_tracker/shelf_locations_dao.dart';
import '../../database/daos/tinda_tracker/utang_records_dao.dart';
import '../../../tinda_tracker/features/customers/data/mappers/customer_mapper.dart';
import '../../../tinda_tracker/features/customers/data/mappers/utang_record_mapper.dart';
import '../../../tinda_tracker/features/inventory/data/mappers/product_category_mapper.dart';
import '../../../tinda_tracker/features/inventory/data/mappers/product_mapper.dart';
import '../../../tinda_tracker/features/inventory/data/mappers/product_unit_conversion_mapper.dart';
import '../../../tinda_tracker/features/inventory/data/mappers/shelf_location_mapper.dart';
import '../../../tinda_tracker/features/pos/data/mappers/sale_item_mapper.dart';
import '../../../tinda_tracker/features/pos/data/mappers/sale_mapper.dart';
import '../remote/customer_remote_repository.dart';
import '../remote/product_category_remote_repository.dart';
import '../remote/product_remote_repository.dart';
import '../remote/product_unit_conversion_remote_repository.dart';
import '../remote/sale_remote_repository.dart';
import '../remote/shelf_location_remote_repository.dart';
import '../remote/utang_record_remote_repository.dart';
import '../retry_policy.dart';
import '../sync_result.dart';

/// Push+pull driver for every tinda_tracker entity.
///
/// `StockMovements` and `SaleItems` are intentionally **not** pushed as
/// stand-alone rows — Stock movements are derived server-side from sales and
/// restock orders; sale items travel embedded inside the parent Sale payload.
/// Locally we still flip their `is_dirty` flag for an outbox-style replay if
/// a transactional insert fails midway.
class TindaTrackerSync {
  TindaTrackerSync(this._db, {RetryPolicy? retryPolicy})
    : _retry = retryPolicy ?? const RetryPolicy(),
      _categories = ProductCategoriesDao(_db),
      _shelves = ShelfLocationsDao(_db),
      _products = ProductsDao(_db),
      _conversions = ProductUnitConversionsDao(_db),
      _customers = CustomersDao(_db),
      _utang = UtangRecordsDao(_db),
      _sales = SalesDao(_db),
      _saleItems = SaleItemsDao(_db);

  static const String moduleKey = 'tinda_tracker';

  final AppDatabase _db;
  final RetryPolicy _retry;
  final ProductCategoriesDao _categories;
  final ShelfLocationsDao _shelves;
  final ProductsDao _products;
  final ProductUnitConversionsDao _conversions;
  final CustomersDao _customers;
  final UtangRecordsDao _utang;
  final SalesDao _sales;
  final SaleItemsDao _saleItems;

  // ── Push ───────────────────────────────────────────────────────────────────

  Future<int> push() async {
    final pushed = await Future.wait([
      _pushCategories(),
      _pushShelves(),
      _pushProducts(),
      _pushConversions(),
      _pushCustomers(),
      _pushUtang(),
      _pushSales(),
    ]);
    return pushed.fold<int>(0, (a, b) => a + b);
  }

  Future<int> _pushCategories() async {
    final dirty = await _categories.pendingPush();
    if (dirty.isEmpty) return 0;
    final payload = dirty
        .map((r) => productCategoryToRemoteJson(r.toDomain()))
        .toList(growable: false);
    _log('push categories: dirty=${dirty.length}');
    final ok = await _retry.run(
      () => ProductCategoryRemoteRepository.instance.push(payload),
    );
    _log('push categories: ok=$ok');
    if (!ok) return 0;
    await _categories.markClean(dirty.map((r) => r.syncId));
    return dirty.length;
  }

  Future<int> _pushShelves() async {
    final dirty = await _shelves.pendingPush();
    if (dirty.isEmpty) return 0;
    final payload = dirty
        .map((r) => shelfLocationToRemoteJson(r.toDomain()))
        .toList(growable: false);
    _log('push shelves: dirty=${dirty.length}');
    final ok = await _retry.run(
      () => ShelfLocationRemoteRepository.instance.push(payload),
    );
    _log('push shelves: ok=$ok');
    if (!ok) return 0;
    await _shelves.markClean(dirty.map((r) => r.syncId));
    return dirty.length;
  }

  Future<int> _pushProducts() async {
    final dirty = await _products.pendingPush();
    if (dirty.isEmpty) return 0;
    final payload = dirty
        .map((r) => productToRemoteJson(r.toDomain()))
        .toList(growable: false);
    _log('push products: dirty=${dirty.length}');
    final ok = await _retry.run(
      () => ProductRemoteRepository.instance.push(payload),
    );
    _log('push products: ok=$ok');
    if (!ok) return 0;
    await _products.markClean(dirty.map((r) => r.syncId));
    return dirty.length;
  }

  Future<int> _pushConversions() async {
    final dirty = await _conversions.pendingPush();
    if (dirty.isEmpty) return 0;
    final payload = dirty
        .map((r) => productUnitConversionToRemoteJson(r.toDomain()))
        .toList(growable: false);
    _log('push conversions: dirty=${dirty.length}');
    final ok = await _retry.run(
      () => ProductUnitConversionRemoteRepository.instance.push(payload),
    );
    _log('push conversions: ok=$ok');
    if (!ok) return 0;
    await _conversions.markClean(dirty.map((r) => r.syncId));
    return dirty.length;
  }

  Future<int> _pushCustomers() async {
    final dirty = await _customers.pendingPush();
    if (dirty.isEmpty) return 0;
    final payload = dirty
        .map((r) => customerToRemoteJson(r.toDomain()))
        .toList(growable: false);
    _log('push customers: dirty=${dirty.length}');
    final ok = await _retry.run(
      () => CustomerRemoteRepository.instance.push(payload),
    );
    _log('push customers: ok=$ok');
    if (!ok) return 0;
    await _customers.markClean(dirty.map((r) => r.syncId));
    return dirty.length;
  }

  Future<int> _pushUtang() async {
    final dirty = await _utang.pendingPush();
    if (dirty.isEmpty) return 0;
    final payload = dirty
        .map((r) => utangRecordToRemoteJson(r.toDomain()))
        .toList(growable: false);
    _log('push utang: dirty=${dirty.length}');
    final ok = await _retry.run(
      () => UtangRecordRemoteRepository.instance.push(payload),
    );
    _log('push utang: ok=$ok');
    if (!ok) return 0;
    await _utang.markClean(dirty.map((r) => r.syncId));
    return dirty.length;
  }

  /// Pushes dirty sales **with their items embedded**. Items inherit the
  /// sale's clean status — they are not pushed standalone.
  Future<int> _pushSales() async {
    final dirty = await _sales.pendingPush();
    if (dirty.isEmpty) return 0;
    _log('push sales: dirty=${dirty.length}');
    final payload = <Map<String, dynamic>>[];
    for (final row in dirty) {
      final items = await _saleItems.listForSale(row.id);
      final sale = row.toDomain(
        items: items.map((i) => i.toDomain()).toList(growable: false),
      );
      payload.add(saleToRemoteJson(sale));
    }
    final ok = await _retry.run(
      () => SaleRemoteRepository.instance.push(payload),
    );
    _log('push sales: ok=$ok');
    if (!ok) return 0;
    await _sales.markClean(dirty.map((r) => r.syncId));
    // Mark the sale's items clean too — they were pushed embedded.
    final allItemIds = <String>[];
    for (final row in dirty) {
      final items = await _saleItems.listForSale(row.id);
      allItemIds.addAll(items.map((i) => i.id));
    }
    await _saleItems.markClean(allItemIds);
    return dirty.length;
  }

  // ── Pull ───────────────────────────────────────────────────────────────────

  Future<({int pulled, int conflicts})> pull({
    required String deviceId,
    required int sinceMs,
  }) async {
    final since = sinceMs == 0 ? null : sinceMs;
    final results = await Future.wait([
      _pullCategories(deviceId: deviceId, since: since),
      _pullShelves(deviceId: deviceId, since: since),
      _pullProducts(deviceId: deviceId, since: since),
      _pullConversions(deviceId: deviceId, since: since),
      _pullCustomers(deviceId: deviceId, since: since),
      _pullUtang(deviceId: deviceId, since: since),
      _pullSales(deviceId: deviceId, since: since),
    ]);
    var pulled = 0;
    var conflicts = 0;
    for (final r in results) {
      pulled += r.$1;
      conflicts += r.$2;
    }
    return (pulled: pulled, conflicts: conflicts);
  }

  Future<(int, int)> _pullCategories({
    required String deviceId,
    int? since,
  }) async {
    final records = await _retry.run(
      () => ProductCategoryRemoteRepository.instance.pull(
        deviceId: deviceId,
        since: since,
      ),
    );
    var conflicts = 0;
    for (final json in records) {
      final applied = await _categories.upsertFromRemote(
        productCategoryCompanionFromRemoteJson(json),
      );
      if (!applied) conflicts++;
    }
    return (records.length, conflicts);
  }

  Future<(int, int)> _pullShelves({
    required String deviceId,
    int? since,
  }) async {
    final records = await _retry.run(
      () => ShelfLocationRemoteRepository.instance.pull(
        deviceId: deviceId,
        since: since,
      ),
    );
    var conflicts = 0;
    for (final json in records) {
      final applied = await _shelves.upsertFromRemote(
        shelfLocationCompanionFromRemoteJson(json),
      );
      if (!applied) conflicts++;
    }
    return (records.length, conflicts);
  }

  Future<(int, int)> _pullProducts({
    required String deviceId,
    int? since,
  }) async {
    final records = await _retry.run(
      () => ProductRemoteRepository.instance.pull(
        deviceId: deviceId,
        since: since,
      ),
    );
    var conflicts = 0;
    for (final json in records) {
      final applied = await _products.upsertFromRemote(
        productCompanionFromRemoteJson(json),
      );
      if (!applied) conflicts++;
    }
    return (records.length, conflicts);
  }

  Future<(int, int)> _pullConversions({
    required String deviceId,
    int? since,
  }) async {
    final records = await _retry.run(
      () => ProductUnitConversionRemoteRepository.instance.pull(
        deviceId: deviceId,
        since: since,
      ),
    );
    var conflicts = 0;
    for (final json in records) {
      final applied = await _conversions.upsertFromRemote(
        productUnitConversionCompanionFromRemoteJson(json),
      );
      if (!applied) conflicts++;
    }
    return (records.length, conflicts);
  }

  Future<(int, int)> _pullCustomers({
    required String deviceId,
    int? since,
  }) async {
    final records = await _retry.run(
      () => CustomerRemoteRepository.instance.pull(
        deviceId: deviceId,
        since: since,
      ),
    );
    var conflicts = 0;
    for (final json in records) {
      final applied = await _customers.upsertFromRemote(
        customerCompanionFromRemoteJson(json),
      );
      if (!applied) conflicts++;
    }
    return (records.length, conflicts);
  }

  Future<(int, int)> _pullUtang({required String deviceId, int? since}) async {
    final records = await _retry.run(
      () => UtangRecordRemoteRepository.instance.pull(
        deviceId: deviceId,
        since: since,
      ),
    );
    var conflicts = 0;
    for (final json in records) {
      final applied = await _utang.upsertFromRemote(
        utangRecordCompanionFromRemoteJson(json),
      );
      if (!applied) conflicts++;
    }
    return (records.length, conflicts);
  }

  /// Pulls sales with embedded items. For each accepted sale, the local
  /// line items are replaced inside a single transaction.
  Future<(int, int)> _pullSales({required String deviceId, int? since}) async {
    final records = await _retry.run(
      () =>
          SaleRemoteRepository.instance.pull(deviceId: deviceId, since: since),
    );
    var conflicts = 0;
    for (final json in records) {
      final saleId = json['id'] as String;
      final saleCompanion = saleCompanionFromRemoteJson(json);
      final itemCompanions = saleItemCompanionsFromRemoteJson(json);
      final applied = await _db.transaction(() async {
        final accepted = await _sales.upsertFromRemote(saleCompanion);
        if (accepted) {
          await _saleItems.deleteForSale(saleId);
          for (final item in itemCompanions) {
            await _saleItems.insertLocal(item);
          }
          // Items applied from remote should not be dirty — clear flag.
          await _saleItems.markClean(itemCompanions.map((c) => c.id.value));
        }
        return accepted;
      });
      if (!applied) conflicts++;
    }
    return (records.length, conflicts);
  }

  // ── High-water mark ────────────────────────────────────────────────────────

  Future<int> maxUpdatedAt() async {
    final maxes = await Future.wait([
      _categories.maxUpdatedAt(),
      _shelves.maxUpdatedAt(),
      _products.maxUpdatedAt(),
      _conversions.maxUpdatedAt(),
      _customers.maxUpdatedAt(),
      _utang.maxUpdatedAt(),
      _sales.maxUpdatedAt(),
    ]);
    return maxes.fold<int>(0, (a, b) => a > b ? a : b);
  }

  Future<int> pendingCount() async {
    final lists = await Future.wait([
      _categories.pendingPush(),
      _shelves.pendingPush(),
      _products.pendingPush(),
      _conversions.pendingPush(),
      _customers.pendingPush(),
      _utang.pendingPush(),
      _sales.pendingPush(),
    ]);
    return lists.fold<int>(0, (a, b) => a + b.length);
  }

  void _log(String message) {
    developer.log(message, name: 'sync.tinda_tracker');
  }

  void logResult(SyncResult result) {
    _log(
      'pulled=${result.pulledCount} pushed=${result.pushedCount} '
      'conflicts=${result.conflictsResolved} '
      'error=${result.error}',
    );
  }
}
