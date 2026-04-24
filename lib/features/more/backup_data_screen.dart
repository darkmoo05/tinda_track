import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class BackupDataScreen extends StatelessWidget {
  const BackupDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup Data'),
        backgroundColor: AppColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Keep your records safe',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Use this screen to export a full backup and restore data whenever needed.',
              style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('Export Backup'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_rounded),
              label: const Text('Restore Backup'),
            ),
          ],
        ),
      ),
    );
  }
}
