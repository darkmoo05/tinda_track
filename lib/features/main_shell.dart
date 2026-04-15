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

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ActivityHistoryScreen(),
    const PartyManagementScreen(),
    const ChargesScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleFab() {
    setState(() => _fabOpen = !_fabOpen);
  }

  void _openTransaction() {
    setState(() => _fabOpen = false);
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddTransactionScreen()));
  }

  void _openOwnerMovement() {
    setState(() => _fabOpen = false);
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddOwnerMovementScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _selectedIndex, children: _screens),
          if (_fabOpen) ...[
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleFab,
                behavior: HitTestBehavior.opaque,
                child: Container(color: Colors.black.withOpacity(0.06)),
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
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton.small(
            heroTag: label,
            onPressed: onTap,
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ],
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
