import 'package:drift/drift.dart';

/// Per-module sync metadata.
///
/// One row per logical module (e.g. `pocket_ledger`, `tinda_tracker`).
/// `last_pulled_at_ms` is the millis-since-epoch cursor used for delta pulls
/// (`since=` query param on the backend).
///
/// `last_push_attempt_at_ms` and `last_push_error` support retry / backoff
/// telemetry visible to the user.
@DataClassName('SyncStateRow')
class SyncState extends Table {
  TextColumn get moduleKey => text()();
  IntColumn get lastPulledAtMs => integer().withDefault(const Constant(0))();
  IntColumn get lastPushedAtMs => integer().withDefault(const Constant(0))();
  IntColumn get lastPushAttemptAtMs =>
      integer().withDefault(const Constant(0))();
  TextColumn get lastPushError => text().nullable()();
  IntColumn get pendingPushCount => integer().withDefault(const Constant(0))();
  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column> get primaryKey => {moduleKey};

  @override
  String? get tableName => 'sync_state';
}

/// Generic key/value store for app-wide settings that aren't worth their own
/// table — e.g. `device_id`, `api_base_url`. Read via [AppMetaDao].
@DataClassName('AppMetaRow')
class AppMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};

  @override
  String? get tableName => 'app_meta';
}
