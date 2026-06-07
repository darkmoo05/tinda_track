import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/app_theme.dart';
import '../../../../shared/widgets/architect_card.dart';

class ArchitectAnalyticsCard extends StatefulWidget {
  final String title;
  final String value;
  final String trend;
  final String subtitle;
  final List<FlSpot>? spots;
  final List<String>? xLabels;
  final List<DateTime>? dates;

  /// When provided, the card uses this period instead of internal state
  /// and hides the internal dropdown.
  final int? selectedPeriod;
  final void Function(int)? onPeriodChanged;

  /// When false, the value / trend / subtitle stats block is hidden.
  final bool showStats;

  final List<FlSpot>? secondarySpots;
  final bool isLineChart;

  const ArchitectAnalyticsCard({
    super.key,
    required this.title,
    required this.value,
    required this.trend,
    this.subtitle = "Today's Profit",
    this.spots,
    this.xLabels,
    this.dates,
    this.selectedPeriod,
    this.onPeriodChanged,
    this.showStats = true,
    this.secondarySpots,
    this.isLineChart = false,
  });

  @override
  State<ArchitectAnalyticsCard> createState() => _ArchitectAnalyticsCardState();
}

class _ArchitectAnalyticsCardState extends State<ArchitectAnalyticsCard> {
  int _selectedPeriod = 0; // 0: DAY, 1: WEEK, 2: MONTH, 3: YEAR
  static const List<String> _periods = ['DAY', 'WEEK', 'MONTH', 'YEAR'];

  @override
  Widget build(BuildContext context) {
    final allSpots =
        widget.spots ??
        const [
          FlSpot(0, 3),
          FlSpot(2, 2.5),
          FlSpot(4, 3.5),
          FlSpot(6, 3),
          FlSpot(8, 4),
          FlSpot(10, 3.8),
          FlSpot(12, 4.5),
        ];
    final allLabels =
        widget.xLabels ??
        List<String>.generate(allSpots.length, (index) => 'D${index + 1}');
    final allDates =
        widget.dates ??
        List<DateTime>.generate(
          allSpots.length,
          (index) => DateTime.now().subtract(
            Duration(days: allSpots.length - 1 - index),
          ),
        );
    final activePeriod = widget.selectedPeriod ?? _selectedPeriod;
    final refilteredFiltered = _filteredSeries(
      allSpots,
      allLabels,
      allDates,
      activePeriod,
    );

    _FilteredSeries? refilteredSecondary;
    if (widget.secondarySpots != null) {
      refilteredSecondary = _filteredSeries(
        widget.secondarySpots!,
        allLabels,
        allDates,
        activePeriod,
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurfaceVariantColor = isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant;
    final secondaryColor = isDark ? const Color(0xFF34D399) : AppColors.secondary;

    return ArchitectCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.title.toUpperCase(),
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: onSurfaceVariantColor,
                  ),
                ),
              ),
            ],
          ),
          if (widget.showStats) ...[
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.trend,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: secondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.subtitle,
              style: TextStyle(
                fontSize: 12,
                color: onSurfaceVariantColor,
              ),
            ),
          ],
          if (widget.selectedPeriod == null) ...[
            const SizedBox(height: 14),
            _buildPeriodFilterChips(),
          ],
          const SizedBox(height: 18),
          _buildChartPanel(
            context,
            refilteredFiltered.spots,
            refilteredSecondary?.spots,
            refilteredFiltered.labels,
          ),
          if (widget.secondarySpots != null) ...[
            const SizedBox(height: 16),
            _buildChartLegend(context),
          ],
        ],
      ),
    );
  }

  Widget _buildPeriodFilterChips() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activePeriod = widget.selectedPeriod ?? _selectedPeriod;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_periods.length, (index) {
          final isSelected = activePeriod == index;
          final label = _periods[index];

          Color accentColor = isDark ? const Color(0xFF06B6D4) : AppColors.primary;
          if (widget.secondarySpots != null) {
            accentColor = isDark ? const Color(0xFF3D9BFF) : AppColors.primary;
          }

          final bgColor = isDark
              ? (isSelected ? accentColor.withValues(alpha: 0.15) : Colors.transparent)
              : (isSelected ? accentColor.withValues(alpha: 0.12) : AppColors.surfaceContainerLow);

          final borderColor = isDark
              ? (isSelected ? accentColor.withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.10))
              : (isSelected ? accentColor.withValues(alpha: 0.35) : AppColors.outlineVariant.withValues(alpha: 0.5));

          final textColor = isDark
              ? (isSelected ? Colors.white : Colors.white.withValues(alpha: 0.45))
              : (isSelected ? accentColor : AppColors.onSurfaceVariant);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                if (widget.onPeriodChanged != null) {
                  widget.onPeriodChanged!(index);
                } else {
                  setState(() => _selectedPeriod = index);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildChartPanel(
    BuildContext context,
    List<FlSpot> spots,
    List<FlSpot>? secondarySpots,
    List<String> labels,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurfaceColor = isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface;

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartWidth = (labels.length * 52.0).clamp(
          constraints.maxWidth,
          560.0,
        );

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF161D30)
                : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.surfaceContainerHigh,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.035),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
              if (isDark && widget.isLineChart && secondarySpots == null)
                BoxShadow(
                  color: const Color(0xFF06B6D4).withValues(alpha: 0.07),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      (widget.isLineChart || secondarySpots != null)
                          ? Icons.show_chart_rounded
                          : Icons.bar_chart_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Charges monitoring report',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: onSurfaceColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                height: 170,
                padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: Theme.of(context).brightness == Brightness.dark
                        ? [
                            const Color(0xFF161D30),
                            const Color(0xFF1E293B),
                          ]
                        : [
                            AppColors.surfaceContainerLowest,
                            AppColors.surfaceContainerLow,
                          ],
                  ),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.08)
                        : AppColors.surfaceContainerHigh,
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: chartWidth,
                    child: (widget.isLineChart || secondarySpots != null)
                        ? LineChart(_buildLineChartData(spots, secondarySpots, labels))
                        : BarChart(_buildChartData(spots, labels)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  LineChartData _buildLineChartData(
    List<FlSpot> spots,
    List<FlSpot>? secondarySpots,
    List<String> labels,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cyanColor = isDark ? const Color(0xFF06B6D4) : AppColors.primary;
    final gcashColor = isDark ? const Color(0xFF3D9BFF) : const Color(0xFF2563EB);
    final mayaColor = isDark ? const Color(0xFF34D399) : const Color(0xFF059669);

    final safeSpots = spots.isEmpty ? const [FlSpot(0, 0)] : spots;

    final double maxY;
    if (secondarySpots != null) {
      final safeSecondarySpots = secondarySpots.isEmpty ? const [FlSpot(0, 0)] : secondarySpots;
      final maxPrimaryY = safeSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
      final maxSecondaryY = safeSecondarySpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
      maxY = maxPrimaryY > maxSecondaryY ? maxPrimaryY : maxSecondaryY;
    } else {
      maxY = safeSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    }
    final chartMaxY = maxY <= 0 ? 1.0 : maxY * 1.2;
    final shouldCompactLabels = labels.length > 4;

    return LineChartData(
      backgroundColor: Colors.transparent,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => FlLine(
          color: AppColors.outlineVariant.withValues(alpha: isDark ? 0.08 : 0.20),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx < 0 || idx >= labels.length) {
                return const SizedBox.shrink();
              }

              final isEdge =
                  idx == 0 ||
                  idx == labels.length - 1 ||
                  idx == (labels.length ~/ 2);
              if (!isEdge && shouldCompactLabels) {
                return const SizedBox.shrink();
              }

              final onSurfaceColor = isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface;
              final onSurfaceVariantColor = isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant;

              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  labels[idx],
                  style: TextStyle(
                    fontSize: shouldCompactLabels ? 9 : 10,
                    fontWeight: FontWeight.w700,
                    color: isEdge ? onSurfaceColor : onSurfaceVariantColor,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minY: 0,
      maxY: chartMaxY,
      lineBarsData: [
        if (secondarySpots != null) ...[
          LineChartBarData(
            spots: safeSpots,
            isCurved: true,
            barWidth: 3,
            color: gcashColor,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 3.5,
                color: gcashColor,
                strokeWidth: 1.5,
                strokeColor: isDark ? const Color(0xFF161D30) : Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  gcashColor.withValues(alpha: isDark ? 0.24 : 0.18),
                  gcashColor.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          LineChartBarData(
            spots: secondarySpots.isEmpty ? const [FlSpot(0, 0)] : secondarySpots,
            isCurved: true,
            barWidth: 3,
            color: mayaColor,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 3.5,
                color: mayaColor,
                strokeWidth: 1.5,
                strokeColor: isDark ? const Color(0xFF161D30) : Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  mayaColor.withValues(alpha: isDark ? 0.24 : 0.18),
                  mayaColor.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ] else ...[
          LineChartBarData(
            spots: safeSpots,
            isCurved: true,
            barWidth: 3.5,
            color: cyanColor,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 4.0,
                color: cyanColor,
                strokeWidth: 2.0,
                strokeColor: isDark ? const Color(0xFF161D30) : Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  cyanColor.withValues(alpha: isDark ? 0.28 : 0.20),
                  cyanColor.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipRoundedRadius: 12,
          getTooltipColor: (_) => isDark ? const Color(0xFF1E293B) : AppColors.onSurface,
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((touchedSpot) {
              final label = (touchedSpot.spotIndex >= 0 && touchedSpot.spotIndex < labels.length)
                  ? labels[touchedSpot.spotIndex]
                  : '';
              if (secondarySpots != null) {
                final isGcash = touchedSpot.barIndex == 0;
                final seriesName = isGcash ? 'GCash' : 'Maya';
                final seriesColor = isGcash ? gcashColor : mayaColor;
                return LineTooltipItem(
                  '$label\n$seriesName: ₱ ${(touchedSpot.y * 1000).toStringAsFixed(2)}',
                  TextStyle(
                    color: seriesColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                );
              } else {
                return LineTooltipItem(
                  '$label\nEarnings: ₱ ${(touchedSpot.y * 1000).toStringAsFixed(2)}',
                  TextStyle(
                    color: cyanColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                );
              }
            }).toList();
          },
        ),
      ),
    );
  }

  Widget _buildChartLegend(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gcashColor = isDark ? const Color(0xFF3D9BFF) : const Color(0xFF2563EB);
    final mayaColor = isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
    final onSurfaceColor = isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('GCash Fee', gcashColor, onSurfaceColor),
        const SizedBox(width: 24),
        _buildLegendItem('Maya Fee', mayaColor, onSurfaceColor),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color dotColor, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  _FilteredSeries _filteredSeries(
    List<FlSpot> allSpots,
    List<String> allLabels,
    List<DateTime> allDates,
    int period,
  ) {
    if (allSpots.isEmpty) {
      return const _FilteredSeries(spots: [], labels: []);
    }

    final safeLength = [
      allSpots.length,
      allDates.length,
    ].reduce((a, b) => a < b ? a : b);
    final points = <_Point>[];
    for (var i = 0; i < safeLength; i++) {
      points.add(_Point(date: allDates[i], value: allSpots[i].y));
    }

    if (points.isEmpty) {
      return const _FilteredSeries(spots: [], labels: []);
    }

    final groups = period == 0
        ? _buildDailyGroups(points, 7)
        : period == 1
        ? _buildWeeklyGroups(points, 7)
        : period == 2
        ? _buildMonthlyGroups(points, 7)
        : _buildYearlyGroups(points, 7);

    final reIndexed = <FlSpot>[];
    final labels = <String>[];
    for (var i = 0; i < groups.length; i++) {
      reIndexed.add(FlSpot(i.toDouble(), groups[i].value));
      labels.add(groups[i].label);
    }

    return _FilteredSeries(spots: reIndexed, labels: labels);
  }

  List<_GroupPoint> _buildDailyGroups(List<_Point> points, int count) {
    final sorted = points.toList()..sort((a, b) => a.date.compareTo(b.date));
    final selected = sorted.length > count
        ? sorted.sublist(sorted.length - count)
        : sorted;
    return selected
        .map(
          (point) => _GroupPoint(
            label: '${point.date.day}/${point.date.month}',
            value: point.value,
          ),
        )
        .toList(growable: false);
  }

  List<_GroupPoint> _buildWeeklyGroups(List<_Point> points, int count) {
    final grouped = <DateTime, double>{};
    for (final point in points) {
      final startOfWeek = DateTime(
        point.date.year,
        point.date.month,
        point.date.day,
      ).subtract(Duration(days: point.date.weekday - 1));
      grouped.update(
        startOfWeek,
        (current) => current + point.value,
        ifAbsent: () => point.value,
      );
    }

    final keys = grouped.keys.toList()..sort();
    final selected = keys.length > count
        ? keys.sublist(keys.length - count)
        : keys;
    return selected
        .map(
          (key) => _GroupPoint(
            label: 'W${((key.day - 1) ~/ 7) + 1} ${_monthShort(key.month)}',
            value: grouped[key] ?? 0,
          ),
        )
        .toList(growable: false);
  }

  List<_GroupPoint> _buildMonthlyGroups(List<_Point> points, int count) {
    final grouped = <DateTime, double>{};
    for (final point in points) {
      final monthKey = DateTime(point.date.year, point.date.month);
      grouped.update(
        monthKey,
        (current) => current + point.value,
        ifAbsent: () => point.value,
      );
    }

    final keys = grouped.keys.toList()..sort();
    final selected = keys.length > count
        ? keys.sublist(keys.length - count)
        : keys;
    return selected
        .map(
          (key) => _GroupPoint(
            label:
                '${_monthShort(key.month)} ${key.year.toString().substring(2)}',
            value: grouped[key] ?? 0,
          ),
        )
        .toList(growable: false);
  }

  List<_GroupPoint> _buildYearlyGroups(List<_Point> points, int count) {
    final grouped = <int, double>{};
    for (final point in points) {
      grouped.update(
        point.date.year,
        (current) => current + point.value,
        ifAbsent: () => point.value,
      );
    }

    final keys = grouped.keys.toList()..sort();
    final selected = keys.length > count
        ? keys.sublist(keys.length - count)
        : keys;
    return selected
        .map(
          (year) =>
              _GroupPoint(label: year.toString(), value: grouped[year] ?? 0),
        )
        .toList(growable: false);
  }

  String _monthShort(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  BarChartData _buildChartData(List<FlSpot> spots, List<String> labels) {
    final safeSpots = spots.isEmpty ? const [FlSpot(0, 0)] : spots;
    final maxY = safeSpots
        .map((spot) => spot.y)
        .reduce((a, b) => a > b ? a : b);
    final chartMaxY = maxY <= 0 ? 1.0 : maxY * 1.2;
    final shouldCompactLabels = labels.length > 4;

    final groups = List.generate(safeSpots.length, (index) {
      final isLatest = index == safeSpots.length - 1;
      final barColor = isLatest
          ? AppColors.primary
          : AppColors.primaryContainer;

      return BarChartGroupData(
        x: index,
        barsSpace: 0,
        barRods: [
          BarChartRodData(
            toY: safeSpots[index].y,
            color: barColor,
            width: safeSpots.length >= 6 ? 14 : 18,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                barColor.withValues(alpha: 0.98),
                barColor.withValues(alpha: isLatest ? 0.78 : 0.66),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: chartMaxY,
              color: AppColors.outlineVariant.withValues(alpha: 0.12),
            ),
          ),
        ],
      );
    });

    return BarChartData(
      backgroundColor: Colors.transparent,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => FlLine(
          color: AppColors.outlineVariant.withValues(alpha: 0.20),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx < 0 || idx >= labels.length) {
                return const SizedBox.shrink();
              }

              final isEdge =
                  idx == 0 ||
                  idx == labels.length - 1 ||
                  idx == (labels.length ~/ 2);
              if (!isEdge && shouldCompactLabels) {
                return const SizedBox.shrink();
              }

              final isDark = Theme.of(context).brightness == Brightness.dark;
              final onSurfaceColor = isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface;
              final onSurfaceVariantColor = isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant;

              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  labels[idx],
                  style: TextStyle(
                    fontSize: shouldCompactLabels ? 9 : 10,
                    fontWeight: FontWeight.w700,
                    color: isEdge
                        ? onSurfaceColor
                        : onSurfaceVariantColor,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minY: 0,
      maxY: chartMaxY,
      groupsSpace: 14,
      alignment: BarChartAlignment.spaceAround,
      barGroups: groups,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          tooltipRoundedRadius: 12,
          getTooltipColor: (_) => Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E293B)
              : AppColors.onSurface,
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final label = (groupIndex >= 0 && groupIndex < labels.length)
                ? labels[groupIndex]
                : '';
            return BarTooltipItem(
              '$label\n₱ ${(rod.toY * 1000).toStringAsFixed(2)}',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Point {
  const _Point({required this.date, required this.value});

  final DateTime date;
  final double value;
}

class _GroupPoint {
  const _GroupPoint({required this.label, required this.value});

  final String label;
  final double value;
}

class _FilteredSeries {
  const _FilteredSeries({required this.spots, required this.labels});

  final List<FlSpot> spots;
  final List<String> labels;
}
