import 'package:flutter/foundation.dart';
import 'package:plagit/core/api_client.dart';
import 'package:plagit/core/token_storage.dart';
import 'package:plagit/models/user.dart';

/// Mock test accounts (debug mode only).
/// candidate@test.com / test123 → candidate home
/// business@test.com  / test123 → business home
/// admin@test.com     / test123 → admin home
const _mockAccounts = {
  'candidate@test.com': {
    'role': 'candidate',
    'user': {
      'id': 'mock_candidate_001',
      'email': 'candidate@test.com',
      'role': 'candidate',
      'name': 'Test Candidate',
      'first_name': 'Test',
      'last_name': 'Candidate',
    },
  },
  'business@test.com': {
    'role': 'business',
    'user': {
      'id': 'mock_business_001',
      'email': 'business@test.com',
      'role': 'business',
      'name': 'Test Restaurant',
      'first_name': 'Test',
      'last_name': 'Restaurant',
    },
  },
  'admin@test.com': {
    'role': 'admin',
    'user': {
      'id': 'mock_admin_001',
      'email': 'admin@test.com',
      'role': 'admin',
      'name': 'Test Admin',
      'first_name': 'Test',
      'last_name': 'Admin',
    },
  },
};

class AuthService {
  final _api = ApiClient();

  /// Try mock login first (debug only), then fall back to real API.
  Future<User> login({
    required String email,
    required String password,
    required String role,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    debugPrint('[AUTH_SVC] login() called for $normalizedEmail role=$role');

    // ── Mock auth (debug mode only) ──
    if (kDebugMode) {
      final mock = _mockAccounts[normalizedEmail];
      if (mock != null && password == 'test123') {
        debugPrint('[AUTH_SVC] MOCK LOGIN for $normalizedEmail');
        final mockRole = mock['role'] as String;
        await TokenStorage.saveTokens(
          accessToken: 'mock_token_${mockRole}_${DateTime.now().millisecondsSinceEpoch}',
        );
        await TokenStorage.saveUserRole(mockRole);
        return User.fromJson(mock['user'] as Map<String, dynamic>);
      }
    }

    // ── Real API login ──
    try {
      final resp = await _api.post('/auth/login', {
        'email': normalizedEmail,
        'password': password,
        'role': role,
      });
      final data = (resp['data'] ?? resp) as Map<String, dynamic>;
      final accessToken = (data['access_token'] ?? data['token']);
      await TokenStorage.saveTokens(
        accessToken: accessToken as String,
        refreshToken: (data['refresh_token'] ?? data['refreshToken']) as String?,
      );
      await TokenStorage.saveUserRole(role);
      return User.fromJson(data['user'] as Map<String, dynamic>);
    } catch (e) {
      // ── Fallback: if API fails in debug mode, retry with mock ──
      if (kDebugMode) {
        final mock = _mockAccounts[normalizedEmail];
        if (mock != null && password == 'test123') {
          debugPrint('[AUTH_SVC] API failed, falling back to MOCK LOGIN');
          final mockRole = mock['role'] as String;
          await TokenStorage.saveTokens(
            accessToken: 'mock_token_${mockRole}_${DateTime.now().millisecondsSinceEpoch}',
          );
          await TokenStorage.saveUserRole(mockRole);
          return User.fromJson(mock['user'] as Map<String, dynamic>);
        }
      }
      rethrow;
    }
  }

  /// Register candidate — mirrors CandidateAuthService.register().
  Future<User> registerCandidate({
    required String name,
    required String email,
    required String password,
    String? role,
    String? location,
    String? experience,
    String? languages,
    String? jobType,
  }) async {
    final resp = await _api.post('/auth/register/candidate', {
      'name': name,
      'email': email,
      'password': password,
      if (role != null) 'role': role,
      if (location != null) 'location': location,
      if (experience != null) 'experience': experience,
      if (languages != null) 'languages': languages,
      if (jobType != null) 'job_type': jobType,
    });
    final data = (resp['data'] ?? resp) as Map<String, dynamic>;
    await TokenStorage.saveTokens(
      accessToken: (data['access_token'] ?? data['token']) as String,
      refreshToken: (data['refresh_token'] ?? data['refreshToken']) as String?,
    );
    await TokenStorage.saveUserRole('candidate');
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  /// Register business — mirrors BusinessAuthService.register().
  Future<User> registerBusiness({
    required String companyName,
    required String email,
    required String password,
    String? contactPerson,
    String? venueType,
    String? location,
    String? requiredRole,
    String? jobType,
    bool openToInternational = false,
  }) async {
    final resp = await _api.post('/auth/register/business', {
      'company_name': companyName,
      'email': email,
      'password': password,
      if (contactPerson != null) 'contact_person': contactPerson,
      if (venueType != null) 'venue_type': venueType,
      if (location != null) 'location': location,
      if (requiredRole != null) 'required_role': requiredRole,
      if (jobType != null) 'job_type': jobType,
      'open_to_international': openToInternational,
    });
    final data = (resp['data'] ?? resp) as Map<String, dynamic>;
    await TokenStorage.saveTokens(
      accessToken: (data['access_token'] ?? data['token']) as String,
      refreshToken: (data['refresh_token'] ?? data['refreshToken']) as String?,
    );
    await TokenStorage.saveUserRole('business');
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await TokenStorage.clearAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await TokenStorage.getAccessToken();
    return token != null;
  }
}
