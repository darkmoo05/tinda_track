import 'package:drift/drift.dart' show Variable;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'statement_entry.dart';

import '../../../../core/app_theme.dart';
import '../../../../core/database/app_database.dart';

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.walletBalance,
    required this.mayaWalletBalance,
    required this.onHandCash,
    required this.businessWalletBalance,
    required this.businessMayaWalletBalance,
    required this.businessOnHandCash,
    required this.businessUsableCash,
    required this.recordedFlow,
    required this.businessFundingTotal,
    required this.personalExpenseTotal,
    required this.personalExpenseAmount,
    required this.personalExpensePaymentAmount,
    required this.personalExpenseOutstanding,
    required this.ownerCreditAdjustment,
    required this.flowTrendLabel,
    required this.flowCaption,
    required this.chargesToOnHand,
    required this.chargesToGcash,
    required this.chargesToMaya,
    required this.remainingWithdrawableOnHand,
    required this.remainingWithdrawableGcash,
    required this.remainingWithdrawableMaya,
    required this.remainingWithdrawableTotal,
    required this.transactionCount,
    required this.alertTitle,
    required this.alertMessage,
    required this.alertActionLabel,
    required this.showAlertCard,
    required this.activities,
    required this.chargeTransactions,
    required this.walletSpots,
    required this.mayaSpots,
    required this.cashSpots,
    required this.flowSpots,
    required this.flowLabels,
    required this.flowDates,
    required this.xLabels,
  });

  final double walletBalance;
  final double mayaWalletBalance;
  final double onHandCash;
  final double businessWalletBalance;
  final double businessMayaWalletBalance;
  final double businessOnHandCash;
  final double businessUsableCash;
  final double recordedFlow;
  final double businessFundingTotal;
  final double personalExpenseTotal;
  final double personalExpenseAmount;
  final double personalExpensePaymentAmount;
  final double personalExpenseOutstanding;
  final double ownerCreditAdjustment;
  final String flowTrendLabel;
  final String flowCaption;
  final double chargesToOnHand;
  final double chargesToGcash;
  final double chargesToMaya;
  final double remainingWithdrawableOnHand;
  final double remainingWithdrawableGcash;
  final double remainingWithdrawableMaya;
  final double remainingWithdrawableTotal;
  final int transactionCount;
  final String alertTitle;
  final String alertMessage;
  final String alertActionLabel;
  final bool showAlertCard;
  final List<DashboardActivity> activities;
  final List<ChargeTransaction> chargeTransactions;
  final List<FlSpot> walletSpots;
  final List<FlSpot> mayaSpots;
  final List<FlSpot> cashSpots;
  final List<FlSpot> flowSpots;
  final List<String> flowLabels;
  final List<DateTime> flowDates;
  final List<String> xLabels;
}

class DashboardActivity {
  const DashboardActivity({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.tag,
    required this.scope,
    required this.createdAt,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String subtitle;
  final String amount;
  final String tag;
  final String scope;
  final DateTime createdAt;
  final IconData icon;
  final Color iconColor;
}

class ChargeTransaction {
  const ChargeTransaction({
    required this.title,
    required this.createdAt,
    required this.chargeAmount,
    required this.chargeDestination,
  });

  final String title;
  final DateTime createdAt;
  final double chargeAmount;
  final String chargeDestination;
}

class DashboardRepository {
  DashboardRepository({required AppDatabase database}) : _database = database;

  final AppDatabase _database;
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱ ',
    decimalDigits: 2,
  );
  final DateFormat _activityDateFormat = DateFormat('dd MMM yyyy');
  final DateFormat _chartDateFormat = DateFormat('dd MMM');
  static const double _lowBalanceRatio = 0.10;

  // SQL alias used everywhere downstream: synthesize a `created_at` ISO
  // string from the new `created_at_ms` column so this file's row-map
  // logic can stay unchanged after the Drift migration.
  static const String _createdAtAlias =
      "strftime('%Y-%m-%dT%H:%M:%fZ', created_at_ms / 1000.0, 'unixepoch') AS created_at";

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

  Future<List<StatementEntry>> loadStatementEntries() async {
    final rows = await _selectRows(
      "SELECT amount, owner_movement_type, note, $_createdAtAlias "
      "FROM ledger_entries "
      "WHERE entry_type = 'owner_movement' "
      "AND owner_movement_type IS NOT NULL "
      "ORDER BY created_at_ms DESC, id DESC",
    );

    final entries = <StatementEntry>[];
    for (final row in rows) {
      final movementType = ((row['owner_movement_type'] as String?) ?? '')
          .trim();
      if (movementType.isEmpty) {
        continue;
      }

      final normalizedType = movementType.toLowerCase();
      final isDebit =
          normalizedType == 'personal expense' ||
          normalizedType == 'borrowed funds';
      final isRepayment =
          normalizedType == 'personal expense payment' ||
          normalizedType == 'borrowed funds repayment';

      if (!isDebit && !isRepayment) {
        continue;
      }

      final createdAtRaw = row['created_at'] as String?;
      final createdAt = createdAtRaw == null
          ? null
          : DateTime.tryParse(createdAtRaw);
      final amount = (row['amount'] as num?)?.toDouble() ?? 0;

      entries.add(
        StatementEntry(
          date: createdAt == null ? '' : _activityDateFormat.format(createdAt),
          createdAt: createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
          type: movementType,
          amount: '${isRepayment ? '-' : '+'}${formatCurrency(amount)}',
          amountColor: isRepayment ? AppColors.secondary : AppColors.error,
          note: (row['note'] as String?)?.trim(),
        ),
      );
    }

    return entries;
  }

  Future<DashboardSnapshot> loadSnapshot() async {
    final rows = await _selectRows(
      "SELECT *, $_createdAtAlias FROM ledger_entries "
      "WHERE COALESCE(is_deleted, 0) = 0 "
      "ORDER BY created_at_ms ASC, id ASC",
    );
    final feeRows = await _selectRows(
      "SELECT related_transaction_sync_id, fee_amount, charge_destination, "
      "$_createdAtAlias "
      "FROM fee_transactions "
      "WHERE COALESCE(is_deleted, 0) = 0",
    );

    double walletBalance = 0;
    double mayaWalletBalance = 0;
    double onHandCash = 0;
    double businessWalletBalance = 0;
    double businessMayaWalletBalance = 0;
    double businessOnHandCash = 0;
    double walletTopUpBaseline = 0;
    double mayaWalletTopUpBaseline = 0;
    double onHandTopUpBaseline = 0;
    double chargesCollected = 0;
    double chargesToOnHand = 0;
    double chargesToGcash = 0;
    double chargesToMaya = 0;
    double businessFundingTotal = 0;
    double personalExpenseTotal = 0;
    double personalExpenseAmount = 0;
    double personalExpensePaymentAmount = 0;
    int transactionCount = 0;

    final walletSpots = <FlSpot>[];
    final mayaSpots = <FlSpot>[];
    final cashSpots = <FlSpot>[];
    final flowSpots = <FlSpot>[];
    final flowLabels = <String>[];
    final flowDates = <DateTime>[];
    final xLabels = <String>[];
    final chargesByDay = <DateTime, double>{};
    final chargeTransactions = <ChargeTransaction>[];
    final walletClosingByDay = <DateTime, double>{};
    final mayaWalletClosingByDay = <DateTime, double>{};
    final cashClosingByDay = <DateTime, double>{};
    final transactionById = <String, Map<String, Object?>>{};
    final feeIncomeEventsBySource = <String, List<_FeeLedgerEvent>>{
      'on_hand': <_FeeLedgerEvent>[],
      'gcash': <_FeeLedgerEvent>[],
      'maya': <_FeeLedgerEvent>[],
    };
    final feeWithdrawalEventsBySource = <String, List<_FeeLedgerEvent>>{
      'on_hand': <_FeeLedgerEvent>[],
      'gcash': <_FeeLedgerEvent>[],
      'maya': <_FeeLedgerEvent>[],
    };

    for (final row in rows) {
      final walletDelta = (row['wallet_delta'] as num).toDouble();
      final mayaWalletDelta =
          (row['maya_wallet_delta'] as num?)?.toDouble() ?? 0.0;
      final onHandDelta = (row['on_hand_delta'] as num).toDouble();
      walletBalance += walletDelta;
      mayaWalletBalance += mayaWalletDelta;
      onHandCash += onHandDelta;
      final createdAt = DateTime.parse(row['created_at'] as String);
      final dayKey = DateTime(createdAt.year, createdAt.month, createdAt.day);
      walletClosingByDay[dayKey] = walletBalance;
      mayaWalletClosingByDay[dayKey] = mayaWalletBalance;
      cashClosingByDay[dayKey] = onHandCash;

      final entryType = (row['entry_type'] as String?) ?? '';
      final ownerScope = ((row['owner_scope'] as String?) ?? 'Business')
          .toLowerCase();
      final isPersonalOwnerMovement =
          entryType == 'owner_movement' && ownerScope == 'personal';

      if (!isPersonalOwnerMovement) {
        businessWalletBalance += walletDelta;
        businessMayaWalletBalance += mayaWalletDelta;
        businessOnHandCash += onHandDelta;
      }

      if (_isTopUpBaselineEntry(row)) {
        final walletDelta = (row['wallet_delta'] as num).toDouble();
        final onHandDelta = (row['on_hand_delta'] as num).toDouble();
        if (walletDelta > 0) {
          walletTopUpBaseline += walletDelta;
        }
        if (mayaWalletDelta > 0) {
          mayaWalletTopUpBaseline += mayaWalletDelta;
        }
        if (onHandDelta > 0) {
          onHandTopUpBaseline += onHandDelta;
        }
      }

      if (entryType == 'owner_movement') {
        final movementType = ((row['owner_movement_type'] as String?) ?? '')
            .toLowerCase();
        final amount = (row['amount'] as num).toDouble();

        if (movementType == 'initial capital' || movementType == 'top-up') {
          businessFundingTotal += amount;
        }

        if (ownerScope == 'personal' ||
            movementType == 'personal expense' ||
            movementType == 'borrowed funds') {
          personalExpenseTotal += amount;
        }

        // Track borrowed-funds-only totals
        if (movementType == 'personal expense' ||
            movementType == 'borrowed funds') {
          personalExpenseAmount += amount;
        }

        if (movementType == 'personal expense payment' ||
            movementType == 'borrowed funds repayment') {
          personalExpensePaymentAmount += amount;
        }

        if (movementType == 'fee withdrawal' ||
            movementType == 'fee transfer') {
          final withdrawalSource = _resolveFeeMovementSource(row, movementType);
          final sourceKey = _normalizeWalletKey(withdrawalSource);
          if (sourceKey == 'on_hand' ||
              sourceKey == 'gcash' ||
              sourceKey == 'maya') {
            feeWithdrawalEventsBySource[sourceKey]!.add(
              _FeeLedgerEvent(
                timestampMs: createdAt.millisecondsSinceEpoch,
                amount: amount,
              ),
            );
          }
        } else if (movementType == 'cash transfer (on-hand to wallet)') {
          final transferredFeeAmount = _extractChargeAmount(row);
          if (transferredFeeAmount > 0) {
            feeWithdrawalEventsBySource['on_hand']!.add(
              _FeeLedgerEvent(
                timestampMs: createdAt.millisecondsSinceEpoch,
                amount: transferredFeeAmount,
              ),
            );
          }
        }
      }

      if (entryType == 'transaction') {
        final transactionSyncId = ((row['sync_id'] as String?) ?? '').trim();
        if (transactionSyncId.isNotEmpty) {
          transactionById[transactionSyncId] = row;
        }
        transactionCount++;
      }
    }

    final linkedTransactionIds = <String>{};
    var feeRowsProcessed = 0;
    var feeRowsInferredDestination = 0;
    var feeRowsUnknownDestination = 0;
    var qrFeeRows = 0;
    var qrFeeAmount = 0.0;
    for (final feeRow in feeRows) {
      final feeAmount = (feeRow['fee_amount'] as num?)?.toDouble() ?? 0.0;
      if (feeAmount <= 0) {
        continue;
      }
      feeRowsProcessed++;

      final relatedTransactionSyncId =
          ((feeRow['related_transaction_sync_id'] as String?) ?? '').trim();
      if (relatedTransactionSyncId.isNotEmpty) {
        linkedTransactionIds.add(relatedTransactionSyncId);
      }

      final destinationRaw = ((feeRow['charge_destination'] as String?) ?? '')
          .trim();
      var destinationKey = _normalizeWalletKey(destinationRaw);
      if (destinationKey.isEmpty && relatedTransactionSyncId.isNotEmpty) {
        final relatedTx = transactionById[relatedTransactionSyncId];
        if (relatedTx != null) {
          destinationKey = _inferFeeDestinationFromTransaction(relatedTx);
          if (destinationKey.isNotEmpty) {
            feeRowsInferredDestination++;
          }
        }
      }
      if (destinationKey.isEmpty) {
        feeRowsUnknownDestination++;
      }

      final relatedTx = relatedTransactionSyncId.isEmpty
          ? null
          : transactionById[relatedTransactionSyncId];
      final createdAtRaw = (feeRow['created_at'] as String?)?.trim();
      final createdAt =
          (createdAtRaw == null || createdAtRaw.isEmpty
              ? null
              : DateTime.tryParse(createdAtRaw)) ??
          DateTime.tryParse((relatedTx?['created_at'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);

      chargesCollected += feeAmount;
      if (destinationKey == 'maya') {
        chargesToMaya += feeAmount;
        feeIncomeEventsBySource['maya']!.add(
          _FeeLedgerEvent(
            timestampMs: createdAt.millisecondsSinceEpoch,
            amount: feeAmount,
          ),
        );
      } else if (destinationKey == 'gcash') {
        chargesToGcash += feeAmount;
        feeIncomeEventsBySource['gcash']!.add(
          _FeeLedgerEvent(
            timestampMs: createdAt.millisecondsSinceEpoch,
            amount: feeAmount,
          ),
        );
      } else {
        chargesToOnHand += feeAmount;
        feeIncomeEventsBySource['on_hand']!.add(
          _FeeLedgerEvent(
            timestampMs: createdAt.millisecondsSinceEpoch,
            amount: feeAmount,
          ),
        );
      }

      final relatedIconKey = ((relatedTx?['icon_key'] as String?) ?? '')
          .toLowerCase();
      final relatedTitle = ((relatedTx?['title'] as String?) ?? '')
          .toLowerCase();
      if (relatedIconKey.contains('out') || relatedTitle.contains('qr')) {
        qrFeeRows++;
        qrFeeAmount += feeAmount;
      }
      final dayKey = DateTime(createdAt.year, createdAt.month, createdAt.day);
      chargesByDay.update(
        dayKey,
        (current) => current + feeAmount,
        ifAbsent: () => feeAmount,
      );

      final destinationLabel = destinationRaw.isNotEmpty
          ? destinationRaw
          : _displayWalletLabel(destinationKey);
      chargeTransactions.add(
        ChargeTransaction(
          title: (relatedTx?['title'] as String?) ?? 'Transaction',
          createdAt: createdAt,
          chargeAmount: feeAmount,
          chargeDestination: destinationLabel,
        ),
      );
    }

    // Conservative legacy fallback: include only rows with explicit
    // "Charge ..." markers when no fee_transactions row is linked.
    for (final entry in transactionById.entries) {
      if (linkedTransactionIds.contains(entry.key)) {
        continue;
      }

      final row = entry.value;
      final chargeAmount = _extractChargeAmount(row);
      if (chargeAmount <= 0) {
        continue;
      }

      final destinationRaw = _extractChargeDestination(row);
      final destinationKey = _normalizeWalletKey(destinationRaw);
      final createdAt = DateTime.parse(row['created_at'] as String);

      chargesCollected += chargeAmount;
      if (destinationKey == 'maya') {
        chargesToMaya += chargeAmount;
        feeIncomeEventsBySource['maya']!.add(
          _FeeLedgerEvent(
            timestampMs: createdAt.millisecondsSinceEpoch,
            amount: chargeAmount,
          ),
        );
      } else if (destinationKey == 'gcash') {
        chargesToGcash += chargeAmount;
        feeIncomeEventsBySource['gcash']!.add(
          _FeeLedgerEvent(
            timestampMs: createdAt.millisecondsSinceEpoch,
            amount: chargeAmount,
          ),
        );
      } else {
        chargesToOnHand += chargeAmount;
        feeIncomeEventsBySource['on_hand']!.add(
          _FeeLedgerEvent(
            timestampMs: createdAt.millisecondsSinceEpoch,
            amount: chargeAmount,
          ),
        );
      }

      final dayKey = DateTime(createdAt.year, createdAt.month, createdAt.day);
      chargesByDay.update(
        dayKey,
        (current) => current + chargeAmount,
        ifAbsent: () => chargeAmount,
      );

      chargeTransactions.add(
        ChargeTransaction(
          title: (row['title'] as String?) ?? 'Transaction',
          createdAt: createdAt,
          chargeAmount: chargeAmount,
          chargeDestination: destinationRaw,
        ),
      );
    }

    if (walletClosingByDay.isNotEmpty ||
        mayaWalletClosingByDay.isNotEmpty ||
        cashClosingByDay.isNotEmpty) {
      final sortedDays = {
        ...walletClosingByDay.keys,
        ...mayaWalletClosingByDay.keys,
        ...cashClosingByDay.keys,
      }.toList()..sort();

      final firstDay = sortedDays.first;
      final lastDay = sortedDays.last;
      var dayCursor = firstDay;
      var pointIndex = 0;
      var currentWalletBalance = 0.0;
      var currentMayaWalletBalance = 0.0;
      var currentCashBalance = 0.0;

      while (!dayCursor.isAfter(lastDay)) {
        currentWalletBalance =
            walletClosingByDay[dayCursor] ?? currentWalletBalance;
        currentMayaWalletBalance =
            mayaWalletClosingByDay[dayCursor] ?? currentMayaWalletBalance;
        currentCashBalance = cashClosingByDay[dayCursor] ?? currentCashBalance;

        walletSpots.add(
          FlSpot(pointIndex.toDouble(), currentWalletBalance / 1000),
        );
        mayaSpots.add(
          FlSpot(pointIndex.toDouble(), currentMayaWalletBalance / 1000),
        );
        cashSpots.add(FlSpot(pointIndex.toDouble(), currentCashBalance / 1000));
        xLabels.add(_chartDateFormat.format(dayCursor));

        dayCursor = dayCursor.add(const Duration(days: 1));
        pointIndex++;
      }
    }

    if (chargesByDay.isNotEmpty) {
      final sortedDays = chargesByDay.keys.toList()..sort();
      final firstDay = sortedDays.first;
      final lastDay = sortedDays.last;
      var dayCursor = firstDay;
      var index = 0;
      while (!dayCursor.isAfter(lastDay)) {
        final dailyCharge = chargesByDay[dayCursor] ?? 0;
        flowSpots.add(FlSpot(index.toDouble(), dailyCharge / 1000));
        flowLabels.add(_chartDateFormat.format(dayCursor));
        flowDates.add(dayCursor);
        dayCursor = dayCursor.add(const Duration(days: 1));
        index++;
      }
    }

    final activities = rows.reversed.map(_mapActivity).toList(growable: false);
    final alertContent = _buildAlertContent(
      walletBalance: walletBalance,
      mayaWalletBalance: mayaWalletBalance,
      walletTopUpBaseline: walletTopUpBaseline,
      mayaWalletTopUpBaseline: mayaWalletTopUpBaseline,
      onHandCash: onHandCash,
      onHandTopUpBaseline: onHandTopUpBaseline,
    );

    final ownerCreditAdjustment =
        personalExpensePaymentAmount - personalExpenseAmount;
    final remainingWithdrawableOnHand = _reconcileRemainingFeeBalance(
      incomeEvents: feeIncomeEventsBySource['on_hand']!,
      withdrawalEvents: feeWithdrawalEventsBySource['on_hand']!,
    );
    final remainingWithdrawableGcash = _reconcileRemainingFeeBalance(
      incomeEvents: feeIncomeEventsBySource['gcash']!,
      withdrawalEvents: feeWithdrawalEventsBySource['gcash']!,
    );
    final remainingWithdrawableMaya = _reconcileRemainingFeeBalance(
      incomeEvents: feeIncomeEventsBySource['maya']!,
      withdrawalEvents: feeWithdrawalEventsBySource['maya']!,
    );
    final remainingWithdrawableTotal =
        remainingWithdrawableOnHand +
        remainingWithdrawableGcash +
        remainingWithdrawableMaya;

    final computedChargeTxSum = chargeTransactions.fold<double>(
      0,
      (sum, tx) => sum + tx.chargeAmount,
    );
    final alreadyWithdrawn = (chargesCollected - remainingWithdrawableTotal)
        .clamp(0.0, double.infinity)
        .toDouble();
    assert(() {
      debugPrint(
        '[DashboardSnapshot sanity] '
        'chargesCollected=${chargesCollected.toStringAsFixed(2)} '
        'chargeTxSum=${computedChargeTxSum.toStringAsFixed(2)} '
        'remainingWithdrawable=${remainingWithdrawableTotal.toStringAsFixed(2)} '
        'alreadyWithdrawn=${alreadyWithdrawn.toStringAsFixed(2)}',
      );
      debugPrint(
        '[DashboardSnapshot fee rows] '
        'rows=${feeRows.length} '
        'processed=$feeRowsProcessed '
        'inferredDestination=$feeRowsInferredDestination '
        'unknownDestination=$feeRowsUnknownDestination '
        'qrRows=$qrFeeRows '
        'qrAmount=${qrFeeAmount.toStringAsFixed(2)} '
        'incomeEventsOnHand=${feeIncomeEventsBySource['on_hand']!.length} '
        'incomeEventsGcash=${feeIncomeEventsBySource['gcash']!.length} '
        'incomeEventsMaya=${feeIncomeEventsBySource['maya']!.length} '
        'withdrawEventsOnHand=${feeWithdrawalEventsBySource['on_hand']!.length} '
        'withdrawEventsGcash=${feeWithdrawalEventsBySource['gcash']!.length} '
        'withdrawEventsMaya=${feeWithdrawalEventsBySource['maya']!.length} '
        'bucketOnHand=${chargesToOnHand.toStringAsFixed(2)} '
        'bucketGcash=${chargesToGcash.toStringAsFixed(2)} '
        'bucketMaya=${chargesToMaya.toStringAsFixed(2)}',
      );
      return true;
    }());

    return DashboardSnapshot(
      walletBalance: walletBalance,
      mayaWalletBalance: mayaWalletBalance,
      onHandCash: onHandCash,
      businessWalletBalance: businessWalletBalance,
      businessMayaWalletBalance: businessMayaWalletBalance,
      businessOnHandCash: businessOnHandCash,
      businessUsableCash:
          businessWalletBalance +
          businessMayaWalletBalance +
          businessOnHandCash +
          ownerCreditAdjustment,
      recordedFlow: chargesCollected,
      businessFundingTotal: businessFundingTotal,
      personalExpenseTotal: personalExpenseTotal,
      personalExpenseAmount: personalExpenseAmount,
      personalExpensePaymentAmount: personalExpensePaymentAmount,
      personalExpenseOutstanding:
          personalExpenseAmount - personalExpensePaymentAmount,
      ownerCreditAdjustment: ownerCreditAdjustment,
      flowTrendLabel: '$transactionCount transactions',
      flowCaption:
          'Charges routed • On-hand: ${formatCurrency(chargesToOnHand)} • GCash: ${formatCurrency(chargesToGcash)} • Maya: ${formatCurrency(chargesToMaya)}',
      chargesToOnHand: chargesToOnHand,
      chargesToGcash: chargesToGcash,
      chargesToMaya: chargesToMaya,
      remainingWithdrawableOnHand: remainingWithdrawableOnHand,
      remainingWithdrawableGcash: remainingWithdrawableGcash,
      remainingWithdrawableMaya: remainingWithdrawableMaya,
      remainingWithdrawableTotal: remainingWithdrawableTotal,
      transactionCount: transactionCount,
      alertTitle: alertContent.title,
      alertMessage: alertContent.message,
      alertActionLabel: alertContent.actionLabel,
      showAlertCard: alertContent.show,
      activities: activities,
      chargeTransactions: chargeTransactions,
      walletSpots: walletSpots,
      mayaSpots: mayaSpots,
      cashSpots: cashSpots,
      flowSpots: flowSpots,
      flowLabels: flowLabels,
      flowDates: flowDates,
      xLabels: xLabels,
    );
  }

  double _extractChargeAmount(Map<String, Object?> row) {
    final note = (row['note'] as String?) ?? '';
    final match = RegExp(
      r'Charge\s*(?:₱|PHP)?\s*([0-9]+(?:,[0-9]{3})*(?:\.[0-9]+)?)',
      caseSensitive: false,
    ).firstMatch(note);
    if (match == null || match.groupCount < 1) {
      return 0;
    }
    return double.tryParse((match.group(1) ?? '').replaceAll(',', '')) ?? 0;
  }

  String _resolveFeeMovementSource(
    Map<String, Object?> row,
    String movementType,
  ) {
    if (movementType == 'fee transfer') {
      final explicitSource = ((row['owner_party_account'] as String?) ?? '')
          .trim()
          .toLowerCase();
      if (explicitSource.isNotEmpty) {
        return explicitSource;
      }

      // Legacy fallback for older rows without explicit fee source.
      final title = ((row['title'] as String?) ?? '').toLowerCase();
      final onHandDelta = (row['on_hand_delta'] as num?)?.toDouble() ?? 0;
      if (title.contains('from on-hand cash') || onHandDelta < 0) {
        return 'on-hand cash';
      }
    }

    return ((row['wallet_account'] as String?) ?? '').trim().toLowerCase();
  }

  String _extractChargeDestination(Map<String, Object?> row) {
    final note = (row['note'] as String?) ?? '';
    final match = RegExp(
      r'Charge\s+routed\s+to\s*([^•]+)',
      caseSensitive: false,
    ).firstMatch(note);
    if (match == null || match.groupCount < 1) {
      return 'on-hand cash';
    }
    return (match.group(1) ?? '').trim().toLowerCase();
  }

  String _normalizeWalletKey(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) {
      return '';
    }

    final compact = normalized.replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (compact.contains('gcash')) {
      return 'gcash';
    }
    if (compact.contains('maya')) {
      return 'maya';
    }
    if (compact.contains('onhand') ||
        compact.contains('cashonhand') ||
        compact.contains('drawer') ||
        compact.contains('cashdrawer') ||
        compact.contains('cash') ||
        compact.contains('cashsakamot') ||
        compact.contains('cashsakamay') ||
        compact.contains('kamot') ||
        compact.contains('kamay')) {
      return 'on_hand';
    }

    return normalized;
  }

  String _displayWalletLabel(String destinationKey) {
    switch (destinationKey) {
      case 'gcash':
        return 'GCash';
      case 'maya':
        return 'Maya Wallet';
      default:
        return 'On-hand Cash';
    }
  }

  String _inferFeeDestinationFromTransaction(Map<String, Object?> row) {
    final iconKey = ((row['icon_key'] as String?) ?? '').toLowerCase();
    if (iconKey.contains('out')) {
      final walletAccount = ((row['wallet_account'] as String?) ?? '').trim();
      return _normalizeWalletKey(walletAccount);
    }
    return 'on_hand';
  }

  double _reconcileRemainingFeeBalance({
    required List<_FeeLedgerEvent> incomeEvents,
    required List<_FeeLedgerEvent> withdrawalEvents,
  }) {
    if (incomeEvents.isEmpty) {
      return 0.0;
    }

    final events = <(int timestampMs, bool isIncome, double amount)>[];
    for (final event in incomeEvents) {
      if (event.amount > 0) {
        events.add((event.timestampMs, true, event.amount));
      }
    }
    for (final event in withdrawalEvents) {
      if (event.amount > 0) {
        events.add((event.timestampMs, false, event.amount));
      }
    }

    events.sort((a, b) {
      final tsCompare = a.$1.compareTo(b.$1);
      if (tsCompare != 0) {
        return tsCompare;
      }
      // Apply income before withdrawal when timestamps are equal.
      if (a.$2 == b.$2) {
        return 0;
      }
      return a.$2 ? -1 : 1;
    });

    var available = 0.0;
    for (final event in events) {
      if (event.$2) {
        available += event.$3;
      } else {
        final applied = event.$3 > available ? available : event.$3;
        available -= applied;
      }
    }

    return available.clamp(0.0, double.infinity).toDouble();
  }

  _DashboardAlertContent _buildAlertContent({
    required double walletBalance,
    required double mayaWalletBalance,
    required double walletTopUpBaseline,
    required double mayaWalletTopUpBaseline,
    required double onHandCash,
    required double onHandTopUpBaseline,
  }) {
    final gcashThreshold = walletTopUpBaseline * _lowBalanceRatio;
    final mayaThreshold = mayaWalletTopUpBaseline * _lowBalanceRatio;
    final onHandThreshold = onHandTopUpBaseline * _lowBalanceRatio;

    final gcashLow = walletTopUpBaseline > 0 && walletBalance <= gcashThreshold;
    final mayaLow =
        mayaWalletTopUpBaseline > 0 && mayaWalletBalance <= mayaThreshold;
    final walletLow = gcashLow || mayaLow;
    final onHandLow = onHandTopUpBaseline > 0 && onHandCash <= onHandThreshold;
    final lowWalletMessages = <String>[
      if (gcashLow)
        _buildWalletAlertLine(
          walletName: 'GCash',
          balance: walletBalance,
          threshold: gcashThreshold,
          baseline: walletTopUpBaseline,
        ),
      if (mayaLow)
        _buildWalletAlertLine(
          walletName: 'Maya',
          balance: mayaWalletBalance,
          threshold: mayaThreshold,
          baseline: mayaWalletTopUpBaseline,
        ),
    ];

    if (walletLow && onHandLow) {
      final onHandTopUpNeeded =
          (onHandTopUpBaseline - onHandCash).clamp(0, double.infinity)
              as double;

      return _DashboardAlertContent(
        show: true,
        title: 'Critical Float Alert',
        message:
            '${lowWalletMessages.join('\n')}\nOn-hand Cash: ${formatCurrency(onHandCash)} available, minimum float ${formatCurrency(onHandThreshold)} from baseline ${formatCurrency(onHandTopUpBaseline)}. Add ${formatCurrency(onHandTopUpNeeded)} to restore float.',
        actionLabel: 'RESTOCK FUNDS',
      );
    }

    if (walletLow) {
      final actionLabel = switch ((gcashLow, mayaLow)) {
        (true, false) => 'LOAD GCASH WALLET',
        (false, true) => 'LOAD MAYA WALLET',
        _ => 'LOAD WALLET',
      };

      return _DashboardAlertContent(
        show: true,
        title: 'Low Wallet Balance',
        message: lowWalletMessages.join('\n'),
        actionLabel: actionLabel,
      );
    }

    if (onHandLow) {
      return _DashboardAlertContent(
        show: true,
        title: 'Low On-Hand Cash',
        message:
            'On-hand cash is down to ${formatCurrency(onHandCash)} (10% of top-up baseline: ${formatCurrency(onHandThreshold)}). Add cash to keep payouts smooth.',
        actionLabel: 'ADD CASH',
      );
    }

    return const _DashboardAlertContent(
      show: false,
      title: '',
      message: '',
      actionLabel: '',
    );
  }

  String _buildWalletAlertLine({
    required String walletName,
    required double balance,
    required double threshold,
    required double baseline,
  }) {
    final topUpNeeded =
        (baseline - balance).clamp(0, double.infinity) as double;
    return '$walletName: ${formatCurrency(balance)} available, minimum float ${formatCurrency(threshold)} from baseline ${formatCurrency(baseline)}. Top up ${formatCurrency(topUpNeeded)} to restore the baseline.';
  }

  bool _isTopUpBaselineEntry(Map<String, Object?> row) {
    if ((row['entry_type'] as String?) != 'owner_movement') {
      return false;
    }

    final movementType = ((row['owner_movement_type'] as String?) ?? '')
        .toLowerCase();
    final title = ((row['title'] as String?) ?? '').toLowerCase();
    final note = ((row['note'] as String?) ?? '').toLowerCase();
    final reference = ((row['reference'] as String?) ?? '').toLowerCase();

    return movementType == 'top-up' ||
        movementType == 'initial capital' ||
        title.contains('top-up') ||
        title.contains('initial capital') ||
        note.contains('startup') ||
        reference.startsWith('top-') ||
        reference.startsWith('cap-');
  }

  String formatCurrency(double value) => _currencyFormat.format(value);

  DashboardActivity _mapActivity(Map<String, Object?> row) {
    final createdAt = DateTime.parse(row['created_at'] as String);
    final amount = (row['amount'] as num).toDouble();
    final iconKey = row['icon_key'] as String;
    final entryType = row['entry_type'] as String;
    final reference = row['reference'] as String;
    final walletAccount = (row['wallet_account'] as String?)?.trim();
    final ownerPartyName = (row['owner_party_name'] as String?)?.trim() ?? '';
    final ownerScope = (row['owner_scope'] as String?)?.trim();
    final subtitleRef = entryType == 'transaction'
        ? _resolveTransactionAccountNumber(row)
        : ownerPartyName.isNotEmpty
        ? '$ownerPartyName • $reference'
        : reference;
    final scope = entryType == 'owner_movement'
        ? ((ownerScope == null || ownerScope.isEmpty) ? 'Business' : ownerScope)
        : 'Business';

    // Wallet perspective: cash_in drains wallet (−, red), cash_out grows wallet (+, green).
    // Non-transaction entries keep the original sign convention.
    final bool isNegative;
    final Color activityColor;
    if (entryType == 'transaction') {
      isNegative = iconKey == 'cash_in' || iconKey == 'maya_cash_in';
      activityColor = isNegative ? AppColors.error : AppColors.secondary;
    } else {
      isNegative = iconKey == 'cash_out';
      activityColor = _colorFor(iconKey);
    }

    // For transactions, show the net amount (excluding the store's service fee)
    // using the delta columns, which already reflect the actual money movement.
    final double displayAmount;
    if (entryType == 'transaction') {
      final walletDelta = (row['wallet_delta'] as num?)?.toDouble() ?? 0;
      final mayaWalletDelta =
          (row['maya_wallet_delta'] as num?)?.toDouble() ?? 0;
      final onHandDelta = (row['on_hand_delta'] as num?)?.toDouble() ?? 0;
      final walletOrMayaAbs = walletDelta != 0
          ? walletDelta.abs()
          : mayaWalletDelta.abs();
      final onHandAbs = onHandDelta.abs();
      displayAmount = (walletOrMayaAbs > 0 && onHandAbs > 0)
          ? (walletOrMayaAbs < onHandAbs ? walletOrMayaAbs : onHandAbs)
          : amount;
    } else {
      displayAmount = amount;
    }

    return DashboardActivity(
      title: row['title'] as String,
      subtitle:
          '${walletAccount != null && walletAccount.isNotEmpty ? '$walletAccount • ' : ''}$subtitleRef • ${_activityDateFormat.format(createdAt)}',
      amount:
          '${isNegative ? '-' : '+'}${_currencyFormat.format(displayAmount)}',
      tag: _activityTag(row),
      scope: scope,
      createdAt: createdAt,
      icon: _iconFor(iconKey),
      iconColor: activityColor,
    );
  }

  String _activityTag(Map<String, Object?> row) {
    final entryType = row['entry_type'] as String? ?? '';
    if (entryType != 'owner_movement') {
      return (row['tag'] as String?) ?? 'Business';
    }

    final movementType = ((row['owner_movement_type'] as String?) ?? '').trim();
    final ownerScope = ((row['owner_scope'] as String?) ?? 'Business').trim();

    if (movementType.isEmpty) {
      return ownerScope;
    }

    return '$ownerScope • $movementType';
  }

  String _resolveTransactionAccountNumber(Map<String, Object?> row) {
    final reference = row['reference'] as String;
    final numericRef = reference.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericRef.isNotEmpty) {
      return numericRef;
    }

    final note = (row['note'] as String?) ?? '';
    final match = RegExp(
      r'Account\s*([0-9]+)',
      caseSensitive: false,
    ).firstMatch(note);
    if (match != null && match.groupCount >= 1) {
      return match.group(1) ?? reference;
    }

    return reference;
  }

  IconData _iconFor(String iconKey) {
    switch (iconKey) {
      case 'wallet':
        return Icons.account_balance_wallet_outlined;
      case 'maya_wallet':
        return Icons.wallet_rounded;
      case 'cash':
        return Icons.payments_outlined;
      case 'cash_in':
        return Icons.arrow_circle_up_rounded;
      case 'cash_out':
        return Icons.arrow_circle_down_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  Color _colorFor(String iconKey) {
    switch (iconKey) {
      case 'wallet':
        return AppColors.primary;
      case 'maya_wallet':
        return AppColors.secondary;
      case 'cash':
        return AppColors.secondary;
      case 'cash_in':
        return AppColors.secondary;
      case 'cash_out':
        return AppColors.error;
      default:
        return AppColors.onSurfaceVariant;
    }
  }
}

class _DashboardAlertContent {
  const _DashboardAlertContent({
    required this.show,
    required this.title,
    required this.message,
    required this.actionLabel,
  });

  final bool show;
  final String title;
  final String message;
  final String actionLabel;
}

class _FeeLedgerEvent {
  const _FeeLedgerEvent({required this.timestampMs, required this.amount});

  final int timestampMs;
  final double amount;
}
