/// Single source of truth for all business-side data.
///
/// Mirrors Swift BusinessAPIService.shared — every screen reads through
/// this repository instead of touching MockData directly.
///
/// While `_isMock` is true (no real token yet) every method returns mock
/// data from the typed models.  When the backend is wired up, each method
/// will call [ApiClient] and deserialise the JSON response.
library;

import 'package:plagit/core/api_client.dart';
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
  final ApiClient _api;

  BusinessRepository({ApiClient? api}) : _api = api ?? ApiClient();

  /// TODO: check token prefix in production — if token starts with "mock_",
  /// return mock data; otherwise hit the real API.
  bool get _isMock => true;

  // ======================================
  // -- Profile --
  // ======================================

  Future<BusinessProfile> fetchProfile() async {
    if (_isMock) return BusinessProfile.mock();
    // TODO: final resp = await _api.get('/business/profile');
    // return BusinessProfile.fromJson(resp['data'] as Map<String, dynamic>);
    throw UnimplementedError('Real API not wired yet');
  }

  Future<BusinessProfile> updateProfile(Map<String, dynamic> fields) async {
    if (_isMock) return BusinessProfile.mock(); // return updated mock
    // TODO: final resp = await _api.put('/business/profile', fields);
    // return BusinessProfile.fromJson(resp['data'] as Map<String, dynamic>);
    throw UnimplementedError('Real API not wired yet');
  }

  // ======================================
  // -- Home --
  // ======================================

  Future<BusinessHomeData> fetchHome() async {
    if (_isMock) return BusinessHomeData.mock();
    // TODO: final resp = await _api.get('/business/home');
    // return BusinessHomeData.fromJson(resp['data'] as Map<String, dynamic>);
    throw UnimplementedError('Real API not wired yet');
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
    // TODO: final resp = await _api.get('/business/jobs?filter=$filter');
    throw UnimplementedError('Real API not wired yet');
  }

  Future<BusinessJob> fetchJobDetail(String jobId) async {
    if (_isMock) {
      return BusinessJob.mockAll().firstWhere(
        (j) => j.id == jobId,
        orElse: () => BusinessJob.mockAll().first,
      );
    }
    // TODO: final resp = await _api.get('/business/jobs/$jobId');
    throw UnimplementedError('Real API not wired yet');
  }

  Future<void> postJob(Map<String, dynamic> data) async {
    if (_isMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      return;
    }
    // TODO: await _api.post('/business/jobs', data);
    throw UnimplementedError('Real API not wired yet');
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
    // TODO: final resp = await _api.get('/business/applicants?jobId=$jobId&status=$statusFilter');
    throw UnimplementedError('Real API not wired yet');
  }

  Future<Applicant> fetchApplicantDetail(String applicantId) async {
    if (_isMock) {
      return Applicant.mockAll().firstWhere(
        (a) => a.id == applicantId,
        orElse: () => Applicant.mockAll().first,
      );
    }
    // TODO: final resp = await _api.get('/business/applicants/$applicantId');
    throw UnimplementedError('Real API not wired yet');
  }

  // ======================================
  // -- Conversations --
  // ======================================

  Future<List<BusinessConversation>> fetchConversations() async {
    if (_isMock) return BusinessConversation.mockAll();
    // TODO: final resp = await _api.get('/business/conversations');
    throw UnimplementedError('Real API not wired yet');
  }

  Future<List<ChatMessage>> fetchMessages(String conversationId) async {
    if (_isMock) {
      // Return business chat messages as ChatMessage instances.
      return MockData.businessChatMessages
          .map((m) => ChatMessage.fromJson(m))
          .toList();
    }
    // TODO: final resp = await _api.get('/business/conversations/$conversationId/messages');
    throw UnimplementedError('Real API not wired yet');
  }

  Future<void> sendMessage(String conversationId, String text) async {
    if (_isMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return;
    }
    // TODO: await _api.post('/business/conversations/$conversationId/messages', {'text': text});
    throw UnimplementedError('Real API not wired yet');
  }

  // ======================================
  // -- Interviews --
  // ======================================

  Future<List<BusinessInterview>> fetchInterviews({String? filter}) async {
    if (_isMock) {
      var interviews = BusinessInterview.mockAll();

      if (filter != null && filter != 'All') {
        interviews =
            interviews.where((i) => i.status == filter).toList();
      }

      return interviews;
    }
    // TODO: final resp = await _api.get('/business/interviews');
    throw UnimplementedError('Real API not wired yet');
  }

  Future<void> scheduleInterview(Map<String, dynamic> data) async {
    if (_isMock) {
      await Future.delayed(const Duration(milliseconds: 800));
      return;
    }
    // TODO: await _api.post('/business/interviews', data);
    throw UnimplementedError('Real API not wired yet');
  }

  // ======================================
  // -- QuickPlug --
  // ======================================

  Future<List<QuickPlugCandidate>> fetchQuickPlugDeck() async {
    if (_isMock) return QuickPlugCandidate.mockAll();
    // TODO: final resp = await _api.get('/business/quickplug/deck');
    throw UnimplementedError('Real API not wired yet');
  }

  Future<void> swipeCandidate(String candidateId, bool interested) async {
    if (_isMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return;
    }
    // TODO: await _api.post('/business/quickplug/swipe', {'candidateId': candidateId, 'interested': interested});
    throw UnimplementedError('Real API not wired yet');
  }

  // ======================================
  // -- Subscription --
  // ======================================

  Future<BusinessSubscription> fetchSubscription() async {
    if (_isMock) return BusinessSubscription.mock();
    // TODO: final resp = await _api.get('/business/subscription');
    throw UnimplementedError('Real API not wired yet');
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
    // TODO: final resp = await _api.get('/business/notifications');
    throw UnimplementedError('Real API not wired yet');
  }
}
