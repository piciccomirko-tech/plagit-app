import 'package:plagit/core/api_client.dart';

/// Mirrors BusinessAPIService.swift — all business endpoints.
class BusinessService {
  final _api = ApiClient();

  // ── Home ──
  Future<Map<String, dynamic>> getHome() async => _api.get('/business/home');

  // ── Jobs ──
  Future<Map<String, dynamic>> getJobs() async => _api.get('/business/jobs');

  Future<Map<String, dynamic>> getJobDetail(String jobId) async =>
      _api.get('/business/jobs/$jobId');

  Future<void> postJob(Map<String, dynamic> jobData) async =>
      await _api.post('/business/jobs', jobData);

  // ── Conversations ──
  Future<Map<String, dynamic>> getConversations() async =>
      _api.get('/business/conversations');

  Future<Map<String, dynamic>> getMessages(String conversationId) async =>
      _api.get('/business/conversations/$conversationId/messages');

  Future<void> sendMessage(String conversationId, String body) async =>
      await _api.post('/business/conversations/$conversationId/messages', {'body': body});

  // ── Interviews ──
  Future<Map<String, dynamic>> getInterviews() async =>
      _api.get('/business/interviews');

  Future<void> scheduleInterview(Map<String, dynamic> data) async =>
      await _api.post('/business/interviews', data);

  // ── Candidates ──
  Future<Map<String, dynamic>> getCandidateProfile(String candidateId) async =>
      _api.get('/business/candidates/$candidateId');

  // ── Profile ──
  Future<Map<String, dynamic>> getProfile() async =>
      _api.get('/business/profile');

  Future<void> updateProfile(Map<String, dynamic> fields) async =>
      await _api.put('/business/profile', fields);

  Future<Map<String, dynamic>> getUnreadCount() async =>
      _api.get('/business/unread-count');
}
