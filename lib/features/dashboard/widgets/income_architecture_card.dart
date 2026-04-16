import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/app_theme.dart';

class IncomeArchitectureCard extends StatefulWidget {
  const IncomeArchitectureCard({
    super.key,
    this.walletSpots,
    this.cashSpots,
    this.xLabels,
    this.walletTotal,
    this.onHandTotal,
  });

  final List<FlSpot>? walletSpots;
  final List<FlSpot>? cashSpots;
  final List<String>? xLabels;
  final double? walletTotal;
  final double? onHandTotal;

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
    final walletSpots = widget.walletSpots ?? _gcashSpots;
    final cashSpots = widget.cashSpots ?? _cashSpots;
    final xLabels = widget.xLabels ?? _xLabels;
    final walletTotal = widget.walletTotal ?? _resolveLatestTotal(walletSpots);
    final onHandTotal = widget.onHandTotal ?? _resolveLatestTotal(cashSpots);
    final combinedTotal = walletTotal + onHandTotal;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 14),
          _buildTotalsRow(context, walletTotal, onHandTotal, combinedTotal),
          const SizedBox(height: 16),
          _buildLegend(),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: LineChart(_buildChartData(walletSpots, cashSpots, xLabels)),
          ),
        ],
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
          'Daily closing balances for your GCash wallet and on-hand cash',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  double _resolveLatestTotal(List<FlSpot> spots) {
    if (spots.isEmpty) {
      return 0;
    }
    return spots.last.y * 1000;
  }

  Widget _buildTotalsRow(
    BuildContext context,
    double walletTotal,
    double onHandTotal,
    double combinedTotal,
  ) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _amountPill(
                label: 'GCash Wallet',
                value: walletTotal,
                color: AppColors.primary,
                textTheme: textTheme,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _amountPill(
                label: 'On-hand Cash',
                value: onHandTotal,
                color: AppColors.secondary,
                textTheme: textTheme,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_rounded,
                size: 18,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Total Cash Position',
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '₱ ${combinedTotal.toStringAsFixed(2)}',
                style: textTheme.titleSmall?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _amountPill({
    required String label,
    required double value,
    required Color color,
    required TextTheme textTheme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₱ ${value.toStringAsFixed(2)}',
            style: textTheme.titleSmall?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _legendDot(AppColors.primary, 'GCash'),
        const SizedBox(width: 16),
        _legendDot(AppColors.secondary, 'On-hand Cash'),
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
    List<FlSpot> cashSpots,
    List<String> xLabels,
  ) {
    final maxX = xLabels.isEmpty ? 0.0 : (xLabels.length - 1).toDouble();
    final maxYValue = [
      ...walletSpots.map((spot) => spot.y),
      ...cashSpots.map((spot) => spot.y),
      1.0,
    ].reduce((value, element) => value > element ? value : element);

    return LineChartData(
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
        // Cash line — secondary green
        LineChartBarData(
          spots: cashSpots,
          isCurved: true,
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
