/// Single canonical home for every database-related Riverpod provider.
///
/// Feature code, sync code, and screens should import providers from
/// **this file only**. The legacy `lib/core/di/database_providers.dart`
/// re-exports the [appDatabaseProvider] from here for backwards
/// compatibility.
///
/// Adding a new DAO? Add its provider here once, then expose it via the
/// feature's own presentation/providers folder if it needs additional
/// composition.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_database.dart';
import '../daos/app_meta_dao.dart';
import '../daos/pocket_ledger/charges_dao.dart';
import '../daos/pocket_ledger/fee_transactions_dao.dart';
import '../daos/pocket_ledger/ledger_entries_dao.dart';
import '../daos/pocket_ledger/movement_categories_dao.dart';
import '../daos/pocket_ledger/parties_dao.dart';
import '../daos/pocket_ledger/transaction_types_dao.dart';
import '../daos/pocket_ledger/transactions_dao.dart';
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

// ── Database ─────────────────────────────────────────────────────────────────

/// Singleton-per-process [AppDatabase]. Disposed on container teardown.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

// ── Shared DAOs ──────────────────────────────────────────────────────────────

final databaseSyncStateDaoProvider = Provider<SyncStateDao>(
  (ref) => SyncStateDao(ref.watch(appDatabaseProvider)),
);
final databaseAppMetaDaoProvider = Provider<AppMetaDao>(
  (ref) => AppMetaDao(ref.watch(appDatabaseProvider)),
);

// ── Pocket Ledger DAOs ───────────────────────────────────────────────────────

final chargesDaoProvider = Provider<ChargesDao>(
  (ref) => ChargesDao(ref.watch(appDatabaseProvider)),
);
final partiesDaoProvider = Provider<PartiesDao>(
  (ref) => PartiesDao(ref.watch(appDatabaseProvider)),
);
final transactionTypesDaoProvider = Provider<TransactionTypesDao>(
  (ref) => TransactionTypesDao(ref.watch(appDatabaseProvider)),
);
final movementCategoriesDaoProvider = Provider<MovementCategoriesDao>(
  (ref) => MovementCategoriesDao(ref.watch(appDatabaseProvider)),
);
final ledgerEntriesDaoProvider = Provider<LedgerEntriesDao>(
  (ref) => LedgerEntriesDao(ref.watch(appDatabaseProvider)),
);
final transactionsDaoProvider = Provider<TransactionsDao>(
  (ref) => TransactionsDao(ref.watch(appDatabaseProvider)),
);
final feeTransactionsDaoProvider = Provider<FeeTransactionsDao>(
  (ref) => FeeTransactionsDao(ref.watch(appDatabaseProvider)),
);

// ── Tinda Tracker DAOs ───────────────────────────────────────────────────────

final productCategoriesDaoProvider = Provider<ProductCategoriesDao>(
  (ref) => ProductCategoriesDao(ref.watch(appDatabaseProvider)),
);
final shelfLocationsDaoProvider = Provider<ShelfLocationsDao>(
  (ref) => ShelfLocationsDao(ref.watch(appDatabaseProvider)),
);
final productsDaoProvider = Provider<ProductsDao>(
  (ref) => ProductsDao(ref.watch(appDatabaseProvider)),
);
final productUnitConversionsDaoProvider = Provider<ProductUnitConversionsDao>(
  (ref) => ProductUnitConversionsDao(ref.watch(appDatabaseProvider)),
);
final stockMovementsDaoProvider = Provider<StockMovementsDao>(
  (ref) => StockMovementsDao(ref.watch(appDatabaseProvider)),
);
final customersDaoProvider = Provider<CustomersDao>(
  (ref) => CustomersDao(ref.watch(appDatabaseProvider)),
);
final utangRecordsDaoProvider = Provider<UtangRecordsDao>(
  (ref) => UtangRecordsDao(ref.watch(appDatabaseProvider)),
);
final salesDaoProvider = Provider<SalesDao>(
  (ref) => SalesDao(ref.watch(appDatabaseProvider)),
);
final saleItemsDaoProvider = Provider<SaleItemsDao>(
  (ref) => SaleItemsDao(ref.watch(appDatabaseProvider)),
);
