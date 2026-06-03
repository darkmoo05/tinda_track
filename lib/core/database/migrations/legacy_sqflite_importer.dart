import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart' as raw;
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../daos/app_meta_dao.dart';

/// One-shot importer that copies data from the historical sqflite
/// `tinda_track.db` into the new Drift database, then deletes the old file.
///
/// Uses `package:sqlite3/sqlite3.dart` for read-only legacy operations,
/// avoiding dependencies on `sqflite` or `sqflite_common_ffi`.
class LegacyImporter {
  LegacyImporter(this._db, this._appMeta);

  final AppDatabase _db;
  final AppMetaDao _appMeta;

  static const String _statusKey = 'legacy_import_status';
  static const String _legacyDbName = 'tinda_track.db';

  static const String _statusDone = 'done';
  static const String _statusNotFound = 'not_found';
  static const String _statusFailed = 'failed';

  /// Resolves the legacy sqflite database path in a cross-platform manner.
  Future<String> _resolveLegacyPath() async {
    if (Platform.isWindows) {
      final localAppData = Platform.environment['LOCALAPPDATA'] ?? '';
      return p.join(localAppData, _legacyDbName);
    }
    
    if (Platform.isAndroid) {
      final docDir = await getApplicationDocumentsDirectory();
      final appDir = p.dirname(docDir.path);
      return p.join(appDir, 'databases', _legacyDbName);
    }
    
    // iOS and macOS default storage
    final docDir = await getApplicationDocumentsDirectory();
    return p.join(docDir.path, _legacyDbName);
  }

  /// Idempotent entry-point. Call once on app startup.
  Future<bool> runIfNeeded() async {
    // 1. SharedPreferences double-lock to prevent unnecessary FFI/db logic
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDone = prefs.getBool(_statusKey) ?? false;
      if (isDone) {
        _log('Legacy import already marked done in SharedPreferences.');
        return false;
      }
    } catch (e) {
      _log('SharedPreferences read failed: $e');
    }

    // 2. Db-meta fallback lock
    final status = await _appMeta.get(_statusKey);
    if (status == _statusDone || status == _statusNotFound) {
      _log('Legacy import status in database is "$status". Ensuring SharedPreferences matches.');
      await _markDoneInPrefs();
      return false;
    }

    final legacyPath = await _resolveLegacyPath();
    if (!await File(legacyPath).exists()) {
      await _appMeta.set(_statusKey, _statusNotFound);
      await _markDoneInPrefs();
      _log('No legacy DB at $legacyPath — nothing to import.');
      return false;
    }

    raw.Database? legacyDb;
    try {
      // Open the sqflite database read-only using raw FFI sqlite3
      final uriPath = 'file:${legacyPath.replaceAll('\\', '/')}?mode=ro';
      legacyDb = raw.sqlite3.open(uriPath, uri: true);
      
      final rows = await _import(legacyDb);
      
      // Perform strict row-count verification before marking done and deleting file
      await _validateRowCounts(legacyDb);
      
      legacyDb.dispose();
      legacyDb = null;

      await _deleteLegacyFile(legacyPath);
      await _appMeta.set(_statusKey, _statusDone);
      await _markDoneInPrefs();
      _log('Successfully imported $rows row(s) from legacy DB, validated, and deleted file.');
      return true;
    } catch (e, st) {
      legacyDb?.dispose();
      await _appMeta.set(_statusKey, _statusFailed);
      developer.log(
        'Legacy import failed: $e',
        name: 'legacy_importer',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  Future<void> _markDoneInPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_statusKey, true);
    } catch (e) {
      _log('Failed to write to SharedPreferences: $e');
    }
  }

  // ── Import driver ──────────────────────────────────────────────────────────

  /// Performs the entire migration atomically inside a single Drift transaction block
  Future<int> _import(raw.Database src) async {
    var total = 0;
    await _db.transaction(() async {
      total += await _importTransactionTypes(src);
      total += await _importMovementCategories(src);
      total += await _importParties(src);
      total += await _importCharges(src);
      total += await _importLedgerEntries(src);
      total += await _importFeeTransactions(src);

      total += await _importTtProductCategories(src);
      total += await _importTtShelfLocations(src);
      total += await _importTtProducts(src);
      total += await _importTtProductUnitConversions(src);
      total += await _importTtCustomers(src);
      total += await _importTtUtangRecords(src);
      total += await _importTtSales(src);
      total += await _importTtSaleItems(src);
      total += await _importTtStockMovements(src);
    });
    return total;
  }

  // ── Row Count Validation Helpers ──────────────────────────────────────────

  int _legacyRowCount(raw.Database src, String tableName) {
    try {
      final exists = src.select(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [tableName],
      );
      if (exists.isEmpty) return 0;
      final result = src.select('SELECT COUNT(*) as c FROM $tableName');
      if (result.isEmpty) return 0;
      return result.first['c'] as int? ?? 0;
    } catch (e) {
      _log('Failed to count rows in legacy table $tableName: $e');
      return 0;
    }
  }

  Future<int> _driftRowCount(Table table) async {
    final info = table as TableInfo;
    final countExpr = info.columnsByName.values.first.count();
    final query = _db.selectOnly(info)..addColumns([countExpr]);
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  Future<void> _validateRowCounts(raw.Database src) async {
    final validations = [
      (legacy: 'charges', drift: _db.charges),
      (legacy: 'parties', drift: _db.parties),
      (legacy: 'transaction_types', drift: _db.transactionTypes),
      (legacy: 'owner_movement_categories', drift: _db.movementCategories),
      (legacy: 'ledger_entries', drift: _db.ledgerEntries),
      (legacy: 'fee_transactions', drift: _db.feeTransactions),
      (legacy: 'tt_product_categories', drift: _db.productCategories),
      (legacy: 'tt_shelf_locations', drift: _db.shelfLocations),
      (legacy: 'tt_products', drift: _db.products),
      (legacy: 'tt_product_unit_conversions', drift: _db.productUnitConversions),
      (legacy: 'tt_customers', drift: _db.customers),
      (legacy: 'tt_utang_records', drift: _db.utangRecords),
      (legacy: 'tt_sales', drift: _db.sales),
      (legacy: 'tt_sale_items', drift: _db.saleItems),
      (legacy: 'tt_stock_movements', drift: _db.stockMovements),
    ];

    for (final v in validations) {
      final legacyCount = _legacyRowCount(src, v.legacy);
      final driftCount = await _driftRowCount(v.drift);
      _log('Row count validation for ${v.legacy}: legacy = $legacyCount, drift = $driftCount');
      if (driftCount != legacyCount) {
        throw StateError(
          'Row count mismatch for table ${v.legacy}: legacy database has $legacyCount rows, '
          'but Drift database has $driftCount rows after import.',
        );
      }
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _syncId(Map<String, Object?> row) {
    final v = row['sync_id'] as String?;
    if (v != null && v.isNotEmpty) return v;
    return const Uuid().v4();
  }

  int _ms(Object? v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) {
      final asInt = int.tryParse(v);
      if (asInt != null) return asInt;
      final dt = DateTime.tryParse(v);
      if (dt != null) return dt.millisecondsSinceEpoch;
    }
    return fallback;
  }

  bool _bool(Object? v, {bool fallback = false}) {
    if (v == null) return fallback;
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final lower = v.toLowerCase();
      return lower == '1' || lower == 'true';
    }
    return fallback;
  }

  double _real(Object? v, {double fallback = 0}) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  String _str(Object? v, {String fallback = ''}) {
    if (v == null) return fallback;
    return v.toString();
  }

  ({int createdAt, int updatedAt}) _timestamps(Map<String, Object?> row) {
    final created = _ms(row['created_at_ms']) != 0
        ? _ms(row['created_at_ms'])
        : _ms(row['created_at']);
    final updated = _ms(row['updated_at_ms']) != 0
        ? _ms(row['updated_at_ms'])
        : (_ms(row['updated_at']) != 0
              ? _ms(row['updated_at'])
              : (created != 0
                    ? created
                    : DateTime.now().millisecondsSinceEpoch));
    return (createdAt: created != 0 ? created : updated, updatedAt: updated);
  }

  // ── Per-table importers ────────────────────────────────────────────────────

  Future<int> _importCharges(raw.Database src) async {
    final rows = _safeQuery(src, 'charges');
    for (final r in rows) {
      final id = _syncId(r);
      final ts = _timestamps(r);
      await _db.into(_db.charges).insertOnConflictUpdate(
            ChargesCompanion.insert(
              id: id,
              lowerBound: _real(r['lower_bound']),
              upperBound: _real(r['upper_bound']),
              chargeAmount: _real(r['charge_amount']),
              transactionTypeKey: Value(
                _str(r['transaction_type_key'], fallback: 'gcash_cashin'),
              ),
              syncId: id,
              deviceId: Value(_str(r['device_id'])),
              isDeleted: Value(_bool(r['is_deleted'])),
              isDirty: Value(_bool(r['is_dirty'], fallback: true)),
              createdAtMs: ts.createdAt,
              updatedAtMs: ts.updatedAt,
            ),
          );
    }
    return rows.length;
  }

  Future<int> _importParties(raw.Database src) async {
    final rows = _safeQuery(src, 'parties');
    for (final r in rows) {
      final id = _syncId(r);
      final ts = _timestamps(r);
      await _db.into(_db.parties).insertOnConflictUpdate(
            PartiesCompanion.insert(
              id: id,
              name: _str(r['name']),
              accountNumber: Value(_str(r['account_number'])),
              entityId: Value(_str(r['entity_id'])),
              description: Value(_str(r['description'])),
              joinDate: _str(r['join_date'], fallback: ''),
              isVerified: Value(_bool(r['is_verified'])),
              syncId: id,
              deviceId: Value(_str(r['device_id'])),
              isDeleted: Value(_bool(r['is_deleted'])),
              isDirty: Value(_bool(r['is_dirty'], fallback: true)),
              createdAtMs: ts.createdAt,
              updatedAtMs: ts.updatedAt,
            ),
          );
    }
    return rows.length;
  }

  Future<int> _importTransactionTypes(raw.Database src) async {
    final rows = _safeQuery(src, 'transaction_types');
    for (final r in rows) {
      final id = _syncId(r);
      final ts = _timestamps(r);
      await _db.into(_db.transactionTypes).insertOnConflictUpdate(
            TransactionTypesCompanion.insert(
              id: id,
              name: _str(r['name']),
              isOutflow: Value(_bool(r['is_outflow'])),
              walletAccount: Value(
                _str(r['wallet_account'], fallback: 'GCash'),
              ),
              syncId: id,
              deviceId: Value(_str(r['device_id'])),
              isDeleted: Value(_bool(r['is_deleted'])),
              isDirty: Value(_bool(r['is_dirty'], fallback: true)),
              createdAtMs: ts.createdAt,
              updatedAtMs: ts.updatedAt,
            ),
          );
    }
    return rows.length;
  }

  Future<int> _importMovementCategories(raw.Database src) async {
    final rows = _safeQuery(src, 'owner_movement_categories');
    for (final r in rows) {
      final id = _syncId(r);
      final ts = _timestamps(r);
      await _db.into(_db.movementCategories).insertOnConflictUpdate(
            MovementCategoriesCompanion.insert(
              id: id,
              name: _str(r['name']),
              syncId: id,
              deviceId: Value(_str(r['device_id'])),
              isDeleted: Value(_bool(r['is_deleted'])),
              isDirty: Value(_bool(r['is_dirty'], fallback: true)),
              createdAtMs: ts.createdAt,
              updatedAtMs: ts.updatedAt,
            ),
          );
    }
    return rows.length;
  }

  Future<int> _importLedgerEntries(raw.Database src) async {
    final rows = _safeQuery(src, 'ledger_entries');
    for (final r in rows) {
      final id = _syncId(r);
      final ts = _timestamps(r);
      final entryDate = _str(r['entry_date'], fallback: _str(r['created_at']));
      await _db.into(_db.ledgerEntries).insertOnConflictUpdate(
            LedgerEntriesCompanion.insert(
              id: id,
              entryType: _str(r['entry_type']),
              amount: _real(r['amount']),
              entryDate: entryDate,
              transactionId: const Value(null),
              title: Value(_str(r['title'])),
              note: Value(_str(r['note'])),
              reference: Value(_str(r['reference'])),
              walletDelta: Value(_real(r['wallet_delta'])),
              mayaWalletDelta: Value(_real(r['maya_wallet_delta'])),
              onHandDelta: Value(_real(r['on_hand_delta'])),
              recordedFlow: Value(_real(r['recorded_flow'])),
              tag: Value(_str(r['tag'])),
              iconKey: Value(_str(r['icon_key'])),
              walletAccount: Value(_str(r['wallet_account'])),
              ownerScope: Value(_str(r['owner_scope'], fallback: 'Business')),
              ownerMovementType: Value(r['owner_movement_type'] as String?),
              ownerCategory: Value(r['owner_category'] as String?),
              ownerPartyName: Value(r['owner_party_name'] as String?),
              ownerPartyAccount: Value(r['owner_party_account'] as String?),
              syncId: id,
              deviceId: Value(_str(r['device_id'])),
              isDeleted: Value(_bool(r['is_deleted'])),
              isDirty: Value(_bool(r['is_dirty'], fallback: true)),
              createdAtMs: ts.createdAt,
              updatedAtMs: ts.updatedAt,
            ),
          );
    }
    return rows.length;
  }

  Future<int> _importFeeTransactions(raw.Database src) async {
    final rows = _safeQuery(src, 'fee_transactions');
    if (rows.isEmpty) return 0;

    final ledgerRows = src.select(
      'SELECT id, sync_id FROM ledger_entries WHERE sync_id IS NOT NULL '
      "AND sync_id != ''",
    );
    final ledgerSyncIdByLegacyId = <int, String>{
      for (final lr in ledgerRows)
        if (lr['id'] is int &&
            lr['sync_id'] is String &&
            (lr['sync_id'] as String).isNotEmpty)
          lr['id']! as int: lr['sync_id']! as String,
    };

    for (final r in rows) {
      final id = _syncId(r);
      final ts = _timestamps(r);
      final legacyRelatedId = r['related_transaction_id'] as int?;
      final relatedSyncId = legacyRelatedId == null
          ? null
          : ledgerSyncIdByLegacyId[legacyRelatedId];
      await _db.into(_db.feeTransactions).insertOnConflictUpdate(
            FeeTransactionsCompanion.insert(
              id: id,
              feeAmount: _real(r['fee_amount']),
              feeType: _str(r['fee_type']),
              chargeDestination: _str(r['charge_destination']),
              relatedTransactionSyncId: Value(relatedSyncId),
              syncId: id,
              deviceId: Value(_str(r['device_id'])),
              isDeleted: Value(_bool(r['is_deleted'])),
              isDirty: Value(_bool(r['is_dirty'], fallback: true)),
              createdAtMs: ts.createdAt,
              updatedAtMs: ts.updatedAt,
            ),
          );
    }
    return rows.length;
  }

  int? _msOrNull(Object? v) {
    if (v == null) return null;
    final n = _ms(v);
    return n == 0 ? null : n;
  }

  Future<int> _importTtProductCategories(raw.Database src) async {
    final rows = _safeQuery(src, 'tt_product_categories');
    for (final r in rows) {
      final id = _syncId(r);
      final ts = _timestamps(r);
      await _db.into(_db.productCategories).insertOnConflictUpdate(
            ProductCategoriesCompanion.insert(
              id: id,
              name: _str(r['name']),
              description: Value(_str(r['description'])),
              examples: Value(_str(r['examples'])),
              isQuickAccess: Value(_bool(r['is_quick_access'])),
              syncId: id,
              deviceId: Value(_str(r['device_id'])),
              isDeleted: Value(_bool(r['is_deleted'])),
              isDirty: Value(_bool(r['is_dirty'], fallback: true)),
              createdAtMs: ts.createdAt,
              updatedAtMs: ts.updatedAt,
            ),
          );
    }
    return rows.length;
  }

  Future<int> _importTtShelfLocations(raw.Database src) async {
    final rows = _safeQuery(src, 'tt_shelf_locations');
    for (final r in rows) {
      final id = _syncId(r);
      final ts = _timestamps(r);
      await _db.into(_db.shelfLocations).insertOnConflictUpdate(
            ShelfLocationsCompanion.insert(
              id: id,
              name: _str(r['name']),
              description: Value(_str(r['description'])),
              examples: Value(_str(r['examples'])),
              imageUrl: Value(r['image_url'] as String?),
              imageLocalPath: Value(r['image_local_path'] as String?),
              syncId: id,
              deviceId: Value(_str(r['device_id'])),
              isDeleted: Value(_bool(r['is_deleted'])),
              isDirty: Value(_bool(r['is_dirty'], fallback: true)),
              createdAtMs: ts.createdAt,
              updatedAtMs: ts.updatedAt,
            ),
          );
    }
    return rows.length;
  }

  Future<int> _importTtProducts(raw.Database src) async {
    final rows = _safeQuery(src, 'tt_products');
    for (final r in rows) {
      final id = _syncId(r);
      final ts = _timestamps(r);
      final baseUnit = _str(
        r['base_unit'],
        fallback: _str(r['unit'], fallback: 'pcs'),
      );
      final stock = r['stock_in_base_unit'] != null
          ? _real(r['stock_in_base_unit'])
          : _real(r['stock_quantity']);
      await _db.into(_db.products).insertOnConflictUpdate(
            ProductsCompanion.insert(
              id: id,
              name: _str(r['name']),
              sku: _str(r['sku']),
              description: Value(_str(r['description'])),
              category: Value(_str(r['category'], fallback: 'General')),
              baseUnit: Value(baseUnit),
              costPrice: Value(_real(r['cost_price'])),
              sellingPrice: _real(r['selling_price']),
              stockInBaseUnit: Value(stock),
              reorderPoint: Value(_ms(r['reorder_point']).toInt()),
              isActive: Value(_bool(r['is_active'], fallback: true)),
              imageUrl: Value(r['image_url'] as String?),
              imageLocalPath: Value(r['image_path'] as String?),
              shelfLocation: Value(
                _str(r['shelf_location'], fallback: 'Counter'),
              ),
              expirationDateMs: Value(_msOrNull(r['expiration_date'])),
              categoryId: Value(r['category_id'] as String?),
              shelfLocationId: Value(r['shelf_location_id'] as String?),
              syncId: id,
              deviceId: Value(_str(r['device_id'])),
              isDeleted: Value(_bool(r['is_deleted'])),
              isDirty: Value(_bool(r['is_dirty'], fallback: true)),
              createdAtMs: ts.createdAt,
              updatedAtMs: ts.updatedAt,
            ),
          );
    }
    return rows.length;
  }

  Future<int> _importTtProductUnitConversions(raw.Database src) async {
    final rows = _safeQuery(src, 'tt_product_unit_conversions');
    for (final r in rows) {
      final id = _syncId(r);
      final ts = _timestamps(r);
      await _db.into(_db.productUnitConversions).insertOnConflictUpdate(
            ProductUnitConversionsCompanion.insert(
              id: id,
              productId: _str(r['product_id']),
              unitName: _str(r['unit_name']),
              conversionFactor: _real(r['conversion_factor'], fallback: 1),
              costPrice: _real(r['cost_price']),
              sellingPrice: _real(r['selling_price']),
              syncId: id,
              deviceId: Value(_str(r['device_id'])),
              isDeleted: Value(_bool(r['is_deleted'])),
              isDirty: Value(_bool(r['is_dirty'], fallback: true)),
              createdAtMs: ts.createdAt,
              updatedAtMs: ts.updatedAt,
            ),
          );
    }
    return rows.length;
  }

  Future<int> _importTtCustomers(raw.Database src) async {
    final rows = _safeQuery(src, 'tt_customers');
    for (final r in rows) {
      final id = _syncId(r);
      final ts = _timestamps(r);
      await _db.into(_db.customers).insertOnConflictUpdate(
            CustomersCompanion.insert(
              id: id,
              name: _str(r['name']),
              phone: Value(_str(r['phone'])),
              address: Value(_str(r['address'])),
              notes: Value(_str(r['notes'])),
              syncId: id,
              deviceId: Value(_str(r['device_id'])),
              isDeleted: Value(_bool(r['is_deleted'])),
              isDirty: Value(_bool(r['is_dirty'], fallback: true)),
              createdAtMs: ts.createdAt,
              updatedAtMs: ts.updatedAt,
            ),
          );
    }
    return rows.length;
  }

  Future<int> _importTtUtangRecords(raw.Database src) async {
    final rows = _safeQuery(src, 'tt_utang_records');
    for (final r in rows) {
      final id = _syncId(r);
      final ts = _timestamps(r);
      await _db.into(_db.utangRecords).insertOnConflictUpdate(
            UtangRecordsCompanion.insert(
              id: id,
              customerId: _str(r['customer_id']),
              description: Value(_str(r['description'])),
              amount: _real(r['amount']),
              syncId: id,
              deviceId: Value(_str(r['device_id'])),
              isDeleted: Value(_bool(r['is_deleted'])),
              isDirty: Value(_bool(r['is_dirty'], fallback: true)),
              createdAtMs: ts.createdAt,
              updatedAtMs: ts.updatedAt,
            ),
          );
    }
    return rows.length;
  }

  Future<int> _importTtSales(raw.Database src) async {
    final rows = _safeQuery(src, 'tt_sales');
    for (final r in rows) {
      final id = _syncId(r);
      final ts = _timestamps(r);
      await _db.into(_db.sales).insertOnConflictUpdate(
            SalesCompanion.insert(
              id: id,
              reference: _str(r['reference']),
              note: Value(_str(r['note'])),
              subtotal: _real(r['subtotal']),
              totalAmount: _real(r['total_amount']),
              paidAmount: _real(r['paid_amount']),
              changeAmount: Value(_real(r['change_amount'])),
              totalItems: _ms(r['total_items']).toInt(),
              syncId: id,
              deviceId: Value(_str(r['device_id'])),
              isDeleted: Value(_bool(r['is_deleted'])),
              isDirty: Value(_bool(r['is_dirty'], fallback: true)),
              createdAtMs: ts.createdAt,
              updatedAtMs: ts.updatedAt,
            ),
          );
    }
    return rows.length;
  }

  Future<int> _importTtSaleItems(raw.Database src) async {
    final rows = _safeQuery(src, 'tt_sale_items');
    for (final r in rows) {
      final id = _syncId(r);
      final created = _ms(r['created_at_ms']) != 0
          ? _ms(r['created_at_ms'])
          : _ms(r['created_at']);
      await _db.into(_db.saleItems).insertOnConflictUpdate(
            SaleItemsCompanion.insert(
              id: id,
              saleId: _str(r['sale_id']),
              productId: _str(r['product_id']),
              selectedUnit: _str(r['selected_unit'], fallback: 'pcs'),
              quantity: _real(r['quantity']),
              unitPrice: _real(r['unit_price']),
              computedBaseQuantity: _real(
                r['computed_base_quantity'],
                fallback: _real(r['quantity']),
              ),
              lineTotal: _real(r['line_total']),
              createdAtMs: created == 0
                  ? DateTime.now().millisecondsSinceEpoch
                  : created,
              isDirty: Value(_bool(r['is_dirty'], fallback: true)),
            ),
          );
    }
    return rows.length;
  }

  Future<int> _importTtStockMovements(raw.Database src) async {
    final rows = _safeQuery(src, 'tt_stock_movements');
    for (final r in rows) {
      final id = _syncId(r);
      final created = _ms(r['created_at_ms']) != 0
          ? _ms(r['created_at_ms'])
          : _ms(r['created_at']);
      await _db.into(_db.stockMovements).insertOnConflictUpdate(
            StockMovementsCompanion.insert(
              id: id,
              productId: _str(r['product_id']),
              movementType: _str(r['movement_type'], fallback: 'ADJUSTMENT'),
              quantity: _real(r['quantity']),
              previousQuantity: _real(r['previous_quantity']),
              newQuantity: _real(r['new_quantity']),
              note: Value(_str(r['note'])),
              reference: Value(_str(r['reference'])),
              expirationDateMs: Value(_msOrNull(r['expiration_date'])),
              createdAtMs: created == 0
                  ? DateTime.now().millisecondsSinceEpoch
                  : created,
              isDirty: Value(_bool(r['is_dirty'], fallback: true)),
            ),
          );
    }
    return rows.length;
  }

  // ── Utilities ──────────────────────────────────────────────────────────────

  List<Map<String, Object?>> _safeQuery(
    raw.Database src,
    String table,
  ) {
    final exists = src.select(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [table],
    );
    if (exists.isEmpty) return const [];
    
    final resultSet = src.select('SELECT * FROM $table');
    return resultSet.toList();
  }

  Future<void> _deleteLegacyFile(String path) async {
    try {
      await File(path).delete();
      for (final ext in const ['-journal', '-wal', '-shm']) {
        final sibling = File('$path$ext');
        if (await sibling.exists()) {
          await sibling.delete();
        }
      }
    } catch (e) {
      _log('Failed to delete legacy DB file $path: $e');
    }
  }

  void _log(String message) {
    developer.log(message, name: 'legacy_importer');
  }
}
