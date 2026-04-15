import 'package:flutter/foundation.dart';

import '../../../core/data/app_database.dart';

class ChargeBracketRecord {
  final int id;
  final int lowerBound;
  final int upperBound;
  final double chargeAmount;

  const ChargeBracketRecord({
    required this.id,
    required this.lowerBound,
    required this.upperBound,
    required this.chargeAmount,
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
    if (_hasOverlappingRange(lowerBound, upperBound)) {
      return 'This range overlaps with an existing charge bracket.';
    }

    final db = await _database.database;
    await db.insert(AppDatabase.chargesTable, {
      'lower_bound': lowerBound,
      'upper_bound': upperBound,
      'charge_amount': chargeAmount,
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
    if (_hasOverlappingRange(lowerBound, upperBound, excludedId: id)) {
      return 'This range overlaps with an existing charge bracket.';
    }

    final db = await _database.database;
    final count = await db.update(
      AppDatabase.chargesTable,
      {
        'lower_bound': lowerBound,
        'upper_bound': upperBound,
        'charge_amount': chargeAmount,
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
    final count = await db.delete(
      AppDatabase.chargesTable,
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
      orderBy: 'lower_bound ASC, upper_bound ASC',
    );
    brackets.value = rows
        .map(
          (row) => ChargeBracketRecord(
            id: (row['id'] as int?) ?? 0,
            lowerBound: (row['lower_bound'] as num).toInt(),
            upperBound: (row['upper_bound'] as num).toInt(),
            chargeAmount: (row['charge_amount'] as num).toDouble(),
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
    return null;
  }

  bool _hasOverlappingRange(int lowerBound, int upperBound, {int? excludedId}) {
    for (final bracket in brackets.value) {
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
