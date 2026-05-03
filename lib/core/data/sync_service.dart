import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'app_database.dart';
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
  static const Duration _requestTimeout = Duration(seconds: 12);

  Future<SyncRunResult> syncAll() async {
    final db = await _database.database;
    await _database.ensureSyncSchema(db);

    final deviceId = await _database.getOrCreateDeviceId();
    final sinceRaw = await _database.getSyncState('last_sync_ms');
    final sinceMs = int.tryParse(sinceRaw ?? '') ?? 0;
    final hasLocalData = await _hasAnyLocalData(db);
    final effectiveSinceMs = hasLocalData ? sinceMs : 0;
    final pullDeviceId = hasLocalData ? deviceId : null;

    var pushed = 0;
    var pulled = 0;

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

    await _database.setSyncState(
      'last_sync_ms',
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
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'Pull failed for $path: ${response.statusCode} ${response.body}',
      );
    }

    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) {
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
}
