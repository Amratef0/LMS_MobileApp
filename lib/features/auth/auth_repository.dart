import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/token_storage.dart';
import '../../models/user_model.dart';

class AuthRepository {
  AuthRepository({required ApiClient apiClient, required TokenStorage tokenStorage})
      : _api = apiClient,
        _storage = tokenStorage;

  final ApiClient _api;
  final TokenStorage _storage;

  /// POST /auth/login — same call the Angular login page makes.
  Future<AppUser> login(String email, String password) async {
    final res = await _api.post(ApiConstants.login, data: {
      'email': email,
      'password': password,
    });
    final token = res['token'] as String;
    final userJson = Map<String, dynamic>.from(res['user'] as Map);
    final user = AppUser.fromJson(userJson);
    await _storage.saveSession(
      token: token,
      userId: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
    );
    return user;
  }

  Future<AppUser?> readCachedUser() async {
    final cached = await _storage.readCachedUser();
    if (cached == null) return null;
    return AppUser(
      id: cached['id'] as int,
      name: cached['name'] as String,
      email: cached['email'] as String,
      role: cached['role'] as String,
    );
  }

  /// GET /users/profile — used on app start to make sure the stored token
  /// is still valid (not expired/revoked) before dropping the user into the
  /// app.
  Future<AppUser> verifySession() async {
    final res = await _api.get(ApiConstants.profile);
    return AppUser.fromJson(res);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _api.post(ApiConstants.changePassword, data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  Future<void> logout() => _storage.clear();
}
