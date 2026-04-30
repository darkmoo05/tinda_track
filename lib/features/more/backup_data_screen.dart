import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/data/sync_config.dart';
import '../../core/data/sync_service.dart';

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
    ).showSnackBar(const SnackBar(content: Text('Server URL saved.')));
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
            'Sync completed — pushed ${result.pushed}, pulled ${result.pulled}.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sync failed: $error'),
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
        title: const Text('Backup & Sync'),
        backgroundColor: AppColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Server connection',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Enter the base URL of your Tinda Track server. '
              'Use your local IP (e.g. http://192.168.1.24:8080/api) '
              'when the device is on the same Wi-Fi as your computer.',
              style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
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
                        labelText: 'Server API URL',
                        hintText: 'http://192.168.1.x:8080/api',
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
                    tooltip: 'Save URL',
                    onPressed: _isSyncing ? null : _saveUrl,
                  ),
                ],
              )
            else
              const LinearProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'Sync data',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Push local changes to the server and pull updates from other devices.',
              style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
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
              label: Text(_isSyncing ? 'Syncing…' : 'Sync Now'),
            ),
            const SizedBox(height: 24),
            Text(
              'Local backup',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
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
