import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/daos/app_meta_dao.dart';
import '../database/daos/sync_state_dao.dart';
import '../di/database_providers.dart';
import 'modules/pocket_ledger_sync.dart';
import 'modules/tinda_tracker_sync.dart';
import 'retry_policy.dart';
import 'sync_result.dart';

/// Coordinates per-module sync runs. The orchestrator is the only public
/// entry point — UI code calls [syncAll] / [syncPocketLedger] and never
/// touches DAOs or remote repositories directly.
///
/// Each module records its outcome via [SyncStateDao] so the UI can surface
/// "last synced at", "pending changes", and the most recent push error.
class SyncOrchestrator {
  SyncOrchestrator({
    required SyncStateDao syncStateDao,
    required AppMetaDao appMetaDao,
    required PocketLedgerSync pocketLedger,
    required TindaTrackerSync tindaTracker,
  }) : _syncState = syncStateDao,
       _appMeta = appMetaDao,
       _pocketLedger = pocketLedger,
       _tindaTracker = tindaTracker;

  final SyncStateDao _syncState;
  final AppMetaDao _appMeta;
  final PocketLedgerSync _pocketLedger;
  final TindaTrackerSync _tindaTracker;

  /// Re-entrancy guard so concurrent UI taps coalesce into one run.
  bool _isSyncing = false;

  final StreamController<SyncResult> _resultsController =
      StreamController<SyncResult>.broadcast();

  /// Broadcast stream of per-module [SyncResult]s. UI surfaces (e.g. the
  /// main shell) listen here to trigger refreshes when sync brings in new
  /// data.
  Stream<SyncResult> get results => _resultsController.stream;

  /// Disposes the broadcast controller. Called by the Riverpod provider's
  /// `onDispose` hook.
  void dispose() {
    _resultsController.close();
  }

  /// Runs every module once, coalescing concurrent callers. Returns the
  /// list of per-module results (also broadcast on [results]).
  Future<List<SyncResult>> runOnce() async {
    if (_isSyncing) return const <SyncResult>[];
    _isSyncing = true;
    try {
      return await syncAll();
    } finally {
      _isSyncing = false;
    }
  }

  /// Convenience: runs every module in series. Returns one [SyncResult] per
  /// module, in module-key order.
  Future<List<SyncResult>> syncAll() async {
    final results = <SyncResult>[];
    results.add(await syncPocketLedger());
    results.add(await syncTindaTracker());
    return results;
  }

  void _publish(SyncResult result) {
    if (!_resultsController.isClosed) {
      _resultsController.add(result);
    }
  }

  Future<SyncResult> syncPocketLedger() async {
    final startedAt = DateTime.now();
    const moduleKey = PocketLedgerSync.moduleKey;
    try {
      final deviceId = await _appMeta.getOrCreateDeviceId();
      final state = await _syncState.read(moduleKey);
      final sinceMs = state?.lastPulledAtMs ?? 0;

      // 1) Push local changes first so the server's authoritative state
      //    incorporates them before we pull.
      final pushedCount = await _pocketLedger.push();

      // 2) Pull server-side changes since the last successful pull.
      final pullOutcome = await _pocketLedger.pull(
        deviceId: deviceId,
        sinceMs: sinceMs,
      );

      // 3) Advance the cursor to the new max(updatedAt). We use the local
      //    high-water mark (which is now ≥ remote updatedAt because pulls
      //    were just applied) — safe lower bound, never moves backwards.
      final newCursor = await _pocketLedger.maxUpdatedAt();
      if (newCursor > sinceMs) {
        await _syncState.setLastPulledAt(moduleKey, newCursor);
      }

      final pending = await _pocketLedger.pendingCount();
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
      _pocketLedger.logResult(result);
      _publish(result);
      return result;
    } catch (error) {
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
      _pocketLedger.logResult(result);
      _publish(result);
      return result;
    }
  }

  Future<SyncResult> syncTindaTracker() async {
    final startedAt = DateTime.now();
    const moduleKey = TindaTrackerSync.moduleKey;
    try {
      final deviceId = await _appMeta.getOrCreateDeviceId();
      final state = await _syncState.read(moduleKey);
      final sinceMs = state?.lastPulledAtMs ?? 0;

      final pushedCount = await _tindaTracker.push();

      final pullOutcome = await _tindaTracker.pull(
        deviceId: deviceId,
        sinceMs: sinceMs,
      );

      final newCursor = await _tindaTracker.maxUpdatedAt();
      if (newCursor > sinceMs) {
        await _syncState.setLastPulledAt(moduleKey, newCursor);
      }

      final pending = await _tindaTracker.pendingCount();
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
      _tindaTracker.logResult(result);
      _publish(result);
      return result;
    } catch (error) {
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
      _tindaTracker.logResult(result);
      _publish(result);
      return result;
    }
  }
}

// ── Riverpod wiring ──────────────────────────────────────────────────────────

final syncStateDaoProvider = Provider<SyncStateDao>((ref) {
  return SyncStateDao(ref.watch(appDatabaseProvider));
});

final appMetaDaoProvider = Provider<AppMetaDao>((ref) {
  return AppMetaDao(ref.watch(appDatabaseProvider));
});

final pocketLedgerSyncProvider = Provider<PocketLedgerSync>((ref) {
  return PocketLedgerSync(
    ref.watch(appDatabaseProvider),
    retryPolicy: const RetryPolicy(),
  );
});

final tindaTrackerSyncProvider = Provider<TindaTrackerSync>((ref) {
  return TindaTrackerSync(
    ref.watch(appDatabaseProvider),
    retryPolicy: const RetryPolicy(),
  );
});

final syncOrchestratorProvider = Provider<SyncOrchestrator>((ref) {
  final orchestrator = SyncOrchestrator(
    syncStateDao: ref.watch(syncStateDaoProvider),
    appMetaDao: ref.watch(appMetaDaoProvider),
    pocketLedger: ref.watch(pocketLedgerSyncProvider),
    tindaTracker: ref.watch(tindaTrackerSyncProvider),
  );
  ref.onDispose(orchestrator.dispose);
  return orchestrator;
});
