import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/app_theme.dart';
import '../../../shared/widgets/architect_card.dart';

class ArchitectAnalyticsCard extends StatefulWidget {
  final String title;
  final String value;
  final String trend;

  const ArchitectAnalyticsCard({
    super.key,
    required this.title,
    required this.value,
    required this.trend,
  });

  @override
  State<ArchitectAnalyticsCard> createState() => _ArchitectAnalyticsCardState();
}

class _ArchitectAnalyticsCardState extends State<ArchitectAnalyticsCard> {
  int _selectedPeriod = 0; // 0: DAY, 1: WEEK, 2: MONTH

  @override
  Widget build(BuildContext context) {
    return ArchitectCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title.toUpperCase(),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
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
          const Text(
            "Today's Profit",
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 80,
            child: LineChart(
              _buildChartData(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    final periods = ['DAY', 'WEEK', 'MONTH'];
    return Container(
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                  )
                ] : null,
              ),
              child: Text(
                periods[index],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  LineChartData _buildChartData() {
    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3),
            FlSpot(2, 2.5),
            FlSpot(4, 3.5),
            FlSpot(6, 3),
            FlSpot(8, 4),
            FlSpot(10, 3.8),
            FlSpot(12, 4.5),
          ],
          isCurved: true,
          color: AppColors.secondary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.secondary.withOpacity(0.1),
          ),
        ),
      ],
    );
  }
}
