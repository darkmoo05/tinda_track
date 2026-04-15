import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../../core/data/app_database.dart';

class PartyRecord {
  final int id;
  final String name;
  final String accountNumber;
  final String entityId;
  final String description;
  final String joinDate;
  final bool isVerified;

  const PartyRecord({
    required this.id,
    required this.name,
    required this.accountNumber,
    required this.entityId,
    required this.description,
    required this.joinDate,
    required this.isVerified,
  });
}

class PartyRepository {
  PartyRepository._();

  static final PartyRepository instance = PartyRepository._();

  final AppDatabase _database = AppDatabase.instance;
  final DateFormat _joinDateFormat = DateFormat('MMM yyyy');
  Future<void>? _loadOperation;

  final ValueNotifier<List<PartyRecord>> parties =
      ValueNotifier<List<PartyRecord>>(const []);

  Future<void> ensureLoaded() {
    _loadOperation ??= _loadParties().catchError((
      Object error,
      StackTrace stack,
    ) {
      _loadOperation = null;
      Error.throwWithStackTrace(error, stack);
    });
    return _loadOperation!;
  }

  Future<PartyRecord?> findByAccount(String accountNumber) async {
    await ensureLoaded();
    final normalized = _normalizeAccount(accountNumber);
    if (normalized.isEmpty) {
      return null;
    }

    for (final party in parties.value) {
      if (_normalizeAccount(party.accountNumber) == normalized) {
        return party;
      }
    }
    return null;
  }

  Future<bool> registerParty({
    required String fullName,
    required String accountNumber,
  }) {
    return _registerParty(fullName: fullName, accountNumber: accountNumber);
  }

  Future<bool> _registerParty({
    required String fullName,
    required String accountNumber,
  }) async {
    await ensureLoaded();
    final normalizedAccount = _normalizeAccount(accountNumber);
    final normalizedName = fullName.trim();
    if (normalizedName.isEmpty || normalizedAccount.isEmpty) {
      return false;
    }
    if (await findByAccount(normalizedAccount) != null) {
      return false;
    }

    final db = await _database.database;
    try {
      await db.insert(AppDatabase.partiesTable, {
        'name': normalizedName,
        'account_number': normalizedAccount,
        'entity_id': _buildEntityId(normalizedAccount),
        'description': 'Newly Registered',
        'join_date': _joinDateFormat.format(DateTime.now()),
        'is_verified': 1,
      });
    } on Exception {
      return false;
    }

    _loadOperation = null;
    await _loadParties();
    return true;
  }

  Future<void> _loadParties() async {
    final db = await _database.database;
    await db.delete(
      AppDatabase.partiesTable,
      where: 'account_number IN (?, ?, ?)',
      whereArgs: const ['0012984432', '3311981021', '8800459920'],
    );
    final rows = await db.query(AppDatabase.partiesTable, orderBy: 'id ASC');

    parties.value = rows.map(_mapRow).toList(growable: false);
  }

  Future<bool> deleteParty(int id) async {
    final db = await _database.database;
    final count = await db.delete(
      AppDatabase.partiesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (count > 0) {
      _loadOperation = null;
      await _loadParties();
      return true;
    }
    return false;
  }

  Future<bool> updateParty(
    int id, {
    required String fullName,
    required String accountNumber,
  }) async {
    final normalizedAccount = _normalizeAccount(accountNumber);
    final normalizedName = fullName.trim();
    if (normalizedName.isEmpty || normalizedAccount.isEmpty) return false;

    final db = await _database.database;
    try {
      final count = await db.update(
        AppDatabase.partiesTable,
        {'name': normalizedName, 'account_number': normalizedAccount},
        where: 'id = ?',
        whereArgs: [id],
      );
      if (count > 0) {
        _loadOperation = null;
        await _loadParties();
        return true;
      }
      return false;
    } on Exception {
      return false;
    }
  }

  PartyRecord _mapRow(Map<String, Object?> row) {
    return PartyRecord(
      id: (row['id'] as int?) ?? 0,
      name: row['name'] as String,
      accountNumber: row['account_number'] as String,
      entityId: row['entity_id'] as String,
      description: row['description'] as String,
      joinDate: row['join_date'] as String,
      isVerified: ((row['is_verified'] as num?) ?? 0) == 1,
    );
  }

  String _buildEntityId(String accountNumber) {
    final digitsOnly = _normalizeAccount(accountNumber);
    final suffix = digitsOnly.length >= 3
        ? digitsOnly.substring(digitsOnly.length - 3)
        : digitsOnly.padLeft(3, '0');
    final sequence = (parties.value.length + 1).toString().padLeft(3, '0');
    return 'FA-$suffix-$sequence';
  }

  String _normalizeAccount(String accountNumber) {
    final digits = accountNumber.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.isNotEmpty ? digits : accountNumber.trim();
  }
}
