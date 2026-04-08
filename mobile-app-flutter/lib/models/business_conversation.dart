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
    return BusinessConversation(
      id: json['id']?.toString() ?? '',
      candidateName: json['candidateName'] as String? ?? '',
      candidateInitials: json['candidateInitials'] as String? ?? '',
      jobContext: json['jobContext'] as String? ?? '',
      lastMessage: json['lastMessage'] as String? ?? '',
      time: json['time'] as String? ?? '',
      unread: json['unread'] as int? ?? 0,
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
}
