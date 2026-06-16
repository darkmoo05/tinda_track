import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/di/database_providers.dart';


const String _kSelectedSessionIdPrefKey = 'selected_monitoring_session_id';

bool disableSessionHealing = false;

/// A simple value class holding the live sum of all wallet deltas.
class LiveWalletBalances {
  const LiveWalletBalances({
    required this.gcash,
    required this.maya,
    required this.onHand,
  });

  final double gcash;
  final double maya;
  final double onHand;

  double get total => gcash + maya + onHand;
}

/// Streams the **live** sum of all non-deleted ledger entry deltas per wallet.
/// This reflects the actual current wallet balances regardless of session boundaries.
final liveWalletBalancesProvider = StreamProvider<LiveWalletBalances>((ref) {
  final db = ref.watch(currentAppDatabaseProvider);
  return db.customSelect(
    '''
    SELECT
      COALESCE(SUM(wallet_delta), 0.0)       AS gcash,
      COALESCE(SUM(maya_wallet_delta), 0.0)  AS maya,
      COALESCE(SUM(on_hand_delta), 0.0)      AS on_hand
    FROM ledger_entries
    WHERE COALESCE(is_deleted, 0) = 0
    ''',
    readsFrom: {db.ledgerEntries},
  ).watch().map((rows) {
    if (rows.isEmpty) {
      return const LiveWalletBalances(gcash: 0.0, maya: 0.0, onHand: 0.0);
    }
    final row = rows.first;
    return LiveWalletBalances(
      gcash: (row.data['gcash'] as num?)?.toDouble() ?? 0.0,
      maya: (row.data['maya'] as num?)?.toDouble() ?? 0.0,
      onHand: (row.data['on_hand'] as num?)?.toDouble() ?? 0.0,
    );
  });
});

/// A lightweight summary of a monitoring session used in the session-picker list.
class SessionSummary {
  const SessionSummary({required this.txCount, required this.netChange});

  /// Total ledger entries (all types) within this session's time window.
  final int txCount;

  /// Net combined wallet change (Σ deltas) within this session's time window.
  final double netChange;
}

/// Loads [SessionSummary] for a single session by its ID.
/// Results are cached by Riverpod for the lifetime of the provider.
final sessionSummaryProvider =
    FutureProvider.family<SessionSummary, String>((ref, sessionId) async {
  final db = ref.watch(currentAppDatabaseProvider);
  final session = await (db.select(db.monitoringSessions)
        ..where((t) => t.id.equals(sessionId))
        ..limit(1))
      .getSingleOrNull();

  if (session == null) {
    return const SessionSummary(txCount: 0, netChange: 0.0);
  }

  var sql = '''
    SELECT COUNT(*) AS cnt,
      COALESCE(SUM(wallet_delta), 0.0)
        + COALESCE(SUM(maya_wallet_delta), 0.0)
        + COALESCE(SUM(on_hand_delta), 0.0) AS net
    FROM ledger_entries
    WHERE COALESCE(is_deleted, 0) = 0
      AND created_at_ms >= ?
  ''';
  final vars = <Variable>[Variable.withInt(session.startDateMs)];

  if (session.endDateMs != null) {
    // Use strict less-than (<) so a transaction recorded at the exact millisecond
    // of the next session's start is NOT double-counted in both sessions.
    sql += ' AND created_at_ms < ?';
    vars.add(Variable.withInt(session.endDateMs!));
  }

  final result = await db.customSelect(sql, variables: vars).getSingleOrNull();
  return SessionSummary(
    txCount: (result?.data['cnt'] as int?) ?? 0,
    netChange: (result?.data['net'] as num?)?.toDouble() ?? 0.0,
  );
});

/// When [true], the Dashboard loads data from ALL sessions with no time filter.
/// Automatically reset to [false] when the user selects a specific session.
final allTimeViewProvider = StateProvider<bool>((ref) => false);

/// Exposes all monitoring sessions ordered by start date (newest first).
final monitoringSessionsStreamProvider = StreamProvider<List<MonitoringSessionRow>>((ref) {
  final db = ref.watch(currentAppDatabaseProvider);
  return (db.select(db.monitoringSessions)
        ..where((t) => t.isDeleted.equals(false))
        ..orderBy([
          (t) => OrderingTerm(expression: t.startDateMs, mode: OrderingMode.desc),
          (t) => OrderingTerm(expression: t.createdAtMs, mode: OrderingMode.desc),
        ]))
      .watch();
});

/// Exposes the currently active (unclosed) session from the database.
final activeSessionProvider = StreamProvider<MonitoringSessionRow?>((ref) {
  final db = ref.watch(currentAppDatabaseProvider);
  // A local closure variable persists for the lifetime of this provider instance.
  // Healing is only triggered when the active session ID actually changes, not on
  // every DB write that causes the stream to re-emit the same row.
  String? lastEmittedActiveId;
  return (db.select(db.monitoringSessions)
        ..where((t) => t.status.upper().equals('ACTIVE') & t.isDeleted.equals(false))
        ..limit(1))
      .watchSingleOrNull()
      .map((row) {
        final incomingId = row?.id;
        if (incomingId != lastEmittedActiveId) {
          lastEmittedActiveId = incomingId;
          if (row == null) {
            _healEmptySessions(db);
          } else {
            _healMultipleActiveSessions(db);
          }
        }
        return row;
      });
});

bool _isHealingEmpty = false;
bool _isHealingMultipleActive = false;

Future<void> _healEmptySessions(AppDatabase db) async {
  if (disableSessionHealing) return;
  if (_isHealingEmpty) return;
  _isHealingEmpty = true;
  try {
    final now = DateTime.now().millisecondsSinceEpoch;
    final check = await (db.select(db.monitoringSessions)
          ..where((t) => t.id.equals('default_session'))
          ..limit(1))
        .get();

    if (check.isEmpty) {
      final minTxQuery = await db.customSelect(
        "SELECT MIN(created_at_ms) as min_ms FROM ledger_entries WHERE COALESCE(is_deleted, 0) = 0"
      ).getSingleOrNull();
      final minMs = minTxQuery?.data['min_ms'] as num?;
      final startDate = minMs?.toInt() ?? now;

      await db.into(db.monitoringSessions).insert(
        MonitoringSessionsCompanion.insert(
          id: 'default_session',
          syncId: 'default_session',
          name: 'Default Monitoring',
          status: const Value('ACTIVE'),
          startDateMs: startDate,
          createdAtMs: now,
          updatedAtMs: now,
          startGcash: const Value(0.0),
          startMaya: const Value(0.0),
          startOnHand: const Value(0.0),
        ),
      );
    } else {
      final status = check.first.status;
      if (status.toUpperCase() == 'CLOSED') {
        final newId = const Uuid().v4();
        await db.into(db.monitoringSessions).insert(
          MonitoringSessionsCompanion.insert(
            id: newId,
            syncId: newId,
            name: 'Default Monitoring',
            status: const Value('ACTIVE'),
            startDateMs: now,
            createdAtMs: now,
            updatedAtMs: now,
            startGcash: const Value(0.0),
            startMaya: const Value(0.0),
            startOnHand: const Value(0.0),
          ),
        );
      }
    }
  } catch (e) {
    debugPrint('Error self-healing empty monitoring sessions: $e');
  } finally {
    _isHealingEmpty = false;
  }
}

Future<void> _healMultipleActiveSessions(AppDatabase db) async {
  if (disableSessionHealing) return;
  if (_isHealingMultipleActive) return;
  _isHealingMultipleActive = true;
  try {
    final activeSessions = await (db.select(db.monitoringSessions)
          ..where((t) => t.status.upper().equals('ACTIVE') & t.isDeleted.equals(false))
          ..orderBy([
            (t) => OrderingTerm(expression: t.startDateMs, mode: OrderingMode.desc),
            (t) => OrderingTerm(expression: t.createdAtMs, mode: OrderingMode.desc),
          ]))
        .get();

    if (activeSessions.length > 1) {
      debugPrint('[SessionHealing] Found ${activeSessions.length} active sessions. Healing...');
      for (final s in activeSessions) {
        debugPrint('[SessionHealing] Active session: id=${s.id}, startDateMs=${s.startDateMs}, status=${s.status}');
      }
      final now = DateTime.now().millisecondsSinceEpoch;

      await db.transaction(() async {
        // Keep the first one (newest) active, close all the others
        for (int i = 1; i < activeSessions.length; i++) {
          final active = activeSessions[i];
          final activeStartGcash = active.startGcash;
          final activeStartMaya = active.startMaya;
          final activeStartOnHand = active.startOnHand;

          final nextActive = activeSessions[i - 1];
          final nextActiveStartMs = nextActive.startDateMs;

          final balanceQuery = await db.customSelect('''
            SELECT 
              SUM(wallet_delta) as gcash,
              SUM(maya_wallet_delta) as maya,
              SUM(on_hand_delta) as on_hand
            FROM ledger_entries
            WHERE COALESCE(is_deleted, 0) = 0
              AND created_at_ms >= ?
              AND created_at_ms < ?
          ''', variables: [
            Variable.withInt(active.startDateMs),
            Variable.withInt(nextActiveStartMs),
          ]).getSingle();

          final activeDeltasGcash = (balanceQuery.data['gcash'] as num?)?.toDouble() ?? 0.0;
          final activeDeltasMaya = (balanceQuery.data['maya'] as num?)?.toDouble() ?? 0.0;
          final activeDeltasOnHand = (balanceQuery.data['on_hand'] as num?)?.toDouble() ?? 0.0;

          final closingGcash = activeStartGcash + activeDeltasGcash;
          final closingMaya = activeStartMaya + activeDeltasMaya;
          final closingOnHand = activeStartOnHand + activeDeltasOnHand;

          debugPrint('[SessionHealing] Closing older active session ${active.id}: GCash: $closingGcash, Maya: $closingMaya, OnHand: $closingOnHand');

          await (db.update(db.monitoringSessions)
                ..where((t) => t.id.equals(active.id)))
              .write(
            MonitoringSessionsCompanion(
              status: const Value('CLOSED'),
              endDateMs: Value(nextActiveStartMs),
              endGcash: Value(closingGcash),
              endMaya: Value(closingMaya),
              endOnHand: Value(closingOnHand),
              updatedAtMs: Value(now),
              isDirty: const Value(true), // Mark dirty so it syncs to server
            ),
          );
        }
      });
    }
  } catch (e) {
    debugPrint('[SessionHealing] Error healing multiple active sessions: $e');
  } finally {
    _isHealingMultipleActive = false;
  }
}


/// Notifier that manages the user's selected viewing session.
/// The selected session can be switched to past historical sessions (read-only mode).
class SelectedSessionNotifier extends StateNotifier<AsyncValue<MonitoringSessionRow?>> {
  SelectedSessionNotifier(this._ref) : super(const AsyncLoading()) {
    _init();
    // React to external active-session changes (sync writes, multi-device).
    _ref.listen<AsyncValue<MonitoringSessionRow?>>(
      activeSessionProvider,
      _onActiveSessionChanged,
    );
  }

  final Ref _ref;
  AppDatabase get _db => _ref.read(currentAppDatabaseProvider);

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString(_kSelectedSessionIdPrefKey);

      if (savedId != null && savedId.isNotEmpty) {
        final row = await (_db.select(_db.monitoringSessions)
              ..where((t) => t.id.equals(savedId) & t.isDeleted.equals(false))
              ..limit(1))
            .getSingleOrNull();

        if (row != null) {
          state = AsyncValue.data(row);
          return;
        }
      }

      // Fallback: Query active session directly from the database to avoid Riverpod lazy loading.
      final activeQuery = await (_db.select(_db.monitoringSessions)
            ..where((t) => t.status.upper().equals('ACTIVE') & t.isDeleted.equals(false))
            ..limit(1))
          .getSingleOrNull();

      if (activeQuery != null) {
        state = AsyncValue.data(activeQuery);
      } else {
        await _healEmptySessions(_db);
        final retryQuery = await (_db.select(_db.monitoringSessions)
              ..where((t) => t.status.upper().equals('ACTIVE') & t.isDeleted.equals(false))
              ..limit(1))
            .getSingleOrNull();
        if (retryQuery != null) {
          state = AsyncValue.data(retryQuery);
        } else {
          state = const AsyncValue.data(null);
        }
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Selects a specific session to view.
  Future<void> selectSession(MonitoringSessionRow session) async {
    state = AsyncValue.data(session);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSelectedSessionIdPrefKey, session.id);
  }

  /// Switches the selection back to the active session.
  Future<void> resetToActive() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSelectedSessionIdPrefKey);
    // Also clear the All-Time view flag so the Dashboard shows the active session.
    _ref.read(allTimeViewProvider.notifier).state = false;

    final activeQuery = await (_db.select(_db.monitoringSessions)
          ..where((t) => t.status.upper().equals('ACTIVE') & t.isDeleted.equals(false))
          ..limit(1))
        .getSingleOrNull();

    if (activeQuery != null) {
      state = AsyncValue.data(activeQuery);
    } else {
      await _healEmptySessions(_db);
      final retryQuery = await (_db.select(_db.monitoringSessions)
            ..where((t) => t.status.upper().equals('ACTIVE') & t.isDeleted.equals(false))
            ..limit(1))
          .getSingleOrNull();
      if (retryQuery != null) {
        state = AsyncValue.data(retryQuery);
      } else {
        state = const AsyncValue.data(null);
      }
    }
  }

  /// Closes the current session and starts a new one.
  Future<void> startNewSession(String name) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final newId = const Uuid().v4();

      await _db.transaction(() async {
        // 1. Query all active sessions directly from database (sorted newest first)
        final activeSessions = await (_db.select(_db.monitoringSessions)
              ..where((t) => t.status.upper().equals('ACTIVE') & t.isDeleted.equals(false))
              ..orderBy([
                (t) => OrderingTerm(expression: t.startDateMs, mode: OrderingMode.desc),
                (t) => OrderingTerm(expression: t.createdAtMs, mode: OrderingMode.desc),
              ]))
            .get();

        // 2. Loop through all active sessions, calculate their respective closing balances, and close them
        for (int i = 0; i < activeSessions.length; i++) {
          final active = activeSessions[i];
          final activeStartGcash = active.startGcash;
          final activeStartMaya = active.startMaya;
          final activeStartOnHand = active.startOnHand;

          final nextActiveStartMs = (i == 0) ? now : activeSessions[i - 1].startDateMs;

          final balanceQuery = await _db.customSelect('''
            SELECT 
              SUM(wallet_delta) as gcash,
              SUM(maya_wallet_delta) as maya,
              SUM(on_hand_delta) as on_hand
            FROM ledger_entries
            WHERE COALESCE(is_deleted, 0) = 0
              AND created_at_ms >= ?
              AND created_at_ms < ?
          ''', variables: [
            Variable.withInt(active.startDateMs),
            Variable.withInt(nextActiveStartMs),
          ]).getSingle();

          final activeDeltasGcash = (balanceQuery.data['gcash'] as num?)?.toDouble() ?? 0.0;
          final activeDeltasMaya = (balanceQuery.data['maya'] as num?)?.toDouble() ?? 0.0;
          final activeDeltasOnHand = (balanceQuery.data['on_hand'] as num?)?.toDouble() ?? 0.0;

          final closingGcash = activeStartGcash + activeDeltasGcash;
          final closingMaya = activeStartMaya + activeDeltasMaya;
          final closingOnHand = activeStartOnHand + activeDeltasOnHand;

          debugPrint('[SessionRollover] Closing active session ${active.id}: GCash: $closingGcash, Maya: $closingMaya, OnHand: $closingOnHand');

          await (_db.update(_db.monitoringSessions)
                ..where((t) => t.id.equals(active.id)))
              .write(
            MonitoringSessionsCompanion(
              status: const Value('CLOSED'),
              endDateMs: Value(nextActiveStartMs),
              endGcash: Value(closingGcash),
              endMaya: Value(closingMaya),
              endOnHand: Value(closingOnHand),
              updatedAtMs: Value(now),
              isDirty: const Value(true),
            ),
          );
        }

        // 3. Create new active session (starts fresh at zero)
        debugPrint('[SessionRollover] Creating new active session: $newId name: $name');
        await _db.into(_db.monitoringSessions).insert(
          MonitoringSessionsCompanion.insert(
            id: newId,
            syncId: newId,
            name: name,
            status: const Value('ACTIVE'),
            startDateMs: now,
            createdAtMs: now,
            updatedAtMs: now,
            startGcash: const Value(0.0),
            startMaya: const Value(0.0),
            startOnHand: const Value(0.0),
          ),
        );
      });

      // 4. Clear any pinned session preference and update state to the
      //    fresh active session. Using resetToActive() instead of
      //    selectSession() avoids writing the new UUID to SharedPreferences
      //    AND prevents a double-fire race with _onActiveSessionChanged
      //    (which also reacts to activeSessionProvider emitting the new row).
      await resetToActive();
    } catch (e, stack) {
      debugPrint('Error starting new monitoring session: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  // ── Reactive listener ───────────────────────────────────────────────────────────

  void _onActiveSessionChanged(
    AsyncValue<MonitoringSessionRow?>? previous,
    AsyncValue<MonitoringSessionRow?> next,
  ) {
    if (!next.hasValue) return;
    final prevId = previous?.value?.id;
    final nextId = next.value?.id;
    if (prevId == nextId) return;
    // Auto-update only when the user is currently viewing the session that changed,
    // or when the user has no selected session (state.value is null).
    if (state.value == null || state.value?.id == prevId) {
      state = next;
    }
  }

  // ── Mutation helpers ──────────────────────────────────────────────────────────

  /// Renames [id] to [newName]. Refreshes state if the renamed session is
  /// currently selected.
  Future<void> renameSession(String id, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    await (_db.update(_db.monitoringSessions)..where((t) => t.id.equals(id)))
        .write(
      MonitoringSessionsCompanion(
        name: Value(trimmed),
        updatedAtMs: Value(now),
        isDirty: const Value(true),
      ),
    );
    if (state.value?.id == id) {
      final q = await (_db.select(_db.monitoringSessions)..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (q != null) {
        state = AsyncValue.data(q);
      }
    }
  }

  /// Permanently deletes a closed session by [id].
  /// Returns null if successful, or an error message if it fails.
  Future<String?> deleteClosedSession(String id) async {
    try {
      debugPrint('[deleteClosedSession] Initiating delete for session ID: $id');
      
      // Print ALL sessions in the database for debugging
      final debugList = await _db.select(_db.monitoringSessions).get();
      debugPrint('[deleteClosedSession] Current sessions in DB (total: ${debugList.length}):');
      for (final s in debugList) {
        debugPrint('  - id=${s.id}, syncId=${s.syncId}, name="${s.name}", status=${s.status}, isDeleted=${s.isDeleted}, isDirty=${s.isDirty}');
      }

      // Guard 1: session must exist and be CLOSED.
      final sessionRow = await (_db.select(_db.monitoringSessions)
            ..where((t) => t.id.equals(id) & t.isDeleted.equals(false))
            ..limit(1))
          .getSingleOrNull();
      if (sessionRow == null) {
        // Check if it exists but is already deleted
        final checkDeleted = await (_db.select(_db.monitoringSessions)
              ..where((t) => t.id.equals(id)))
            .getSingleOrNull();
        if (checkDeleted != null) {
          debugPrint('[deleteClosedSession] Aborting: Session $id is already marked as deleted (isDeleted=true).');
          return 'Session is already deleted.';
        }
        debugPrint('[deleteClosedSession] Aborting: Session $id not found in database.');
        return 'Session not found in database.';
      }
      if (sessionRow.status.toUpperCase() == 'ACTIVE') {
        debugPrint('[deleteClosedSession] Aborting: Session $id is ACTIVE and cannot be deleted.');
        return 'Session is ACTIVE and cannot be deleted.';
      }

      // Guard 2: must not be the last remaining session.
      final allSessions = await (_db.select(_db.monitoringSessions)
            ..where((t) => t.isDeleted.equals(false)))
          .get();
      if (allSessions.length <= 1) {
        debugPrint('[deleteClosedSession] Aborting: Only ${allSessions.length} session(s) remaining in database.');
        return 'Cannot delete the last remaining session.';
      }

      // Use Drift's typed query builder instead of customStatement.
      // This ensures Drift is aware of the deletion and automatically
      // notifies all stream listeners/watchers to refresh the UI immediately.
      final now = DateTime.now().millisecondsSinceEpoch;
      final rowsAffected = await (_db.update(_db.monitoringSessions)
            ..where((t) => t.id.equals(id)))
          .write(
        MonitoringSessionsCompanion(
          isDeleted: const Value(true),
          isDirty: const Value(true),
          updatedAtMs: Value(now),
        ),
      );

      debugPrint('[deleteClosedSession] Deleted $rowsAffected session row(s) for ID $id');

      if (state.value?.id == id) {
        debugPrint('[deleteClosedSession] Session was active view state, resetting to active session.');
        await resetToActive();
      }
      
      if (rowsAffected > 0) {
        return null; // Success
      } else {
        return 'Delete statement matched 0 rows.';
      }
    } catch (e, stack) {
      debugPrint('Error deleting session $id: $e\n$stack');
      return 'Error: $e';
    }
  }

}

/// Provider managing the selected viewing session.
final selectedSessionProvider = StateNotifierProvider<SelectedSessionNotifier, AsyncValue<MonitoringSessionRow?>>((ref) {
  ref.watch(activeUsernameProvider);
  return SelectedSessionNotifier(ref);
});

/// Streams the session-specific current balances for the currently selected session.
final selectedSessionBalancesProvider = StreamProvider<LiveWalletBalances>((ref) {
  final db = ref.watch(currentAppDatabaseProvider);
  final selectedSessionAsync = ref.watch(selectedSessionProvider);

  return selectedSessionAsync.when(
    data: (selectedSession) {
      if (selectedSession == null) {
        return Stream.value(const LiveWalletBalances(gcash: 0.0, maya: 0.0, onHand: 0.0));
      }
      
      // If it is closed, just return its static end balances as the current balances.
      if (selectedSession.status.toUpperCase() == 'CLOSED') {
        return Stream.value(LiveWalletBalances(
          gcash: selectedSession.endGcash ?? 0.0,
          maya: selectedSession.endMaya ?? 0.0,
          onHand: selectedSession.endOnHand ?? 0.0,
        ));
      }

      // If it is active, stream startGcash + deltas in this session.
      // The upper-bound sub-query prevents transactions from a newer session
      // leaking into this balance during a transitional ACTIVE→CLOSED state.
      return db.customSelect(
        '''
        SELECT
          COALESCE(SUM(wallet_delta), 0.0)       AS gcash,
          COALESCE(SUM(maya_wallet_delta), 0.0)  AS maya,
          COALESCE(SUM(on_hand_delta), 0.0)      AS on_hand
        FROM ledger_entries
        WHERE COALESCE(is_deleted, 0) = 0
          AND created_at_ms >= ?
          AND created_at_ms < COALESCE(
            (SELECT MIN(start_date_ms)
             FROM monitoring_sessions
             WHERE start_date_ms > ?
               AND COALESCE(is_deleted, 0) = 0),
            9223372036854775807
          )
        ''',
        variables: [
          Variable.withInt(selectedSession.startDateMs),
          Variable.withInt(selectedSession.startDateMs),
        ],
        readsFrom: {db.ledgerEntries, db.monitoringSessions},
      ).watch().map((rows) {
        if (rows.isEmpty) {
          return LiveWalletBalances(
            gcash: selectedSession.startGcash,
            maya: selectedSession.startMaya,
            onHand: selectedSession.startOnHand,
          );
        }
        final row = rows.first;
        return LiveWalletBalances(
          gcash: selectedSession.startGcash + ((row.data['gcash'] as num?)?.toDouble() ?? 0.0),
          maya: selectedSession.startMaya + ((row.data['maya'] as num?)?.toDouble() ?? 0.0),
          onHand: selectedSession.startOnHand + ((row.data['on_hand'] as num?)?.toDouble() ?? 0.0),
        );
      });
    },
    loading: () => Stream.value(const LiveWalletBalances(gcash: 0.0, maya: 0.0, onHand: 0.0)),
    error: (e, st) => Stream.value(const LiveWalletBalances(gcash: 0.0, maya: 0.0, onHand: 0.0)),
  );
});
