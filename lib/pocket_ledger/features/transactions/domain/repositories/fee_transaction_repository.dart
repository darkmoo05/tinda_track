import '../entities/fee_transaction.dart';

abstract class FeeTransactionRepository {
  Stream<List<FeeTransaction>> watchAll({String? relatedTransactionSyncId});
  Future<FeeTransaction?> findById(String id);
  Future<FeeTransaction> save(FeeTransaction fee);
  Future<void> delete(String id);
}
