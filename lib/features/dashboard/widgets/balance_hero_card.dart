import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

class ArchitectBalanceHero extends StatelessWidget {
  final String balance;
  final String label;
  final Color backgroundColor;
  final Color glowColor;

  const ArchitectBalanceHero({
    super.key,
    required this.balance,
    required this.label,
    this.backgroundColor = AppColors.primary,
    this.glowColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white70,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            balance,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Available for transactions',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
