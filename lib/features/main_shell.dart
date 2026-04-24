import 'dart:ui';

import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import 'dashboard/dashboard_screen.dart';
import 'activity/activity_history_screen.dart';
import 'parties/party_management_screen.dart';
import 'charges/charges_screen.dart';
import 'transactions/add_transaction_screen.dart';
import 'transactions/add_owner_movement_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  bool _fabOpen = false;
  int _refreshToken = 0;

  void _handleDataChanged() {
    if (!mounted) {
      return;
    }

    setState(() {
      _refreshToken++;
    });
  }

  void _onItemTapped(int index) {
    if (_fabOpen) {
      setState(() => _fabOpen = false);
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleFab() {
    setState(() => _fabOpen = !_fabOpen);
  }

  Future<void> _openTransaction() async {
    setState(() => _fabOpen = false);
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
    );
    if (saved == true && mounted) {
      _handleDataChanged();
    }
  }

  Future<void> _openOwnerMovement() async {
    setState(() => _fabOpen = false);
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddOwnerMovementScreen()),
    );

    if (saved == true && mounted) {
      _handleDataChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: [
              DashboardScreen(
                key: ValueKey('dashboard-$_refreshToken'),
                onDataChanged: _handleDataChanged,
              ),
              ActivityHistoryScreen(key: ValueKey('history-$_refreshToken')),
              PartyManagementScreen(key: ValueKey('parties-$_refreshToken')),
              ChargesScreen(key: ValueKey('charges-$_refreshToken')),
            ],
          ),
          if (_fabOpen) ...[
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleFab,
                behavior: HitTestBehavior.opaque,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: AppColors.onSurface.withOpacity(0.10),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 96,
              child: Center(
                child: AnimatedSlide(
                  offset: _fabOpen ? Offset.zero : const Offset(0, 0.2),
                  duration: const Duration(milliseconds: 200),
                  child: AnimatedOpacity(
                    opacity: _fabOpen ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSubFab(
                          label: 'Record Owner Movement',
                          icon: Icons.swap_horiz_rounded,
                          color: AppColors.secondary,
                          onTap: _openOwnerMovement,
                        ),
                        const SizedBox(height: 12),
                        _buildSubFab(
                          label: 'Transaction',
                          icon: Icons.receipt_long_rounded,
                          color: AppColors.primary,
                          onTap: _openTransaction,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleFab,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: AnimatedRotation(
          turns: _fabOpen ? 0.125 : 0,
          duration: const Duration(milliseconds: 200),
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.zero,
        height: 72,
        color: AppColors.surfaceContainerLowest,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.dashboard_rounded, 'Home'),
            _buildNavItem(1, Icons.history_rounded, 'History'),
            const SizedBox(width: 48), // Space for FAB
            _buildNavItem(2, Icons.people_rounded, 'Parties'),
            _buildNavItem(3, Icons.payments_rounded, 'Charges'),
          ],
        ),
      ),
    );
  }

  Widget _buildSubFab({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        splashColor: color.withOpacity(0.10),
        highlightColor: color.withOpacity(0.06),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.18), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.14),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: AppColors.onSurface.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon badge
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(0.18),
                        color.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 21),
                ),
                const SizedBox(width: 14),
                // Label block
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap to open',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: color.withOpacity(0.75),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Arrow indicator
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
