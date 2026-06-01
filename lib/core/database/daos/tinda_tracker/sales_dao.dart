import 'package:drift/drift.dart';

import '../../app_database.dart';
import '../../tables/tinda_tracker_tables.dart';

part 'sales_dao.g.dart';

@DriftAccessor(tables: [Sales])
class SalesDao extends DatabaseAccessor<AppDatabase> with _$SalesDaoMixin {
  SalesDao(super.db);

  Stream<List<SaleRow>> watchAll({int? limit}) {
    final q = select(sales)
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAtMs)]);
    if (limit != null) q.limit(limit);
    return q.watch();
  }

  Future<SaleRow?> findById(String id) {
    return (select(sales)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<SaleRow?> findBySyncId(String syncId) {
    return (select(
      sales,
    )..where((t) => t.syncId.equals(syncId))).getSingleOrNull();
  }

  Future<SaleRow?> findByReference(String reference) {
    return (select(
      sales,
    )..where((t) => t.reference.equals(reference))).getSingleOrNull();
  }

  Future<void> upsertLocal(SalesCompanion companion) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final patched = companion.copyWith(
      isDirty: const Value(true),
      updatedAtMs: Value(now),
      createdAtMs: companion.createdAtMs.present
          ? companion.createdAtMs
          : Value(now),
    );
    await into(sales).insertOnConflictUpdate(patched);
  }

  Future<void> softDelete(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (update(sales)..where((t) => t.id.equals(id))).write(
      SalesCompanion(
        isDeleted: const Value(true),
        isDirty: const Value(true),
        updatedAtMs: Value(now),
      ),
    );
  }

  Future<List<SaleRow>> pendingPush() {
    return (select(sales)..where((t) => t.isDirty.equals(true))).get();
  }

  Future<void> markClean(Iterable<String> syncIds) async {
    if (syncIds.isEmpty) return;
    await (update(sales)..where((t) => t.syncId.isIn(syncIds))).write(
      const SalesCompanion(isDirty: Value(false)),
    );
  }

  Future<bool> upsertFromRemote(SalesCompanion remote) async {
    final existing = await findBySyncId(remote.syncId.value);
    if (existing != null &&
        existing.updatedAtMs > remote.updatedAtMs.value &&
        existing.isDirty) {
      return false;
    }
    final patched = (existing != null && existing.id != remote.id.value)
        ? remote.copyWith(id: Value(existing.id), isDirty: const Value(false))
        : remote.copyWith(isDirty: const Value(false));
    await into(sales).insertOnConflictUpdate(patched);
    return true;
  }

  Future<int> maxUpdatedAt() async {
    final row = await (selectOnly(
      sales,
    )..addColumns([sales.updatedAtMs.max()])).getSingle();
    return row.read(sales.updatedAtMs.max()) ?? 0;
  }
}
