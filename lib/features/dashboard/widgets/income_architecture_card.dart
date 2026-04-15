import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/app_theme.dart';

class IncomeArchitectureCard extends StatefulWidget {
  const IncomeArchitectureCard({super.key});

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

  final List<String> _xLabels = const [
    '1 Oct',
    '7 Oct',
    '14 Oct',
    '21 Oct',
    '28 Oct',
    'Today',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          _buildLegend(),
          const SizedBox(height: 20),
          SizedBox(height: 160, child: LineChart(_buildChartData())),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Income Architecture',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Visualizing your growth trends over the last 30 days',
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
        _legendDot(AppColors.secondary, 'Cash'),
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

  LineChartData _buildChartData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 5,
        getDrawingHorizontalLine: (_) => FlLine(
          color: AppColors.outlineVariant.withOpacity(0.4),
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
              if (idx < 0 || idx >= _xLabels.length) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  _xLabels[idx],
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
      maxX: 5,
      minY: 0,
      maxY: 20,
      lineBarsData: [
        // GCash line — primary blue
        LineChartBarData(
          spots: _gcashSpots,
          isCurved: true,
          color: AppColors.primary,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
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
                AppColors.primary.withOpacity(0.15),
                AppColors.primary.withOpacity(0.0),
              ],
            ),
          ),
        ),
        // Cash line — secondary green
        LineChartBarData(
          spots: _cashSpots,
          isCurved: true,
          color: AppColors.secondary,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
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
                AppColors.secondary.withOpacity(0.12),
                AppColors.secondary.withOpacity(0.0),
              ],
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => AppColors.onSurface,
          tooltipRoundedRadius: 8,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final isGcash = spot.barIndex == 0;
              return LineTooltipItem(
                '₱ ${(spot.y * 1000).toStringAsFixed(0)}',
                TextStyle(
                  color: isGcash
                      ? AppColors.primaryContainer
                      : AppColors.secondaryContainer,
                  fontWeight: FontWeight.bold,
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
