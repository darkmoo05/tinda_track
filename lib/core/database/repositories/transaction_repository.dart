import '../../../../pocket_ledger/features/transactions/domain/entities/transaction.dart';

abstract class TransactionRepository {
  Stream<List<TxRecord>> watchAll({String? walletProvider});
  Future<TxRecord?> findById(String id);
  Future<TxRecord> save(TxRecord tx);
  Future<void> delete(String id);
}
