import 'package:flutter/foundation.dart';

import '../../../core/data/app_database.dart';

class ChargeBracketRecord {
  final int id;
  final int lowerBound;
  final int upperBound;
  final double chargeAmount;
  final String transactionTypeKey;

  const ChargeBracketRecord({
    required this.id,
    required this.lowerBound,
    required this.upperBound,
    required this.chargeAmount,
    required this.transactionTypeKey,
  });
}

class ChargeRepository {
  ChargeRepository._();

  static final ChargeRepository instance = ChargeRepository._();

  final AppDatabase _database = AppDatabase.instance;
  Future<void>? _loadOperation;

  final ValueNotifier<List<ChargeBracketRecord>> brackets =
      ValueNotifier<List<ChargeBracketRecord>>(const []);

  Future<void> ensureLoaded() {
    _loadOperation ??= _loadBrackets().catchError((
      Object error,
      StackTrace stack,
    ) {
      _loadOperation = null;
      Error.throwWithStackTrace(error, stack);
    });
    return _loadOperation!;
  }

  Future<String?> addBracket({
    required int lowerBound,
    required int upperBound,
    required double chargeAmount,
    required String transactionTypeKey,
  }) async {
    final validationError = _validateRange(
      lowerBound: lowerBound,
      upperBound: upperBound,
      chargeAmount: chargeAmount,
    );
    if (validationError != null) {
      return validationError;
    }

    await ensureLoaded();
    if (_hasOverlappingRange(
      lowerBound,
      upperBound,
      typeKey: transactionTypeKey,
    )) {
      return 'This range overlaps with an existing charge bracket for this type.';
    }

    final db = await _database.database;
    final deviceId = await _database.getOrCreateDeviceId();
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    await db.insert(AppDatabase.chargesTable, {
      'lower_bound': lowerBound,
      'upper_bound': upperBound,
      'charge_amount': chargeAmount,
      AppDatabase.transactionTypeKeyColumn: transactionTypeKey,
      AppDatabase.syncIdColumn: AppDatabase.generateSyncId('charge'),
      AppDatabase.deviceIdColumn: deviceId,
      AppDatabase.updatedAtMsColumn: nowMs,
      AppDatabase.isDeletedColumn: 0,
      AppDatabase.isDirtyColumn: 1,
    });

    _loadOperation = null;
    await _loadBrackets();
    return null;
  }

  Future<String?> updateBracket(
    int id, {
    required int lowerBound,
    required int upperBound,
    required double chargeAmount,
  }) async {
    final validationError = _validateRange(
      lowerBound: lowerBound,
      upperBound: upperBound,
      chargeAmount: chargeAmount,
    );
    if (validationError != null) {
      return validationError;
    }

    await ensureLoaded();
    final existing = brackets.value.where((b) => b.id == id).firstOrNull;
    if (existing != null &&
        _hasOverlappingRange(
          lowerBound,
          upperBound,
          excludedId: id,
          typeKey: existing.transactionTypeKey,
        )) {
      return 'This range overlaps with an existing charge bracket for this type.';
    }

    final db = await _database.database;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final count = await db.update(
      AppDatabase.chargesTable,
      {
        'lower_bound': lowerBound,
        'upper_bound': upperBound,
        'charge_amount': chargeAmount,
        AppDatabase.updatedAtMsColumn: nowMs,
        AppDatabase.isDirtyColumn: 1,
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    if (count == 0) {
      return 'Unable to update the selected bracket.';
    }

    _loadOperation = null;
    await _loadBrackets();
    return null;
  }

  Future<bool> deleteBracket(int id) async {
    final db = await _database.database;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final count = await db.update(
      AppDatabase.chargesTable,
      {
        AppDatabase.isDeletedColumn: 1,
        AppDatabase.isDirtyColumn: 1,
        AppDatabase.updatedAtMsColumn: nowMs,
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    if (count == 0) {
      return false;
    }

    _loadOperation = null;
    await _loadBrackets();
    return true;
  }

  Future<void> _loadBrackets() async {
    final db = await _database.database;
    final rows = await db.query(
      AppDatabase.chargesTable,
      where: '${AppDatabase.isDeletedColumn} = 0',
      orderBy:
          '${AppDatabase.transactionTypeKeyColumn} ASC, lower_bound ASC, upper_bound ASC',
    );
    brackets.value = rows
        .map(
          (row) => ChargeBracketRecord(
            id: (row['id'] as int?) ?? 0,
            lowerBound: (row['lower_bound'] as num).toInt(),
            upperBound: (row['upper_bound'] as num).toInt(),
            chargeAmount: (row['charge_amount'] as num).toDouble(),
            transactionTypeKey:
                (row[AppDatabase.transactionTypeKeyColumn] as String?) ??
                'gcash_cashin',
          ),
        )
        .toList(growable: false);
  }

  String? _validateRange({
    required int lowerBound,
    required int upperBound,
    required double chargeAmount,
  }) {
    if (lowerBound <= 0) {
      return 'Lower bound must be greater than zero.';
    }
    if (upperBound < lowerBound) {
      return 'Upper bound must be greater than or equal to lower bound.';
    }
    if (chargeAmount < 0) {
      return 'Charge amount cannot be negative.';
    }
    final maxAllowed = upperBound * 0.5;
    if (chargeAmount > maxAllowed) {
      return 'Charge amount cannot exceed 50% of the upper bound '
          '(max ₱${maxAllowed.toStringAsFixed(2)} for a ₱$upperBound upper bound).';
    }
    return null;
  }

  bool _hasOverlappingRange(
    int lowerBound,
    int upperBound, {
    int? excludedId,
    required String typeKey,
  }) {
    for (final bracket in brackets.value) {
      if (bracket.transactionTypeKey != typeKey) continue;
      if (excludedId != null && bracket.id == excludedId) {
        continue;
      }
      final overlaps =
          lowerBound <= bracket.upperBound && upperBound >= bracket.lowerBound;
      if (overlaps) {
        return true;
      }
    }
    return false;
  }
}
