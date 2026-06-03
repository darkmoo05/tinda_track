import '../entities/product_category.dart';

abstract class ProductCategoryRepository {
  Stream<List<ProductCategory>> watchAll();
  Future<ProductCategory?> findById(String id);
  Future<ProductCategory> save(ProductCategory category);
  Future<void> delete(String id);
}
