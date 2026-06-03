abstract class AuthRepository {
  Future<Map<String, dynamic>> login(String username, String password);
  Future<Map<String, dynamic>> register(String username, String password, {String? role});
  Future<void> logout();
  Future<String?> getAccessToken();
  Future<bool> hasValidToken();
  Future<void> saveToken(String token);
  Future<String?> getLastUsername();
  Future<void> saveLastUsername(String username);
}
