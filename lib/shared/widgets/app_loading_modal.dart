import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class AppLoadingModalController {
  AppLoadingModalController._(this._context, this._rootNavigator);

  final BuildContext _context;
  final bool _rootNavigator;
  bool _closed = false;

  void close() {
    if (_closed) return;
    _closed = true;
    final navigator = Navigator.of(_context, rootNavigator: _rootNavigator);
    if (!navigator.mounted || !navigator.canPop()) return;
    navigator.pop();
  }
}

AppLoadingModalController showAppLoadingModal(
  BuildContext context, {
  required String message,
  String? caption,
  bool rootNavigator = true,
}) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: rootNavigator,
    barrierColor: Colors.black.withValues(alpha: 0.52),
    builder: (_) => PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.6),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    if (caption != null && caption.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        caption,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  return AppLoadingModalController._(context, rootNavigator);
}
