import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/app_theme.dart';
import '../../../../core/di/database_providers.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../shared/widgets/architect_app_bar.dart';
import '../../../../shared/widgets/screen_header_card.dart';
import '../../transactions/screens/add_owner_movement_screen.dart';
import '../../dashboard/data/dashboard_repository.dart';
import '../../dashboard/widgets/analytics_card.dart';

class ChargesEarningsScreen extends ConsumerStatefulWidget {
  const ChargesEarningsScreen({
    super.key,
    required this.totalEarnings,
    required this.transactionCount,
    required this.chargesToOnHand,
    required this.chargesToGcash,
    required this.chargesToMaya,
    required this.remainingWithdrawableOnHand,
    required this.remainingWithdrawableGcash,
    required this.remainingWithdrawableMaya,
    required this.remainingWithdrawableTotal,
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
  final double remainingWithdrawableOnHand;
  final double remainingWithdrawableGcash;
  final double remainingWithdrawableMaya;
  final double remainingWithdrawableTotal;
  final List<FlSpot> flowSpots;
  final List<String> flowLabels;
  final List<DateTime> flowDates;
  final List<ChargeTransaction> chargeTransactions;

  @override
  ConsumerState<ChargesEarningsScreen> createState() =>
      _ChargesEarningsScreenState();
}

class _ChargesEarningsScreenState extends ConsumerState<ChargesEarningsScreen> {
  static final _currency = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱ ',
    decimalDigits: 2,
  );
  static final _dateHeader = DateFormat('EEE, dd MMM yyyy');
  static final _timeFormat = DateFormat('HH:mm');

  String _fmt(double v) => _currency.format(v);

  int _selectedPeriod = 0;
  static const List<String> _periods = ['DAY', 'WEEK', 'MONTH', 'YEAR'];
  _HistorySourceFilter _historySourceFilter = _HistorySourceFilter.all;

  List<_FeeMovementEntry> _feeMovements = [];
  bool _isLoadingFeeMovements = true;
  int _feeMovementsTotal = 0;
  static final _movementDateTimeFormat = DateFormat('dd MMM yyyy · h:mm a');

  // Memoized fee history day groups — recomputed only when the filter changes.
  List<_DayGroup> _dayGroups = const [];

  final Set<DateTime> _expandedDays = {};
  final Map<int, GlobalKey> _dayHeaderKeys = {};

  GlobalKey _headerKeyForDay(DateTime day) {
    final key = day.millisecondsSinceEpoch;
    return _dayHeaderKeys.putIfAbsent(key, () => GlobalKey());
  }

  void _scrollDayHeaderIntoView(DateTime day, {double alignment = 0.08}) {
    final contextForHeader =
        _dayHeaderKeys[day.millisecondsSinceEpoch]?.currentContext;
    if (contextForHeader == null) {
      return;
    }

    Scrollable.ensureVisible(
      contextForHeader,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      alignment: alignment,
    );
  }

  double get _alreadyWithdrawnTotal {
    final withdrawn = widget.totalEarnings - widget.remainingWithdrawableTotal;
    return withdrawn.clamp(0.0, double.infinity).toDouble();
  }

  String _friendlyTransactionLabel(String rawTitle) {
    final lower = rawTitle.toLowerCase();
    if (lower.contains('cashin') || lower.contains('cash in')) {
      return 'Fee from Cash In';
    }
    if (lower.contains('cashout') || lower.contains('cash out')) {
      return 'Fee from Cash Out';
    }
    if (lower.contains('paybills') || lower.contains('bill')) {
      return 'Fee from Bills Payment';
    }
    if (lower.contains('load')) {
      return 'Fee from Load';
    }
    if (lower.contains('qr')) {
      return 'Fee from QR Payment';
    }
    return 'Fee from Transaction';
  }

  String _friendlyDestinationSentence(String destinationLabel) {
    return 'Fee routed to $destinationLabel';
  }

  bool _matchesSourceFilter(ChargeTransaction tx) {
    final destination = tx.chargeDestination.toLowerCase();
    switch (_historySourceFilter) {
      case _HistorySourceFilter.all:
        return true;
      case _HistorySourceFilter.gcash:
        return destination.contains('gcash');
      case _HistorySourceFilter.maya:
        return destination.contains('maya');
      case _HistorySourceFilter.onHand:
        return destination.contains('hand') || destination.contains('cash');
    }
  }

  String get _bestWithdrawalSource {
    final buckets = <String, double>{
      'GCash': widget.remainingWithdrawableGcash,
      'Maya Wallet': widget.remainingWithdrawableMaya,
      'On-hand Cash': widget.remainingWithdrawableOnHand,
    };

    var selected = 'On-hand Cash';
    var maxValue = -1.0;
    buckets.forEach((source, value) {
      if (value > maxValue) {
        maxValue = value;
        selected = source;
      }
    });
    return selected;
  }

  Future<void> _openFeeWithdrawal() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddOwnerMovementScreen(
          initialMovementType: 'Fee Withdrawal',
          initialDestination: _bestWithdrawalSource,
        ),
      ),
    );

    if (!mounted) {
      return;
    }
    if (saved == true) {
      Navigator.of(context).pop(true);
    }
  }

  // Pure computation — called once on init and whenever the filter changes.
  // Never called inside build(), so it doesn't run on every setState.
  List<_DayGroup> _computeDayGroups() {
    final map = <DateTime, List<ChargeTransaction>>{};
    for (final tx in widget.chargeTransactions) {
      if (!_matchesSourceFilter(tx)) continue;
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
  void initState() {
    super.initState();
    // Build once immediately — no setState needed since this is initState.
    _dayGroups = _computeDayGroups();
    _loadFeeMovements();
  }

  Future<void> _loadFeeMovements() async {
    final database = ref.read(appDatabaseProvider);
    final result = await database.customSelect(_feeMovementsSql).get();
    final allEntries = result
        .map((row) => _mapFeeMovementEntry(Map<String, Object?>.from(row.data)))
        .whereType<_FeeMovementEntry>()
        .toList(growable: false);

    if (!mounted) return;

    final previewEntries = allEntries.take(5).toList(growable: false);

    setState(() {
      _feeMovementsTotal = allEntries.length;
      _feeMovements = previewEntries;
      _isLoadingFeeMovements = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ArchitectAppBar(title: context.l10n.appTitle, actions: const []),
      body: CustomScrollView(
        slivers: [
          // ── Fixed top content ──────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScreenHeaderCard(
                    title: context.l10n.chargesEarnings,
                    subtitle: 'All-time charges collected from transactions',
                  ),
                  const SizedBox(height: 16),
                  _buildHeroBanner(),
                  const SizedBox(height: 14),
                  _buildWithdrawableCard(),
                  const SizedBox(height: 14),
                  _buildAnalyticsSection(),
                  const SizedBox(height: 20),
                  _buildFeeMovementLog(),
                  const SizedBox(height: 24),
                  // Fee History header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fee History',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.onSurface,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Tap a day to see each fee entry',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${_dayGroups.length} day${_dayGroups.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildSourceFilterChips(),
                  const SizedBox(height: 8),
                  _buildHistoryLegend(),
                  const SizedBox(height: 12),
                  if (_dayGroups.isEmpty) _buildEmptyState(),
                ],
              ),
            ),
          ),

          // ── Day groups — lazy, only visible headers are built ──
          if (_dayGroups.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
              sliver: SliverList.builder(
                itemCount: _dayGroups.length,
                itemBuilder: (_, i) => _buildDayGroup(_dayGroups[i]),
              ),
            )
          else
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
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

  Widget _buildWithdrawableCard() {
    final hasWithdrawable = widget.remainingWithdrawableTotal > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Remaining withdrawable earnings',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _fmt(widget.remainingWithdrawableTotal),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Already withdrawn: ${_fmt(_alreadyWithdrawnTotal)}',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildBreakdownChip('GCash', widget.remainingWithdrawableGcash),
              const SizedBox(width: 8),
              _buildBreakdownChip('Maya', widget.remainingWithdrawableMaya),
              const SizedBox(width: 8),
              _buildBreakdownChip(
                'On-hand',
                widget.remainingWithdrawableOnHand,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: hasWithdrawable ? _openFeeWithdrawal : null,
              icon: const Icon(Icons.savings_rounded),
              label: const Text('Withdraw Earnings Now'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownChip(String label, double amount) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                _fmt(amount),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceFilterChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildFilterChip(_HistorySourceFilter.all, 'All'),
        _buildFilterChip(_HistorySourceFilter.gcash, 'GCash'),
        _buildFilterChip(_HistorySourceFilter.maya, 'Maya'),
        _buildFilterChip(_HistorySourceFilter.onHand, 'On-hand'),
      ],
    );
  }

  Widget _buildFilterChip(_HistorySourceFilter value, String label) {
    final selected = _historySourceFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _historySourceFilter = value;
          _expandedDays.clear();
          // Recompute memoized groups for the new filter in the same setState
          // so build() reads the already-updated list.
          _dayGroups = _computeDayGroups();
        });
      },
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: selected ? Colors.white : AppColors.onSurface,
      ),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.outlineVariant,
      ),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildHistoryLegend() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Legend: each row shows fee source type and where the fee was routed (GCash, Maya, or On-hand).',
        style: TextStyle(
          fontSize: 11,
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.85),
          fontWeight: FontWeight.w500,
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
    final headerKey = _headerKeyForDay(group.date);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          // Day header — tap to expand / collapse
          Material(
            key: headerKey,
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
              onTap: () {
                final willExpand = !isExpanded;
                setState(() {
                  if (willExpand) {
                    _expandedDays.add(group.date);
                  } else {
                    _expandedDays.remove(group.date);
                  }
                });

                // After the frame, scroll so expanded content is visible.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  if (willExpand) {
                    // Small delay so AnimatedSize begins expanding, then scroll
                    Future.delayed(const Duration(milliseconds: 80), () {
                      if (!mounted) return;
                      _scrollDayHeaderIntoView(group.date, alignment: 0.28);
                    });
                  } else {
                    // On collapse, keep the header near top
                    _scrollDayHeaderIntoView(group.date, alignment: 0.08);
                  }
                });
              },
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
                              '$count fee entr${count == 1 ? 'y' : 'ies'}',
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _fmt(group.total),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'Total fees collected that day',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.onSurfaceVariant.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ],
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

    final friendlyTitle = _friendlyTransactionLabel(tx.title);
    final routeSentence = _friendlyDestinationSentence(destLabel);

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
                  friendlyTitle,
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
                  '${_timeFormat.format(tx.createdAt)} • $routeSentence',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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

  // ── Fee movement log ─────────────────────────────────────────

  Widget _buildFeeMovementLog() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fee Earnings Log',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Every time fee earnings were withdrawn or moved to a wallet',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (!_isLoadingFeeMovements)
              Text(
                '$_feeMovementsTotal record${_feeMovementsTotal == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (_isLoadingFeeMovements)
          const LinearProgressIndicator(minHeight: 2)
        else if (_feeMovements.isEmpty)
          _buildFeeMovementEmptyState()
        else
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              children: [
                ..._feeMovements.asMap().entries.map(
                  (e) => _buildFeeMovementEntry(
                    e.value,
                    isLast:
                        e.key == _feeMovements.length - 1 &&
                        _feeMovementsTotal <= _feeMovements.length,
                  ),
                ),
                if (_feeMovementsTotal > _feeMovements.length)
                  InkWell(
                    onTap: _showFeeMovementSheet,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: AppColors.outlineVariant,
                            width: 0.5,
                          ),
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'View all $_feeMovementsTotal records',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _showFeeMovementSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _FeeMovementSheet(),
    );
  }

  Widget _buildFeeMovementEntry(
    _FeeMovementEntry entry, {
    bool isLast = false,
  }) {
    final isWithdrawal = entry.movementType == 'Fee Withdrawal';
    final Color color = isWithdrawal
        ? AppColors.error
        : const Color(0xFFF59E0B);
    final IconData icon = isWithdrawal
        ? Icons.savings_rounded
        : Icons.swap_horiz_rounded;
    final String badgeLabel = isWithdrawal ? 'WITHDRAWN' : 'MOVED TO WALLET';

    final String sourceLabel = _feeDestLabel(entry.source);
    final String title = isWithdrawal
        ? 'Fee Withdrawn \u00b7 $sourceLabel'
        : 'Fee Transferred \u00b7 $sourceLabel \u2192 ${_feeDestLabel(entry.destination ?? '')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
      ),
      child: Row(
        children: [
          // Icon badge
          Container(
            width: 38,
            height: 38,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          // Title + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _movementDateTimeFormat.format(entry.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.65),
                  ),
                ),
                if (entry.reference.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    entry.reference,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Amount + badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _fmt(entry.amount),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _feeDestLabel(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('gcash')) return 'GCash';
    if (lower.contains('maya')) return 'Maya Wallet';
    if (lower.contains('hand') || lower.contains('cash')) return 'On-Hand Cash';
    return raw.isNotEmpty ? raw : 'Unknown';
  }

  Widget _buildFeeMovementEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(
            Icons.swap_horiz_rounded,
            size: 36,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 10),
          const Text(
            'No fee earnings yet',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'When you withdraw or transfer your fee earnings to a wallet, each movement will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────

  Widget _buildEmptyState() {
    String filterText;
    switch (_historySourceFilter) {
      case _HistorySourceFilter.gcash:
        filterText = 'No GCash fee entries in this period.';
        break;
      case _HistorySourceFilter.maya:
        filterText = 'No Maya fee entries in this period.';
        break;
      case _HistorySourceFilter.onHand:
        filterText = 'No on-hand fee entries in this period.';
        break;
      default:
        filterText = 'No fee entries in this period.';
    }
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
          Text(
            filterText,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Charge earnings from transactions will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _FeeMovementEntry {
  const _FeeMovementEntry({
    required this.createdAt,
    required this.movementType,
    required this.source,
    this.destination,
    required this.amount,
    required this.reference,
  });

  final DateTime createdAt;
  final String movementType; // 'Fee Withdrawal' or 'Fee Transfer'
  final String source; // where fee came from
  final String? destination; // only set for Fee Transfer
  final double amount;
  final String reference;
}

/// Drift-compatible query against the new `ledger_entries` table.
///
/// Aliases the integer `created_at_ms` column to ISO-formatted `created_at`
/// so the existing [_mapFeeMovementEntry] helper continues to work unchanged.
const String _feeMovementsSql = '''
  SELECT
    strftime('%Y-%m-%dT%H:%M:%fZ', created_at_ms / 1000.0, 'unixepoch')
      AS created_at,
    owner_movement_type,
    wallet_account,
    owner_party_account,
    note,
    amount,
    reference
  FROM ledger_entries
  WHERE is_deleted = 0
    AND entry_type = 'owner_movement'
    AND owner_movement_type IN (
      'Fee Withdrawal',
      'Fee Transfer',
      'Cash Transfer (On-hand to Wallet)'
    )
  ORDER BY created_at_ms DESC, id DESC
''';

_FeeMovementEntry? _mapFeeMovementEntry(Map<String, Object?> row) {
  final movementType = (row['owner_movement_type'] as String?) ?? '';
  final createdAt =
      DateTime.tryParse((row['created_at'] as String?) ?? '') ?? DateTime.now();
  final walletAccount = (row['wallet_account'] as String?) ?? '';
  final ownerPartyAccount = (row['owner_party_account'] as String?) ?? '';
  final note = (row['note'] as String?) ?? '';
  final reference = (row['reference'] as String?) ?? '';

  if (movementType == 'Fee Withdrawal') {
    return _FeeMovementEntry(
      createdAt: createdAt,
      movementType: movementType,
      source: walletAccount,
      destination: null,
      amount: (row['amount'] as num?)?.toDouble() ?? 0,
      reference: reference,
    );
  }

  if (movementType == 'Fee Transfer') {
    return _FeeMovementEntry(
      createdAt: createdAt,
      movementType: movementType,
      source: ownerPartyAccount,
      destination: walletAccount,
      amount: (row['amount'] as num?)?.toDouble() ?? 0,
      reference: reference,
    );
  }

  if (movementType == 'Cash Transfer (On-hand to Wallet)') {
    final feeAmount = _extractChargeAmountFromNote(note);
    if (feeAmount <= 0) {
      return null;
    }

    return _FeeMovementEntry(
      createdAt: createdAt,
      movementType: 'Fee Transfer',
      source: 'On-hand Cash',
      destination: walletAccount,
      amount: feeAmount,
      reference: reference,
    );
  }

  return null;
}

double _extractChargeAmountFromNote(String note) {
  final match = RegExp(
    r'Charge\s*(?:₱|PHP)?\s*([0-9]+(?:,[0-9]{3})*(?:\.[0-9]+)?)',
    caseSensitive: false,
  ).firstMatch(note);
  if (match == null || match.groupCount < 1) {
    return 0.0;
  }

  final rawAmount = (match.group(1) ?? '').replaceAll(',', '');
  return double.tryParse(rawAmount) ?? 0.0;
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

// ── Full-screen fee movement log sheet ───────────────────────

class _FeeMovementSheet extends ConsumerStatefulWidget {
  const _FeeMovementSheet();

  @override
  ConsumerState<_FeeMovementSheet> createState() => _FeeMovementSheetState();
}

class _FeeMovementSheetState extends ConsumerState<_FeeMovementSheet> {
  static final _currency = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱ ',
    decimalDigits: 2,
  );
  static final _dateHeader = DateFormat('EEE, dd MMM yyyy');
  static final _dtFormat = DateFormat('dd MMM yyyy · h:mm a');

  List<_FeeMovementEntry> _all = [];
  bool _isLoading = true;
  _FeeMovementTypeFilter _filter = _FeeMovementTypeFilter.all;
  final Set<DateTime> _expandedDays = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final database = ref.read(appDatabaseProvider);
    final result = await database.customSelect(_feeMovementsSql).get();
    if (!mounted) return;
    setState(() {
      _all = result
          .map(
            (row) => _mapFeeMovementEntry(Map<String, Object?>.from(row.data)),
          )
          .whereType<_FeeMovementEntry>()
          .toList(growable: false);
      _isLoading = false;
    });
  }

  List<_FeeMovementEntry> get _filtered {
    switch (_filter) {
      case _FeeMovementTypeFilter.withdrawals:
        return _all.where((e) => e.movementType == 'Fee Withdrawal').toList();
      case _FeeMovementTypeFilter.transfers:
        return _all.where((e) => e.movementType == 'Fee Transfer').toList();
      case _FeeMovementTypeFilter.all:
        return _all;
    }
  }

  // Groups filtered list by calendar day, newest first.
  List<MapEntry<DateTime, List<_FeeMovementEntry>>> get _dayGroups {
    final map = <DateTime, List<_FeeMovementEntry>>{};
    for (final e in _filtered) {
      final key = DateTime(
        e.createdAt.year,
        e.createdAt.month,
        e.createdAt.day,
      );
      map.putIfAbsent(key, () => []).add(e);
    }
    final days = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return days.map((d) => MapEntry(d, map[d]!)).toList();
  }

  String _fmt(double v) => _currency.format(v);

  String _label(String raw) {
    final l = raw.toLowerCase();
    if (l.contains('gcash')) return 'GCash';
    if (l.contains('maya')) return 'Maya Wallet';
    if (l.contains('hand') || l.contains('cash')) return 'On-Hand Cash';
    return raw.isNotEmpty ? raw : 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final groups = _dayGroups;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fee Earnings Log',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'All withdrawals and wallet transfers of fee earnings',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  color: AppColors.onSurfaceVariant,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _chip('All', _FeeMovementTypeFilter.all),
                const SizedBox(width: 8),
                _chip('Withdrawals', _FeeMovementTypeFilter.withdrawals),
                const SizedBox(width: 8),
                _chip('Transfers', _FeeMovementTypeFilter.transfers),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          // Scrollable content
          Flexible(
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : groups.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                    itemCount: groups.length,
                    itemBuilder: (_, i) => _buildDayGroup(groups[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, _FeeMovementTypeFilter value) {
    final selected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() {
        _filter = value;
        _expandedDays.clear();
      }),
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: selected ? Colors.white : AppColors.onSurface,
      ),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.outlineVariant,
      ),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildDayGroup(MapEntry<DateTime, List<_FeeMovementEntry>> group) {
    final day = group.key;
    final entries = group.value;
    final isExpanded = _expandedDays.contains(day);
    final count = entries.length;
    final dayTotal = entries.fold(0.0, (s, e) => s + e.amount);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          // Day header
          InkWell(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(14),
              topRight: const Radius.circular(14),
              bottomLeft: Radius.circular(isExpanded ? 0 : 14),
              bottomRight: Radius.circular(isExpanded ? 0 : 14),
            ),
            onTap: () => setState(() {
              if (isExpanded) {
                _expandedDays.remove(day);
              } else {
                _expandedDays.add(day);
              }
            }),
            child: Ink(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: Radius.circular(isExpanded ? 0 : 14),
                  bottomRight: Radius.circular(isExpanded ? 0 : 14),
                ),
                border: Border.all(
                  color: isExpanded
                      ? AppColors.primary.withValues(alpha: 0.35)
                      : AppColors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.calendar_today_rounded,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _dateHeader.format(day),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            '$count movement${count == 1 ? '' : 's'}',
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _fmt(dayTotal),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'moved that day',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.onSurfaceVariant.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),
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
          // Entries panel
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: isExpanded
                ? Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                      ),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Column(
                      children: entries
                          .asMap()
                          .entries
                          .map(
                            (e) => _buildEntry(
                              e.value,
                              isLast: e.key == entries.length - 1,
                            ),
                          )
                          .toList(),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildEntry(_FeeMovementEntry entry, {bool isLast = false}) {
    final isWithdrawal = entry.movementType == 'Fee Withdrawal';
    final Color color = isWithdrawal
        ? AppColors.error
        : const Color(0xFFF59E0B);
    final IconData icon = isWithdrawal
        ? Icons.savings_rounded
        : Icons.swap_horiz_rounded;
    final String badge = isWithdrawal ? 'WITHDRAWN' : 'MOVED TO WALLET';
    final src = _label(entry.source);
    final title = isWithdrawal
        ? 'Fee Withdrawn \u00b7 $src'
        : 'Fee Transferred \u00b7 $src \u2192 ${_label(entry.destination ?? '')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _dtFormat.format(entry.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.65),
                  ),
                ),
                if (entry.reference.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    entry.reference,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _fmt(entry.amount),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    String label;
    switch (_filter) {
      case _FeeMovementTypeFilter.withdrawals:
        label = 'withdrawals';
        break;
      case _FeeMovementTypeFilter.transfers:
        label = 'transfers';
        break;
      case _FeeMovementTypeFilter.all:
        label = 'movements';
        break;
    }
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.swap_horiz_rounded,
            size: 40,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 12),
          Text(
            'No $label recorded',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Fee earnings entries will appear here once you withdraw or transfer fee earnings.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

enum _FeeMovementTypeFilter { all, withdrawals, transfers }

enum _HistorySourceFilter { all, gcash, maya, onHand }
