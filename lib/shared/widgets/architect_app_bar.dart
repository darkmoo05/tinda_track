import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class ArchitectAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onSettingsPressed;

  /// Optional custom leading widget. When provided it replaces the default
  /// back-arrow so callers can supply a close button on modal screens.
  final Widget? leading;

  const ArchitectAppBar({
    super.key,
    required this.title,
    this.actions,
    this.onSettingsPressed,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarBg = isDark ? AppColors.darkNavy : AppColors.background;
    final titleColor = isDark ? const Color(0xFF60A5FA) : AppColors.primary;
    final iconBgColor = isDark ? const Color(0xFF161D30) : AppColors.primary;
    final actionBg = isDark ? const Color(0xFF161D30) : AppColors.surfaceContainerLow;
    final actionIconColor = isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant;

    return AppBar(
      backgroundColor: appBarBg,
      elevation: 0,
      centerTitle: false,
      leading: leading,
      foregroundColor: isDark ? const Color(0xFF94A3B8) : AppColors.onSurfaceVariant,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset('tinda_tract_icon.png', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: titleColor,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions:
          actions ??
          [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton.filledTonal(
                tooltip: 'Open menu',
                onPressed: onSettingsPressed ?? () {},
                style: IconButton.styleFrom(
                  backgroundColor: actionBg,
                ),
                icon: Icon(
                  Icons.settings_outlined,
                  color: actionIconColor,
                  size: 20,
                ),
              ),
            ),
          ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
