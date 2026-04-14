import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';

class ArchitectSearchInput extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;

  const ArchitectSearchInput({
    super.key,
    this.hintText = 'Search parties, accounts...',
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEF0), // Matching the gray from screenshot
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.onSurfaceVariant,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
