import 'package:uuid/uuid.dart';

import '../../../../../core/database/daos/tinda_tracker/product_unit_conversions_dao.dart';
import '../../domain/entities/product_unit_conversion.dart';
import '../../domain/repositories/product_unit_conversion_repository.dart';
import '../mappers/product_unit_conversion_mapper.dart';

class ProductUnitConversionRepositoryImpl
    implements ProductUnitConversionRepository {
  ProductUnitConversionRepositoryImpl(this._dao, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final ProductUnitConversionsDao _dao;
  final Uuid _uuid;

  @override
  Stream<List<ProductUnitConversion>> watchForProduct(String productId) {
    return _dao
        .watchForProduct(productId)
        .map((rows) => rows.map((r) => r.toDomain()).toList(growable: false));
  }

  @override
  Future<List<ProductUnitConversion>> listForProduct(String productId) async {
    final rows = await _dao.listForProduct(productId);
    return rows.map((r) => r.toDomain()).toList(growable: false);
  }

  @override
  Future<ProductUnitConversion?> findById(String id) async {
    final row = await _dao.findById(id);
    return row?.toDomain();
  }

  @override
  Future<ProductUnitConversion> save(ProductUnitConversion conversion) async {
    final now = DateTime.now();
    final rounded = conversion.copyWith(
      costPrice: double.parse(conversion.costPrice.toStringAsFixed(2)),
      sellingPrice: double.parse(conversion.sellingPrice.toStringAsFixed(2)),
    );
    final prepared = rounded.copyWith(
      id: rounded.id.isEmpty ? _uuid.v4() : rounded.id,
      sync: rounded.sync.copyWith(
        syncId: rounded.sync.syncId.isEmpty ? _uuid.v4() : rounded.sync.syncId,
        isDirty: true,
        updatedAt: now,
        createdAt: rounded.sync.createdAt.millisecondsSinceEpoch == 0
            ? now
            : rounded.sync.createdAt,
      ),
    );
    await _dao.upsertLocal(prepared.toCompanion());
    return prepared;
  }

  @override
  Future<void> delete(String id) => _dao.softDelete(id);
}
