import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_theme.dart';
import '../../shared/widgets/app_side_drawer.dart';
import '../../shared/widgets/unsynced_banner.dart';
import '../features/customers/screens/customer_list_screen.dart';
import '../features/dashboard/screens/tt_dashboard_screen.dart';
import '../features/inventory/providers/inventory_providers.dart';
import '../features/inventory/screens/business_profile_wizard_screen.dart';
import '../features/inventory/screens/inventory_screen.dart';
import '../features/pos/screens/pos_screen.dart';
import '../features/reports/screens/reports_screen.dart';
import 'tinda_tracker_drawer_config.dart';

class TindaTrackerShell extends ConsumerStatefulWidget {
  const TindaTrackerShell({super.key, this.onSwitchApp});

  final VoidCallback? onSwitchApp;

  @override
  ConsumerState<TindaTrackerShell> createState() => _TindaTrackerShellState();
}

class _TindaTrackerShellState extends ConsumerState<TindaTrackerShell> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onNavTap(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(businessProfileProvider);

    return profileAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF0F0F12),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: const Color(0xFF0F0F12),
        body: Center(
          child: Text(
            'Error loading profile: $e',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      data: (profile) {
        if (profile == null) {
          return const BusinessProfileWizardScreen();
        }

        return Scaffold(
          key: _scaffoldKey,
          drawer: AppSideDrawer(
            config: buildTindaTrackerDrawerConfig(
              context,
              onSwitchApp: widget.onSwitchApp,
            ),
          ),
          body: Stack(
            children: [
              // Unsynced data warning — only visible when a returning user has
              // offline changes that weren't pushed before their last logout.
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: UnsyncedBanner(),
              ),
              IndexedStack(
                index: _selectedIndex,
                children: [
                  TtDashboardScreen(
                    onGoToSell: () => _onNavTap(1),
                    onGoToInventory: () => _onNavTap(2),
                  ),
                  const PosScreen(),
                  const InventoryScreen(), // ConsumerStatefulWidget — const ctor is fine
                  const CustomerListScreen(),
                  const ReportsScreen(),
                ],
              ),
            ],
          ),
          bottomNavigationBar: _TindaNavBar(
            selectedIndex: _selectedIndex,
            onTap: _onNavTap,
          ),
        );
      },
    );
  }
}

class _TindaNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _TindaNavBar({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavItem(icon: Icons.home_rounded, label: 'Home'),
      _NavItem(icon: Icons.shopping_cart_rounded, label: 'Sell'),
      _NavItem(icon: Icons.inventory_2_rounded, label: 'Inventory'),
      _NavItem(icon: Icons.people_rounded, label: 'Customers'),
      _NavItem(icon: Icons.bar_chart_rounded, label: 'Reports'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == selectedIndex;
              // Sell button gets special styling
              if (index == 1) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(index),
                    // Match the other nav items so the full Expanded slot
                    // (not just the visible 44px circle) is tappable.
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.35,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(item.icon, color: Colors.white, size: 22),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        size: 22,
                        color: isSelected
                            ? AppColors.secondary
                            : AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.normal,
                          color: isSelected
                              ? AppColors.secondary
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
