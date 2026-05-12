import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../shared/widgets/architect_card.dart';

class ArchitectActivityTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? supportingText;
  final String amount;
  final String time;
  final IconData icon;
  final Color iconColor;
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: ArchitectCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.labelMedium?.copyWith(fontSize: 12),
                    ),
                    if (supportingText != null &&
                        supportingText!.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            supportingText!,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: iconColor,
                                ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isTopUp
                          ? AppColors.primary
                          : (isIncome ? AppColors.secondary : AppColors.error),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
