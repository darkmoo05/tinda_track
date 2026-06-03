import '../entities/sale_item.dart';

abstract class SaleItemRepository {
  Stream<List<SaleItem>> watchForSale(String saleId);
  Future<List<SaleItem>> listForSale(String saleId);
  Future<SaleItem?> findById(String id);
}
