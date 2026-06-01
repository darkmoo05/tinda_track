import 'package:drift/drift.dart';

import 'connection/native.dart';
import 'tables/pocket_ledger_tables.dart';
import 'tables/shared_tables.dart';
import 'tables/tinda_tracker_tables.dart';

part 'app_database.g.dart';

/// Drift database for tinda_track.
///
/// Schema version 1 is the **new baseline** after the sqflite → Drift cutover.
/// Existing user data is migrated **once** by `LegacyImporter`
/// (see `migrations/legacy_sqflite_importer.dart`) on first launch after the
/// upgrade, then the legacy `tinda_track.db` file is deleted.
///
/// Subsequent schema changes will bump [schemaVersion] and add a step in
/// [MigrationStrategy.onUpgrade].
@DriftDatabase(
  tables: [
    // Shared
    SyncState,
    AppMeta,
    // Pocket Ledger
    Charges,
    Parties,
    TransactionTypes,
    MovementCategories,
    LedgerEntries,
    Transactions,
    FeeTransactions,
    // Tinda Tracker
    ProductCategories,
    ShelfLocations,
    Products,
    ProductUnitConversions,
    StockMovements,
    Customers,
    UtangRecords,
    Sales,
    SaleItems,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openAppConnection());

  /// Test-only constructor accepting a custom executor (in-memory, mock, …).
  AppDatabase.forExecutor(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedDefaults();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _seedDefaults() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await batch((b) {
      b.insertAll(syncState, [
        SyncStateCompanion.insert(moduleKey: 'pocket_ledger', updatedAtMs: now),
        SyncStateCompanion.insert(moduleKey: 'tinda_tracker', updatedAtMs: now),
      ]);
    });
  }
}
