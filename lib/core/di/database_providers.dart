import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';

/// Singleton-per-process [AppDatabase] provider.
///
/// Riverpod disposes the database when the app shuts down or the provider
/// container is torn down (tests). Feature DAOs and repositories should
/// depend on this provider rather than constructing a database directly.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
