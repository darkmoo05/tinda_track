import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:drift_dev/api/migrations_native.dart'; // ignore: depend_on_referenced_packages

import 'connection/native.dart';
import 'tables/pocket_ledger_tables.dart';
import 'tables/shared_tables.dart';
import 'tables/tinda_tracker_tables.dart';
import 'tables/business_profiles_table.dart';

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
    MonitoringSessions,
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
    BusinessProfiles,
    ProductSerialNumbers,
    ProductRecipeIngredients,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openAppConnection());

  /// Test-only constructor accepting a custom executor (in-memory, mock, …).
  AppDatabase.forExecutor(super.e);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedDefaults();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(businessProfiles);
      }
      if (from < 3) {
        await m.addColumn(products, products.itemType);
        await m.addColumn(products, products.customAttributesJson);
        await m.createTable(productSerialNumbers);
        await m.createTable(productRecipeIngredients);
      }
      if (from < 4) {
        await m.createTable(monitoringSessions);
      }
      if (from < 5) {
        if (from >= 4) {
          // Upgrade monitoring_sessions to add sync columns
          await m.addColumn(monitoringSessions, monitoringSessions.syncId);
          await m.addColumn(monitoringSessions, monitoringSessions.deviceId);
          await m.addColumn(monitoringSessions, monitoringSessions.isDeleted);
          await m.addColumn(monitoringSessions, monitoringSessions.isDirty);
        }

        // Backfill existing local sessions with sync metadata
        // We set sync_id to the existing unique id, and mark it dirty so it gets pushed
        await customStatement(
          "UPDATE monitoring_sessions SET sync_id = id, is_deleted = 0, is_dirty = 1 "
          "WHERE sync_id IS NULL OR sync_id = ''"
        );
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      
      // Ensure we have a default active monitoring session
      try {
        final sessionCountQuery = await customSelect('SELECT COUNT(*) as cnt FROM monitoring_sessions').getSingle();
        final sessionCount = sessionCountQuery.read<int>('cnt');
        if (sessionCount == 0) {
          final minTxQuery = await customSelect(
            "SELECT MIN(created_at_ms) as min_ms FROM ledger_entries WHERE COALESCE(is_deleted, 0) = 0"
          ).getSingleOrNull();
          final minMs = minTxQuery?.read<int?>('min_ms');
          final now = DateTime.now().millisecondsSinceEpoch;
          final startDate = minMs ?? now;

          await customStatement('''
            INSERT INTO monitoring_sessions (id, sync_id, name, status, start_date_ms, start_gcash, start_maya, start_on_hand, created_at_ms, updated_at_ms)
            VALUES ('default_session', 'default_session', 'Default Monitoring', 'ACTIVE', ?, 0.0, 0.0, 0.0, ?, ?)
          ''', [startDate, now, now]);
        }

        // Fix any default_session currently starting at 0 (1970) to start at the earliest transaction date
        final defaultSessionQuery = await customSelect(
          "SELECT id, start_date_ms FROM monitoring_sessions WHERE id = 'default_session' LIMIT 1"
        ).getSingleOrNull();

        if (defaultSessionQuery != null) {
          final startDateMs = defaultSessionQuery.read<int>('start_date_ms');
          if (startDateMs == 0) {
            final minTxQuery = await customSelect(
              "SELECT MIN(created_at_ms) as min_ms FROM ledger_entries WHERE COALESCE(is_deleted, 0) = 0"
            ).getSingleOrNull();
            final minMs = minTxQuery?.read<int?>('min_ms');
            if (minMs != null) {
              await customStatement(
                "UPDATE monitoring_sessions SET start_date_ms = ? WHERE id = 'default_session'",
                [minMs]
              );
            } else {
              final now = DateTime.now().millisecondsSinceEpoch;
              await customStatement(
                "UPDATE monitoring_sessions SET start_date_ms = ? WHERE id = 'default_session'",
                [now]
              );
            }
          }
        }
      } catch (e) {
        debugPrint('Error seeding or migrating default monitoring session: $e');
      }

      if (kDebugMode) {
        await validateDatabaseSchema();
      }
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
