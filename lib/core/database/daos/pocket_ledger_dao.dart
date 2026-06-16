import '../app_database.dart';
import 'pocket_ledger/charges_dao.dart';
import 'pocket_ledger/fee_transactions_dao.dart';
import 'pocket_ledger/ledger_entries_dao.dart';
import 'pocket_ledger/movement_categories_dao.dart';
import 'pocket_ledger/parties_dao.dart';
import 'pocket_ledger/transactions_dao.dart';
import 'pocket_ledger/transaction_types_dao.dart';
import 'pocket_ledger/monitoring_sessions_dao.dart';

/// Grouped facade DAO for the **pocket_ledger** module.
///
/// Per-table DAOs (e.g. [TransactionsDao], [LedgerEntriesDao]) remain the
/// authoritative implementations — they're small, focused, and individually
/// testable. This facade does two things:
///
///   1. **Single import surface** for repositories. A repository can depend on
///      `PocketLedgerDao` instead of pulling in seven separate DAO files.
///   2. **Cross-table atomic writes**. Any operation that touches more than one
///      pocket_ledger table (e.g. recording a wallet transaction together with
///      its ledger entry and fee transaction) belongs here, wrapped in a
///      single Drift `transaction { ... }` block so the on-disk state is
///      consistent and `is_dirty` flags don't end up half-set on a crash.
///
/// Add a new cross-table helper here whenever you find yourself sequencing
/// two `upsertLocal(...)` calls in a repository — that's a sign the operation
/// should be atomic.
class PocketLedgerDao {
  PocketLedgerDao(this._db)
    : charges = ChargesDao(_db),
      parties = PartiesDao(_db),
      transactionTypes = TransactionTypesDao(_db),
      movementCategories = MovementCategoriesDao(_db),
      ledgerEntries = LedgerEntriesDao(_db),
      transactions = TransactionsDao(_db),
      feeTransactions = FeeTransactionsDao(_db),
      monitoringSessions = MonitoringSessionsDao(_db);

  final AppDatabase _db;

  /// Underlying database — exposed for advanced callers that need ad-hoc
  /// `selectOnly` / `customSelect` queries (rare; prefer per-table DAOs).
  AppDatabase get database => _db;

  final ChargesDao charges;
  final PartiesDao parties;
  final TransactionTypesDao transactionTypes;
  final MovementCategoriesDao movementCategories;
  final LedgerEntriesDao ledgerEntries;
  final TransactionsDao transactions;
  final FeeTransactionsDao feeTransactions;
  final MonitoringSessionsDao monitoringSessions;

  // ── Cross-table atomic writes ──────────────────────────────────────────────

  /// Records a wallet transaction together with its mirror ledger entry and
  /// (optionally) the service-fee row in **one** SQLite transaction.
  ///
  /// All companions are stamped `is_dirty = true` by their respective DAOs;
  /// the SyncOrchestrator will pick them up on the next push cycle.
  Future<void> recordWalletTransaction({
    required TransactionsCompanion transaction,
    required LedgerEntriesCompanion ledgerEntry,
    FeeTransactionsCompanion? feeTransaction,
  }) {
    return _db.transaction(() async {
      await transactions.upsertLocal(transaction);
      await ledgerEntries.upsertLocal(ledgerEntry);
      if (feeTransaction != null) {
        await feeTransactions.upsertLocal(feeTransaction);
      }
    });
  }

  /// Soft-deletes a wallet transaction *and* its dependent ledger / fee rows.
  /// Each row stays in the database (so the server can reconcile) but is
  /// hidden from `watchAll()` queries and marked dirty for next sync.
  Future<void> softDeleteWalletTransaction({
    required String transactionId,
    String? ledgerEntryId,
    String? feeTransactionId,
  }) {
    return _db.transaction(() async {
      await transactions.softDelete(transactionId);
      if (ledgerEntryId != null) {
        await ledgerEntries.softDelete(ledgerEntryId);
      }
      if (feeTransactionId != null) {
        await feeTransactions.softDelete(feeTransactionId);
      }
    });
  }
}
