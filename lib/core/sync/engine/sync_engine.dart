import 'dart:async';
import 'dart:developer' as developer;

import '../../database/daos/app_meta_dao.dart';
import '../../database/daos/sync_state_dao.dart';
import '../sync_result.dart';
import 'retry_policy.dart';
import 'sync_module.dart';

/// The single public entry-point for triggering sync. UI code reads
/// `syncEngineProvider` (alias `syncOrchestratorProvider` is kept for
/// backwards compatibility) and calls [runOnce] / [syncAll] / per-module
/// helpers.
///
/// The engine is intentionally **module-agnostic**: it knows how to drive a
/// list of [SyncModule]s but never references any specific entity. New
/// entities are added by editing a bindings file, never by editing here.
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
  bool _isSyncing = false;

  final StreamController<SyncResult> _resultsController =
      StreamController<SyncResult>.broadcast();

  /// Broadcast stream of per-module [SyncResult]s. Listened to by the
  /// shell to trigger refreshes.
  Stream<SyncResult> get results => _resultsController.stream;

  /// Module keys registered with the engine.
  Iterable<String> get moduleKeys => _modules.keys;

  void dispose() => _resultsController.close();

  /// Runs every module once, coalescing concurrent callers.
  Future<List<SyncResult>> runOnce() async {
    if (_isSyncing) return const <SyncResult>[];
    _isSyncing = true;
    try {
      return await syncAll();
    } finally {
      _isSyncing = false;
    }
  }

  Future<List<SyncResult>> syncAll() async {
    final out = <SyncResult>[];
    for (final key in _modules.keys) {
      out.add(await syncModule(key));
    }
    return out;
  }

  /// Runs sync for a specific module by key. Returns `SyncResult.failed`
  /// for unknown keys so callers can defensively iterate without crashing.
  Future<SyncResult> syncModule(String moduleKey) async {
    final module = _modules[moduleKey];
    if (module == null) {
      return SyncResult.failed(
        moduleKey,
        StateError('Unknown sync module: $moduleKey'),
      );
    }

    final startedAt = DateTime.now();
    try {
      final deviceId = await _appMeta.getOrCreateDeviceId();
      final state = await _syncState.read(moduleKey);
      final sinceMs = state?.lastPulledAtMs ?? 0;

      // 1) Push first so the server incorporates local edits before we pull.
      final pushedCount = await module.push(_retry);

      // 2) Pull deltas since the per-module cursor.
      final pullOutcome = await module.pull(
        retry: _retry,
        deviceId: deviceId,
        sinceMs: sinceMs,
      );

      // 3) Advance cursor to the new local high-water mark (safe: monotonic
      //    and never moves backwards — `setLastPulledAt` is guarded).
      final newCursor = await module.maxUpdatedAt();
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
        pulledCount: pullOutcome.pulled,
        pushedCount: pushedCount,
        conflictsResolved: pullOutcome.conflicts,
        startedAt: startedAt,
        finishedAt: DateTime.now(),
      );
      _log(moduleKey, result);
      _publish(result);
      return result;
    } catch (error, stack) {
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
      return result;
    }
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
