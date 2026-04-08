/// Typed conversation & chat message models — replaces message.dart.
///
/// Mirrors the Swift messaging DTOs.
library;

import 'package:plagit/core/mock/mock_data.dart';

// ─────────────────────────────────────────────
// Conversation
// ─────────────────────────────────────────────

/// A conversation thread between a candidate and a business.
class Conversation {
  final String id;
  final String company;
  final String jobContext;
  final String lastMessage;
  final String time;
  final int unread;

  const Conversation({
    required this.id,
    required this.company,
    required this.jobContext,
    required this.lastMessage,
    required this.time,
    this.unread = 0,
  });

  // ── JSON serialisation ──

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id']?.toString() ?? '',
      company: json['company'] as String? ?? '',
      jobContext: json['jobContext'] as String? ?? '',
      lastMessage: json['lastMessage'] as String? ?? '',
      time: json['time'] as String? ?? '',
      unread: json['unread'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'company': company,
        'jobContext': jobContext,
        'lastMessage': lastMessage,
        'time': time,
        'unread': unread,
      };

  // ── Mock factory ──

  /// Returns all mock conversations as typed [Conversation] instances.
  static List<Conversation> mockAll() =>
      MockData.conversations.map((c) => Conversation.fromJson(c)).toList();
}

// ─────────────────────────────────────────────
// ChatMessage
// ─────────────────────────────────────────────

/// A single message within a conversation thread.
class ChatMessage {
  final String sender; // 'business' | 'candidate'
  final String text;
  final String time;

  const ChatMessage({
    required this.sender,
    required this.text,
    required this.time,
  });

  // ── JSON serialisation ──

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      sender: json['sender'] as String? ?? '',
      text: json['text'] as String? ?? '',
      time: json['time'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'sender': sender,
        'text': text,
        'time': time,
      };

  /// Whether this message was sent by the business side.
  bool get isFromBusiness => sender == 'business';

  // ── Mock factory ──

  /// Returns the mock Ritz conversation messages.
  static List<ChatMessage> mockRitzMessages() =>
      MockData.ritzMessages.map((m) => ChatMessage.fromJson(m)).toList();
}
