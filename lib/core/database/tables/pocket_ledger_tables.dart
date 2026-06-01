import 'package:drift/drift.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Sync-mixin: every synchronised table has the same metadata columns.
//   sync_id     — UUID generated client-side, also unique on the server.
//   device_id   — origin device; used by server to filter same-device pulls.
//   is_deleted  — soft delete flag (synced).
//   is_dirty    — local-only flag, true until the row is acknowledged by the
//                 server (push success).
//   created_at  — millis-since-epoch (UTC).
//   updated_at  — millis-since-epoch (UTC); LWW conflict resolution uses this.
// Drift mixins are added to each table via `with SyncedRow`.
// ─────────────────────────────────────────────────────────────────────────────
mixin SyncedRow on Table {
  TextColumn get syncId => text().unique()();
  TextColumn get deviceId => text().withDefault(const Constant(''))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isDirty => boolean().withDefault(const Constant(true))();
  IntColumn get createdAtMs => integer()();
  IntColumn get updatedAtMs => integer()();
}

// ─────────────────────────────────────────────────────────────────────────────
// CHARGE — tiered service-charge rules.
// Mirrors Prisma `Charge` (table `charges`).
// ─────────────────────────────────────────────────────────────────────────────
@DataClassName('ChargeRow')
class Charges extends Table with SyncedRow {
  TextColumn get id => text()();
  RealColumn get lowerBound => real()();
  RealColumn get upperBound => real()();
  RealColumn get chargeAmount => real()();
  TextColumn get transactionTypeKey =>
      text().withDefault(const Constant('gcash_cashin'))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String? get tableName => 'charges';
}

// ─────────────────────────────────────────────────────────────────────────────
// PARTY — counterpartie in transactions (banks, wallets, persons).
// Mirrors Prisma `Party` (table `parties`).
// ─────────────────────────────────────────────────────────────────────────────
@DataClassName('PartyRow')
class Parties extends Table with SyncedRow {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get accountNumber => text().withDefault(const Constant(''))();
  TextColumn get entityId => text().withDefault(const Constant(''))();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get joinDate => text()(); // ISO date string, matches Prisma
  BoolColumn get isVerified => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String? get tableName => 'parties';
}

// ─────────────────────────────────────────────────────────────────────────────
// TRANSACTION TYPE — user-defined transaction labels for the ledger UI.
// Mirrors Prisma `TransactionType` (table `transaction_types`).
// ─────────────────────────────────────────────────────────────────────────────
@DataClassName('TransactionTypeRow')
class TransactionTypes extends Table with SyncedRow {
  TextColumn get id => text()();
  TextColumn get name => text()();
  BoolColumn get isOutflow => boolean().withDefault(const Constant(false))();
  TextColumn get walletAccount => text().withDefault(const Constant('GCash'))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String? get tableName => 'transaction_types';
}

// ─────────────────────────────────────────────────────────────────────────────
// MOVEMENT CATEGORY — owner-movement classification lookup.
// Mirrors Prisma `MovementCategory` (table `movement_categories`).
// ─────────────────────────────────────────────────────────────────────────────
@DataClassName('MovementCategoryRow')
class MovementCategories extends Table with SyncedRow {
  TextColumn get id => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String? get tableName => 'movement_categories';
}

// ─────────────────────────────────────────────────────────────────────────────
// LEDGER ENTRY — the core append-only ledger row.
// Mirrors Prisma `LedgerEntry` (table `ledger_entries`).
// `transactionId` is the FK to `transactions.id` (nullable, set-null on delete).
// ─────────────────────────────────────────────────────────────────────────────
@DataClassName('LedgerEntryRow')
class LedgerEntries extends Table with SyncedRow {
  TextColumn get id => text()();
  TextColumn get transactionId => text().nullable()();
  TextColumn get entryType => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get reference => text().withDefault(const Constant(''))();
  RealColumn get amount => real()();
  RealColumn get walletDelta => real().withDefault(const Constant(0))();
  RealColumn get mayaWalletDelta => real().withDefault(const Constant(0))();
  RealColumn get onHandDelta => real().withDefault(const Constant(0))();
  RealColumn get recordedFlow => real().withDefault(const Constant(0))();
  TextColumn get tag => text().withDefault(const Constant(''))();
  TextColumn get iconKey => text().withDefault(const Constant(''))();
  TextColumn get walletAccount => text().withDefault(const Constant(''))();
  TextColumn get ownerScope => text().withDefault(const Constant('Business'))();
  TextColumn get ownerMovementType => text().nullable()();
  TextColumn get ownerCategory => text().nullable()();
  TextColumn get ownerPartyName => text().nullable()();
  TextColumn get ownerPartyAccount => text().nullable()();
  TextColumn get entryDate => text()(); // ISO date string

  @override
  Set<Column> get primaryKey => {id};

  @override
  String? get tableName => 'ledger_entries';
}

// ─────────────────────────────────────────────────────────────────────────────
// TRANSACTION — wallet transaction parent record (groups ledger entries).
// Mirrors Prisma `Transaction` (table `transactions`).
// Enums (walletProvider/direction/ocrStatus/status) are stored as TEXT and
// validated by mappers — this keeps the schema portable across SQLite versions.
// ─────────────────────────────────────────────────────────────────────────────
@DataClassName('TransactionRow')
class Transactions extends Table with SyncedRow {
  TextColumn get id => text()();
  TextColumn get walletProvider => text()(); // GCASH | MAYA
  TextColumn get direction => text()(); // CASH_IN | CASH_OUT
  RealColumn get amount => real()();
  RealColumn get chargeAmount => real().withDefault(const Constant(0))();
  RealColumn get totalAmount => real()();
  RealColumn get balanceBefore => real()();
  RealColumn get balanceAfter => real()();
  RealColumn get chargeLowerBound => real().nullable()();
  RealColumn get chargeUpperBound => real().nullable()();
  TextColumn get chargeHandling =>
      text().withDefault(const Constant('addOnTop'))();
  TextColumn get receiptImagePath => text().nullable()();
  TextColumn get receiptOriginalName => text().nullable()();
  TextColumn get receiptMimeType => text().nullable()();
  IntColumn get receiptUploadedAtMs => integer().nullable()();
  TextColumn get ocrStatus => text().withDefault(const Constant('PENDING'))();
  RealColumn get ocrExtractedAmount => real().nullable()();
  TextColumn get ocrRawText => text().nullable()();
  IntColumn get ocrProcessedAtMs => integer().nullable()();
  TextColumn get externalProvider => text().nullable()();
  TextColumn get externalTransactionId => text().nullable()();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get reference => text().withDefault(const Constant(''))();
  TextColumn get entryDate => text()();
  TextColumn get status => text().withDefault(const Constant('COMPLETED'))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String? get tableName => 'transactions';
}

// ─────────────────────────────────────────────────────────────────────────────
// FEE TRANSACTION — service-fee income row linked to a ledger entry by sync_id.
// Mirrors Prisma `FeeTransaction` (table `fee_transactions`).
// ─────────────────────────────────────────────────────────────────────────────
@DataClassName('FeeTransactionRow')
class FeeTransactions extends Table with SyncedRow {
  TextColumn get id => text()();
  TextColumn get relatedTransactionSyncId => text().nullable()();
  RealColumn get feeAmount => real()();
  TextColumn get feeType => text()();
  TextColumn get chargeDestination => text()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String? get tableName => 'fee_transactions';
}
