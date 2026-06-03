import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/app_theme.dart';
import '../../pos/data/pos_repository.dart';

enum _DateRange { today, week, month, custom }

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  _DateRange _range = _DateRange.week;
  DateTime? _customFrom;
  DateTime? _customTo;
  late Future<ReportsData> _reportFuture;
  final _currency = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
  final _compact = NumberFormat.compactCurrency(symbol: '₱', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final (from, to) = _resolveRange();
    _reportFuture = ref
        .read(posRepositoryProvider)
        .getReports(from: from?.toIso8601String(), to: to?.toIso8601String());
  }

  (DateTime?, DateTime?) _resolveRange() {
    final now = DateTime.now();
    switch (_range) {
      case _DateRange.today:
        final start = DateTime(now.year, now.month, now.day);
        return (start, now);
      case _DateRange.week:
        final start = now.subtract(const Duration(days: 6));
        return (DateTime(start.year, start.month, start.day), now);
      case _DateRange.month:
        final start = DateTime(now.year, now.month, 1);
        return (start, now);
      case _DateRange.custom:
        return (_customFrom, _customTo ?? now);
    }
  }

  void _selectRange(_DateRange range) {
    setState(() => _range = range);
    _reload();
  }

  void _reload() {
    setState(_load);
  }

  Future<void> _pickCustomRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.secondary,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _range = _DateRange.custom;
        _customFrom = picked.start;
        _customTo = picked.end;
      });
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        title: const Text(
          'Reports',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _reload,
          ),
        ],
      ),
      body: Column(
        children: [
          // Date range chips
          Container(
            color: AppColors.secondary,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _RangeChip(
                    label: 'Today',
                    selected: _range == _DateRange.today,
                    onTap: () => _selectRange(_DateRange.today),
                  ),
                  const SizedBox(width: 8),
                  _RangeChip(
                    label: 'This Week',
                    selected: _range == _DateRange.week,
                    onTap: () => _selectRange(_DateRange.week),
                  ),
                  const SizedBox(width: 8),
                  _RangeChip(
                    label: 'This Month',
                    selected: _range == _DateRange.month,
                    onTap: () => _selectRange(_DateRange.month),
                  ),
                  const SizedBox(width: 8),
                  _RangeChip(
                    label: 'Custom',
                    selected: _range == _DateRange.custom,
                    onTap: _pickCustomRange,
                    icon: Icons.date_range_rounded,
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: FutureBuilder<ReportsData>(
              future: _reportFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.secondary,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.cloud_off_rounded,
                          size: 48,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        const Text('Could not load reports'),
                        TextButton(
                          onPressed: _reload,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                final data = snapshot.data!;
                return _buildBody(data);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ReportsData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Total Sales',
                  value: _compact.format(data.summary.totalSales),
                  icon: Icons.point_of_sale_rounded,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryCard(
                  label: 'Total Profit',
                  value: _compact.format(data.summary.totalProfit),
                  icon: Icons.trending_up_rounded,
                  color: const Color(0xFF1565C0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _SummaryCard(
            label: 'Total Transactions',
            value: data.summary.totalTransactions.toString(),
            icon: Icons.receipt_long_rounded,
            color: const Color(0xFF6A1B9A),
            wide: true,
          ),
          const SizedBox(height: 24),

          // Sales chart
          if (data.daily.isNotEmpty) ...[
            const Text(
              'Sales Over Time',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.onSurface.withValues(alpha: 0.04),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: _buildChart(data.daily),
            ),
            const SizedBox(height: 24),
          ],

          // Top products
          if (data.topProducts.isNotEmpty) ...[
            const Text(
              'Top Products',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            ...data.topProducts.asMap().entries.map(
              (entry) => _TopProductRow(
                rank: entry.key + 1,
                product: entry.value,
                currency: _currency,
                maxRevenue: data.topProducts.first.revenue,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChart(List<DailyStats> daily) {
    if (daily.isEmpty) return const SizedBox.shrink();

    final spots = daily.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.sales);
    }).toList();

    final maxY = daily.map((d) => d.sales).fold(0.0, (a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (daily.length - 1).toDouble(),
        minY: 0,
        maxY: maxY * 1.2,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 0 ? maxY / 4 : 1,
          getDrawingHorizontalLine: (_) => FlLine(
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              getTitlesWidget: (value, _) => Text(
                _compact.format(value),
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: daily.length <= 10,
              reservedSize: 24,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index < 0 || index >= daily.length) {
                  return const SizedBox.shrink();
                }
                final date = daily[index].date;
                return Text(
                  date.length >= 10 ? date.substring(5) : date,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.onSurfaceVariant,
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.secondary,
            barWidth: 2.5,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.secondary.withValues(alpha: 0.2),
                  AppColors.secondary.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _RangeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  const _RangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: selected ? AppColors.secondary : Colors.white,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.secondary : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool wide;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.04),
            blurRadius: 16,
          ),
        ],
      ),
      child: wide
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
    );
  }
}

class _TopProductRow extends StatelessWidget {
  final int rank;
  final TopProduct product;
  final NumberFormat currency;
  final double maxRevenue;

  const _TopProductRow({
    required this.rank,
    required this.product,
    required this.currency,
    required this.maxRevenue,
  });

  @override
  Widget build(BuildContext context) {
    final progress = maxRevenue > 0 ? (product.revenue / maxRevenue) : 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: rank <= 3
                      ? AppColors.secondary.withValues(alpha: 0.15)
                      : AppColors.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: rank <= 3
                          ? AppColors.secondary
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              Text(
                '${product.qty} sold',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                currency.format(product.revenue),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}
