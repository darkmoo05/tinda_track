import '../entities/ledger_entry.dart';

abstract class LedgerEntryRepository {
  Stream<List<LedgerEntry>> watchAll({String? transactionId});
  Future<LedgerEntry?> findById(String id);
  Future<LedgerEntry> save(LedgerEntry entry);
  Future<void> delete(String id);
}
