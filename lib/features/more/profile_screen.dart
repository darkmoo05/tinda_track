import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
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
              'Your Profile',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Set your display name, contact details, and business identity settings.',
              style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
