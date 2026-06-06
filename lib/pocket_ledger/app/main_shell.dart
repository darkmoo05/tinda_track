import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_theme.dart';
import '../../core/sync/sync_orchestrator.dart';
import '../../core/sync/sync_result.dart';
import '../../core/l10n/l10n_extension.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/activity/screens/activity_history_screen.dart';
import '../features/parties/screens/party_management_screen.dart';
import '../features/charges/screens/charges_screen.dart';
import '../features/transactions/screens/add_transaction_screen.dart';
import '../features/transactions/screens/add_owner_movement_screen.dart';
import '../../shared/widgets/app_side_drawer.dart';
import '../../shared/widgets/unsynced_banner.dart';
import 'pocket_ledger_drawer_config.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key, this.onSwitchApp});

  final VoidCallback? onSwitchApp;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _shellScaffoldKey = GlobalKey<ScaffoldState>();
  bool _fabOpen = false;
  bool _fabOverlayVisible = false;
  int _refreshToken = 0;
  int _historyViewToken = 0;
  HistoryWalletPerspective? _historyWalletPerspective;
  late final AnimationController _fabMenuController;
  late final StreamSubscription<SyncResult> _syncResultsSub;

  @override
  void initState() {
    super.initState();
    _fabMenuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _syncResultsSub = ref.read(syncOrchestratorProvider).results.listen((
      result,
    ) {
      if (!mounted) {
        return;
      }
      if (result.pushedCount == 0 && result.pulledCount == 0) {
        return;
      }
      _handleDataChanged();
    });
  }

  @override
  void dispose() {
    _syncResultsSub.cancel();
    _fabMenuController.dispose();
    super.dispose();
  }

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
      _closeFabMenu();
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleFab() {
    if (_fabOpen) {
      _closeFabMenu();
      return;
    }

    _openFabMenu();
  }

  void _openFabMenu() {
    setState(() {
      _fabOpen = true;
      _fabOverlayVisible = true;
    });
    _fabMenuController.forward(from: 0);
  }

  Future<void> _closeFabMenu() async {
    if (!_fabOverlayVisible) {
      return;
    }

    if (_fabOpen && mounted) {
      setState(() => _fabOpen = false);
    }

    await _fabMenuController.reverse();

    if (!mounted) {
      return;
    }

    setState(() => _fabOverlayVisible = false);
  }

  void _dismissFabMenuImmediate() {
    if (!_fabOverlayVisible) {
      return;
    }

    _fabMenuController.stop();
    _fabMenuController.value = 0;

    if (!mounted) {
      return;
    }

    setState(() {
      _fabOpen = false;
      _fabOverlayVisible = false;
    });
  }

  double _staggerProgress(double parentValue, {required double start}) {
    final normalized = ((parentValue - start) / (1 - start)).clamp(0.0, 1.0);
    return Curves.easeOutCubic.transform(normalized);
  }

  Future<void> _openTransaction() async {
    _dismissFabMenuImmediate();
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
    );
    if (saved == true && mounted) {
      setState(() {
        _selectedIndex = 0;
        _refreshToken++;
      });
    }
  }

  Future<void> _openOwnerMovement() async {
    _dismissFabMenuImmediate();
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddOwnerMovementScreen()),
    );

    if (saved == true && mounted) {
      _handleDataChanged();
    }
  }

  void _openHistoryWithPerspective(HistoryWalletPerspective perspective) {
    _dismissFabMenuImmediate();
    setState(() {
      _selectedIndex = 1;
      _historyWalletPerspective = perspective;
      _historyViewToken++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;

    if (isKeyboardVisible && _fabOverlayVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _dismissFabMenuImmediate();
      });
    }

    final subFabWidth = (MediaQuery.sizeOf(context).width * 0.78).clamp(
      260.0,
      360.0,
    );

    return Scaffold(
      key: _shellScaffoldKey,
      drawer: AppSideDrawer(
        config: buildPocketLedgerDrawerConfig(
          context,
          onNavTap: (i) {
            _dismissFabMenuImmediate();
            setState(() => _selectedIndex = i);
          },
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
              DashboardScreen(
                key: ValueKey('dashboard-$_refreshToken'),
                openDrawer: () => _shellScaffoldKey.currentState?.openDrawer(),
                onDataChanged: _handleDataChanged,
                onWalletPerspectiveSelected: _openHistoryWithPerspective,
              ),
              ActivityHistoryScreen(
                key: ValueKey('history-$_refreshToken-$_historyViewToken'),
                openDrawer: () => _shellScaffoldKey.currentState?.openDrawer(),
                initialWalletPerspective: _historyWalletPerspective,
              ),
              PartyManagementScreen(
                key: ValueKey('parties-$_refreshToken'),
                openDrawer: () => _shellScaffoldKey.currentState?.openDrawer(),
              ),
              ChargesScreen(
                key: ValueKey('charges-$_refreshToken'),
                openDrawer: () => _shellScaffoldKey.currentState?.openDrawer(),
              ),
            ],
          ),
          if (_fabOverlayVisible) ...[
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleFab,
                behavior: HitTestBehavior.opaque,
                child: ClipRect(
                  child: AnimatedBuilder(
                    animation: _fabMenuController,
                    builder: (context, child) {
                      final progress = _fabMenuController.value;
                      return BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 10 * progress,
                          sigmaY: 10 * progress,
                        ),
                        child: Container(
                          color: AppColors.onSurface.withValues(
                            alpha: 0.10 * progress,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 96,
              child: Center(
                child: AnimatedBuilder(
                  animation: _fabMenuController,
                  builder: (context, child) {
                    final menuProgress = _fabMenuController.value;
                    final movementProgress = _staggerProgress(
                      menuProgress,
                      start: 0.0,
                    );
                    final transactionProgress = _staggerProgress(
                      menuProgress,
                      start: 0.18,
                    );

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSubFab(
                          label: context.l10n.recordOwnerMovementFab,
                          icon: Icons.swap_horiz_rounded,
                          color: AppColors.secondary,
                          width: subFabWidth,
                          revealProgress: movementProgress,
                          onTap: _openOwnerMovement,
                        ),
                        const SizedBox(height: 12),
                        _buildSubFab(
                          label: context.l10n.transaction,
                          icon: Icons.receipt_long_rounded,
                          color: AppColors.primary,
                          width: subFabWidth,
                          revealProgress: transactionProgress,
                          onTap: _openTransaction,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 160),
        reverseDuration: const Duration(milliseconds: 120),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1.0).animate(animation),
              child: child,
            ),
          );
        },
        child: isKeyboardVisible
            ? const SizedBox.shrink(key: ValueKey('mainShellFabHidden'))
            : FloatingActionButton(
                key: const ValueKey('mainShellFabVisible'),
                heroTag: null,
                onPressed: _toggleFab,
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: AnimatedRotation(
                  turns: _fabOpen ? 0.125 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.add, color: Colors.white, size: 32),
                ),
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.zero,
        height: 72,
        color: AppColors.surfaceContainerLowest,
        shape: isKeyboardVisible ? null : const CircularNotchedRectangle(),
        notchMargin: isKeyboardVisible ? 0 : 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.dashboard_rounded, 'Home'),
            _buildNavItem(1, Icons.history_rounded, 'History'),
            SizedBox(width: isKeyboardVisible ? 0 : 48),
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
    required double width,
    required double revealProgress,
    required VoidCallback onTap,
  }) {
    return _AnimatedSubFabButton(
      label: label,
      icon: icon,
      color: color,
      width: width,
      revealProgress: revealProgress,
      onTap: onTap,
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

class _AnimatedSubFabButton extends StatefulWidget {
  const _AnimatedSubFabButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.width,
    required this.revealProgress,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final double width;
  final double revealProgress;
  final VoidCallback onTap;

  @override
  State<_AnimatedSubFabButton> createState() => _AnimatedSubFabButtonState();
}

class _AnimatedSubFabButtonState extends State<_AnimatedSubFabButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final reveal = widget.revealProgress.clamp(0.0, 1.0);

    return Transform.translate(
      offset: Offset(0, (1 - reveal) * 12),
      child: Opacity(
        opacity: reveal,
        child: Transform.scale(
          scale: 0.97 + (0.03 * reveal),
          child: SizedBox(
            width: widget.width,
            child: AnimatedScale(
              scale: _pressed ? 0.99 : 1,
              duration: Duration(milliseconds: _pressed ? 70 : 90),
              curve: Curves.easeOut,
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  splashColor: widget.color.withValues(alpha: 0.10),
                  highlightColor: widget.color.withValues(alpha: 0.06),
                  onTapDown: (_) => setState(() => _pressed = true),
                  onTapUp: (_) => setState(() => _pressed = false),
                  onTapCancel: () => setState(() => _pressed = false),
                  onTap: widget.onTap,
                  child: Ink(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: widget.color.withValues(alpha: 0.18),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withValues(alpha: 0.12),
                          blurRadius: _pressed ? 8 : 10,
                          offset: Offset(0, _pressed ? 3 : 4),
                        ),
                        BoxShadow(
                          color: AppColors.onSurface.withValues(alpha: 0.06),
                          blurRadius: _pressed ? 4 : 5,
                          offset: Offset(0, _pressed ? 1 : 1),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  widget.color.withValues(alpha: 0.18),
                                  widget.color.withValues(alpha: 0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              widget.icon,
                              color: widget.color,
                              size: 21,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
                                    color: widget.color.withValues(alpha: 0.75),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          AnimatedSlide(
                            offset: _pressed
                                ? const Offset(0.10, 0)
                                : Offset.zero,
                            duration: const Duration(milliseconds: 140),
                            curve: Curves.easeOut,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: widget.color.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 13,
                                color: widget.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
