import 'package:uuid/uuid.dart';
import '../daos/pocket_ledger_dao.dart';
import 'ledger_repository.dart';

import 'package:tinda_track/pocket_ledger/features/transactions/domain/entities/ledger_entry.dart';
import 'package:tinda_track/pocket_ledger/features/charges/domain/entities/charge.dart';
import 'package:tinda_track/pocket_ledger/features/parties/domain/entities/party.dart';
import 'package:tinda_track/pocket_ledger/features/transactions/domain/entities/transaction_type.dart';
import 'package:tinda_track/pocket_ledger/features/transactions/domain/entities/movement_category.dart';
import 'package:tinda_track/pocket_ledger/features/transactions/domain/entities/fee_transaction.dart';

import 'package:tinda_track/pocket_ledger/features/charges/data/mappers/charge_mapper.dart';
import 'package:tinda_track/pocket_ledger/features/parties/data/mappers/party_mapper.dart';
import 'package:tinda_track/pocket_ledger/features/transactions/data/mappers/ledger_entry_mapper.dart';
import 'package:tinda_track/pocket_ledger/features/transactions/data/mappers/transaction_type_mapper.dart';
import 'package:tinda_track/pocket_ledger/features/transactions/data/mappers/movement_category_mapper.dart';
import 'package:tinda_track/pocket_ledger/features/transactions/data/mappers/fee_transaction_mapper.dart';

class LedgerRepositoryImpl implements LedgerRepository {
  LedgerRepositoryImpl(this._dao, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final PocketLedgerDao _dao;
  final Uuid _uuid;

  // ── Ledger Entries ─────────────────────────────────────────────────────────

  @override
  Stream<List<LedgerEntry>> watchAllLedgerEntries({String? transactionId}) {
    return _dao.ledgerEntries
        .watchAll(transactionId: transactionId)
        .map((rows) => rows.map((r) => r.toDomain()).toList(growable: false));
  }

  @override
  Future<LedgerEntry?> findLedgerEntryById(String id) async {
    final row = await _dao.ledgerEntries.findById(id);
    return row?.toDomain();
  }

  @override
  Future<LedgerEntry> saveLedgerEntry(LedgerEntry entry) async {
    final now = DateTime.now();
    final prepared = entry.copyWith(
      id: entry.id.isEmpty ? _uuid.v4() : entry.id,
      sync: entry.sync.copyWith(
        syncId: entry.sync.syncId.isEmpty ? _uuid.v4() : entry.sync.syncId,
        isDirty: true,
        updatedAt: now,
        createdAt: entry.sync.createdAt.millisecondsSinceEpoch == 0
            ? now
            : entry.sync.createdAt,
      ),
    );
    await _dao.ledgerEntries.upsertLocal(prepared.toCompanion());
    return prepared;
  }

  @override
  Future<void> deleteLedgerEntry(String id) => _dao.ledgerEntries.softDelete(id);

  // ── Parties ────────────────────────────────────────────────────────────────

  @override
  Stream<List<Party>> watchAllParties() {
    return _dao.parties
        .watchAll()
        .map((rows) => rows.map((r) => r.toDomain()).toList(growable: false));
  }

  @override
  Future<Party?> findPartyById(String id) async {
    final row = await _dao.parties.findById(id);
    return row?.toDomain();
  }

  @override
  Future<Party> saveParty(Party party) async {
    final now = DateTime.now();
    final prepared = party.copyWith(
      id: party.id.isEmpty ? _uuid.v4() : party.id,
      sync: party.sync.copyWith(
        syncId: party.sync.syncId.isEmpty ? _uuid.v4() : party.sync.syncId,
        isDirty: true,
        updatedAt: now,
        createdAt: party.sync.createdAt.millisecondsSinceEpoch == 0
            ? now
            : party.sync.createdAt,
      ),
    );
    await _dao.parties.upsertLocal(prepared.toCompanion());
    return prepared;
  }

  @override
  Future<void> deleteParty(String id) => _dao.parties.softDelete(id);

  // ── Charges ────────────────────────────────────────────────────────────────

  @override
  Stream<List<Charge>> watchAllCharges({String? transactionTypeKey}) {
    return _dao.charges
        .watchAll(transactionTypeKey: transactionTypeKey)
        .map((rows) => rows.map((r) => r.toDomain()).toList(growable: false));
  }

  @override
  Future<Charge?> findChargeById(String id) async {
    final row = await _dao.charges.findById(id);
    return row?.toDomain();
  }

  @override
  Future<Charge> saveCharge(Charge charge) async {
    final now = DateTime.now();
    final prepared = charge.copyWith(
      id: charge.id.isEmpty ? _uuid.v4() : charge.id,
      sync: charge.sync.copyWith(
        syncId: charge.sync.syncId.isEmpty ? _uuid.v4() : charge.sync.syncId,
        isDirty: true,
        updatedAt: now,
        createdAt: charge.sync.createdAt.millisecondsSinceEpoch == 0
            ? now
            : charge.sync.createdAt,
      ),
    );
    await _dao.charges.upsertLocal(prepared.toCompanion());
    return prepared;
  }

  @override
  Future<void> deleteCharge(String id) => _dao.charges.softDelete(id);

  // ── Transaction Types ──────────────────────────────────────────────────────

  @override
  Stream<List<TransactionType>> watchAllTransactionTypes() {
    return _dao.transactionTypes
        .watchAll()
        .map((rows) => rows.map((r) => r.toDomain()).toList(growable: false));
  }

  @override
  Future<TransactionType?> findTransactionTypeById(String id) async {
    final row = await _dao.transactionTypes.findById(id);
    return row?.toDomain();
  }

  @override
  Future<TransactionType> saveTransactionType(TransactionType type) async {
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
    await _dao.transactionTypes.upsertLocal(prepared.toCompanion());
    return prepared;
  }

  @override
  Future<void> deleteTransactionType(String id) => _dao.transactionTypes.softDelete(id);

  // ── Movement Categories ────────────────────────────────────────────────────

  @override
  Stream<List<MovementCategory>> watchAllMovementCategories() {
    return _dao.movementCategories
        .watchAll()
        .map((rows) => rows.map((r) => r.toDomain()).toList(growable: false));
  }

  @override
  Future<MovementCategory?> findMovementCategoryById(String id) async {
    final row = await _dao.movementCategories.findById(id);
    return row?.toDomain();
  }

  @override
  Future<MovementCategory> saveMovementCategory(MovementCategory category) async {
    final now = DateTime.now();
    final prepared = category.copyWith(
      id: category.id.isEmpty ? _uuid.v4() : category.id,
      sync: category.sync.copyWith(
        syncId: category.sync.syncId.isEmpty ? _uuid.v4() : category.sync.syncId,
        isDirty: true,
        updatedAt: now,
        createdAt: category.sync.createdAt.millisecondsSinceEpoch == 0
            ? now
            : category.sync.createdAt,
      ),
    );
    await _dao.movementCategories.upsertLocal(prepared.toCompanion());
    return prepared;
  }

  @override
  Future<void> deleteMovementCategory(String id) => _dao.movementCategories.softDelete(id);

  // ── Fee Transactions ───────────────────────────────────────────────────────

  @override
  Stream<List<FeeTransaction>> watchAllFeeTransactions() {
    return _dao.feeTransactions
        .watchAll()
        .map((rows) => rows.map((r) => r.toDomain()).toList(growable: false));
  }

  @override
  Future<FeeTransaction?> findFeeTransactionById(String id) async {
    final row = await _dao.feeTransactions.findById(id);
    return row?.toDomain();
  }

  @override
  Future<FeeTransaction> saveFeeTransaction(FeeTransaction feeTx) async {
    final now = DateTime.now();
    final prepared = feeTx.copyWith(
      id: feeTx.id.isEmpty ? _uuid.v4() : feeTx.id,
      sync: feeTx.sync.copyWith(
        syncId: feeTx.sync.syncId.isEmpty ? _uuid.v4() : feeTx.sync.syncId,
        isDirty: true,
        updatedAt: now,
        createdAt: feeTx.sync.createdAt.millisecondsSinceEpoch == 0
            ? now
            : feeTx.sync.createdAt,
      ),
    );
    await _dao.feeTransactions.upsertLocal(prepared.toCompanion());
    return prepared;
  }

  @override
  Future<void> deleteFeeTransaction(String id) => _dao.feeTransactions.softDelete(id);
}
