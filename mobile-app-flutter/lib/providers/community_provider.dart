import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/models/community_post.dart';

/// Categories the user can sort their saved posts into. Mirrors the
/// approved Swift `SavedPostCategory` enum so behavior is parity-equivalent
/// across iOS native and Flutter.
enum SavedPostCategory {
  restaurants,
  cookingVideos,
  jobsTips,
  hospitalityNews,
  recipes,
  other;

  String get label => switch (this) {
        SavedPostCategory.restaurants => 'Restaurants',
        SavedPostCategory.cookingVideos => 'Cooking Videos',
        SavedPostCategory.jobsTips => 'Jobs Tips',
        SavedPostCategory.hospitalityNews => 'Hospitality News',
        SavedPostCategory.recipes => 'Recipes',
        SavedPostCategory.other => 'Other',
      };

  IconData get icon => switch (this) {
        SavedPostCategory.restaurants => Icons.restaurant_menu,
        SavedPostCategory.cookingVideos => CupertinoIcons.play_rectangle_fill,
        SavedPostCategory.jobsTips => CupertinoIcons.lightbulb_fill,
        SavedPostCategory.hospitalityNews => CupertinoIcons.news_solid,
        SavedPostCategory.recipes => CupertinoIcons.book_fill,
        SavedPostCategory.other => CupertinoIcons.folder_fill,
      };
}

/// Single source of truth for the community feed across Candidate, Business
/// and Admin sides. Holding the state in one provider means a like, save, or
/// hide action on one side is immediately reflected on the others.
///
/// All methods mutate state synchronously and call `notifyListeners()` so the
/// UI updates instantly without waiting for a backend round-trip. When the
/// real API is wired, each method becomes an optimistic write + repository
/// call without any UI changes.
class CommunityProvider extends ChangeNotifier {
  final List<CommunityPost> _posts = [];
  final List<Comment> _comments = [];
  final List<CommunityNotification> _notifications = [];

  /// postId → category the viewer filed this saved post into.
  /// Local-only for now; persists in memory until backend lands.
  final Map<String, SavedPostCategory> _savedCategories = {};

  /// Identity of the currently-active viewer. Updated by the side that
  /// owns the screen so `createPost()` can attribute correctly.
  String _viewerId = 'me';
  String _viewerName = 'You';
  String _viewerInitials = 'YO';
  AuthorKind _viewerKind = AuthorKind.candidate;
  String _viewerRole = 'Hospitality Pro';
  String _viewerLocation = 'London';
  bool _viewerVerified = false;

  CommunityProvider() {
    _seedFromMock();
  }

  // ── Read state ──
  List<CommunityPost> get all => List.unmodifiable(_posts);
  List<CommunityPost> get visible =>
      _posts.where((p) => !p.isHidden).toList(growable: false);
  List<CommunityNotification> get notifications =>
      List.unmodifiable(_notifications);
  int get unreadNotifications =>
      _notifications.where((n) => !n.isRead).length;

  /// Posts saved by the current viewer.
  List<CommunityPost> get saved =>
      _posts.where((p) => p.isSaved && !p.isHidden).toList(growable: false);

  /// Posts authored by the current viewer (used by business profile).
  List<CommunityPost> get myPosts =>
      _posts.where((p) => p.authorId == _viewerId).toList(growable: false);

  /// Posts that have been reported (admin-only).
  List<CommunityPost> get reported =>
      _posts.where((p) => p.isReported).toList(growable: false);

  // ── Identity ──
  void setViewer({
    required String id,
    required String name,
    required String initials,
    AuthorKind kind = AuthorKind.candidate,
    String role = 'Hospitality Pro',
    String location = 'London',
    bool verified = false,
  }) {
    _viewerId = id;
    _viewerName = name;
    _viewerInitials = initials;
    _viewerKind = kind;
    _viewerRole = role;
    _viewerLocation = location;
    _viewerVerified = verified;
  }

  AuthorKind get viewerKind => _viewerKind;
  String get viewerName => _viewerName;
  String get viewerInitials => _viewerInitials;
  String get viewerId => _viewerId;
  String get viewerRole => _viewerRole;

  // ── Lookups ──
  CommunityPost? postById(String id) {
    for (final p in _posts) {
      if (p.id == id) return p;
    }
    return null;
  }

  List<Comment> commentsFor(String postId) =>
      _comments.where((c) => c.postId == postId).toList(growable: false);

  // ──────────────────────────────────────────────
  // POST INSIGHTS — premium analytics for an author
  //
  // Deterministically derives an aggregated, privacy-safe insights view from
  // the post's ID + live counters. Same input → same output every render so
  // the sheet doesn't shuffle on rebuild. When a real backend lands, swap
  // this for a `_repo.fetchPostInsights(postId)` call without touching the
  // sheet UI.
  // ──────────────────────────────────────────────
  PostInsights insightsFor(String postId) {
    final post = postById(postId);
    if (post == null) {
      return const PostInsights(views: 0, saves: 0, likes: 0, commentsCount: 0);
    }

    final views = post.views;
    final saves = post.saves;
    final likes = post.likes;
    final comments = post.commentsCount;

    // Stable seed so the breakdowns don't reshuffle between rebuilds.
    final seed = post.id.hashCode.abs();

    // ── Top cities (deterministic distribution) ──
    const cityPool = [
      'London', 'Dubai', 'Milan', 'Paris', 'Barcelona', 'Rome', 'New York',
    ];
    final cityCount = (3 + (seed % 3)).clamp(2, 5); // 3–5 cities
    int remaining = views;
    final cities = <({String city, int count})>[];
    for (int i = 0; i < cityCount; i++) {
      // Larger share for the first city (~45%), tapering down.
      final share = i == 0
          ? (views * 0.45).round()
          : i == 1
              ? (views * 0.25).round()
              : i == 2
                  ? (views * 0.15).round()
                  : (views * 0.08).round();
      final count = i == cityCount - 1 ? remaining : share;
      remaining -= count;
      if (count <= 0) continue;
      cities.add((city: cityPool[(seed + i) % cityPool.length], count: count));
    }

    // ── Discovery sources (must sum to ~views) ──
    final discoverySources = <String, int>{
      'For You': (views * 0.55).round(),
      'Nearby': (views * 0.20).round(),
      'Following': (views * 0.15).round(),
      'Profile': (views * 0.10).round(),
    };

    // ── Viewer kinds (privacy-safe aggregate) ──
    // Heuristic: posts from business authors attract candidates, and vice
    // versa. ~30% of viewers are the opposite kind, the rest are same-kind.
    final isBusinessAuthor = post.authorKind == AuthorKind.business;
    final viewerKinds = <String, int>{
      'Candidate': isBusinessAuthor ? (views * 0.70).round() : (views * 0.30).round(),
      'Business': isBusinessAuthor ? (views * 0.30).round() : (views * 0.70).round(),
    };

    // ── Audience roles ──
    const candidateRolePool = [
      'Manager', 'Chef', 'Bartender', 'Waiter', 'Sommelier', 'Host',
    ];
    const businessRolePool = [
      'Restaurant', 'Hotel', 'Cocktail Bar', 'Cafe', 'Catering',
    ];
    final rolePool = isBusinessAuthor ? candidateRolePool : businessRolePool;
    final audienceRoles = <({String role, int count})>[];
    final roleCount = rolePool.length.clamp(3, 5);
    for (int i = 0; i < roleCount; i++) {
      final share = (views * (0.34 - i * 0.06)).round().clamp(0, views);
      if (share <= 0) break;
      audienceRoles.add((role: rolePool[(seed + i * 3) % rolePool.length], count: share));
    }

    // ── Weekly trend (7 points, smooth curve) ──
    final weeklyTrend = List<int>.generate(7, (i) {
      final ratio = 0.45 + (i * 0.10) + (((seed >> i) % 5) / 100);
      return (views * ratio / 7).round();
    });

    // ── Suspicious-engagement detector (admin only) ──
    // Flags posts where likes vastly exceed views (impossible ratio) or
    // saves spike abnormally vs likes — basic patterns a human moderator
    // would want to inspect.
    final suspicious = (views > 0 && likes > views) ||
        (likes > 0 && saves > likes * 4);
    final suspiciousReason = suspicious
        ? (likes > views
            ? 'Likes exceed view count — possible bot engagement'
            : 'Save-to-like ratio exceeds 4x — unusual pattern')
        : null;

    return PostInsights(
      views: views,
      saves: saves,
      likes: likes,
      commentsCount: comments,
      topCities: cities,
      discoverySources: discoverySources,
      viewerKinds: viewerKinds,
      audienceRoles: audienceRoles,
      weeklyTrend: weeklyTrend,
      suspicious: suspicious,
      suspiciousReason: suspiciousReason,
    );
  }

  // ── Filtering / tabs ──
  /// Posts to show on the candidate "For You" tab — every visible non-hidden
  /// post that isn't reported (so spam doesn't reach the feed).
  List<CommunityPost> forYouFeed({String roleFilter = 'All'}) {
    return _posts
        .where((p) => !p.isHidden && !p.isReported)
        .where((p) => roleFilter == 'All' ||
            p.authorRole.toLowerCase().contains(roleFilter.toLowerCase()))
        .toList(growable: false);
  }

  /// "Following" feed — currently a curated subset (verified authors).
  /// Real product would track follow relationships.
  List<CommunityPost> followingFeed({String roleFilter = 'All'}) {
    return _posts
        .where((p) => !p.isHidden && !p.isReported && p.authorVerified)
        .where((p) => roleFilter == 'All' ||
            p.authorRole.toLowerCase().contains(roleFilter.toLowerCase()))
        .toList(growable: false);
  }

  /// "Nearby" feed — naive: matches the viewer's location field.
  List<CommunityPost> nearbyFeed({String roleFilter = 'All'}) {
    final loc = _viewerLocation.toLowerCase();
    return _posts
        .where((p) => !p.isHidden && !p.isReported)
        .where((p) => (p.authorLocation ?? '').toLowerCase().contains(loc))
        .where((p) => roleFilter == 'All' ||
            p.authorRole.toLowerCase().contains(roleFilter.toLowerCase()))
        .toList(growable: false);
  }

  // ── Mutations: like / save / hide / report ──
  void toggleLike(String postId) {
    final p = postById(postId);
    if (p == null) return;
    p.isLiked = !p.isLiked;
    p.likes += p.isLiked ? 1 : -1;
    if (p.likes < 0) p.likes = 0;
    notifyListeners();
  }

  void toggleSave(String postId) {
    final p = postById(postId);
    if (p == null) return;
    p.isSaved = !p.isSaved;
    p.saves += p.isSaved ? 1 : -1;
    if (p.saves < 0) p.saves = 0;
    if (!p.isSaved) {
      _savedCategories.remove(postId);
    }
    notifyListeners();
  }

  /// Save a post into a specific collection category. If the post wasn't
  /// already saved, this also flips `isSaved` and bumps the saves counter
  /// (so it works as a one-tap "save + categorize" flow from the bookmark
  /// icon). Replaces any existing category.
  void saveToCategory(String postId, SavedPostCategory category) {
    final p = postById(postId);
    if (p == null) return;
    if (!p.isSaved) {
      p.isSaved = true;
      p.saves += 1;
    }
    _savedCategories[postId] = category;
    notifyListeners();
  }

  /// Remove a post from its collection AND unsave it (used by the
  /// "Remove from collection" action inside the picker sheet).
  void removeFromCollection(String postId) {
    final p = postById(postId);
    if (p == null) return;
    if (p.isSaved) {
      p.isSaved = false;
      p.saves -= 1;
      if (p.saves < 0) p.saves = 0;
    }
    _savedCategories.remove(postId);
    notifyListeners();
  }

  /// Returns the category a post is filed under, or null if uncategorized
  /// (or not saved at all).
  SavedPostCategory? categoryFor(String postId) => _savedCategories[postId];

  void incrementViews(String postId) {
    final p = postById(postId);
    if (p == null) return;
    p.views += 1;
    // Don't notify — view-count bumps are silent.
  }

  /// Mark a post as reported. Visible to admins; hidden from main feeds.
  void report(String postId, {String? reason}) {
    final p = postById(postId);
    if (p == null) return;
    p.isReported = true;
    notifyListeners();
  }

  /// Hide a post from a viewer's feed (used for "mute / hide" candidate
  /// action and admin "remove from feed").
  void hide(String postId) {
    final p = postById(postId);
    if (p == null) return;
    p.isHidden = true;
    notifyListeners();
  }

  /// Admin: clear the reported flag (post is OK after review).
  void unreport(String postId) {
    final p = postById(postId);
    if (p == null) return;
    p.isReported = false;
    notifyListeners();
  }

  /// Admin: hard-remove a post from the system.
  void remove(String postId) {
    _posts.removeWhere((p) => p.id == postId);
    _comments.removeWhere((c) => c.postId == postId);
    notifyListeners();
  }

  // ── Comments ──
  void addComment(String postId, String body) {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return;
    final p = postById(postId);
    if (p == null) return;
    final comment = Comment(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      authorId: _viewerId,
      authorName: _viewerName,
      authorInitials: _viewerInitials,
      authorKind: _viewerKind,
      authorVerified: _viewerVerified,
      body: trimmed,
      timeAgo: 'now',
    );
    _comments.add(comment);
    p.commentsCount += 1;
    notifyListeners();
  }

  // ── Create post ──
  CommunityPost createPost({
    required String body,
    PostType type = PostType.text,
    List<String> images = const [],
    String? videoUrl,
  }) {
    final post = CommunityPost(
      id: 'cp_${DateTime.now().millisecondsSinceEpoch}',
      authorId: _viewerId,
      authorName: _viewerName,
      authorInitials: _viewerInitials,
      authorKind: _viewerKind,
      authorRole: _viewerRole,
      authorLocation: _viewerLocation,
      authorVerified: _viewerVerified,
      type: type,
      body: body.trim(),
      images: images,
      videoUrl: videoUrl,
      timeAgo: 'now',
      likes: 0,
      commentsCount: 0,
      views: 0,
    );
    _posts.insert(0, post);
    notifyListeners();
    return post;
  }

  // ── Notifications ──
  void markNotificationRead(String id) {
    for (final n in _notifications) {
      if (n.id == id) {
        n.isRead = true;
        notifyListeners();
        return;
      }
    }
  }

  void markAllNotificationsRead() {
    var changed = false;
    for (final n in _notifications) {
      if (!n.isRead) {
        n.isRead = true;
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  // ── Mock seed ──
  void _seedFromMock() {
    for (final raw in MockData.communityPosts) {
      _posts.add(CommunityPost.fromJson(Map<String, dynamic>.from(raw)));
    }
    for (final raw in MockData.communityComments) {
      _comments.add(Comment.fromJson(Map<String, dynamic>.from(raw)));
    }
    for (final raw in MockData.communityNotifications) {
      _notifications.add(CommunityNotification.fromJson(Map<String, dynamic>.from(raw)));
    }
  }
}
