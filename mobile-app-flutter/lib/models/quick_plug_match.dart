/// Models for QuickPlug like/interest and match system.
///
/// A business likes a candidate → candidate receives a like.
/// If candidate accepts → a match is created.
/// Business sends first message → conversation unlocked.

enum QuickPlugLikeStatus { pending, accepted, rejected, expired }

/// A business's interest signal toward a candidate.
class QuickPlugLike {
  final String id;
  final String businessId;
  final String businessName;
  final String businessInitials;
  final String? businessPhotoUrl;
  final bool businessVerified;
  final String? jobTitle;
  final String location;
  final DateTime likedAt;
  final QuickPlugLikeStatus status;

  const QuickPlugLike({
    required this.id,
    required this.businessId,
    required this.businessName,
    required this.businessInitials,
    this.businessPhotoUrl,
    this.businessVerified = false,
    this.jobTitle,
    required this.location,
    required this.likedAt,
    this.status = QuickPlugLikeStatus.pending,
  });

  factory QuickPlugLike.fromJson(Map<String, dynamic> json) {
    return QuickPlugLike(
      id: json['id'] as String? ?? '',
      businessId: json['business_id'] as String? ?? json['businessId'] as String? ?? '',
      businessName: json['business_name'] as String? ?? json['businessName'] as String? ?? '',
      businessInitials: json['business_initials'] as String? ?? json['businessInitials'] as String? ?? '',
      businessPhotoUrl: json['business_photo_url'] as String? ?? json['businessPhotoUrl'] as String?,
      businessVerified: json['business_verified'] as bool? ?? json['businessVerified'] as bool? ?? false,
      jobTitle: json['job_title'] as String? ?? json['jobTitle'] as String?,
      location: json['location'] as String? ?? '',
      likedAt: json['liked_at'] != null
          ? DateTime.tryParse(json['liked_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: _parseStatus(json['status'] as String?),
    );
  }

  static QuickPlugLikeStatus _parseStatus(String? s) => switch (s) {
    'accepted' => QuickPlugLikeStatus.accepted,
    'rejected' => QuickPlugLikeStatus.rejected,
    'expired' => QuickPlugLikeStatus.expired,
    _ => QuickPlugLikeStatus.pending,
  };

  static List<QuickPlugLike> mockAll() => [
    QuickPlugLike(
      id: 'ql1', businessId: 'b1', businessName: 'The Ritz London',
      businessInitials: 'TR', businessVerified: true,
      jobTitle: 'Head Waiter', location: 'London, UK',
      likedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    QuickPlugLike(
      id: 'ql2', businessId: 'b2', businessName: 'Nobu Dubai',
      businessInitials: 'ND', businessVerified: true,
      jobTitle: 'Bartender', location: 'Dubai, UAE',
      likedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    QuickPlugLike(
      id: 'ql3', businessId: 'b3', businessName: 'Dishoom Soho',
      businessInitials: 'DS', businessVerified: false,
      jobTitle: 'Line Cook', location: 'London, UK',
      likedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];
}

/// A confirmed match between a business and a candidate.
class QuickPlugMatch {
  final String id;
  final String likeId;
  final String businessId;
  final String candidateId;
  final String businessName;
  final String candidateName;
  final DateTime matchedAt;
  final String? conversationId;
  final bool businessSentFirstMessage;

  const QuickPlugMatch({
    required this.id,
    required this.likeId,
    required this.businessId,
    required this.candidateId,
    required this.businessName,
    required this.candidateName,
    required this.matchedAt,
    this.conversationId,
    this.businessSentFirstMessage = false,
  });

  factory QuickPlugMatch.fromJson(Map<String, dynamic> json) {
    return QuickPlugMatch(
      id: json['id'] as String? ?? '',
      likeId: json['like_id'] as String? ?? json['likeId'] as String? ?? '',
      businessId: json['business_id'] as String? ?? json['businessId'] as String? ?? '',
      candidateId: json['candidate_id'] as String? ?? json['candidateId'] as String? ?? '',
      businessName: json['business_name'] as String? ?? json['businessName'] as String? ?? '',
      candidateName: json['candidate_name'] as String? ?? json['candidateName'] as String? ?? '',
      matchedAt: json['matched_at'] != null
          ? DateTime.tryParse(json['matched_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      conversationId: json['conversation_id'] as String? ?? json['conversationId'] as String?,
      businessSentFirstMessage: json['business_sent_first_message'] as bool? ?? json['businessSentFirstMessage'] as bool? ?? false,
    );
  }
}
