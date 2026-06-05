import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../daos/app_meta_dao.dart';
import '../daos/tinda_tracker/product_categories_dao.dart';
import '../daos/tinda_tracker/product_unit_conversions_dao.dart';
import '../daos/tinda_tracker/products_dao.dart';
import '../daos/tinda_tracker/shelf_locations_dao.dart';
import '../daos/tinda_tracker/stock_movements_dao.dart';
import '../../../../tinda_tracker/features/inventory/data/models/custom_category.dart';
import '../../../../tinda_tracker/features/inventory/data/models/custom_shelf_location.dart';
import '../../../../tinda_tracker/features/inventory/data/models/inventory_product.dart';
import '../../../../tinda_tracker/features/inventory/data/models/product_unit_conversion.dart';
import '../../../../tinda_tracker/features/inventory/data/models/stock_movement.dart';
import '../../../../tinda_tracker/features/inventory/data/local_inventory_repository.dart'
    show
        InventorySummary,
        DuplicateSkuException,
        DuplicateNameException,
        QuickAccessLimitException,
        maxQuickAccessCategories;
import 'inventory_repository.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  InventoryRepositoryImpl({required AppDatabase database})
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

  @override
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
        (t) =>
            t.name.lower().like(pattern) |
            t.sku.lower().like(pattern) |
            t.customAttributesJson.lower().like(pattern),
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

  @override
  Future<InventoryProduct?> getById(String id) async {
    final row = await _productsDao.findById(id);
    if (row == null) return null;
    final conv = await _listConversionsForProductId(id);
    return InventoryProduct.fromRow(row, conversions: conv);
  }

  @override
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
    String itemType = 'standard',
    Map<String, dynamic> customAttributes = const {},
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
          itemType: Value(itemType),
          customAttributesJson: Value(json.encode(customAttributes)),
          createdAtMs: 0,
          updatedAtMs: 0,
        ),
      );
      await _writeConversions(id, unitConversions, deviceId: deviceId);
    });

    final saved = await getById(id);
    return saved!;
  }

  @override
  Future<InventoryProduct> updateProduct(
    String id, {
    Object? name = updateSentinel,
    Object? sku = updateSentinel,
    Object? description = updateSentinel,
    Object? category = updateSentinel,
    Object? unit = updateSentinel,
    Object? baseUnit = updateSentinel,
    Object? costPrice = updateSentinel,
    Object? sellingPrice = updateSentinel,
    Object? stockInBaseUnit = updateSentinel,
    Object? reorderPoint = updateSentinel,
    Object? isActive = updateSentinel,
    Object? shelfLocation = updateSentinel,
    Object? imagePath = updateSentinel,
    Object? expirationDate = updateSentinel,
    Object? unitConversions = updateSentinel,
    Object? itemType = updateSentinel,
    Object? customAttributes = updateSentinel,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    Value<T> v<T>(Object? raw) => identical(raw, updateSentinel)
        ? Value<T>.absent()
        : Value<T>(raw as T);

    final baseUnitValue = !identical(baseUnit, updateSentinel)
        ? Value<String>(baseUnit as String)
        : !identical(unit, updateSentinel)
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
      imageUrl: identical(imagePath, updateSentinel)
          ? const Value<String?>.absent()
          : const Value<String?>(null),
      expirationDateMs: identical(expirationDate, updateSentinel)
          ? const Value<int?>.absent()
          : Value<int?>((expirationDate as DateTime?)?.millisecondsSinceEpoch),
      itemType: v<String>(itemType),
      customAttributesJson: identical(customAttributes, updateSentinel)
          ? const Value<String>.absent()
          : Value(json.encode(customAttributes as Map<String, dynamic>)),
      isDirty: const Value(true),
      updatedAtMs: Value(now),
    );

    await _database.transaction(() async {
      await (_database.update(
        _database.products,
      )..where((t) => t.id.equals(id))).write(companion);
      if (!identical(unitConversions, updateSentinel)) {
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

  @override
  Future<void> deleteProduct(String id) => _productsDao.softDelete(id);

  @override
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

  @override
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

  @override
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

  @override
  Future<List<CustomCategory>> listCategories({
    bool includeDeleted = false,
  }) async {
    final query = _database.select(_database.productCategories);
    if (!includeDeleted) query.where((t) => t.isDeleted.equals(false));
    query.orderBy([(t) => OrderingTerm.asc(t.name)]);
    final rows = await query.get();
    return rows.map((r) => CustomCategory.fromRow(r)).toList(growable: false);
  }

  @override
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

  @override
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

  @override
  Future<CustomCategory> updateCategory(
    String id, {
    Object? name = updateSentinel,
    Object? description = updateSentinel,
    Object? examples = updateSentinel,
    Object? isQuickAccess = updateSentinel,
  }) async {
    var nameValue = const Value<String>.absent();
    if (!identical(name, updateSentinel)) {
      final trimmed = (name as String).trim();
      if (trimmed.isEmpty) {
        throw ArgumentError('Category name cannot be empty.');
      }
      await _assertCategoryNameAvailable(trimmed, excludeId: id);
      nameValue = Value(trimmed);
    }

    var quickAccessValue = const Value<bool>.absent();
    if (!identical(isQuickAccess, updateSentinel)) {
      if (isQuickAccess == true) {
        await _assertCanPinAnotherQuickAccessCategory(localIdAlreadyPinned: id);
      }
      quickAccessValue = Value(isQuickAccess as bool);
    }

    final companion = ProductCategoriesCompanion(
      name: nameValue,
      description: identical(description, updateSentinel)
          ? const Value<String>.absent()
          : Value(description as String),
      examples: identical(examples, updateSentinel)
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

  @override
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

  @override
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

  @override
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

  @override
  Future<CustomShelfLocation> updateShelfLocation(
    String id, {
    Object? name = updateSentinel,
    Object? description = updateSentinel,
    Object? examples = updateSentinel,
    Object? imagePath = updateSentinel,
  }) async {
    var nameValue = const Value<String>.absent();
    if (!identical(name, updateSentinel)) {
      final trimmed = (name as String).trim();
      if (trimmed.isEmpty) {
        throw ArgumentError('Shelf location name cannot be empty.');
      }
      await _assertShelfLocationNameAvailable(trimmed, excludeId: id);
      nameValue = Value(trimmed);
    }

    final companion = ShelfLocationsCompanion(
      name: nameValue,
      description: identical(description, updateSentinel)
          ? const Value<String>.absent()
          : Value(description as String),
      examples: identical(examples, updateSentinel)
          ? const Value<String>.absent()
          : Value(examples as String),
      imageLocalPath: identical(imagePath, updateSentinel)
          ? const Value<String?>.absent()
          : Value(imagePath as String?),
      imageUrl: identical(imagePath, updateSentinel)
          ? const Value<String?>.absent()
          : const Value<String?>(null),
      isDirty: const Value(true),
      updatedAtMs: Value(DateTime.now().millisecondsSinceEpoch),
    );

    await (_database.update(
      _database.shelfLocations,
    )..where((t) => t.id.equals(id))).write(companion);

    final row = await _shelvesDao.findById(id);
    return CustomShelfLocation.fromRow(row!);
  }

  @override
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
