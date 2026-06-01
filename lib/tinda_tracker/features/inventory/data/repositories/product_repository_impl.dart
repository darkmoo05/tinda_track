import 'package:uuid/uuid.dart';

import '../../../../../core/database/daos/tinda_tracker/products_dao.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../mappers/product_mapper.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._dao, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final ProductsDao _dao;
  final Uuid _uuid;

  @override
  Stream<List<Product>> watchAll({String? categoryId, bool? activeOnly}) {
    return _dao
        .watchAll(categoryId: categoryId, activeOnly: activeOnly)
        .map((rows) => rows.map((r) => r.toDomain()).toList(growable: false));
  }

  @override
  Future<Product?> findById(String id) async {
    final row = await _dao.findById(id);
    return row?.toDomain();
  }

  @override
  Future<Product?> findBySku(String sku) async {
    final row = await _dao.findBySku(sku);
    return row?.toDomain();
  }

  @override
  Future<Product> save(Product product) async {
    final now = DateTime.now();
    final prepared = product.copyWith(
      id: product.id.isEmpty ? _uuid.v4() : product.id,
      sync: product.sync.copyWith(
        syncId: product.sync.syncId.isEmpty ? _uuid.v4() : product.sync.syncId,
        isDirty: true,
        updatedAt: now,
        createdAt: product.sync.createdAt.millisecondsSinceEpoch == 0
            ? now
            : product.sync.createdAt,
      ),
    );
    await _dao.upsertLocal(prepared.toCompanion());
    return prepared;
  }

  @override
  Future<void> delete(String id) => _dao.softDelete(id);

  @override
  Future<double> adjustStock(String productId, double delta) =>
      _dao.adjustStock(productId, delta);
}
