import 'package:uuid/uuid.dart';

import '../../../../../core/database/daos/tinda_tracker/shelf_locations_dao.dart';
import '../../domain/entities/shelf_location.dart';
import '../../domain/repositories/shelf_location_repository.dart';
import '../mappers/shelf_location_mapper.dart';

class ShelfLocationRepositoryImpl implements ShelfLocationRepository {
  ShelfLocationRepositoryImpl(this._dao, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final ShelfLocationsDao _dao;
  final Uuid _uuid;

  @override
  Stream<List<ShelfLocation>> watchAll() => _dao.watchAll().map(
    (rows) => rows.map((r) => r.toDomain()).toList(growable: false),
  );

  @override
  Future<ShelfLocation?> findById(String id) async {
    final row = await _dao.findById(id);
    return row?.toDomain();
  }

  @override
  Future<ShelfLocation> save(ShelfLocation location) async {
    final now = DateTime.now();
    final prepared = location.copyWith(
      id: location.id.isEmpty ? _uuid.v4() : location.id,
      sync: location.sync.copyWith(
        syncId: location.sync.syncId.isEmpty
            ? _uuid.v4()
            : location.sync.syncId,
        isDirty: true,
        updatedAt: now,
        createdAt: location.sync.createdAt.millisecondsSinceEpoch == 0
            ? now
            : location.sync.createdAt,
      ),
    );
    await _dao.upsertLocal(prepared.toCompanion());
    return prepared;
  }

  @override
  Future<void> delete(String id) => _dao.softDelete(id);
}
