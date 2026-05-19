import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../shared/widgets/app_side_drawer.dart';
import 'tinda_tracker_drawer_config.dart';

class TindaTrackerShell extends StatefulWidget {
  const TindaTrackerShell({super.key, this.onSwitchApp});

  final VoidCallback? onSwitchApp;

  @override
  State<TindaTrackerShell> createState() => _TindaTrackerShellState();
}

class _TindaTrackerShellState extends State<TindaTrackerShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppSideDrawer(
        config: buildTindaTrackerDrawerConfig(
          context,
          onSwitchApp: widget.onSwitchApp,
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            title: const Text(
              'TindaTracker',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ),
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      size: 44,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'TindaTracker',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Coming soon',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
