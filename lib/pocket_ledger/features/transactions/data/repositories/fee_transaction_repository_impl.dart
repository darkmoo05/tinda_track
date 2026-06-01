import 'package:uuid/uuid.dart';

import '../../../../../core/database/daos/pocket_ledger/fee_transactions_dao.dart';
import '../../domain/entities/fee_transaction.dart';
import '../../domain/repositories/fee_transaction_repository.dart';
import '../mappers/fee_transaction_mapper.dart';

class FeeTransactionRepositoryImpl implements FeeTransactionRepository {
  FeeTransactionRepositoryImpl(this._dao, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final FeeTransactionsDao _dao;
  final Uuid _uuid;

  @override
  Stream<List<FeeTransaction>> watchAll({String? relatedTransactionSyncId}) {
    return _dao
        .watchAll(relatedTransactionSyncId: relatedTransactionSyncId)
        .map((rows) => rows.map((r) => r.toDomain()).toList(growable: false));
  }

  @override
  Future<FeeTransaction?> findById(String id) async {
    final row = await _dao.findById(id);
    return row?.toDomain();
  }

  @override
  Future<FeeTransaction> save(FeeTransaction fee) async {
    final now = DateTime.now();
    final prepared = fee.copyWith(
      id: fee.id.isEmpty ? _uuid.v4() : fee.id,
      sync: fee.sync.copyWith(
        syncId: fee.sync.syncId.isEmpty ? _uuid.v4() : fee.sync.syncId,
        isDirty: true,
        updatedAt: now,
        createdAt: fee.sync.createdAt.millisecondsSinceEpoch == 0
            ? now
            : fee.sync.createdAt,
      ),
    );
    await _dao.upsertLocal(prepared.toCompanion());
    return prepared;
  }

  @override
  Future<void> delete(String id) => _dao.softDelete(id);
}
