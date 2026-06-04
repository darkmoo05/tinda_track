/// Single canonical home for every database-related Riverpod provider.
///
/// Feature code, sync code, and screens should import providers from
/// **this file only**.
///
/// ## Per-user database isolation
/// Each logged-in user has their own SQLite file on disk.
/// `activeUsernameProvider` holds the currently logged-in username.
/// `appDatabaseProvider` is a family keyed by username that opens or reuses
/// the correct per-user [AppDatabase].
/// `currentAppDatabaseProvider` is a convenience alias that delegates to the
/// family using the active username — all DAOs should watch this.
///
/// Adding a new DAO? Add its provider here once, then expose it via the
/// feature's own presentation/providers folder if it needs additional
/// composition.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/ledger_repository.dart';
import '../repositories/ledger_repository_impl.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/transaction_repository_impl.dart';
import '../repositories/inventory_repository.dart';
import '../repositories/inventory_repository_impl.dart';

import '../app_database.dart';
import '../daos/app_meta_dao.dart';
import '../daos/pocket_ledger/charges_dao.dart';
import '../daos/pocket_ledger/fee_transactions_dao.dart';
import '../daos/pocket_ledger/ledger_entries_dao.dart';
import '../daos/pocket_ledger/movement_categories_dao.dart';
import '../daos/pocket_ledger/parties_dao.dart';
import '../daos/pocket_ledger/transaction_types_dao.dart';
import '../daos/pocket_ledger/transactions_dao.dart';
import '../daos/pocket_ledger_dao.dart';
import '../daos/sync_state_dao.dart';
import '../daos/tinda_tracker/customers_dao.dart';
import '../daos/tinda_tracker/product_categories_dao.dart';
import '../daos/tinda_tracker/product_unit_conversions_dao.dart';
import '../daos/tinda_tracker/products_dao.dart';
import '../daos/tinda_tracker/sale_items_dao.dart';
import '../daos/tinda_tracker/sales_dao.dart';
import '../daos/tinda_tracker/shelf_locations_dao.dart';
import '../daos/tinda_tracker/stock_movements_dao.dart';
import '../daos/tinda_tracker/utang_records_dao.dart';
import '../daos/tinda_tracker_dao.dart';

// ── Database ─────────────────────────────────────────────────────────────────

import '../connection/native.dart';

/// Holds the username of the currently authenticated user.
///
/// Set to the real username string on login, and reset to an empty string on
/// logout. All database providers derive their connection from this value.
final activeUsernameProvider = StateProvider<String>((ref) => '');

/// Per-user [AppDatabase] family.
///
/// Keyed by the sanitized username string. Riverpod automatically caches and
/// disposes each instance when it is no longer watched.
final appDatabaseProvider = Provider.family<AppDatabase, String>((ref, username) {
  final db = username.isNotEmpty
      ? AppDatabase.forExecutor(openAppConnectionForUser(username))
      : AppDatabase(); // fallback for test / legacy migration path
  ref.onDispose(db.close);
  return db;
});

/// Convenience alias that automatically reads the active username and delegates
/// to [appDatabaseProvider]. All DAOs watch this instead of the family directly
/// so that switching users hot-swaps the underlying database with zero
/// call-site changes.
final currentAppDatabaseProvider = Provider<AppDatabase>((ref) {
  final username = ref.watch(activeUsernameProvider);
  return ref.watch(appDatabaseProvider(username));
});

// ── Shared DAOs ──────────────────────────────────────────────────────────────

final databaseSyncStateDaoProvider = Provider<SyncStateDao>(
  (ref) => SyncStateDao(ref.watch(currentAppDatabaseProvider)),
);
final databaseAppMetaDaoProvider = Provider<AppMetaDao>(
  (ref) => AppMetaDao(ref.watch(currentAppDatabaseProvider)),
);

// ── Pocket Ledger DAOs ───────────────────────────────────────────────────────

final chargesDaoProvider = Provider<ChargesDao>(
  (ref) => ChargesDao(ref.watch(currentAppDatabaseProvider)),
);
final partiesDaoProvider = Provider<PartiesDao>(
  (ref) => PartiesDao(ref.watch(currentAppDatabaseProvider)),
);
final transactionTypesDaoProvider = Provider<TransactionTypesDao>(
  (ref) => TransactionTypesDao(ref.watch(currentAppDatabaseProvider)),
);
final movementCategoriesDaoProvider = Provider<MovementCategoriesDao>(
  (ref) => MovementCategoriesDao(ref.watch(currentAppDatabaseProvider)),
);
final ledgerEntriesDaoProvider = Provider<LedgerEntriesDao>(
  (ref) => LedgerEntriesDao(ref.watch(currentAppDatabaseProvider)),
);
final transactionsDaoProvider = Provider<TransactionsDao>(
  (ref) => TransactionsDao(ref.watch(currentAppDatabaseProvider)),
);
final feeTransactionsDaoProvider = Provider<FeeTransactionsDao>(
  (ref) => FeeTransactionsDao(ref.watch(currentAppDatabaseProvider)),
);

// ── Tinda Tracker DAOs ───────────────────────────────────────────────────────

final productCategoriesDaoProvider = Provider<ProductCategoriesDao>(
  (ref) => ProductCategoriesDao(ref.watch(currentAppDatabaseProvider)),
);
final shelfLocationsDaoProvider = Provider<ShelfLocationsDao>(
  (ref) => ShelfLocationsDao(ref.watch(currentAppDatabaseProvider)),
);
final productsDaoProvider = Provider<ProductsDao>(
  (ref) => ProductsDao(ref.watch(currentAppDatabaseProvider)),
);
final productUnitConversionsDaoProvider = Provider<ProductUnitConversionsDao>(
  (ref) => ProductUnitConversionsDao(ref.watch(currentAppDatabaseProvider)),
);
final stockMovementsDaoProvider = Provider<StockMovementsDao>(
  (ref) => StockMovementsDao(ref.watch(currentAppDatabaseProvider)),
);
final customersDaoProvider = Provider<CustomersDao>(
  (ref) => CustomersDao(ref.watch(currentAppDatabaseProvider)),
);
final utangRecordsDaoProvider = Provider<UtangRecordsDao>(
  (ref) => UtangRecordsDao(ref.watch(currentAppDatabaseProvider)),
);
final salesDaoProvider = Provider<SalesDao>(
  (ref) => SalesDao(ref.watch(currentAppDatabaseProvider)),
);
final saleItemsDaoProvider = Provider<SaleItemsDao>(
  (ref) => SaleItemsDao(ref.watch(currentAppDatabaseProvider)),
);

// ── Grouped facade DAOs (preferred for new code) ─────────────────────────────
//
// New repositories should depend on these grouped facades instead of injecting
// 5-7 per-table DAOs individually. The per-table providers above remain so
// existing code keeps working — both layers share the same AppDatabase
// instance, so there is no double-bookkeeping.

final pocketLedgerDaoProvider = Provider<PocketLedgerDao>(
  (ref) => PocketLedgerDao(ref.watch(currentAppDatabaseProvider)),
);
final tindaTrackerDaoProvider = Provider<TindaTrackerDao>(
  (ref) => TindaTrackerDao(ref.watch(currentAppDatabaseProvider)),
);

// ── Central Repositories ─────────────────────────────────────────────────────

final ledgerRepositoryProvider = Provider<LedgerRepository>((ref) {
  return LedgerRepositoryImpl(ref.watch(pocketLedgerDaoProvider));
});

final localTransactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(ref.watch(transactionsDaoProvider));
});

final localInventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepositoryImpl(database: ref.watch(currentAppDatabaseProvider));
});

