import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../network/api_client.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required ApiClient apiClient,
    FlutterSecureStorage? secureStorage,
  })  : _apiClient = apiClient,
        _secureStorage = secureStorage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
        );

  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage;
  static const _tokenKey = 'jwt_access_token';
  static const _refreshTokenKey = 'jwt_refresh_token';

  @override
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _apiClient.post('/auth/login', {
        'username': username,
        'password': password,
      });
      final data = response.data as Map<String, dynamic>;
      final token = data['accessToken'] as String?;
      final refreshToken = data['refreshToken'] as String?;
      if (token != null) {
        await saveToken(token);
      }
      if (refreshToken != null) {
        await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
      }
      return data;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> register(String username, String password, {String? role}) async {
    try {
      final payload = {
        'username': username,
        'password': password,
      };
      if (role != null) {
        payload['role'] = role;
      }
      final response = await _apiClient.post('/auth/register', payload);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        // Send a best-effort logout request to invalidate session on backend
        await _apiClient.post('/auth/logout', {'refreshToken': refreshToken}).timeout(
          const Duration(seconds: 4),
        );
      }
    } catch (_) {
      // Ignore background logout network errors
    } finally {
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
    }
  }

  @override
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  @override
  Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) return false;
    // Simple basic client-side check if token format looks like JWT
    return token.split('.').length == 3;
  }

  @override
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }
}

