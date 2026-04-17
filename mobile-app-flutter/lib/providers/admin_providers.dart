/// ChangeNotifier providers for all admin-side state.
///
/// Follows the same three-state pattern as candidate/business providers:
/// loading -> error (with retry) -> content.
library;

import 'package:flutter/material.dart';
import 'package:plagit/config/env_config.dart';
import 'package:plagit/core/auth/user_role.dart';
import 'package:plagit/core/services/auth_expired_handler.dart';
import 'package:plagit/models/admin_notification.dart';
import 'package:plagit/repositories/admin_repository.dart';
import 'package:plagit/repositories/auth_repository.dart';

// ================================================================
// Auth — admin/super_admin authentication
// ================================================================

class AdminAuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isRestoring = true;
  UserRole _role = UserRole.admin;
  String? _userName;
  String? _userEmail;
  String? _userId;
  final AuthRepository _authRepo;

  AdminAuthProvider({AdminRepository? repo, AuthRepository? authRepo})
      : _authRepo = authRepo ?? AuthRepository();

  bool get isAuthenticated => _isAuthenticated;
  bool get isRestoring => _isRestoring;
  UserRole get role => _role;
  String get userName => _userName ?? 'Admin';
  String get userEmail => _userEmail ?? '';
  String get userId => _userId ?? '';
  bool get isSuperAdmin => _role == UserRole.superAdmin;

  /// Login via AuthRepository. Rejects non-admin roles.
  Future<void> login(String email, String password) async {
    final result = await _authRepo.login(email: email, password: password);
    final parsedRole = UserRole.fromString(result.role);

    if (!parsedRole.isAdmin) {
      // Clear the persisted session — this account isn't admin
      await _authRepo.logout();
      throw Exception('This account does not have admin access');
    }

    _role = parsedRole;
    _userName = result.name;
    _userEmail = result.email;
    _userId = result.userId;
    _isAuthenticated = true;
    notifyListeners();
  }

  /// Restore session from stored token.
  Future<void> restoreSession() async {
    _isRestoring = true;
    notifyListeners();
    try {
      final result = await _authRepo.restoreSession();
      if (result != null) {
        final parsedRole = UserRole.fromString(result.role);
        if (parsedRole.isAdmin) {
          _role = parsedRole;
          _userName = result.name;
          _userEmail = result.email;
          _userId = result.userId;
          _isAuthenticated = true;
        }
      }
    } catch (_) {
      // No valid session — stay logged out
    }
    _isRestoring = false;
    notifyListeners();
  }

  /// Clear auth state and tokens.
  Future<void> logout() async {
    await _authRepo.logout();
    _isAuthenticated = false;
    _userName = null;
    _userEmail = null;
    _userId = null;
    _role = UserRole.admin;
    notifyListeners();
  }
}

// ================================================================
// Dashboard
// ================================================================

class AdminDashboardProvider extends ChangeNotifier {
  Map<String, dynamic>? _stats;
  bool _loading = true;
  String? _error;
  final AdminRepository _repo;

  AdminDashboardProvider({AdminRepository? repo})
      : _repo = repo ?? AdminRepository();

  Map<String, dynamic>? get stats => _stats;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _stats = await _repo.fetchDashboardStats();
    } catch (e) {
      if (!EnvConfig.useMockData && AuthExpiredHandler.instance.handleIfAuthError(e)) {
        return;
      }
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }
}

// ================================================================
// Notifications
// ================================================================

class AdminNotificationsProvider extends ChangeNotifier {
  List<AdminNotification> _items = [];
  bool _loading = true;
  String? _error;
  final AdminRepository _repo;

  AdminNotificationsProvider({AdminRepository? repo})
      : _repo = repo ?? AdminRepository();

  List<AdminNotification> get items => _items;
  int get unreadCount => _items.where((n) => !n.isRead).length;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _repo.fetchNotifications();
    } catch (e) {
      if (!EnvConfig.useMockData && AuthExpiredHandler.instance.handleIfAuthError(e)) {
        return;
      }
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> markRead(String id) async {
    try {
      await _repo.markNotificationRead(id);
    } catch (_) {}
    final idx = _items.indexWhere((n) => n.id == id);
    if (idx >= 0) {
      final old = _items[idx];
      _items[idx] = AdminNotification(
        id: old.id,
        type: old.type,
        title: old.title,
        body: old.body,
        createdAt: old.createdAt,
        isRead: true,
        actionRoute: old.actionRoute,
      );
      notifyListeners();
    }
  }
}

// ================================================================
// Admin list providers — typed wrappers for each list endpoint
// ================================================================

abstract class _AdminListBase extends ChangeNotifier {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> get items => _items;
  bool get loading => _loading;
  String? get error => _error;

  Future<List<Map<String, dynamic>>> fetchFromRepo();

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await fetchFromRepo();
    } catch (e) {
      if (!EnvConfig.useMockData && AuthExpiredHandler.instance.handleIfAuthError(e)) {
        return;
      }
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  void updateItem(String id, Map<String, dynamic> Function(Map<String, dynamic>) updater) {
    final idx = _items.indexWhere((item) => item['id'] == id);
    if (idx >= 0) {
      _items[idx] = updater(_items[idx]);
      notifyListeners();
    }
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item['id'] == id);
    notifyListeners();
  }
}

class AdminCandidatesListProvider extends _AdminListBase {
  final AdminRepository _repo;
  AdminCandidatesListProvider({AdminRepository? repo}) : _repo = repo ?? AdminRepository();
  @override Future<List<Map<String, dynamic>>> fetchFromRepo() => _repo.fetchCandidates();
}

class AdminBusinessesListProvider extends _AdminListBase {
  final AdminRepository _repo;
  AdminBusinessesListProvider({AdminRepository? repo}) : _repo = repo ?? AdminRepository();
  @override Future<List<Map<String, dynamic>>> fetchFromRepo() => _repo.fetchBusinesses();
}

class AdminJobsListProvider extends _AdminListBase {
  final AdminRepository _repo;
  AdminJobsListProvider({AdminRepository? repo}) : _repo = repo ?? AdminRepository();
  @override Future<List<Map<String, dynamic>>> fetchFromRepo() => _repo.fetchJobs();
}

class AdminApplicationsListProvider extends _AdminListBase {
  final AdminRepository _repo;
  AdminApplicationsListProvider({AdminRepository? repo}) : _repo = repo ?? AdminRepository();
  @override Future<List<Map<String, dynamic>>> fetchFromRepo() => _repo.fetchApplications();
}

class AdminInterviewsListProvider extends _AdminListBase {
  final AdminRepository _repo;
  AdminInterviewsListProvider({AdminRepository? repo}) : _repo = repo ?? AdminRepository();
  @override Future<List<Map<String, dynamic>>> fetchFromRepo() => _repo.fetchInterviews();
}

class AdminVerificationsListProvider extends _AdminListBase {
  final AdminRepository _repo;
  AdminVerificationsListProvider({AdminRepository? repo}) : _repo = repo ?? AdminRepository();
  @override Future<List<Map<String, dynamic>>> fetchFromRepo() => _repo.fetchVerifications();
}

class AdminReportsListProvider extends _AdminListBase {
  final AdminRepository _repo;
  AdminReportsListProvider({AdminRepository? repo}) : _repo = repo ?? AdminRepository();
  @override Future<List<Map<String, dynamic>>> fetchFromRepo() => _repo.fetchReports();
}

class AdminSupportListProvider extends _AdminListBase {
  final AdminRepository _repo;
  AdminSupportListProvider({AdminRepository? repo}) : _repo = repo ?? AdminRepository();
  @override Future<List<Map<String, dynamic>>> fetchFromRepo() => _repo.fetchSupportIssues();
}

// ================================================================
// Admin Actions — executes admin operations with loading feedback
// ================================================================

class AdminActionsProvider extends ChangeNotifier {
  bool _busy = false;
  String? _lastError;
  String? _lastSuccess;
  final AdminRepository _repo;

  AdminActionsProvider({AdminRepository? repo})
      : _repo = repo ?? AdminRepository();

  bool get busy => _busy;
  String? get lastError => _lastError;
  String? get lastSuccess => _lastSuccess;

  void clearMessages() {
    _lastError = null;
    _lastSuccess = null;
  }

  Future<bool> _run(String label, Future<void> Function() action) async {
    _busy = true;
    _lastError = null;
    _lastSuccess = null;
    notifyListeners();
    try {
      await action();
      _lastSuccess = label;
      _busy = false;
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = '$label failed: $e';
      _busy = false;
      notifyListeners();
      return false;
    }
  }

  // ── User actions ──
  Future<bool> verifyUser(String userId) => _run('User verified', () => _repo.verifyUser(userId));
  Future<bool> unverifyUser(String userId) => _run('Verification removed', () => _repo.unverifyUser(userId));
  Future<bool> suspendUser(String userId) => _run('User suspended', () => _repo.suspendUser(userId));
  Future<bool> unsuspendUser(String userId) => _run('User reactivated', () => _repo.unsuspendUser(userId));

  // ── Business actions ──
  Future<bool> approveBusiness(String businessId) => _run('Business approved', () => _repo.approveBusiness(businessId));
  Future<bool> rejectBusiness(String businessId) => _run('Business rejected', () => _repo.rejectBusiness(businessId));

  // ── Verification actions ──
  Future<bool> approveVerification(String id) => _run('Verification approved', () => _repo.approveVerification(id));
  Future<bool> rejectVerification(String id) => _run('Verification rejected', () => _repo.rejectVerification(id));

  // ── Moderation actions ──
  Future<bool> resolveReport(String id, {String? resolution}) => _run('Report resolved', () => _repo.resolveReport(id, resolution: resolution));
  Future<bool> dismissReport(String id) => _run('Report dismissed', () => _repo.dismissReport(id));

  // ── Support actions ──
  Future<bool> updateSupportStatus(String id, String status) => _run('Status updated', () => _repo.updateSupportStatus(id, status));
  Future<bool> resolveSupportIssue(String id, {String? resolution}) => _run('Issue resolved', () => _repo.resolveSupportIssue(id, resolution: resolution));

  // ── Content actions ──
  Future<bool> removeJob(String jobId) => _run('Job removed', () => _repo.removeJob(jobId));
  Future<bool> featureJob(String jobId) => _run('Job featured', () => _repo.featureJob(jobId));
  Future<bool> unfeatureJob(String jobId) => _run('Job unfeatured', () => _repo.unfeatureJob(jobId));
  Future<bool> overrideApplicationStatus(String id, String status) => _run('Status overridden', () => _repo.overrideApplicationStatus(id, status));
  Future<bool> cancelInterview(String id, {String? reason}) => _run('Interview cancelled', () => _repo.cancelInterview(id, reason: reason));
  Future<bool> markInterviewComplete(String id) => _run('Interview completed', () => _repo.markInterviewComplete(id));
  Future<bool> markInterviewNoShow(String id) => _run('Marked as no-show', () => _repo.markInterviewNoShow(id));
}
