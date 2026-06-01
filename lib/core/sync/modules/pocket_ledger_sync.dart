import 'dart:developer' as developer;

import '../../database/app_database.dart';
import '../../database/daos/pocket_ledger/charges_dao.dart';
import '../../database/daos/pocket_ledger/fee_transactions_dao.dart';
import '../../database/daos/pocket_ledger/ledger_entries_dao.dart';
import '../../database/daos/pocket_ledger/movement_categories_dao.dart';
import '../../database/daos/pocket_ledger/parties_dao.dart';
import '../../database/daos/pocket_ledger/transaction_types_dao.dart';
import '../../../pocket_ledger/features/charges/data/mappers/charge_mapper.dart';
import '../../../pocket_ledger/features/parties/data/mappers/party_mapper.dart';
import '../../../pocket_ledger/features/transactions/data/mappers/fee_transaction_mapper.dart';
import '../../../pocket_ledger/features/transactions/data/mappers/ledger_entry_mapper.dart';
import '../../../pocket_ledger/features/transactions/data/mappers/movement_category_mapper.dart';
import '../../../pocket_ledger/features/transactions/data/mappers/transaction_type_mapper.dart';
import '../remote/charge_remote_repository.dart';
import '../remote/fee_transaction_remote_repository.dart';
import '../remote/ledger_entry_remote_repository.dart';
import '../remote/movement_category_remote_repository.dart';
import '../remote/party_remote_repository.dart';
import '../remote/transaction_type_remote_repository.dart';
import '../retry_policy.dart';
import '../sync_result.dart';

/// Push+pull driver for every pocket_ledger entity.
///
/// Strategy:
/// * **Push** — collect dirty rows from each DAO, batch-POST as a single
///   `/<entity>/push` request, on success call `markClean(syncIds)`.
/// * **Pull** — call `/<entity>/pull?since=<lastPulledAtMs>` then apply each
///   record via `upsertFromRemote` (LWW). The orchestrator advances the
///   per-module cursor afterwards.
///
/// All network calls go through [RetryPolicy] for exponential-backoff resilience.
class PocketLedgerSync {
  PocketLedgerSync(this._db, {RetryPolicy? retryPolicy})
    : _retry = retryPolicy ?? const RetryPolicy(),
      _charges = ChargesDao(_db),
      _parties = PartiesDao(_db),
      _txTypes = TransactionTypesDao(_db),
      _movementCats = MovementCategoriesDao(_db),
      _ledgerEntries = LedgerEntriesDao(_db),
      _feeTx = FeeTransactionsDao(_db);

  static const String moduleKey = 'pocket_ledger';

  final AppDatabase _db;
  final RetryPolicy _retry;
  final ChargesDao _charges;
  final PartiesDao _parties;
  final TransactionTypesDao _txTypes;
  final MovementCategoriesDao _movementCats;
  final LedgerEntriesDao _ledgerEntries;
  final FeeTransactionsDao _feeTx;

  // ── Push ───────────────────────────────────────────────────────────────────

  /// Pushes every dirty pocket_ledger row to the backend. Returns the total
  /// number of rows acknowledged by the server across all entities.
  Future<int> push() async {
    final pushed = await Future.wait([
      _pushCharges(),
      _pushParties(),
      _pushTransactionTypes(),
      _pushMovementCategories(),
      _pushLedgerEntries(),
      _pushFeeTransactions(),
    ]);
    return pushed.fold<int>(0, (a, b) => a + b);
  }

  Future<int> _pushCharges() async {
    final dirty = await _charges.pendingPush();
    if (dirty.isEmpty) return 0;
    final payload = dirty
        .map((r) => chargeToRemoteJson(r.toDomain()))
        .toList(growable: false);
    final ok = await _retry.run(
      () => ChargeRemoteRepository.instance.push(payload),
    );
    if (!ok) return 0;
    await _charges.markClean(dirty.map((r) => r.syncId));
    return dirty.length;
  }

  Future<int> _pushParties() async {
    final dirty = await _parties.pendingPush();
    if (dirty.isEmpty) return 0;
    final payload = dirty
        .map((r) => partyToRemoteJson(r.toDomain()))
        .toList(growable: false);
    final ok = await _retry.run(
      () => PartyRemoteRepository.instance.push(payload),
    );
    if (!ok) return 0;
    await _parties.markClean(dirty.map((r) => r.syncId));
    return dirty.length;
  }

  Future<int> _pushTransactionTypes() async {
    final dirty = await _txTypes.pendingPush();
    if (dirty.isEmpty) return 0;
    final payload = dirty
        .map((r) => transactionTypeToRemoteJson(r.toDomain()))
        .toList(growable: false);
    final ok = await _retry.run(
      () => TransactionTypeRemoteRepository.instance.push(payload),
    );
    if (!ok) return 0;
    await _txTypes.markClean(dirty.map((r) => r.syncId));
    return dirty.length;
  }

  Future<int> _pushMovementCategories() async {
    final dirty = await _movementCats.pendingPush();
    if (dirty.isEmpty) return 0;
    final payload = dirty
        .map((r) => movementCategoryToRemoteJson(r.toDomain()))
        .toList(growable: false);
    final ok = await _retry.run(
      () => MovementCategoryRemoteRepository.instance.push(payload),
    );
    if (!ok) return 0;
    await _movementCats.markClean(dirty.map((r) => r.syncId));
    return dirty.length;
  }

  Future<int> _pushLedgerEntries() async {
    final dirty = await _ledgerEntries.pendingPush();
    if (dirty.isEmpty) return 0;
    final payload = dirty
        .map((r) => ledgerEntryToRemoteJson(r.toDomain()))
        .toList(growable: false);
    final ok = await _retry.run(
      () => LedgerEntryRemoteRepository.instance.push(payload),
    );
    if (!ok) return 0;
    await _ledgerEntries.markClean(dirty.map((r) => r.syncId));
    return dirty.length;
  }

  Future<int> _pushFeeTransactions() async {
    final dirty = await _feeTx.pendingPush();
    if (dirty.isEmpty) return 0;
    final payload = dirty
        .map((r) => feeTransactionToRemoteJson(r.toDomain()))
        .toList(growable: false);
    final ok = await _retry.run(
      () => FeeTransactionRemoteRepository.instance.push(payload),
    );
    if (!ok) return 0;
    await _feeTx.markClean(dirty.map((r) => r.syncId));
    return dirty.length;
  }

  // ── Pull ───────────────────────────────────────────────────────────────────

  /// Pulls server changes since [sinceMs] for every pocket_ledger entity.
  /// Returns `(pulledCount, conflictsResolved)`.
  Future<({int pulled, int conflicts})> pull({
    required String deviceId,
    required int sinceMs,
  }) async {
    final since = sinceMs == 0 ? null : sinceMs;
    final results = await Future.wait([
      _pullCharges(deviceId: deviceId, since: since),
      _pullParties(deviceId: deviceId, since: since),
      _pullTransactionTypes(deviceId: deviceId, since: since),
      _pullMovementCategories(deviceId: deviceId, since: since),
      _pullLedgerEntries(deviceId: deviceId, since: since),
      _pullFeeTransactions(deviceId: deviceId, since: since),
    ]);
    var pulled = 0;
    var conflicts = 0;
    for (final r in results) {
      pulled += r.$1;
      conflicts += r.$2;
    }
    return (pulled: pulled, conflicts: conflicts);
  }

  Future<(int, int)> _pullCharges({
    required String deviceId,
    int? since,
  }) async {
    final records = await _retry.run(
      () => ChargeRemoteRepository.instance.pull(
        deviceId: deviceId,
        since: since,
      ),
    );
    var conflicts = 0;
    for (final json in records) {
      final companion = chargeCompanionFromRemoteJson(json);
      final applied = await _charges.upsertFromRemote(companion);
      if (!applied) conflicts++;
    }
    return (records.length, conflicts);
  }

  Future<(int, int)> _pullParties({
    required String deviceId,
    int? since,
  }) async {
    final records = await _retry.run(
      () =>
          PartyRemoteRepository.instance.pull(deviceId: deviceId, since: since),
    );
    var conflicts = 0;
    for (final json in records) {
      final companion = partyCompanionFromRemoteJson(json);
      final applied = await _parties.upsertFromRemote(companion);
      if (!applied) conflicts++;
    }
    return (records.length, conflicts);
  }

  Future<(int, int)> _pullTransactionTypes({
    required String deviceId,
    int? since,
  }) async {
    final records = await _retry.run(
      () => TransactionTypeRemoteRepository.instance.pull(
        deviceId: deviceId,
        since: since,
      ),
    );
    var conflicts = 0;
    for (final json in records) {
      final companion = transactionTypeCompanionFromRemoteJson(json);
      final applied = await _txTypes.upsertFromRemote(companion);
      if (!applied) conflicts++;
    }
    return (records.length, conflicts);
  }

  Future<(int, int)> _pullMovementCategories({
    required String deviceId,
    int? since,
  }) async {
    final records = await _retry.run(
      () => MovementCategoryRemoteRepository.instance.pull(
        deviceId: deviceId,
        since: since,
      ),
    );
    var conflicts = 0;
    for (final json in records) {
      final companion = movementCategoryCompanionFromRemoteJson(json);
      final applied = await _movementCats.upsertFromRemote(companion);
      if (!applied) conflicts++;
    }
    return (records.length, conflicts);
  }

  Future<(int, int)> _pullLedgerEntries({
    required String deviceId,
    int? since,
  }) async {
    final records = await _retry.run(
      () => LedgerEntryRemoteRepository.instance.pull(
        deviceId: deviceId,
        since: since,
      ),
    );
    var conflicts = 0;
    for (final json in records) {
      final companion = ledgerEntryCompanionFromRemoteJson(json);
      final applied = await _ledgerEntries.upsertFromRemote(companion);
      if (!applied) conflicts++;
    }
    return (records.length, conflicts);
  }

  Future<(int, int)> _pullFeeTransactions({
    required String deviceId,
    int? since,
  }) async {
    final records = await _retry.run(
      () => FeeTransactionRemoteRepository.instance.pull(
        deviceId: deviceId,
        since: since,
      ),
    );
    var conflicts = 0;
    for (final json in records) {
      final companion = feeTransactionCompanionFromRemoteJson(json);
      final applied = await _feeTx.upsertFromRemote(companion);
      if (!applied) conflicts++;
    }
    return (records.length, conflicts);
  }

  // ── High-water mark ────────────────────────────────────────────────────────

  /// Highest `updated_at_ms` across all pocket_ledger entities — the
  /// orchestrator stores this as the new pull cursor on success.
  Future<int> maxUpdatedAt() async {
    final maxes = await Future.wait([
      _charges.maxUpdatedAt(),
      _parties.maxUpdatedAt(),
      _txTypes.maxUpdatedAt(),
      _movementCats.maxUpdatedAt(),
      _ledgerEntries.maxUpdatedAt(),
      _feeTx.maxUpdatedAt(),
    ]);
    return maxes.fold<int>(0, (a, b) => a > b ? a : b);
  }

  /// Returns the count of locally-dirty rows across every entity — useful
  /// for surfacing "N pending changes" badges in the UI.
  Future<int> pendingCount() async {
    final lists = await Future.wait([
      _charges.pendingPush(),
      _parties.pendingPush(),
      _txTypes.pendingPush(),
      _movementCats.pendingPush(),
      _ledgerEntries.pendingPush(),
      _feeTx.pendingPush(),
    ]);
    return lists.fold<int>(0, (a, b) => a + b.length);
  }

  void _log(String message) {
    developer.log(message, name: 'sync.pocket_ledger');
  }

  /// Best-effort logger used by the orchestrator for telemetry. Kept here
  /// so the orchestrator doesn't import `dart:developer` directly.
  void logResult(SyncResult result) {
    _log(
      'pulled=${result.pulledCount} pushed=${result.pushedCount} '
      'conflicts=${result.conflictsResolved} '
      'error=${result.error}',
    );
  }
}
