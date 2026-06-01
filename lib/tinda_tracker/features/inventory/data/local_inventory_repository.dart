import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/app_meta_dao.dart';
import '../../../../core/database/daos/tinda_tracker/product_categories_dao.dart';
import '../../../../core/database/daos/tinda_tracker/product_unit_conversions_dao.dart';
import '../../../../core/database/daos/tinda_tracker/products_dao.dart';
import '../../../../core/database/daos/tinda_tracker/shelf_locations_dao.dart';
import '../../../../core/database/daos/tinda_tracker/stock_movements_dao.dart';
import '../../../../core/di/database_providers.dart';
import 'models/custom_category.dart';
import 'models/custom_shelf_location.dart';
import 'models/inventory_product.dart';
import 'models/product_unit_conversion.dart';
import 'models/stock_movement.dart';

/// Hard cap on the number of categories that can be pinned to the dashboard
/// chip row. Enforced by [LocalInventoryRepository] on every mutating call.
const int maxQuickAccessCategories = 10;

/// Riverpod provider for [LocalInventoryRepository]. Consumers should obtain
/// the repository via `ref.read(localInventoryRepositoryProvider)`.
final localInventoryRepositoryProvider = Provider<LocalInventoryRepository>((
  ref,
) {
  return LocalInventoryRepository(database: ref.watch(appDatabaseProvider));
});

/// Sentinel used by [LocalInventoryRepository.updateProduct] (and the
/// lookup-table updates) so callers can distinguish *omitted* from
/// *explicitly set to null* for nullable fields.
const Object _updateSentinel = Object();

/// Inventory-domain repository: CRUD for products, categories, shelf
/// locations, unit conversions, and stock movements against the local
/// Drift database. Push to the server is handled by `SyncOrchestrator`
/// via the `is_dirty` flags the DAOs set on every mutation.
///
/// All persistence goes through typed Drift DAOs — no raw SQL. The previous
/// sqflite-style `customStatement`/`customSelect` helpers were removed
/// because they bypassed the DAO contract (which auto-stamps `is_dirty=1`
/// and `updated_at_ms=now`) and made schema typos invisible until runtime.
class LocalInventoryRepository {
  LocalInventoryRepository({required AppDatabase database})
    : _database = database,
      _appMeta = AppMetaDao(database),
      _categoriesDao = ProductCategoriesDao(database),
      _shelvesDao = ShelfLocationsDao(database),
      _productsDao = ProductsDao(database),
      _conversionsDao = ProductUnitConversionsDao(database),
      _movementsDao = StockMovementsDao(database);

  final AppDatabase _database;
  final AppMetaDao _appMeta;
  final ProductCategoriesDao _categoriesDao;
  final ShelfLocationsDao _shelvesDao;
  final ProductsDao _productsDao;
  final ProductUnitConversionsDao _conversionsDao;
  final StockMovementsDao _movementsDao;
  static const _uuid = Uuid();

  // ───── Products ───────────────────────────────────────────────────────────

  /// Lists all non-deleted products (or all products if [includeDeleted]),
  /// optionally filtered by case-insensitive [search] across name / sku.
  Future<List<InventoryProduct>> listProducts({
    String? search,
    bool includeDeleted = false,
  }) async {
    final query = _database.select(_database.products);
    if (!includeDeleted) {
      query.where((t) => t.isDeleted.equals(false));
    }
    if (search != null && search.trim().isNotEmpty) {
      final pattern = '%${search.trim().toLowerCase()}%';
      query.where(
        (t) => t.name.lower().like(pattern) | t.sku.lower().like(pattern),
      );
    }
    query.orderBy([(t) => OrderingTerm.desc(t.createdAtMs)]);
    final rows = await query.get();
    if (rows.isEmpty) return const [];
    final conversionsById = await _loadConversionsByProductIds(
      rows.map((r) => r.id).toList(growable: false),
    );
    return rows
        .map(
          (row) => InventoryProduct.fromRow(
            row,
            conversions: conversionsById[row.id] ?? const [],
          ),
        )
        .toList(growable: false);
  }

  Future<InventoryProduct?> getById(String id) async {
    final row = await _productsDao.findById(id);
    if (row == null) return null;
    final conv = await _listConversionsForProductId(id);
    return InventoryProduct.fromRow(row, conversions: conv);
  }

  /// Creates a product. Throws [DuplicateSkuException] if [sku] already
  /// exists (including soft-deleted rows — caller decides whether to
  /// restock the existing row).
  Future<InventoryProduct> createProduct({
    required String name,
    required String sku,
    String description = '',
    String category = 'General',
    String unit = 'pcs',
    String? baseUnit,
    double costPrice = 0,
    required double sellingPrice,
    int stockQuantity = 0,
    double? stockInBaseUnit,
    int reorderPoint = 0,
    bool isActive = true,
    String shelfLocation = 'Counter',
    String? imagePath,
    DateTime? expirationDate,
    List<ProductUnitConversion> unitConversions = const [],
  }) async {
    final existing = await _productsDao.findBySku(sku);
    if (existing != null) {
      throw DuplicateSkuException(InventoryProduct.fromRow(existing));
    }
    final id = _uuid.v4();
    final deviceId = await _appMeta.getOrCreateDeviceId();
    final effectiveBaseUnit = baseUnit ?? unit;
    final stockBase = stockInBaseUnit ?? stockQuantity.toDouble();

    await _database.transaction(() async {
      await _productsDao.upsertLocal(
        ProductsCompanion.insert(
          id: id,
          syncId: id,
          deviceId: Value(deviceId),
          name: name,
          sku: sku,
          description: Value(description),
          category: Value(category),
          baseUnit: Value(effectiveBaseUnit),
          costPrice: Value(costPrice),
          sellingPrice: sellingPrice,
          stockInBaseUnit: Value(stockBase),
          reorderPoint: Value(reorderPoint),
          isActive: Value(isActive),
          imageLocalPath: Value(imagePath),
          shelfLocation: Value(shelfLocation),
          expirationDateMs: Value(expirationDate?.millisecondsSinceEpoch),
          createdAtMs: 0, // upsertLocal will stamp now
          updatedAtMs: 0,
        ),
      );
      await _writeConversions(id, unitConversions, deviceId: deviceId);
    });

    final saved = await getById(id);
    return saved!;
  }

  /// Patches a product. Use [_updateSentinel] semantics: pass `null` to
  /// clear a nullable column, omit (default sentinel) to leave unchanged.
  Future<InventoryProduct> updateProduct(
    String id, {
    Object? name = _updateSentinel,
    Object? sku = _updateSentinel,
    Object? description = _updateSentinel,
    Object? category = _updateSentinel,
    Object? unit = _updateSentinel,
    Object? baseUnit = _updateSentinel,
    Object? costPrice = _updateSentinel,
    Object? sellingPrice = _updateSentinel,
    Object? stockInBaseUnit = _updateSentinel,
    Object? reorderPoint = _updateSentinel,
    Object? isActive = _updateSentinel,
    Object? shelfLocation = _updateSentinel,
    Object? imagePath = _updateSentinel,
    Object? expirationDate = _updateSentinel,
    Object? unitConversions = _updateSentinel,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    Value<T> v<T>(Object? raw) => identical(raw, _updateSentinel)
        ? Value<T>.absent()
        : Value<T>(raw as T);

    // base_unit is the canonical column; `unit` is a legacy alias used when
    // baseUnit is omitted.
    final baseUnitValue = !identical(baseUnit, _updateSentinel)
        ? Value<String>(baseUnit as String)
        : !identical(unit, _updateSentinel)
        ? Value<String>(unit as String)
        : const Value<String>.absent();

    final companion = ProductsCompanion(
      name: v<String>(name),
      sku: v<String>(sku),
      description: v<String>(description),
      category: v<String>(category),
      baseUnit: baseUnitValue,
      costPrice: v<double>(costPrice),
      sellingPrice: v<double>(sellingPrice),
      stockInBaseUnit: v<double>(stockInBaseUnit),
      reorderPoint: v<int>(reorderPoint),
      isActive: v<bool>(isActive),
      shelfLocation: v<String?>(shelfLocation),
      imageLocalPath: v<String?>(imagePath),
      expirationDateMs: identical(expirationDate, _updateSentinel)
          ? const Value<int?>.absent()
          : Value<int?>((expirationDate as DateTime?)?.millisecondsSinceEpoch),
      isDirty: const Value(true),
      updatedAtMs: Value(now),
    );

    await _database.transaction(() async {
      await (_database.update(
        _database.products,
      )..where((t) => t.id.equals(id))).write(companion);
      if (!identical(unitConversions, _updateSentinel)) {
        final deviceId = await _appMeta.getOrCreateDeviceId();
        await _replaceProductConversions(
          id,
          unitConversions as List<ProductUnitConversion>,
          deviceId: deviceId,
        );
      }
    });

    final updated = await getById(id);
    if (updated == null) {
      throw StateError('Product $id was deleted during update.');
    }
    return updated;
  }

  /// Soft-deletes a product (sets `is_deleted=1`, `is_dirty=1`).
  Future<void> deleteProduct(String id) => _productsDao.softDelete(id);

  /// Adjusts stock for [productId] by [quantityDeltaBase] (in base units)
  /// and writes a `stock_movements` row. [quantityDelta] is kept for
  /// backwards compatibility with the legacy outbox payload; the canonical
  /// truth is [quantityDeltaBase].
  Future<void> adjustStock({
    required String productId,
    required int quantityDelta,
    double? quantityDeltaBase,
    required String movementType,
    String note = '',
    DateTime? expirationDate,
  }) async {
    final deltaBase = quantityDeltaBase ?? quantityDelta.toDouble();
    final now = DateTime.now().millisecondsSinceEpoch;
    final movementId = _uuid.v4();

    await _database.transaction(() async {
      final product = await _productsDao.findById(productId);
      if (product == null) {
        throw StateError('Product $productId not found.');
      }
      final prev = product.stockInBaseUnit;
      final next = prev + deltaBase;

      await (_database.update(
        _database.products,
      )..where((t) => t.id.equals(productId))).write(
        ProductsCompanion(
          stockInBaseUnit: Value(next),
          expirationDateMs: expirationDate == null
              ? const Value<int?>.absent()
              : Value<int?>(expirationDate.millisecondsSinceEpoch),
          isDirty: const Value(true),
          updatedAtMs: Value(now),
        ),
      );

      await _movementsDao.insertLocal(
        StockMovementsCompanion.insert(
          id: movementId,
          productId: productId,
          movementType: movementType,
          quantity: deltaBase,
          previousQuantity: prev,
          newQuantity: next,
          note: Value(note),
          expirationDateMs: Value(expirationDate?.millisecondsSinceEpoch),
          createdAtMs: now,
        ),
      );
    });
  }

  /// Returns the stock movement history for [productId], newest first.
  Future<List<StockMovement>> getMovementsForProduct(String productId) async {
    final rows =
        await (_database.select(_database.stockMovements)
              ..where((t) => t.productId.equals(productId))
              ..orderBy([(t) => OrderingTerm.desc(t.createdAtMs)]))
            .get();
    return rows
        .map(
          (r) => StockMovement(
            id: r.id,
            productId: r.productId,
            movementType: r.movementType,
            quantity: r.quantity.toInt(),
            previousQuantity: r.previousQuantity.toInt(),
            newQuantity: r.newQuantity.toInt(),
            note: r.note,
            reference: r.reference,
            createdAt: DateTime.fromMillisecondsSinceEpoch(r.createdAtMs),
            expirationDate: r.expirationDateMs == null
                ? null
                : DateTime.fromMillisecondsSinceEpoch(r.expirationDateMs!),
          ),
        )
        .toList(growable: false);
  }

  /// Aggregate counts/value used by the inventory summary card.
  Future<InventorySummary> getSummary() async {
    final products = await listProducts();
    return InventorySummary(
      totalProducts: products.length,
      totalStock: products.fold<int>(0, (s, p) => s + p.stockQuantity),
      lowStockCount: products.where((p) => p.isLowStock).length,
      outOfStockCount: products.where((p) => p.isOutOfStock).length,
      totalStockValue: products.fold<double>(0, (s, p) {
        final unit = p.costPrice > 0 ? p.costPrice : p.sellingPrice;
        return s + unit * p.stockQuantity;
      }),
    );
  }

  // ───── Unit conversions ───────────────────────────────────────────────────

  Future<Map<String, List<ProductUnitConversion>>> _loadConversionsByProductIds(
    List<String> productIds,
  ) async {
    if (productIds.isEmpty) return const {};
    final rows =
        await (_database.select(_database.productUnitConversions)..where(
              (t) => t.isDeleted.equals(false) & t.productId.isIn(productIds),
            ))
            .get();
    final out = <String, List<ProductUnitConversion>>{};
    for (final r in rows) {
      out
          .putIfAbsent(r.productId, () => [])
          .add(ProductUnitConversion.fromRow(r));
    }
    return out;
  }

  Future<List<ProductUnitConversion>> _listConversionsForProductId(
    String productId,
  ) async {
    final rows = await _conversionsDao.listForProduct(productId);
    return rows
        .map((r) => ProductUnitConversion.fromRow(r))
        .toList(growable: false);
  }

  Future<void> _writeConversions(
    String productId,
    List<ProductUnitConversion> conversions, {
    required String deviceId,
  }) async {
    if (conversions.isEmpty) return;
    for (final c in conversions) {
      final id = c.id.isNotEmpty ? c.id : _uuid.v4();
      await _conversionsDao.upsertLocal(
        ProductUnitConversionsCompanion.insert(
          id: id,
          syncId: id,
          deviceId: Value(deviceId),
          productId: productId,
          unitName: c.unitName,
          conversionFactor: c.conversionFactor,
          costPrice: c.costPrice,
          sellingPrice: c.sellingPrice,
          createdAtMs: 0,
          updatedAtMs: 0,
        ),
      );
    }
  }

  Future<void> _replaceProductConversions(
    String productId,
    List<ProductUnitConversion> conversions, {
    required String deviceId,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    // Soft-delete all existing rows for this product.
    await (_database.update(_database.productUnitConversions)..where(
          (t) => t.productId.equals(productId) & t.isDeleted.equals(false),
        ))
        .write(
          ProductUnitConversionsCompanion(
            isDeleted: const Value(true),
            isDirty: const Value(true),
            updatedAtMs: Value(now),
          ),
        );
    await _writeConversions(productId, conversions, deviceId: deviceId);
  }

  // ───── Categories ─────────────────────────────────────────────────────────

  Future<List<CustomCategory>> listCategories({
    bool includeDeleted = false,
  }) async {
    final query = _database.select(_database.productCategories);
    if (!includeDeleted) query.where((t) => t.isDeleted.equals(false));
    query.orderBy([(t) => OrderingTerm.asc(t.name)]);
    final rows = await query.get();
    return rows.map((r) => CustomCategory.fromRow(r)).toList(growable: false);
  }

  Future<int> countQuickAccessCategories() async {
    final count = _database.productCategories.id.count();
    final row =
        await (_database.selectOnly(_database.productCategories)
              ..addColumns([count])
              ..where(
                _database.productCategories.isDeleted.equals(false) &
                    _database.productCategories.isQuickAccess.equals(true),
              ))
            .getSingle();
    return row.read(count) ?? 0;
  }

  Future<CustomCategory> createCategory(
    String name, {
    String description = '',
    String examples = '',
    bool isQuickAccess = false,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Category name cannot be empty.');
    }
    await _assertCategoryNameAvailable(trimmed);
    if (isQuickAccess) {
      await _assertCanPinAnotherQuickAccessCategory();
    }
    final id = _uuid.v4();
    final deviceId = await _appMeta.getOrCreateDeviceId();
    await _categoriesDao.upsertLocal(
      ProductCategoriesCompanion.insert(
        id: id,
        syncId: id,
        deviceId: Value(deviceId),
        name: trimmed,
        description: Value(description),
        examples: Value(examples),
        isQuickAccess: Value(isQuickAccess),
        createdAtMs: 0,
        updatedAtMs: 0,
      ),
    );
    final row = await _categoriesDao.findById(id);
    return CustomCategory.fromRow(row!);
  }

  Future<CustomCategory> updateCategory(
    String id, {
    Object? name = _updateSentinel,
    Object? description = _updateSentinel,
    Object? examples = _updateSentinel,
    Object? isQuickAccess = _updateSentinel,
  }) async {
    var nameValue = const Value<String>.absent();
    if (!identical(name, _updateSentinel)) {
      final trimmed = (name as String).trim();
      if (trimmed.isEmpty) {
        throw ArgumentError('Category name cannot be empty.');
      }
      await _assertCategoryNameAvailable(trimmed, excludeId: id);
      nameValue = Value(trimmed);
    }

    var quickAccessValue = const Value<bool>.absent();
    if (!identical(isQuickAccess, _updateSentinel)) {
      if (isQuickAccess == true) {
        await _assertCanPinAnotherQuickAccessCategory(localIdAlreadyPinned: id);
      }
      quickAccessValue = Value(isQuickAccess as bool);
    }

    final companion = ProductCategoriesCompanion(
      name: nameValue,
      description: identical(description, _updateSentinel)
          ? const Value<String>.absent()
          : Value(description as String),
      examples: identical(examples, _updateSentinel)
          ? const Value<String>.absent()
          : Value(examples as String),
      isQuickAccess: quickAccessValue,
      isDirty: const Value(true),
      updatedAtMs: Value(DateTime.now().millisecondsSinceEpoch),
    );

    await (_database.update(
      _database.productCategories,
    )..where((t) => t.id.equals(id))).write(companion);

    final row = await _categoriesDao.findById(id);
    return CustomCategory.fromRow(row!);
  }

  Future<void> deleteCategory(String id) => _categoriesDao.softDelete(id);

  Future<void> _assertCategoryNameAvailable(
    String name, {
    String? excludeId,
  }) async {
    final query = _database.select(_database.productCategories)
      ..where(
        (t) =>
            t.isDeleted.equals(false) &
            t.name.lower().equals(name.toLowerCase()),
      )
      ..limit(1);
    final hits = await query.get();
    if (hits.any((r) => r.id != excludeId)) {
      throw DuplicateNameException(kind: 'category', name: name);
    }
  }

  Future<void> _assertCanPinAnotherQuickAccessCategory({
    String? localIdAlreadyPinned,
  }) async {
    final count = _database.productCategories.id.count();
    final builder = _database.selectOnly(_database.productCategories)
      ..addColumns([count])
      ..where(
        _database.productCategories.isDeleted.equals(false) &
            _database.productCategories.isQuickAccess.equals(true),
      );
    if (localIdAlreadyPinned != null) {
      builder.where(
        _database.productCategories.id.equals(localIdAlreadyPinned).not(),
      );
    }
    final row = await builder.getSingle();
    final pinned = row.read(count) ?? 0;
    if (pinned >= maxQuickAccessCategories) {
      throw const QuickAccessLimitException(maxQuickAccessCategories);
    }
  }

  // ───── Shelf locations ────────────────────────────────────────────────────

  Future<List<CustomShelfLocation>> listShelfLocations({
    bool includeDeleted = false,
  }) async {
    final query = _database.select(_database.shelfLocations);
    if (!includeDeleted) query.where((t) => t.isDeleted.equals(false));
    query.orderBy([(t) => OrderingTerm.asc(t.name)]);
    final rows = await query.get();
    return rows
        .map((r) => CustomShelfLocation.fromRow(r))
        .toList(growable: false);
  }

  Future<CustomShelfLocation> createShelfLocation(
    String name, {
    String description = '',
    String examples = '',
    String? imagePath,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Shelf location name cannot be empty.');
    }
    await _assertShelfLocationNameAvailable(trimmed);
    final id = _uuid.v4();
    final deviceId = await _appMeta.getOrCreateDeviceId();
    await _shelvesDao.upsertLocal(
      ShelfLocationsCompanion.insert(
        id: id,
        syncId: id,
        deviceId: Value(deviceId),
        name: trimmed,
        description: Value(description),
        examples: Value(examples),
        imageLocalPath: Value(imagePath),
        createdAtMs: 0,
        updatedAtMs: 0,
      ),
    );
    final row = await _shelvesDao.findById(id);
    return CustomShelfLocation.fromRow(row!);
  }

  Future<CustomShelfLocation> updateShelfLocation(
    String id, {
    Object? name = _updateSentinel,
    Object? description = _updateSentinel,
    Object? examples = _updateSentinel,
    Object? imagePath = _updateSentinel,
  }) async {
    var nameValue = const Value<String>.absent();
    if (!identical(name, _updateSentinel)) {
      final trimmed = (name as String).trim();
      if (trimmed.isEmpty) {
        throw ArgumentError('Shelf location name cannot be empty.');
      }
      await _assertShelfLocationNameAvailable(trimmed, excludeId: id);
      nameValue = Value(trimmed);
    }

    final companion = ShelfLocationsCompanion(
      name: nameValue,
      description: identical(description, _updateSentinel)
          ? const Value<String>.absent()
          : Value(description as String),
      examples: identical(examples, _updateSentinel)
          ? const Value<String>.absent()
          : Value(examples as String),
      imageLocalPath: identical(imagePath, _updateSentinel)
          ? const Value<String?>.absent()
          : Value(imagePath as String?),
      isDirty: const Value(true),
      updatedAtMs: Value(DateTime.now().millisecondsSinceEpoch),
    );

    await (_database.update(
      _database.shelfLocations,
    )..where((t) => t.id.equals(id))).write(companion);

    final row = await _shelvesDao.findById(id);
    return CustomShelfLocation.fromRow(row!);
  }

  Future<void> deleteShelfLocation(String id) => _shelvesDao.softDelete(id);

  Future<void> _assertShelfLocationNameAvailable(
    String name, {
    String? excludeId,
  }) async {
    final query = _database.select(_database.shelfLocations)
      ..where(
        (t) =>
            t.isDeleted.equals(false) &
            t.name.lower().equals(name.toLowerCase()),
      )
      ..limit(1);
    final hits = await query.get();
    if (hits.any((r) => r.id != excludeId)) {
      throw DuplicateNameException(kind: 'shelf location', name: name);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Exceptions and aggregates
// ─────────────────────────────────────────────────────────────────────────────

/// Thrown by [LocalInventoryRepository.createProduct] when an existing
/// product (including soft-deleted) already uses the same SKU. The
/// caller can offer a restock-the-existing-row flow with [existing].
class DuplicateSkuException implements Exception {
  final InventoryProduct existing;
  const DuplicateSkuException(this.existing);

  @override
  String toString() => 'DuplicateSkuException(existing=${existing.sku})';
}

/// Thrown when a category / shelf-location name collides with an
/// existing non-deleted row.
class DuplicateNameException implements Exception {
  /// Human-readable kind, e.g. 'category' or 'shelf location'.
  final String kind;
  final String name;
  const DuplicateNameException({required this.kind, required this.name});

  @override
  String toString() => 'DuplicateNameException($kind "$name")';
}

/// Thrown when pinning a category would exceed
/// [maxQuickAccessCategories].
class QuickAccessLimitException implements Exception {
  final int limit;
  const QuickAccessLimitException(this.limit);

  @override
  String toString() =>
      'QuickAccessLimitException(limit=$limit) — pin one fewer to add another.';
}

/// Aggregate counts/value for the inventory dashboard summary card.
class InventorySummary {
  final int totalProducts;
  final int totalStock;
  final int lowStockCount;
  final int outOfStockCount;
  final double totalStockValue;

  const InventorySummary({
    required this.totalProducts,
    required this.totalStock,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.totalStockValue,
  });
}
