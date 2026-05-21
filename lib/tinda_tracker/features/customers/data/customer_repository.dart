import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/sync/sync_config.dart';
import 'customer_model.dart';

/// Local-first customer repository.
///
/// All writes hit SQLite immediately (is_dirty = 1), then a fire-and-forget
/// background API call is made. Reads always come from local SQLite.
class CustomerRepository {
  CustomerRepository._();
  static final CustomerRepository instance = CustomerRepository._();

  static const _uuid = Uuid();
  static const _timeout = Duration(seconds: 12);
  final _db = AppDatabase.instance;

  Future<Map<String, Object?>?> _customerRowById(String id) async {
    final db = await _db.database;
    final rows = await db.query(
      AppDatabase.ttCustomersTable,
      where: 'server_id = ? OR sync_id = ?',
      whereArgs: [id, id],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<TtCustomer> _buildCustomer(Map<String, Object?> row) async {
    final db = await _db.database;
    final syncId = row['sync_id'] as String;
    final customerId = (row['server_id'] as String?) ?? syncId;
    final utangRows = await db.query(
      AppDatabase.ttUtangRecordsTable,
      where: 'customer_sync_id = ? AND is_deleted = 0',
      whereArgs: [syncId],
      orderBy: 'created_at ASC',
    );
    final records =
        utangRows.map((r) => TtUtangRecord.fromLocalDb(r, customerId)).toList();
    return TtCustomer.fromLocalDb(row, records);
  }

  Future<List<TtCustomer>> listCustomers() async {
    final db = await _db.database;
    final rows = await db.query(
      AppDatabase.ttCustomersTable,
      where: 'is_deleted = 0',
      orderBy: 'name ASC',
    );
    return Future.wait(rows.map(_buildCustomer));
  }

  Future<TtCustomer> getCustomer(String id) async {
    final row = await _customerRowById(id);
    if (row == null) throw Exception('Customer not found: $id');
    return _buildCustomer(row);
  }

  Future<TtCustomer> createCustomer({
    required String name,
    String? phone,
    String? address,
    String? notes,
  }) async {
    final db = await _db.database;
    final syncId = _uuid.v4();
    final deviceId = await _db.getOrCreateDeviceId();
    final now = DateTime.now().toIso8601String();

    await db.insert(AppDatabase.ttCustomersTable, {
      'sync_id': syncId,
      'server_id': null,
      'device_id': deviceId,
      'name': name,
      'phone': phone ?? '',
      'address': address ?? '',
      'notes': notes ?? '',
      'balance': 0.0,
      'is_deleted': 0,
      'is_dirty': 1,
      'created_at': now,
      'updated_at': now,
    });

    final rows = await db.query(
      AppDatabase.ttCustomersTable,
      where: 'sync_id = ?',
      whereArgs: [syncId],
      limit: 1,
    );
    final customer = await _buildCustomer(rows.first);
    unawaited(_pushCreateCustomer(syncId));
    return customer;
  }

  Future<TtUtangRecord> addUtang({
    required String customerId,
    required double amount,
    required String description,
  }) async {
    final row = await _customerRowById(customerId);
    if (row == null) throw Exception('Customer not found: $customerId');
    final customerSyncId = row['sync_id'] as String;
    final exposedCustomerId = (row['server_id'] as String?) ?? customerSyncId;

    final db = await _db.database;
    final syncId = _uuid.v4();
    final deviceId = await _db.getOrCreateDeviceId();
    final now = DateTime.now().toIso8601String();

    await db.insert(AppDatabase.ttUtangRecordsTable, {
      'sync_id': syncId,
      'server_id': null,
      'customer_sync_id': customerSyncId,
      'device_id': deviceId,
      'description': description,
      'amount': amount,
      'is_deleted': 0,
      'is_dirty': 1,
      'created_at': now,
    });

    final newBalance = (row['balance'] as num).toDouble() + amount;
    await db.update(
      AppDatabase.ttCustomersTable,
      {'balance': newBalance, 'is_dirty': 1, 'updated_at': now},
      where: 'sync_id = ?',
      whereArgs: [customerSyncId],
    );

    final utangRow = await db.query(
      AppDatabase.ttUtangRecordsTable,
      where: 'sync_id = ?',
      whereArgs: [syncId],
      limit: 1,
    );
    final record = TtUtangRecord.fromLocalDb(utangRow.first, exposedCustomerId);
    unawaited(
        _pushUtang(customerSyncId, syncId, amount, description, isPayment: false));
    return record;
  }

  Future<TtUtangRecord> recordPayment({
    required String customerId,
    required double amount,
    String? note,
  }) async {
    return addUtang(
      customerId: customerId,
      amount: -amount.abs(),
      description: note ?? 'Payment',
    );
  }

  Future<void> deleteCustomer(String id) async {
    final row = await _customerRowById(id);
    if (row == null) return;
    final syncId = row['sync_id'] as String;
    final serverId = row['server_id'] as String?;

    final db = await _db.database;
    await db.update(
      AppDatabase.ttCustomersTable,
      {
        'is_deleted': 1,
        'is_dirty': 1,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'sync_id = ?',
      whereArgs: [syncId],
    );
    if (serverId != null) unawaited(_pushDeleteCustomer(serverId, syncId));
  }

  Future<void> _pushCreateCustomer(String syncId) async {
    try {
      final db = await _db.database;
      final rows = await db.query(
        AppDatabase.ttCustomersTable,
        where: 'sync_id = ?',
        whereArgs: [syncId],
        limit: 1,
      );
      if (rows.isEmpty) return;
      final row = rows.first;

      final baseUrl = await SyncConfig.getBaseApiUrl();
      final res = await http
          .post(
            Uri.parse('$baseUrl/customers'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': row['name'],
              if ((row['phone'] as String).isNotEmpty) 'phone': row['phone'],
              if ((row['address'] as String).isNotEmpty)
                'address': row['address'],
              if ((row['notes'] as String).isNotEmpty) 'notes': row['notes'],
            }),
          )
          .timeout(_timeout);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body)['data'] as Map<String, dynamic>;
        await db.update(
          AppDatabase.ttCustomersTable,
          {'server_id': data['id'] as String, 'is_dirty': 0},
          where: 'sync_id = ?',
          whereArgs: [syncId],
        );
      }
    } catch (_) {}
  }

  Future<void> _pushUtang(
    String customerSyncId,
    String utangSyncId,
    double amount,
    String description, {
    required bool isPayment,
  }) async {
    try {
      final db = await _db.database;
      final customerRows = await db.query(
        AppDatabase.ttCustomersTable,
        where: 'sync_id = ?',
        whereArgs: [customerSyncId],
        limit: 1,
      );
      if (customerRows.isEmpty) return;
      final serverId = customerRows.first['server_id'] as String?;
      if (serverId == null) return;

      final baseUrl = await SyncConfig.getBaseApiUrl();
      final path = isPayment
          ? '$baseUrl/customers/$serverId/payment'
          : '$baseUrl/customers/$serverId/utang';

      final res = await http
          .post(
            Uri.parse(path),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'amount': amount.abs(),
              if (description.isNotEmpty) 'description': description,
              if (isPayment && description.isNotEmpty) 'note': description,
            }),
          )
          .timeout(_timeout);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body)['data'] as Map<String, dynamic>;
        await db.update(
          AppDatabase.ttUtangRecordsTable,
          {'server_id': data['id'] as String?, 'is_dirty': 0},
          where: 'sync_id = ?',
          whereArgs: [utangSyncId],
        );
      }
    } catch (_) {}
  }

  Future<void> _pushDeleteCustomer(String serverId, String syncId) async {
    try {
      final baseUrl = await SyncConfig.getBaseApiUrl();
      final res = await http
          .delete(Uri.parse('$baseUrl/customers/$serverId'))
          .timeout(_timeout);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final db = await _db.database;
        await db.update(
          AppDatabase.ttCustomersTable,
          {'is_dirty': 0},
          where: 'sync_id = ?',
          whereArgs: [syncId],
        );
      }
    } catch (_) {}
  }
}
