import 'package:uuid/uuid.dart';

import '../../../../../core/database/daos/tinda_tracker/utang_records_dao.dart';
import '../../domain/entities/utang_record.dart';
import '../../domain/repositories/utang_record_repository.dart';
import '../mappers/utang_record_mapper.dart';

class UtangRecordRepositoryImpl implements UtangRecordRepository {
  UtangRecordRepositoryImpl(this._dao, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final UtangRecordsDao _dao;
  final Uuid _uuid;

  @override
  Stream<List<UtangRecord>> watchAll() => _dao.watchAll().map(
    (rows) => rows.map((r) => r.toDomain()).toList(growable: false),
  );

  @override
  Stream<List<UtangRecord>> watchForCustomer(String customerId) => _dao
      .watchForCustomer(customerId)
      .map((rows) => rows.map((r) => r.toDomain()).toList(growable: false));

  @override
  Future<UtangRecord?> findById(String id) async {
    final row = await _dao.findById(id);
    return row?.toDomain();
  }

  @override
  Future<UtangRecord> save(UtangRecord record) async {
    final now = DateTime.now();
    final prepared = record.copyWith(
      id: record.id.isEmpty ? _uuid.v4() : record.id,
      sync: record.sync.copyWith(
        syncId: record.sync.syncId.isEmpty ? _uuid.v4() : record.sync.syncId,
        isDirty: true,
        updatedAt: now,
        createdAt: record.sync.createdAt.millisecondsSinceEpoch == 0
            ? now
            : record.sync.createdAt,
      ),
    );
    await _dao.upsertLocal(prepared.toCompanion());
    return prepared;
  }

  @override
  Future<void> delete(String id) => _dao.softDelete(id);
}
