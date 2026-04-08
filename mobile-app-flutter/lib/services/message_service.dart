import 'package:plagit/core/api_client.dart';

class MessageService {
  final _api = ApiClient();

  Future<List<Map<String, dynamic>>> getConversations() async {
    final data = await _api.get('/candidate/messages');
    return List<Map<String, dynamic>>.from(data['conversations'] as List);
  }

  Future<List<Map<String, dynamic>>> getMessages(int conversationId) async {
    final data = await _api.get('/candidate/messages/$conversationId');
    return List<Map<String, dynamic>>.from(data['messages'] as List);
  }

  Future<void> sendMessage({required int receiverId, required String content}) async {
    await _api.post('/candidate/messages', {
      'receiver_id': receiverId,
      'content': content,
    });
  }
}
