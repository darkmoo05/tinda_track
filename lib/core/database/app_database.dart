import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:math';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const String ledgerTable = 'ledger_entries';
  static const String feeTransactionsTable = 'fee_transactions';
  static const String partiesTable = 'parties';
  static const String chargesTable = 'charges';
  static const String transactionTypesTable = 'transaction_types';
  static const String ownerMovementCategoriesTable =
      'owner_movement_categories';
  static const String syncStateTable = 'sync_state';

  // TindaTracker local cache tables
  static const String ttProductsTable = 'tt_products';
  static const String ttProductConversionsTable = 'tt_product_conversions';
  static const String ttProductCategoriesTable = 'tt_product_categories';
  static const String ttShelfLocationsTable = 'tt_shelf_locations';
  static const String ttCustomersTable = 'tt_customers';
  static const String ttUtangRecordsTable = 'tt_utang_records';
  static const String ttSalesTable = 'tt_sales';
  static const String ttSaleItemsTable = 'tt_sale_items';

  static const String transactionTypeKeyColumn = 'transaction_type_key';
  static const String syncIdColumn = 'sync_id';
  static const String deviceIdColumn = 'device_id';
  static const String updatedAtMsColumn = 'updated_at_ms';
  static const String isDeletedColumn = 'is_deleted';
  static const String isDirtyColumn = 'is_dirty';

  static final Random _random = Random();

  Database? _database;
  DatabaseFactory? _databaseFactory;

  Future<void> init() async {
    await database;
  }

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final databaseFactory = _resolveFactory();
    final databasesPath = await databaseFactory.getDatabasesPath();
    final databasePath = path.join(databasesPath, 'tinda_track.db');

    _database = await databaseFactory.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 20,
        onCreate: (db, version) async {
          await _createLedgerTable(db);
          await _createFeeTransactionsTable(db);
          await _createPartiesTable(db);
          await _createChargesTable(db);
          await _createTransactionTypesTable(db);
          await _createOwnerMovementCategoriesTable(db);
          await _createSyncStateTable(db);
          await _seedOwnerMovementCategoriesIfEmpty(db);
          await ensureSyncSchema(db);
          await _backfillSyncMetadata(db);
          await _createTtProductsTable(db);
          await _createTtProductConversionsTable(db);
          await _createTtProductCategoriesTable(db);
          await _createTtShelfLocationsTable(db);
          await _seedTtLookupTablesIfEmpty(db);
          await _createTtCustomersTable(db);
          await _createTtUtangRecordsTable(db);
          await _createTtSalesTable(db);
          await _createTtSaleItemsTable(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await _createPartiesTable(db);
          }
          if (oldVersion < 3) {
            await _createChargesTable(db);
          }
          if (oldVersion < 4) {
            await _createTransactionTypesTable(db);
          }
          if (oldVersion < 5) {
            final columnExists = await _columnExists(
              db,
              transactionTypesTable,
              'is_outflow',
            );
            if (!columnExists) {
              await db.execute(
                'ALTER TABLE $transactionTypesTable ADD COLUMN is_outflow INTEGER NOT NULL DEFAULT 0',
              );
            }
            await _backfillDefaultOutflowTypes(db);
          }
          if (oldVersion < 6) {
            final hasScopeColumn = await _columnExists(
              db,
              ledgerTable,
              'owner_scope',
            );
            final hasMovementTypeColumn = await _columnExists(
              db,
              ledgerTable,
              'owner_movement_type',
            );
            final hasCategoryColumn = await _columnExists(
              db,
              ledgerTable,
              'owner_category',
            );

            if (!hasScopeColumn) {
              await db.execute(
                "ALTER TABLE $ledgerTable ADD COLUMN owner_scope TEXT NOT NULL DEFAULT 'Business'",
              );
            }
            if (!hasMovementTypeColumn) {
              await db.execute(
                'ALTER TABLE $ledgerTable ADD COLUMN owner_movement_type TEXT',
              );
            }
            if (!hasCategoryColumn) {
              await db.execute(
                'ALTER TABLE $ledgerTable ADD COLUMN owner_category TEXT',
              );
            }
            await _createOwnerMovementCategoriesTable(db);
            await _seedOwnerMovementCategoriesIfEmpty(db);
          }
          if (oldVersion < 7) {
            final hasPartyNameColumn = await _columnExists(
              db,
              ledgerTable,
              'owner_party_name',
            );
            final hasPartyAccountColumn = await _columnExists(
              db,
              ledgerTable,
              'owner_party_account',
            );

            if (!hasPartyNameColumn) {
              await db.execute(
                'ALTER TABLE $ledgerTable ADD COLUMN owner_party_name TEXT',
              );
            }
            if (!hasPartyAccountColumn) {
              await db.execute(
                'ALTER TABLE $ledgerTable ADD COLUMN owner_party_account TEXT',
              );
            }
          }
          if (oldVersion < 8) {
            final hasMayaWalletDeltaColumn = await _columnExists(
              db,
              ledgerTable,
              'maya_wallet_delta',
            );
            final hasWalletAccountColumn = await _columnExists(
              db,
              ledgerTable,
              'wallet_account',
            );

            if (!hasMayaWalletDeltaColumn) {
              await db.execute(
                'ALTER TABLE $ledgerTable ADD COLUMN maya_wallet_delta REAL NOT NULL DEFAULT 0',
              );
            }
            if (!hasWalletAccountColumn) {
              await db.execute(
                "ALTER TABLE $ledgerTable ADD COLUMN wallet_account TEXT NOT NULL DEFAULT ''",
              );
            }

            await db.execute('''
              UPDATE $ledgerTable
              SET wallet_account = CASE
                WHEN maya_wallet_delta != 0 THEN 'Maya Wallet'
                WHEN wallet_delta != 0 THEN 'GCash'
                WHEN on_hand_delta != 0 THEN 'On-hand Cash'
                ELSE wallet_account
              END
              WHERE wallet_account = ''
            ''');
          }
          if (oldVersion < 9) {
            // Remove previously seeded default types so users manage their own.
            const defaultNames = [
              'Bank Deposit',
              'Bank Withdrawal',
              'GCash Cash In',
              'GCash Cash Out',
              'Maya Cash In',
              'Maya Cash Out',
              'Bills Payment',
              'Money Transfer',
            ];
            for (final name in defaultNames) {
              await db.delete(
                transactionTypesTable,
                where: 'LOWER(name) = LOWER(?)',
                whereArgs: [name],
              );
            }
          }
          if (oldVersion < 10) {
            final hasWalletAccountColumn = await _columnExists(
              db,
              transactionTypesTable,
              'wallet_account',
            );
            if (!hasWalletAccountColumn) {
              await db.execute(
                "ALTER TABLE $transactionTypesTable ADD COLUMN wallet_account TEXT NOT NULL DEFAULT 'GCash'",
              );
            }
          }
          if (oldVersion < 11) {
            await db.execute('''
              CREATE TABLE transaction_types_new (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL COLLATE NOCASE,
                is_outflow INTEGER NOT NULL DEFAULT 0,
                wallet_account TEXT NOT NULL DEFAULT 'GCash',
                created_at TEXT NOT NULL,
                UNIQUE(name, is_outflow, wallet_account)
              )
            ''');

            await db.execute('''
              INSERT OR IGNORE INTO transaction_types_new (
                id,
                name,
                is_outflow,
                wallet_account,
                created_at
              )
              SELECT
                id,
                name,
                is_outflow,
                COALESCE(NULLIF(wallet_account, ''), 'GCash') AS wallet_account,
                created_at
              FROM $transactionTypesTable
            ''');

            await db.execute('DROP TABLE $transactionTypesTable');
            await db.execute(
              'ALTER TABLE transaction_types_new RENAME TO $transactionTypesTable',
            );
          }
          if (oldVersion < 12) {
            await _createSyncStateTable(db);
            await ensureSyncSchema(db);
            await _backfillSyncMetadata(db);
          }
          if (oldVersion < 13) {
            final hasTypeKeyColumn = await _columnExists(
              db,
              chargesTable,
              transactionTypeKeyColumn,
            );
            if (!hasTypeKeyColumn) {
              await db.execute(
                "ALTER TABLE $chargesTable ADD COLUMN $transactionTypeKeyColumn TEXT NOT NULL DEFAULT 'gcash_cashin'",
              );
            }
          }
          if (oldVersion < 14) {
            await _createFeeTransactionsTable(db);
          }
          if (oldVersion < 15) {
            await _createTtProductsTable(db);
            await _createTtCustomersTable(db);
            await _createTtUtangRecordsTable(db);
            await _createTtSalesTable(db);
            await _createTtSaleItemsTable(db);
          }
          if (oldVersion < 16) {
            // Add image and shelf-location columns to tt_products.
            final hasImagePath = await _columnExists(
              db,
              ttProductsTable,
              'image_path',
            );
            if (!hasImagePath) {
              await db.execute(
                'ALTER TABLE $ttProductsTable ADD COLUMN image_path TEXT',
              );
            }
            final hasImageUrl = await _columnExists(
              db,
              ttProductsTable,
              'image_url',
            );
            if (!hasImageUrl) {
              await db.execute(
                'ALTER TABLE $ttProductsTable ADD COLUMN image_url TEXT',
              );
            }
            final hasShelfLocation = await _columnExists(
              db,
              ttProductsTable,
              'shelf_location',
            );
            if (!hasShelfLocation) {
              await db.execute(
                "ALTER TABLE $ttProductsTable ADD COLUMN shelf_location TEXT NOT NULL DEFAULT 'Counter'",
              );
            }
          }
          if (oldVersion < 17) {
            // Add expiration_date column to tt_products.
            final hasExpirationDate = await _columnExists(
              db,
              ttProductsTable,
              'expiration_date',
            );
            if (!hasExpirationDate) {
              await db.execute(
                'ALTER TABLE $ttProductsTable ADD COLUMN expiration_date TEXT',
              );
            }
            // Create lookup tables for user-managed categories and shelf locations.
            await _createTtProductCategoriesTable(db);
            await _createTtShelfLocationsTable(db);
            // Seed default values from the legacy constant lists so existing
            // installations are not left with empty lookup tables.
            await _seedTtLookupTablesIfEmpty(db);
          }
          if (oldVersion < 18) {
            // v18 — Inventory deep-profile fields.
            //
            // Categories: add description, examples, and the isQuickAccess
            // flag that pins entries to the dashboard chip row.
            await _addColumnIfMissing(
              db,
              ttProductCategoriesTable,
              'description',
              "TEXT NOT NULL DEFAULT ''",
            );
            await _addColumnIfMissing(
              db,
              ttProductCategoriesTable,
              'examples',
              "TEXT NOT NULL DEFAULT ''",
            );
            await _addColumnIfMissing(
              db,
              ttProductCategoriesTable,
              'is_quick_access',
              'INTEGER NOT NULL DEFAULT 0',
            );

            // Shelf locations: add description, examples and the dual
            // image_path (local file) / image_url (server URL) pair so the
            // picture survives both offline use and full re-installs.
            await _addColumnIfMissing(
              db,
              ttShelfLocationsTable,
              'description',
              "TEXT NOT NULL DEFAULT ''",
            );
            await _addColumnIfMissing(
              db,
              ttShelfLocationsTable,
              'examples',
              "TEXT NOT NULL DEFAULT ''",
            );
            await _addColumnIfMissing(
              db,
              ttShelfLocationsTable,
              'image_path',
              'TEXT',
            );
            await _addColumnIfMissing(
              db,
              ttShelfLocationsTable,
              'image_url',
              'TEXT',
            );

            // Re-seed when the user is still on the legacy short hardcoded
            // list — never wipe customizations they made themselves.
            await _reseedLookupsIfStillDefault(db);
          }
          if (oldVersion < 19) {
            // v19 — multi-unit inventory foundation.
            // Keep legacy `stock_quantity` for compatibility while introducing
            // floating base-unit storage and explicit base-unit label.
            await _addColumnIfMissing(
              db,
              ttProductsTable,
              'stock_in_base_unit',
              'REAL NOT NULL DEFAULT 0',
            );
            await _addColumnIfMissing(
              db,
              ttProductsTable,
              'base_unit',
              "TEXT NOT NULL DEFAULT 'pcs'",
            );

            // Backfill from the legacy integer stock + unit columns.
            await db.execute(
              'UPDATE $ttProductsTable '
              'SET stock_in_base_unit = CAST(stock_quantity AS REAL) '
              'WHERE stock_in_base_unit IS NULL OR stock_in_base_unit = 0',
            );
            await db.execute(
              'UPDATE $ttProductsTable '
              'SET base_unit = COALESCE(NULLIF(unit, ""), "pcs") '
              'WHERE base_unit IS NULL OR base_unit = ""',
            );

            await _createTtProductConversionsTable(db);
          }
          if (oldVersion < 20) {
            await _addColumnIfMissing(
              db,
              ttSaleItemsTable,
              'selected_unit',
              "TEXT NOT NULL DEFAULT 'pc'",
            );
            await _addColumnIfMissing(
              db,
              ttSaleItemsTable,
              'computed_base_quantity',
              'REAL NOT NULL DEFAULT 0',
            );

            await db.execute(
              'UPDATE $ttSaleItemsTable '
              'SET computed_base_quantity = CAST(quantity AS REAL) '
              'WHERE computed_base_quantity IS NULL OR computed_base_quantity = 0',
            );
          }
        },
        onOpen: (db) async {
          await ensureWalletSchema(db);
          await ensureTransactionTypeSchema(db);
          await ensureSyncSchema(db);
          await _normalizeLegacyInventoryUnits(db);
          await _seedOwnerMovementCategoriesIfEmpty(db);
          await _backfillDefaultOutflowTypes(db);
          await _removeLegacyDummyParties(db);
        },
      ),
    );

    return _database!;
  }

  DatabaseFactory _resolveFactory() {
    if (_databaseFactory != null) {
      return _databaseFactory!;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
        sqfliteFfiInit();
        _databaseFactory = databaseFactoryFfi;
        break;
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        _databaseFactory = databaseFactory;
        break;
    }

    return _databaseFactory!;
  }

  Future<void> _createLedgerTable(Database db) async {
    await db.execute('''
      CREATE TABLE $ledgerTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entry_type TEXT NOT NULL,
        title TEXT NOT NULL,
        note TEXT NOT NULL,
        reference TEXT NOT NULL,
        amount REAL NOT NULL,
        wallet_delta REAL NOT NULL,
        maya_wallet_delta REAL NOT NULL DEFAULT 0,
        on_hand_delta REAL NOT NULL,
        recorded_flow REAL NOT NULL,
        tag TEXT NOT NULL,
        icon_key TEXT NOT NULL,
        wallet_account TEXT NOT NULL DEFAULT '',
        owner_scope TEXT NOT NULL DEFAULT 'Business',
        owner_movement_type TEXT,
        owner_category TEXT,
        owner_party_name TEXT,
        owner_party_account TEXT,
        $syncIdColumn TEXT UNIQUE,
        $deviceIdColumn TEXT NOT NULL DEFAULT '',
        $updatedAtMsColumn INTEGER NOT NULL DEFAULT 0,
        $isDeletedColumn INTEGER NOT NULL DEFAULT 0,
        $isDirtyColumn INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createPartiesTable(Database db) async {
    await db.execute('''
      CREATE TABLE $partiesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        account_number TEXT NOT NULL UNIQUE,
        entity_id TEXT NOT NULL,
        description TEXT NOT NULL,
        join_date TEXT NOT NULL,
        is_verified INTEGER NOT NULL,
        $syncIdColumn TEXT UNIQUE,
        $deviceIdColumn TEXT NOT NULL DEFAULT '',
        $updatedAtMsColumn INTEGER NOT NULL DEFAULT 0,
        $isDeletedColumn INTEGER NOT NULL DEFAULT 0,
        $isDirtyColumn INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }

  Future<void> _createChargesTable(Database db) async {
    await db.execute('''
      CREATE TABLE $chargesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lower_bound INTEGER NOT NULL,
        upper_bound INTEGER NOT NULL,
        charge_amount REAL NOT NULL,
        $transactionTypeKeyColumn TEXT NOT NULL DEFAULT 'gcash_cashin',
        $syncIdColumn TEXT UNIQUE,
        $deviceIdColumn TEXT NOT NULL DEFAULT '',
        $updatedAtMsColumn INTEGER NOT NULL DEFAULT 0,
        $isDeletedColumn INTEGER NOT NULL DEFAULT 0,
        $isDirtyColumn INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }

  Future<void> _createTtProductsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $ttProductsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sync_id TEXT NOT NULL UNIQUE,
        server_id TEXT,
        device_id TEXT NOT NULL DEFAULT '',
        name TEXT NOT NULL,
        sku TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        category TEXT NOT NULL DEFAULT 'General',
        unit TEXT NOT NULL DEFAULT 'pcs',
        base_unit TEXT NOT NULL DEFAULT 'pcs',
        cost_price REAL NOT NULL DEFAULT 0,
        selling_price REAL NOT NULL DEFAULT 0,
        stock_quantity INTEGER NOT NULL DEFAULT 0,
        stock_in_base_unit REAL NOT NULL DEFAULT 0,
        reorder_point INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        is_dirty INTEGER NOT NULL DEFAULT 1,
        image_path TEXT,
        image_url TEXT,
        shelf_location TEXT NOT NULL DEFAULT 'Counter',
        expiration_date TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createTtProductConversionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $ttProductConversionsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sync_id TEXT NOT NULL UNIQUE,
        product_id TEXT NOT NULL,
        unit_name TEXT NOT NULL,
        conversion_factor REAL NOT NULL,
        cost_price REAL NOT NULL DEFAULT 0,
        selling_price REAL NOT NULL DEFAULT 0,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        is_dirty INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createTtProductCategoriesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $ttProductCategoriesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sync_id TEXT NOT NULL UNIQUE,
        server_id TEXT,
        name TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        examples TEXT NOT NULL DEFAULT '',
        is_quick_access INTEGER NOT NULL DEFAULT 0,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        is_dirty INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createTtShelfLocationsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $ttShelfLocationsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sync_id TEXT NOT NULL UNIQUE,
        server_id TEXT,
        name TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        examples TEXT NOT NULL DEFAULT '',
        image_path TEXT,
        image_url TEXT,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        is_dirty INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  /// Seeds [ttProductCategoriesTable] and [ttShelfLocationsTable] with a
  /// Philippine-market starter dataset.  The first 10 categories carry
  /// `is_quick_access = 1` so they appear in the dashboard chip row.
  /// Uses INSERT OR IGNORE to stay idempotent across re-installs.
  Future<void> _seedTtLookupTablesIfEmpty(Database db) async {
    final categories = _defaultCategorySeeds();
    final shelfLocations = _defaultShelfLocationSeeds();

    final catCount =
        (await db.rawQuery(
              'SELECT COUNT(*) AS c FROM $ttProductCategoriesTable WHERE is_deleted = 0',
            )).first['c']
            as int? ??
        0;
    if (catCount == 0) {
      final now = DateTime.now().toIso8601String();
      final batch = db.batch();
      for (final c in categories) {
        batch.insert(ttProductCategoriesTable, {
          'sync_id': c.syncId,
          'name': c.name,
          'description': c.description,
          'examples': c.examples,
          'is_quick_access': c.isQuickAccess ? 1 : 0,
          'is_deleted': 0,
          'is_dirty': 1,
          'created_at': now,
          'updated_at': now,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      await batch.commit(noResult: true);
    }

    final locCount =
        (await db.rawQuery(
              'SELECT COUNT(*) AS c FROM $ttShelfLocationsTable WHERE is_deleted = 0',
            )).first['c']
            as int? ??
        0;
    if (locCount == 0) {
      final now = DateTime.now().toIso8601String();
      final batch = db.batch();
      for (final l in shelfLocations) {
        batch.insert(ttShelfLocationsTable, {
          'sync_id': l.syncId,
          'name': l.name,
          'description': l.description,
          'examples': l.examples,
          'is_deleted': 0,
          'is_dirty': 1,
          'created_at': now,
          'updated_at': now,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      await batch.commit(noResult: true);
    }
  }

  /// v18 helper — if the lookup tables only contain the legacy short list
  /// that v17 used to seed, replace them with the new Philippine dataset.
  /// User-added rows (`sync_id` not starting with `seed_cat_`/`seed_loc_`)
  /// are left untouched.
  Future<void> _reseedLookupsIfStillDefault(Database db) async {
    // Categories: only matters if every existing row looks like a v17 seed.
    final allCats = await db.query(
      ttProductCategoriesTable,
      columns: ['sync_id'],
    );
    final allCatsAreLegacySeeds =
        allCats.isNotEmpty &&
        allCats.every(
          (r) => (r['sync_id'] as String?)?.startsWith('seed_cat_') == true,
        );
    if (allCatsAreLegacySeeds) {
      // Mark obsolete seeds deleted (they'll soft-delete on next push), then
      // insert the new dataset.
      await db.update(ttProductCategoriesTable, {
        'is_deleted': 1,
        'is_dirty': 1,
      }, where: "sync_id LIKE 'seed_cat_%'");
      final now = DateTime.now().toIso8601String();
      final batch = db.batch();
      for (final c in _defaultCategorySeeds()) {
        batch.insert(ttProductCategoriesTable, {
          'sync_id': c.syncId,
          'name': c.name,
          'description': c.description,
          'examples': c.examples,
          'is_quick_access': c.isQuickAccess ? 1 : 0,
          'is_deleted': 0,
          'is_dirty': 1,
          'created_at': now,
          'updated_at': now,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      await batch.commit(noResult: true);
    }

    final allLocs = await db.query(ttShelfLocationsTable, columns: ['sync_id']);
    final allLocsAreLegacySeeds =
        allLocs.isNotEmpty &&
        allLocs.every(
          (r) => (r['sync_id'] as String?)?.startsWith('seed_loc_') == true,
        );
    if (allLocsAreLegacySeeds) {
      await db.update(ttShelfLocationsTable, {
        'is_deleted': 1,
        'is_dirty': 1,
      }, where: "sync_id LIKE 'seed_loc_%'");
      final now = DateTime.now().toIso8601String();
      final batch = db.batch();
      for (final l in _defaultShelfLocationSeeds()) {
        batch.insert(ttShelfLocationsTable, {
          'sync_id': l.syncId,
          'name': l.name,
          'description': l.description,
          'examples': l.examples,
          'is_deleted': 0,
          'is_dirty': 1,
          'created_at': now,
          'updated_at': now,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      await batch.commit(noResult: true);
    }
  }

  /// Adds a column to [table] only if it doesn't already exist.
  /// Wrapping every ALTER TABLE in this guard makes the migration safe to
  /// re-run on databases where partial upgrades succeeded earlier.
  Future<void> _addColumnIfMissing(
    Database db,
    String table,
    String column,
    String typeAndConstraints,
  ) async {
    if (await _columnExists(db, table, column)) return;
    await db.execute(
      'ALTER TABLE $table ADD COLUMN $column $typeAndConstraints',
    );
  }

  List<_CategorySeed> _defaultCategorySeeds() => const [
    // ── Top-10 quick-access ─────────────────────────────────────────────
    _CategorySeed(
      'seed_cat_snacks',
      'Snacks',
      'Chips, biscuits, junk foods, candies',
      'Piattos, Chippy, Cream-O, V-Cut',
      true,
    ),
    _CategorySeed(
      'seed_cat_beverages',
      'Beverages',
      'Soft drinks, juices, water, tea, coffee',
      'Coke, Sprite, C2, Zesto, Wilkins',
      true,
    ),
    _CategorySeed(
      'seed_cat_canned',
      'Canned Goods',
      'Sardines, corned beef, meat loaf, fruit cocktail',
      'Ligo, Argentina, Purefoods, Del Monte',
      true,
    ),
    _CategorySeed(
      'seed_cat_noodles',
      'Instant Noodles',
      'Pancit canton, lucky me, cup noodles',
      'Lucky Me, Payless, Nissin',
      true,
    ),
    _CategorySeed(
      'seed_cat_condiments',
      'Condiments',
      'Soy sauce, vinegar, ketchup, fish sauce',
      'Silver Swan, Datu Puti, UFC, Mama Sita',
      true,
    ),
    _CategorySeed(
      'seed_cat_rice_grains',
      'Rice & Grains',
      'Rice, sugar, salt, flour by weight',
      'Sinandomeng, Dinorado, Brown sugar',
      true,
    ),
    _CategorySeed(
      'seed_cat_dairy',
      'Dairy & Eggs',
      'Milk, eggs, cheese, butter, yogurt',
      'Bear Brand, Alaska, Eden, Magnolia',
      true,
    ),
    _CategorySeed(
      'seed_cat_personal_care',
      'Personal Care',
      'Shampoo, soap, toothpaste, sachets',
      'Safeguard, Colgate, Palmolive, Sunsilk',
      true,
    ),
    _CategorySeed(
      'seed_cat_laundry',
      'Laundry & Cleaning',
      'Detergents, bleach, fabric conditioner',
      'Tide, Surf, Downy, Zonrox',
      true,
    ),
    _CategorySeed(
      'seed_cat_cigarettes',
      'Cigarettes & Tobacco',
      'Sticks and packs (age-restricted)',
      'Marlboro, Winston, Mighty',
      true,
    ),
    // ── Standard pool ───────────────────────────────────────────────────
    _CategorySeed(
      'seed_cat_bread_pastry',
      'Bread & Pastries',
      'Pandesal, sliced bread, cakes, pastries',
      "Gardenia, Julie's, Pandesal",
      false,
    ),
    _CategorySeed(
      'seed_cat_frozen',
      'Frozen Foods',
      'Hotdogs, longganisa, tocino, ice cream',
      'Purefoods Tender Juicy, Selecta',
      false,
    ),
    _CategorySeed(
      'seed_cat_cooking_oil',
      'Cooking Oil & Lard',
      'Vegetable oil, coconut oil, lard',
      'Baguio, Minola, Marca Leon',
      false,
    ),
    _CategorySeed(
      'seed_cat_spreads',
      'Spreads & Sandwich',
      'Mayonnaise, peanut butter, jam, sandwich spread',
      "Lady's Choice, Skippy, Magnolia",
      false,
    ),
    _CategorySeed(
      'seed_cat_baby_care',
      'Baby Care',
      'Diapers, milk, wipes, baby cologne',
      'EQ, Pampers, Bonna, Cherifer',
      false,
    ),
    _CategorySeed(
      'seed_cat_school_office',
      'School & Office',
      'Pen, paper, notebook, envelope',
      'Mongol, Pilot, intermediate paper',
      false,
    ),
    _CategorySeed(
      'seed_cat_medicine',
      'OTC Medicine',
      'Pain relievers, vitamins, cough drops',
      'Biogesic, Alaxan, Neozep, Strepsils',
      false,
    ),
    _CategorySeed(
      'seed_cat_household',
      'Household Supplies',
      'Light bulbs, batteries, candles, matches',
      'Eveready, Firefly, Lite-y',
      false,
    ),
    _CategorySeed(
      'seed_cat_kitchenware',
      'Kitchenware',
      'Spoons, plates, plastic cups, foil',
      'Coleman, Lock & Lock, foil rolls',
      false,
    ),
    _CategorySeed(
      'seed_cat_pet_supplies',
      'Pet Supplies',
      'Dog food, cat food, treats',
      'Pedigree, Whiskas, Top Breed',
      false,
    ),
    _CategorySeed(
      'seed_cat_load_prepaid',
      'Mobile Load & Cards',
      'Prepaid load, e-PINs, gaming cards',
      'Globe, Smart, TNT, Sun, Mobile Legends',
      false,
    ),
    _CategorySeed(
      'seed_cat_alcohol',
      'Alcohol & Beer',
      'Beer, gin, rhum, brandy (age-restricted)',
      'San Miguel, Red Horse, GSM, Tanduay',
      false,
    ),
    _CategorySeed(
      'seed_cat_misc',
      'Miscellaneous',
      "Other items that don't fit the standard categories",
      'Lighters, ice candy bags, plastic straws',
      false,
    ),
  ];

  List<_ShelfLocationSeed> _defaultShelfLocationSeeds() => const [
    _ShelfLocationSeed(
      'seed_loc_counter',
      'Counter',
      'Main checkout counter — impulse-buy zone',
      'Candies, mints, sachet shampoo, single sticks',
    ),
    _ShelfLocationSeed(
      'seed_loc_front_window',
      'Front Window',
      'Window display visible from the street',
      'New arrivals, promo items, eye-catchers',
    ),
    _ShelfLocationSeed(
      'seed_loc_shelf_a',
      'Shelf A — Top',
      'Top shelf on the left wall (above eye level)',
      'Light bulbs, batteries, slow-movers',
    ),
    _ShelfLocationSeed(
      'seed_loc_shelf_b',
      'Shelf B — Middle',
      'Eye-level shelf on the left wall (best-sellers)',
      'Coffee 3-in-1, milk sachets, biscuits',
    ),
    _ShelfLocationSeed(
      'seed_loc_shelf_c',
      'Shelf C — Bottom',
      'Bottom shelf on the left wall (bulky goods)',
      'Detergent powder, 1.5L sodas',
    ),
    _ShelfLocationSeed(
      'seed_loc_shelf_d',
      'Shelf D — Top',
      'Top shelf on the right wall',
      'Personal care, cosmetics, cologne',
    ),
    _ShelfLocationSeed(
      'seed_loc_shelf_e',
      'Shelf E — Middle',
      'Eye-level shelf on the right wall',
      'Canned sardines, corned beef, condensed milk',
    ),
    _ShelfLocationSeed(
      'seed_loc_shelf_f',
      'Shelf F — Bottom',
      'Bottom shelf on the right wall',
      'Sacks of rice, cooking oil gallons',
    ),
    _ShelfLocationSeed(
      'seed_loc_rice_area',
      'Rice Area',
      'Dedicated rice / grains corner with sacks and scoops',
      'Sinandomeng, Dinorado, brown sugar sacks',
    ),
    _ShelfLocationSeed(
      'seed_loc_fridge',
      'Refrigerator',
      'Cold drinks and dairy fridge (visible front)',
      'Coke 1.5L, Wilkins water, Milo',
    ),
    _ShelfLocationSeed(
      'seed_loc_freezer',
      'Freezer',
      'Chest freezer for frozen meats and ice cream',
      'Hotdogs, longganisa, Selecta ice cream',
    ),
    _ShelfLocationSeed(
      'seed_loc_bread_rack',
      'Bread Rack',
      'Hanging or table rack for fresh bread and pastries',
      'Pandesal, sliced bread, polvoron',
    ),
    _ShelfLocationSeed(
      'seed_loc_load_station',
      'Load Station',
      'Mobile load and prepaid cards area (behind counter)',
      'Smart/Globe load wallet, gaming cards',
    ),
    _ShelfLocationSeed(
      'seed_loc_medicine_cabinet',
      'Medicine Cabinet',
      'Locked or elevated cabinet for OTC meds',
      'Biogesic, Alaxan FR, Neozep, Strepsils',
    ),
    _ShelfLocationSeed(
      'seed_loc_cigarette_rack',
      'Cigarette Rack',
      'Behind-counter cigarette and tobacco rack',
      'Marlboro packs, Winston sticks',
    ),
    _ShelfLocationSeed(
      'seed_loc_alcohol_shelf',
      'Alcohol Shelf',
      'Liquor shelf above counter (age-restricted)',
      'Red Horse, Tanduay, Emperador',
    ),
    _ShelfLocationSeed(
      'seed_loc_stockroom',
      'Stockroom',
      'Back room for overstock and bulk supply',
      'Boxes of biscuits, sacks, refill stocks',
    ),
    _ShelfLocationSeed(
      'seed_loc_hanging_display',
      'Hanging Display',
      'Sachet strips hanging from the ceiling or grill',
      'Sunsilk sachets, instant coffee strips, candy strips',
    ),
    _ShelfLocationSeed(
      'seed_loc_storefront_table',
      'Storefront Table',
      'Table just outside the window for produce / promos',
      'Bananas, garlic, onions, eggs by tray',
    ),
  ];

  Future<void> _createTtCustomersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $ttCustomersTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sync_id TEXT NOT NULL UNIQUE,
        server_id TEXT,
        device_id TEXT NOT NULL DEFAULT '',
        name TEXT NOT NULL,
        phone TEXT NOT NULL DEFAULT '',
        address TEXT NOT NULL DEFAULT '',
        notes TEXT NOT NULL DEFAULT '',
        balance REAL NOT NULL DEFAULT 0,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        is_dirty INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createTtUtangRecordsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $ttUtangRecordsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sync_id TEXT NOT NULL UNIQUE,
        server_id TEXT,
        customer_sync_id TEXT NOT NULL,
        device_id TEXT NOT NULL DEFAULT '',
        description TEXT NOT NULL DEFAULT '',
        amount REAL NOT NULL,
        is_deleted INTEGER NOT NULL DEFAULT 0,
        is_dirty INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createTtSalesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $ttSalesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sync_id TEXT NOT NULL UNIQUE,
        server_id TEXT,
        device_id TEXT NOT NULL DEFAULT '',
        reference TEXT NOT NULL,
        note TEXT NOT NULL DEFAULT '',
        subtotal REAL NOT NULL DEFAULT 0,
        total_amount REAL NOT NULL DEFAULT 0,
        paid_amount REAL NOT NULL DEFAULT 0,
        change_amount REAL NOT NULL DEFAULT 0,
        total_items INTEGER NOT NULL DEFAULT 0,
        is_dirty INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createTtSaleItemsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $ttSaleItemsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_sync_id TEXT NOT NULL,
        product_sync_id TEXT NOT NULL,
        product_server_id TEXT,
        product_name TEXT NOT NULL DEFAULT '',
        selected_unit TEXT NOT NULL DEFAULT 'pc',
        quantity REAL NOT NULL,
        unit_price REAL NOT NULL,
        computed_base_quantity REAL NOT NULL DEFAULT 0,
        line_total REAL NOT NULL
      )
    ''');
  }

  Future<void> _createFeeTransactionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE $feeTransactionsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        related_transaction_id INTEGER,
        fee_amount REAL NOT NULL,
        fee_type TEXT NOT NULL,
        charge_destination TEXT NOT NULL,
        $syncIdColumn TEXT UNIQUE,
        $deviceIdColumn TEXT NOT NULL DEFAULT '',
        $updatedAtMsColumn INTEGER NOT NULL DEFAULT 0,
        $isDeletedColumn INTEGER NOT NULL DEFAULT 0,
        $isDirtyColumn INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createTransactionTypesTable(Database db) async {
    await db.execute('''
      CREATE TABLE $transactionTypesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL COLLATE NOCASE,
        is_outflow INTEGER NOT NULL DEFAULT 0,
        wallet_account TEXT NOT NULL DEFAULT 'GCash',
        $syncIdColumn TEXT UNIQUE,
        $deviceIdColumn TEXT NOT NULL DEFAULT '',
        $updatedAtMsColumn INTEGER NOT NULL DEFAULT 0,
        $isDeletedColumn INTEGER NOT NULL DEFAULT 0,
        $isDirtyColumn INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        UNIQUE(name, is_outflow, wallet_account)
      )
    ''');
  }

  Future<void> _createOwnerMovementCategoriesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $ownerMovementCategoriesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        $syncIdColumn TEXT UNIQUE,
        $deviceIdColumn TEXT NOT NULL DEFAULT '',
        $updatedAtMsColumn INTEGER NOT NULL DEFAULT 0,
        $isDeletedColumn INTEGER NOT NULL DEFAULT 0,
        $isDirtyColumn INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createSyncStateTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $syncStateTable (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> _removeLegacyDummyParties(Database db) async {
    await db.delete(
      partiesTable,
      where: 'account_number IN (?, ?, ?)',
      whereArgs: const ['0012984432', '3311981021', '8800459920'],
    );
  }

  Future<void> _seedOwnerMovementCategoriesIfEmpty(Database db) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM $ownerMovementCategoriesTable',
    );
    final count = (result.first['count'] as int?) ?? 0;
    if (count > 0) {
      return;
    }

    final batch = db.batch();
    final now = DateTime.now().toIso8601String();
    for (final category in _defaultOwnerMovementCategories) {
      batch.insert(ownerMovementCategoriesTable, {
        'name': category,
        'created_at': now,
      });
    }
    await batch.commit(noResult: true);
  }

  /// Normalizes legacy inventory unit values created by older app versions.
  ///
  /// Historical rows may contain `pcs`/`piece` while current unit lists use
  /// `pc`. This keeps dropdown values consistent and prevents assertion
  /// failures when editing products.
  Future<void> _normalizeLegacyInventoryUnits(Database db) async {
    if (await _columnExists(db, ttProductsTable, 'unit')) {
      await db.execute(
        "UPDATE $ttProductsTable "
        "SET unit = 'pc' "
        "WHERE LOWER(TRIM(unit)) IN ('pcs', 'piece', 'pieces')",
      );
    }
    if (await _columnExists(db, ttProductsTable, 'base_unit')) {
      await db.execute(
        "UPDATE $ttProductsTable "
        "SET base_unit = 'pc' "
        "WHERE LOWER(TRIM(base_unit)) IN ('pcs', 'piece', 'pieces')",
      );
    }
  }

  Future<List<String>> loadTransactionTypes() async {
    final records = await loadTransactionTypeRecords();
    return records.map((record) => record.name).toList(growable: false);
  }

  Future<List<TransactionTypeRecord>> loadTransactionTypeRecords() async {
    final db = await database;
    final rows = await db.query(
      transactionTypesTable,
      columns: ['id', 'name', 'is_outflow', 'wallet_account'],
      where: '$isDeletedColumn = 0',
      orderBy: 'name COLLATE NOCASE ASC, id ASC',
    );
    return rows
        .map(
          (row) => TransactionTypeRecord(
            id: (row['id'] as num).toInt(),
            name: (row['name'] as String).trim(),
            isOutflow: ((row['is_outflow'] as num?) ?? 0) == 1,
            walletAccount:
                ((row['wallet_account'] as String?) ?? 'GCash').trim().isEmpty
                ? 'GCash'
                : (row['wallet_account'] as String).trim(),
          ),
        )
        .where((record) => record.name.isNotEmpty)
        .toList(growable: false);
  }

  Future<int?> insertTransactionType(
    String name, {
    bool isOutflow = false,
    String walletAccount = 'GCash',
    String? deviceId,
    String? syncId,
  }) async {
    final normalized = name.trim();
    if (normalized.isEmpty) {
      return null;
    }

    final db = await database;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    return db.insert(transactionTypesTable, {
      'name': normalized,
      'is_outflow': isOutflow ? 1 : 0,
      'wallet_account': walletAccount.trim().isEmpty
          ? 'GCash'
          : walletAccount.trim(),
      syncIdColumn: syncId ?? generateSyncId('type'),
      deviceIdColumn: deviceId ?? await getOrCreateDeviceId(),
      updatedAtMsColumn: nowMs,
      isDeletedColumn: 0,
      isDirtyColumn: 1,
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> updateTransactionType({
    required int id,
    required String name,
    required bool isOutflow,
    required String walletAccount,
  }) async {
    final normalized = name.trim();
    if (normalized.isEmpty) {
      return;
    }

    final db = await database;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    await db.update(
      transactionTypesTable,
      {
        'name': normalized,
        'is_outflow': isOutflow ? 1 : 0,
        'wallet_account': walletAccount.trim().isEmpty
            ? 'GCash'
            : walletAccount.trim(),
        updatedAtMsColumn: nowMs,
        isDirtyColumn: 1,
      },
      where: 'id = ?',
      whereArgs: [id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> deleteTransactionType(int id) async {
    final db = await database;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    await db.update(
      transactionTypesTable,
      {isDeletedColumn: 1, isDirtyColumn: 1, updatedAtMsColumn: nowMs},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<String>> loadOwnerMovementCategories() async {
    final db = await database;
    await _seedOwnerMovementCategoriesIfEmpty(db);
    final rows = await db.query(
      ownerMovementCategoriesTable,
      columns: ['name'],
      where: '$isDeletedColumn = 0',
      orderBy: 'name COLLATE NOCASE ASC, id ASC',
    );
    return rows
        .map((row) => (row['name'] as String).trim())
        .where((name) => name.isNotEmpty)
        .toList(growable: false);
  }

  Future<void> insertOwnerMovementCategory(
    String name, {
    String? deviceId,
    String? syncId,
  }) async {
    final normalized = name.trim();
    if (normalized.isEmpty) {
      return;
    }

    final db = await database;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    await db.insert(ownerMovementCategoriesTable, {
      'name': normalized,
      syncIdColumn: syncId ?? generateSyncId('category'),
      deviceIdColumn: deviceId ?? await getOrCreateDeviceId(),
      updatedAtMsColumn: nowMs,
      isDeletedColumn: 0,
      isDirtyColumn: 1,
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> updateOwnerMovementCategory({
    required String previousName,
    required String newName,
  }) async {
    final normalized = newName.trim();
    if (normalized.isEmpty) {
      return;
    }

    final db = await database;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    await db.transaction((txn) async {
      await txn.update(
        ownerMovementCategoriesTable,
        {'name': normalized, updatedAtMsColumn: nowMs, isDirtyColumn: 1},
        where: 'LOWER(name) = LOWER(?)',
        whereArgs: [previousName],
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      await txn.update(
        ledgerTable,
        {'owner_category': normalized},
        where: 'LOWER(owner_category) = LOWER(?)',
        whereArgs: [previousName],
      );
    });
  }

  Future<void> deleteOwnerMovementCategory(String name) async {
    final db = await database;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    await db.update(
      ownerMovementCategoriesTable,
      {isDeletedColumn: 1, isDirtyColumn: 1, updatedAtMsColumn: nowMs},
      where: 'LOWER(name) = LOWER(?)',
      whereArgs: [name],
    );
  }

  Future<List<OwnerBorrowBalanceRecord>> loadOwnerBorrowBalances() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT
        SUM(CASE WHEN owner_movement_type IN ('Borrowed Funds', 'Personal Expense') THEN amount ELSE 0 END) AS total_borrowed,
        SUM(CASE WHEN owner_movement_type IN ('Borrowed Funds Repayment', 'Personal Expense Payment') THEN amount ELSE 0 END) AS total_repaid
      FROM $ledgerTable
      WHERE entry_type = 'owner_movement'
        AND owner_movement_type IN ('Borrowed Funds', 'Borrowed Funds Repayment', 'Personal Expense', 'Personal Expense Payment')
    ''');

    if (rows.isEmpty) {
      return const [];
    }

    final row = rows.first;
    final totalBorrowed = (row['total_borrowed'] as num?)?.toDouble() ?? 0;
    final totalRepaid = (row['total_repaid'] as num?)?.toDouble() ?? 0;

    if (totalBorrowed == 0 && totalRepaid == 0) {
      return const [];
    }

    return [
      OwnerBorrowBalanceRecord(
        partyName: 'Owner Credit',
        partyAccount: 'SYSTEM',
        totalBorrowed: totalBorrowed,
        totalRepaid: totalRepaid,
      ),
    ];
  }

  Future<bool> _columnExists(
    Database db,
    String tableName,
    String columnName,
  ) async {
    final result = await db.rawQuery('PRAGMA table_info($tableName)');
    return result.any((col) => col['name'] == columnName);
  }

  Future<void> ensureWalletSchemaUpToDate() async {
    final db = await database;
    await ensureWalletSchema(db);
    await ensureTransactionTypeSchema(db);
  }

  Future<void> ensureTransactionTypeSchema(Database db) async {
    final hasWalletAccountColumn = await _columnExists(
      db,
      transactionTypesTable,
      'wallet_account',
    );
    if (!hasWalletAccountColumn) {
      await db.execute(
        "ALTER TABLE $transactionTypesTable ADD COLUMN wallet_account TEXT NOT NULL DEFAULT 'GCash'",
      );
    }
  }

  Future<void> ensureSyncSchema(Database db) async {
    await _ensureTableSyncColumns(db, ledgerTable);
    await _ensureTableSyncColumns(db, partiesTable);
    await _ensureTableSyncColumns(db, chargesTable);
    await _ensureTableSyncColumns(db, transactionTypesTable);
    await _ensureTableSyncColumns(db, ownerMovementCategoriesTable);
    await _createSyncStateTable(db);
  }

  Future<void> _ensureTableSyncColumns(Database db, String tableName) async {
    if (!await _columnExists(db, tableName, syncIdColumn)) {
      await db.execute('ALTER TABLE $tableName ADD COLUMN $syncIdColumn TEXT');
      await db.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_${tableName}_sync_id ON $tableName($syncIdColumn)',
      );
    }
    if (!await _columnExists(db, tableName, deviceIdColumn)) {
      await db.execute(
        "ALTER TABLE $tableName ADD COLUMN $deviceIdColumn TEXT NOT NULL DEFAULT ''",
      );
    }
    if (!await _columnExists(db, tableName, updatedAtMsColumn)) {
      await db.execute(
        'ALTER TABLE $tableName ADD COLUMN $updatedAtMsColumn INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (!await _columnExists(db, tableName, isDeletedColumn)) {
      await db.execute(
        'ALTER TABLE $tableName ADD COLUMN $isDeletedColumn INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (!await _columnExists(db, tableName, isDirtyColumn)) {
      await db.execute(
        'ALTER TABLE $tableName ADD COLUMN $isDirtyColumn INTEGER NOT NULL DEFAULT 1',
      );
    }
  }

  Future<void> _backfillSyncMetadata(Database db) async {
    final deviceId = await _getOrCreateDeviceIdWithDb(db);
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    await _backfillTableSyncMetadata(db, ledgerTable, 'entry', deviceId, nowMs);
    await _backfillTableSyncMetadata(
      db,
      partiesTable,
      'party',
      deviceId,
      nowMs,
    );
    await _backfillTableSyncMetadata(
      db,
      chargesTable,
      'charge',
      deviceId,
      nowMs,
    );
    await _backfillTableSyncMetadata(
      db,
      transactionTypesTable,
      'type',
      deviceId,
      nowMs,
    );
    await _backfillTableSyncMetadata(
      db,
      ownerMovementCategoriesTable,
      'category',
      deviceId,
      nowMs,
    );
  }

  Future<void> _backfillTableSyncMetadata(
    Database db,
    String tableName,
    String prefix,
    String deviceId,
    int nowMs,
  ) async {
    await db.execute('''
      UPDATE $tableName
      SET
        $syncIdColumn = COALESCE(NULLIF($syncIdColumn, ''), '$prefix-' || id),
        $deviceIdColumn = COALESCE($deviceIdColumn, ''),
        $updatedAtMsColumn = CASE WHEN $updatedAtMsColumn <= 0 THEN $nowMs ELSE $updatedAtMsColumn END,
        $isDeletedColumn = COALESCE($isDeletedColumn, 0),
        $isDirtyColumn = COALESCE($isDirtyColumn, 1)
    ''');
    await db.update(
      tableName,
      {deviceIdColumn: deviceId},
      where: '$deviceIdColumn = ?',
      whereArgs: [''],
    );
  }

  Future<String?> getSyncState(String key) async {
    final db = await database;
    return _getSyncStateWithDb(db, key);
  }

  Future<String?> _getSyncStateWithDb(Database db, String key) async {
    final rows = await db.query(
      syncStateTable,
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return rows.first['value'] as String?;
  }

  Future<void> setSyncState(String key, String value) async {
    final db = await database;
    await _setSyncStateWithDb(db, key, value);
  }

  Future<void> _setSyncStateWithDb(
    Database db,
    String key,
    String value,
  ) async {
    await db.insert(syncStateTable, {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String> getOrCreateDeviceId() async {
    final db = await database;
    return _getOrCreateDeviceIdWithDb(db);
  }

  Future<String> _getOrCreateDeviceIdWithDb(Database db) async {
    final existing = await _getSyncStateWithDb(db, 'device_id');
    if (existing != null && existing.trim().isNotEmpty) {
      return existing;
    }
    final id =
        'device-${DateTime.now().millisecondsSinceEpoch}-${_random.nextInt(1 << 20)}';
    await _setSyncStateWithDb(db, 'device_id', id);
    return id;
  }

  static String generateSyncId(String prefix) {
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(1 << 24)}';
  }

  Future<void> ensureWalletSchema(Database db) async {
    final hasMayaWalletDeltaColumn = await _columnExists(
      db,
      ledgerTable,
      'maya_wallet_delta',
    );
    if (!hasMayaWalletDeltaColumn) {
      await db.execute(
        'ALTER TABLE $ledgerTable ADD COLUMN maya_wallet_delta REAL NOT NULL DEFAULT 0',
      );
    }

    final hasWalletAccountColumn = await _columnExists(
      db,
      ledgerTable,
      'wallet_account',
    );
    if (!hasWalletAccountColumn) {
      await db.execute(
        "ALTER TABLE $ledgerTable ADD COLUMN wallet_account TEXT NOT NULL DEFAULT ''",
      );
    }

    await db.execute('''
      UPDATE $ledgerTable
      SET wallet_account = CASE
        WHEN maya_wallet_delta != 0 THEN 'Maya Wallet'
        WHEN wallet_delta != 0 THEN 'GCash'
        WHEN on_hand_delta != 0 THEN 'On-hand Cash'
        ELSE wallet_account
      END
      WHERE wallet_account = ''
    ''');
  }

  Future<void> _backfillDefaultOutflowTypes(Database db) async {
    for (final type in _defaultTransactionTypes.where(
      (type) => type.isOutflow,
    )) {
      await db.update(
        transactionTypesTable,
        {'is_outflow': 1},
        where: 'LOWER(name) = LOWER(?)',
        whereArgs: [type.name],
      );
    }
  }

  static const List<_DefaultTransactionType> _defaultTransactionTypes = [];

  static const List<String> _defaultOwnerMovementCategories = [
    'Bills Payment',
    'Groceries',
    'Shopping',
    'Transportation',
  ];
}

class TransactionTypeRecord {
  const TransactionTypeRecord({
    required this.id,
    required this.name,
    required this.isOutflow,
    required this.walletAccount,
  });

  final int id;
  final String name;
  final bool isOutflow;
  final String walletAccount;
}

class OwnerBorrowBalanceRecord {
  const OwnerBorrowBalanceRecord({
    required this.partyName,
    required this.partyAccount,
    required this.totalBorrowed,
    required this.totalRepaid,
  });

  final String partyName;
  final String partyAccount;
  final double totalBorrowed;
  final double totalRepaid;

  double get outstandingBalance => totalBorrowed - totalRepaid;
}

class FixedTransactionType {
  const FixedTransactionType({
    required this.key,
    required this.label,
    required this.wallet,
    required this.isOutflow,
  });

  final String key;
  final String label;
  final String wallet;
  final bool isOutflow;

  static const List<FixedTransactionType> all = [
    FixedTransactionType(
      key: 'gcash_cashin',
      label: 'GCash Cash-In',
      wallet: 'GCash',
      isOutflow: false,
    ),
    FixedTransactionType(
      key: 'gcash_cashout',
      label: 'GCash Cash-Out',
      wallet: 'GCash',
      isOutflow: true,
    ),
    FixedTransactionType(
      key: 'gcash_load',
      label: 'GCash Load',
      wallet: 'GCash',
      isOutflow: false,
    ),
    FixedTransactionType(
      key: 'gcash_paybills',
      label: 'GCash Pay Bills',
      wallet: 'GCash',
      isOutflow: false,
    ),
    FixedTransactionType(
      key: 'gcash_qrpayment',
      label: 'GCash QR Payment',
      wallet: 'GCash',
      isOutflow: true,
    ),
    FixedTransactionType(
      key: 'maya_cashin',
      label: 'Maya Cash-In',
      wallet: 'Maya Wallet',
      isOutflow: false,
    ),
    FixedTransactionType(
      key: 'maya_cashout',
      label: 'Maya Cash-Out',
      wallet: 'Maya Wallet',
      isOutflow: true,
    ),
    FixedTransactionType(
      key: 'maya_load',
      label: 'Maya Load',
      wallet: 'Maya Wallet',
      isOutflow: false,
    ),
    FixedTransactionType(
      key: 'maya_paybills',
      label: 'Maya Pay Bills',
      wallet: 'Maya Wallet',
      isOutflow: false,
    ),
    FixedTransactionType(
      key: 'maya_qrpayment',
      label: 'Maya QR Payment',
      wallet: 'Maya Wallet',
      isOutflow: true,
    ),
  ];

  static FixedTransactionType forKey(String key) {
    return all.firstWhere((t) => t.key == key, orElse: () => all.first);
  }
}

class _DefaultTransactionType {
  const _DefaultTransactionType({
    required this.name,
    required this.isOutflow,
    required this.walletAccount,
  });

  final String name;
  final bool isOutflow;
  final String walletAccount;
}

// --- Inventory lookup seed records -----------------------------------------

/// Internal value-class describing a seeded category row.
class _CategorySeed {
  const _CategorySeed(
    this.syncId,
    this.name,
    this.description,
    this.examples,
    this.isQuickAccess,
  );
  final String syncId;
  final String name;
  final String description;
  final String examples;
  final bool isQuickAccess;
}

/// Internal value-class describing a seeded shelf-location row.
class _ShelfLocationSeed {
  const _ShelfLocationSeed(
    this.syncId,
    this.name,
    this.description,
    this.examples,
  );
  final String syncId;
  final String name;
  final String description;
  final String examples;
}
