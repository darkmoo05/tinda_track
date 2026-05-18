import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/app_theme.dart';

enum _TimePeriod { week, month, year }

// Neon palette for crypto-vibe glassmorphism card
const _kGcashNeon = Color(0xFF3D9BFF); // electric blue
const _kMayaNeon = Color(0xFF39FF95); // neon green
const _kCashNeon = Color(0xFFFFD060); // gold
const _kCardDark = Color(0xFF0A1628); // deep navy
const _kCardDeep = Color(0xFF1C0E38); // deep indigo

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

  bool _isDarkMode = false;
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

  Widget _buildPeriodFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPeriodPill('7D', _TimePeriod.week),
        const SizedBox(width: 8),
        _buildPeriodPill('1M', _TimePeriod.month),
        const SizedBox(width: 8),
        _buildPeriodPill('1Y', _TimePeriod.year),
      ],
    );
  }

  Widget _buildPeriodPill(String label, _TimePeriod period) {
    final isSelected = _selectedPeriod == period;

    final bgColor = _isDarkMode
        ? (isSelected
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.transparent)
        : (isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.surfaceContainerLow);

    final borderColor = _isDarkMode
        ? (isSelected
              ? Colors.white.withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.10))
        : (isSelected
              ? AppColors.primary.withValues(alpha: 0.35)
              : AppColors.outlineVariant.withValues(alpha: 0.5));

    final textColor = _isDarkMode
        ? (isSelected ? Colors.white : Colors.white.withValues(alpha: 0.35))
        : (isSelected ? AppColors.primary : AppColors.onSurfaceVariant);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
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
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: 0.5,
          ),
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
    final minChartWidth = (xLabels.length * 48.0).clamp(260.0, double.infinity);

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartWidth = constraints.maxWidth > minChartWidth
            ? constraints.maxWidth
            : minChartWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: chartWidth,
            height: 212,
            child: LineChart(
              _buildChartData(walletSpots, mayaSpots, cashSpots, xLabels),
            ),
          ),
        );
      },
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: _isDarkMode
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_kCardDark, _kCardDeep],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              boxShadow: [
                BoxShadow(
                  color: _kGcashNeon.withValues(alpha: 0.07),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: _kMayaNeon.withValues(alpha: 0.04),
                  blurRadius: 40,
                  offset: const Offset(0, 14),
                ),
              ],
            )
          : BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.surfaceContainerLowest,
                  AppColors.surfaceContainerLow,
                ],
              ),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.4),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.onSurface.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          _buildDeltaChips(
            filteredWalletSpots,
            filteredMayaSpots,
            filteredCashSpots,
          ),
          const SizedBox(height: 16),
          Divider(
            color: _isDarkMode
                ? Colors.white.withValues(alpha: 0.07)
                : AppColors.outlineVariant.withValues(alpha: 0.25),
            height: 1,
          ),
          const SizedBox(height: 14),
          _buildScrollableChart(
            filteredWalletSpots,
            filteredMayaSpots,
            filteredCashSpots,
            filteredXLabels,
          ),
          const SizedBox(height: 18),
          _buildPeriodFilter(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final iconBg = _isDarkMode
        ? _kGcashNeon.withValues(alpha: 0.14)
        : AppColors.primary.withValues(alpha: 0.10);
    final iconBorderColor = _isDarkMode
        ? _kGcashNeon.withValues(alpha: 0.28)
        : AppColors.primary.withValues(alpha: 0.20);
    final iconColor = _isDarkMode ? _kGcashNeon : AppColors.primary;
    final titleColor = _isDarkMode ? Colors.white : AppColors.onSurface;
    final subtitleColor = _isDarkMode
        ? Colors.white.withValues(alpha: 0.42)
        : AppColors.onSurfaceVariant;
    final toggleAccent = _isDarkMode ? _kMayaNeon : AppColors.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: iconBorderColor),
          ),
          child: Icon(
            Icons.candlestick_chart_rounded,
            color: iconColor,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Balance Trend',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Touch graph to see balance at any point',
                style: TextStyle(fontSize: 11, color: subtitleColor),
              ),
            ],
          ),
        ),
        // Theme toggle button replacing the static LIVE badge
        GestureDetector(
          onTap: () => setState(() => _isDarkMode = !_isDarkMode),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: toggleAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: toggleAccent.withValues(alpha: 0.30)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isDarkMode
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  size: 11,
                  color: toggleAccent,
                ),
                const SizedBox(width: 4),
                Text(
                  _isDarkMode ? 'DARK' : 'LIGHT',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: toggleAccent,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _computeDelta(List<FlSpot> spots) {
    if (spots.length < 2) return '–';
    final first = spots.first.y;
    final last = spots.last.y;
    if (first == 0) return '–';
    final delta = (last - first) / first * 100;
    final sign = delta >= 0 ? '▲' : '▼';
    return '$sign ${delta.abs().toStringAsFixed(1)}%';
  }

  bool _isDeltaPositive(List<FlSpot> spots) {
    if (spots.length < 2) return true;
    return spots.last.y >= spots.first.y;
  }

  Widget _buildDeltaChips(
    List<FlSpot> walletSpots,
    List<FlSpot> mayaSpots,
    List<FlSpot> cashSpots,
  ) {
    final gcashColor = _isDarkMode ? _kGcashNeon : AppColors.primary;
    final mayaColor = _isDarkMode ? _kMayaNeon : AppColors.secondary;
    final cashColor = _isDarkMode ? _kCashNeon : const Color(0xFF8E6C00);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.hardEdge,
      child: Row(
        children: [
          _buildDeltaChip(gcashColor, 'GCash', walletSpots),
          const SizedBox(width: 8),
          _buildDeltaChip(mayaColor, 'Maya', mayaSpots),
          const SizedBox(width: 8),
          _buildDeltaChip(cashColor, 'On-hand', cashSpots),
        ],
      ),
    );
  }

  Widget _buildDeltaChip(Color accentColor, String label, List<FlSpot> spots) {
    final deltaText = _computeDelta(spots);
    final isPositive = _isDeltaPositive(spots);

    final deltaColor = deltaText == '–'
        ? (_isDarkMode
              ? Colors.white.withValues(alpha: 0.30)
              : AppColors.onSurfaceVariant)
        : isPositive
        ? (_isDarkMode ? const Color(0xFF39FF95) : AppColors.secondary)
        : (_isDarkMode ? const Color(0xFFFF6B6B) : const Color(0xFFBA1A1A));

    final labelTextColor = _isDarkMode
        ? Colors.white.withValues(alpha: 0.88)
        : AppColors.onSurface;

    final dotDecoration = BoxDecoration(
      color: accentColor,
      shape: BoxShape.circle,
      boxShadow: _isDarkMode
          ? [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.65),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ]
          : null,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: _isDarkMode ? 0.08 : 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: accentColor.withValues(alpha: _isDarkMode ? 0.25 : 0.20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: dotDecoration),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: labelTextColor,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            deltaText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: deltaColor,
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildChartData(
    List<FlSpot> walletSpots,
    List<FlSpot> mayaSpots,
    List<FlSpot> cashSpots,
    List<String> xLabels,
  ) {
    // Theme-aware color palette
    final gcashColor = _isDarkMode ? _kGcashNeon : AppColors.primary;
    final mayaColor = _isDarkMode ? _kMayaNeon : AppColors.secondary;
    final cashColor = _isDarkMode ? _kCashNeon : const Color(0xFF8E6C00);
    final gridColor = _isDarkMode
        ? Colors.white.withValues(alpha: 0.06)
        : AppColors.outlineVariant.withValues(alpha: 0.24);
    final labelColor = _isDarkMode
        ? Colors.white.withValues(alpha: 0.38)
        : AppColors.onSurfaceVariant;

    final maxX = xLabels.isEmpty ? 0.0 : (xLabels.length - 1).toDouble();
    final maxYValue = [
      ...walletSpots.map((spot) => spot.y),
      ...mayaSpots.map((spot) => spot.y),
      ...cashSpots.map((spot) => spot.y),
      1.0,
    ].reduce((value, element) => value > element ? value : element);

    LineChartBarData buildLine(Color color, List<FlSpot> spots) {
      return LineChartBarData(
        spots: spots,
        isCurved: true,
        preventCurveOverShooting: true,
        preventCurveOvershootingThreshold: 8,
        color: color,
        barWidth: 2.5,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, pct, barData, idx) => FlDotCirclePainter(
            radius: 3,
            color: color,
            strokeWidth: _isDarkMode ? 0 : 1.5,
            strokeColor: _isDarkMode ? Colors.transparent : Colors.white,
          ),
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: _isDarkMode ? 0.20 : 0.13),
              color.withValues(alpha: 0.0),
            ],
          ),
        ),
      );
    }

    return LineChartData(
      clipData: FlClipData.all(),
      backgroundColor: Colors.transparent,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 5,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: gridColor, strokeWidth: 1),
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
                  style: TextStyle(
                    fontSize: 9,
                    color: labelColor,
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
        buildLine(gcashColor, walletSpots),
        buildLine(mayaColor, mayaSpots),
        buildLine(cashColor, cashSpots),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => const Color(0xFF0D1F35),
          tooltipRoundedRadius: 12,
          tooltipPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          showOnTopOfTheChartBoxArea: true,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final (walletName, lineColor) = switch (spot.barIndex) {
                0 => ('GCash', gcashColor),
                1 => ('Maya', mayaColor),
                _ => ('Cash', cashColor),
              };
              return LineTooltipItem(
                '$walletName  ₱ ${(spot.y * 1000).toStringAsFixed(0)}',
                TextStyle(
                  color: lineColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }
}
