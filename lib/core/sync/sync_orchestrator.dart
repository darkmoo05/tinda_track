import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/providers/database_providers.dart';
import 'bindings/pocket_ledger_bindings.dart';
import 'bindings/tinda_tracker_bindings.dart';
import 'engine/retry_policy.dart';
import 'engine/sync_engine.dart';
import 'sync_result.dart';

/// Thin backwards-compatibility facade over [SyncEngine] so the existing
/// `syncOrchestratorProvider` API used by `main.dart` and `main_shell.dart`
/// keeps working. New code should depend on [syncEngineProvider] directly.
///
/// Both providers return the same underlying engine instance.
class SyncOrchestrator {
  SyncOrchestrator(this._engine);
  final SyncEngine _engine;

  Stream<SyncResult> get results => _engine.results;

  Future<List<SyncResult>> runOnce() => _engine.runOnce();
  Future<List<SyncResult>> syncAll() => _engine.syncAll();
  Future<SyncResult> syncPocketLedger() => _engine.syncModule('pocket_ledger');
  Future<SyncResult> syncTindaTracker() => _engine.syncModule('tinda_tracker');
  Future<SyncResult> syncModule(String key) => _engine.syncModule(key);

  void dispose() => _engine.dispose();
}

// ── Riverpod wiring ──────────────────────────────────────────────────────────

/// Backwards-compatible alias for the consolidated provider. Existing
/// import paths (`core/sync/sync_orchestrator.dart`) continue to resolve.
final syncStateDaoProvider = databaseSyncStateDaoProvider;
final appMetaDaoProvider = databaseAppMetaDaoProvider;

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final engine = SyncEngine(
    syncStateDao: ref.watch(syncStateDaoProvider),
    appMetaDao: ref.watch(appMetaDaoProvider),
    retryPolicy: const RetryPolicy(),
    modules: [
      // BUG-16 fix: pass the singleton grouped-DAO facades so the bindings
      // do not silently construct a parallel set of per-table DAOs against
      // the same AppDatabase. Every cache and stream now has exactly one
      // source of truth.
      buildPocketLedgerModule(ref.watch(pocketLedgerDaoProvider)),
      buildTindaTrackerModule(ref.watch(tindaTrackerDaoProvider)),
    ],
  );
  ref.onDispose(engine.dispose);
  return engine;
});

final syncOrchestratorProvider = Provider<SyncOrchestrator>(
  (ref) => SyncOrchestrator(ref.watch(syncEngineProvider)),
);
