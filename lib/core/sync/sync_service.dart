import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';

import '../data/app_database.dart';
import 'remote/charge_remote_repository.dart';
import 'remote/ledger_entry_remote_repository.dart';
import 'remote/movement_category_remote_repository.dart';
import 'remote/party_remote_repository.dart';
import 'remote/transaction_type_remote_repository.dart';

class SyncService {
  SyncService._();
  static final SyncService instance = SyncService._();

  static const String _deviceIdKey = 'sync_device_id';
  static const String _lastSyncKey = 'sync_last_pull_at';
  static const String _bootstrapPushedKey = 'sync_bootstrap_pushed';

  String? _deviceId;
  Future<void>? _activeOperation;
  bool _syncQueued = false;

  // ── Initialise ──────────────────────────────────────────────────────────────

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString(_deviceIdKey);
    if (_deviceId == null) {
      _deviceId = const Uuid().v4();
      await prefs.setString(_deviceIdKey, _deviceId!);
    }

    // Listen for connectivity changes and auto-sync when coming back online.
    Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online) sync();
    });
  }

  // ── Public entry point ───────────────────────────────────────────────────────

  Future<void> syncOnLaunch() async {
    await _runExclusive(() async {
      await _bootstrapLocalDataToServerInternal();
      await _syncInternal();
    });
  }

  Future<void> sync() async {
    await _runExclusive(_syncInternal, queueSyncIfBusy: true);
  }

  // Push all existing local records once to seed cloud data for this device.
  Future<void> bootstrapLocalDataToServer() async {
    await _runExclusive(_bootstrapLocalDataToServerInternal);
  }

  Future<void> _runExclusive(
    Future<void> Function() operation, {
    bool queueSyncIfBusy = false,
  }) async {
    if (_activeOperation != null) {
      if (queueSyncIfBusy) {
        _syncQueued = true;
      }
      await _activeOperation;
      return;
    }

    final currentOperation = operation();
    _activeOperation = currentOperation;
    try {
      await currentOperation;
    } finally {
      _activeOperation = null;
    }

    if (_syncQueued) {
      _syncQueued = false;
      await _runExclusive(_syncInternal);
    }
  }

  Future<void> _syncInternal() async {
    final results = await Connectivity().checkConnectivity();
    final online = results.any((r) => r != ConnectivityResult.none);
    if (!online) return;

    await _push();
    await _pull();
  }

  Future<void> _bootstrapLocalDataToServerInternal() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyBootstrapped = prefs.getBool(_bootstrapPushedKey) ?? false;
    if (alreadyBootstrapped) {
      return;
    }

    final results = await Connectivity().checkConnectivity();
    final online = results.any((r) => r != ConnectivityResult.none);
    if (!online) {
      return;
    }

    final pushedAll = await _push(forceAll: true);
    if (pushedAll) {
      await prefs.setBool(_bootstrapPushedKey, true);
    }
  }

  // ── Push: unsynced local records → server ────────────────────────────────────

  Future<bool> _push({bool forceAll = false}) async {
    final db = await AppDatabase.instance.database;
    final whereClause = forceAll
        ? '${AppDatabase.isDeletedColumn} = 0'
        : '${AppDatabase.isDirtyColumn} = 1';
    var allSucceeded = true;

    // Parties
    final parties = await db.query(
      AppDatabase.partiesTable,
      where: whereClause,
    );
    if (parties.isNotEmpty) {
      final mapped = parties.map((r) => _toPartyPayload(r)).toList();
      final pushed = await PartyRemoteRepository.instance.push(mapped);
      if (pushed) {
        await _markSynced(db, AppDatabase.partiesTable, parties);
      } else {
        allSucceeded = false;
        _logPushFailure('parties', parties.length);
      }
    }

    // Ledger entries
    final entries = await db.query(AppDatabase.ledgerTable, where: whereClause);
    if (entries.isNotEmpty) {
      final mapped = entries.map((r) => _toEntryPayload(r)).toList();
      final pushed = await LedgerEntryRemoteRepository.instance.push(mapped);
      if (pushed) {
        await _markSynced(db, AppDatabase.ledgerTable, entries);
      } else {
        allSucceeded = false;
        _logPushFailure('ledger_entries', entries.length);
      }
    }

    // Charges
    final charges = await db.query(
      AppDatabase.chargesTable,
      where: whereClause,
    );
    if (charges.isNotEmpty) {
      final mapped = charges.map((r) => _toChargePayload(r)).toList();
      final pushed = await ChargeRemoteRepository.instance.push(mapped);
      if (pushed) {
        await _markSynced(db, AppDatabase.chargesTable, charges);
      } else {
        allSucceeded = false;
        _logPushFailure('charges', charges.length);
      }
    }

    // Transaction types
    final types = await db.query(
      AppDatabase.transactionTypesTable,
      where: whereClause,
    );
    if (types.isNotEmpty) {
      final mapped = types.map((r) => _toTransactionTypePayload(r)).toList();
      final pushed = await TransactionTypeRemoteRepository.instance.push(
        mapped,
      );
      if (pushed) {
        await _markSynced(db, AppDatabase.transactionTypesTable, types);
      } else {
        allSucceeded = false;
        _logPushFailure('transaction_types', types.length);
      }
    }

    // Movement categories
    final cats = await db.query(
      AppDatabase.ownerMovementCategoriesTable,
      where: whereClause,
    );
    if (cats.isNotEmpty) {
      final mapped = cats.map((r) => _toMovementCategoryPayload(r)).toList();
      final pushed = await MovementCategoryRemoteRepository.instance.push(
        mapped,
      );
      if (pushed) {
        await _markSynced(db, AppDatabase.ownerMovementCategoriesTable, cats);
      } else {
        allSucceeded = false;
        _logPushFailure('owner_movement_categories', cats.length);
      }
    }

    return allSucceeded;
  }

  // ── Pull: server records → local SQLite ──────────────────────────────────────

  Future<void> _pull() async {
    final prefs = await SharedPreferences.getInstance();
    final since = prefs.getInt(_lastSyncKey);
    final deviceId = _deviceId!;
    final db = await AppDatabase.instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    // Parties
    final remoteParties = await PartyRemoteRepository.instance.pull(
      deviceId: deviceId,
      since: since,
    );
    for (final r in remoteParties) {
      if (r['isDeleted'] == true) {
        await db.update(
          AppDatabase.partiesTable,
          {
            AppDatabase.isDeletedColumn: 1,
            AppDatabase.isDirtyColumn: 0,
            AppDatabase.updatedAtMsColumn: now,
          },
          where: '${AppDatabase.syncIdColumn} = ?',
          whereArgs: [r['syncId']],
        );
      } else {
        await db.insert(AppDatabase.partiesTable, {
          'name': r['name'],
          'account_number': r['accountNumber'],
          'entity_id': r['entityId'] ?? '',
          'description': r['description'] ?? '',
          'join_date': r['joinDate'],
          'is_verified': (r['isVerified'] == true) ? 1 : 0,
          AppDatabase.syncIdColumn: r['syncId'],
          AppDatabase.deviceIdColumn: r['deviceId'] ?? '',
          AppDatabase.updatedAtMsColumn: now,
          AppDatabase.isDeletedColumn: 0,
          AppDatabase.isDirtyColumn: 0,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }

    // Ledger entries
    final remoteEntries = await LedgerEntryRemoteRepository.instance.pull(
      deviceId: deviceId,
      since: since,
    );
    for (final r in remoteEntries) {
      if (r['isDeleted'] == true) {
        await db.update(
          AppDatabase.ledgerTable,
          {
            AppDatabase.isDeletedColumn: 1,
            AppDatabase.isDirtyColumn: 0,
            AppDatabase.updatedAtMsColumn: now,
          },
          where: '${AppDatabase.syncIdColumn} = ?',
          whereArgs: [r['syncId']],
        );
      } else {
        await db.insert(AppDatabase.ledgerTable, {
          'entry_type': r['entryType'],
          'title': r['title'] ?? '',
          'note': r['note'] ?? '',
          'reference': r['reference'] ?? '',
          'amount': r['amount'],
          'wallet_delta': r['walletDelta'] ?? 0,
          'maya_wallet_delta': r['mayaWalletDelta'] ?? 0,
          'on_hand_delta': r['onHandDelta'] ?? 0,
          'recorded_flow': r['recordedFlow'] ?? 0,
          'tag': r['tag'] ?? '',
          'icon_key': r['iconKey'] ?? '',
          'wallet_account': r['walletAccount'] ?? '',
          'owner_scope': r['ownerScope'] ?? 'Business',
          'owner_movement_type': r['ownerMovementType'],
          'owner_category': r['ownerCategory'],
          'owner_party_name': r['ownerPartyName'],
          'owner_party_account': r['ownerPartyAccount'],
          'created_at': r['entryDate'],
          AppDatabase.syncIdColumn: r['syncId'],
          AppDatabase.deviceIdColumn: r['deviceId'] ?? '',
          AppDatabase.updatedAtMsColumn: now,
          AppDatabase.isDeletedColumn: 0,
          AppDatabase.isDirtyColumn: 0,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }

    // Charges
    final remoteCharges = await ChargeRemoteRepository.instance.pull(
      deviceId: deviceId,
      since: since,
    );
    for (final r in remoteCharges) {
      if (r['isDeleted'] == true) {
        await db.update(
          AppDatabase.chargesTable,
          {
            AppDatabase.isDeletedColumn: 1,
            AppDatabase.isDirtyColumn: 0,
            AppDatabase.updatedAtMsColumn: now,
          },
          where: '${AppDatabase.syncIdColumn} = ?',
          whereArgs: [r['syncId']],
        );
      } else {
        await db.insert(AppDatabase.chargesTable, {
          'lower_bound': r['lowerBound'],
          'upper_bound': r['upperBound'],
          'charge_amount': r['chargeAmount'],
          AppDatabase.syncIdColumn: r['syncId'],
          AppDatabase.deviceIdColumn: r['deviceId'] ?? '',
          AppDatabase.updatedAtMsColumn: now,
          AppDatabase.isDeletedColumn: 0,
          AppDatabase.isDirtyColumn: 0,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }

    // Transaction types
    final remoteTypes = await TransactionTypeRemoteRepository.instance.pull(
      deviceId: deviceId,
      since: since,
    );
    for (final r in remoteTypes) {
      if (r['isDeleted'] == true) {
        await db.update(
          AppDatabase.transactionTypesTable,
          {
            AppDatabase.isDeletedColumn: 1,
            AppDatabase.isDirtyColumn: 0,
            AppDatabase.updatedAtMsColumn: now,
          },
          where: '${AppDatabase.syncIdColumn} = ?',
          whereArgs: [r['syncId']],
        );
      } else {
        await db.insert(
          AppDatabase.transactionTypesTable,
          {
            'name': r['name'],
            'is_outflow': (r['isOutflow'] == true) ? 1 : 0,
            'wallet_account': r['walletAccount'] ?? 'GCash',
            'created_at': r['createdAt'] ?? DateTime.now().toIso8601String(),
            AppDatabase.syncIdColumn: r['syncId'],
            AppDatabase.deviceIdColumn: r['deviceId'] ?? '',
            AppDatabase.updatedAtMsColumn: now,
            AppDatabase.isDeletedColumn: 0,
            AppDatabase.isDirtyColumn: 0,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    // Movement categories
    final remoteCats = await MovementCategoryRemoteRepository.instance.pull(
      deviceId: deviceId,
      since: since,
    );
    for (final r in remoteCats) {
      if (r['isDeleted'] == true) {
        await db.update(
          AppDatabase.ownerMovementCategoriesTable,
          {
            AppDatabase.isDeletedColumn: 1,
            AppDatabase.isDirtyColumn: 0,
            AppDatabase.updatedAtMsColumn: now,
          },
          where: '${AppDatabase.syncIdColumn} = ?',
          whereArgs: [r['syncId']],
        );
      } else {
        await db.insert(
          AppDatabase.ownerMovementCategoriesTable,
          {
            'name': r['name'],
            'created_at': r['createdAt'] ?? DateTime.now().toIso8601String(),
            AppDatabase.syncIdColumn: r['syncId'],
            AppDatabase.deviceIdColumn: r['deviceId'] ?? '',
            AppDatabase.updatedAtMsColumn: now,
            AppDatabase.isDeletedColumn: 0,
            AppDatabase.isDirtyColumn: 0,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    await prefs.setInt(_lastSyncKey, now);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Future<void> _markSynced(
    dynamic db,
    String table,
    List<Map<String, dynamic>> rows,
  ) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final row in rows) {
      final syncId = _syncId(row);
      await db.update(
        table,
        {
          AppDatabase.syncIdColumn: syncId,
          AppDatabase.isDirtyColumn: 0,
          AppDatabase.updatedAtMsColumn: now,
        },
        where: 'id = ?',
        whereArgs: [row['id']],
      );
    }
  }

  String _syncId(Map<String, dynamic> row) {
    return row['sync_id'] as String? ?? '${_deviceId}_${row['id']}';
  }

  Map<String, dynamic> _toPartyPayload(Map<String, dynamic> r) => {
    'syncId': _syncId(r),
    'deviceId': _deviceId,
    'name': r['name'],
    'accountNumber': r['account_number'],
    'entityId': r['entity_id'],
    'description': r['description'],
    'joinDate': r['join_date'],
    'isVerified': r['is_verified'] == 1,
    'isDeleted': r['is_deleted'] == 1,
  };

  Map<String, dynamic> _toEntryPayload(Map<String, dynamic> r) => {
    'syncId': _syncId(r),
    'deviceId': _deviceId,
    'entryType': r['entry_type'],
    'title': r['title'],
    'note': r['note'],
    'reference': r['reference'],
    'amount': r['amount'],
    'walletDelta': r['wallet_delta'],
    'mayaWalletDelta': r['maya_wallet_delta'],
    'onHandDelta': r['on_hand_delta'],
    'recordedFlow': r['recorded_flow'],
    'tag': r['tag'],
    'iconKey': r['icon_key'],
    'walletAccount': r['wallet_account'],
    'ownerScope': r['owner_scope'],
    'ownerMovementType': r['owner_movement_type'],
    'ownerCategory': r['owner_category'],
    'ownerPartyName': r['owner_party_name'],
    'ownerPartyAccount': r['owner_party_account'],
    'entryDate': r['created_at'],
    'isDeleted': r['is_deleted'] == 1,
  };

  Map<String, dynamic> _toChargePayload(Map<String, dynamic> r) => {
    'syncId': _syncId(r),
    'deviceId': _deviceId,
    'lowerBound': r['lower_bound'],
    'upperBound': r['upper_bound'],
    'chargeAmount': r['charge_amount'],
    'isDeleted': r['is_deleted'] == 1,
  };

  Map<String, dynamic> _toTransactionTypePayload(Map<String, dynamic> r) => {
    'syncId': _syncId(r),
    'deviceId': _deviceId,
    'name': r['name'],
    'isOutflow': r['is_outflow'] == 1,
    'walletAccount': r['wallet_account'],
    'isDeleted': r['is_deleted'] == 1,
  };

  Map<String, dynamic> _toMovementCategoryPayload(Map<String, dynamic> r) => {
    'syncId': _syncId(r),
    'deviceId': _deviceId,
    'name': r['name'],
    'isDeleted': r['is_deleted'] == 1,
  };

  void _logPushFailure(String table, int count) {
    if (kDebugMode) {
      debugPrint('Sync push failed: $table=$count');
    }
  }
}
