/// Single source of truth for all candidate-side data.
///
/// Mirrors Swift CandidateAPIService.shared — every screen reads through
/// this repository instead of touching MockData directly.
///
/// While `_isMock` is true (no real token yet) every method returns mock
/// data from the typed models.  When the backend is wired up, each method
/// will call [ApiClient] and deserialise the JSON response.
library;

import 'package:plagit/core/api_client.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/models/application.dart';
import 'package:plagit/models/candidate_home_data.dart';
import 'package:plagit/models/candidate_profile.dart';
import 'package:plagit/models/conversation.dart';
import 'package:plagit/models/interview.dart';
import 'package:plagit/models/job.dart';
import 'package:plagit/models/notification_item.dart';
import 'package:plagit/models/subscription_state.dart';

class CandidateRepository {
  final ApiClient _api;

  CandidateRepository({ApiClient? api}) : _api = api ?? ApiClient();

  /// TODO: check token prefix in production — if token starts with "mock_",
  /// return mock data; otherwise hit the real API.
  bool get _isMock => true;

  // ══════════════════════════════════════════
  // ── Profile ──
  // ══════════════════════════════════════════

  Future<CandidateProfile> fetchProfile() async {
    if (_isMock) return CandidateProfile.mock();
    // TODO: final resp = await _api.get('/candidate/profile');
    // return CandidateProfile.fromJson(resp['data'] as Map<String, dynamic>);
    throw UnimplementedError('Real API not wired yet');
  }

  Future<CandidateProfile> updateProfile(Map<String, dynamic> fields) async {
    if (_isMock) return CandidateProfile.mock(); // return updated mock
    // TODO: final resp = await _api.put('/candidate/profile', fields);
    // return CandidateProfile.fromJson(resp['data'] as Map<String, dynamic>);
    throw UnimplementedError('Real API not wired yet');
  }

  // ══════════════════════════════════════════
  // ── Home ──
  // ══════════════════════════════════════════

  Future<CandidateHomeData> fetchHome() async {
    if (_isMock) return CandidateHomeData.mock();
    // TODO: final resp = await _api.get('/candidate/home');
    // return CandidateHomeData.fromJson(resp['data'] as Map<String, dynamic>);
    throw UnimplementedError('Real API not wired yet');
  }

  // ══════════════════════════════════════════
  // ── Jobs ──
  // ══════════════════════════════════════════

  Future<List<Job>> fetchJobs({
    String? search,
    String? filter,
    String? sort,
  }) async {
    if (_isMock) {
      var jobs = Job.mockAll();

      // Filter by contract type
      if (filter != null && filter != 'All') {
        jobs = jobs.where((j) => j.contract == filter).toList();
      }

      // Search by title or company
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        jobs = jobs
            .where((j) =>
                j.title.toLowerCase().contains(q) ||
                j.company.toLowerCase().contains(q))
            .toList();
      }

      // Sort
      if (sort == 'Salary') {
        jobs.sort((a, b) => b.salary.compareTo(a.salary));
      }
      // 'Newest' is the default order from mock data

      return jobs;
    }
    // TODO: final resp = await _api.get('/candidate/jobs?...');
    throw UnimplementedError('Real API not wired yet');
  }

  Future<Job> fetchJobDetail(String jobId) async {
    if (_isMock) {
      return Job.mockAll().firstWhere(
        (j) => j.id == jobId,
        orElse: () => Job.mockAll().first,
      );
    }
    // TODO: final resp = await _api.get('/candidate/jobs/$jobId');
    throw UnimplementedError('Real API not wired yet');
  }

  Future<void> applyToJob(String jobId, {String? note}) async {
    if (_isMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      return;
    }
    // TODO: await _api.post('/candidate/jobs/$jobId/apply', {'note': note});
    throw UnimplementedError('Real API not wired yet');
  }

  // ══════════════════════════════════════════
  // ── Applications ──
  // ══════════════════════════════════════════

  Future<List<Application>> fetchApplications({String? statusFilter}) async {
    if (_isMock) {
      var apps = Application.mockAll();
      if (statusFilter != null && statusFilter != 'All') {
        apps = apps
            .where((a) => a.status.displayName == statusFilter)
            .toList();
      }
      return apps;
    }
    // TODO: final resp = await _api.get('/candidate/applications');
    throw UnimplementedError('Real API not wired yet');
  }

  // ══════════════════════════════════════════
  // ── Conversations ──
  // ══════════════════════════════════════════

  Future<List<Conversation>> fetchConversations() async {
    if (_isMock) return Conversation.mockAll();
    // TODO: final resp = await _api.get('/candidate/conversations');
    throw UnimplementedError('Real API not wired yet');
  }

  Future<List<ChatMessage>> fetchMessages(String conversationId) async {
    if (_isMock) return ChatMessage.mockRitzMessages();
    // TODO: final resp = await _api.get('/candidate/conversations/$conversationId/messages');
    throw UnimplementedError('Real API not wired yet');
  }

  Future<void> sendMessage(String conversationId, String text) async {
    if (_isMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return;
    }
    // TODO: await _api.post('/candidate/conversations/$conversationId/messages', {'text': text});
    throw UnimplementedError('Real API not wired yet');
  }

  // ══════════════════════════════════════════
  // ── Interviews ──
  // ══════════════════════════════════════════

  Future<List<Interview>> fetchInterviews({String? filter}) async {
    if (_isMock) return Interview.mockAll();
    // TODO: final resp = await _api.get('/candidate/interviews');
    throw UnimplementedError('Real API not wired yet');
  }

  // ══════════════════════════════════════════
  // ── Notifications ──
  // ══════════════════════════════════════════

  Future<List<NotificationItem>> fetchNotifications() async {
    if (_isMock) return NotificationItem.mockAll();
    // TODO: final resp = await _api.get('/candidate/notifications');
    throw UnimplementedError('Real API not wired yet');
  }

  // ══════════════════════════════════════════
  // ── Saved Jobs ──
  // ══════════════════════════════════════════

  Future<Set<String>> fetchSavedJobIds() async {
    if (_isMock) return MockData.savedJobIds.toSet();
    // TODO: final resp = await _api.get('/candidate/saved-jobs');
    throw UnimplementedError('Real API not wired yet');
  }

  Future<void> saveJob(String jobId) async {
    if (_isMock) return;
    // TODO: await _api.post('/candidate/saved-jobs', {'jobId': jobId});
    throw UnimplementedError('Real API not wired yet');
  }

  Future<void> unsaveJob(String jobId) async {
    if (_isMock) return;
    // TODO: await _api.delete('/candidate/saved-jobs/$jobId');
    throw UnimplementedError('Real API not wired yet');
  }

  // ══════════════════════════════════════════
  // ── Subscription ──
  // ══════════════════════════════════════════

  Future<CandidateSubscription> fetchSubscription() async {
    if (_isMock) return CandidateSubscription.mock();
    // TODO: final resp = await _api.get('/candidate/subscription');
    throw UnimplementedError('Real API not wired yet');
  }
}
