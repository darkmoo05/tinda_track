import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'core/data/app_database.dart';
import 'core/data/sync_service.dart';
import 'features/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.init();
  runApp(const TindaTrackApp());
}

class TindaTrackApp extends StatelessWidget {
  const TindaTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tinda Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const StartupSyncGate(),
    ); //yes von
  }
}

class StartupSyncGate extends StatefulWidget {
  const StartupSyncGate({super.key});

  @override
  State<StartupSyncGate> createState() => _StartupSyncGateState();
}

class _StartupSyncGateState extends State<StartupSyncGate> {
  late final Future<SyncRunResult> _startupSync;

  @override
  void initState() {
    super.initState();
    _startupSync = _runStartupSync();
  }

  Future<SyncRunResult> _runStartupSync() async {
    try {
      return await SyncService.instance.syncAll();
    } catch (_) {
      return const SyncRunResult(pushed: 0, pulled: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SyncRunResult>(
      future: _startupSync,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _StartupLoadingScreen();
        }

        return const MainShell();
      },
    );
  }
}

class _StartupLoadingScreen extends StatelessWidget {
  const _StartupLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryContainer],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Icon centered in expanded space
              Expanded(
                child: Center(
                  child: Image.asset(
                    'tinda_tract_icon.png',
                    width: 140,
                    height: 140,
                  ),
                ),
              ),
              // Spinner + label pinned to bottom
              Padding(
                padding: const EdgeInsets.only(bottom: 48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.onPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Syncing your data…',
                      style: TextStyle(
                        color: AppColors.onPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
