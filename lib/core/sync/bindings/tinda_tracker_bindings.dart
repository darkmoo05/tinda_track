import 'dart:io';
import 'package:drift/drift.dart';
import '../../../tinda_tracker/features/customers/data/mappers/customer_mapper.dart';
import '../../../tinda_tracker/features/customers/data/mappers/utang_record_mapper.dart';
import '../../../tinda_tracker/features/inventory/data/mappers/product_category_mapper.dart';
import '../../../tinda_tracker/features/inventory/data/mappers/product_mapper.dart';
import '../../../tinda_tracker/features/inventory/data/mappers/product_unit_conversion_mapper.dart';
import '../../../tinda_tracker/features/inventory/data/mappers/shelf_location_mapper.dart';
import '../../../tinda_tracker/features/pos/data/mappers/sale_item_mapper.dart';
import '../../../tinda_tracker/features/pos/data/mappers/sale_mapper.dart';
import '../../database/app_database.dart';
import '../../database/daos/tinda_tracker/customers_dao.dart';
import '../../database/daos/tinda_tracker/product_categories_dao.dart';
import '../../database/daos/tinda_tracker/product_unit_conversions_dao.dart';
import '../../database/daos/tinda_tracker/products_dao.dart';
import '../../database/daos/tinda_tracker/sale_items_dao.dart';
import '../../database/daos/tinda_tracker/sales_dao.dart';
import '../../database/daos/tinda_tracker/shelf_locations_dao.dart';
import '../../database/daos/tinda_tracker/utang_records_dao.dart';
import '../../database/daos/tinda_tracker_dao.dart';
import '../engine/entity_sync.dart';
import '../engine/retry_policy.dart';
import '../engine/sync_errors.dart';
import '../engine/sync_module.dart';
import '../remote/customer_remote_repository.dart';
import '../remote/product_category_remote_repository.dart';
import '../remote/product_remote_repository.dart';
import '../remote/product_unit_conversion_remote_repository.dart';
import '../remote/sale_remote_repository.dart';
import '../remote/shelf_location_remote_repository.dart';
import '../remote/utang_record_remote_repository.dart';

/// Builds the `tinda_tracker` [SyncModule].
///
/// Special cases:
/// * **Sales** ride with their child [SaleItem]s embedded in both directions
///   — see [_SalesEntitySync] which overrides push/pull to walk the items
///   DAO and commit pulled items inside a Drift transaction.
/// * **SaleItems** never sync standalone — embedded above.
/// * **StockMovements** never sync — they're derived server-side and the
///   local table is an outbox for offline replay only.
SyncModule buildTindaTrackerModule(TindaTrackerDao dao) {
  final AppDatabase db = dao.database;
  final ProductCategoriesDao categories = dao.productCategories;
  final ShelfLocationsDao shelves = dao.shelfLocations;
  final ProductsDao products = dao.products;
  final ProductUnitConversionsDao conversions = dao.productUnitConversions;
  final CustomersDao customers = dao.customers;
  final UtangRecordsDao utang = dao.utangRecords;
  final SalesDao sales = dao.sales;
  final SaleItemsDao saleItems = dao.saleItems;

  return SyncModule(
    key: 'tinda_tracker',
    runInTransaction: dao.database.transaction,
    entities: [
      EntitySync<ProductCategoryRow>(
        entityKey: 'product_categories',
        route: '/inventory/categories',
        pendingPush: categories.pendingPush,
        markClean: categories.markClean,
        maxUpdatedAt: categories.maxUpdatedAt,
        toRemoteJson: (row) => productCategoryToRemoteJson(row.toDomain()),
        applyRemote: (json) => categories.upsertFromRemote(
          productCategoryCompanionFromRemoteJson(json),
        ),
        pushRemote: (p) => ProductCategoryRemoteRepository.instance.push(p),
        pullRemote: ({required deviceId, since}) =>
            ProductCategoryRemoteRepository.instance.pull(
              deviceId: deviceId,
              since: since,
            ),
      ),
      EntitySync<ShelfLocationRow>(
        entityKey: 'shelf_locations',
        route: '/inventory/shelves',
        pendingPush: shelves.pendingPush,
        markClean: shelves.markClean,
        maxUpdatedAt: shelves.maxUpdatedAt,
        toRemoteJson: (row) => shelfLocationToRemoteJson(row.toDomain()),
        applyRemote: (json) => shelves.upsertFromRemote(
          shelfLocationCompanionFromRemoteJson(json),
        ),
        pushRemote: (p) => ShelfLocationRemoteRepository.instance.push(p),
        pullRemote: ({required deviceId, since}) =>
            ShelfLocationRemoteRepository.instance.pull(
              deviceId: deviceId,
              since: since,
            ),
        postPushHook: (acked) async {
          for (final row in acked) {
            if (row.imageLocalPath != null && row.imageUrl == null) {
              final file = File(row.imageLocalPath!);
              if (await file.exists()) {
                final url = await ShelfLocationRemoteRepository.instance.uploadImage(row.id, file);
                if (url != null) {
                  await (shelves.update(shelves.shelfLocations)..where((t) => t.id.equals(row.id))).write(
                    ShelfLocationsCompanion(
                      imageUrl: Value(url),
                      isDirty: const Value(false),
                    ),
                  );
                }
              }
            }
          }
        },
      ),
      EntitySync<ProductRow>(
        entityKey: 'products',
        route: '/inventory/products',
        pendingPush: products.pendingPush,
        markClean: products.markClean,
        maxUpdatedAt: products.maxUpdatedAt,
        toRemoteJson: (row) => productToRemoteJson(row.toDomain()),
        applyRemote: (json) =>
            products.upsertFromRemote(productCompanionFromRemoteJson(json)),
        pushRemote: (p) => ProductRemoteRepository.instance.push(p),
        pullRemote: ({required deviceId, since}) => ProductRemoteRepository
            .instance
            .pull(deviceId: deviceId, since: since),
        postPushHook: (acked) async {
          for (final row in acked) {
            if (row.imageLocalPath != null && row.imageUrl == null) {
              final file = File(row.imageLocalPath!);
              if (await file.exists()) {
                final url = await ProductRemoteRepository.instance.uploadImage(row.id, file);
                if (url != null) {
                  await (products.update(products.products)..where((t) => t.id.equals(row.id))).write(
                    ProductsCompanion(
                      imageUrl: Value(url),
                      isDirty: const Value(false),
                    ),
                  );
                }
              }
            }
          }
        },
      ),
      EntitySync<ProductUnitConversionRow>(
        entityKey: 'product_unit_conversions',
        route: '/inventory/unit-conversions',
        pendingPush: conversions.pendingPush,
        markClean: conversions.markClean,
        maxUpdatedAt: conversions.maxUpdatedAt,
        toRemoteJson: (row) =>
            productUnitConversionToRemoteJson(row.toDomain()),
        applyRemote: (json) => conversions.upsertFromRemote(
          productUnitConversionCompanionFromRemoteJson(json),
        ),
        pushRemote: (p) =>
            ProductUnitConversionRemoteRepository.instance.push(p),
        pullRemote: ({required deviceId, since}) =>
            ProductUnitConversionRemoteRepository.instance.pull(
              deviceId: deviceId,
              since: since,
            ),
      ),
      EntitySync<CustomerRow>(
        entityKey: 'customers',
        route: '/customers',
        pendingPush: customers.pendingPush,
        markClean: customers.markClean,
        maxUpdatedAt: customers.maxUpdatedAt,
        toRemoteJson: (row) => customerToRemoteJson(row.toDomain()),
        applyRemote: (json) =>
            customers.upsertFromRemote(customerCompanionFromRemoteJson(json)),
        pushRemote: (p) => CustomerRemoteRepository.instance.push(p),
        pullRemote: ({required deviceId, since}) => CustomerRemoteRepository
            .instance
            .pull(deviceId: deviceId, since: since),
      ),
      EntitySync<UtangRecordRow>(
        entityKey: 'utang_records',
        route: '/utang-records',
        pendingPush: utang.pendingPush,
        markClean: utang.markClean,
        maxUpdatedAt: utang.maxUpdatedAt,
        toRemoteJson: (row) => utangRecordToRemoteJson(row.toDomain()),
        applyRemote: (json) =>
            utang.upsertFromRemote(utangRecordCompanionFromRemoteJson(json)),
        pushRemote: (p) => UtangRecordRemoteRepository.instance.push(p),
        pullRemote: ({required deviceId, since}) => UtangRecordRemoteRepository
            .instance
            .pull(deviceId: deviceId, since: since),
      ),
      _SalesEntitySync(db: db, sales: sales, saleItems: saleItems),
    ],
  );
}

/// Bespoke [EntitySync] for sales: push embeds children, pull replaces
/// them atomically inside a Drift transaction.
class _SalesEntitySync extends EntitySync<SaleRow> {
  _SalesEntitySync({
    required AppDatabase db,
    required SalesDao sales,
    required SaleItemsDao saleItems,
  }) : _db = db,
       _sales = sales,
       _saleItems = saleItems,
       super(
         entityKey: 'sales',
         route: '/sales',
         pendingPush: sales.pendingPush,
         markClean: sales.markClean,
         maxUpdatedAt: sales.maxUpdatedAt,
         // Base impls bypassed by the overrides below.
         toRemoteJson: _unused,
         applyRemote: _unusedApply,
         pushRemote: _unusedPush,
         pullRemote: ({required deviceId, since}) => SaleRemoteRepository
             .instance
             .pull(deviceId: deviceId, since: since),
       );

  final AppDatabase _db;
  final SalesDao _sales;
  final SaleItemsDao _saleItems;

  static Map<String, dynamic> _unused(SaleRow _) =>
      throw UnimplementedError('overridden');
  static Future<bool> _unusedApply(Map<String, dynamic> _) async => false;
  static Future<bool> _unusedPush(List<Map<String, dynamic>> _) async => true;

  @override
  Future<int> push(RetryPolicy retry) async {
    // BUG-3 fix: read dirty sales and their line items inside one Drift
    // transaction so the (sale, items) snapshot is consistent even if the
    // POS commits a new sale concurrently.
    final assembled = await _db.transaction(() async {
      final dirty = await _sales.pendingPush();
      if (dirty.isEmpty) {
        return (
          payload: const <Map<String, dynamic>>[],
          saleSyncIds: const <String>[],
          itemIds: const <String>[],
        );
      }
      final payload = <Map<String, dynamic>>[];
      final itemIds = <String>[];
      for (final row in dirty) {
        final items = await _saleItems.listForSale(row.id);
        itemIds.addAll(items.map((i) => i.id));
        final sale = row.toDomain(
          items: items.map((i) => i.toDomain()).toList(growable: false),
        );
        payload.add(saleToRemoteJson(sale));
      }
      return (
        payload: payload,
        saleSyncIds: dirty.map((r) => r.syncId).toList(growable: false),
        itemIds: itemIds,
      );
    });

    if (assembled.payload.isEmpty) return 0;

    final ok = await retry.run(
      () => SaleRemoteRepository.instance.push(assembled.payload),
    );
    if (!ok) {
      // BUG-6 parity: surface the failure so the engine records it.
      throw PushRejectedError(
        'pushRemote returned false for sales '
        '(${assembled.payload.length} sale(s))',
      );
    }

    // Mark sales and their line items clean atomically.
    await _db.transaction(() async {
      await _sales.markClean(assembled.saleSyncIds);
      await _saleItems.markClean(assembled.itemIds);
    });
    return assembled.payload.length;
  }

  @override
  Future<EntityPullOutcome> pull({
    required RetryPolicy retry,
    required String deviceId,
    int? since,
  }) async {
    final records = await retry.run(
      () =>
          SaleRemoteRepository.instance.pull(deviceId: deviceId, since: since),
    );
    var conflicts = 0;
    var maxServer = 0;
    for (final json in records) {
      final saleId = json['id'] as String?;
      if (saleId == null || saleId.isEmpty) {
        // Malformed payload — skip rather than crash.
        continue;
      }
      final saleCompanion = saleCompanionFromRemoteJson(json);
      final itemCompanions = saleItemCompanionsFromRemoteJson(json);

      // BUG-4 fix: guard companion ids before reading `.value`. Drop any
      // items whose id is absent so `markClean` cannot throw.
      final cleanableItemIds = <String>[
        for (final c in itemCompanions)
          if (c.id.present) c.id.value,
      ];

      final applied = await _db.transaction(() async {
        final accepted = await _sales.upsertFromRemote(saleCompanion);
        if (!accepted) return false;

        // BUG-9 fix: do NOT blindly wipe local items — a user may have added
        // items offline that haven't been pushed yet. Keep any local row
        // that is still dirty, replace everything else with the server copy.
        final localItems = await _saleItems.listForSale(saleId);
        final dirtyLocalIds = {
          for (final it in localItems)
            if (it.isDirty) it.id,
        };
        for (final it in localItems) {
          if (!dirtyLocalIds.contains(it.id)) {
            // Hard-delete the acknowledged-clean local row; the server copy
            // (if any) is reinserted below.
            await (_db.delete(
              _db.saleItems,
            )..where((t) => t.id.equals(it.id))).go();
          }
        }
        for (final item in itemCompanions) {
          if (item.id.present && dirtyLocalIds.contains(item.id.value)) {
            // Keep the dirty local edit; skip the server copy until our
            // next push cycle reconciles it.
            continue;
          }
          await _saleItems.insertLocal(item);
        }
        await _saleItems.markClean(cleanableItemIds);
        return true;
      });
      if (!applied) conflicts++;

      // Track server cursor (BUG-2 parity).
      final v = json['updated_at_ms'] ?? json['updatedAtMs'];
      if (v is int && v > maxServer) {
        maxServer = v;
      } else if (v is num && v.toInt() > maxServer) {
        maxServer = v.toInt();
      }
    }
    return EntityPullOutcome(
      pulled: records.length,
      conflicts: conflicts,
      maxServerUpdatedAtMs: maxServer,
    );
  }
}
