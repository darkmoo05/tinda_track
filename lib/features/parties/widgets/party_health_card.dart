import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

class PartyHealthHero extends StatelessWidget {
  final int totalEntities;
  final double verificationRate;

  const PartyHealthHero({
    super.key,
    required this.totalEntities,
    required this.verificationRate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NETWORK HEALTH',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Active Entities',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildMetricPill('$totalEntities Total', Colors.white.withOpacity(0.2)),
              const SizedBox(width: 12),
              _buildMetricPill('● $verificationRate% Verified', const Color(0xFF4DB6AC).withOpacity(0.3)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricPill(String label, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
