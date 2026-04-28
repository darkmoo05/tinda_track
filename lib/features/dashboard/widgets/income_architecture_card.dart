import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/app_theme.dart';

enum _TimePeriod { week, month, year }

class IncomeArchitectureCard extends StatefulWidget {
  const IncomeArchitectureCard({
    super.key,
    this.walletSpots,
    this.mayaSpots,
    this.cashSpots,
    this.xLabels,
  });

  final List<FlSpot>? walletSpots;
  final List<FlSpot>? mayaSpots;
  final List<FlSpot>? cashSpots;
  final List<String>? xLabels;

  @override
  State<IncomeArchitectureCard> createState() => _IncomeArchitectureCardState();
}

class _IncomeArchitectureCardState extends State<IncomeArchitectureCard> {
  // GCash trend data points (value in thousands PHP)
  final List<FlSpot> _gcashSpots = const [
    FlSpot(0, 12.5),
    FlSpot(1, 13.8),
    FlSpot(2, 11.2),
    FlSpot(3, 14.9),
    FlSpot(4, 13.1),
    FlSpot(5, 14.25),
  ];

  // Cash on-hand trend data points
  final List<FlSpot> _cashSpots = const [
    FlSpot(0, 2.8),
    FlSpot(1, 3.5),
    FlSpot(2, 2.2),
    FlSpot(3, 4.1),
    FlSpot(4, 3.0),
    FlSpot(5, 3.42),
  ];

  // Maya trend data points
  final List<FlSpot> _mayaSpots = const [
    FlSpot(0, 1.2),
    FlSpot(1, 1.4),
    FlSpot(2, 1.1),
    FlSpot(3, 1.6),
    FlSpot(4, 1.5),
    FlSpot(5, 1.8),
  ];

  final List<String> _xLabels = const [
    '1 Oct',
    '7 Oct',
    '14 Oct',
    '21 Oct',
    '28 Oct',
    'Today',
  ];

  late _TimePeriod _selectedPeriod;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedPeriod = _TimePeriod.month;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  (List<FlSpot>, List<FlSpot>, List<FlSpot>, List<String>) _filterDataByPeriod(
    List<FlSpot> walletSpots,
    List<FlSpot> mayaSpots,
    List<FlSpot> cashSpots,
    List<String> xLabels,
  ) {
    if (walletSpots.isEmpty || xLabels.isEmpty) {
      return (walletSpots, mayaSpots, cashSpots, xLabels);
    }

    final dataLength = xLabels.length;

    switch (_selectedPeriod) {
      case _TimePeriod.week:
        // Show last 7 days
        final startIdx = (dataLength - 7).clamp(0, dataLength);
        final endIdx = dataLength;
        return _sliceData(
          walletSpots,
          mayaSpots,
          cashSpots,
          xLabels,
          startIdx,
          endIdx,
        );
      case _TimePeriod.month:
        // Show all data (default to month view)
        return (walletSpots, mayaSpots, cashSpots, xLabels);
      case _TimePeriod.year:
        // Aggregate data to show weekly averages for the year
        return _aggregateToWeekly(walletSpots, mayaSpots, cashSpots, xLabels);
    }
  }

  (List<FlSpot>, List<FlSpot>, List<FlSpot>, List<String>) _sliceData(
    List<FlSpot> walletSpots,
    List<FlSpot> mayaSpots,
    List<FlSpot> cashSpots,
    List<String> xLabels,
    int startIdx,
    int endIdx,
  ) {
    return (
      walletSpots.skip(startIdx).take(endIdx - startIdx).toList(),
      mayaSpots.skip(startIdx).take(endIdx - startIdx).toList(),
      cashSpots.skip(startIdx).take(endIdx - startIdx).toList(),
      xLabels.skip(startIdx).take(endIdx - startIdx).toList(),
    );
  }

  (List<FlSpot>, List<FlSpot>, List<FlSpot>, List<String>) _aggregateToWeekly(
    List<FlSpot> walletSpots,
    List<FlSpot> mayaSpots,
    List<FlSpot> cashSpots,
    List<String> xLabels,
  ) {
    final weeklyWallet = <FlSpot>[];
    final weeklyMaya = <FlSpot>[];
    final weeklyCash = <FlSpot>[];
    final weeklyLabels = <String>[];

    for (int i = 0; i < walletSpots.length; i += 7) {
      final weekEnd = (i + 7).clamp(0, walletSpots.length);
      final walletWeek = walletSpots.sublist(i, weekEnd);
      final mayaWeek = mayaSpots.sublist(i, weekEnd);
      final cashWeek = cashSpots.sublist(i, weekEnd);

      if (walletWeek.isNotEmpty) {
        final avgWallet =
            walletWeek.map((s) => s.y).reduce((a, b) => a + b) /
            walletWeek.length;
        final avgMaya =
            mayaWeek.map((s) => s.y).reduce((a, b) => a + b) / mayaWeek.length;
        final avgCash =
            cashWeek.map((s) => s.y).reduce((a, b) => a + b) / cashWeek.length;

        final newIndex = weeklyWallet.length.toDouble();
        weeklyWallet.add(FlSpot(newIndex, avgWallet));
        weeklyMaya.add(FlSpot(newIndex, avgMaya));
        weeklyCash.add(FlSpot(newIndex, avgCash));
        weeklyLabels.add('W${(i ~/ 7) + 1}');
      }
    }

    return (weeklyWallet, weeklyMaya, weeklyCash, weeklyLabels);
  }

  Widget _buildTimePeriodFilter() {
    return Row(
      children: [
        _buildPeriodButton('Week', _TimePeriod.week),
        const SizedBox(width: 8),
        _buildPeriodButton('Month', _TimePeriod.month),
        const SizedBox(width: 8),
        _buildPeriodButton('Year', _TimePeriod.year),
      ],
    );
  }

  Widget _buildPeriodButton(String label, _TimePeriod period) {
    final isSelected = _selectedPeriod == period;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedPeriod = period;
              // Auto-scroll to start when period changes
              Future.delayed(const Duration(milliseconds: 100), () {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              });
            });
          }
        },
        backgroundColor: Colors.transparent,
        selectedColor: AppColors.primary.withValues(alpha: 0.3),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildScrollableChart(
    List<FlSpot> walletSpots,
    List<FlSpot> mayaSpots,
    List<FlSpot> cashSpots,
    List<String> xLabels,
  ) {
    // Calculate minimum chart width based on data points
    final minChartWidth = (xLabels.length * 50.0).clamp(280.0, double.infinity);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: minChartWidth,
        height: 240,
        child: LineChart(
          _buildChartData(walletSpots, mayaSpots, cashSpots, xLabels),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletSpots = widget.walletSpots ?? _gcashSpots;
    final mayaSpots = widget.mayaSpots ?? _mayaSpots;
    final cashSpots = widget.cashSpots ?? _cashSpots;
    final xLabels = widget.xLabels ?? _xLabels;

    // Filter data based on selected time period
    final (
      filteredWalletSpots,
      filteredMayaSpots,
      filteredCashSpots,
      filteredXLabels,
    ) = _filterDataByPeriod(
      walletSpots,
      mayaSpots,
      cashSpots,
      xLabels,
    );

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 12),
            _buildTimePeriodFilter(),
            const SizedBox(height: 16),
            _buildLegend(),
            const SizedBox(height: 20),
            _buildScrollableChart(
              filteredWalletSpots,
              filteredMayaSpots,
              filteredCashSpots,
              filteredXLabels,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wallet and Cash Balance Trend',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Daily closing balances for GCash, Maya, and on-hand cash',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _legendDot(AppColors.primary, 'GCash'),
        const SizedBox(width: 16),
        _legendDot(AppColors.secondary, 'Maya'),
        const SizedBox(width: 16),
        _legendDot(const Color(0xFF8E6C00), 'On-hand Cash'),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  LineChartData _buildChartData(
    List<FlSpot> walletSpots,
    List<FlSpot> mayaSpots,
    List<FlSpot> cashSpots,
    List<String> xLabels,
  ) {
    final maxX = xLabels.isEmpty ? 0.0 : (xLabels.length - 1).toDouble();
    final maxYValue = [
      ...walletSpots.map((spot) => spot.y),
      ...mayaSpots.map((spot) => spot.y),
      ...cashSpots.map((spot) => spot.y),
      1.0,
    ].reduce((value, element) => value > element ? value : element);

    return LineChartData(
      clipData: FlClipData.all(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 5,
        getDrawingHorizontalLine: (_) => FlLine(
          color: AppColors.outlineVariant.withValues(alpha: 0.4),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx < 0 || idx >= xLabels.length) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  xLabels[idx],
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: maxX,
      minY: 0,
      maxY: maxYValue + 1,
      lineBarsData: [
        // GCash line — primary blue
        LineChartBarData(
          spots: walletSpots,
          isCurved: true,
          preventCurveOverShooting: true,
          preventCurveOvershootingThreshold: 8,
          color: AppColors.primary,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, touchedSpotIndex, barData, spotIndex) =>
                FlDotCirclePainter(
                  radius: 3,
                  color: AppColors.primary,
                  strokeWidth: 1.5,
                  strokeColor: Colors.white,
                ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withValues(alpha: 0.15),
                AppColors.primary.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
        // Maya line — secondary green
        LineChartBarData(
          spots: mayaSpots,
          isCurved: true,
          preventCurveOverShooting: true,
          preventCurveOvershootingThreshold: 8,
          color: AppColors.secondary,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, touchedSpotIndex, barData, spotIndex) =>
                FlDotCirclePainter(
                  radius: 3,
                  color: AppColors.secondary,
                  strokeWidth: 1.5,
                  strokeColor: Colors.white,
                ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.secondary.withValues(alpha: 0.12),
                AppColors.secondary.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
        // Cash line — amber
        LineChartBarData(
          spots: cashSpots,
          isCurved: true,
          preventCurveOverShooting: true,
          preventCurveOvershootingThreshold: 8,
          color: const Color(0xFF8E6C00),
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, touchedSpotIndex, barData, spotIndex) =>
                FlDotCirclePainter(
                  radius: 3,
                  color: const Color(0xFF8E6C00),
                  strokeWidth: 1.5,
                  strokeColor: Colors.white,
                ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF8E6C00).withValues(alpha: 0.12),
                const Color(0xFF8E6C00).withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => AppColors.onSurface.withValues(alpha: 0.95),
          tooltipRoundedRadius: 8,
          tooltipPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          showOnTopOfTheChartBoxArea: true,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final tooltipColor = switch (spot.barIndex) {
                0 => AppColors.primaryContainer,
                1 => AppColors.secondaryContainer,
                _ => const Color(0xFFF8E287),
              };
              return LineTooltipItem(
                '₱ ${(spot.y * 1000).toStringAsFixed(0)}',
                TextStyle(
                  color: tooltipColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }
}
