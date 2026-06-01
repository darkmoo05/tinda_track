import '../entities/shelf_location.dart';

abstract class ShelfLocationRepository {
  Stream<List<ShelfLocation>> watchAll();
  Future<ShelfLocation?> findById(String id);
  Future<ShelfLocation> save(ShelfLocation location);
  Future<void> delete(String id);
}
