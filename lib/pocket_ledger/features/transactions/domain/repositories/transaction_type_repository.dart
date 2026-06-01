import '../entities/transaction_type.dart';

abstract class TransactionTypeRepository {
  Stream<List<TransactionType>> watchAll();
  Future<TransactionType?> findById(String id);
  Future<TransactionType> save(TransactionType type);
  Future<void> delete(String id);
}
