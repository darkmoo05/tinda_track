import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';

class ArchitectDateHeader extends StatelessWidget {
  final String label;

  const ArchitectDateHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerBg = isDark ? const Color(0xFF1E293B) : AppColors.surfaceContainerHigh;
    final textColor = isDark ? const Color(0xFFE2E8F0) : AppColors.onSurfaceVariant;
    final lineColor = isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.surfaceContainerHigh;

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Row(
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: containerBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(height: 1, color: lineColor),
          ),
        ],
      ),
    );
  }
}
