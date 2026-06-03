import '../entities/movement_category.dart';

abstract class MovementCategoryRepository {
  Stream<List<MovementCategory>> watchAll();
  Future<MovementCategory?> findById(String id);
  Future<MovementCategory> save(MovementCategory category);
  Future<void> delete(String id);
}
