/// Typed business conversation model — represents a message thread with a candidate.
///
/// Distinct from `Conversation` (candidate-side) which uses company names.
/// This model uses candidate names since the business is the viewer.
library;

import 'package:plagit/core/mock/mock_data.dart';

// -----------------------------------------
// BusinessConversation
// -----------------------------------------

/// A conversation thread between a business and a candidate.
class BusinessConversation {
  final String id;
  final String candidateName;
  final String candidateInitials;
  final String jobContext;
  final String lastMessage;
  final String time;
  final int unread;

  const BusinessConversation({
    required this.id,
    required this.candidateName,
    required this.candidateInitials,
    required this.jobContext,
    required this.lastMessage,
    required this.time,
    this.unread = 0,
  });

  // -- JSON serialisation --

  factory BusinessConversation.fromJson(Map<String, dynamic> json) {
    final candidateName =
        json['candidateName'] as String? ??
        json['candidate_name'] as String? ??
        '';
    final candidateInitials =
        json['candidateInitials'] as String? ??
        json['candidate_initials'] as String? ??
        _deriveInitials(candidateName);
    return BusinessConversation(
      id: json['id']?.toString() ?? '',
      candidateName: candidateName,
      candidateInitials: candidateInitials,
      jobContext:
          json['jobContext'] as String? ??
          json['job_context'] as String? ??
          json['jobTitle'] as String? ??
          json['job_title'] as String? ??
          '',
      lastMessage:
          json['lastMessage'] as String? ??
          json['last_message'] as String? ??
          '',
      time:
          json['time'] as String? ??
          json['updated_at'] as String? ??
          '',
      unread:
          (json['unread_count'] as num?)?.toInt() ??
          (json['unread'] as num?)?.toInt() ??
          0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'candidateName': candidateName,
        'candidateInitials': candidateInitials,
        'jobContext': jobContext,
        'lastMessage': lastMessage,
        'time': time,
        'unread': unread,
      };

  // -- Mock factory --

  /// Returns all mock business conversations as typed instances.
  static List<BusinessConversation> mockAll() =>
      MockData.businessConversations
          .map((c) => BusinessConversation.fromJson(c))
          .toList();

  static String _deriveInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .toList();
    if (parts.isEmpty) return '';
    return parts.map((part) => part[0].toUpperCase()).join();
  }
}
