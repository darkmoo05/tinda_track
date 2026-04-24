import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class ArchitectAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onSettingsPressed;

  const ArchitectAppBar({
    super.key,
    required this.title,
    this.actions,
    this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
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
              color: AppColors.primary,
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
                  backgroundColor: AppColors.surfaceContainerLow,
                ),
                icon: const Icon(
                  Icons.settings_outlined,
                  color: AppColors.onSurfaceVariant,
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
