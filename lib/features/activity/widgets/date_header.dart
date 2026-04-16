import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

class ArchitectDateHeader extends StatelessWidget {
  final String label;

  const ArchitectDateHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.surfaceContainerLow,
            ),
          ),
        ],
      ),
    );
  }
}
