import 'package:shared_preferences/shared_preferences.dart';

/// Persists the JWT + a light cache of the logged-in user between app
/// launches (mirrors what the Angular app keeps in localStorage).
class TokenStorage {
  static const _tokenKey = 'lms_token';
  static const _userIdKey = 'lms_user_id';
  static const _userNameKey = 'lms_user_name';
  static const _userEmailKey = 'lms_user_email';
  static const _userRoleKey = 'lms_user_role';

  Future<void> saveSession({
    required String token,
    required int userId,
    required String name,
    required String email,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_userRoleKey, role);
  }

  Future<String?> readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<Map<String, dynamic>?> readCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final id = prefs.getInt(_userIdKey);
    final role = prefs.getString(_userRoleKey);
    if (token == null || id == null || role == null) return null;
    return {
      'token': token,
      'id': id,
      'name': prefs.getString(_userNameKey) ?? '',
      'email': prefs.getString(_userEmailKey) ?? '',
      'role': role,
    };
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userRoleKey);
  }
}
