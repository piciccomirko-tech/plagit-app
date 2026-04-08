import 'package:plagit/core/api_client.dart';
import 'package:plagit/models/message.dart';

class MessageService {
  final _api = ApiClient();

  Future<List<Map<String, dynamic>>> getConversations() async {
    final data = await _api.get('/candidate/messages');
    return List<Map<String, dynamic>>.from(data['conversations'] as List);
  }

  Future<List<Message>> getMessages(int conversationId) async {
    final data = await _api.get('/candidate/messages/$conversationId');
    final messages = data['messages'] as List;
    return messages.map((m) => Message.fromJson(m as Map<String, dynamic>)).toList();
  }

  Future<void> sendMessage({required int receiverId, required String content}) async {
    await _api.post('/candidate/messages', {
      'receiver_id': receiverId,
      'content': content,
    });
  }
}
