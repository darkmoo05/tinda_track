import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinda_track/core/database/app_database.dart';
import 'package:tinda_track/core/di/database_providers.dart';
import 'package:tinda_track/pocket_ledger/features/more/logic/monitoring_session_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() async {
    disableSessionHealing = true; // Disable background healing by default during setup
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forExecutor(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [
        currentAppDatabaseProvider.overrideWithValue(db),
      ],
    );
    // Wait for the asynchronous provider initialization to complete
    while (container.read(selectedSessionProvider) is AsyncLoading) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
    // Clear any self-healed sessions to start with a clean slate
    await db.delete(db.monitoringSessions).go();
  });

  tearDown(() async {
    disableSessionHealing = false; // Reset to default
    await db.close();
    container.dispose();
  });

  test('Starts a new session, closing the old active one(s)', () async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Seed default session
    await db.into(db.monitoringSessions).insert(
      MonitoringSessionsCompanion.insert(
        id: 'default_session',
        syncId: 'default_session',
        name: 'Default Monitoring',
        status: const Value('ACTIVE'),
        startDateMs: now,
        createdAtMs: now,
        updatedAtMs: now,
      ),
    );

    // Verify there is 1 active session
    var activeSessions = await (db.select(db.monitoringSessions)
          ..where((t) => t.status.upper().equals('ACTIVE')))
        .get();
    expect(activeSessions.length, equals(1));
    expect(activeSessions.first.id, equals('default_session'));

    // Start a new session
    await container.read(selectedSessionProvider.notifier).startNewSession('Cycle #2');

    // Verify the old session is now closed and marked dirty for sync
    final oldSession = await (db.select(db.monitoringSessions)
          ..where((t) => t.id.equals('default_session')))
        .getSingle();
    expect(oldSession.status.toUpperCase(), equals('CLOSED'));
    expect(oldSession.endDateMs, isNotNull);
    expect(oldSession.isDirty, isTrue);

    // Verify the new active session is created
    activeSessions = await (db.select(db.monitoringSessions)
          ..where((t) => t.status.upper().equals('ACTIVE')))
        .get();
    expect(activeSessions.length, equals(1));
    expect(activeSessions.first.name, equals('Cycle #2'));
  });

  test('Deletes a closed session successfully and keeps active session', () async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // The system automatically self-heals and seeds 'default_session' as ACTIVE when we clear it.
    // Let's verify that default_session exists or seed it if not.
    final defaultSession = await (db.select(db.monitoringSessions)
          ..where((t) => t.id.equals('default_session')))
        .getSingleOrNull();

    if (defaultSession == null) {
      await db.into(db.monitoringSessions).insert(
        MonitoringSessionsCompanion.insert(
          id: 'default_session',
          syncId: 'default_session',
          name: 'Default Monitoring',
          status: const Value('ACTIVE'),
          startDateMs: now,
          createdAtMs: now,
          updatedAtMs: now,
        ),
      );
    }

    // Now seed 1 closed session
    await db.into(db.monitoringSessions).insert(
      MonitoringSessionsCompanion.insert(
        id: 'closed_session',
        syncId: 'closed_session',
        name: 'Closed Session',
        status: const Value('CLOSED'),
        startDateMs: now - 10000,
        endDateMs: Value(now),
        createdAtMs: now - 10000,
        updatedAtMs: now,
      ),
    );

    // Verify initial counts (default_session and closed_session)
    var allSessions = await db.select(db.monitoringSessions).get();
    expect(allSessions.length, equals(2));

    // Delete closed session
    final deleteError = await container.read(selectedSessionProvider.notifier).deleteClosedSession('closed_session');
    expect(deleteError, isNull);

    // Verify only 1 non-deleted session remains
    final activeSessionsOnly = await (db.select(db.monitoringSessions)..where((t) => t.isDeleted.equals(false))).get();
    expect(activeSessionsOnly.length, equals(1));
    expect(activeSessionsOnly.first.id, equals('default_session'));

    // Verify the soft-deleted session still exists in db but is marked deleted and dirty
    final deletedSession = await (db.select(db.monitoringSessions)..where((t) => t.id.equals('closed_session'))).getSingle();
    expect(deletedSession.isDeleted, isTrue);
    expect(deletedSession.isDirty, isTrue);

    // Try deleting the active session (should fail)
    final deleteErrorActive = await container.read(selectedSessionProvider.notifier).deleteClosedSession('default_session');
    expect(deleteErrorActive, isNotNull);

    // Verify active session was NOT soft-deleted
    final activeSessionRow = await (db.select(db.monitoringSessions)..where((t) => t.id.equals('default_session'))).getSingle();
    expect(activeSessionRow.isDeleted, isFalse);
  });

  test('Heals multiple active sessions automatically', () async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Seed two active sessions (different start times)
    await db.into(db.monitoringSessions).insert(
      MonitoringSessionsCompanion.insert(
        id: 'old_active_session',
        syncId: 'old_active_session',
        name: 'Old Active Cycle',
        status: const Value('ACTIVE'),
        startDateMs: now - 50000,
        createdAtMs: now - 50000,
        updatedAtMs: now - 50000,
      ),
    );

    await db.into(db.monitoringSessions).insert(
      MonitoringSessionsCompanion.insert(
        id: 'new_active_session',
        syncId: 'new_active_session',
        name: 'New Active Cycle',
        status: const Value('ACTIVE'),
        startDateMs: now,
        createdAtMs: now,
        updatedAtMs: now,
      ),
    );

    // Verify there are 2 active sessions initially
    var activeSessions = await (db.select(db.monitoringSessions)
          ..where((t) => t.status.upper().equals('ACTIVE') & t.isDeleted.equals(false)))
        .get();
    expect(activeSessions.length, equals(2));

    // Enable session healing now that setup is complete
    disableSessionHealing = false;

    // Read activeSessionProvider to trigger stream map (which runs the self-healing)
    final providerSubscription = container.listen(
      activeSessionProvider,
      (previous, next) {},
      fireImmediately: true,
    );

    // Wait for the stream update and self-healing transaction to finish
    await Future.delayed(const Duration(milliseconds: 100));

    // Disable healing again to protect assertions from concurrent triggers
    disableSessionHealing = true;

    // Verify that the old active session was closed and marked dirty
    final oldSession = await (db.select(db.monitoringSessions)
          ..where((t) => t.id.equals('old_active_session')))
        .getSingle();
    expect(oldSession.status.toUpperCase(), equals('CLOSED'));
    expect(oldSession.isDirty, isTrue);

    // Verify that the new active session remained active
    final newSession = await (db.select(db.monitoringSessions)
          ..where((t) => t.id.equals('new_active_session')))
        .getSingle();
    expect(newSession.status.toUpperCase(), equals('ACTIVE'));

    providerSubscription.close();
  });
}
