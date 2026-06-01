import 'package:drift/drift.dart';

import '../../app_database.dart';
import '../../tables/tinda_tracker_tables.dart';

part 'stock_movements_dao.g.dart';

/// Stock movement audit log.
///
/// Not a `SyncedRow` on the backend (Prisma has no syncId) — the table only
/// has `is_dirty` for an outbox-style local replay. Methods omit `markClean`
/// behaviour around sync_id because there is no LWW for these rows.
@DriftAccessor(tables: [StockMovements])
class StockMovementsDao extends DatabaseAccessor<AppDatabase>
    with _$StockMovementsDaoMixin {
  StockMovementsDao(super.db);

  Stream<List<StockMovementRow>> watchForProduct(String productId) {
    return (select(stockMovements)
          ..where((t) => t.productId.equals(productId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAtMs)]))
        .watch();
  }

  Future<List<StockMovementRow>> recent({int limit = 100}) {
    return (select(stockMovements)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAtMs)])
          ..limit(limit))
        .get();
  }

  Future<StockMovementRow?> findById(String id) {
    return (select(
      stockMovements,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertLocal(StockMovementsCompanion companion) async {
    await into(
      stockMovements,
    ).insert(companion.copyWith(isDirty: const Value(true)));
  }

  /// Returns dirty movements awaiting outbox replay.
  Future<List<StockMovementRow>> pendingPush() {
    return (select(stockMovements)..where((t) => t.isDirty.equals(true))).get();
  }

  Future<void> markClean(Iterable<String> ids) async {
    if (ids.isEmpty) return;
    await (update(stockMovements)..where((t) => t.id.isIn(ids))).write(
      const StockMovementsCompanion(isDirty: Value(false)),
    );
  }
}
