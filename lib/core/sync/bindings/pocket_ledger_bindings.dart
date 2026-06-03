import '../../../pocket_ledger/features/charges/data/mappers/charge_mapper.dart';
import '../../../pocket_ledger/features/parties/data/mappers/party_mapper.dart';
import '../../../pocket_ledger/features/transactions/data/mappers/fee_transaction_mapper.dart';
import '../../../pocket_ledger/features/transactions/data/mappers/ledger_entry_mapper.dart';
import '../../../pocket_ledger/features/transactions/data/mappers/movement_category_mapper.dart';
import '../../../pocket_ledger/features/transactions/data/mappers/transaction_mapper.dart';
import '../../../pocket_ledger/features/transactions/data/mappers/transaction_type_mapper.dart';
import '../../database/app_database.dart';
import '../../database/daos/pocket_ledger/charges_dao.dart';
import '../../database/daos/pocket_ledger/fee_transactions_dao.dart';
import '../../database/daos/pocket_ledger/ledger_entries_dao.dart';
import '../../database/daos/pocket_ledger/movement_categories_dao.dart';
import '../../database/daos/pocket_ledger/parties_dao.dart';
import '../../database/daos/pocket_ledger/transaction_types_dao.dart';
import '../../database/daos/pocket_ledger/transactions_dao.dart';
import '../../database/daos/pocket_ledger_dao.dart';
import '../engine/entity_sync.dart';
import '../engine/sync_module.dart';
import '../remote/charge_remote_repository.dart';
import '../remote/fee_transaction_remote_repository.dart';
import '../remote/ledger_entry_remote_repository.dart';
import '../remote/movement_category_remote_repository.dart';
import '../remote/party_remote_repository.dart';
import '../remote/transaction_remote_repository.dart';
import '../remote/transaction_type_remote_repository.dart';

/// Builds the `pocket_ledger` [SyncModule]. Pure factory — no state.
///
/// BUG-16 fix: takes the already-constructed [PocketLedgerDao] facade
/// (built by the riverpod provider against the same [AppDatabase]
/// instance) instead of constructing fresh per-table DAOs locally. This
/// removes the silent duplication where every sync run produced a second
/// set of DAO objects parallel to the ones in `database_providers.dart`.
SyncModule buildPocketLedgerModule(PocketLedgerDao dao) {
  final ChargesDao charges = dao.charges;
  final PartiesDao parties = dao.parties;
  final TransactionTypesDao txTypes = dao.transactionTypes;
  final MovementCategoriesDao movementCats = dao.movementCategories;
  final LedgerEntriesDao ledgerEntries = dao.ledgerEntries;
  final FeeTransactionsDao feeTx = dao.feeTransactions;
  final TransactionsDao transactions = dao.transactions;

  return SyncModule(
    key: 'pocket_ledger',
    runInTransaction: dao.database.transaction,
    entities: [
      EntitySync<ChargeRow>(
        entityKey: 'charges',
        route: '/charges',
        pendingPush: charges.pendingPush,
        markClean: charges.markClean,
        maxUpdatedAt: charges.maxUpdatedAt,
        toRemoteJson: (row) => chargeToRemoteJson(row.toDomain()),
        applyRemote: (json) =>
            charges.upsertFromRemote(chargeCompanionFromRemoteJson(json)),
        pushRemote: (payload) => ChargeRemoteRepository.instance.push(payload),
        pullRemote: ({required deviceId, since}) => ChargeRemoteRepository
            .instance
            .pull(deviceId: deviceId, since: since),
      ),
      EntitySync<PartyRow>(
        entityKey: 'parties',
        route: '/parties',
        pendingPush: parties.pendingPush,
        markClean: parties.markClean,
        maxUpdatedAt: parties.maxUpdatedAt,
        toRemoteJson: (row) => partyToRemoteJson(row.toDomain()),
        applyRemote: (json) =>
            parties.upsertFromRemote(partyCompanionFromRemoteJson(json)),
        pushRemote: (payload) => PartyRemoteRepository.instance.push(payload),
        pullRemote: ({required deviceId, since}) => PartyRemoteRepository
            .instance
            .pull(deviceId: deviceId, since: since),
      ),
      EntitySync<TransactionTypeRow>(
        entityKey: 'transaction_types',
        route: '/transaction-types',
        pendingPush: txTypes.pendingPush,
        markClean: txTypes.markClean,
        maxUpdatedAt: txTypes.maxUpdatedAt,
        toRemoteJson: (row) => transactionTypeToRemoteJson(row.toDomain()),
        applyRemote: (json) => txTypes.upsertFromRemote(
          transactionTypeCompanionFromRemoteJson(json),
        ),
        pushRemote: (payload) =>
            TransactionTypeRemoteRepository.instance.push(payload),
        pullRemote: ({required deviceId, since}) =>
            TransactionTypeRemoteRepository.instance.pull(
              deviceId: deviceId,
              since: since,
            ),
      ),
      EntitySync<MovementCategoryRow>(
        entityKey: 'movement_categories',
        route: '/movement-categories',
        pendingPush: movementCats.pendingPush,
        markClean: movementCats.markClean,
        maxUpdatedAt: movementCats.maxUpdatedAt,
        toRemoteJson: (row) => movementCategoryToRemoteJson(row.toDomain()),
        applyRemote: (json) => movementCats.upsertFromRemote(
          movementCategoryCompanionFromRemoteJson(json),
        ),
        pushRemote: (payload) =>
            MovementCategoryRemoteRepository.instance.push(payload),
        pullRemote: ({required deviceId, since}) =>
            MovementCategoryRemoteRepository.instance.pull(
              deviceId: deviceId,
              since: since,
            ),
      ),
      EntitySync<LedgerEntryRow>(
        entityKey: 'ledger_entries',
        route: '/ledger-entries',
        pendingPush: ledgerEntries.pendingPush,
        markClean: ledgerEntries.markClean,
        maxUpdatedAt: ledgerEntries.maxUpdatedAt,
        toRemoteJson: (row) => ledgerEntryToRemoteJson(row.toDomain()),
        applyRemote: (json) => ledgerEntries.upsertFromRemote(
          ledgerEntryCompanionFromRemoteJson(json),
        ),
        pushRemote: (payload) =>
            LedgerEntryRemoteRepository.instance.push(payload),
        pullRemote: ({required deviceId, since}) => LedgerEntryRemoteRepository
            .instance
            .pull(deviceId: deviceId, since: since),
      ),
      EntitySync<TransactionRow>(
        entityKey: 'transactions',
        route: '/transactions',
        pendingPush: transactions.pendingPush,
        markClean: transactions.markClean,
        maxUpdatedAt: transactions.maxUpdatedAt,
        toRemoteJson: (row) => transactionToRemoteJson(row.toDomain()),
        applyRemote: (json) => transactions.upsertFromRemote(
          transactionCompanionFromRemoteJson(json),
        ),
        pushRemote: (payload) =>
            TransactionRemoteRepository.instance.push(payload),
        pullRemote: ({required deviceId, since}) =>
            TransactionRemoteRepository.instance.pull(
              deviceId: deviceId,
              since: since,
            ),
      ),
      EntitySync<FeeTransactionRow>(
        entityKey: 'fee_transactions',
        route: '/fee-transactions',
        pendingPush: feeTx.pendingPush,
        markClean: feeTx.markClean,
        maxUpdatedAt: feeTx.maxUpdatedAt,
        toRemoteJson: (row) => feeTransactionToRemoteJson(row.toDomain()),
        applyRemote: (json) =>
            feeTx.upsertFromRemote(feeTransactionCompanionFromRemoteJson(json)),
        pushRemote: (payload) =>
            FeeTransactionRemoteRepository.instance.push(payload),
        pullRemote: ({required deviceId, since}) =>
            FeeTransactionRemoteRepository.instance.pull(
              deviceId: deviceId,
              since: since,
            ),
      ),
    ],
  );
}
