import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/l10n/l10n_extension.dart';
import '../../shared/widgets/app_side_drawer.dart';
import '../../shared/features/settings/screens/about_app_screen.dart';
import '../../shared/features/settings/screens/backup_data_screen.dart';
import '../../shared/features/settings/screens/profile_screen.dart';

AppDrawerConfig buildTindaTrackerDrawerConfig(
  BuildContext context, {
  VoidCallback? onSwitchApp,
}) {
  void push(Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  return AppDrawerConfig(
    appIcon: Icons.storefront_rounded,
    appColor: AppColors.secondary,
    appTitle: 'TindaTracker',
    appSubtitle: 'Quick navigation',
    navItems: const [],
    settingsItems: [
      DrawerItem(
        icon: Icons.backup_rounded,
        label: context.l10n.backupData,
        onTap: () => push(const BackupDataScreen()),
      ),
      DrawerItem(
        icon: Icons.person_outline_rounded,
        label: context.l10n.profile,
        onTap: () => push(const ProfileScreen()),
      ),
      DrawerItem(
        icon: Icons.info_outline_rounded,
        label: context.l10n.aboutApp,
        onTap: () => push(
          AboutAppScreen(
            info: AppInfo(
              appBarTitle: 'About TindaTracker',
              title: 'TindaTracker',
              description:
                  'Track your sari-sari store sales, inventory, and daily transactions.',
              icon: Icons.storefront_rounded,
              color: AppColors.secondary,
            ),
          ),
        ),
      ),
    ],
    switcherConfig: onSwitchApp != null
        ? AppSwitcherConfig(
            otherAppIcon: Icons.account_balance_wallet_rounded,
            otherAppColor: AppColors.primary,
            otherAppLabel: 'PocketLedger',
            onSwitch: onSwitchApp,
          )
        : null,
  );
}
