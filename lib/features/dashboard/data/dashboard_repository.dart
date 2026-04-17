import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/app_theme.dart';
import '../../../core/data/app_database.dart';

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.walletBalance,
    required this.onHandCash,
    required this.businessWalletBalance,
    required this.businessOnHandCash,
    required this.businessUsableCash,
    required this.recordedFlow,
    required this.businessFundingTotal,
    required this.personalExpenseTotal,
    required this.totalBorrowed,
    required this.totalRepaid,
    required this.ownerCreditAdjustment,
    required this.netBorrowOutstanding,
    required this.flowTrendLabel,
    required this.flowCaption,
    required this.alertTitle,
    required this.alertMessage,
    required this.alertActionLabel,
    required this.showAlertCard,
    required this.activities,
    required this.walletSpots,
    required this.cashSpots,
    required this.flowSpots,
    required this.flowLabels,
    required this.flowDates,
    required this.xLabels,
  });

  final double walletBalance;
  final double onHandCash;
  final double businessWalletBalance;
  final double businessOnHandCash;
  final double businessUsableCash;
  final double recordedFlow;
  final double businessFundingTotal;
  final double personalExpenseTotal;
  final double totalBorrowed;
  final double totalRepaid;
  final double ownerCreditAdjustment;
  final double netBorrowOutstanding;
  final String flowTrendLabel;
  final String flowCaption;
  final String alertTitle;
  final String alertMessage;
  final String alertActionLabel;
  final bool showAlertCard;
  final List<DashboardActivity> activities;
  final List<FlSpot> walletSpots;
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

class DashboardRepository {
  DashboardRepository({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱ ',
    decimalDigits: 2,
  );
  final DateFormat _activityDateFormat = DateFormat('dd MMM yyyy');
  final DateFormat _chartDateFormat = DateFormat('dd MMM');
  static const double _lowBalanceRatio = 0.10;

  Future<DashboardSnapshot> loadSnapshot() async {
    final db = await _database.database;
    final rows = await db.query(
      AppDatabase.ledgerTable,
      orderBy: 'created_at ASC, id ASC',
    );

    double walletBalance = 0;
    double onHandCash = 0;
    double businessWalletBalance = 0;
    double businessOnHandCash = 0;
    double walletTopUpBaseline = 0;
    double onHandTopUpBaseline = 0;
    double chargesCollected = 0;
    double businessFundingTotal = 0;
    double personalExpenseTotal = 0;
    double totalBorrowed = 0;
    double totalRepaid = 0;
    int transactionCount = 0;

    final walletSpots = <FlSpot>[];
    final cashSpots = <FlSpot>[];
    final flowSpots = <FlSpot>[];
    final flowLabels = <String>[];
    final flowDates = <DateTime>[];
    final xLabels = <String>[];
    final chargesByDay = <DateTime, double>{};
    final walletClosingByDay = <DateTime, double>{};
    final cashClosingByDay = <DateTime, double>{};

    for (final row in rows) {
      final walletDelta = (row['wallet_delta'] as num).toDouble();
      final onHandDelta = (row['on_hand_delta'] as num).toDouble();
      walletBalance += walletDelta;
      onHandCash += onHandDelta;
      final createdAt = DateTime.parse(row['created_at'] as String);
      final dayKey = DateTime(createdAt.year, createdAt.month, createdAt.day);
      walletClosingByDay[dayKey] = walletBalance;
      cashClosingByDay[dayKey] = onHandCash;

      final entryType = (row['entry_type'] as String?) ?? '';
      final ownerScope = ((row['owner_scope'] as String?) ?? 'Business')
          .toLowerCase();
      final isPersonalOwnerMovement =
          entryType == 'owner_movement' && ownerScope == 'personal';

      if (!isPersonalOwnerMovement) {
        businessWalletBalance += walletDelta;
        businessOnHandCash += onHandDelta;
      }

      if (_isTopUpBaselineEntry(row)) {
        final walletDelta = (row['wallet_delta'] as num).toDouble();
        final onHandDelta = (row['on_hand_delta'] as num).toDouble();
        if (walletDelta > 0) {
          walletTopUpBaseline += walletDelta;
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

        if (ownerScope == 'personal' || movementType == 'personal expense') {
          personalExpenseTotal += amount;
        }

        if (movementType == 'borrowing' || movementType == 'personal expense') {
          totalBorrowed += amount;
        }

        if (movementType == 'repayment') {
          totalRepaid += amount;
        }
      }

      if (entryType == 'transaction') {
        final chargeAmount = _extractChargeAmount(row);
        chargesCollected += chargeAmount;
        transactionCount++;
        chargesByDay.update(
          dayKey,
          (current) => current + chargeAmount,
          ifAbsent: () => chargeAmount,
        );
      }
    }

    if (walletClosingByDay.isNotEmpty || cashClosingByDay.isNotEmpty) {
      final sortedDays = {
        ...walletClosingByDay.keys,
        ...cashClosingByDay.keys,
      }.toList()..sort();

      final firstDay = sortedDays.first;
      final lastDay = sortedDays.last;
      var dayCursor = firstDay;
      var pointIndex = 0;
      var currentWalletBalance = 0.0;
      var currentCashBalance = 0.0;

      while (!dayCursor.isAfter(lastDay)) {
        currentWalletBalance =
            walletClosingByDay[dayCursor] ?? currentWalletBalance;
        currentCashBalance = cashClosingByDay[dayCursor] ?? currentCashBalance;

        walletSpots.add(
          FlSpot(pointIndex.toDouble(), currentWalletBalance / 1000),
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
      walletTopUpBaseline: walletTopUpBaseline,
      onHandCash: onHandCash,
      onHandTopUpBaseline: onHandTopUpBaseline,
    );

    final ownerCreditAdjustment = totalRepaid - totalBorrowed;

    return DashboardSnapshot(
      walletBalance: walletBalance,
      onHandCash: onHandCash,
      businessWalletBalance: businessWalletBalance,
      businessOnHandCash: businessOnHandCash,
      businessUsableCash:
          businessWalletBalance + businessOnHandCash + ownerCreditAdjustment,
      recordedFlow: chargesCollected,
      businessFundingTotal: businessFundingTotal,
      personalExpenseTotal: personalExpenseTotal,
      totalBorrowed: totalBorrowed,
      totalRepaid: totalRepaid,
      ownerCreditAdjustment: ownerCreditAdjustment,
      netBorrowOutstanding: totalBorrowed - totalRepaid,
      flowTrendLabel: '$transactionCount transactions',
      flowCaption: 'Total amount collected on charges',
      alertTitle: alertContent.title,
      alertMessage: alertContent.message,
      alertActionLabel: alertContent.actionLabel,
      showAlertCard: alertContent.show,
      activities: activities,
      walletSpots: walletSpots,
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
      r'Charge\s*₱\s*([0-9]+(?:\.[0-9]+)?)',
      caseSensitive: false,
    ).firstMatch(note);
    if (match == null || match.groupCount < 1) {
      return 0;
    }
    return double.tryParse(match.group(1)!) ?? 0;
  }

  _DashboardAlertContent _buildAlertContent({
    required double walletBalance,
    required double walletTopUpBaseline,
    required double onHandCash,
    required double onHandTopUpBaseline,
  }) {
    final walletThreshold = walletTopUpBaseline * _lowBalanceRatio;
    final onHandThreshold = onHandTopUpBaseline * _lowBalanceRatio;

    final walletLow =
        walletTopUpBaseline > 0 && walletBalance <= walletThreshold;
    final onHandLow = onHandTopUpBaseline > 0 && onHandCash <= onHandThreshold;

    if (walletLow && onHandLow) {
      return _DashboardAlertContent(
        show: true,
        title: 'Critical Float Alert',
        message:
            'GCash wallet (${formatCurrency(walletBalance)}) and on-hand cash (${formatCurrency(onHandCash)}) are at or below 10% of your top-up baseline. Reload both floats immediately.',
        actionLabel: 'RESTOCK FUNDS',
      );
    }

    if (walletLow) {
      return _DashboardAlertContent(
        show: true,
        title: 'Low GCash Wallet Balance',
        message:
            'GCash wallet is down to ${formatCurrency(walletBalance)} (10% of top-up baseline: ${formatCurrency(walletThreshold)}). Please load wallet funds.',
        actionLabel: 'LOAD WALLET',
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
    final isOutgoing = iconKey == 'cash_out';
    final reference = row['reference'] as String;
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

    return DashboardActivity(
      title: row['title'] as String,
      subtitle: '$subtitleRef • ${_activityDateFormat.format(createdAt)}',
      amount: '${isOutgoing ? '-' : '+'}${_currencyFormat.format(amount)}',
      tag: _activityTag(row),
      scope: scope,
      createdAt: createdAt,
      icon: _iconFor(iconKey),
      iconColor: _colorFor(iconKey),
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
      return match.group(1)!;
    }

    return reference;
  }

  IconData _iconFor(String iconKey) {
    switch (iconKey) {
      case 'wallet':
        return Icons.account_balance_wallet_outlined;
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
