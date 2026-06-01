import 'package:drift/drift.dart';

import '../../app_database.dart';
import '../../tables/tinda_tracker_tables.dart';

part 'customers_dao.g.dart';

@DriftAccessor(tables: [Customers])
class CustomersDao extends DatabaseAccessor<AppDatabase>
    with _$CustomersDaoMixin {
  CustomersDao(super.db);

  Stream<List<CustomerRow>> watchAll() {
    return (select(customers)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<CustomerRow?> findById(String id) {
    return (select(customers)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<CustomerRow?> findBySyncId(String syncId) {
    return (select(
      customers,
    )..where((t) => t.syncId.equals(syncId))).getSingleOrNull();
  }

  Future<void> upsertLocal(CustomersCompanion companion) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final patched = companion.copyWith(
      isDirty: const Value(true),
      updatedAtMs: Value(now),
      createdAtMs: companion.createdAtMs.present
          ? companion.createdAtMs
          : Value(now),
    );
    await into(customers).insertOnConflictUpdate(patched);
  }

  Future<void> softDelete(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (update(customers)..where((t) => t.id.equals(id))).write(
      CustomersCompanion(
        isDeleted: const Value(true),
        isDirty: const Value(true),
        updatedAtMs: Value(now),
      ),
    );
  }

  Future<List<CustomerRow>> pendingPush() {
    return (select(customers)..where((t) => t.isDirty.equals(true))).get();
  }

  Future<void> markClean(Iterable<String> syncIds) async {
    if (syncIds.isEmpty) return;
    await (update(customers)..where((t) => t.syncId.isIn(syncIds))).write(
      const CustomersCompanion(isDirty: Value(false)),
    );
  }

  Future<bool> upsertFromRemote(CustomersCompanion remote) async {
    final existing = await findBySyncId(remote.syncId.value);
    if (existing != null &&
        existing.updatedAtMs > remote.updatedAtMs.value &&
        existing.isDirty) {
      return false;
    }
    final patched = (existing != null && existing.id != remote.id.value)
        ? remote.copyWith(id: Value(existing.id), isDirty: const Value(false))
        : remote.copyWith(isDirty: const Value(false));
    await into(customers).insertOnConflictUpdate(patched);
    return true;
  }

  Future<int> maxUpdatedAt() async {
    final row = await (selectOnly(
      customers,
    )..addColumns([customers.updatedAtMs.max()])).getSingle();
    return row.read(customers.updatedAtMs.max()) ?? 0;
  }
}
