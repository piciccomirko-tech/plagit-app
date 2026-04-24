/// Single source of truth for all candidate-side data.
///
/// Mirrors Swift CandidateAPIService.shared — every screen reads through
/// this repository instead of touching MockData directly.
///
/// While `_isMock` is true (no real token yet) every method returns mock
/// data from the typed models.  When the backend is wired up, each method
/// will call [ApiClient] and deserialise the JSON response.
library;

import 'package:plagit/config/env_config.dart';
import 'package:plagit/core/network/api_client.dart';
import 'package:plagit/core/network/api_error.dart';
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
  final PlagitApiClient _api;

  CandidateRepository({PlagitApiClient? api})
      : _api = api ?? PlagitApiClient.instance;

  /// TODO: check token prefix in production — if token starts with "mock_",
  /// return mock data; otherwise hit the real API.
  bool get _isMock => EnvConfig.useMockData;

  // ══════════════════════════════════════════
  // ── Profile ──
  // ══════════════════════════════════════════

  Future<CandidateProfile> fetchProfile() async {
    if (_isMock) return CandidateProfile.mock();
    final resp = await _api.get('/candidate/profile');
    return CandidateProfile.fromJson(resp['data'] as Map<String, dynamic>? ?? resp);
  }

  Future<CandidateProfile> updateProfile(Map<String, dynamic> fields) async {
    if (_isMock) return CandidateProfile.mock();
    final resp = await _api.put('/candidate/profile', body: fields);
    return CandidateProfile.fromJson(resp['data'] as Map<String, dynamic>? ?? resp);
  }

  // ══════════════════════════════════════════
  // ── Home ──
  // ══════════════════════════════════════════

  Future<CandidateHomeData> fetchHome() async {
    if (_isMock) return CandidateHomeData.mock();
    final resp = await _api.get('/candidate/home');
    return CandidateHomeData.fromJson(resp['data'] as Map<String, dynamic>? ?? resp);
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
    final params = <String, String>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (filter != null && filter != 'All') params['filter'] = filter;
    if (sort != null) params['sort'] = sort;
    final resp = await _api.get('/candidate/jobs', queryParams: params.isNotEmpty ? params : null);
    final list = resp['data'] as List<dynamic>? ?? [];
    return list.map((e) => Job.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Job> fetchJobDetail(String jobId) async {
    if (_isMock) {
      return Job.mockAll().firstWhere(
        (j) => j.id == jobId,
        orElse: () => Job.mockAll().first,
      );
    }
    final resp = await _api.get('/candidate/jobs/$jobId');
    final data = resp['data'] as Map<String, dynamic>? ?? resp;
    final jobJson = data['job'] as Map<String, dynamic>? ?? data;
    return Job.fromJson(jobJson);
  }

  /// Rebuild a coherent saved-jobs list from the real saved ids plus the
  /// existing jobs/detail endpoints, without introducing a new endpoint.
  Future<List<Job>> fetchSavedJobs() async {
    final savedIds = await fetchSavedJobIds();
    if (savedIds.isEmpty) return const [];

    if (_isMock) {
      return Job.mockAll().where((j) => savedIds.contains(j.id)).toList();
    }

    final jobs = await fetchJobs();
    final byId = {for (final job in jobs) job.id: job};
    final result = <Job>[];

    for (final id in savedIds) {
      final existing = byId[id];
      if (existing != null) {
        result.add(existing);
        continue;
      }

      result.add(await fetchJobDetail(id));
    }

    return result;
  }

  Future<void> applyToJob(String jobId, {String? note}) async {
    if (_isMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      return;
    }
    final body = <String, dynamic>{'jobId': jobId};
    if (note != null) body['note'] = note;
    await _api.post('/candidate/applications', body: body);
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
    final params = <String, String>{};
    if (statusFilter != null && statusFilter != 'All') params['status'] = statusFilter;
    final resp = await _api.get('/candidate/applications', queryParams: params.isNotEmpty ? params : null);
    final list = resp['data'] as List<dynamic>? ?? [];
    return list.map((e) => Application.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Application> fetchApplicationDetail(String id) async {
    final applications = await fetchApplications();
    try {
      return applications.firstWhere((app) => app.id == id);
    } catch (_) {
      throw ApiError(
        type: ApiErrorType.notFound,
        message: 'Application not found',
      );
    }
  }

  // ══════════════════════════════════════════
  // ── Conversations ──
  // ══════════════════════════════════════════

  Future<List<Conversation>> fetchConversations() async {
    if (_isMock) return Conversation.mockAll();
    final resp = await _api.get('/candidate/conversations');
    final list = resp['data'] as List<dynamic>? ?? [];
    return list.map((e) => Conversation.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Conversation> fetchConversationDetail(String id) async {
    final conversations = await fetchConversations();
    try {
      return conversations.firstWhere((conversation) => conversation.id == id);
    } catch (_) {
      throw ApiError(
        type: ApiErrorType.notFound,
        message: 'Conversation not found',
      );
    }
  }

  Future<List<ChatMessage>> fetchMessages(String conversationId) async {
    if (_isMock) return ChatMessage.mockRitzMessages();
    final resp = await _api.get('/candidate/conversations/$conversationId/messages');
    final list = resp['data'] as List<dynamic>? ?? [];
    return list.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> sendMessage(String conversationId, String text) async {
    if (_isMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return;
    }
    await _api.post('/candidate/conversations/$conversationId/messages', body: {'text': text});
  }

  // ══════════════════════════════════════════
  // ── Interviews ──
  // ══════════════════════════════════════════

  Future<List<Interview>> fetchInterviews({String? filter}) async {
    if (_isMock) return Interview.mockAll();
    final params = <String, String>{};
    if (filter != null && filter != 'All') params['filter'] = filter;
    final resp = await _api.get('/candidate/interviews', queryParams: params.isNotEmpty ? params : null);
    final list = resp['data'] as List<dynamic>? ?? [];
    return list.map((e) => Interview.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Interview> fetchInterviewDetail(String id) async {
    final interviews = await fetchInterviews();
    try {
      return interviews.firstWhere((interview) => interview.id == id);
    } catch (_) {
      throw ApiError(
        type: ApiErrorType.notFound,
        message: 'Interview not found',
      );
    }
  }

  // ══════════════════════════════════════════
  // ── Notifications ──
  // ══════════════════════════════════════════

  Future<List<NotificationItem>> fetchNotifications() async {
    if (_isMock) return NotificationItem.mockAll();
    final resp = await _api.get('/candidate/notifications');
    final list = resp['data'] as List<dynamic>? ?? [];
    return list.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ══════════════════════════════════════════
  // ── Saved Jobs ──
  // ══════════════════════════════════════════

  Future<Set<String>> fetchSavedJobIds() async {
    if (_isMock) return MockData.savedJobIds.toSet();
    try {
      final resp = await _api.get('/candidate/saved-jobs');
      final list = resp['data'] as List<dynamic>? ?? [];
      return list.map((e) => e.toString()).toSet();
    } on ApiError catch (e) {
      if (e.type == ApiErrorType.notFound) return {}; // Endpoint not built yet
      rethrow;
    }
  }

  Future<void> saveJob(String jobId) async {
    if (_isMock) return;
    try {
      await _api.post('/candidate/saved-jobs', body: {'jobId': jobId});
    } on ApiError catch (e) {
      if (e.type == ApiErrorType.notFound) return; // Endpoint not built yet
      rethrow;
    }
  }

  Future<void> unsaveJob(String jobId) async {
    if (_isMock) return;
    try {
      await _api.delete('/candidate/saved-jobs/$jobId');
    } on ApiError catch (e) {
      if (e.type == ApiErrorType.notFound) return; // Endpoint not built yet
      rethrow;
    }
  }

  // ══════════════════════════════════════════
  // ── Subscription ──
  // ══════════════════════════════════════════

  Future<CandidateSubscription> fetchSubscription() async {
    if (_isMock) return CandidateSubscription.mock();
    try {
      final resp = await _api.get('/candidate/subscription');
      final data = resp['data'] as Map<String, dynamic>? ?? {};
      return CandidateSubscription.fromJson(data);
    } on ApiError catch (e) {
      // Subscription endpoint may not exist yet — return free plan
      if (e.type == ApiErrorType.notFound) return CandidateSubscription.mock();
      rethrow;
    }
  }
}
