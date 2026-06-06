import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';

class ArchitectActivityTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? supportingText;
  final String amount;
  final String time;
  final IconData icon;
  final Color iconColor;
  final Color? amountColor;
  final String? runningBalance;
  final VoidCallback? onTap;

  const ArchitectActivityTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.supportingText,
    required this.amount,
    required this.time,
    required this.icon,
    required this.iconColor,
    this.amountColor,
    this.runningBalance,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = amount.startsWith('+');
    final normalizedTitle = title.toLowerCase();
    final normalizedSubtitle = subtitle.toLowerCase();
    final isTopUp =
        normalizedTitle.contains('top-up') ||
        normalizedTitle.contains('top up') ||
        normalizedSubtitle.contains('top-up') ||
        normalizedSubtitle.contains('top up');

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
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
                        color: AppColors.outlineVariant.withValues(alpha: 0.45),
                      ),
                    ),
                    // Icon circle with white background to cut through line
                    Positioned(
                      top: 14,
                      left: 8,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: AppColors.background,
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
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            if (supportingText != null &&
                                supportingText!.trim().isNotEmpty)
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
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      supportingText!,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: iconColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              amount,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: amountColor ?? (isTopUp
                                    ? AppColors.primary
                                    : (isIncome
                                          ? AppColors.secondary
                                          : AppColors.error)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            time,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          if (runningBalance != null &&
                              runningBalance!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              runningBalance!,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurfaceVariant
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
