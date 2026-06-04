import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import '../database/providers/auth_providers.dart';
import '../database/providers/database_providers.dart';
import 'sync_orchestrator.dart';

const String backgroundSyncTaskName = 'com.tindatrack.backgroundSyncTask';

/// The entry-point callback dispatcher required by Workmanager.
/// This runs in a separate isolate when the background task fires.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == backgroundSyncTaskName) {
      final container = ProviderContainer();
      try {
        // Hydrate the active username from secure storage so the background task
        // opens the correct user-scoped database file.
        final authRepo = container.read(authRepositoryProvider);
        final username = await authRepo.getLastUsername();
        if (username != null && username.isNotEmpty) {
          container.read(activeUsernameProvider.notifier).state = username;
        }

        final orchestrator = container.read(syncOrchestratorProvider);
        final results = await orchestrator.syncAll();
        
        // Return true if all modules synced without terminal errors
        final hasFailed = results.any((r) => r.error != null);
        return !hasFailed;
      } catch (_) {
        return false;
      } finally {
        container.dispose();
      }
    }
    return true;
  });
}

/// Helper manager to configure and register Workmanager tasks.
class BackgroundSyncManager {
  BackgroundSyncManager._();

  /// Initializes the Workmanager with the callback dispatcher.
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  /// Registers a periodic sync task that runs every 15 minutes
  /// (minimum interval allowed by Android/iOS platform constraints).
  static Future<void> registerPeriodicSync() async {
    await Workmanager().registerPeriodicTask(
      'periodic-sync-task',
      backgroundSyncTaskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }

  /// Cancels all scheduled background sync tasks.
  static Future<void> cancelAll() async {
    await Workmanager().cancelAll();
  }
}
