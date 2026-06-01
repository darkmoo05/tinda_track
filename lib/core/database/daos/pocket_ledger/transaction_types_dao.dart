import 'package:drift/drift.dart';

import '../../app_database.dart';
import '../../tables/pocket_ledger_tables.dart';

part 'transaction_types_dao.g.dart';

@DriftAccessor(tables: [TransactionTypes])
class TransactionTypesDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionTypesDaoMixin {
  TransactionTypesDao(super.db);

  Stream<List<TransactionTypeRow>> watchAll() {
    return (select(transactionTypes)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<TransactionTypeRow?> findById(String id) => (select(
    transactionTypes,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<TransactionTypeRow?> findBySyncId(String syncId) => (select(
    transactionTypes,
  )..where((t) => t.syncId.equals(syncId))).getSingleOrNull();

  Future<void> upsertLocal(TransactionTypesCompanion companion) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await into(transactionTypes).insertOnConflictUpdate(
      companion.copyWith(
        isDirty: const Value(true),
        updatedAtMs: Value(now),
        createdAtMs: companion.createdAtMs.present
            ? companion.createdAtMs
            : Value(now),
      ),
    );
  }

  Future<void> softDelete(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (update(transactionTypes)..where((t) => t.id.equals(id))).write(
      TransactionTypesCompanion(
        isDeleted: const Value(true),
        isDirty: const Value(true),
        updatedAtMs: Value(now),
      ),
    );
  }

  Future<List<TransactionTypeRow>> pendingPush() =>
      (select(transactionTypes)..where((t) => t.isDirty.equals(true))).get();

  Future<void> markClean(Iterable<String> syncIds) async {
    if (syncIds.isEmpty) return;
    await (update(transactionTypes)..where((t) => t.syncId.isIn(syncIds)))
        .write(const TransactionTypesCompanion(isDirty: Value(false)));
  }

  Future<bool> upsertFromRemote(TransactionTypesCompanion remote) async {
    final existing = await findBySyncId(remote.syncId.value);
    if (existing != null &&
        existing.updatedAtMs > remote.updatedAtMs.value &&
        existing.isDirty) {
      return false;
    }
    await into(
      transactionTypes,
    ).insertOnConflictUpdate(remote.copyWith(isDirty: const Value(false)));
    return true;
  }

  Future<int> maxUpdatedAt() async {
    final row = await (selectOnly(
      transactionTypes,
    )..addColumns([transactionTypes.updatedAtMs.max()])).getSingle();
    return row.read(transactionTypes.updatedAtMs.max()) ?? 0;
  }
}
