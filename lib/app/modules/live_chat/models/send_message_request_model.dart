import 'dart:convert';

class SendMessageRequestModel {
  final String senderId;
  final String conversationId;
  final String dateTime;
  final String text;

  SendMessageRequestModel({
    required this.senderId,
    required this.conversationId,
    required this.dateTime,
    required this.text,
  });

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
    "senderId": senderId,
    "conversationId": conversationId,
    "dateTime": dateTime,
    "text": text,
  };
}
