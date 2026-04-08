import 'package:flutter/foundation.dart';
import 'package:plagit/config/env_config.dart';
import 'package:plagit/core/network/api_client.dart';
import 'package:plagit/core/network/api_error.dart';
import 'package:plagit/core/token_storage.dart';

/// Auth result returned from login/register.
class AuthResult {
  final String accessToken;
  final String? refreshToken;
  final String role; // 'candidate', 'business', 'admin'
  final String userId;
  final String name;
  final String email;

  const AuthResult({
    required this.accessToken,
    this.refreshToken,
    required this.role,
    required this.userId,
    required this.name,
    required this.email,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? json;
    return AuthResult(
      accessToken:
          json['accessToken'] as String? ?? json['token'] as String? ?? '',
      refreshToken: json['refreshToken'] as String?,
      role: user['role'] as String? ?? 'candidate',
      userId: (user['id'] ?? user['_id'] ?? '').toString(),
      name: user['name'] as String? ?? '',
      email: user['email'] as String? ?? '',
    );
  }
}

/// Central auth repository — mock in dev, real API in production.
class AuthRepository {
  final PlagitApiClient _api;

  AuthRepository({PlagitApiClient? api})
      : _api = api ?? PlagitApiClient.instance;

  bool get _useMock => EnvConfig.useMockData;

  static const _mockAccounts = {
    'candidate@test.com': AuthResult(
      accessToken: 'mock_candidate_token',
      refreshToken: 'mock_candidate_refresh',
      role: 'candidate',
      userId: 'mock_c_001',
      name: 'Test Candidate',
      email: 'candidate@test.com',
    ),
    'business@test.com': AuthResult(
      accessToken: 'mock_business_token',
      refreshToken: 'mock_business_refresh',
      role: 'business',
      userId: 'mock_b_001',
      name: 'Test Business',
      email: 'business@test.com',
    ),
    'admin@test.com': AuthResult(
      accessToken: 'mock_admin_token',
      refreshToken: 'mock_admin_refresh',
      role: 'admin',
      userId: 'mock_a_001',
      name: 'Admin User',
      email: 'admin@test.com',
    ),
  };

  /// Login. Returns [AuthResult] or throws [ApiError].
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final normalized = email.trim().toLowerCase();
    debugPrint('[AuthRepo] login($normalized, mock=$_useMock)');

    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      final mock = _mockAccounts[normalized];
      if (mock != null && password == 'test123') {
        await _persistSession(mock);
        return mock;
      }
      throw const ApiError(
        type: ApiErrorType.unauthorized,
        message: 'Invalid email or password',
      );
    }

    final resp = await _api.post('/auth/login', body: {
      'email': normalized,
      'password': password,
    });
    final result =
        AuthResult.fromJson(resp['data'] as Map<String, dynamic>? ?? resp);
    await _persistSession(result);
    return result;
  }

  /// Register. Returns [AuthResult] or throws.
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    debugPrint('[AuthRepo] register($email, role=$role, mock=$_useMock)');

    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      final result = AuthResult(
        accessToken: 'mock_${role}_token',
        refreshToken: 'mock_${role}_refresh',
        role: role,
        userId: 'mock_new_001',
        name: name,
        email: email.trim().toLowerCase(),
      );
      await _persistSession(result);
      return result;
    }

    final resp = await _api.post('/auth/signup', body: {
      'name': name,
      'email': email.trim().toLowerCase(),
      'password': password,
      'role': role,
    });
    final result =
        AuthResult.fromJson(resp['data'] as Map<String, dynamic>? ?? resp);
    await _persistSession(result);
    return result;
  }

  /// Request password reset.
  Future<void> forgotPassword(String email) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }
    await _api.post('/auth/forgot-password',
        body: {'email': email.trim().toLowerCase()});
  }

  /// Restore session from stored token. Returns null if no valid session.
  Future<AuthResult?> restoreSession() async {
    final token = await TokenStorage.getAccessToken();
    final role = await TokenStorage.getUserRole();
    debugPrint(
        '[AuthRepo] restoreSession(token=${token != null ? "YES" : "null"}, role=$role)');

    if (token == null || role == null) return null;

    // Mock tokens are always valid
    if (token.startsWith('mock_')) {
      return _mockAccounts['$role@test.com'];
    }

    // Real token: validate with /auth/me
    try {
      final resp = await _api.get('/auth/me');
      final data = resp['data'] as Map<String, dynamic>? ?? resp;
      return AuthResult(
        accessToken: token,
        role: data['role'] as String? ?? role,
        userId: (data['id'] ?? data['_id'] ?? '').toString(),
        name: data['name'] as String? ?? '',
        email: data['email'] as String? ?? '',
      );
    } on ApiError catch (e) {
      debugPrint('[AuthRepo] restoreSession failed: ${e.type} ${e.message}');
      await logout(); // Clear stale token on any API error
      return null;
    } catch (e) {
      debugPrint('[AuthRepo] restoreSession unexpected error: $e');
      await logout(); // Clear stale token to prevent stuck state
      return null;
    }
  }

  /// Clear session.
  Future<void> logout() async {
    debugPrint('[AuthRepo] logout()');
    await TokenStorage.clearAll();
  }

  Future<void> _persistSession(AuthResult result) async {
    await TokenStorage.saveTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    );
    await TokenStorage.saveUserRole(result.role);
  }
}
