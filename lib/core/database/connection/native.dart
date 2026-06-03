import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Resolves the absolute path of the Drift database file.
Future<File> resolveDatabaseFile() async {
  final dir = await getApplicationDocumentsDirectory();
  return File(p.join(dir.path, 'tinda_track_drift.sqlite'));
}

/// Creates a standard [driftDatabase] connection utilizing `drift_flutter` standards.
///
/// Automatically manages background isolates, native SQLite library bindings,
/// WAL journal modes, and robust cross-platform operations.
QueryExecutor openAppConnection() {
  return driftDatabase(
    name: 'tinda_track_drift',
    native: DriftNativeOptions(
      // Keep legacy file path location and name
      databasePath: () async {
        final file = await resolveDatabaseFile();
        return file.path;
      },
      // Safely share database connection across multiple isolates (e.g. background syncs)
      shareAcrossIsolates: true,
      setup: (db) {
        db.execute('PRAGMA foreign_keys = ON;');
        db.execute('PRAGMA journal_mode = WAL;');
        db.execute('PRAGMA synchronous = NORMAL;');
      },
    ),
  );
}
