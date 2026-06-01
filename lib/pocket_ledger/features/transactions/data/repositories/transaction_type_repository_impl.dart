import 'package:uuid/uuid.dart';

import '../../../../../../core/database/daos/pocket_ledger/transaction_types_dao.dart';
import '../../domain/entities/transaction_type.dart';
import '../../domain/repositories/transaction_type_repository.dart';
import '../mappers/transaction_type_mapper.dart';

class TransactionTypeRepositoryImpl implements TransactionTypeRepository {
  TransactionTypeRepositoryImpl(this._dao, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final TransactionTypesDao _dao;
  final Uuid _uuid;

  @override
  Stream<List<TransactionType>> watchAll() => _dao.watchAll().map(
    (rows) => rows.map((r) => r.toDomain()).toList(growable: false),
  );

  @override
  Future<TransactionType?> findById(String id) async =>
      (await _dao.findById(id))?.toDomain();

  @override
  Future<TransactionType> save(TransactionType type) async {
    final now = DateTime.now();
    final prepared = type.copyWith(
      id: type.id.isEmpty ? _uuid.v4() : type.id,
      sync: type.sync.copyWith(
        syncId: type.sync.syncId.isEmpty ? _uuid.v4() : type.sync.syncId,
        isDirty: true,
        updatedAt: now,
        createdAt: type.sync.createdAt.millisecondsSinceEpoch == 0
            ? now
            : type.sync.createdAt,
      ),
    );
    await _dao.upsertLocal(prepared.toCompanion());
    return prepared;
  }

  @override
  Future<void> delete(String id) => _dao.softDelete(id);
}
