import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../shared/widgets/architect_card.dart';

class ArchitectActivityTile extends StatelessWidget {
  final String title;
  final String type;
  final String reference;
  final String amount;
  final String time;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const ArchitectActivityTile({
    super.key,
    required this.title,
    required this.type,
    required this.reference,
    required this.amount,
    required this.time,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = amount.startsWith('+');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: ArchitectCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
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
                    const SizedBox(height: 2),
                    Text(
                      '$type • $reference',
                      style: Theme.of(
                        context,
                      ).textTheme.labelMedium?.copyWith(fontSize: 11),
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
                      color: isIncome ? AppColors.secondary : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(fontSize: 10),
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
