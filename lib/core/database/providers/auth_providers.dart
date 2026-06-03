import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../network/api_client.dart';
import '../connection/native.dart';
import '../repositories/auth_repository.dart';
import '../repositories/auth_repository_impl.dart';
import 'database_providers.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  const AuthState({
    required this.status,
    this.errorMessage,
    this.username,
    this.role,
  });

  const AuthState.initial()
      : status = AuthStatus.initial,
        errorMessage = null,
        username = null,
        role = null;

  const AuthState.loading()
      : status = AuthStatus.loading,
        errorMessage = null,
        username = null,
        role = null;

  const AuthState.authenticated({required this.username, required this.role})
      : status = AuthStatus.authenticated,
        errorMessage = null;

  const AuthState.unauthenticated()
      : status = AuthStatus.unauthenticated,
        errorMessage = null,
        username = null,
        role = null;

  const AuthState.error(String message)
      : status = AuthStatus.error,
        errorMessage = message,
        username = null,
        role = null;

  final AuthStatus status;
  final String? errorMessage;
  final String? username;
  final String? role;

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(apiClient: ApiClient.instance);
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository, this.ref) : super(const AuthState.initial()) {
    checkAuth();
  }

  final AuthRepository _repository;
  final Ref ref;

  Map<String, dynamic> _decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return {};
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      return json.decode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<void> checkAuth() async {
    state = const AuthState.loading();
    final token = await _repository.getAccessToken();
    if (token != null && token.isNotEmpty && token.split('.').length == 3) {
      final payload = _decodeJwt(token);
      final username = payload['username'] as String? ?? 'User';
      final role = payload['role'] as String? ?? 'OWNER';
      state = AuthState.authenticated(username: username, role: role);
    } else {
      state = const AuthState.unauthenticated();
    }
  }

  Future<bool> login(String username, String password) async {
    state = const AuthState.loading();
    try {
      final res = await _repository.login(username, password);
      final user = res['user'] as Map<String, dynamic>?;
      final name = user?['username'] as String? ?? username;
      final role = user?['role'] as String? ?? 'OWNER';
      state = AuthState.authenticated(username: name, role: role);
      return true;
    } catch (e) {
      state = AuthState.error(e.toString().replaceAll('DioException:', ''));
      return false;
    }
  }

  Future<bool> register(String username, String password, {String role = 'OWNER'}) async {
    state = const AuthState.loading();
    try {
      await _repository.register(username, password, role: role);
      // Automatically login after successful registration
      return await login(username, password);
    } catch (e) {
      state = AuthState.error(e.toString().replaceAll('DioException:', ''));
      return false;
    }
  }

  Future<void> logout() async {
    state = const AuthState.loading();
    try {
      // 1. Close the database connection
      final db = ref.read(appDatabaseProvider);
      await db.close();

      // 2. Delete the local SQLite database files
      final file = await resolveDatabaseFile();
      if (await file.exists()) {
        await file.delete();
      }
      final walFile = File('${file.path}-wal');
      if (await walFile.exists()) {
        await walFile.delete();
      }
      final shmFile = File('${file.path}-shm');
      if (await shmFile.exists()) {
        await shmFile.delete();
      }
    } catch (e) {
      developer.log(
        'Error wiping database on logout',
        name: 'auth.logout',
        error: e,
      );
    }

    // 3. Clear auth token from secure storage
    await _repository.logout();

    // 4. Invalidate database provider to recreate database next time it is read
    ref.invalidate(appDatabaseProvider);

    state = const AuthState.unauthenticated();
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider), ref);
});
