import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/daos/app_meta_dao.dart';
import '../network/api_client.dart';
import 'sync_orchestrator.dart';

/// User-configurable backend URL persisted in `app_meta`.
///
/// Reads/writes go through [AppMetaDao]; on save, the [ApiClient]'s Dio
/// instance is updated in-place so the next request hits the new host
/// without a process restart.
class SyncConfig {
  SyncConfig._();

  static const String _defaultTunnelBaseUrl =
      'https://tfkdx2ql-8080.asse.devtunnels.ms/api';

  /// Compile-time override (e.g. `--dart-define=API_BASE_URL=...`). When set,
  /// it wins over the persisted value so CI/dev builds can pin a URL.
  static const String defaultBaseApiUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultTunnelBaseUrl,
  );

  static const List<String> fallbackBaseApiUrls = [_defaultTunnelBaseUrl];

  /// Returns the user-configured URL, falling back to the compile-time
  /// default when unset.
  static Future<String> getBaseApiUrl(AppMetaDao dao) async {
    final stored = await dao.getApiBaseUrl();
    if (stored != null && stored.trim().isNotEmpty) return stored.trim();
    return defaultBaseApiUrl;
  }

  /// Persists [url] and updates the live [ApiClient.dio] base URL so the
  /// next sync uses it immediately.
  static Future<void> setBaseApiUrl(AppMetaDao dao, String url) async {
    final normalized = _normalize(url);
    if (normalized.isEmpty) return;
    await dao.setApiBaseUrl(normalized);
    ApiClient.instance.dio.options = ApiClient.instance.dio.options.copyWith(
      baseUrl: normalized,
    );
  }

  /// Hydrates the live Dio base URL from the persisted setting. Call once
  /// during app startup before the first sync.
  static Future<void> hydrate(Ref ref) async {
    final dao = ref.read(appMetaDaoProvider);
    final url = await getBaseApiUrl(dao);
    ApiClient.instance.dio.options = ApiClient.instance.dio.options.copyWith(
      baseUrl: url,
    );
  }

  /// De-duplicated probe list — current URL first, then the compile-time
  /// default, then known fallbacks.
  static List<String> buildProbeCandidates(String currentBaseUrl) {
    final seen = <String>{};
    final ordered = <String>[];
    void add(String value) {
      final n = _normalize(value);
      if (n.isEmpty) return;
      if (seen.add(n)) ordered.add(n);
    }

    add(currentBaseUrl);
    add(defaultBaseApiUrl);
    for (final u in fallbackBaseApiUrls) {
      add(u);
    }
    return ordered;
  }

  static String _normalize(String url) =>
      url.trim().replaceAll(RegExp(r'/+$'), '');
}
