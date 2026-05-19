import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

void main() async {
  sqfliteFfiInit();
  var databaseFactory = databaseFactoryFfi;
  var databasesPath = await databaseFactory.getDatabasesPath();
  var dbPath = p.join(databasesPath, 'tinda_track.db');
  print('DATABASE_PATH: $dbPath');
  if (await File(dbPath).exists()) {
    print('EXISTS: true');
  } else {
    print('EXISTS: false');
  }
  exit(0);
}
