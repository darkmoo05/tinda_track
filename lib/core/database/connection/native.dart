import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

/// Resolves the absolute path of the Drift database file (same directory as
/// the historical sqflite database, but a new filename).
Future<File> resolveDatabaseFile() async {
  final dir = await getApplicationDocumentsDirectory();
  return File(p.join(dir.path, 'tinda_track_drift.sqlite'));
}

/// Creates a [LazyDatabase] that opens the SQLite file on first use.
///
/// Enables WAL + foreign keys, and installs a temporary-directory workaround
/// on Android to silence the "cannot determine temp dir" warning.
QueryExecutor openAppConnection() {
  return LazyDatabase(() async {
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    final file = await resolveDatabaseFile();
    final cache = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cache;

    return NativeDatabase.createInBackground(
      file,
      logStatements: false,
      setup: (db) {
        db.execute('PRAGMA foreign_keys = ON;');
        db.execute('PRAGMA journal_mode = WAL;');
        db.execute('PRAGMA synchronous = NORMAL;');
      },
    );
  });
}
