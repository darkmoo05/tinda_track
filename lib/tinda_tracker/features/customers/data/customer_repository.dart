import 'package:drift/drift.dart' show Variable;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/app_meta_dao.dart';
import '../../../../core/di/database_providers.dart';
import 'customer_model.dart';

/// Riverpod provider for the local-first customer repository.
final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository(database: ref.watch(appDatabaseProvider));
});

/// Local-first customer repository (Drift-backed). Background push is handled
/// by `SyncOrchestrator` via `is_dirty` flags — this layer only writes to
/// SQLite.
class CustomerRepository {
  CustomerRepository({required AppDatabase database})
    : _database = database,
      _appMeta = AppMetaDao(database);

  final AppDatabase _database;
  final AppMetaDao _appMeta;
  static const _uuid = Uuid();

  static const String _createdAtAlias =
      "strftime('%Y-%m-%dT%H:%M:%fZ', created_at_ms / 1000.0, 'unixepoch') "
      "AS created_at";

  Future<List<Map<String, Object?>>> _selectRows(
    String sql, {
    List<Variable> variables = const [],
  }) async {
    final result = await _database
        .customSelect(sql, variables: variables)
        .get();
    return result
        .map((row) => Map<String, Object?>.from(row.data))
        .toList(growable: false);
  }

  Future<Map<String, Object?>?> _customerRowById(String id) async {
    final rows = await _selectRows(
      'SELECT id, id AS sync_id, id AS server_id, name, phone, address, notes '
      'FROM customers WHERE id = ? LIMIT 1',
      variables: [Variable<String>(id)],
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<TtCustomer> _buildCustomer(Map<String, Object?> row) async {
    final customerId = row['id'] as String;
    final utangRows = await _selectRows(
      'SELECT id, id AS sync_id, id AS server_id, description, amount, '
      "$_createdAtAlias "
      'FROM utang_records WHERE customer_id = ? '
      'AND COALESCE(is_deleted, 0) = 0 '
      'ORDER BY created_at_ms ASC',
      variables: [Variable<String>(customerId)],
    );
    final records = utangRows
        .map((r) => TtUtangRecord.fromLocalDb(r, customerId))
        .toList();
    // Customers table no longer carries a `balance` column; derive it from
    // utang records and inject for the legacy fromLocalDb factory.
    final balance = records.fold<double>(0, (sum, r) => sum + r.amount);
    final rowWithBalance = <String, Object?>{...row, 'balance': balance};
    return TtCustomer.fromLocalDb(rowWithBalance, records);
  }

  Future<List<TtCustomer>> listCustomers() async {
    final rows = await _selectRows(
      'SELECT id, id AS sync_id, id AS server_id, name, phone, address, notes '
      'FROM customers WHERE COALESCE(is_deleted, 0) = 0 '
      'ORDER BY name ASC',
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
    final id = _uuid.v4();
    final deviceId = await _appMeta.getOrCreateDeviceId();
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    await _database.customStatement(
      'INSERT INTO customers ('
      'id, name, phone, address, notes, '
      'sync_id, device_id, is_deleted, is_dirty, '
      'created_at_ms, updated_at_ms'
      ') VALUES (?,?,?,?,?,?,?,0,1,?,?)',
      [
        id,
        name,
        phone ?? '',
        address ?? '',
        notes ?? '',
        id,
        deviceId,
        nowMs,
        nowMs,
      ],
    );

    final row = await _customerRowById(id);
    return _buildCustomer(row!);
  }

  Future<TtUtangRecord> addUtang({
    required String customerId,
    required double amount,
    required String description,
  }) async {
    final row = await _customerRowById(customerId);
    if (row == null) throw Exception('Customer not found: $customerId');
    final canonicalCustomerId = row['id'] as String;

    final id = _uuid.v4();
    final deviceId = await _appMeta.getOrCreateDeviceId();
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    await _database.transaction(() async {
      await _database.customStatement(
        'INSERT INTO utang_records ('
        'id, customer_id, description, amount, '
        'sync_id, device_id, is_deleted, is_dirty, '
        'created_at_ms, updated_at_ms'
        ') VALUES (?,?,?,?,?,?,0,1,?,?)',
        [
          id,
          canonicalCustomerId,
          description,
          amount,
          id,
          deviceId,
          nowMs,
          nowMs,
        ],
      );
      // Touch the customer so it gets re-pushed by sync (balance is derived).
      await _database.customStatement(
        'UPDATE customers SET is_dirty = 1, updated_at_ms = ? WHERE id = ?',
        [nowMs, canonicalCustomerId],
      );
    });

    final newUtangRows = await _selectRows(
      'SELECT id, id AS sync_id, id AS server_id, description, amount, '
      "$_createdAtAlias "
      'FROM utang_records WHERE id = ? LIMIT 1',
      variables: [Variable<String>(id)],
    );
    return TtUtangRecord.fromLocalDb(newUtangRows.first, canonicalCustomerId);
  }

  Future<TtUtangRecord> recordPayment({
    required String customerId,
    required double amount,
    String? note,
  }) {
    return addUtang(
      customerId: customerId,
      amount: -amount.abs(),
      description: note ?? 'Payment',
    );
  }

  Future<void> deleteCustomer(String id) async {
    final row = await _customerRowById(id);
    if (row == null) return;
    final canonicalId = row['id'] as String;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    await _database.customStatement(
      'UPDATE customers SET is_deleted = 1, is_dirty = 1, updated_at_ms = ? '
      'WHERE id = ?',
      [nowMs, canonicalId],
    );
  }
}
