import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../shared/widgets/architect_card.dart';

class VerificationWarningCard extends StatelessWidget {
  final int count;
  final VoidCallback onReview;

  const VerificationWarningCard({
    super.key,
    required this.count,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    return ArchitectCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFCC99).withOpacity(0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.contact_page_outlined,
              color: Color(0xFF8B4513),
              size: 20,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'AWAITING VERIFICATION',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onReview,
            child: Row(
              children: const [
                Text(
                  'Review Queue',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
