import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const String ledgerTable = 'ledger_entries';
  static const String partiesTable = 'parties';
  static const String chargesTable = 'charges';

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
        version: 3,
        onCreate: (db, version) async {
          await _createLedgerTable(db);
          await _createPartiesTable(db);
          await _createChargesTable(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await _createPartiesTable(db);
          }
          if (oldVersion < 3) {
            await _createChargesTable(db);
          }
        },
        onOpen: (db) async {
          await _seedLedgerIfEmpty(db);
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
        on_hand_delta REAL NOT NULL,
        recorded_flow REAL NOT NULL,
        tag TEXT NOT NULL,
        icon_key TEXT NOT NULL,
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
        is_verified INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _createChargesTable(Database db) async {
    await db.execute('''
      CREATE TABLE $chargesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lower_bound INTEGER NOT NULL,
        upper_bound INTEGER NOT NULL,
        charge_amount REAL NOT NULL
      )
    ''');
  }

  Future<void> _seedLedgerIfEmpty(Database db) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS count FROM $ledgerTable',
    );
    final count = (result.first['count'] as int?) ?? 0;
    if (count > 0) {
      return;
    }

    final batch = db.batch();
    for (final entry in _seedEntries) {
      batch.insert(ledgerTable, entry);
    }
    await batch.commit(noResult: true);
  }

  Future<void> _removeLegacyDummyParties(Database db) async {
    await db.delete(
      partiesTable,
      where: 'account_number IN (?, ?, ?)',
      whereArgs: const ['0012984432', '3311981021', '8800459920'],
    );
  }

  List<Map<String, Object>> get _seedEntries => [
    {
      'entry_type': 'owner_movement',
      'title': 'Initial Capital - GCash',
      'note': 'Owner recorded startup wallet capital.',
      'reference': 'CAP-0001',
      'amount': 5000.0,
      'wallet_delta': 5000.0,
      'on_hand_delta': 0.0,
      'recorded_flow': 5000.0,
      'tag': 'Owner Movement',
      'icon_key': 'wallet',
      'created_at': '2026-04-11T08:15:00.000',
    },
    {
      'entry_type': 'owner_movement',
      'title': 'Initial Capital - On-Hand Cash',
      'note': 'Owner recorded startup cash drawer capital.',
      'reference': 'CAP-0002',
      'amount': 4000.0,
      'wallet_delta': 0.0,
      'on_hand_delta': 4000.0,
      'recorded_flow': 4000.0,
      'tag': 'Owner Movement',
      'icon_key': 'cash',
      'created_at': '2026-04-11T08:30:00.000',
    },
    {
      'entry_type': 'transaction',
      'title': 'GCash Cash In',
      'note': 'Customer cash-in worth P1,000 processed from wallet float.',
      'reference': 'TXN-1000',
      'amount': 1000.0,
      'wallet_delta': -1000.0,
      'on_hand_delta': 1000.0,
      'recorded_flow': 1000.0,
      'tag': 'Transaction',
      'icon_key': 'cash_in',
      'created_at': '2026-04-13T10:05:00.000',
    },
    {
      'entry_type': 'transaction',
      'title': 'GCash Cash Out',
      'note': 'Customer cash-out worth P300 released from on-hand cash.',
      'reference': 'TXN-0300',
      'amount': 300.0,
      'wallet_delta': 300.0,
      'on_hand_delta': -300.0,
      'recorded_flow': 300.0,
      'tag': 'Transaction',
      'icon_key': 'cash_out',
      'created_at': '2026-04-14T15:20:00.000',
    },
  ];
}
