import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

/// A standardised gradient hero-header card used at the top of every
/// major screen to give users an immediate, branded sense of place.
///
/// [title]         – large white headline (e.g. "Wallet Overview")
/// [subtitle]      – smaller white caption below the title
/// [trailing]      – optional widget pinned to the right (e.g. a report button)
/// [gradientColors] – optional custom gradient; defaults to primary→primaryContainer
class ScreenHeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  final List<Color>? gradientColors;

  const ScreenHeaderCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              gradientColors ?? [AppColors.primary, AppColors.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
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
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
  }
}
