import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

/// Shows a non-intrusive alert banner anchored to the **top** of the screen.
///
/// Used instead of [ScaffoldMessenger]'s default SnackBar when the message
/// needs to be seen above modal bottom sheets, dialogs, or the keyboard
/// (where a bottom-anchored SnackBar would be hidden).
///
/// The banner auto-dismisses after [duration] and can also be tapped to
/// dismiss immediately.
void showTopAlert(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 4),
  Color? backgroundColor,
  IconData icon = Icons.error_outline_rounded,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) => _TopAlert(
      message: message,
      duration: duration,
      backgroundColor: backgroundColor ?? AppColors.error,
      icon: icon,
      onDismiss: () {
        if (entry.mounted) entry.remove();
      },
    ),
  );
  overlay.insert(entry);
}

class _TopAlert extends StatefulWidget {
  const _TopAlert({
    required this.message,
    required this.duration,
    required this.backgroundColor,
    required this.icon,
    required this.onDismiss,
  });

  final String message;
  final Duration duration;
  final Color backgroundColor;
  final IconData icon;
  final VoidCallback onDismiss;

  @override
  State<_TopAlert> createState() => _TopAlertState();
}

class _TopAlertState extends State<_TopAlert>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offset;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _offset = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
    // Schedule auto-dismiss after the requested duration.
    Future.delayed(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Positioned(
      top: topPadding + 8,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _offset,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _dismiss,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(widget.icon, color: Colors.white, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.close_rounded,
                      color: Colors.white70,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
