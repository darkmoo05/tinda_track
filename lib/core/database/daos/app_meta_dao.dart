import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables/shared_tables.dart';

part 'app_meta_dao.g.dart';

/// Generic key/value DAO. Backs `device_id`, `api_base_url`, and any future
/// scalar settings that don't deserve a dedicated table.
@DriftAccessor(tables: [AppMeta])
class AppMetaDao extends DatabaseAccessor<AppDatabase> with _$AppMetaDaoMixin {
  AppMetaDao(super.db);

  static const String _deviceIdKey = 'device_id';
  static const String _apiBaseUrlKey = 'api_base_url';

  Future<String?> get(String key) async {
    final row = await (select(
      appMeta,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> set(String key, String value) async {
    await into(appMeta).insertOnConflictUpdate(
      AppMetaCompanion(key: Value(key), value: Value(value)),
    );
  }

  /// Returns the persisted device id, creating one on first call.
  Future<String> getOrCreateDeviceId({Uuid? uuid}) async {
    final existing = await get(_deviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final generated = (uuid ?? const Uuid()).v4();
    await set(_deviceIdKey, generated);
    return generated;
  }

  Future<String?> getApiBaseUrl() => get(_apiBaseUrlKey);
  Future<void> setApiBaseUrl(String url) => set(_apiBaseUrlKey, url);
}
