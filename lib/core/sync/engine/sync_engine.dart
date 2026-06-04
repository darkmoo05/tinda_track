import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import '../../database/daos/app_meta_dao.dart';
import '../../database/daos/sync_state_dao.dart';
import '../remote/unified_sync_repository.dart';
import '../sync_result.dart';
import 'retry_policy.dart';
import 'sync_module.dart';

/// The single public entry-point for triggering sync. UI code reads
/// `syncEngineProvider` (alias `syncOrchestratorProvider` is kept for
/// backwards compatibility) and calls [runOnce] / [syncAll] / per-module
/// helpers.
///
/// The engine consolidates all modules into a single HTTP request calling
/// `/sync` to reduce read/write costs and bypass throttler limits.
class SyncEngine {
  SyncEngine({
    required SyncStateDao syncStateDao,
    required AppMetaDao appMetaDao,
    required List<SyncModule> modules,
    RetryPolicy retryPolicy = const RetryPolicy(),
  }) : _syncState = syncStateDao,
       _appMeta = appMetaDao,
       _modules = {for (final m in modules) m.key: m},
       _retry = retryPolicy;

  final SyncStateDao _syncState;
  final AppMetaDao _appMeta;
  final Map<String, SyncModule> _modules;
  final RetryPolicy _retry;

  /// Re-entrancy guard so concurrent UI taps coalesce into one in-flight run.
  Future<List<SyncResult>>? _inFlight;

  final StreamController<SyncResult> _resultsController =
      StreamController<SyncResult>.broadcast();

  /// Broadcast stream of per-module [SyncResult]s. Listened to by the
  /// shell to trigger refreshes.
  Stream<SyncResult> get results => _resultsController.stream;

  /// Module keys registered with the engine.
  Iterable<String> get moduleKeys => _modules.keys;

  void dispose() => _resultsController.close();

  /// Total number of locally-dirty rows across all registered modules.
  Future<int> getPendingPushCount() async {
    final counts = await Future.wait(
      _modules.values.map((m) => m.pendingCount()),
    );
    return counts.fold<int>(0, (a, b) => a + b);
  }

  /// Runs every module once, coalescing concurrent callers.
  Future<List<SyncResult>> runOnce() {
    final existing = _inFlight;
    if (existing != null) return existing;
    final run = syncAll().whenComplete(() => _inFlight = null);
    _inFlight = run;
    return run;
  }

  /// Helper to convert snake_case (client) to camelCase (server DTO keys)
  String _snakeToCamel(String snake) {
    final parts = snake.split('_');
    if (parts.length == 1) return snake;
    return parts[0] + parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
  }

  /// Execute unified sync for all registered modules in exactly 1 API call.
  Future<List<SyncResult>> syncAll() async {
    final startedAt = DateTime.now();
    final out = <SyncResult>[];

    try {
      final deviceId = await _appMeta.getOrCreateDeviceId();
      
      // 1) Read latest pull cursors for all modules
      final pocketState = await _syncState.read('pocket_ledger');
      final tindaState = await _syncState.read('tinda_tracker');
      
      final pocketCursor = pocketState?.lastPulledAtMs ?? 0;
      final tindaCursor = tindaState?.lastPulledAtMs ?? 0;

      // Safe minimum cursor so we don't miss updates from either app segment
      final lastSync = (pocketCursor == 0 || tindaCursor == 0)
          ? 0
          : min(pocketCursor, tindaCursor);

      // 2) Gather all dirty payloads from all modules
      final pushData = <String, List<Map<String, dynamic>>>{};
      final ackCallbacks = <Future<void> Function()>[];
      final modulePushedCounts = <String, int>{};

      for (final entry in _modules.entries) {
        final moduleKey = entry.key;
        final module = entry.value;
        var pushedCount = 0;

        for (final entity in module.entities) {
          final payload = await entity.preparePush();
          if (payload != null && payload.records.isNotEmpty) {
            final records = payload.records;
            for (final record in records) {
              final recDeviceId = record['deviceId'];
              if (recDeviceId == null || recDeviceId.toString().trim().isEmpty) {
                try {
                  record['deviceId'] = deviceId;
                } catch (_) {
                  final mutableRecord = Map<String, dynamic>.from(record);
                  mutableRecord['deviceId'] = deviceId;
                  final index = records.indexOf(record);
                  if (index != -1) {
                    records[index] = mutableRecord;
                  }
                }
              }
            }
            final serverKey = _snakeToCamel(payload.entityKey);
            pushData[serverKey] = records;
            ackCallbacks.add(payload.onAck);
            pushedCount += records.length;
          }
        }
        modulePushedCounts[moduleKey] = pushedCount;
      }

      // 3) Call NestJS /sync API endpoint within the retry policy
      final response = await _retry.run(() => UnifiedSyncRepository.instance.sync(
            deviceId: deviceId,
            lastSync: lastSync,
            pushData: pushData,
          ));

      // 4) Clean local dirty flags since the server accepted the push batch
      for (final ack in ackCallbacks) {
        await ack();
      }

      // 5) Process pulling data inside Drift transactions
      final pullObj = response['pull'] as Map<String, dynamic>? ?? {};
      final serverTimestamp = response['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch;

      for (final entry in _modules.entries) {
        final moduleKey = entry.key;
        final module = entry.value;

        var pulledCount = 0;
        var conflicts = 0;
        var maxServerUpdatedAt = 0;

        final dbAction = () async {
          for (final entity in module.entities) {
            final serverKey = _snakeToCamel(entity.entityKey);
            final recordsJson = pullObj[serverKey];
            if (recordsJson is List) {
              final records = recordsJson.cast<Map<String, dynamic>>();
              final outcome = await entity.processPull(records);
              pulledCount += outcome.pulled;
              conflicts += outcome.conflicts;
              if (outcome.maxServerUpdatedAtMs > maxServerUpdatedAt) {
                maxServerUpdatedAt = outcome.maxServerUpdatedAtMs;
              }
            }
          }
        };

        if (module.runInTransaction != null) {
          await module.runInTransaction!(dbAction);
        } else {
          await dbAction();
        }

        // Advance cursor to serverTimestamp safely
        final newCursor = serverTimestamp;
        final sinceMs = moduleKey == 'pocket_ledger' ? pocketCursor : tindaCursor;
        if (newCursor > sinceMs) {
          await _syncState.setLastPulledAt(moduleKey, newCursor);
        }

        final pending = await module.pendingCount();
        await _syncState.recordPush(
          moduleKey: moduleKey,
          success: true,
          pendingCount: pending,
        );

        final result = SyncResult(
          moduleKey: moduleKey,
          pulledCount: pulledCount,
          pushedCount: modulePushedCounts[moduleKey] ?? 0,
          conflictsResolved: conflicts,
          startedAt: startedAt,
          finishedAt: DateTime.now(),
        );
        _log(moduleKey, result);
        _publish(result);
        out.add(result);
      }
      return out;
    } catch (error, stack) {
      for (final moduleKey in _modules.keys) {
        await _syncState.recordPush(
          moduleKey: moduleKey,
          success: false,
          error: error.toString(),
        );
        final result = SyncResult(
          moduleKey: moduleKey,
          pulledCount: 0,
          pushedCount: 0,
          conflictsResolved: 0,
          error: error,
          startedAt: startedAt,
          finishedAt: DateTime.now(),
        );
        _log(moduleKey, result, stack: stack);
        _publish(result);
        out.add(result);
      }
      return out;
    }
  }

  /// Runs sync for a specific module by key. Returns `SyncResult.failed`
  /// for unknown keys. Binds directly to the unified execution model.
  Future<SyncResult> syncModule(String moduleKey) async {
    if (!_modules.containsKey(moduleKey)) {
      return SyncResult.failed(
        moduleKey,
        StateError('Unknown sync module: $moduleKey'),
      );
    }
    final results = await runOnce();
    return results.firstWhere(
      (r) => r.moduleKey == moduleKey,
      orElse: () => SyncResult.failed(moduleKey, StateError('Module not found')),
    );
  }

  void _publish(SyncResult result) {
    if (!_resultsController.isClosed) _resultsController.add(result);
  }

  void _log(String moduleKey, SyncResult r, {StackTrace? stack}) {
    developer.log(
      'pulled=${r.pulledCount} pushed=${r.pushedCount} '
      'conflicts=${r.conflictsResolved} error=${r.error}',
      name: 'sync.$moduleKey',
      error: r.error,
      stackTrace: stack,
    );
  }
}
