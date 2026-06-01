import 'package:uuid/uuid.dart';

import '../../../../../core/database/daos/tinda_tracker/stock_movements_dao.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/repositories/stock_movement_repository.dart';
import '../mappers/stock_movement_mapper.dart';

class StockMovementRepositoryImpl implements StockMovementRepository {
  StockMovementRepositoryImpl(this._dao, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final StockMovementsDao _dao;
  final Uuid _uuid;

  @override
  Stream<List<StockMovement>> watchForProduct(String productId) {
    return _dao
        .watchForProduct(productId)
        .map((rows) => rows.map((r) => r.toDomain()).toList(growable: false));
  }

  @override
  Future<List<StockMovement>> recent({int limit = 100}) async {
    final rows = await _dao.recent(limit: limit);
    return rows.map((r) => r.toDomain()).toList(growable: false);
  }

  @override
  Future<StockMovement?> findById(String id) async {
    final row = await _dao.findById(id);
    return row?.toDomain();
  }

  @override
  Future<StockMovement> record(StockMovement movement) async {
    final now = DateTime.now();
    final prepared = movement.copyWith(
      id: movement.id.isEmpty ? _uuid.v4() : movement.id,
      createdAt: movement.createdAt.millisecondsSinceEpoch == 0
          ? now
          : movement.createdAt,
      isDirty: true,
    );
    await _dao.insertLocal(prepared.toCompanion());
    return prepared;
  }
}
