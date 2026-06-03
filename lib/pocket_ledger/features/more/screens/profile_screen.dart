import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_theme.dart';
import '../../../../core/database/providers/auth_providers.dart';
import '../../../../core/l10n/l10n_extension.dart';

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
                onPressed: () {
                  ref.read(authStateProvider.notifier).logout();
                  Navigator.of(context).pop();
                },
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
}
