class ApiConfig {
  ApiConfig._();

  static const String _defaultTunnelBaseUrl =
      'https://tfkdx2ql-8080.asse.devtunnels.ms/api';
  static const String _overrideBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultTunnelBaseUrl,
  );

  static String get baseUrl {
    final override = _overrideBaseUrl.trim();
    if (override.isNotEmpty) {
      final normalized = override.endsWith('/')
          ? override.substring(0, override.length - 1)
          : override;
      return normalized.endsWith('/api') ? normalized : '$normalized/api';
    }

    return _defaultTunnelBaseUrl;
  }
}
