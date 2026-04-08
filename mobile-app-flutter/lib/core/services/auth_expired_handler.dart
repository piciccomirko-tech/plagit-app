import 'package:flutter/material.dart';
import 'package:plagit/core/network/api_error.dart';
import 'package:plagit/core/token_storage.dart';

/// Global handler for auth-expired errors.
///
/// When any authenticated API call returns 401/403 (invalid/expired token),
/// this handler clears stored tokens and navigates to /entry so the user
/// is never stuck inside a shell showing error screens.
class AuthExpiredHandler {
  AuthExpiredHandler._();

  static final instance = AuthExpiredHandler._();

  GlobalKey<NavigatorState>? _navigatorKey;
  bool _handling = false; // Prevent multiple simultaneous redirects

  /// Call once from main.dart to provide the navigator key.
  void initialize(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  /// Returns true if [error] is an auth-expired error that was handled
  /// (tokens cleared, navigation triggered). Providers should check this
  /// before storing the error string.
  bool handleIfAuthError(Object error) {
    if (error is! ApiError) return false;
    if (error.type != ApiErrorType.unauthorized &&
        error.type != ApiErrorType.forbidden) return false;

    if (_handling) return true; // Already redirecting
    _handling = true;

    debugPrint('[AuthExpiredHandler] Token expired — clearing session, redirecting to /entry');

    TokenStorage.clearAll().then((_) {
      final nav = _navigatorKey?.currentState;
      if (nav != null) {
        nav.pushNamedAndRemoveUntil('/entry', (_) => false);
      }
      // Reset after a short delay so the flag clears for future sessions
      Future.delayed(const Duration(seconds: 2), () => _handling = false);
    });

    return true;
  }
}
