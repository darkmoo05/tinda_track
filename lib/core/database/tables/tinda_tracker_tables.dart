import 'package:drift/drift.dart';

import 'pocket_ledger_tables.dart' show SyncedRow;

// ─────────────────────────────────────────────────────────────────────────────
// PRODUCT CATEGORY — Prisma `ProductCategory` (table `product_categories`).
// ─────────────────────────────────────────────────────────────────────────────
@DataClassName('ProductCategoryRow')
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
