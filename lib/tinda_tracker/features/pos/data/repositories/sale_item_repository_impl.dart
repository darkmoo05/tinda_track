import '../../../../../core/database/daos/tinda_tracker/sale_items_dao.dart';
import '../../domain/entities/sale_item.dart';
import '../../domain/repositories/sale_item_repository.dart';
import '../mappers/sale_item_mapper.dart';

class SaleItemRepositoryImpl implements SaleItemRepository {
  SaleItemRepositoryImpl(this._dao);

  final SaleItemsDao _dao;

  @override
  Stream<List<SaleItem>> watchForSale(String saleId) => _dao
      .watchForSale(saleId)
      .map((rows) => rows.map((r) => r.toDomain()).toList(growable: false));

  @override
  Future<List<SaleItem>> listForSale(String saleId) async {
    final rows = await _dao.listForSale(saleId);
    return rows.map((r) => r.toDomain()).toList(growable: false);
  }

  @override
  Future<SaleItem?> findById(String id) async {
    final row = await _dao.findById(id);
    return row?.toDomain();
  }
}
