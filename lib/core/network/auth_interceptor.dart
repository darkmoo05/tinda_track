import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_config.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  final FlutterSecureStorage _secureStorage;
  static const _tokenKey = 'jwt_access_token';
  static const _refreshTokenKey = 'jwt_refresh_token';

  static bool _isRefreshing = false;
  static final List<Completer<String?>> _refreshQueue = [];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Avoid appending headers if path is for login/register/refresh
    if (options.path.contains('/auth/login') ||
        options.path.contains('/auth/register') ||
        options.path.contains('/auth/refresh')) {
      return handler.next(options);
    }

    final token = await _secureStorage.read(key: _tokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final path = err.requestOptions.path;
      if (path.contains('/auth/login') ||
          path.contains('/auth/register') ||
          path.contains('/auth/refresh')) {
        return handler.next(err);
      }

      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      if (refreshToken == null || refreshToken.isEmpty) {
        return handler.next(err);
      }

      if (_isRefreshing) {
        // Another request is already refreshing the token.
        // Queue this request to wait for the new access token.
        final completer = Completer<String?>();
        _refreshQueue.add(completer);

        try {
          final newToken = await completer.future;
          if (newToken != null && newToken.isNotEmpty) {
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newToken';
            final dio = Dio();
            final response = await dio.fetch(options);
            return handler.resolve(response);
          }
        } catch (_) {
          // Fallback to error if waiting fails
        }
        return handler.next(err);
      }

      _isRefreshing = true;
      try {
        final success = await _refreshToken(refreshToken);
        if (success) {
          final newToken = await _secureStorage.read(key: _tokenKey);

          // Resolve all queued requests with the new access token
          for (final completer in _refreshQueue) {
            if (!completer.isCompleted) {
              completer.complete(newToken);
            }
          }
          _refreshQueue.clear();
          _isRefreshing = false;

          if (newToken != null && newToken.isNotEmpty) {
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newToken';
            final dio = Dio();
            final response = await dio.fetch(options);
            return handler.resolve(response);
          }
        } else {
          // If refresh fails, clear waiting queue
          for (final completer in _refreshQueue) {
            if (!completer.isCompleted) {
              completer.complete(null);
            }
          }
          _refreshQueue.clear();
          _isRefreshing = false;
          await _clearTokens();
        }
      } catch (e) {
        for (final completer in _refreshQueue) {
          if (!completer.isCompleted) {
            completer.complete(null);
          }
        }
        _refreshQueue.clear();
        _isRefreshing = false;
        await _clearTokens();
      }
    }
    return handler.next(err);
  }

  Future<bool> _refreshToken(String oldRefreshToken) async {
    try {
      final dio = Dio(BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
      ));

      final response = await dio.post(
        '/auth/refresh',
        data: {'refreshToken': oldRefreshToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final newAccessToken = data['accessToken'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;
        if (newAccessToken != null && newRefreshToken != null) {
          await _secureStorage.write(key: _tokenKey, value: newAccessToken);
          await _secureStorage.write(key: _refreshTokenKey, value: newRefreshToken);
          return true;
        }
      }
    } catch (_) {
      // Failed to refresh
    }
    return false;
  }

  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }
}

