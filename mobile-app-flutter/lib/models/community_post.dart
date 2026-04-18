/// Community / social-feed models — shared by Candidate, Business, and Admin.
///
/// All 3 sides read and mutate the same `CommunityProvider` state, so the
/// like / save / comment / report / hide actions are consistent across the
/// product.
library;

import 'package:plagit/core/mock/mock_data.dart';

// ─────────────────────────────────────────────
// AuthorKind & PostType
// ─────────────────────────────────────────────

/// Who authored a post — drives badging (verified seal, business chip) and
/// what action sheets are available (e.g. business posts can be "Followed").
enum AuthorKind {
  candidate,
  business,
  admin;

  static AuthorKind fromString(String s) {
    final lower = s.toLowerCase();
    return switch (lower) {
      'business' => business,
      'admin' => admin,
      _ => candidate,
    };
  }
}

/// Type of post — determines how the body renders.
enum PostType {
  text,
  image,
  multiImage,
  video,
  promotion;

  static PostType fromString(String s) {
    final lower = s.toLowerCase().replaceAll('_', '').replaceAll(' ', '');
    return switch (lower) {
      'image' => image,
      'multiimage' || 'gallery' => multiImage,
      'video' => video,
      'promotion' || 'promo' => promotion,
      _ => text,
    };
  }
}

// ─────────────────────────────────────────────
// Comment
// ─────────────────────────────────────────────

/// A comment on a community post.
class Comment {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String authorInitials;
  final AuthorKind authorKind;
  final bool authorVerified;
  final String? authorPhotoUrl;
  final String body;
  final String timeAgo;

  const Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.authorInitials,
    this.authorKind = AuthorKind.candidate,
    this.authorVerified = false,
    this.authorPhotoUrl,
    required this.body,
    required this.timeAgo,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json['id'] as String? ?? '',
        postId: json['postId'] as String? ?? '',
        authorId: json['authorId'] as String? ?? '',
        authorName: json['authorName'] as String? ?? '',
        authorInitials: json['authorInitials'] as String? ?? '?',
        authorKind: AuthorKind.fromString(json['authorKind'] as String? ?? 'candidate'),
        authorVerified: json['authorVerified'] as bool? ?? false,
        authorPhotoUrl: json['authorPhotoUrl'] as String?,
        body: json['body'] as String? ?? '',
        timeAgo: json['timeAgo'] as String? ?? 'now',
      );
}

// ─────────────────────────────────────────────
// CommunityPost
// ─────────────────────────────────────────────

class CommunityPost {
  final String id;
  final String authorId;
  final String authorName;
  final String authorInitials;
  final AuthorKind authorKind;
  final String authorRole; // e.g. "Head Chef", "Restaurant Owner"
  final String? authorLocation;
  final bool authorVerified;
  /// Author headshot URL — null for businesses (use brand identity instead).
  final String? authorPhotoUrl;
  final PostType type;
  final String body;
  final List<String> images;
  final String? videoUrl;
  final String timeAgo;
  // Mutable engagement state
  int likes;
  int commentsCount;
  int views;
  /// Total number of saves (any user) — drives the global Saves counter on
  /// the Post Insights sheet. Distinct from `isSaved` (per-viewer flag).
  int saves;
  bool isLiked;
  bool isSaved;
  bool isHidden; // moderation
  bool isReported; // moderation flag

  CommunityPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorInitials,
    this.authorKind = AuthorKind.candidate,
    required this.authorRole,
    this.authorLocation,
    this.authorVerified = false,
    this.authorPhotoUrl,
    this.type = PostType.text,
    required this.body,
    this.images = const [],
    this.videoUrl,
    required this.timeAgo,
    this.likes = 0,
    this.commentsCount = 0,
    this.views = 0,
    this.saves = 0,
    this.isLiked = false,
    this.isSaved = false,
    this.isHidden = false,
    this.isReported = false,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    final imagesRaw = json['images'];
    final images = imagesRaw is List ? imagesRaw.map((e) => e.toString()).toList() : <String>[];
    return CommunityPost(
      id: json['id'] as String? ?? '',
      authorId: json['authorId'] as String? ?? '',
      authorName: json['authorName'] as String? ?? '',
      authorInitials: json['authorInitials'] as String? ?? '?',
      authorKind: AuthorKind.fromString(json['authorKind'] as String? ?? 'candidate'),
      authorRole: json['authorRole'] as String? ?? '',
      authorLocation: json['authorLocation'] as String?,
      authorVerified: json['authorVerified'] as bool? ?? false,
      authorPhotoUrl: json['authorPhotoUrl'] as String?,
      type: PostType.fromString(json['type'] as String? ?? 'text'),
      body: json['body'] as String? ?? '',
      images: images,
      videoUrl: json['videoUrl'] as String?,
      timeAgo: json['timeAgo'] as String? ?? 'now',
      likes: json['likes'] as int? ?? 0,
      commentsCount: json['commentsCount'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
      saves: json['saves'] as int? ?? ((json['views'] as int? ?? 0) * 0.08).round(),
      isLiked: json['isLiked'] as bool? ?? false,
      isSaved: json['isSaved'] as bool? ?? false,
      isHidden: json['isHidden'] as bool? ?? false,
      isReported: json['isReported'] as bool? ?? false,
    );
  }

  // ── Mock factory ──
  static List<CommunityPost> mockAll() =>
      MockData.communityPosts.map((p) => CommunityPost.fromJson(Map<String, dynamic>.from(p))).toList();
}

// ─────────────────────────────────────────────
// CommunityNotification
// ─────────────────────────────────────────────

enum CommunityNotifType { like, comment, follow, mention, system }

class CommunityNotification {
  final String id;
  final CommunityNotifType type;
  final String actorName;
  final String actorInitials;
  final bool actorVerified;
  final String? actorPhotoUrl;
  final String? postId; // tap target if applicable
  final String? preview;
  final String timeAgo;
  bool isRead;

  CommunityNotification({
    required this.id,
    required this.type,
    required this.actorName,
    required this.actorInitials,
    this.actorVerified = false,
    this.actorPhotoUrl,
    this.postId,
    this.preview,
    required this.timeAgo,
    this.isRead = false,
  });

  factory CommunityNotification.fromJson(Map<String, dynamic> json) {
    final typeStr = (json['type'] as String? ?? 'like').toLowerCase();
    final type = switch (typeStr) {
      'comment' => CommunityNotifType.comment,
      'follow' => CommunityNotifType.follow,
      'mention' => CommunityNotifType.mention,
      'system' => CommunityNotifType.system,
      _ => CommunityNotifType.like,
    };
    return CommunityNotification(
      id: json['id'] as String? ?? '',
      type: type,
      actorName: json['actorName'] as String? ?? '',
      actorInitials: json['actorInitials'] as String? ?? '?',
      actorVerified: json['actorVerified'] as bool? ?? false,
      actorPhotoUrl: json['actorPhotoUrl'] as String?,
      postId: json['postId'] as String?,
      preview: json['preview'] as String?,
      timeAgo: json['timeAgo'] as String? ?? 'now',
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}

// ─────────────────────────────────────────────
// PostInsights — premium analytics surface
// ─────────────────────────────────────────────

/// Aggregated, privacy-safe analytics for a single post.
///
/// Drives the Post Insights bottom sheet shown when an author taps the
/// engagement row on their own post (Candidate or Business). Free users see
/// only the top counters; premium users unlock the breakdowns below.
///
/// Privacy rules:
///   • Always aggregated — never exposes individual viewer identities by
///     default. Counts only.
///   • Top cities are city-level, not address-level.
///   • Audience role is grouped (Manager / Chef / Recruiter / Venue) — never
///     individual job titles.
class PostInsights {
  // ── Always-visible counters (free tier) ──
  final int views;
  final int saves;
  final int likes;
  final int commentsCount;

  // ── Premium fields ──
  /// Top cities the post was viewed from, descending order.
  final List<({String city, int count})> topCities;

  /// How viewers discovered the post. Keys: For You / Nearby / Following /
  /// Profile.
  final Map<String, int> discoverySources;

  /// Aggregated viewer kinds. Keys: Business / Candidate.
  final Map<String, int> viewerKinds;

  /// Aggregated audience role buckets. Top entries first.
  final List<({String role, int count})> audienceRoles;

  /// 7-point series for the weekly performance trend.
  final List<int> weeklyTrend;

  // ── Admin-only flags ──
  /// Set when the engagement looks suspicious (spike, bot pattern, etc.)
  final bool suspicious;
  final String? suspiciousReason;

  const PostInsights({
    required this.views,
    required this.saves,
    required this.likes,
    required this.commentsCount,
    this.topCities = const [],
    this.discoverySources = const {},
    this.viewerKinds = const {},
    this.audienceRoles = const [],
    this.weeklyTrend = const [],
    this.suspicious = false,
    this.suspiciousReason,
  });

  /// Total premium engagement points (used in the headline summary).
  int get totalEngagement => likes + commentsCount + saves;
}
