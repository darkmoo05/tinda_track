import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_theme.dart';
import '../../../../core/database/providers/auth_providers.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/sync/sync_orchestrator.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final authState = ref.watch(authStateProvider);
    final username = authState.username ?? 'User';
    final role = authState.role ?? 'OWNER';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        backgroundColor: AppColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 34,
              backgroundColor: AppColors.surfaceContainerHigh,
              child: Icon(
                Icons.person_rounded,
                size: 34,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              username,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Role: $role',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.profileDescription,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _handleLogout(context, ref),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('LOG OUT'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                  foregroundColor: Colors.redAccent,
                  elevation: 0,
                  side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.2)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Show a loading indicator dialog while counting pending pushes
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    int pending = 0;
    try {
      pending = await ref.read(syncEngineProvider).getPendingPushCount();
    } catch (_) {
      // Ignored
    } finally {
      if (context.mounted) {
        Navigator.of(context).pop(); // Dismiss loading indicator
      }
    }

    if (pending == 0) {
      // No pending changes, log out immediately
      await ref.read(authStateProvider.notifier).logout();
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      return;
    }

    // Unsynced changes detected, show choice dialog
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Unsynced Changes'),
        content: Text(
          'You have $pending offline changes that are not yet synced to the cloud. '
          'Your data will be kept safe — you can sync it when you log back in. '
          'Would you like to sync now before logging out?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.of(dialogCtx).pop(); // Dismiss alert dialog
              
              // Proceed with logout/deletion
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pop(); // Pop ProfileScreen
              }
            },
            child: const Text('LOG OUT WITHOUT SYNCING'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop(); // Dismiss alert dialog
              
              // Show sync in-progress indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(width: 20),
                      Text('Syncing changes...'),
                    ],
                  ),
                ),
              );

              bool syncSuccess = false;
              try {
                final results = await ref.read(syncEngineProvider).runOnce();
                syncSuccess = results.every((r) => r.error == null);
              } catch (_) {
                syncSuccess = false;
              } finally {
                if (context.mounted) {
                  Navigator.of(context).pop(); // Dismiss sync in-progress dialog
                }
              }

              if (syncSuccess) {
                // Double-check count
                int remaining = 0;
                try {
                  remaining = await ref.read(syncEngineProvider).getPendingPushCount();
                } catch (_) {}
                
                if (remaining == 0) {
                  await ref.read(authStateProvider.notifier).logout();
                  if (context.mounted) {
                    Navigator.of(context).pop(); // Pop ProfileScreen
                  }
                  return;
                }
              }

              // If sync failed or remaining > 0, show error toast
              scaffoldMessenger.showSnackBar(
                const SnackBar(
                  content: Text('Sync failed. Please check your connection and try again.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            child: const Text('SYNC & LOG OUT'),
          ),
        ],
      ),
    );
  }
}
