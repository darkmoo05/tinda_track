import 'package:tinda_track/pocket_ledger/features/transactions/domain/entities/ledger_entry.dart';
import 'package:tinda_track/pocket_ledger/features/charges/domain/entities/charge.dart';
import 'package:tinda_track/pocket_ledger/features/parties/domain/entities/party.dart';
import 'package:tinda_track/pocket_ledger/features/transactions/domain/entities/transaction_type.dart';
import 'package:tinda_track/pocket_ledger/features/transactions/domain/entities/movement_category.dart';
import 'package:tinda_track/pocket_ledger/features/transactions/domain/entities/fee_transaction.dart';

abstract class LedgerRepository {
  // Ledger Entries
  Stream<List<LedgerEntry>> watchAllLedgerEntries({String? transactionId});
  Future<LedgerEntry?> findLedgerEntryById(String id);
  Future<LedgerEntry> saveLedgerEntry(LedgerEntry entry);
  Future<void> deleteLedgerEntry(String id);

  // Parties
  Stream<List<Party>> watchAllParties();
  Future<Party?> findPartyById(String id);
  Future<Party> saveParty(Party party);
  Future<void> deleteParty(String id);

  // Charges
  Stream<List<Charge>> watchAllCharges({String? transactionTypeKey});
  Future<Charge?> findChargeById(String id);
  Future<Charge> saveCharge(Charge charge);
  Future<void> deleteCharge(String id);

  // Transaction Types
  Stream<List<TransactionType>> watchAllTransactionTypes();
  Future<TransactionType?> findTransactionTypeById(String id);
  Future<TransactionType> saveTransactionType(TransactionType type);
  Future<void> deleteTransactionType(String id);

  // Movement Categories
  Stream<List<MovementCategory>> watchAllMovementCategories();
  Future<MovementCategory?> findMovementCategoryById(String id);
  Future<MovementCategory> saveMovementCategory(MovementCategory category);
  Future<void> deleteMovementCategory(String id);

  // Fee Transactions
  Stream<List<FeeTransaction>> watchAllFeeTransactions();
  Future<FeeTransaction?> findFeeTransactionById(String id);
  Future<FeeTransaction> saveFeeTransaction(FeeTransaction feeTx);
  Future<void> deleteFeeTransaction(String id);
}
