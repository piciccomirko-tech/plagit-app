class Message {
  final int id;
  final int senderId;
  final int receiverId;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json['id'] as int,
    senderId: json['sender_id'] as int,
    receiverId: json['receiver_id'] as int,
    content: json['content'] as String,
    isRead: json['is_read'] as bool? ?? false,
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}
