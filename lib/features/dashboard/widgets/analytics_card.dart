import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/app_theme.dart';
import '../../../shared/widgets/architect_card.dart';

class ArchitectAnalyticsCard extends StatefulWidget {
  final String title;
  final String value;
  final String trend;
  final String subtitle;
  final List<FlSpot>? spots;
  final List<String>? xLabels;
  final List<DateTime>? dates;

  const ArchitectAnalyticsCard({
    super.key,
    required this.title,
    required this.value,
    required this.trend,
    this.subtitle = "Today's Profit",
    this.spots,
    this.xLabels,
    this.dates,
  });

  @override
  State<ArchitectAnalyticsCard> createState() => _ArchitectAnalyticsCardState();
}

class _ArchitectAnalyticsCardState extends State<ArchitectAnalyticsCard> {
  int _selectedPeriod = 0; // 0: DAY, 1: WEEK, 2: MONTH, 3: YEAR

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
    final filtered = _filteredSeries(allSpots, allLabels, allDates);

    return ArchitectCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildSegmentedControl(),
            ],
          ),
          const SizedBox(height: 24),
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
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: BarChart(_buildChartData(filtered.spots, filtered.labels)),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    final periods = ['DAY', 'WEEK', 'MONTH', 'YEAR'];
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 210),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: List.generate(periods.length, (index) {
              final isSelected = _selectedPeriod == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedPeriod = index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    periods[index],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  _FilteredSeries _filteredSeries(
    List<FlSpot> allSpots,
    List<String> allLabels,
    List<DateTime> allDates,
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

    final groups = _selectedPeriod == 0
        ? _buildDailyGroups(points, 7)
        : _selectedPeriod == 1
        ? _buildWeeklyGroups(points, 7)
        : _selectedPeriod == 2
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

    final groups = List.generate(safeSpots.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: safeSpots[index].y,
            color: AppColors.secondary,
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });

    return BarChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => FlLine(
          color: AppColors.outlineVariant.withValues(alpha: 0.25),
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
              if (!isEdge && labels.length > 3) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  labels[idx],
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
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
      barGroups: groups,
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          tooltipRoundedRadius: 8,
          getTooltipColor: (_) => AppColors.onSurface,
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
