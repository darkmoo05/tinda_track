import 'package:drift/drift.dart';

import '../../app_database.dart';
import '../../tables/pocket_ledger_tables.dart';

part 'ledger_entries_dao.g.dart';

/// Data-access object for the `ledger_entries` table.
@DriftAccessor(tables: [LedgerEntries])
class LedgerEntriesDao extends DatabaseAccessor<AppDatabase>
    with _$LedgerEntriesDaoMixin {
  LedgerEntriesDao(super.db);

  // ── Reactive reads ────────────────────────────────────────────────────────

  Stream<List<LedgerEntryRow>> watchAll({String? transactionId}) {
    final q = select(ledgerEntries)..where((t) => t.isDeleted.equals(false));
    if (transactionId != null) {
      q.where((t) => t.transactionId.equals(transactionId));
    }
    q.orderBy([(t) => OrderingTerm.desc(t.entryDate)]);
    return q.watch();
  }

  Future<LedgerEntryRow?> findById(String id) {
    return (select(
      ledgerEntries,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<LedgerEntryRow?> findBySyncId(String syncId) {
    return (select(
      ledgerEntries,
    )..where((t) => t.syncId.equals(syncId))).getSingleOrNull();
  }

  // ── Local writes ──────────────────────────────────────────────────────────

  Future<void> upsertLocal(LedgerEntriesCompanion companion) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final patched = companion.copyWith(
      isDirty: const Value(true),
      updatedAtMs: Value(now),
      createdAtMs: companion.createdAtMs.present
          ? companion.createdAtMs
          : Value(now),
    );
    await into(ledgerEntries).insertOnConflictUpdate(patched);
  }

  Future<void> softDelete(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (update(ledgerEntries)..where((t) => t.id.equals(id))).write(
      LedgerEntriesCompanion(
        isDeleted: const Value(true),
        isDirty: const Value(true),
        updatedAtMs: Value(now),
      ),
    );
  }

  // ── Sync hooks ────────────────────────────────────────────────────────────

  Future<List<LedgerEntryRow>> pendingPush() {
    return (select(ledgerEntries)..where((t) => t.isDirty.equals(true))).get();
  }

  Future<void> markClean(Iterable<String> syncIds) async {
    if (syncIds.isEmpty) return;
    await (update(ledgerEntries)..where((t) => t.syncId.isIn(syncIds))).write(
      const LedgerEntriesCompanion(isDirty: Value(false)),
    );
  }

  Future<bool> upsertFromRemote(LedgerEntriesCompanion remote) async {
    final syncId = remote.syncId.value;
    final existing = await findBySyncId(syncId);
    if (existing != null &&
        existing.updatedAtMs > remote.updatedAtMs.value &&
        existing.isDirty) {
      return false;
    }
    await into(
      ledgerEntries,
    ).insertOnConflictUpdate(remote.copyWith(isDirty: const Value(false)));
    return true;
  }

  Future<int> maxUpdatedAt() async {
    final row = await (selectOnly(
      ledgerEntries,
    )..addColumns([ledgerEntries.updatedAtMs.max()])).getSingle();
    return row.read(ledgerEntries.updatedAtMs.max()) ?? 0;
  }
}
