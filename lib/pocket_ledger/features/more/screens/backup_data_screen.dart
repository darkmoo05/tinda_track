import 'package:flutter/material.dart';

import '../../../../core/app_theme.dart';
import '../../../../core/sync/sync_config.dart';
import '../../../../core/sync/sync_service.dart';
import '../../../../core/l10n/l10n_extension.dart';

class BackupDataScreen extends StatefulWidget {
  const BackupDataScreen({super.key});

  @override
  State<BackupDataScreen> createState() => _BackupDataScreenState();
}

class _BackupDataScreenState extends State<BackupDataScreen> {
  bool _isSyncing = false;
  bool _urlLoaded = false;
  late final TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
    _loadUrl();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _loadUrl() async {
    final url = await SyncConfig.getBaseApiUrl();
    if (!mounted) return;
    _urlController.text = url;
    setState(() => _urlLoaded = true);
  }

  Future<void> _saveUrl() async {
    final raw = _urlController.text.trim();
    if (raw.isEmpty) return;
    await SyncConfig.setBaseApiUrl(raw);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.serverUrlSaved)));
  }

  Future<void> _syncNow() async {
    if (_isSyncing) return;

    // Save any pending URL change first.
    await _saveUrl();

    setState(() => _isSyncing = true);
    try {
      final result = await SyncService.instance.syncAll();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.syncCompleted(result.pushed, result.pulled),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.syncFailed(error)),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.backupSync),
        backgroundColor: AppColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.serverConnection,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.serverUrlInstruction,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (_urlLoaded)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _urlController,
                      enabled: !_isSyncing,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        isDense: true,
                        labelText: context.l10n.serverApiUrl,
                        hintText: context.l10n.serverApiUrlHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      keyboardType: TextInputType.url,
                      autocorrect: false,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.outlined(
                    icon: const Icon(Icons.save_rounded),
                    tooltip: context.l10n.saveUrl,
                    onPressed: _isSyncing ? null : _saveUrl,
                  ),
                ],
              )
            else
              const LinearProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              context.l10n.syncData,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.syncInstruction,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _isSyncing ? null : _syncNow,
              icon: _isSyncing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync_rounded),
              label: Text(
                _isSyncing ? context.l10n.syncing : context.l10n.syncNow,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.localBackup,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.upload_file_rounded),
              label: Text(context.l10n.exportBackup),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_rounded),
              label: Text(context.l10n.restoreBackup),
            ),
          ],
        ),
      ),
    );
  }
}
