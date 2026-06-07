import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';

class ArchitectActivityItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final String tag;
  final IconData icon;
  final Color iconColor;

  const ArchitectActivityItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.tag,
    required this.icon,
    this.iconColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = amount.startsWith('+');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface;
    final textSecondary = isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Timeline left column
            SizedBox(
              width: 52,
              child: Stack(
                children: [
                  // Full-height connecting line
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 25,
                    child: Container(
                      width: 1.5,
                      color: (isDark ? const Color(0xFF334155) : AppColors.outlineVariant)
                          .withValues(alpha: 0.45),
                    ),
                  ),
                  // Icon circle cutting through the line
                  Positioned(
                    top: 14,
                    left: 8,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0B0F19) : AppColors.background,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: iconColor.withValues(alpha: 0.35),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(icon, color: iconColor, size: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: textSecondary,
                            ),
                          ),
                          if (tag.trim().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: iconColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  tag,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: iconColor,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      amount,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isPositive
                            ? AppColors.secondary
                            : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
