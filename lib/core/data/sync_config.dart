import 'app_database.dart';

class SyncConfig {
  SyncConfig._();

  static const String defaultBaseApiUrl = 'http://192.168.1.24:8080/api';

  static const String _stateKey = 'api_base_url';

  /// Returns the user-configured URL from SQLite, falling back to the default.
  static Future<String> getBaseApiUrl() async {
    final stored = await AppDatabase.instance.getSyncState(_stateKey);
    if (stored != null && stored.trim().isNotEmpty) {
      return stored.trim();
    }
    return defaultBaseApiUrl;
  }

  /// Persists a new base URL so the next sync uses it immediately.
  static Future<void> setBaseApiUrl(String url) async {
    final normalized = url.trim().replaceAll(RegExp(r'/+$'), '');
    await AppDatabase.instance.setSyncState(_stateKey, normalized);
  }
}
