import '../entities/stock_movement.dart';

abstract class StockMovementRepository {
  Stream<List<StockMovement>> watchForProduct(String productId);
  Future<List<StockMovement>> recent({int limit});
  Future<StockMovement?> findById(String id);
  Future<StockMovement> record(StockMovement movement);
}
