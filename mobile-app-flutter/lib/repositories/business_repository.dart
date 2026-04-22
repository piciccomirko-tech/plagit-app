/// Single source of truth for all business-side data.
///
/// Mirrors Swift BusinessAPIService.shared — every screen reads through
/// this repository instead of touching MockData directly.
///
/// While `_isMock` is true (no real token yet) every method returns mock
/// data from the typed models.  When the backend is wired up, each method
/// will call [ApiClient] and deserialise the JSON response.
library;

import 'package:plagit/config/env_config.dart';
import 'package:plagit/core/network/api_client.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/models/applicant.dart';
import 'package:plagit/models/business_conversation.dart';
import 'package:plagit/models/business_home_data.dart';
import 'package:plagit/models/business_interview.dart';
import 'package:plagit/models/business_job.dart';
import 'package:plagit/models/business_profile.dart';
import 'package:plagit/models/business_subscription.dart';
import 'package:plagit/models/conversation.dart'; // reuse ChatMessage
import 'package:plagit/models/notification_item.dart';
import 'package:plagit/models/quick_plug_candidate.dart';

class BusinessRepository {
  final PlagitApiClient _api;

  BusinessRepository({PlagitApiClient? api})
      : _api = api ?? PlagitApiClient.instance;

  /// TODO: check token prefix in production — if token starts with "mock_",
  /// return mock data; otherwise hit the real API.
  bool get _isMock => EnvConfig.useMockData;

  // ======================================
  // -- Profile --
  // ======================================

  Future<BusinessProfile> fetchProfile() async {
    if (_isMock) return BusinessProfile.mock();
    final resp = await _api.get('/business/profile');
    return BusinessProfile.fromJson(resp['data'] as Map<String, dynamic>? ?? resp);
  }

  Future<BusinessProfile> updateProfile(Map<String, dynamic> fields) async {
    if (_isMock) return BusinessProfile.mock();
    final resp = await _api.put('/business/profile', body: fields);
    return BusinessProfile.fromJson(resp['data'] as Map<String, dynamic>? ?? resp);
  }

  // ======================================
  // -- Home --
  // ======================================

  Future<BusinessHomeData> fetchHome() async {
    if (_isMock) return BusinessHomeData.mock();
    final resp = await _api.get('/business/home');
    return BusinessHomeData.fromJson(resp['data'] as Map<String, dynamic>? ?? resp);
  }

  // ======================================
  // -- Jobs --
  // ======================================

  Future<List<BusinessJob>> fetchJobs({String? filter}) async {
    if (_isMock) {
      var jobs = BusinessJob.mockAll();

      // Filter by status
      if (filter != null && filter != 'All') {
        final status = BusinessJobStatus.fromString(filter);
        jobs = jobs.where((j) => j.status == status).toList();
      }

      return jobs;
    }
    final params = <String, String>{};
    if (filter != null && filter != 'All') params['status'] = filter;
    final resp = await _api.get('/business/jobs', queryParams: params.isNotEmpty ? params : null);
    final list = resp['data'] as List<dynamic>? ?? [];
    return list.map((e) => BusinessJob.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<BusinessJob> fetchJobDetail(String jobId) async {
    if (_isMock) {
      return BusinessJob.mockAll().firstWhere(
        (j) => j.id == jobId,
        orElse: () => BusinessJob.mockAll().first,
      );
    }
    final resp = await _api.get('/business/jobs/$jobId');
    return BusinessJob.fromJson(resp['data'] as Map<String, dynamic>? ?? resp);
  }

  Future<void> postJob(Map<String, dynamic> data) async {
    if (_isMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      return;
    }
    await _api.post('/business/jobs', body: data);
  }

  // ======================================
  // -- Applicants --
  // ======================================

  Future<List<Applicant>> fetchApplicants({
    String? jobId,
    String? statusFilter,
  }) async {
    if (_isMock) {
      var applicants = Applicant.mockAll();

      // Filter by job
      if (jobId != null) {
        applicants = applicants.where((a) => a.jobId == jobId).toList();
      }

      // Filter by status
      if (statusFilter != null && statusFilter != 'All') {
        final status = ApplicantStatus.fromString(statusFilter);
        applicants = applicants.where((a) => a.status == status).toList();
      }

      return applicants;
    }
    final params = <String, String>{};
    if (jobId != null) params['jobId'] = jobId;
    if (statusFilter != null && statusFilter != 'All') params['status'] = statusFilter;
    final resp = await _api.get('/business/applicants', queryParams: params.isNotEmpty ? params : null);
    final list = resp['data'] as List<dynamic>? ?? [];
    return list.map((e) => Applicant.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Applicant> fetchApplicantDetail(String applicantId) async {
    if (_isMock) {
      return Applicant.mockAll().firstWhere(
        (a) => a.id == applicantId,
        orElse: () => Applicant.mockAll().first,
      );
    }
    final resp = await _api.get('/business/applicants/$applicantId');
    return Applicant.fromJson(resp['data'] as Map<String, dynamic>? ?? resp);
  }

  // ======================================
  // -- Conversations --
  // ======================================

  Future<List<BusinessConversation>> fetchConversations() async {
    if (_isMock) return BusinessConversation.mockAll();
    final resp = await _api.get('/business/conversations');
    final payload = resp['data'] ?? resp['conversations'] ?? resp;
    final list = payload is List<dynamic> ? payload : <dynamic>[];
    return list.map((e) => BusinessConversation.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ChatMessage>> fetchMessages(String conversationId) async {
    if (_isMock) {
      return MockData.businessChatMessages
          .map((m) => ChatMessage.fromJson(m))
          .toList();
    }
    final resp = await _api.get('/business/conversations/$conversationId/messages');
    final list = resp['data'] as List<dynamic>? ?? [];
    return list.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> sendMessage(String conversationId, String text) async {
    if (_isMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return;
    }
    await _api.post('/business/conversations/$conversationId/messages', body: {'text': text});
  }

  // ======================================
  // -- Interviews --
  // ======================================

  Future<List<BusinessInterview>> fetchInterviews({String? filter}) async {
    if (_isMock) {
      var interviews = BusinessInterview.mockAll();
      if (filter != null && filter != 'All') {
        interviews = interviews.where((i) => i.status == filter).toList();
      }
      return interviews;
    }
    final params = <String, String>{};
    if (filter != null && filter != 'All') params['status'] = filter;
    final resp = await _api.get('/business/interviews', queryParams: params.isNotEmpty ? params : null);
    final dynamic rawList =
        resp['data'] ??
        resp['interviews'] ??
        (resp is List<dynamic> ? resp : null);
    final list = rawList is List<dynamic> ? rawList : const <dynamic>[];
    return list.map((e) => BusinessInterview.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> scheduleInterview(Map<String, dynamic> data) async {
    if (_isMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      return;
    }
    await _api.post('/business/interviews', body: data);
  }

  // ======================================
  // -- QuickPlug --
  // ======================================

  Future<List<QuickPlugCandidate>> fetchQuickPlugDeck() async {
    if (_isMock) return QuickPlugCandidate.mockAll();
    final resp = await _api.get('/business/quickplug/deck');
    final list = resp['data'] as List<dynamic>? ?? [];
    return list.map((e) => QuickPlugCandidate.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> swipeCandidate(String candidateId, bool interested) async {
    if (_isMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return;
    }
    await _api.post('/business/quickplug/swipe', body: {
      'candidateId': candidateId,
      'interested': interested,
    });
  }

  // ======================================
  // -- Subscription --
  // ======================================

  Future<BusinessSubscription> fetchSubscription() async {
    if (_isMock) return BusinessSubscription.mock();
    final resp = await _api.get('/business/subscription');
    final data = resp['data'] as Map<String, dynamic>? ?? {};
    return BusinessSubscription.fromJson(data);
  }

  // ======================================
  // -- Notifications --
  // ======================================

  Future<List<NotificationItem>> fetchNotifications() async {
    if (_isMock) {
      return MockData.businessNotifications
          .map((n) => NotificationItem.fromJson(n))
          .toList();
    }
    final resp = await _api.get('/business/notifications');
    final list = resp['data'] as List<dynamic>? ?? [];
    return list.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>)).toList();
  }
}
