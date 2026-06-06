import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/sync/sync_orchestrator.dart';

/// A self-contained banner that appears at the top of the screen whenever the
/// current user has unsynced local data remaining from a previous session.
///
/// Behaviour:
/// - Reads [syncEngineProvider.getPendingPushCount()] once on first mount.
/// - Displays an amber warning banner when count > 0.
/// - Tapping "Sync Now" triggers a full sync and dismisses on success.
/// - Dismissing via the close button hides it for the current session
///   (will reappear next session if still unsynced).
class UnsyncedBanner extends ConsumerStatefulWidget {
  const UnsyncedBanner({super.key});

  @override
  ConsumerState<UnsyncedBanner> createState() => _UnsyncedBannerState();
}

class _UnsyncedBannerState extends ConsumerState<UnsyncedBanner>
    with SingleTickerProviderStateMixin {
  int _pendingCount = 0;
  bool _visible = false;
  bool _checking = true;
  bool _syncing = false;
  bool _dismissed = false;

  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) => _checkPending());
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _checkPending() async {
    if (!mounted) return;
    try {
      final count = await ref.read(syncEngineProvider).getPendingPushCount();
      if (!mounted) return;
      setState(() {
        _pendingCount = count;
        _visible = count > 0;
        _checking = false;
      });
      if (_visible) _slideController.forward();
    } catch (_) {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _syncNow() async {
    if (_syncing) return;
    setState(() => _syncing = true);
    try {
      final results = await ref.read(syncEngineProvider).runOnce();
      if (!mounted) return;
      final allOk = results.every((r) => r.error == null);
      if (allOk) {
        final remaining =
            await ref.read(syncEngineProvider).getPendingPushCount();
        if (!mounted) return;
        if (remaining == 0) {
          await _dismiss();
          return;
        }
      }
    } catch (_) {
      // Swallow — banner stays visible if sync failed.
    }
    if (mounted) setState(() => _syncing = false);
  }

  Future<void> _dismiss() async {
    await _slideController.reverse();
    if (mounted) {
      setState(() {
        _dismissed = true;
        _visible = false;
        _syncing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking || !_visible || _dismissed) return const SizedBox.shrink();

    return SlideTransition(
      position: _slideAnimation,
      child: Material(
        elevation: 4,
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFFA500).withValues(alpha: 0.92),
                const Color(0xFFFF6B00).withValues(alpha: 0.88),
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _pendingCount == 1
                          ? '1 unsynced change from your last session.'
                          : '$_pendingCount unsynced changes from your last session.',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _syncing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : TextButton(
                          onPressed: _syncNow,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.20),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Sync Now',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: _syncing ? null : _dismiss,
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    tooltip: 'Dismiss',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
