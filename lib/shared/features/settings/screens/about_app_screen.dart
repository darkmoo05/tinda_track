import 'package:flutter/material.dart';

import '../../../../core/app_theme.dart';
import '../../../../core/l10n/l10n_extension.dart';

class AppInfo {
  const AppInfo({
    required this.appBarTitle,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String appBarTitle;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
}

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key, required this.info});

  final AppInfo info;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(info.appBarTitle),
        backgroundColor: AppColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: info.color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(info.icon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Text(
                  info.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: info.color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              info.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.verified_rounded, color: info.color),
              title: Text(l10n.version),
              subtitle: Text(l10n.buildInfo),
            ),
          ],
        ),
      ),
    );
  }
}
