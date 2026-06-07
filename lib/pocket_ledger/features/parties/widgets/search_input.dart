import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkIndigo : AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: const Color(0xFF1E293B)) : null,
      ),
      child: TextField(
        onChanged: onChanged,
        style: TextStyle(
          color: isDark ? const Color(0xFFF8FAFC) : AppColors.onSurface,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
