import 'package:uuid/uuid.dart';

import '../../../../../../core/database/daos/pocket_ledger/movement_categories_dao.dart';
import '../../domain/entities/movement_category.dart';
import '../../domain/repositories/movement_category_repository.dart';
import '../mappers/movement_category_mapper.dart';

class MovementCategoryRepositoryImpl implements MovementCategoryRepository {
  MovementCategoryRepositoryImpl(this._dao, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final MovementCategoriesDao _dao;
  final Uuid _uuid;

  @override
  Stream<List<MovementCategory>> watchAll() => _dao.watchAll().map(
    (rows) => rows.map((r) => r.toDomain()).toList(growable: false),
  );

  @override
  Future<MovementCategory?> findById(String id) async =>
      (await _dao.findById(id))?.toDomain();

  @override
  Future<MovementCategory> save(MovementCategory category) async {
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
