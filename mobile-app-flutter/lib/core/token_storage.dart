import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Token storage with secure storage as primary and SharedPreferences as fallback.
/// Keychain can fail on simulator without entitlements, so we always write to both.
class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _accessTokenKey = 'plagit_access_token';
  static const _refreshTokenKey = 'plagit_refresh_token';
  static const _userRoleKey = 'plagit_user_role';

  static Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    // Always write to SharedPreferences as fallback
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    if (refreshToken != null) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    }
    // Try secure storage (may fail on simulator)
    try {
      await _storage.write(key: _accessTokenKey, value: accessToken);
      if (refreshToken != null) {
        await _storage.write(key: _refreshTokenKey, value: refreshToken);
      }
    } catch (_) {}
  }

  static Future<String?> getAccessToken() async {
    try {
      final token = await _storage.read(key: _accessTokenKey);
      if (token != null) return token;
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    try {
      final token = await _storage.read(key: _refreshTokenKey);
      if (token != null) return token;
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  static Future<void> saveUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userRoleKey, role);
    try {
      await _storage.write(key: _userRoleKey, value: role);
    } catch (_) {}
  }

  static Future<String?> getUserRole() async {
    try {
      final role = await _storage.read(key: _userRoleKey);
      if (role != null) return role;
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userRoleKey);
    try {
      await _storage.deleteAll();
    } catch (_) {}
  }
}
