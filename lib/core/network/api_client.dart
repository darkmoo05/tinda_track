import 'package:dio/dio.dart';
import 'api_config.dart';

class ApiClient {
  ApiClient._()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Content-Type': 'application/json'},
        ),
      );

  static final ApiClient instance = ApiClient._();

  final Dio _dio;

  Dio get dio => _dio;

  Future<Response> get(String path, {Map<String, dynamic>? params}) {
    return _dio.get(path, queryParameters: params);
  }

  Future<Response> post(String path, dynamic data) {
    return _dio.post(path, data: data);
  }

  Future<Response> patch(String path, dynamic data) {
    return _dio.patch(path, data: data);
  }

  Future<Response> delete(String path) {
    return _dio.delete(path);
  }

  /// Origin of the live API server (scheme + host + port), derived from
  /// the current Dio `baseUrl` so it reflects any runtime override the
  /// user applied via the settings screen.
  String get _serverOrigin {
    final url = _dio.options.baseUrl.isNotEmpty
        ? _dio.options.baseUrl
        : ApiConfig.baseUrl;
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    return Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
    ).toString();
  }

  /// Turns a server-supplied image reference into an absolute URL safe to
  /// hand to `Image.network` / `CachedNetworkImage` / `NetworkImage`.
  ///
  /// - Returns `null` for null/empty input.
  /// - Returns absolute `http(s)` URLs unchanged.
  /// - Prefixes relative paths (e.g. `/uploads/products/foo.webp`) with
  ///   the live server origin so they aren't interpreted as
  ///   `file:///uploads/...` (which crashes with
  ///   `No host specified in URI`).
  String? resolveImageUrl(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$_serverOrigin$path';
  }
}

/// Top-level convenience: `resolveImageUrl(product.imageUrl)`. Always
/// reads the live base URL from [ApiClient.instance].
String? resolveImageUrl(String? raw) => ApiClient.instance.resolveImageUrl(raw);
