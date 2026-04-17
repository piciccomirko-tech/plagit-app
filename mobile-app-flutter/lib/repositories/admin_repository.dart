import 'package:flutter/foundation.dart';
import 'package:plagit/config/env_config.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/core/network/api_client.dart';
import 'package:plagit/models/admin_notification.dart';

/// Admin-specific API calls.
///
/// In mock mode returns hardcoded data. In production, calls
/// admin-scoped endpoints that the backend protects with
/// role-based middleware (admin / super_admin only).
class AdminRepository {
  final PlagitApiClient _api;

  AdminRepository({PlagitApiClient? api})
      : _api = api ?? PlagitApiClient.instance;

  bool get _useMock => EnvConfig.useMockData;

  // ─── Dashboard stats ──────────────────────────────────────────

  Future<Map<String, dynamic>> fetchDashboardStats() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return _mockDashboardStats;
    }
    final raw = await _api.get('/admin/dashboard/stats');
    // Backend returns snake_case at top level (no 'data' wrapper).
    // Normalize to camelCase keys matching mock data shape.
    return {
      'totalCandidates': raw['total_candidates'] ?? 0,
      'totalBusinesses': raw['total_businesses'] ?? 0,
      'activeJobs': raw['active_jobs'] ?? 0,
      'applicationsToday': raw['applications_today'] ?? 0,
      'interviewsThisWeek': raw['interviews_this_week'] ?? 0,
      'pendingVerifications': raw['pending_business_verification'] ?? 0,
      'reportedContent': raw['open_reports'] ?? 0,
      'premiumSubscribers': raw['active_plans'] ?? 0,
      'newCandidates': raw['new_candidates'] ?? 0,
      'newBusinesses': raw['new_businesses'] ?? 0,
      'interviewsToday': raw['interviews_today'] ?? 0,
      'unreadSupport': raw['urgent_reports'] ?? 0,
      'flaggedContent': raw['flagged_content'] ?? 0,
      'systemWarnings': 0,
      'subscriptionIssues': raw['failed_payments'] ?? 0,
    };
  }

  // ─── Notifications ────────────────────────────────────────────

  Future<List<AdminNotification>> fetchNotifications() async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _mockNotifications;
    }
    final resp = await _api.get('/admin/notifications');
    final list = resp['data'] as List<dynamic>? ?? [];
    return list
        .map((j) => AdminNotification.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<void> markNotificationRead(String id) async {
    if (_useMock) return;
    await _api.patch('/admin/notifications/$id/read', body: {});
  }

  // ─── Admin actions ────────────────────────────────────────────

  Future<void> approveBusiness(String businessId) async {
    debugPrint('[AdminRepo] approveBusiness($businessId)');
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }
    await _api.patch('/admin/businesses/$businessId/status', body: {'status': 'active'});
  }

  Future<void> rejectBusiness(String businessId) async {
    debugPrint('[AdminRepo] rejectBusiness($businessId)');
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }
    await _api.patch('/admin/businesses/$businessId/status', body: {'status': 'suspended'});
  }

  Future<void> verifyUser(String userId) async {
    debugPrint('[AdminRepo] verifyUser($userId)');
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }
    await _api.patch('/admin/users/$userId/verify', body: {'is_verified': true});
  }

  Future<void> unverifyUser(String userId) async {
    debugPrint('[AdminRepo] unverifyUser($userId)');
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }
    await _api.patch('/admin/users/$userId/verify', body: {'is_verified': false});
  }

  Future<void> suspendUser(String userId) async {
    debugPrint('[AdminRepo] suspendUser($userId)');
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }
    await _api.patch('/admin/users/$userId/status', body: {'status': 'suspended'});
  }

  Future<void> unsuspendUser(String userId) async {
    debugPrint('[AdminRepo] unsuspendUser($userId)');
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }
    await _api.patch('/admin/users/$userId/status', body: {'status': 'active'});
  }

  Future<void> removeJob(String jobId) async {
    debugPrint('[AdminRepo] removeJob($jobId)');
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }
    await _api.delete('/admin/jobs/$jobId');
  }

  // ─── Verification actions ─────────────────────────────────────

  Future<void> approveVerification(String verificationId) async {
    debugPrint('[AdminRepo] approveVerification($verificationId)');
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }
    await _api.patch('/admin/candidates/$verificationId/verification', body: {'status': 'approved'});
  }

  Future<void> rejectVerification(String verificationId) async {
    debugPrint('[AdminRepo] rejectVerification($verificationId)');
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }
    await _api.patch('/admin/candidates/$verificationId/verification', body: {'status': 'rejected'});
  }

  // ─── Moderation actions ───────────────────────────────────────

  Future<void> resolveReport(String reportId, {String? resolution}) async {
    debugPrint('[AdminRepo] resolveReport($reportId)');
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }
    await _api.patch('/admin/reports/$reportId/status', body: {
      'status': 'resolved',
      if (resolution != null) 'resolution': resolution,
    });
  }

  Future<void> dismissReport(String reportId) async {
    debugPrint('[AdminRepo] dismissReport($reportId)');
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }
    await _api.patch('/admin/reports/$reportId/status', body: {'status': 'dismissed'});
  }

  // ─── Support actions ──────────────────────────────────────────

  Future<void> updateSupportStatus(String issueId, String newStatus) async {
    debugPrint('[AdminRepo] updateSupportStatus($issueId, $newStatus)');
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }
    await _api.patch('/admin/reports/$issueId/status', body: {'status': newStatus});
  }

  Future<void> resolveSupportIssue(String issueId, {String? resolution}) async {
    debugPrint('[AdminRepo] resolveSupportIssue($issueId)');
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }
    await _api.patch('/admin/reports/$issueId/status', body: {
      'status': 'resolved',
      if (resolution != null) 'resolution': resolution,
    });
  }

  // ─── Content actions ──────────────────────────────────────────

  Future<void> featureJob(String jobId) async {
    debugPrint('[AdminRepo] featureJob($jobId)');
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }
    await _api.patch('/admin/jobs/$jobId/featured', body: {'is_featured': true});
  }

  Future<void> unfeatureJob(String jobId) async {
    debugPrint('[AdminRepo] unfeatureJob($jobId)');
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }
    await _api.patch('/admin/jobs/$jobId/featured', body: {'is_featured': false});
  }

  Future<void> overrideApplicationStatus(String applicationId, String newStatus) async {
    debugPrint('[AdminRepo] overrideApplicationStatus($applicationId, $newStatus)');
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }
    await _api.patch('/admin/applications/$applicationId/status', body: {'status': newStatus});
  }

  Future<void> cancelInterview(String interviewId, {String? reason}) async {
    debugPrint('[AdminRepo] cancelInterview($interviewId)');
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }
    await _api.patch('/admin/interviews/$interviewId/status', body: {
      'status': 'cancelled',
      if (reason != null) 'reason': reason,
    });
  }

  Future<void> markInterviewComplete(String interviewId) async {
    debugPrint('[AdminRepo] markInterviewComplete($interviewId)');
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }
    await _api.patch('/admin/interviews/$interviewId/status', body: {'status': 'completed'});
  }

  Future<void> markInterviewNoShow(String interviewId) async {
    debugPrint('[AdminRepo] markInterviewNoShow($interviewId)');
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }
    await _api.patch('/admin/interviews/$interviewId/status', body: {'status': 'no_show'});
  }

  // ─── List endpoints (GET) ───────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchCandidates() async {
    debugPrint('[AdminRepo] fetchCandidates(mock=$_useMock)');
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return MockData.adminCandidates.map((c) => Map<String, dynamic>.from(c)).toList();
    }
    final resp = await _api.get('/admin/candidates');
    return (resp['data'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchBusinesses() async {
    debugPrint('[AdminRepo] fetchBusinesses(mock=$_useMock)');
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return MockData.adminBusinesses.map((b) => Map<String, dynamic>.from(b)).toList();
    }
    final resp = await _api.get('/admin/businesses');
    return (resp['data'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchJobs() async {
    debugPrint('[AdminRepo] fetchJobs(mock=$_useMock)');
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return MockData.adminJobs.map((j) => Map<String, dynamic>.from(j)).toList();
    }
    final resp = await _api.get('/admin/jobs');
    return (resp['data'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchApplications() async {
    debugPrint('[AdminRepo] fetchApplications(mock=$_useMock)');
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return MockData.adminApplications.map((a) => Map<String, dynamic>.from(a)).toList();
    }
    final resp = await _api.get('/admin/applications');
    return (resp['data'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchInterviews() async {
    debugPrint('[AdminRepo] fetchInterviews(mock=$_useMock)');
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return MockData.adminInterviews.map((i) => Map<String, dynamic>.from(i)).toList();
    }
    final resp = await _api.get('/admin/interviews');
    return (resp['data'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchVerifications() async {
    debugPrint('[AdminRepo] fetchVerifications(mock=$_useMock)');
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return MockData.adminVerificationQueue.map((v) => Map<String, dynamic>.from(v)).toList();
    }
    // No separate /admin/verifications endpoint — use /admin/candidates with pending filter
    final resp = await _api.get('/admin/candidates', queryParams: {'verification': 'pending'});
    return (resp['data'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchReports() async {
    debugPrint('[AdminRepo] fetchReports(mock=$_useMock)');
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return MockData.adminModerationReports.map((r) => Map<String, dynamic>.from(r)).toList();
    }
    final resp = await _api.get('/admin/reports');
    return (resp['data'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> fetchSupportIssues() async {
    debugPrint('[AdminRepo] fetchSupportIssues(mock=$_useMock)');
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      return MockData.adminSupportIssues.map((s) => Map<String, dynamic>.from(s)).toList();
    }
    // No separate /admin/support endpoint — use /admin/reports with type filter
    final resp = await _api.get('/admin/reports', queryParams: {'type': 'support'});
    return (resp['data'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
  }

  // ─── Mock data ────────────────────────────────────────────────

  static final _mockDashboardStats = <String, dynamic>{
    'newCandidates': 12,
    'newBusinesses': 3,
    'newJobs': 8,
    'recentApplications': 47,
    'interviewsToday': 5,
    'upcomingInterviews': 14,
    'unreadSupport': 6,
    'reportedUsers': 2,
    'flaggedContent': 4,
    'subscriptionIssues': 1,
    'systemWarnings': 0,
    'totalCandidates': 1248,
    'totalBusinesses': 156,
    'activeJobs': 89,
    'premiumSubscribers': 67,
  };

  static final _mockNotifications = <AdminNotification>[
    AdminNotification(
      id: 'an_01',
      type: AdminNotificationType.businessPendingApproval,
      title: 'New business registration',
      body: 'The Savoy Hotel has registered and is awaiting approval.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      actionRoute: '/admin/businesses/mock_b_002',
    ),
    AdminNotification(
      id: 'an_02',
      type: AdminNotificationType.newReport,
      title: 'Content reported',
      body: 'A job listing has been flagged for misleading salary information.',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      actionRoute: '/admin/moderation',
    ),
    AdminNotification(
      id: 'an_03',
      type: AdminNotificationType.urgentMessage,
      title: 'Urgent support request',
      body: 'A business reports they cannot access their interview dashboard.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      actionRoute: '/admin/support',
    ),
    AdminNotification(
      id: 'an_04',
      type: AdminNotificationType.suspiciousActivity,
      title: 'Suspicious login detected',
      body: 'Multiple failed login attempts for account marco@restaurant.com.',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    AdminNotification(
      id: 'an_05',
      type: AdminNotificationType.paymentIssue,
      title: 'Payment failure',
      body: 'Premium subscription renewal failed for 2 accounts.',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      actionRoute: '/admin/subscriptions',
    ),
    AdminNotification(
      id: 'an_06',
      type: AdminNotificationType.interviewIssue,
      title: 'Interview cancelled',
      body: 'Business cancelled an interview 30 minutes before the scheduled time.',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      actionRoute: '/admin/interviews',
    ),
    AdminNotification(
      id: 'an_07',
      type: AdminNotificationType.systemAlert,
      title: 'API latency spike',
      body: 'Average response time exceeded 2s for 15 minutes.',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      isRead: true,
    ),
  ];
}
