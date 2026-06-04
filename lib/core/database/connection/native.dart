import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Resolves the absolute path of the **legacy** Drift database file.
/// Used only during the one-time sqflite → Drift migration check on startup.
Future<File> resolveDatabaseFile() async {
  final dir = await getApplicationDocumentsDirectory();
  return File(p.join(dir.path, 'tinda_track_drift.sqlite'));
}

/// Sanitizes a username so it is safe to use as part of a file name.
String _sanitizeUsername(String username) =>
    username.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_\-]'), '_');

/// Resolves the per-user Drift database [File].
///
/// Each user gets their own SQLite file:
///   `<documents>/tinda_track_user_<sanitized_username>.sqlite`
///
/// The file is intentionally **not** deleted on logout — it is only removed
/// after a confirmed full sync so offline data is never lost.
Future<File> resolveDatabaseFileForUser(String username) async {
  final dir = await getApplicationDocumentsDirectory();
  final safe = _sanitizeUsername(username);
  return File(p.join(dir.path, 'tinda_track_user_$safe.sqlite'));
}

/// Lists all per-user database files in the app documents directory.
///
/// Returns every file whose name matches `tinda_track_user_*.sqlite`.
Future<List<File>> listUserDatabaseFiles() async {
  final dir = await getApplicationDocumentsDirectory();
  final allFiles = dir.listSync().whereType<File>().toList();
  return allFiles
      .where((f) {
        final name = p.basename(f.path);
        return name.startsWith('tinda_track_user_') && name.endsWith('.sqlite');
      })
      .toList();
}

/// Opens a per-user [driftDatabase] connection for [username].
///
/// Automatically manages background isolates, native SQLite library bindings,
/// WAL journal modes, and robust cross-platform operations.
QueryExecutor openAppConnectionForUser(String username) {
  final safe = _sanitizeUsername(username);
  return driftDatabase(
    name: 'tinda_track_user_$safe',
    native: DriftNativeOptions(
      databasePath: () async {
        final file = await resolveDatabaseFileForUser(username);
        return file.path;
      },
      shareAcrossIsolates: true,
      setup: (db) {
        db.execute('PRAGMA foreign_keys = ON;');
        db.execute('PRAGMA journal_mode = WAL;');
        db.execute('PRAGMA synchronous = NORMAL;');
      },
    ),
  );
}

/// Creates a standard [driftDatabase] connection utilizing `drift_flutter` standards.
///
/// @deprecated Prefer [openAppConnectionForUser]. Kept for the legacy migration
/// path and for [AppDatabase] default constructor used in tests.
QueryExecutor openAppConnection() {
  return driftDatabase(
    name: 'tinda_track_drift',
    native: DriftNativeOptions(
      databasePath: () async {
        final file = await resolveDatabaseFile();
        return file.path;
      },
      shareAcrossIsolates: true,
      setup: (db) {
        db.execute('PRAGMA foreign_keys = ON;');
        db.execute('PRAGMA journal_mode = WAL;');
        db.execute('PRAGMA synchronous = NORMAL;');
      },
    ),
  );
}
