import '../entities/product.dart';

abstract class ProductRepository {
  Stream<List<Product>> watchAll({String? categoryId, bool? activeOnly});
  Future<Product?> findById(String id);
  Future<Product?> findBySku(String sku);
  Future<Product> save(Product product);
  Future<void> delete(String id);

  /// Atomically adjusts stock and returns the new value.
  Future<double> adjustStock(String productId, double delta);
}
