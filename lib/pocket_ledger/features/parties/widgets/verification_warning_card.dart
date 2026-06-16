import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';
import '../../../../shared/widgets/architect_card.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ArchitectCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF2C1B03)
                  : AppColors.warningContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.contact_page_outlined,
              color: isDark ? const Color(0xFFFFD060) : AppColors.warningText,
              size: 20,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'AWAITING VERIFICATION',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onReview,
            child: Row(
              children: [
                Text(
                  'Review Queue',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: isDark ? const Color(0xFF60A5FA) : AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
