import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../sync/engine/sync_errors.dart';
import 'api_config.dart';
import 'auth_interceptor.dart';

class ApiClient {
  ApiClient._()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Content-Type': 'application/json'},
        ),
      ) {
    _dio.interceptors.add(AuthInterceptor());
    _setupSSLPinning();
  }

  void _setupSSLPinning() {
    final adapter = _dio.httpClientAdapter;
    if (adapter is IOHttpClientAdapter) {
      adapter.createHttpClient = () {
        final context = SecurityContext(withTrustedRoots: true);
        final client = HttpClient(context: context);
        
        client.badCertificateCallback = (cert, host, port) {
          final isProd = const bool.fromEnvironment('dart.vm.product');
          if (!isProd) {
            // Allow self-signed certs or proxy tools only during local dev
            return true;
          }
          return false; // Reject all invalid certificates in production
        };
        return client;
      };
    }
  }

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

  /// Fetches a sync `/pull` endpoint and returns the `data` envelope as a
  /// `List<Map<String, dynamic>>`, throwing a [SchemaSyncError] when the
  /// response is not the expected JSON shape (e.g. an HTML login page from
  /// a closed Dev Tunnel, an empty 200 from a misconfigured proxy, or a
  /// payload missing the `data` key).
  ///
  /// Network/server failures are re-thrown as Dio exceptions and the
  /// retry policy handles them; only schema violations short-circuit.
  Future<List<Map<String, dynamic>>> getJsonList(
    String path, {
    Map<String, dynamic>? params,
  }) async {
    final res = await _dio.get(path, queryParameters: params);
    final ct = res.headers.value('content-type') ?? '';
    if (!ct.toLowerCase().contains('application/json')) {
      throw SchemaSyncError(
        'GET $path returned non-JSON content-type "$ct" '
        '(status ${res.statusCode}). The endpoint may be behind '
        'an auth gate or proxy login page.',
      );
    }
    final body = res.data;
    if (body is! Map<String, dynamic>) {
      throw SchemaSyncError(
        'GET $path returned a top-level ${body.runtimeType}, expected '
        'an object with a "data" array.',
      );
    }
    final data = body['data'];
    if (data is! List) {
      throw SchemaSyncError(
        'GET $path response missing "data" array '
        '(got ${data.runtimeType}).',
      );
    }
    return data.cast<Map<String, dynamic>>();
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
