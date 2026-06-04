import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../../network/api_client.dart';
import '../app_database.dart';
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
      // Restore the active username so the correct DB is opened on warm start.
      ref.read(activeUsernameProvider.notifier).state = username;
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

      // Point the database layer at this user's personal DB file.
      // Riverpod will open `tinda_track_user_<name>.sqlite` automatically.
      ref.read(activeUsernameProvider.notifier).state = name;

      await _repository.saveLastUsername(name);

      // Best-effort: delete DB files for other users that are fully synced.
      unawaited(_cleanupSyncedUserDatabases(activeUsername: name));

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

  /// Logs the current user out.
  ///
  /// **Does not delete the local database.** The user's SQLite file is
  /// preserved so that any unsynced offline data survives the session.
  /// The file is only deleted later (on next login) after a confirmed sync
  /// via [_cleanupSyncedUserDatabases].
  Future<void> logout() async {
    state = const AuthState.loading();

    // 1. Clear auth token from secure storage — this is the only destructive step.
    await _repository.logout();

    // 2. Reset the active username so the database provider is no longer pinned
    //    to this user. The underlying DB connection will be disposed by Riverpod
    //    when nothing else holds a reference to appDatabaseProvider(username).
    ref.read(activeUsernameProvider.notifier).state = '';

    state = const AuthState.unauthenticated();
  }

  // ---------------------------------------------------------------------------
  // Cleanup helper
  // ---------------------------------------------------------------------------

  /// Scans all per-user DB files in the app documents directory and deletes
  /// any that belong to a user **other than** [activeUsername] AND whose
  /// pending push count is zero (fully synced).
  ///
  /// Called on every successful login so stale files are eventually reclaimed
  /// without ever risking unsynced data loss.
  Future<void> _cleanupSyncedUserDatabases({
    required String activeUsername,
  }) async {
    try {
      final userFiles = await listUserDatabaseFiles();
      final activeFile = await resolveDatabaseFileForUser(activeUsername);

      for (final file in userFiles) {
        // Skip the currently active user's DB — it is in use.
        if (p.canonicalize(file.path) == p.canonicalize(activeFile.path)) continue;

        // Open a temporary, isolated, one-off connection using NativeDatabase
        // directly. This bypasses Drift's cache and prevents deadlocks or
        // closing active connections.
        final basename = file.path
            .split(RegExp(r'[\\/]'))
            .last
            .replaceAll('.sqlite', '');
        AppDatabase? tempDb;
        try {
          tempDb = AppDatabase.forExecutor(
            NativeDatabase(file),
          );

          // Count dirty rows across all tables by querying the sync_state
          // table's `pending_count` column which is maintained by the engine.
          // Add a short timeout so a locked DB file doesn't block cleanup indefinitely.
          final states = await tempDb.select(tempDb.syncState).get().timeout(
            const Duration(seconds: 1),
          );
          final totalPending = states.fold<int>(
            0,
            (sum, row) => sum + row.pendingPushCount,
          );

          if (totalPending == 0) {
            developer.log(
              'Deleting fully-synced DB for former user: $basename',
              name: 'auth.cleanup',
            );
            await tempDb.close().timeout(const Duration(seconds: 1));
            tempDb = null;
            await _deleteDbFiles(file);
          }
        } catch (e) {
          developer.log(
            'Could not inspect or clean up $basename: $e',
            name: 'auth.cleanup',
          );
        } finally {
          if (tempDb != null) {
            try {
              await tempDb.close().timeout(const Duration(seconds: 1));
            } catch (_) {}
          }
        }
      }
    } catch (e) {
      // Non-fatal — cleanup is best-effort.
      developer.log(
        'Error during stale DB cleanup: $e',
        name: 'auth.cleanup',
      );
    }
  }

  /// Deletes a SQLite database file together with its WAL and SHM sidecar files.
  Future<void> _deleteDbFiles(File mainFile) async {
    for (final path in [
      mainFile.path,
      '${mainFile.path}-wal',
      '${mainFile.path}-shm',
    ]) {
      final f = File(path);
      if (await f.exists()) await f.delete();
    }
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider), ref);
});



