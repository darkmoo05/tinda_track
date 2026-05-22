// ignore_for_file: avoid_print

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

void main() async {
  // Use the default desktop path logic without initializing the actual sqlite engine
  // which is usually where sqflite_ffi stores databases on Windows.
  String path;
  if (Platform.isWindows) {
    path = Platform.environment['LOCALAPPDATA'] ?? '';
  } else {
    path = await databaseFactoryFfi.getDatabasesPath();
  }
  print('LOCALAPPDATA: $path');
  exit(0);
}
