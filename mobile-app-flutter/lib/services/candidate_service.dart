import 'package:plagit/core/api_client.dart';

/// Mirrors CandidateAPIService.swift — all candidate endpoints.
class CandidateService {
  final _api = ApiClient();

  // ── Home ──
  Future<Map<String, dynamic>> getHome() async {
    return _api.get('/candidate/home');
  }

  // ── Jobs ──
  Future<Map<String, dynamic>> getJobs({
    int page = 1,
    String? search,
    String? category,
    String? jobType,
    String? sort,
  }) async {
    final params = <String, String>{'page': page.toString()};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (category != null && category.isNotEmpty) params['category'] = category;
    if (jobType != null && jobType.isNotEmpty) params['job_type'] = jobType;
    if (sort != null && sort.isNotEmpty) params['sort'] = sort;
    final query = params.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
    return _api.get('/candidate/jobs?$query');
  }

  Future<Map<String, dynamic>> getJobDetail(String jobId) async {
    return _api.get('/candidate/jobs/$jobId');
  }

  Future<void> applyToJob(String jobId, {String? coverLetter}) async {
    await _api.post('/candidate/jobs/$jobId/apply', {
      if (coverLetter != null) 'cover_letter': coverLetter,
    });
  }

  // ── Applications ──
  Future<Map<String, dynamic>> getApplications() async {
    return _api.get('/candidate/applications');
  }

  // ── Conversations ──
  Future<Map<String, dynamic>> getConversations() async {
    return _api.get('/candidate/conversations');
  }

  Future<Map<String, dynamic>> getMessages(String conversationId) async {
    return _api.get('/candidate/conversations/$conversationId/messages');
  }

  Future<void> sendMessage(String conversationId, String body) async {
    await _api.post('/candidate/conversations/$conversationId/messages', {
      'body': body,
    });
  }

  // ── Profile ──
  Future<Map<String, dynamic>> getProfile() async {
    return _api.get('/candidate/profile');
  }

  Future<void> updateProfile(Map<String, dynamic> fields) async {
    await _api.put('/candidate/profile', fields);
  }
}
