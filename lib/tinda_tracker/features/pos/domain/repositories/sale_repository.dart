import '../entities/sale.dart';

abstract class SaleRepository {
  Stream<List<Sale>> watchAll({int? limit});

  /// Returns the sale with its [SaleItem]s populated.
  Future<Sale?> findById(String id);

  /// Persists a sale and its line items atomically. The line items are
  /// taken from `sale.items` — the repository handles assigning ids,
  /// timestamps and the `saleId` foreign key.
  Future<Sale> save(Sale sale);

  Future<void> delete(String id);
}
