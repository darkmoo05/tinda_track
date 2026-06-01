import 'package:uuid/uuid.dart';

import '../../../../../core/database/daos/tinda_tracker/product_categories_dao.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/repositories/product_category_repository.dart';
import '../mappers/product_category_mapper.dart';

class ProductCategoryRepositoryImpl implements ProductCategoryRepository {
  ProductCategoryRepositoryImpl(this._dao, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final ProductCategoriesDao _dao;
  final Uuid _uuid;

  @override
  Stream<List<ProductCategory>> watchAll() => _dao.watchAll().map(
    (rows) => rows.map((r) => r.toDomain()).toList(growable: false),
  );

  @override
  Future<ProductCategory?> findById(String id) async {
    final row = await _dao.findById(id);
    return row?.toDomain();
  }

  @override
  Future<ProductCategory> save(ProductCategory category) async {
    final now = DateTime.now();
    final prepared = category.copyWith(
      id: category.id.isEmpty ? _uuid.v4() : category.id,
      sync: category.sync.copyWith(
        syncId: category.sync.syncId.isEmpty
            ? _uuid.v4()
            : category.sync.syncId,
        isDirty: true,
        updatedAt: now,
        createdAt: category.sync.createdAt.millisecondsSinceEpoch == 0
            ? now
            : category.sync.createdAt,
      ),
    );
    await _dao.upsertLocal(prepared.toCompanion());
    return prepared;
  }

  @override
  Future<void> delete(String id) => _dao.softDelete(id);
}
