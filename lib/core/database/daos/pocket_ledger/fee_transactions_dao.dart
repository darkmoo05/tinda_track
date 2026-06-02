import 'package:drift/drift.dart';

import '../../app_database.dart';
import '../../lww.dart';
import '../../tables/pocket_ledger_tables.dart';

part 'fee_transactions_dao.g.dart';

/// Data-access object for the `fee_transactions` table.
@DriftAccessor(tables: [FeeTransactions])
class FeeTransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$FeeTransactionsDaoMixin {
  FeeTransactionsDao(super.db);

  // ── Reactive reads ────────────────────────────────────────────────────────

  Stream<List<FeeTransactionRow>> watchAll({String? relatedTransactionSyncId}) {
    final q = select(feeTransactions)..where((t) => t.isDeleted.equals(false));
    if (relatedTransactionSyncId != null) {
      q.where(
        (t) => t.relatedTransactionSyncId.equals(relatedTransactionSyncId),
      );
    }
    q.orderBy([(t) => OrderingTerm.desc(t.createdAtMs)]);
    return q.watch();
  }

  Future<FeeTransactionRow?> findById(String id) {
    return (select(
      feeTransactions,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<FeeTransactionRow?> findBySyncId(String syncId) {
    return (select(
      feeTransactions,
    )..where((t) => t.syncId.equals(syncId))).getSingleOrNull();
  }

  // ── Local writes ──────────────────────────────────────────────────────────

  Future<void> upsertLocal(FeeTransactionsCompanion companion) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final patched = companion.copyWith(
      isDirty: const Value(true),
      updatedAtMs: Value(now),
      createdAtMs: companion.createdAtMs.present
          ? companion.createdAtMs
          : Value(now),
    );
    await into(feeTransactions).insertOnConflictUpdate(patched);
  }

  Future<void> softDelete(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (update(feeTransactions)..where((t) => t.id.equals(id))).write(
      FeeTransactionsCompanion(
        isDeleted: const Value(true),
        isDirty: const Value(true),
        updatedAtMs: Value(now),
      ),
    );
  }

  // ── Sync hooks ────────────────────────────────────────────────────────────

  Future<List<FeeTransactionRow>> pendingPush() {
    return (select(
      feeTransactions,
    )..where((t) => t.isDirty.equals(true))).get();
  }

  Future<void> markClean(Iterable<String> syncIds) async {
    if (syncIds.isEmpty) return;
    await (update(feeTransactions)..where((t) => t.syncId.isIn(syncIds))).write(
      const FeeTransactionsCompanion(isDirty: Value(false)),
    );
  }

  Future<bool> upsertFromRemote(FeeTransactionsCompanion remote) async {
    final syncId = remote.syncId.value;
    final existing = await findBySyncId(syncId);
    if (existing != null &&
        Lww.localShouldKeep(
          localUpdatedAtMs: existing.updatedAtMs,
          localIsDirty: existing.isDirty,
          remoteUpdatedAtMs: remote.updatedAtMs.value,
        )) {
      return false;
    }
    await into(
      feeTransactions,
    ).insertOnConflictUpdate(remote.copyWith(isDirty: const Value(false)));
    return true;
  }

  Future<int> maxUpdatedAt() async {
    final row = await (selectOnly(
      feeTransactions,
    )..addColumns([feeTransactions.updatedAtMs.max()])).getSingle();
    return row.read(feeTransactions.updatedAtMs.max()) ?? 0;
  }
}
