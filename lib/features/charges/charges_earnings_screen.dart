import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/app_theme.dart';
import '../../core/l10n_extension.dart';
import '../../shared/widgets/architect_app_bar.dart';
import '../dashboard/data/dashboard_repository.dart';
import '../dashboard/widgets/analytics_card.dart';

class ChargesEarningsScreen extends StatefulWidget {
  const ChargesEarningsScreen({
    super.key,
    required this.totalEarnings,
    required this.transactionCount,
    required this.chargesToOnHand,
    required this.chargesToGcash,
    required this.chargesToMaya,
    required this.flowSpots,
    required this.flowLabels,
    required this.flowDates,
    required this.chargeTransactions,
  });

  final double totalEarnings;
  final int transactionCount;
  final double chargesToOnHand;
  final double chargesToGcash;
  final double chargesToMaya;
  final List<FlSpot> flowSpots;
  final List<String> flowLabels;
  final List<DateTime> flowDates;
  final List<ChargeTransaction> chargeTransactions;

  @override
  State<ChargesEarningsScreen> createState() => _ChargesEarningsScreenState();
}

class _ChargesEarningsScreenState extends State<ChargesEarningsScreen> {
  static final _currency = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱ ',
    decimalDigits: 2,
  );
  static final _dateHeader = DateFormat('EEE, dd MMM yyyy');
  static final _timeFormat = DateFormat('HH:mm');

  String _fmt(double v) => _currency.format(v);

  // No longer needed as a getter — routing shown inline in hero.

  int _selectedPeriod = 0;
  static const List<String> _periods = ['DAY', 'WEEK', 'MONTH', 'YEAR'];

  final Set<DateTime> _expandedDays = {};

  List<_DayGroup> _buildDayGroups() {
    final map = <DateTime, List<ChargeTransaction>>{};
    for (final tx in widget.chargeTransactions) {
      final key = DateTime(
        tx.createdAt.year,
        tx.createdAt.month,
        tx.createdAt.day,
      );
      map.putIfAbsent(key, () => []).add(tx);
    }
    final days = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return days.map((day) {
      final txs = map[day]!..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final total = txs.fold(0.0, (sum, t) => sum + t.chargeAmount);
      return _DayGroup(date: day, transactions: txs, total: total);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dayGroups = _buildDayGroups();

    return Scaffold(
      appBar: ArchitectAppBar(
        title: context.l10n.appTitle,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton.filledTonal(
              tooltip: context.l10n.goBack,
              onPressed: () => Navigator.of(context).pop(),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surfaceContainerLow,
              ),
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          Text(
            context.l10n.chargesEarnings,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'All-time charges collected from transactions',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),
          _buildHeroBanner(),
          const SizedBox(height: 20),
          _buildAnalyticsSection(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction History',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Tap a day to see each transaction',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${dayGroups.length} day${dayGroups.length == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (dayGroups.isEmpty)
            _buildEmptyState()
          else
            ...dayGroups.map(_buildDayGroup),
        ],
      ),
    );
  }

  // ── Hero banner ───────────────────────────────────────────────

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), AppColors.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryContainer.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          const Text(
            'Total service fee earned',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          // Big total
          Text(
            _fmt(widget.totalEarnings),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          // Period filter — moved from the chart card
          Row(
            children: [
              const Text(
                'View by',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedPeriod,
                      isDense: true,
                      borderRadius: BorderRadius.circular(12),
                      dropdownColor: AppColors.primaryContainer,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white70,
                        size: 18,
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      items: List.generate(_periods.length, (i) {
                        return DropdownMenuItem<int>(
                          value: i,
                          child: Text(_periods[i]),
                        );
                      }),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedPeriod = v);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Where the money went — inline routing chips
          const Text(
            'Where did the charges go?',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildHeroChip(
                label: context.l10n.onHand,
                amount: widget.chargesToOnHand,
                icon: Icons.payments_outlined,
              ),
              const SizedBox(width: 8),
              _buildHeroChip(
                label: context.l10n.gcash,
                amount: widget.chargesToGcash,
                icon: Icons.account_balance_wallet_rounded,
              ),
              const SizedBox(width: 8),
              _buildHeroChip(
                label: context.l10n.maya,
                amount: widget.chargesToMaya,
                icon: Icons.account_balance_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroChip({
    required String label,
    required double amount,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white70, size: 12),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                _fmt(amount),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Analytics chart ──────────────────────────────────────────

  Widget _buildAnalyticsSection() {
    final safeLength = [
      widget.flowSpots.length,
      widget.flowLabels.length,
      widget.flowDates.length,
    ].reduce((a, b) => a < b ? a : b);

    if (safeLength == 0) {
      return _buildChartPlaceholder();
    }

    return ArchitectAnalyticsCard(
      title: context.l10n.dailyEarningsTrend,
      value: _fmt(widget.totalEarnings),
      trend: '${widget.transactionCount} transactions',
      subtitle: '',
      showStats: false,
      selectedPeriod: _selectedPeriod,
      onPeriodChanged: (v) => setState(() => _selectedPeriod = v),
      spots: widget.flowSpots.take(safeLength).toList(growable: false),
      xLabels: widget.flowLabels.take(safeLength).toList(growable: false),
      dates: widget.flowDates.take(safeLength).toList(growable: false),
    );
  }

  Widget _buildChartPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Charges Collected',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Charges analytics will appear after transactions are added.',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  // ── Day group (expandable) ────────────────────────────────────

  Widget _buildDayGroup(_DayGroup group) {
    final isExpanded = _expandedDays.contains(group.date);
    final count = group.transactions.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          // Day header — tap to expand / collapse
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isExpanded ? 0 : 16),
              bottomRight: Radius.circular(isExpanded ? 0 : 16),
            ),
            child: InkWell(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isExpanded ? 0 : 16),
                bottomRight: Radius.circular(isExpanded ? 0 : 16),
              ),
              onTap: () => setState(() {
                if (isExpanded) {
                  _expandedDays.remove(group.date);
                } else {
                  _expandedDays.add(group.date);
                }
              }),
              child: Ink(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isExpanded ? 0 : 16),
                    bottomRight: Radius.circular(isExpanded ? 0 : 16),
                  ),
                  border: Border.all(
                    color: isExpanded
                        ? AppColors.primaryContainer.withValues(alpha: 0.45)
                        : AppColors.outlineVariant.withValues(alpha: 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.onSurface.withValues(alpha: 0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.calendar_today_rounded,
                          color: AppColors.primaryContainer,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _dateHeader.format(group.date),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$count transaction${count == 1 ? '' : 's'}',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.onSurfaceVariant.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _fmt(group.total),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Sub-transaction panel
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: isExpanded
                ? Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      border: Border.all(
                        color: AppColors.primaryContainer.withValues(
                          alpha: 0.45,
                        ),
                      ),
                    ),
                    child: Column(
                      children: group.transactions
                          .map(_buildSubTransaction)
                          .toList(),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTransaction(ChargeTransaction tx) {
    final dest = tx.chargeDestination.toLowerCase();
    final Color chipColor;
    final IconData chipIcon;
    final String destLabel;

    if (dest.contains('maya')) {
      chipColor = AppColors.secondary;
      chipIcon = Icons.account_balance_rounded;
      destLabel = context.l10n.maya;
    } else if (dest.contains('gcash')) {
      chipColor = AppColors.primary;
      chipIcon = Icons.account_balance_wallet_rounded;
      destLabel = context.l10n.gcash;
    } else {
      chipColor = const Color(0xFF8E6C00);
      chipIcon = Icons.payments_outlined;
      destLabel = context.l10n.onHand;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: Row(
        children: [
          // Wallet icon badge
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: chipColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(chipIcon, color: chipColor, size: 16),
          ),
          // Title + time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _timeFormat.format(tx.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          // Amount + routing label
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _fmt(tx.chargeAmount),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: chipColor,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(chipIcon, color: chipColor, size: 11),
                  const SizedBox(width: 3),
                  Text(
                    destLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: chipColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 40,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          const Text(
            'No charges yet',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Charge earnings from transactions\nwill appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayGroup {
  const _DayGroup({
    required this.date,
    required this.transactions,
    required this.total,
  });
  final DateTime date;
  final List<ChargeTransaction> transactions;
  final double total;
}
