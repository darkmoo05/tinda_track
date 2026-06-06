import 'package:drift/drift.dart';

import 'pocket_ledger_tables.dart' show SyncedRow;

// ─────────────────────────────────────────────────────────────────────────────
// PRODUCT CATEGORY — Prisma `ProductCategory` (table `product_categories`).
// ─────────────────────────────────────────────────────────────────────────────
@DataClassName('ProductCategoryRow')
@TableIndex(name: 'product_categories_is_dirty_idx', columns: {#isDirty})
class ProductCategories extends Table with SyncedRow {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get examples => text().withDefault(const Constant(''))();
  BoolColumn get isQuickAccess =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {name},
  ];

  @override
  String? get tableName => 'product_categories';
}

// ─────────────────────────────────────────────────────────────────────────────
// SHELF LOCATION — Prisma `ShelfLocation` (table `shelf_locations`).
// `image_url` holds the server URL; `image_local_path` is a local-only column
// (NOT synced) used by the UI when offline.
// ─────────────────────────────────────────────────────────────────────────────
@DataClassName('ShelfLocationRow')
@TableIndex(name: 'shelf_locations_is_dirty_idx', columns: {#isDirty})
class ShelfLocations extends Table with SyncedRow {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get examples => text().withDefault(const Constant(''))();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get imageLocalPath => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {name},
  ];

  @override
  String? get tableName => 'shelf_locations';
}

// ─────────────────────────────────────────────────────────────────────────────
// PRODUCT — Prisma `Product` (table `products`).
// Denormalised `category` and `shelf_location` name snapshots are kept in sync
// with the FK relations by the repository layer.
// ─────────────────────────────────────────────────────────────────────────────
@DataClassName('ProductRow')
@TableIndex(name: 'products_category_id_idx', columns: {#categoryId})
@TableIndex(name: 'products_shelf_location_id_idx', columns: {#shelfLocationId})
@TableIndex(name: 'products_is_dirty_idx', columns: {#isDirty})
@TableIndex(name: 'products_name_idx', columns: {#name})
class Products extends Table with SyncedRow {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get sku => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get category => text().withDefault(const Constant('General'))();
  TextColumn get baseUnit => text().withDefault(const Constant('pcs'))();
  RealColumn get costPrice => real().withDefault(const Constant(0))();
  RealColumn get sellingPrice => real()();
  RealColumn get stockInBaseUnit => real().withDefault(const Constant(0))();
  IntColumn get reorderPoint => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get imageLocalPath => text().nullable()();
  TextColumn get shelfLocation =>
      text().nullable().withDefault(const Constant('Counter'))();
  IntColumn get expirationDateMs => integer().nullable()();
  TextColumn get categoryId =>
      text().nullable().references(ProductCategories, #id)();
  TextColumn get shelfLocationId =>
      text().nullable().references(ShelfLocations, #id)();

  // Multi-industry dynamic attributes & extensions (Phase 2)
  TextColumn get itemType => text().withDefault(const Constant('standard'))();
  TextColumn get customAttributesJson =>
      text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {sku},
  ];

  @override
  String? get tableName => 'products';
}

// ─────────────────────────────────────────────────────────────────────────────
// PRODUCT UNIT CONVERSION — Prisma `ProductUnitConversion`.
// Stored prices as REAL on SQLite (Prisma Decimal(12,2) on Postgres). The
// repository rounds to 2dp on write.
// ─────────────────────────────────────────────────────────────────────────────
@DataClassName('ProductUnitConversionRow')
@TableIndex(name: 'product_unit_conversions_product_id_idx', columns: {#productId})
@TableIndex(name: 'product_unit_conversions_is_dirty_idx', columns: {#isDirty})
class ProductUnitConversions extends Table with SyncedRow {
  TextColumn get id => text()();
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get unitName => text()();
  RealColumn get conversionFactor => real()();
  RealColumn get costPrice => real()();
  RealColumn get sellingPrice => real()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String? get tableName => 'product_unit_conversions';
}

// ─────────────────────────────────────────────────────────────────────────────
// STOCK MOVEMENT — Prisma `StockMovement`.
// `movement_type` is TEXT (RESTOCK | ADJUSTMENT | SALE) and validated by code.
// Not a `SyncedRow` because the server schema has no sync_id/device_id —
// these are derived from sales/restocks server-side. We track local dirty rows
// in a tiny outbox approach (`is_dirty` only).
// ─────────────────────────────────────────────────────────────────────────────
@DataClassName('StockMovementRow')
@TableIndex(name: 'stock_movements_product_id_idx', columns: {#productId})
@TableIndex(name: 'stock_movements_is_dirty_idx', columns: {#isDirty})
@TableIndex(name: 'stock_movements_created_at_ms_idx', columns: {#createdAtMs})
class StockMovements extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get movementType => text()();
  RealColumn get quantity => real()();
  RealColumn get previousQuantity => real()();
  RealColumn get newQuantity => real()();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get reference => text().withDefault(const Constant(''))();
  IntColumn get expirationDateMs => integer().nullable()();
  IntColumn get createdAtMs => integer()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String? get tableName => 'stock_movements';
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOMER / UTANG — Prisma `Customer` and `UtangRecord`.
// ─────────────────────────────────────────────────────────────────────────────
@DataClassName('CustomerRow')
@TableIndex(name: 'customers_is_dirty_idx', columns: {#isDirty})
@TableIndex(name: 'customers_name_idx', columns: {#name})
class Customers extends Table with SyncedRow {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().withDefault(const Constant(''))();
  TextColumn get address => text().withDefault(const Constant(''))();
  TextColumn get notes => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String? get tableName => 'customers';
}

@DataClassName('UtangRecordRow')
@TableIndex(name: 'utang_records_customer_id_idx', columns: {#customerId})
@TableIndex(name: 'utang_records_is_dirty_idx', columns: {#isDirty})
class UtangRecords extends Table with SyncedRow {
  TextColumn get id => text()();
  TextColumn get customerId => text().references(Customers, #id)();
  TextColumn get description => text().withDefault(const Constant(''))();
  RealColumn get amount => real()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String? get tableName => 'utang_records';
}

// ─────────────────────────────────────────────────────────────────────────────
// SALE / SALE ITEM — Prisma `Sale` and `SaleItem`.
// ─────────────────────────────────────────────────────────────────────────────
@DataClassName('SaleRow')
@TableIndex(name: 'sales_is_dirty_idx', columns: {#isDirty})
@TableIndex(name: 'sales_created_at_ms_idx', columns: {#createdAtMs})
class Sales extends Table with SyncedRow {
  TextColumn get id => text()();
  TextColumn get reference => text()();
  TextColumn get note => text().withDefault(const Constant(''))();
  RealColumn get subtotal => real()();
  RealColumn get totalAmount => real()();
  RealColumn get paidAmount => real()();
  RealColumn get changeAmount => real().withDefault(const Constant(0))();
  IntColumn get totalItems => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {reference},
  ];

  @override
  String? get tableName => 'sales';
}

@DataClassName('SaleItemRow')
@TableIndex(name: 'sale_items_sale_id_idx', columns: {#saleId})
@TableIndex(name: 'sale_items_product_id_idx', columns: {#productId})
@TableIndex(name: 'sale_items_is_dirty_idx', columns: {#isDirty})
class SaleItems extends Table {
  TextColumn get id => text()();
  TextColumn get saleId => text().references(Sales, #id)();
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get selectedUnit => text()();
  RealColumn get quantity => real()();
  RealColumn get unitPrice => real()();
  RealColumn get computedBaseQuantity => real()();
  RealColumn get lineTotal => real()();
  IntColumn get createdAtMs => integer()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String? get tableName => 'sale_items';
}

// ─────────────────────────────────────────────────────────────────────────────
// PRODUCT SERIAL NUMBER — Prisma `ProductSerialNumber` (table `product_serial_numbers`).
// ─────────────────────────────────────────────────────────────────────────────
@DataClassName('ProductSerialNumberRow')
@TableIndex(name: 'product_serial_numbers_product_idx', columns: {#productId})
@TableIndex(name: 'product_serial_numbers_is_dirty_idx', columns: {#isDirty})
class ProductSerialNumbers extends Table with SyncedRow {
  TextColumn get id => text()();
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get serialNumber => text()();
  TextColumn get status => text().withDefault(const Constant('AVAILABLE'))(); // AVAILABLE, SOLD, WASTE, RETURNED

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {productId, serialNumber},
  ];

  @override
  String? get tableName => 'product_serial_numbers';
}

// ─────────────────────────────────────────────────────────────────────────────
// PRODUCT RECIPE INGREDIENT — Prisma `ProductRecipeIngredient` (table `product_recipe_ingredients`).
// Maps a parent recipe/dish product to its ingredient products.
// ─────────────────────────────────────────────────────────────────────────────
@DataClassName('ProductRecipeIngredientRow')
@TableIndex(name: 'product_recipe_ingredients_recipe_idx', columns: {#recipeProductId})
@TableIndex(name: 'product_recipe_ingredients_is_dirty_idx', columns: {#isDirty})
class ProductRecipeIngredients extends Table with SyncedRow {
  TextColumn get id => text()();
  @ReferenceName('recipeProductRefs')
  TextColumn get recipeProductId => text().references(Products, #id)();

  @ReferenceName('ingredientProductRefs')
  TextColumn get ingredientProductId => text().references(Products, #id)();
  RealColumn get quantityNeeded => real()(); // quantity of ingredient needed for 1 unit of recipe (in ingredient's baseUnit)

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {recipeProductId, ingredientProductId},
  ];

  @override
  String? get tableName => 'product_recipe_ingredients';
}
