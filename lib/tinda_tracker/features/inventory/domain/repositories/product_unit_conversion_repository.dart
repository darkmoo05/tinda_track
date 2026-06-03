import '../entities/product_unit_conversion.dart';

abstract class ProductUnitConversionRepository {
  Stream<List<ProductUnitConversion>> watchForProduct(String productId);
  Future<List<ProductUnitConversion>> listForProduct(String productId);
  Future<ProductUnitConversion?> findById(String id);
  Future<ProductUnitConversion> save(ProductUnitConversion conversion);
  Future<void> delete(String id);
}
