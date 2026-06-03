import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/l10n/l10n_extension.dart';
import '../../shared/widgets/app_side_drawer.dart';
import '../features/activity/screens/activity_history_screen.dart';
import '../features/charges/screens/charges_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../../shared/features/settings/screens/about_app_screen.dart';
import '../../shared/features/settings/screens/backup_data_screen.dart';
import '../../shared/features/settings/screens/profile_screen.dart';
import '../features/parties/screens/party_management_screen.dart';

AppDrawerConfig buildPocketLedgerDrawerConfig(
  BuildContext context, {
  void Function(int)? onNavTap,
  VoidCallback? onSwitchApp,
}) {
  void push(Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  return AppDrawerConfig(
    appIcon: Icons.account_balance_wallet_rounded,
    appColor: AppColors.primary,
    appTitle: context.l10n.appTitle,
    appSubtitle: context.l10n.quickNavigation,
    navItems: [
      DrawerItem(
        icon: Icons.dashboard_rounded,
        label: 'Home',
        onTap: () =>
            onNavTap != null ? onNavTap(0) : push(const DashboardScreen()),
      ),
      DrawerItem(
        icon: Icons.history_rounded,
        label: 'History',
        onTap: () => onNavTap != null
            ? onNavTap(1)
            : push(const ActivityHistoryScreen()),
      ),
      DrawerItem(
        icon: Icons.people_rounded,
        label: 'Parties',
        onTap: () => onNavTap != null
            ? onNavTap(2)
            : push(const PartyManagementScreen()),
      ),
      DrawerItem(
        icon: Icons.payments_rounded,
        label: 'Charges',
        onTap: () =>
            onNavTap != null ? onNavTap(3) : push(const ChargesScreen()),
      ),
    ],
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
              appBarTitle: context.l10n.aboutPocketLedger,
              title: context.l10n.appTitle,
              description: context.l10n.pocketLedgerDescription,
              icon: Icons.account_balance_wallet_rounded,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    ],
    switcherConfig: onSwitchApp != null
        ? AppSwitcherConfig(
            otherAppIcon: Icons.storefront_rounded,
            otherAppColor: AppColors.secondary,
            otherAppLabel: 'TindaTracker',
            onSwitch: onSwitchApp,
          )
        : null,
  );
}
