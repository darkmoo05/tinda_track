import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../database/app_database.dart';
import 'sync_config.dart';

class SyncRunResult {
  const SyncRunResult({required this.pushed, required this.pulled});

  final int pushed;
  final int pulled;
}

class SyncService {
  SyncService._();

  static final SyncService instance = SyncService._();

  final AppDatabase _database = AppDatabase.instance;
  final StreamController<SyncRunResult> _syncResultsController =
      StreamController<SyncRunResult>.broadcast();
  static const Duration _requestTimeout = Duration(seconds: 12);
  static const List<String> _reachabilityProbePaths = [
    '/health',
    '/inventory/categories/pull?since=0',
    '/parties/pull?since=0',
  ];

  bool _isSyncing = false;

  Stream<SyncRunResult> get syncResults => _syncResultsController.stream;

  Future<SyncRunResult> syncAll() async {
    // Guard against concurrent calls (e.g. startup fire-and-forget overlapping
    // with the 60-second periodic timer).
    if (_isSyncing) return const SyncRunResult(pushed: 0, pulled: 0);
    _isSyncing = true;
    try {
      final result = await _doSyncAll();
      _syncResultsController.add(result);
      return result;
    } finally {
      _isSyncing = false;
    }
  }

  Future<SyncRunResult> _doSyncAll() async {
    final db = await _database.database;
    await _database.ensureSyncSchema(db);

    // Fast reachability check — probe current URL first, then hostname/IP
    // fallbacks, and persist the first reachable candidate.
    final currentBaseUrl = await SyncConfig.getBaseApiUrl();
    final probeCandidates = SyncConfig.buildProbeCandidates(currentBaseUrl);
    String? activeBaseUrl;
    for (final candidate in probeCandidates) {
      if (await _isServerReachable(candidate)) {
        activeBaseUrl = candidate;
        break;
      }
    }

    if (activeBaseUrl == null) {
      final diagnosis = await _diagnoseHealthProbeFailure(currentBaseUrl);
      if (diagnosis != null) {
        log('[Sync] $diagnosis', name: 'SyncService');
      } else {
        log('[Sync] Server unreachable, skipping sync', name: 'SyncService');
      }

      // Do not hard-stop here. Some environments (especially mobile tunnels)
      // can fail probe endpoints while real sync endpoints still work.
      activeBaseUrl = currentBaseUrl;
      log(
        '[Sync] Proceeding with sync attempt despite probe failure: $activeBaseUrl',
        name: 'SyncService',
      );
    }

    if (activeBaseUrl != currentBaseUrl) {
      await SyncConfig.setBaseApiUrl(activeBaseUrl);
      log(
        '[Sync] Switched API URL to reachable endpoint: $activeBaseUrl',
        name: 'SyncService',
      );
    }

    final deviceId = await _database.getOrCreateDeviceId();
    // Use a per-scope timestamp for PocketLedger so a failed PL sync never
    // advances the cursor and causes permanently missed records on the next run.
    // Falls back to the legacy 'last_sync_ms' key for existing installs.
    final plSinceRaw =
        await _database.getSyncState('pl_last_sync_ms') ??
        await _database.getSyncState('last_sync_ms');
    final plSinceMs = int.tryParse(plSinceRaw ?? '') ?? 0;
    final hasLocalData = await _hasAnyLocalData(db);
    final effectiveSinceMs = (hasLocalData && plSinceMs > 0) ? plSinceMs : 0;
    final pullDeviceId = hasLocalData ? deviceId : null;

    var pushed = 0;
    var pulled = 0;
    var plSyncOk = false;

    // PocketLedger sync — isolated so a server error here never prevents
    // TindaTracker data from syncing.
    try {
      pushed += await _syncParties(
        db,
        deviceId,
        effectiveSinceMs,
        isPush: true,
        pullDeviceId: pullDeviceId,
      );
      pulled += await _syncParties(
        db,
        deviceId,
        effectiveSinceMs,
        isPush: false,
        pullDeviceId: pullDeviceId,
      );

      pushed += await _syncEntries(
        db,
        deviceId,
        effectiveSinceMs,
        isPush: true,
        pullDeviceId: pullDeviceId,
      );
      pulled += await _syncEntries(
        db,
        deviceId,
        effectiveSinceMs,
        isPush: false,
        pullDeviceId: pullDeviceId,
      );

      pushed += await _syncCharges(
        db,
        deviceId,
        effectiveSinceMs,
        isPush: true,
        pullDeviceId: pullDeviceId,
      );
      pulled += await _syncCharges(
        db,
        deviceId,
        effectiveSinceMs,
        isPush: false,
        pullDeviceId: pullDeviceId,
      );

      pushed += await _syncTransactionTypes(
        db,
        deviceId,
        effectiveSinceMs,
        isPush: true,
        pullDeviceId: pullDeviceId,
      );
      pulled += await _syncTransactionTypes(
        db,
        deviceId,
        effectiveSinceMs,
        isPush: false,
        pullDeviceId: pullDeviceId,
      );

      pushed += await _syncMovementCategories(
        db,
        deviceId,
        effectiveSinceMs,
        isPush: true,
        pullDeviceId: pullDeviceId,
      );
      pulled += await _syncMovementCategories(
        db,
        deviceId,
        effectiveSinceMs,
        isPush: false,
        pullDeviceId: pullDeviceId,
      );

      pushed += await _syncFeeTransactions(
        db,
        deviceId,
        effectiveSinceMs,
        isPush: true,
        pullDeviceId: pullDeviceId,
      );
      pulled += await _syncFeeTransactions(
        db,
        deviceId,
        effectiveSinceMs,
        isPush: false,
        pullDeviceId: pullDeviceId,
      );
      plSyncOk = true;
    } catch (e) {
      log(
        '[Sync] PocketLedger sync error (TindaTracker sync will still run): $e',
        name: 'SyncService',
      );
    }

    // Save PL timestamp only when every entity synced successfully.
    // If any entity threw, the cursor stays at its previous value so the
    // next run retries a full pull instead of skipping unsynced records.
    if (plSyncOk) {
      await _database.setSyncState(
        'pl_last_sync_ms',
        DateTime.now().millisecondsSinceEpoch.toString(),
      );
    }

    // TindaTracker local-cache sync
    // Sync lookup tables first so the server has FK targets before products
    pushed += await _syncTtProductCategories(db, deviceId, isPush: true);
    pulled += await _syncTtProductCategories(db, deviceId, isPush: false);
    pushed += await _syncTtShelfLocations(db, deviceId, isPush: true);
    // Image upload MUST run between the row push and the row pull. The pull
    // path overwrites local `image_url` from the server's `updatedAt` feed,
    // and the upload filter requires `image_url IS NULL` to detect pending
    // photos. Running it after the pull would re-stamp the row with the old
    // remote URL and the new picture would never reach the server.
    pushed += await _pushShelfLocationImages(db);
    pulled += await _syncTtShelfLocations(db, deviceId, isPush: false);
    // Shelf-location records now have server_ids — flush any pending
    // offline-captured photos before products start referencing them.
    pushed += await _syncTtProducts(db, deviceId, isPush: true);
    pulled += await _syncTtProducts(db, deviceId, isPush: false);
    pushed += await _syncTtCustomers(db, deviceId, isPush: true);
    pulled += await _syncTtCustomers(db, deviceId, isPush: false);
    pushed += await _syncTtSales(db, deviceId, isPush: true);
    pulled += await _syncTtSales(db, deviceId, isPush: false);

    // TindaTracker keeps its own timestamp (separate scope from PocketLedger).
    await _database.setSyncState(
      'tt_last_sync_ms',
      DateTime.now().millisecondsSinceEpoch.toString(),
    );

    return SyncRunResult(pushed: pushed, pulled: pulled);
  }

  Future<int> _syncParties(
    Database db,
    String deviceId,
    int sinceMs, {
    required bool isPush,
    String? pullDeviceId,
  }) async {
    if (isPush) {
      final rows = await db.query(
        AppDatabase.partiesTable,
        where: '${AppDatabase.isDirtyColumn} = 1',
      );
      if (rows.isEmpty) return 0;
      final payload = rows
          .map((row) {
            return {
              'syncId': row[AppDatabase.syncIdColumn],
              'deviceId': row[AppDatabase.deviceIdColumn],
              'name': row['name'],
              'accountNumber': row['account_number'],
              'entityId': row['entity_id'],
              'description': row['description'],
              'joinDate': row['join_date'],
              'isVerified': _toBool(row['is_verified']),
              'isDeleted': _toBool(row[AppDatabase.isDeletedColumn]),
            };
          })
          .toList(growable: false);

      await _post('/parties/push', payload);
      await _markRowsClean(db, AppDatabase.partiesTable, rows);
      return rows.length;
    }

    final data = await _pull('/parties/pull', sinceMs, pullDeviceId);
    if (data.isEmpty) return 0;

    for (final item in data) {
      final syncId = _asString(item['syncId']);
      if (syncId.isEmpty) continue;
      final remoteUpdated = _remoteUpdatedMs(item);
      final local = await _findBySyncId(db, AppDatabase.partiesTable, syncId);
      if (_shouldKeepLocal(local, remoteUpdated)) {
        continue;
      }
      final values = {
        'name': _asString(item['name']),
        'account_number': _asString(item['accountNumber']),
        'entity_id': _asString(item['entityId']),
        'description': _asString(item['description']),
        'join_date': _asString(item['joinDate']),
        'is_verified': _toBool(item['isVerified']) ? 1 : 0,
        AppDatabase.syncIdColumn: syncId,
        AppDatabase.deviceIdColumn: _asString(item['deviceId']),
        AppDatabase.updatedAtMsColumn: remoteUpdated,
        AppDatabase.isDeletedColumn: _toBool(item['isDeleted']) ? 1 : 0,
        AppDatabase.isDirtyColumn: 0,
      };
      await _upsertBySyncId(db, AppDatabase.partiesTable, local, values);
    }
    return data.length;
  }

  Future<int> _syncEntries(
    Database db,
    String deviceId,
    int sinceMs, {
    required bool isPush,
    String? pullDeviceId,
  }) async {
    if (isPush) {
      final rows = await db.query(
        AppDatabase.ledgerTable,
        where: '${AppDatabase.isDirtyColumn} = 1',
      );
      if (rows.isEmpty) return 0;
      final payload = rows
          .map((row) {
            return {
              'syncId': row[AppDatabase.syncIdColumn],
              'deviceId': row[AppDatabase.deviceIdColumn],
              'entryType': row['entry_type'],
              'title': row['title'],
              'note': row['note'],
              'reference': row['reference'],
              'amount': _asDouble(row['amount']),
              'walletDelta': _asDouble(row['wallet_delta']),
              'mayaWalletDelta': _asDouble(row['maya_wallet_delta']),
              'onHandDelta': _asDouble(row['on_hand_delta']),
              'recordedFlow': _asDouble(row['recorded_flow']),
              'tag': row['tag'],
              'iconKey': row['icon_key'],
              'walletAccount': row['wallet_account'],
              'ownerScope': row['owner_scope'],
              'ownerMovementType': row['owner_movement_type'],
              'ownerCategory': row['owner_category'],
              'ownerPartyName': row['owner_party_name'],
              'ownerPartyAccount': row['owner_party_account'],
              'entryDate': row['created_at'],
              'isDeleted': _toBool(row[AppDatabase.isDeletedColumn]),
            };
          })
          .toList(growable: false);

      await _post('/entries/push', payload);
      await _markRowsClean(db, AppDatabase.ledgerTable, rows);
      return rows.length;
    }

    final data = await _pull('/entries/pull', sinceMs, pullDeviceId);
    if (data.isEmpty) return 0;

    for (final item in data) {
      final syncId = _asString(item['syncId']);
      if (syncId.isEmpty) continue;
      final remoteUpdated = _remoteUpdatedMs(item);
      final local = await _findBySyncId(db, AppDatabase.ledgerTable, syncId);
      if (_shouldKeepLocal(local, remoteUpdated)) {
        continue;
      }
      final values = {
        'entry_type': _asString(item['entryType']),
        'title': _asString(item['title']),
        'note': _asString(item['note']),
        'reference': _asString(item['reference']),
        'amount': _asDouble(item['amount']),
        'wallet_delta': _asDouble(item['walletDelta']),
        'maya_wallet_delta': _asDouble(item['mayaWalletDelta']),
        'on_hand_delta': _asDouble(item['onHandDelta']),
        'recorded_flow': _asDouble(item['recordedFlow']),
        'tag': _asString(item['tag']),
        'icon_key': _asString(item['iconKey']),
        'wallet_account': _asString(item['walletAccount']),
        'owner_scope': _asString(item['ownerScope'], fallback: 'Business'),
        'owner_movement_type': item['ownerMovementType'],
        'owner_category': item['ownerCategory'],
        'owner_party_name': item['ownerPartyName'],
        'owner_party_account': item['ownerPartyAccount'],
        'created_at': _asString(
          item['entryDate'],
          fallback: _asString(item['createdAt']),
        ),
        AppDatabase.syncIdColumn: syncId,
        AppDatabase.deviceIdColumn: _asString(item['deviceId']),
        AppDatabase.updatedAtMsColumn: remoteUpdated,
        AppDatabase.isDeletedColumn: _toBool(item['isDeleted']) ? 1 : 0,
        AppDatabase.isDirtyColumn: 0,
      };
      await _upsertBySyncId(db, AppDatabase.ledgerTable, local, values);
    }
    return data.length;
  }

  Future<int> _syncCharges(
    Database db,
    String deviceId,
    int sinceMs, {
    required bool isPush,
    String? pullDeviceId,
  }) async {
    if (isPush) {
      final rows = await db.query(
        AppDatabase.chargesTable,
        where: '${AppDatabase.isDirtyColumn} = 1',
      );
      if (rows.isEmpty) return 0;
      final payload = rows
          .map((row) {
            return {
              'syncId': row[AppDatabase.syncIdColumn],
              'deviceId': row[AppDatabase.deviceIdColumn],
              'lowerBound': row['lower_bound'],
              'upperBound': row['upper_bound'],
              'chargeAmount': _asDouble(row['charge_amount']),
              'transactionTypeKey':
                  row[AppDatabase.transactionTypeKeyColumn] ?? 'gcash_cashin',
              'isDeleted': _toBool(row[AppDatabase.isDeletedColumn]),
            };
          })
          .toList(growable: false);

      await _post('/charges/push', payload);
      await _markRowsClean(db, AppDatabase.chargesTable, rows);
      return rows.length;
    }

    final data = await _pull('/charges/pull', sinceMs, pullDeviceId);
    if (data.isEmpty) return 0;

    for (final item in data) {
      final syncId = _asString(item['syncId']);
      if (syncId.isEmpty) continue;
      final remoteUpdated = _remoteUpdatedMs(item);
      final local = await _findBySyncId(db, AppDatabase.chargesTable, syncId);
      if (_shouldKeepLocal(local, remoteUpdated)) {
        continue;
      }
      final values = {
        'lower_bound': _asInt(item['lowerBound']),
        'upper_bound': _asInt(item['upperBound']),
        'charge_amount': _asDouble(item['chargeAmount']),
        AppDatabase.transactionTypeKeyColumn: _asString(
          item['transactionTypeKey'],
          fallback: 'gcash_cashin',
        ),
        AppDatabase.syncIdColumn: syncId,
        AppDatabase.deviceIdColumn: _asString(item['deviceId']),
        AppDatabase.updatedAtMsColumn: remoteUpdated,
        AppDatabase.isDeletedColumn: _toBool(item['isDeleted']) ? 1 : 0,
        AppDatabase.isDirtyColumn: 0,
      };
      await _upsertBySyncId(db, AppDatabase.chargesTable, local, values);
    }
    return data.length;
  }

  Future<int> _syncTransactionTypes(
    Database db,
    String deviceId,
    int sinceMs, {
    required bool isPush,
    String? pullDeviceId,
  }) async {
    if (isPush) {
      final rows = await db.query(
        AppDatabase.transactionTypesTable,
        where: '${AppDatabase.isDirtyColumn} = 1',
      );
      if (rows.isEmpty) return 0;
      final payload = rows
          .map((row) {
            return {
              'syncId': row[AppDatabase.syncIdColumn],
              'deviceId': row[AppDatabase.deviceIdColumn],
              'name': row['name'],
              'isOutflow': _toBool(row['is_outflow']),
              'walletAccount': row['wallet_account'],
              'isDeleted': _toBool(row[AppDatabase.isDeletedColumn]),
            };
          })
          .toList(growable: false);

      await _post('/transaction-types/push', payload);
      await _markRowsClean(db, AppDatabase.transactionTypesTable, rows);
      return rows.length;
    }

    final data = await _pull('/transaction-types/pull', sinceMs, pullDeviceId);
    if (data.isEmpty) return 0;

    for (final item in data) {
      final syncId = _asString(item['syncId']);
      if (syncId.isEmpty) continue;
      final remoteUpdated = _remoteUpdatedMs(item);
      final local = await _findBySyncId(
        db,
        AppDatabase.transactionTypesTable,
        syncId,
      );
      if (_shouldKeepLocal(local, remoteUpdated)) {
        continue;
      }
      final values = {
        'name': _asString(item['name']),
        'is_outflow': _toBool(item['isOutflow']) ? 1 : 0,
        'wallet_account': _asString(item['walletAccount'], fallback: 'GCash'),
        'created_at': _asString(
          item['createdAt'],
          fallback: DateTime.now().toIso8601String(),
        ),
        AppDatabase.syncIdColumn: syncId,
        AppDatabase.deviceIdColumn: _asString(item['deviceId']),
        AppDatabase.updatedAtMsColumn: remoteUpdated,
        AppDatabase.isDeletedColumn: _toBool(item['isDeleted']) ? 1 : 0,
        AppDatabase.isDirtyColumn: 0,
      };
      await _upsertBySyncId(
        db,
        AppDatabase.transactionTypesTable,
        local,
        values,
      );
    }
    return data.length;
  }

  Future<int> _syncMovementCategories(
    Database db,
    String deviceId,
    int sinceMs, {
    required bool isPush,
    String? pullDeviceId,
  }) async {
    if (isPush) {
      final rows = await db.query(
        AppDatabase.ownerMovementCategoriesTable,
        where: '${AppDatabase.isDirtyColumn} = 1',
      );
      if (rows.isEmpty) return 0;
      final payload = rows
          .map((row) {
            return {
              'syncId': row[AppDatabase.syncIdColumn],
              'deviceId': row[AppDatabase.deviceIdColumn],
              'name': row['name'],
              'isDeleted': _toBool(row[AppDatabase.isDeletedColumn]),
            };
          })
          .toList(growable: false);

      await _post('/movement-categories/push', payload);
      await _markRowsClean(db, AppDatabase.ownerMovementCategoriesTable, rows);
      return rows.length;
    }

    final data = await _pull(
      '/movement-categories/pull',
      sinceMs,
      pullDeviceId,
    );
    if (data.isEmpty) return 0;

    for (final item in data) {
      final syncId = _asString(item['syncId']);
      if (syncId.isEmpty) continue;
      final remoteUpdated = _remoteUpdatedMs(item);
      final local = await _findBySyncId(
        db,
        AppDatabase.ownerMovementCategoriesTable,
        syncId,
      );
      if (_shouldKeepLocal(local, remoteUpdated)) {
        continue;
      }
      final values = {
        'name': _asString(item['name']),
        'created_at': _asString(
          item['createdAt'],
          fallback: DateTime.now().toIso8601String(),
        ),
        AppDatabase.syncIdColumn: syncId,
        AppDatabase.deviceIdColumn: _asString(item['deviceId']),
        AppDatabase.updatedAtMsColumn: remoteUpdated,
        AppDatabase.isDeletedColumn: _toBool(item['isDeleted']) ? 1 : 0,
        AppDatabase.isDirtyColumn: 0,
      };
      await _upsertBySyncId(
        db,
        AppDatabase.ownerMovementCategoriesTable,
        local,
        values,
      );
    }
    return data.length;
  }

  Future<int> _syncFeeTransactions(
    Database db,
    String deviceId,
    int sinceMs, {
    required bool isPush,
    String? pullDeviceId,
  }) async {
    if (isPush) {
      final rows = await db.query(
        AppDatabase.feeTransactionsTable,
        where: '${AppDatabase.isDirtyColumn} = 1',
      );
      if (rows.isEmpty) return 0;

      // Resolve the related ledger entry's syncId from its local integer id.
      final payload = await Future.wait(
        rows.map((row) async {
          String? relatedSyncId;
          final relatedId = row['related_transaction_id'];
          if (relatedId != null) {
            final parentRows = await db.query(
              AppDatabase.ledgerTable,
              columns: [AppDatabase.syncIdColumn],
              where: 'id = ?',
              whereArgs: [relatedId],
              limit: 1,
            );
            if (parentRows.isNotEmpty) {
              relatedSyncId =
                  parentRows.first[AppDatabase.syncIdColumn] as String?;
            }
          }
          return <String, Object?>{
            'syncId': row[AppDatabase.syncIdColumn],
            'deviceId': row[AppDatabase.deviceIdColumn],
            'relatedTransactionSyncId': relatedSyncId,
            'feeAmount': _asDouble(row['fee_amount']),
            'feeType': row['fee_type'],
            'chargeDestination': row['charge_destination'],
            'isDeleted': _toBool(row[AppDatabase.isDeletedColumn]),
          };
        }),
      );

      await _post('/fee-transactions/push', payload);
      await _markRowsClean(db, AppDatabase.feeTransactionsTable, rows);
      return rows.length;
    }

    final data = await _pull('/fee-transactions/pull', sinceMs, pullDeviceId);
    if (data.isEmpty) return 0;

    for (final item in data) {
      final syncId = _asString(item['syncId']);
      if (syncId.isEmpty) continue;
      final remoteUpdated = _remoteUpdatedMs(item);
      final local = await _findBySyncId(
        db,
        AppDatabase.feeTransactionsTable,
        syncId,
      );
      if (_shouldKeepLocal(local, remoteUpdated)) {
        continue;
      }
      // Resolve the server's relatedTransactionSyncId back to a local integer id.
      int? relatedTransactionId;
      final relatedSyncId = _asString(item['relatedTransactionSyncId']);
      if (relatedSyncId.isNotEmpty) {
        final parentRows = await db.query(
          AppDatabase.ledgerTable,
          columns: ['id'],
          where: '${AppDatabase.syncIdColumn} = ?',
          whereArgs: [relatedSyncId],
          limit: 1,
        );
        if (parentRows.isNotEmpty) {
          relatedTransactionId = parentRows.first['id'] as int?;
        }
      }
      final values = {
        'related_transaction_id': relatedTransactionId,
        'fee_amount': _asDouble(item['feeAmount']),
        'fee_type': _asString(item['feeType']),
        'charge_destination': _asString(item['chargeDestination']),
        'created_at': _asString(
          item['createdAt'],
          fallback: DateTime.now().toIso8601String(),
        ),
        AppDatabase.syncIdColumn: syncId,
        AppDatabase.deviceIdColumn: _asString(item['deviceId']),
        AppDatabase.updatedAtMsColumn: remoteUpdated,
        AppDatabase.isDeletedColumn: _toBool(item['isDeleted']) ? 1 : 0,
        AppDatabase.isDirtyColumn: 0,
      };
      await _upsertBySyncId(
        db,
        AppDatabase.feeTransactionsTable,
        local,
        values,
      );
    }
    return data.length;
  }

  Future<void> _post(String path, List<Map<String, Object?>> payload) async {
    final baseUrl = await SyncConfig.getBaseApiUrl();
    final uri = Uri.parse('$baseUrl$path');
    final response = await _runRequest(
      () => http
          .post(
            uri,
            headers: const {'content-type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(_requestTimeout),
      uri,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'Push failed for $path: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<List<Map<String, dynamic>>> _pull(
    String path,
    int sinceMs,
    String? deviceId,
  ) async {
    final baseUrl = await SyncConfig.getBaseApiUrl();
    final queryParameters = <String, String>{'since': sinceMs.toString()};
    final normalizedDeviceId = deviceId?.trim() ?? '';
    if (normalizedDeviceId.isNotEmpty) {
      queryParameters['deviceId'] = normalizedDeviceId;
    }
    final uri = Uri.parse(
      '$baseUrl$path',
    ).replace(queryParameters: queryParameters);
    final response = await _runRequest(
      () => http
          .get(uri, headers: const {'accept': 'application/json'})
          .timeout(_requestTimeout),
      uri,
    );
    _ensureJsonApiResponse(response, uri, operation: 'pull $path');

    final body = _decodeJsonMapBody(
      response.body,
      uri,
      operation: 'pull $path',
    );
    if (body.isEmpty) {
      return const [];
    }
    final data = body['data'];
    if (data is! List) {
      return const [];
    }
    return data.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  Future<http.Response> _runRequest(
    Future<http.Response> Function() request,
    Uri uri,
  ) async {
    try {
      return await request();
    } on TimeoutException {
      throw StateError(
        'Connection timed out while reaching $uri. Check whether the server is online and reachable from your device.',
      );
    } on SocketException catch (error) {
      throw StateError(
        'Unable to connect to $uri (${error.message}). If you are using Android with http://, cleartext traffic must be allowed and the server must be running.',
      );
    } on http.ClientException catch (error) {
      throw StateError(
        'HTTP client error while reaching $uri: ${error.message}',
      );
    }
  }

  Future<void> _markRowsClean(
    Database db,
    String table,
    List<Map<String, Object?>> rows,
  ) async {
    final batch = db.batch();
    for (final row in rows) {
      final syncId = row[AppDatabase.syncIdColumn] as String?;
      if (syncId == null || syncId.isEmpty) {
        continue;
      }
      batch.update(
        table,
        {AppDatabase.isDirtyColumn: 0},
        where: '${AppDatabase.syncIdColumn} = ?',
        whereArgs: [syncId],
      );
    }
    await batch.commit(noResult: true);
  }

  Future<Map<String, Object?>?> _findBySyncId(
    Database db,
    String table,
    String syncId,
  ) async {
    final rows = await db.query(
      table,
      where: '${AppDatabase.syncIdColumn} = ?',
      whereArgs: [syncId],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return rows.first;
  }

  bool _shouldKeepLocal(Map<String, Object?>? local, int remoteUpdatedMs) {
    if (local == null) {
      return false;
    }
    final localDirty = _toBool(local[AppDatabase.isDirtyColumn]);
    final localUpdated = _asInt(local[AppDatabase.updatedAtMsColumn]);
    return localDirty && localUpdated > remoteUpdatedMs;
  }

  Future<void> _upsertBySyncId(
    Database db,
    String table,
    Map<String, Object?>? local,
    Map<String, Object?> values,
  ) async {
    if (local != null) {
      final id = local['id'];
      if (id is int) {
        await db.update(table, values, where: 'id = ?', whereArgs: [id]);
        return;
      }
    }
    await db.insert(
      table,
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  int _remoteUpdatedMs(Map<String, dynamic> item) {
    final updatedAtRaw = item['updatedAt'];
    if (updatedAtRaw is String) {
      final parsed = DateTime.tryParse(updatedAtRaw);
      if (parsed != null) {
        return parsed.millisecondsSinceEpoch;
      }
    }
    return DateTime.now().millisecondsSinceEpoch;
  }

  String _asString(Object? value, {String fallback = ''}) {
    if (value == null) return fallback;
    final str = value.toString();
    return str.isEmpty ? fallback : str;
  }

  int _asInt(Object? value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  double _asDouble(Object? value, {double fallback = 0}) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  bool _toBool(Object? value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase().trim();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }

  /// Returns true if the server responds with API JSON to at least one probe
  /// endpoint within 3 seconds. Falls back to real sync routes when /health is
  /// unavailable so sync can still proceed.
  Future<bool> _isServerReachable(String baseUrl) async {
    var sawTunnelAuthGate = false;

    for (final path in _reachabilityProbePaths) {
      final uri = Uri.parse('$baseUrl$path');
      try {
        final res = await http
            .get(uri, headers: const {'accept': 'application/json'})
            .timeout(const Duration(seconds: 3));

        if (_looksLikeTunnelAuthGate(res) || _looksLikeHtml(res.body)) {
          sawTunnelAuthGate = true;
          continue;
        }

        if (res.statusCode < 200 || res.statusCode >= 300) {
          continue;
        }

        if (!_isLikelyJsonResponse(res)) {
          continue;
        }

        final body = _tryDecodeJsonMapBody(res.body);
        if (body == null) {
          continue;
        }

        if (path == '/health') {
          final status = _asString(body['status']).toLowerCase();
          if (status == 'ok') {
            return true;
          }
          continue;
        }

        // Non-health endpoints use { success, data } envelope.
        return true;
      } catch (_) {
        continue;
      }
    }

    if (sawTunnelAuthGate) {
      return false;
    }

    return false;
  }

  Future<String?> _diagnoseHealthProbeFailure(String baseUrl) async {
    SocketException? socketError;
    var sawTimeout = false;
    var sawTunnelAuthGate = false;
    final statusMessages = <String>[];

    for (final path in _reachabilityProbePaths) {
      final uri = Uri.parse('$baseUrl$path');
      try {
        final res = await http
            .get(uri, headers: const {'accept': 'application/json'})
            .timeout(const Duration(seconds: 3));

        if (_looksLikeTunnelAuthGate(res) || _looksLikeHtml(res.body)) {
          sawTunnelAuthGate = true;
          statusMessages.add('$uri => login/auth HTML');
          continue;
        }

        if (res.statusCode < 200 || res.statusCode >= 300) {
          statusMessages.add('$uri => HTTP ${res.statusCode}');
          continue;
        }

        if (!_isLikelyJsonResponse(res)) {
          statusMessages.add(
            '$uri => non-JSON (${res.headers['content-type'] ?? 'unknown'})',
          );
          continue;
        }
      } on TimeoutException {
        sawTimeout = true;
      } on SocketException catch (error) {
        socketError = error;
      } catch (_) {
        continue;
      }
    }

    if (sawTunnelAuthGate) {
      return 'Sync probe warning: Dev Tunnel is returning a login/auth page on one or more probe endpoints. '
          '${statusMessages.join('; ')}. Set forwarded port 8080 to public/anonymous for API testing.';
    }

    if (statusMessages.isNotEmpty) {
      return 'Sync probe warning: probe endpoints did not return a usable API response. '
          '${statusMessages.join('; ')}';
    }
    if (sawTimeout) {
      return 'Sync probe warning: probe request timed out for $baseUrl.';
    }
    if (socketError != null) {
      return 'Sync probe warning: cannot connect to $baseUrl (${socketError!.message}).';
    }

    return null;
  }

  Map<String, dynamic>? _tryDecodeJsonMapBody(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  bool _isLikelyJsonResponse(http.Response response) {
    final contentType = (response.headers['content-type'] ?? '')
        .toLowerCase()
        .trim();
    return contentType.contains('application/json') ||
        contentType.contains('+json');
  }

  bool _looksLikeHtml(String body) {
    final normalized = body.trimLeft().toLowerCase();
    return normalized.startsWith('<!doctype html') ||
        normalized.startsWith('<html');
  }

  bool _looksLikeTunnelAuthGate(http.Response response) {
    final requestHost = response.request?.url.host.toLowerCase() ?? '';
    final location = (response.headers['location'] ?? '').toLowerCase();
    final body = response.body.toLowerCase();
    return requestHost.contains('github.com') ||
        location.contains('github.com/login') ||
        location.contains('/auth/github/signin') ||
        body.contains('sign in to github') ||
        body.contains('continue to dev tunnels') ||
        body.contains('auth/github/signin');
  }

  String _previewBody(String body, {int maxChars = 180}) {
    final compact = body.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.isEmpty) return '';
    if (compact.length <= maxChars) return compact;
    return '${compact.substring(0, maxChars)}...';
  }

  Map<String, dynamic> _decodeJsonMapBody(
    String body,
    Uri uri, {
    required String operation,
  }) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw StateError(
      'Invalid API response for $operation at $uri: expected a JSON object envelope.',
    );
  }

  void _ensureJsonApiResponse(
    http.Response response,
    Uri uri, {
    required String operation,
  }) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (response.statusCode == 401 ||
          response.statusCode == 403 ||
          response.statusCode == 406 ||
          _looksLikeTunnelAuthGate(response)) {
        throw StateError(
          'Sync blocked by tunnel authentication while calling $operation at $uri '
          '(HTTP ${response.statusCode}). Make port 8080 public/anonymous in VS Code Dev Tunnels, '
          'or use an endpoint that does not require GitHub sign-in.',
        );
      }

      throw StateError(
        'Pull failed for $operation: HTTP ${response.statusCode}. ${_previewBody(response.body)}',
      );
    }

    if (!_isLikelyJsonResponse(response) || _looksLikeHtml(response.body)) {
      if (_looksLikeTunnelAuthGate(response)) {
        throw StateError(
          'Sync blocked by a Dev Tunnel login page while calling $operation at $uri. '
          'The response is HTML instead of JSON. Make the forwarded port public/anonymous for testing.',
        );
      }

      throw StateError(
        'Invalid response for $operation at $uri: expected JSON but got '
        '"${response.headers['content-type'] ?? 'unknown'}". ${_previewBody(response.body)}',
      );
    }
  }

  Future<bool> _hasAnyLocalData(Database db) async {
    final tables = [
      AppDatabase.partiesTable,
      AppDatabase.ledgerTable,
      AppDatabase.chargesTable,
      AppDatabase.transactionTypesTable,
      AppDatabase.ownerMovementCategoriesTable,
    ];

    for (final table in tables) {
      final rows = await db.rawQuery(
        'SELECT 1 AS has_data FROM $table WHERE ${AppDatabase.isDeletedColumn} = 0 LIMIT 1',
      );
      if (rows.isNotEmpty) {
        return true;
      }
    }

    return false;
  }

  // ─── TindaTracker sync helpers ────────────────────────────────────────────

  Future<int> _syncTtLookupTable(
    Database db, {
    required String localTable,
    required String pushEndpoint,
    required String pullEndpoint,
    required bool isPush,
    Map<String, Object?> Function(Map<String, Object?> row)? extraPushFields,
    FutureOr<Map<String, Object?>> Function(Map<String, dynamic> serverItem)?
    extraPullFields,
  }) async {
    final baseUrl = await SyncConfig.getBaseApiUrl();
    if (isPush) {
      final rows = await db.query(localTable, where: 'is_dirty = 1');
      if (rows.isEmpty) return 0;
      final payload = rows.map((r) {
        final base = <String, Object?>{
          'syncId': r['sync_id'],
          'name': r['name'],
          'isDeleted': (r['is_deleted'] as int) == 1,
        };
        if (extraPushFields != null) base.addAll(extraPushFields(r));
        return base;
      }).toList();
      try {
        final res = await http
            .post(
              Uri.parse('$baseUrl/$pushEndpoint'),
              headers: const {'Content-Type': 'application/json'},
              body: jsonEncode(payload),
            )
            .timeout(_requestTimeout);
        if (res.statusCode >= 200 && res.statusCode < 300) {
          _ensureJsonApiResponse(
            res,
            Uri.parse('$baseUrl/$pushEndpoint'),
            operation: 'push $pushEndpoint',
          );
          final body = _decodeJsonMapBody(
            res.body,
            Uri.parse('$baseUrl/$pushEndpoint'),
            operation: 'push $pushEndpoint',
          );
          final rawData = body is Map ? body['data'] : null;
          final serverItems =
              (rawData as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
          for (final item in serverItems) {
            await db.update(
              localTable,
              {'server_id': item['id'], 'is_dirty': 0},
              where: 'sync_id = ?',
              whereArgs: [item['syncId']],
            );
          }
          // If server returned no items (e.g. older API), still mark rows clean
          if (serverItems.isEmpty) {
            for (final row in rows) {
              await db.update(
                localTable,
                {'is_dirty': 0},
                where: 'sync_id = ?',
                whereArgs: [row['sync_id']],
              );
            }
          }
        } else if (res.statusCode == 400) {
          // Surface the server's structured error (e.g. quick-access cap).
          log(
            '[Sync] $pushEndpoint rejected (400): ${res.body}',
            name: 'SyncService',
          );
        }
      } catch (e) {
        log('[Sync] $pushEndpoint push error: $e', name: 'SyncService');
      }
      return rows.length;
    }

    // pull
    try {
      final sinceRaw = await _database.getSyncState('tt_last_sync_ms');
      final sinceMs = sinceRaw != null ? int.tryParse(sinceRaw) ?? 0 : 0;
      final pullUri = Uri.parse('$baseUrl/$pullEndpoint?since=$sinceMs');
      final res = await _runRequest(
        () => http
            .get(pullUri, headers: const {'accept': 'application/json'})
            .timeout(_requestTimeout),
        pullUri,
      );
      _ensureJsonApiResponse(res, pullUri, operation: 'pull $pullEndpoint');
      final body = _decodeJsonMapBody(
        res.body,
        pullUri,
        operation: 'pull $pullEndpoint',
      );
      final list = (body['data'] as List<dynamic>).cast<Map<String, dynamic>>();
      var count = 0;
      for (final item in list) {
        final syncId = item['syncId'] as String?;
        final serverId = item['id'] as String;
        final now = DateTime.now().toIso8601String();
        final values = <String, Object?>{
          'sync_id': syncId ?? serverId,
          'server_id': serverId,
          'name': item['name'] as String? ?? '',
          'is_deleted': (item['isDeleted'] as bool? ?? false) ? 1 : 0,
          'is_dirty': 0,
          'created_at': item['createdAt'] ?? now,
          'updated_at': item['updatedAt'] ?? now,
        };
        if (extraPullFields != null) {
          values.addAll(await extraPullFields(item));
        }
        final existing = await db.query(
          localTable,
          where: 'sync_id = ? OR server_id = ?',
          whereArgs: [values['sync_id'], serverId],
          limit: 1,
        );
        if (existing.isEmpty) {
          await db.insert(
            localTable,
            values,
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        } else if ((existing.first['is_dirty'] as int) == 0) {
          await db.update(
            localTable,
            values,
            where: 'id = ?',
            whereArgs: [existing.first['id']],
          );
        }
        count++;
      }
      return count;
    } catch (e) {
      log('[Sync] $pullEndpoint pull error: $e', name: 'SyncService');
      return 0;
    }
  }

  Future<int> _syncTtProductCategories(
    Database db,
    String deviceId, {
    required bool isPush,
  }) async {
    if (isPush) {
      await _normalizeQuickAccessCategoryPins(db, maxPinned: 10);
    }

    return _syncTtLookupTable(
      db,
      localTable: AppDatabase.ttProductCategoriesTable,
      pushEndpoint: 'inventory/categories/push',
      pullEndpoint: 'inventory/categories/pull',
      isPush: isPush,
      extraPushFields: (r) => {
        'description': r['description'] ?? '',
        'examples': r['examples'] ?? '',
        'isQuickAccess': (r['is_quick_access'] as int? ?? 0) == 1,
      },
      extraPullFields: (m) => {
        'description': (m['description'] as String?) ?? '',
        'examples': (m['examples'] as String?) ?? '',
        'is_quick_access': (m['isQuickAccess'] as bool? ?? false) ? 1 : 0,
      },
    );
  }

  Future<void> _normalizeQuickAccessCategoryPins(
    Database db, {
    required int maxPinned,
  }) async {
    final rows = await db.query(
      AppDatabase.ttProductCategoriesTable,
      columns: const ['id'],
      where: 'is_deleted = 0 AND is_quick_access = 1',
      orderBy: 'updated_at DESC, id DESC',
    );
    if (rows.length <= maxPinned) {
      return;
    }

    final now = DateTime.now().toIso8601String();
    final overflowRows = rows.skip(maxPinned);
    final batch = db.batch();
    var changed = 0;

    for (final row in overflowRows) {
      final id = row['id'];
      if (id is! int) {
        continue;
      }

      batch.update(
        AppDatabase.ttProductCategoriesTable,
        {'is_quick_access': 0, 'is_dirty': 1, 'updated_at': now},
        where: 'id = ?',
        whereArgs: [id],
      );
      changed++;
    }

    if (changed == 0) {
      return;
    }

    await batch.commit(noResult: true);
    log(
      '[Sync] Normalized quick-access categories before push: '
      'max=$maxPinned, unpinned=$changed',
      name: 'SyncService',
    );
  }

  Future<int> _syncTtShelfLocations(
    Database db,
    String deviceId, {
    required bool isPush,
  }) async {
    return _syncTtLookupTable(
      db,
      localTable: AppDatabase.ttShelfLocationsTable,
      pushEndpoint: 'inventory/shelf-locations/push',
      pullEndpoint: 'inventory/shelf-locations/pull',
      isPush: isPush,
      extraPushFields: (r) => {
        'description': r['description'] ?? '',
        'examples': r['examples'] ?? '',
      },
      extraPullFields: (m) async {
        // Server is authoritative for image_url; rebuilt as an absolute URL
        // so [Image.network] can render it directly.
        final baseUrl = await SyncConfig.getBaseApiUrl();
        return {
          'description': (m['description'] as String?) ?? '',
          'examples': (m['examples'] as String?) ?? '',
          'image_url': _absoluteImageUrl(m['imageUrl'] as String?, baseUrl),
        };
      },
    );
  }

  Future<int> _syncTtProducts(
    Database db,
    String deviceId, {
    required bool isPush,
  }) async {
    final table = AppDatabase.ttProductsTable;
    if (isPush) {
      final rows = await db.query(table, where: 'is_dirty = 1');
      if (rows.isEmpty) return 0;
      final baseUrl = await SyncConfig.getBaseApiUrl();
      var count = 0;
      for (final row in rows) {
        try {
          final syncId = row['sync_id'] as String;
          final serverId = row['server_id'] as String?;
          final isDeleted = (row['is_deleted'] as int) == 1;
          final conversions = await _loadLocalProductConversions(db, syncId);

          // Bug fix: never push a deleted record that was never on server
          if (isDeleted && serverId == null) {
            await db.update(
              table,
              {'is_dirty': 0},
              where: 'sync_id = ?',
              whereArgs: [syncId],
            );
            count++;
            continue;
          }

          http.Response res;
          if (isDeleted && serverId != null) {
            res = await http
                .delete(Uri.parse('$baseUrl/inventory/products/$serverId'))
                .timeout(_requestTimeout);
          } else if (serverId == null) {
            res = await http
                .post(
                  Uri.parse('$baseUrl/inventory/products'),
                  headers: const {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'syncId': syncId,
                    'deviceId': row['device_id'],
                    'name': row['name'],
                    'sku': row['sku'],
                    'description': row['description'],
                    'category': row['category'],
                    'baseUnit': row['base_unit'] ?? row['unit'] ?? 'pcs',
                    'costPrice': row['cost_price'],
                    'sellingPrice': row['selling_price'],
                    'stockInBaseUnit':
                        row['stock_in_base_unit'] ?? row['stock_quantity'],
                    'reorderPoint': row['reorder_point'],
                    'isActive': (row['is_active'] as int) == 1,
                    'shelfLocation': row['shelf_location'] ?? 'Counter',
                    'expirationDate': row['expiration_date'],
                    'unitConversions': conversions,
                  }),
                )
                .timeout(_requestTimeout);
            if (res.statusCode >= 200 && res.statusCode < 300) {
              final data = jsonDecode(res.body)['data'] as Map<String, dynamic>;
              final newServerId = data['id'] as String;
              await db.update(
                table,
                {'server_id': newServerId, 'is_dirty': 0},
                where: 'sync_id = ?',
                whereArgs: [syncId],
              );
              // If the product has a local image that hasn't been uploaded yet,
              // push it immediately after the product record is confirmed on the server.
              final imagePath = row['image_path'] as String?;
              final imageUrl = row['image_url'] as String?;
              if (imagePath != null && imageUrl == null) {
                unawaited(
                  _pushProductImage(
                    db: db,
                    table: table,
                    syncId: syncId,
                    serverId: newServerId,
                    imagePath: imagePath,
                    baseUrl: baseUrl,
                  ),
                );
              }
            } else {
              log(
                '[Sync] product POST failed ${res.statusCode}: ${res.body}',
                name: 'SyncService',
              );
            }
            count++;
            continue;
          } else {
            res = await http
                .patch(
                  Uri.parse('$baseUrl/inventory/products/$serverId'),
                  headers: const {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'name': row['name'],
                    'sku': row['sku'],
                    'description': row['description'],
                    'category': row['category'],
                    'baseUnit': row['base_unit'] ?? row['unit'] ?? 'pcs',
                    'costPrice': row['cost_price'],
                    'sellingPrice': row['selling_price'],
                    'stockInBaseUnit':
                        row['stock_in_base_unit'] ?? row['stock_quantity'],
                    'reorderPoint': row['reorder_point'],
                    'isActive': (row['is_active'] as int) == 1,
                    'shelfLocation': row['shelf_location'] ?? 'Counter',
                    'expirationDate': row['expiration_date'],
                    'unitConversions': conversions,
                  }),
                )
                .timeout(_requestTimeout);
          }
          if (res.statusCode >= 200 && res.statusCode < 300) {
            await db.update(
              table,
              {'is_dirty': 0},
              where: 'sync_id = ?',
              whereArgs: [row['sync_id']],
            );
            // Also upload the image if it has never reached the server.
            final patchImagePath = row['image_path'] as String?;
            final patchImageUrl = row['image_url'] as String?;
            if (patchImagePath != null && patchImageUrl == null) {
              unawaited(
                _pushProductImage(
                  db: db,
                  table: table,
                  syncId: syncId,
                  serverId: serverId,
                  imagePath: patchImagePath,
                  baseUrl: baseUrl,
                ),
              );
            }
          }
          count++;
        } catch (e, st) {
          log('[Sync] product push error: $e\n$st', name: 'SyncService');
        }
      }
      return count;
    }

    // pull
    try {
      final baseUrl = await SyncConfig.getBaseApiUrl();
      final res = await http
          .get(
            Uri.parse(
              '$baseUrl/inventory/products?includeDeleted=true&limit=1000',
            ),
          )
          .timeout(_requestTimeout);
      if (res.statusCode < 200 || res.statusCode >= 300) return 0;
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final list = body['data'] as List<dynamic>;
      var count = 0;
      for (final item in list) {
        final m = item as Map<String, dynamic>;
        final serverSyncId = m['syncId'] as String?;
        final serverId = m['id'] as String;

        // find local row by syncId first, then by server_id
        List<Map<String, Object?>> localRows = [];
        if (serverSyncId != null) {
          localRows = await db.query(
            table,
            where: 'sync_id = ?',
            whereArgs: [serverSyncId],
            limit: 1,
          );
        }
        if (localRows.isEmpty) {
          localRows = await db.query(
            table,
            where: 'server_id = ?',
            whereArgs: [serverId],
            limit: 1,
          );
        }
        final local = localRows.isEmpty ? null : localRows.first;
        // Don't overwrite dirty local rows
        if (local != null && (local['is_dirty'] as int) == 1) continue;

        final values = {
          'sync_id': serverSyncId ?? serverId,
          'server_id': serverId,
          'device_id': m['deviceId'] ?? deviceId,
          'name': m['name'] ?? '',
          'sku': m['sku'] ?? '',
          'description': m['description'] ?? '',
          'category': m['category'] ?? 'General',
          'unit': m['baseUnit'] ?? m['unit'] ?? 'pcs',
          'base_unit': m['baseUnit'] ?? m['unit'] ?? 'pcs',
          'cost_price': (m['costPrice'] as num?)?.toDouble() ?? 0,
          'selling_price': (m['sellingPrice'] as num?)?.toDouble() ?? 0,
          'stock_quantity':
              ((m['stockInBaseUnit'] as num?) ?? (m['stockQuantity'] as num?))
                  ?.toDouble()
                  .floor() ??
              0,
          'stock_in_base_unit':
              ((m['stockInBaseUnit'] as num?) ?? (m['stockQuantity'] as num?))
                  ?.toDouble() ??
              0,
          'reorder_point': (m['reorderPoint'] as num?)?.toInt() ?? 0,
          'is_active': (m['isActive'] as bool? ?? true) ? 1 : 0,
          'is_deleted': (m['isDeleted'] as bool? ?? false) ? 1 : 0,
          'is_dirty': 0,
          'shelf_location': (m['shelfLocation'] as String?) ?? 'Counter',
          'expiration_date': m['expirationDate'] as String?,
          'image_url': _absoluteImageUrl(m['imageUrl'] as String?, baseUrl),
          'created_at': m['createdAt'] ?? DateTime.now().toIso8601String(),
          'updated_at': m['updatedAt'] ?? DateTime.now().toIso8601String(),
        };
        if (local == null) {
          await db.insert(
            table,
            values,
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        } else {
          await db.update(
            table,
            values,
            where: 'id = ?',
            whereArgs: [local['id']],
          );
        }
        await _replaceLocalProductConversions(
          db,
          productSyncId: values['sync_id'] as String,
          fromServer: (m['unitConversions'] as List<dynamic>?) ?? const [],
        );
        count++;
      }
      return count;
    } catch (_) {
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> _loadLocalProductConversions(
    Database db,
    String productSyncId,
  ) async {
    final rows = await db.query(
      AppDatabase.ttProductConversionsTable,
      where: 'product_id = ? AND is_deleted = 0',
      whereArgs: [productSyncId],
      orderBy: 'conversion_factor DESC, unit_name ASC',
    );
    return rows
        .map(
          (r) => {
            'syncId': r['sync_id'],
            'unitName': r['unit_name'],
            'conversionFactor': (r['conversion_factor'] as num).toDouble(),
            'costPrice': (r['cost_price'] as num).toDouble(),
            'sellingPrice': (r['selling_price'] as num).toDouble(),
          },
        )
        .toList(growable: false);
  }

  Future<void> _replaceLocalProductConversions(
    Database db, {
    required String productSyncId,
    required List<dynamic> fromServer,
  }) async {
    final batch = db.batch();
    batch.delete(
      AppDatabase.ttProductConversionsTable,
      where: 'product_id = ?',
      whereArgs: [productSyncId],
    );
    final now = DateTime.now().toIso8601String();
    for (final item in fromServer) {
      final m = item as Map<String, dynamic>;
      final factor = (m['conversionFactor'] as num?)?.toDouble() ?? 0;
      final unitName = (m['unitName'] as String?)?.trim() ?? '';
      if (unitName.isEmpty || factor <= 0) continue;
      batch.insert(AppDatabase.ttProductConversionsTable, {
        'sync_id': (m['syncId'] as String?) ?? _randomSyncId(),
        'product_id': productSyncId,
        'unit_name': unitName,
        'conversion_factor': factor,
        'cost_price': (m['costPrice'] as num?)?.toDouble() ?? 0,
        'selling_price': (m['sellingPrice'] as num?)?.toDouble() ?? 0,
        'is_deleted': 0,
        'is_dirty': 0,
        'created_at': now,
        'updated_at': now,
      });
    }
    await batch.commit(noResult: true);
  }

  String _randomSyncId() => DateTime.now().microsecondsSinceEpoch.toString();

  /// Uploads a product image to the server using multipart POST.
  /// Updates [table].image_url in SQLite on success.
  Future<void> _pushProductImage({
    required Database db,
    required String table,
    required String syncId,
    required String serverId,
    required String imagePath,
    required String baseUrl,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/inventory/products/$serverId/image');
      final request = http.MultipartRequest('PATCH', uri);
      // Explicitly declare the MIME type so the server's fileFilter accepts it
      // regardless of OS-level MIME detection fallbacks (which may return
      // application/octet-stream for .webp on some Android builds).
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imagePath,
          contentType: MediaType('image', 'webp'),
        ),
      );
      final streamed = await request.send().timeout(_requestTimeout);
      final responseBody = await streamed.stream.bytesToString();
      if (streamed.statusCode >= 200 && streamed.statusCode < 300) {
        final data = jsonDecode(responseBody)['data'] as Map<String, dynamic>?;
        final remoteUrl = _absoluteImageUrl(
          data?['imageUrl'] as String?,
          baseUrl,
        );
        await db.update(
          table,
          {'image_url': remoteUrl},
          where: 'sync_id = ?',
          whereArgs: [syncId],
        );
      } else {
        log(
          '[Sync] image upload failed ${streamed.statusCode} for $syncId: $responseBody',
          name: 'SyncService',
        );
      }
    } catch (e) {
      log('[Sync] image upload error for $syncId: $e', name: 'SyncService');
    }
  }

  /// Walks every shelf location that has a local `image_path` but no
  /// `image_url` (i.e. picture captured offline, never uploaded) and pushes
  /// it via multipart PATCH. Called from [_doSyncAll] after the shelf
  /// locations themselves have been pushed, guaranteeing each row has a
  /// `server_id` to address.
  Future<int> _pushShelfLocationImages(Database db) async {
    final rows = await db.query(
      AppDatabase.ttShelfLocationsTable,
      where:
          'image_path IS NOT NULL AND (image_url IS NULL OR image_url = "") '
          'AND server_id IS NOT NULL AND is_deleted = 0',
    );
    if (rows.isEmpty) return 0;
    final baseUrl = await SyncConfig.getBaseApiUrl();
    var pushed = 0;
    for (final row in rows) {
      final syncId = row['sync_id'] as String;
      final serverId = row['server_id'] as String;
      final imagePath = row['image_path'] as String;
      try {
        final uri = Uri.parse(
          '$baseUrl/inventory/shelf-locations/$serverId/image',
        );
        final request = http.MultipartRequest('PATCH', uri);
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            imagePath,
            contentType: MediaType('image', 'webp'),
          ),
        );
        final streamed = await request.send().timeout(_requestTimeout);
        final responseBody = await streamed.stream.bytesToString();
        if (streamed.statusCode >= 200 && streamed.statusCode < 300) {
          final data =
              jsonDecode(responseBody)['data'] as Map<String, dynamic>?;
          final remoteUrl = _absoluteImageUrl(
            data?['imageUrl'] as String?,
            baseUrl,
          );
          await db.update(
            AppDatabase.ttShelfLocationsTable,
            {'image_url': remoteUrl},
            where: 'sync_id = ?',
            whereArgs: [syncId],
          );
          pushed++;
        } else {
          log(
            '[Sync] shelf-location image upload failed '
            '${streamed.statusCode} for $syncId: $responseBody',
            name: 'SyncService',
          );
        }
      } catch (e) {
        log(
          '[Sync] shelf-location image upload error for $syncId: $e',
          name: 'SyncService',
        );
      }
    }
    return pushed;
  }

  /// Converts a server-returned image URL to an absolute URL.
  /// The server stores paths like `/uploads/products/foo.webp` (relative).
  /// We need `http://host:port/uploads/products/foo.webp` for [Image.network].
  String? _absoluteImageUrl(String? url, String baseUrl) {
    if (url == null) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('/')) {
      final origin = Uri.parse(baseUrl).origin;
      return '$origin$url';
    }
    return url;
  }

  Future<int> _syncTtCustomers(
    Database db,
    String deviceId, {
    required bool isPush,
  }) async {
    final table = AppDatabase.ttCustomersTable;
    if (isPush) {
      final rows = await db.query(table, where: 'is_dirty = 1');
      if (rows.isEmpty) return 0;
      final baseUrl = await SyncConfig.getBaseApiUrl();
      var count = 0;
      for (final row in rows) {
        try {
          final serverId = row['server_id'] as String?;
          final isDeleted = (row['is_deleted'] as int) == 1;
          final syncId = row['sync_id'] as String;

          // Bug fix: never push a deleted record that was never on server
          if (isDeleted && serverId == null) {
            await db.update(
              table,
              {'is_dirty': 0},
              where: 'sync_id = ?',
              whereArgs: [syncId],
            );
            count++;
            continue;
          }

          if (isDeleted && serverId != null) {
            await http
                .delete(Uri.parse('$baseUrl/customers/$serverId'))
                .timeout(_requestTimeout);
          } else if (serverId == null) {
            final res = await http
                .post(
                  Uri.parse('$baseUrl/customers'),
                  headers: const {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'name': row['name'],
                    if ((row['phone'] as String).isNotEmpty)
                      'phone': row['phone'],
                    if ((row['address'] as String).isNotEmpty)
                      'address': row['address'],
                    if ((row['notes'] as String).isNotEmpty)
                      'notes': row['notes'],
                  }),
                )
                .timeout(_requestTimeout);
            if (res.statusCode >= 200 && res.statusCode < 300) {
              final data = jsonDecode(res.body)['data'] as Map<String, dynamic>;
              final newServerId = data['id'] as String;
              await db.update(
                table,
                {'server_id': newServerId, 'is_dirty': 0},
                where: 'sync_id = ?',
                whereArgs: [syncId],
              );
              // Push dirty utang records for this customer
              await _pushPendingUtang(db, syncId, newServerId, baseUrl);
            }
            count++;
            continue;
          } else {
            // Bug fix: customer with server_id updated offline — PATCH it
            await http
                .patch(
                  Uri.parse('$baseUrl/customers/$serverId'),
                  headers: const {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'name': row['name'],
                    if ((row['phone'] as String).isNotEmpty)
                      'phone': row['phone'],
                    if ((row['address'] as String).isNotEmpty)
                      'address': row['address'],
                    if ((row['notes'] as String).isNotEmpty)
                      'notes': row['notes'],
                  }),
                )
                .timeout(_requestTimeout);
          }
          await db.update(
            table,
            {'is_dirty': 0},
            where: 'sync_id = ?',
            whereArgs: [syncId],
          );
          count++;
        } catch (e, st) {
          log('[Sync] customer push error: $e\n$st', name: 'SyncService');
        }
      }

      // Bug fix: push orphaned dirty utang records whose customers already
      // have a server_id (customer wasn't dirty so _pushPendingUtang was
      // never called for them).
      final orphanedUtang = await db.query(
        AppDatabase.ttUtangRecordsTable,
        where: 'is_dirty = 1 AND server_id IS NULL',
      );
      for (final utang in orphanedUtang) {
        try {
          final customerSyncId = utang['customer_sync_id'] as String;
          final customerRows = await db.query(
            AppDatabase.ttCustomersTable,
            where: 'sync_id = ?',
            whereArgs: [customerSyncId],
            limit: 1,
          );
          if (customerRows.isEmpty) continue;
          final customerServerId = customerRows.first['server_id'] as String?;
          if (customerServerId == null) continue;
          await _pushPendingUtang(
            db,
            customerSyncId,
            customerServerId,
            baseUrl,
          );
        } catch (e, st) {
          log('[Sync] orphaned utang push error: $e\n$st', name: 'SyncService');
        }
      }

      return count;
    }

    // pull
    try {
      final baseUrl = await SyncConfig.getBaseApiUrl();
      final res = await http
          .get(Uri.parse('$baseUrl/customers'))
          .timeout(_requestTimeout);
      if (res.statusCode < 200 || res.statusCode >= 300) return 0;
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final list = body['data'] as List<dynamic>;
      var count = 0;
      for (final item in list) {
        final m = item as Map<String, dynamic>;
        final serverId = m['id'] as String;
        final localRows = await db.query(
          table,
          where: 'server_id = ?',
          whereArgs: [serverId],
          limit: 1,
        );
        final local = localRows.isEmpty ? null : localRows.first;
        if (local != null && (local['is_dirty'] as int) == 1) continue;

        final now = DateTime.now().toIso8601String();
        final values = {
          'sync_id': local?['sync_id'] ?? serverId,
          'server_id': serverId,
          'device_id': deviceId,
          'name': m['name'] ?? '',
          'phone': m['phone'] ?? '',
          'address': m['address'] ?? '',
          'notes': m['notes'] ?? '',
          'balance': (m['balance'] as num?)?.toDouble() ?? 0,
          'is_deleted': 0,
          'is_dirty': 0,
          'created_at': m['createdAt'] ?? now,
          'updated_at': m['updatedAt'] ?? now,
        };
        if (local == null) {
          await db.insert(
            table,
            values,
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        } else {
          await db.update(
            table,
            values,
            where: 'id = ?',
            whereArgs: [local['id']],
          );
        }
        count++;
      }
      return count;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _pushPendingUtang(
    Database db,
    String customerSyncId,
    String serverCustomerId,
    String baseUrl,
  ) async {
    final utangRows = await db.query(
      AppDatabase.ttUtangRecordsTable,
      where: 'customer_sync_id = ? AND is_dirty = 1 AND server_id IS NULL',
      whereArgs: [customerSyncId],
    );
    for (final row in utangRows) {
      try {
        final amount = (row['amount'] as num).toDouble();
        final isPayment = amount < 0;
        final path = isPayment
            ? '$baseUrl/customers/$serverCustomerId/payment'
            : '$baseUrl/customers/$serverCustomerId/utang';
        final res = await http
            .post(
              Uri.parse(path),
              headers: const {'Content-Type': 'application/json'},
              body: jsonEncode({
                'amount': amount.abs(),
                'description': row['description'],
              }),
            )
            .timeout(_requestTimeout);
        if (res.statusCode >= 200 && res.statusCode < 300) {
          final data = jsonDecode(res.body)['data'] as Map<String, dynamic>;
          await db.update(
            AppDatabase.ttUtangRecordsTable,
            {'server_id': data['id'], 'is_dirty': 0},
            where: 'sync_id = ?',
            whereArgs: [row['sync_id']],
          );
        }
      } catch (e, st) {
        log('[Sync] _pushPendingUtang error: $e\n$st', name: 'SyncService');
      }
    }
  }

  Future<int> _syncTtSales(
    Database db,
    String deviceId, {
    required bool isPush,
  }) async {
    final table = AppDatabase.ttSalesTable;
    if (isPush) {
      final rows = await db.query(
        table,
        where: 'is_dirty = 1 AND server_id IS NULL',
      );
      if (rows.isEmpty) return 0;
      final baseUrl = await SyncConfig.getBaseApiUrl();
      var count = 0;
      for (final row in rows) {
        try {
          final saleSyncId = row['sync_id'] as String;
          final itemRows = await db.query(
            AppDatabase.ttSaleItemsTable,
            where: 'sale_sync_id = ?',
            whereArgs: [saleSyncId],
          );
          // Bug fix: refresh product_server_id from tt_products in case
          // products were pushed (and got their server_id) in this same sync.
          for (final item in itemRows) {
            if (item['product_server_id'] != null) continue;
            final pSyncId = item['product_sync_id'] as String;
            final pRows = await db.query(
              AppDatabase.ttProductsTable,
              where: 'sync_id = ?',
              whereArgs: [pSyncId],
              limit: 1,
            );
            if (pRows.isNotEmpty && pRows.first['server_id'] != null) {
              await db.update(
                AppDatabase.ttSaleItemsTable,
                {'product_server_id': pRows.first['server_id']},
                where: 'sale_sync_id = ? AND product_sync_id = ?',
                whereArgs: [saleSyncId, pSyncId],
              );
            }
          }
          // Re-query after refresh
          final refreshedItems = await db.query(
            AppDatabase.ttSaleItemsTable,
            where: 'sale_sync_id = ?',
            whereArgs: [saleSyncId],
          );
          final allHaveServerIds = refreshedItems.every(
            (r) => r['product_server_id'] != null,
          );
          if (!allHaveServerIds) continue;

          final res = await http
              .post(
                Uri.parse('$baseUrl/pos/checkout'),
                headers: const {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'reference': row['reference'],
                  'paidAmount': row['paid_amount'],
                  if ((row['note'] as String).isNotEmpty) 'note': row['note'],
                  'deviceId': row['device_id'],
                  'items': refreshedItems
                      .map(
                        (r) => {
                          'productId': r['product_server_id'],
                          'quantity': r['quantity'],
                          'selectedUnit': r['selected_unit'],
                          'unitPrice': r['unit_price'],
                          'computedBaseQuantity': r['computed_base_quantity'],
                        },
                      )
                      .toList(),
                }),
              )
              .timeout(_requestTimeout);

          if (res.statusCode >= 200 && res.statusCode < 300) {
            final data = jsonDecode(res.body)['data'] as Map<String, dynamic>;
            await db.update(
              table,
              {'server_id': data['id'], 'is_dirty': 0},
              where: 'sync_id = ?',
              whereArgs: [saleSyncId],
            );
          }
          count++;
        } catch (e, st) {
          log('[Sync] sale push error: $e\n$st', name: 'SyncService');
        }
      }
      return count;
    }

    // pull
    try {
      final baseUrl = await SyncConfig.getBaseApiUrl();
      final res = await http
          .get(Uri.parse('$baseUrl/pos/sales?limit=500'))
          .timeout(_requestTimeout);
      if (res.statusCode < 200 || res.statusCode >= 300) return 0;
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final list = body['data'] as List<dynamic>;
      var count = 0;
      for (final item in list) {
        final m = item as Map<String, dynamic>;
        final serverId = m['id'] as String;
        final localRows = await db.query(
          table,
          where: 'server_id = ?',
          whereArgs: [serverId],
          limit: 1,
        );
        if (localRows.isNotEmpty) continue; // already have it

        final saleSyncId = serverId;
        final now = DateTime.now().toIso8601String();
        await db.insert(table, {
          'sync_id': saleSyncId,
          'server_id': serverId,
          'device_id': deviceId,
          'reference': m['reference'] ?? '',
          'note': m['note'] ?? '',
          'subtotal': (m['subtotal'] as num?)?.toDouble() ?? 0,
          'total_amount': (m['totalAmount'] as num?)?.toDouble() ?? 0,
          'paid_amount': (m['paidAmount'] as num?)?.toDouble() ?? 0,
          'change_amount': (m['changeAmount'] as num?)?.toDouble() ?? 0,
          'total_items': (m['totalItems'] as num?)?.toInt() ?? 0,
          'is_dirty': 0,
          'created_at': m['createdAt'] ?? now,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);

        final itemsJson = m['saleItems'] as List<dynamic>? ?? [];
        for (final si in itemsJson) {
          final sm = si as Map<String, dynamic>;
          final product = sm['product'] as Map<String, dynamic>? ?? {};
          await db.insert(
            AppDatabase.ttSaleItemsTable,
            {
              'sale_sync_id': saleSyncId,
              'product_sync_id': sm['productId'] ?? '',
              'product_server_id': sm['productId'],
              'product_name': product['name'] ?? '',
              'selected_unit':
                  sm['selectedUnit'] ?? product['baseUnit'] ?? 'pc',
              'quantity': (sm['quantity'] as num?)?.toDouble() ?? 0,
              'unit_price': (sm['unitPrice'] as num?)?.toDouble() ?? 0,
              'computed_base_quantity':
                  (sm['computedBaseQuantity'] as num?)?.toDouble() ??
                  (sm['quantity'] as num?)?.toDouble() ??
                  0,
              'line_total': (sm['lineTotal'] as num?)?.toDouble() ?? 0,
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
        count++;
      }
      return count;
    } catch (_) {
      return 0;
    }
  }
}
