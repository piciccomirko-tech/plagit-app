import 'package:flutter/foundation.dart';
import 'package:plagit/core/api_client.dart';

/// Mirrors BusinessAPIService.swift — all business endpoints.
/// In debug mode, returns mock data when the API is unreachable.
class BusinessService {
  final _api = ApiClient();

  Future<Map<String, dynamic>> _withMock(
    Future<Map<String, dynamic>> Function() apiCall,
    Map<String, dynamic> mockData,
  ) async {
    if (kDebugMode) {
      try { return await apiCall(); } catch (_) {
        debugPrint('[BUSINESS_SVC] API failed, using mock data');
        return mockData;
      }
    }
    return apiCall();
  }

  // ── Home ──
  Future<Map<String, dynamic>> getHome() => _withMock(
    () => _api.get('/business/home'),
    const {
      'company': {'name': 'Test Restaurant', 'location': 'Milan, Italy'},
      'stats': {'activeJobs': 2, 'applicants': 8, 'newApplicants': 3, 'interviews': 1},
      'nextInterview': {'candidateName': 'Marco Rossi', 'jobTitle': 'Waiter', 'scheduledAt': '2026-04-10T14:00:00Z'},
      'unreadMessages': 3,
    },
  );

  // ── Jobs ──
  Future<Map<String, dynamic>> getJobs() => _withMock(
    () => _api.get('/business/jobs'),
    const {
      'jobs': [
        {'id': 'bj1', 'title': 'Waiter', 'status': 'active', 'applicants': 5, 'posted_at': '2026-04-01T10:00:00Z'},
        {'id': 'bj2', 'title': 'Bartender', 'status': 'active', 'applicants': 3, 'posted_at': '2026-04-03T09:00:00Z'},
      ],
    },
  );

  Future<Map<String, dynamic>> getJobDetail(String jobId) => _withMock(
    () => _api.get('/business/jobs/$jobId'),
    {'id': jobId, 'title': 'Mock Job', 'status': 'active', 'applicants': 5, 'description': 'Mock job for testing.'},
  );

  Future<void> postJob(Map<String, dynamic> jobData) async {
    if (kDebugMode) {
      try { await _api.post('/business/jobs', jobData); } catch (_) { debugPrint('[BUSINESS_SVC] Mock: job posted'); }
      return;
    }
    await _api.post('/business/jobs', jobData);
  }

  // ── Conversations ──
  Future<Map<String, dynamic>> getConversations() => _withMock(
    () => _api.get('/business/conversations'),
    const {
      'conversations': [
        {'id': 'bc1', 'candidate_name': 'Marco Rossi', 'last_message': 'I\'m interested in the waiter position.', 'unread': 2, 'updated_at': '2026-04-07T14:00:00Z'},
        {'id': 'bc2', 'candidate_name': 'Sara Bianchi', 'last_message': 'When can I start?', 'unread': 1, 'updated_at': '2026-04-06T11:00:00Z'},
      ],
    },
  );

  Future<Map<String, dynamic>> getMessages(String conversationId) => _withMock(
    () => _api.get('/business/conversations/$conversationId/messages'),
    const {'messages': [
      {'id': 'm1', 'body': 'Hello! I saw your job listing.', 'sender': 'candidate', 'created_at': '2026-04-07T14:00:00Z'},
      {'id': 'm2', 'body': 'Great, let\'s schedule an interview.', 'sender': 'business', 'created_at': '2026-04-07T14:10:00Z'},
    ]},
  );

  Future<void> sendMessage(String conversationId, String body) async {
    if (kDebugMode) {
      try { await _api.post('/business/conversations/$conversationId/messages', {'body': body}); } catch (_) {}
      return;
    }
    await _api.post('/business/conversations/$conversationId/messages', {'body': body});
  }

  // ── Interviews ──
  Future<Map<String, dynamic>> getInterviews() => _withMock(
    () => _api.get('/business/interviews'),
    const {
      'interviews': [
        {'id': 'bi1', 'candidate_name': 'Marco Rossi', 'job_title': 'Waiter', 'scheduled_at': '2026-04-10T14:00:00Z', 'type': 'in_person'},
      ],
    },
  );

  Future<void> scheduleInterview(Map<String, dynamic> data) async {
    if (kDebugMode) {
      try { await _api.post('/business/interviews', data); } catch (_) { debugPrint('[BUSINESS_SVC] Mock: interview scheduled'); }
      return;
    }
    await _api.post('/business/interviews', data);
  }

  // ── Candidates ──
  Future<Map<String, dynamic>> getCandidateProfile(String candidateId) => _withMock(
    () => _api.get('/business/candidates/$candidateId'),
    {'id': candidateId, 'name': 'Mock Candidate', 'role': 'Waiter', 'experience': '3 years', 'location': 'London, UK'},
  );

  // ── Profile ──
  Future<Map<String, dynamic>> getProfile() => _withMock(
    () => _api.get('/business/profile'),
    const {'id': 'mock_business_001', 'company_name': 'Test Restaurant', 'email': 'business@test.com', 'location': 'Milan, Italy'},
  );

  Future<void> updateProfile(Map<String, dynamic> fields) async {
    if (kDebugMode) {
      try { await _api.put('/business/profile', fields); } catch (_) { debugPrint('[BUSINESS_SVC] Mock: profile updated'); }
      return;
    }
    await _api.put('/business/profile', fields);
  }

  Future<Map<String, dynamic>> getUnreadCount() => _withMock(
    () => _api.get('/business/unread-count'),
    const {'unread': 3},
  );
}
