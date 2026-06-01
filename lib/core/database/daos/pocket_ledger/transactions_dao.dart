import 'package:drift/drift.dart';

import '../../app_database.dart';
import '../../tables/pocket_ledger_tables.dart';

part 'transactions_dao.g.dart';

/// Data-access object for the `transactions` table (wallet transactions).
@DriftAccessor(tables: [Transactions])
class TransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  // ── Reactive reads ────────────────────────────────────────────────────────

  Stream<List<TransactionRow>> watchAll({String? walletProvider}) {
    final q = select(transactions)..where((t) => t.isDeleted.equals(false));
    if (walletProvider != null) {
      q.where((t) => t.walletProvider.equals(walletProvider));
    }
    q.orderBy([(t) => OrderingTerm.desc(t.entryDate)]);
    return q.watch();
  }

  Future<TransactionRow?> findById(String id) {
    return (select(
      transactions,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<TransactionRow?> findBySyncId(String syncId) {
    return (select(
      transactions,
    )..where((t) => t.syncId.equals(syncId))).getSingleOrNull();
  }

  // ── Local writes ──────────────────────────────────────────────────────────

  Future<void> upsertLocal(TransactionsCompanion companion) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final patched = companion.copyWith(
      isDirty: const Value(true),
      updatedAtMs: Value(now),
      createdAtMs: companion.createdAtMs.present
          ? companion.createdAtMs
          : Value(now),
    );
    await into(transactions).insertOnConflictUpdate(patched);
  }

  Future<void> softDelete(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (update(transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        isDeleted: const Value(true),
        isDirty: const Value(true),
        updatedAtMs: Value(now),
      ),
    );
  }

  // ── Sync hooks ────────────────────────────────────────────────────────────

  Future<List<TransactionRow>> pendingPush() {
    return (select(transactions)..where((t) => t.isDirty.equals(true))).get();
  }

  Future<void> markClean(Iterable<String> syncIds) async {
    if (syncIds.isEmpty) return;
    await (update(transactions)..where((t) => t.syncId.isIn(syncIds))).write(
      const TransactionsCompanion(isDirty: Value(false)),
    );
  }

  Future<bool> upsertFromRemote(TransactionsCompanion remote) async {
    final syncId = remote.syncId.value;
    final existing = await findBySyncId(syncId);
    if (existing != null &&
        existing.updatedAtMs > remote.updatedAtMs.value &&
        existing.isDirty) {
      return false;
    }
    await into(
      transactions,
    ).insertOnConflictUpdate(remote.copyWith(isDirty: const Value(false)));
    return true;
  }

  Future<int> maxUpdatedAt() async {
    final row = await (selectOnly(
      transactions,
    )..addColumns([transactions.updatedAtMs.max()])).getSingle();
    return row.read(transactions.updatedAtMs.max()) ?? 0;
  }
}
