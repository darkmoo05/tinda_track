import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:math';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const String ledgerTable = 'ledger_entries';
  static const String partiesTable = 'parties';
  static const String chargesTable = 'charges';
  static const String transactionTypesTable = 'transaction_types';
  static const String ownerMovementCategoriesTable =
      'owner_movement_categories';
  static const String syncStateTable = 'sync_state';

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
        version: 12,
        onCreate: (db, version) async {
          await _createLedgerTable(db);
          await _createPartiesTable(db);
          await _createChargesTable(db);
          await _createTransactionTypesTable(db);
          await _createOwnerMovementCategoriesTable(db);
          await _createSyncStateTable(db);
          await _seedOwnerMovementCategoriesIfEmpty(db);
          await ensureSyncSchema(db);
          await _backfillSyncMetadata(db);
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
        },
        onOpen: (db) async {
          await ensureWalletSchema(db);
          await ensureTransactionTypeSchema(db);
          await ensureSyncSchema(db);
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
        $syncIdColumn TEXT UNIQUE,
        $deviceIdColumn TEXT NOT NULL DEFAULT '',
        $updatedAtMsColumn INTEGER NOT NULL DEFAULT 0,
        $isDeletedColumn INTEGER NOT NULL DEFAULT 0,
        $isDirtyColumn INTEGER NOT NULL DEFAULT 1
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
        SUM(CASE WHEN owner_movement_type IN ('Borrowing', 'Personal Expense') THEN amount ELSE 0 END) AS total_borrowed,
        SUM(CASE WHEN owner_movement_type = 'Repayment' THEN amount ELSE 0 END) AS total_repaid
      FROM $ledgerTable
      WHERE entry_type = 'owner_movement'
        AND owner_movement_type IN ('Borrowing', 'Personal Expense', 'Repayment')
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
