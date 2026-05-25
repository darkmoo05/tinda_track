import '../database/app_database.dart';

class SyncConfig {
  SyncConfig._();

  static const String _defaultTunnelBaseUrl =
      'https://tfkdx2ql-8080.asse.devtunnels.ms/api';

  // Ordered fallback targets for tunnel-based development.
  static const List<String> fallbackBaseApiUrls = [_defaultTunnelBaseUrl];

  static const String defaultBaseApiUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultTunnelBaseUrl,
  );

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

  /// Returns a de-duplicated, normalized probe list where [currentBaseUrl]
  /// is tried first, followed by tunnel default and known fallbacks.
  static List<String> buildProbeCandidates(String currentBaseUrl) {
    final seen = <String>{};
    final ordered = <String>[];

    void add(String value) {
      final normalized = value.trim().replaceAll(RegExp(r'/+$'), '');
      if (normalized.isEmpty) return;
      if (seen.add(normalized)) ordered.add(normalized);
    }

    add(currentBaseUrl);
    add(defaultBaseApiUrl);
    for (final url in fallbackBaseApiUrls) {
      add(url);
    }
    return ordered;
  }
}
