import 'package:flutter/foundation.dart';
import 'package:plagit/core/api_client.dart';

/// Mock data returned in debug mode when the real API is unavailable.
const _mockHomeData = <String, dynamic>{
  'user': {
    'name': 'Test Candidate',
    'first_name': 'Test',
    'last_name': 'Candidate',
    'location': 'London, UK',
    'profileStrength': 65,
  },
  'applicationsSummary': {
    'applied': 3,
    'under_review': 1,
    'interview': 1,
    'offer': 0,
  },
  'unreadMessages': 2,
  'unreadNotifications': 4,
  'featuredJobs': [
    {
      'id': 'mock_job_1',
      'title': 'Waiter',
      'businessName': 'The Ritz',
      'location': 'London, UK',
      'salary': '£14/hr',
      'employmentType': 'Full-time',
      'isFeatured': true,
    },
    {
      'id': 'mock_job_2',
      'title': 'Bartender',
      'businessName': 'Nobu',
      'location': 'Dubai, UAE',
      'salary': '£16/hr',
      'employmentType': 'Full-time',
      'isFeatured': true,
    },
    {
      'id': 'mock_job_3',
      'title': 'Chef de Partie',
      'businessName': 'Cipriani',
      'location': 'London, UK',
      'salary': '£18/hr',
      'employmentType': 'Full-time',
      'isFeatured': false,
    },
    {
      'id': 'mock_job_4',
      'title': 'Hostess',
      'businessName': 'Zuma',
      'location': 'London, UK',
      'salary': '£13/hr',
      'employmentType': 'Part-time',
      'isFeatured': false,
    },
  ],
};

const _mockJobsData = <String, dynamic>{
  'jobs': [
    {
      'id': 'mock_job_1',
      'title': 'Waiter',
      'business_name': 'The Ritz',
      'location': 'London, UK',
      'salary': '£14/hr',
      'employment_type': 'Full-time',
      'posted_at': '2026-04-06T10:00:00Z',
    },
    {
      'id': 'mock_job_2',
      'title': 'Bartender',
      'business_name': 'Nobu',
      'location': 'Dubai, UAE',
      'salary': '£16/hr',
      'employment_type': 'Full-time',
      'posted_at': '2026-04-05T09:00:00Z',
    },
    {
      'id': 'mock_job_3',
      'title': 'Chef de Partie',
      'business_name': 'Cipriani',
      'location': 'London, UK',
      'salary': '£18/hr',
      'employment_type': 'Full-time',
      'posted_at': '2026-04-04T14:00:00Z',
    },
    {
      'id': 'mock_job_4',
      'title': 'Hostess',
      'business_name': 'Zuma',
      'location': 'London, UK',
      'salary': '£13/hr',
      'employment_type': 'Part-time',
      'posted_at': '2026-04-03T08:00:00Z',
    },
  ],
  'total': 4,
  'page': 1,
};

const _mockApplicationsData = <String, dynamic>{
  'applications': [
    {
      'id': 'mock_app_1',
      'job_title': 'Waiter',
      'business_name': 'The Ritz',
      'status': 'under_review',
      'applied_at': '2026-04-06T10:00:00Z',
    },
    {
      'id': 'mock_app_2',
      'job_title': 'Bartender',
      'business_name': 'Nobu',
      'status': 'applied',
      'applied_at': '2026-04-05T09:00:00Z',
    },
  ],
};

const _mockConversationsData = <String, dynamic>{
  'conversations': [
    {
      'id': 'mock_conv_1',
      'business_name': 'The Ritz',
      'last_message': 'We\'d love to schedule an interview!',
      'unread': 1,
      'updated_at': '2026-04-07T14:00:00Z',
    },
    {
      'id': 'mock_conv_2',
      'business_name': 'Nobu',
      'last_message': 'Thank you for applying.',
      'unread': 1,
      'updated_at': '2026-04-06T11:00:00Z',
    },
  ],
};

const _mockProfileData = <String, dynamic>{
  'id': 'mock_candidate_001',
  'name': 'Test Candidate',
  'email': 'candidate@test.com',
  'role': 'Waiter',
  'location': 'London, UK',
  'experience': '3 years',
  'languages': ['English', 'Italian'],
  'profileStrength': 65,
};

/// Mirrors CandidateAPIService.swift — all candidate endpoints.
/// In debug mode, returns mock data when the API is unreachable.
class CandidateService {
  final _api = ApiClient();

  /// Wraps an API call with mock fallback in debug mode.
  Future<Map<String, dynamic>> _withMockFallback(
    Future<Map<String, dynamic>> Function() apiCall,
    Map<String, dynamic> mockData,
  ) async {
    if (kDebugMode) {
      try {
        return await apiCall();
      } catch (_) {
        debugPrint('[CANDIDATE_SVC] API failed, using mock data');
        return mockData;
      }
    }
    return apiCall();
  }

  // ── Home ──
  Future<Map<String, dynamic>> getHome() =>
      _withMockFallback(() => _api.get('/candidate/home'), _mockHomeData);

  // ── Jobs ──
  Future<Map<String, dynamic>> getJobs({
    int page = 1,
    String? search,
    String? category,
    String? jobType,
    String? sort,
  }) {
    final params = <String, String>{'page': page.toString()};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (category != null && category.isNotEmpty) params['category'] = category;
    if (jobType != null && jobType.isNotEmpty) params['job_type'] = jobType;
    if (sort != null && sort.isNotEmpty) params['sort'] = sort;
    final query = params.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
    return _withMockFallback(() => _api.get('/candidate/jobs?$query'), _mockJobsData);
  }

  Future<Map<String, dynamic>> getJobDetail(String jobId) =>
      _withMockFallback(() => _api.get('/candidate/jobs/$jobId'), {
        'id': jobId,
        'title': 'Mock Job',
        'business_name': 'Mock Business',
        'location': 'London, UK',
        'salary': '£15/hr',
        'description': 'This is a mock job detail for local testing.',
      });

  Future<void> applyToJob(String jobId, {String? coverLetter}) async {
    if (kDebugMode) {
      try {
        await _api.post('/candidate/jobs/$jobId/apply', {
          if (coverLetter != null) 'cover_letter': coverLetter,
        });
      } catch (_) {
        debugPrint('[CANDIDATE_SVC] Mock: applied to job $jobId');
      }
      return;
    }
    await _api.post('/candidate/jobs/$jobId/apply', {
      if (coverLetter != null) 'cover_letter': coverLetter,
    });
  }

  // ── Applications ──
  Future<Map<String, dynamic>> getApplications() =>
      _withMockFallback(() => _api.get('/candidate/applications'), _mockApplicationsData);

  // ── Conversations ──
  Future<Map<String, dynamic>> getConversations() =>
      _withMockFallback(() => _api.get('/candidate/conversations'), _mockConversationsData);

  Future<Map<String, dynamic>> getMessages(String conversationId) =>
      _withMockFallback(() => _api.get('/candidate/conversations/$conversationId/messages'), {
        'messages': [
          {'id': 'msg1', 'body': 'Hello! We reviewed your application.', 'sender': 'business', 'created_at': '2026-04-07T14:00:00Z'},
          {'id': 'msg2', 'body': 'Thank you! I\'m very interested.', 'sender': 'candidate', 'created_at': '2026-04-07T14:05:00Z'},
        ],
      });

  Future<void> sendMessage(String conversationId, String body) async {
    if (kDebugMode) {
      try {
        await _api.post('/candidate/conversations/$conversationId/messages', {'body': body});
      } catch (_) {
        debugPrint('[CANDIDATE_SVC] Mock: sent message to $conversationId');
      }
      return;
    }
    await _api.post('/candidate/conversations/$conversationId/messages', {'body': body});
  }

  // ── Profile ──
  Future<Map<String, dynamic>> getProfile() =>
      _withMockFallback(() => _api.get('/candidate/profile'), _mockProfileData);

  Future<void> updateProfile(Map<String, dynamic> fields) async {
    if (kDebugMode) {
      try {
        await _api.put('/candidate/profile', fields);
      } catch (_) {
        debugPrint('[CANDIDATE_SVC] Mock: profile updated');
      }
      return;
    }
    await _api.put('/candidate/profile', fields);
  }
}
