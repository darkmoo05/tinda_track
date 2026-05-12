import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/l10n_extension.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aboutPocketLedger),
        backgroundColor: AppColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.appTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.pocketLedgerDescription,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.verified_rounded,
                color: AppColors.primary,
              ),
              title: Text(l10n.version),
              subtitle: Text(l10n.buildInfo),
            ),
          ],
        ),
      ),
    );
  }
}
