import 'package:flutter/material.dart';

import '../../../core/app_theme.dart';
import '../data/party_repository.dart';

class PartyHealthHero extends StatelessWidget {
  final int totalEntities;
  final double verificationRate;
  final List<PartyActivityRecord> activeParties;

  const PartyHealthHero({
    super.key,
    required this.totalEntities,
    required this.verificationRate,
    required this.activeParties,
  });

  @override
  Widget build(BuildContext context) {
    final maxCount = activeParties.isEmpty
        ? 1
        : activeParties
              .map((item) => item.transactionCount)
              .reduce((a, b) => a > b ? a : b);

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
            'MOST ACTIVE PARTIES',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Activity by Transactions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildMetricPill(
                '$totalEntities Total',
                Colors.white.withOpacity(0.2),
              ),
              const SizedBox(width: 12),
              _buildMetricPill(
                '${verificationRate.toStringAsFixed(1)}% Verified',
                const Color(0xFF4DB6AC).withOpacity(0.3),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (activeParties.isEmpty)
            const Text(
              'No transaction activity yet. Save transactions to populate this graph.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            )
          else
            Column(
              children: activeParties
                  .map((item) => _buildActivityBar(item, maxCount))
                  .toList(growable: false),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityBar(PartyActivityRecord item, int maxCount) {
    final ratio = maxCount <= 0 ? 0.0 : item.transactionCount / maxCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.party.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${item.transactionCount} txns',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.18),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF80CBC4),
              ),
            ),
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
