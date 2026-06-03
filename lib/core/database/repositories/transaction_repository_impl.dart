import 'package:uuid/uuid.dart';

import '../daos/pocket_ledger/transactions_dao.dart';
import '../../../../pocket_ledger/features/transactions/domain/entities/transaction.dart';
import '../../../../pocket_ledger/features/transactions/data/mappers/transaction_mapper.dart';
import 'transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this._dao, {Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  final TransactionsDao _dao;
  final Uuid _uuid;

  @override
  Stream<List<TxRecord>> watchAll({String? walletProvider}) {
    return _dao
        .watchAll(walletProvider: walletProvider)
        .map((rows) => rows.map((r) => r.toDomain()).toList(growable: false));
  }

  @override
  Future<TxRecord?> findById(String id) async {
    final row = await _dao.findById(id);
    return row?.toDomain();
  }

  @override
  Future<TxRecord> save(TxRecord tx) async {
    final now = DateTime.now();
    final prepared = tx.copyWith(
      id: tx.id.isEmpty ? _uuid.v4() : tx.id,
      sync: tx.sync.copyWith(
        syncId: tx.sync.syncId.isEmpty ? _uuid.v4() : tx.sync.syncId,
        isDirty: true,
        updatedAt: now,
        createdAt: tx.sync.createdAt.millisecondsSinceEpoch == 0
            ? now
            : tx.sync.createdAt,
      ),
    );
    await _dao.upsertLocal(prepared.toCompanion());
    return prepared;
  }

  @override
  Future<void> delete(String id) => _dao.softDelete(id);
}
