import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/widgets/app_back_title_bar.dart';
import 'package:plagit/core/widgets/header_action_icon.dart';
import 'package:plagit/core/widgets/post_insights_sheet.dart';
import 'package:plagit/core/widgets/profile_photo.dart';
import 'package:plagit/core/widgets/search_screen.dart';
import 'package:plagit/models/community_post.dart';
import 'package:plagit/providers/candidate_providers.dart';
import 'package:plagit/providers/community_provider.dart';
import 'package:plagit/providers/recent_searches_provider.dart';

// ═══════════════════════════════════════════════════════════════
// Theme
// ═══════════════════════════════════════════════════════════════
const _tealMain = Color(0xFF00B5B0);
const _tealLight = Color(0x1A00B5B0);
const _bgMain = Color(0xFFF6F7F8);
const _cardBg = Color(0xFFFFFFFF);
const _surface = Color(0xFFF9FAFB);
const _charcoal = Color(0xFF1A1C24);
const _secondary = Color(0xFF707580);
const _tertiary = Color(0xFF9EA3AD);
const _border = Color(0xFFE6E8ED);
const _urgent = Color(0xFFFF3B30);

BoxShadow get _cardShadow => BoxShadow(
  color: Colors.black.withValues(alpha: 0.05),
  blurRadius: 14,
  offset: const Offset(0, 5),
);

class CommunityView extends StatefulWidget {
  const CommunityView({super.key});
  @override
  State<CommunityView> createState() => _CommunityViewState();
}

class _CommunityViewState extends State<CommunityView> {
  int _tabIndex = 0;
  int _roleIndex = 0;

  static const _tabs = ['For You', 'Following', 'Nearby', 'Saved'];
  static const _roles = [
    'All',
    'Chef',
    'Waiter',
    'Bartender',
    'Manager',
    'Sommelier',
    'Reception',
  ];

  void _openSearchScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SearchScreen(
          scope: RecentSearchScope.candidateCommunity,
          title: 'Search Community',
          hintText: 'Search people, posts, venues…',
          resultsBuilder: (ctx, query) {
            final all = ctx.watch<CommunityProvider>().visible;
            final q = query.toLowerCase();
            final results = all
                .where(
                  (p) =>
                      p.body.toLowerCase().contains(q) ||
                      p.authorName.toLowerCase().contains(q) ||
                      p.authorRole.toLowerCase().contains(q) ||
                      (p.authorLocation ?? '').toLowerCase().contains(q),
                )
                .toList();
            if (results.isEmpty) return SearchNoResults(query: query);
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              itemCount: results.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final p = results[i];
                return GestureDetector(
                  onTap: () => ctx.push('/feed/post/${p.id}'),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFEFEFF4),
                        width: 0.5,
                      ),
                      boxShadow: [_cardShadow],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfilePhoto(
                          photoUrl: p.authorPhotoUrl,
                          initials: p.authorInitials,
                          size: 44,
                          square: p.authorKind == AuthorKind.business,
                          verified: p.authorVerified,
                          hueSeed: p.authorName,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.authorName,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: _charcoal,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${p.authorRole}${p.authorLocation != null ? ' · ${p.authorLocation}' : ''}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: _tertiary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                p.body,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: _secondary,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommunityProvider>();
    final roleFilter = _roles[_roleIndex];

    final List<CommunityPost> posts = switch (_tabIndex) {
      1 => provider.followingFeed(roleFilter: roleFilter),
      2 => provider.nearbyFeed(roleFilter: roleFilter),
      3 => provider.saved,
      _ => provider.forYouFeed(roleFilter: roleFilter),
    };

    return Scaffold(
      backgroundColor: _bgMain,
      body: SafeArea(
        child: Column(
          children: [
            // ── TOP BAR ──
            AppBackTitleBar(
              title: 'Community',
              onBack: () => context.canPop() ? context.pop() : null,
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
              backBackgroundColor: _surface,
              titleStyle: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: _charcoal,
                letterSpacing: -0.2,
              ),
              trailingMinWidth: 82,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HeaderActionIcon(
                    onTap: () => _openSearchScreen(context),
                    icon: const Icon(
                      CupertinoIcons.search,
                      size: 20,
                      color: _charcoal,
                    ),
                  ),
                  const SizedBox(width: 16),
                  HeaderActionIcon(
                    onTap: () => context.push('/feed/activity'),
                    icon: SizedBox(
                      width: 24,
                      height: 24,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Center(
                            child: Icon(
                              CupertinoIcons.bell,
                              size: 20,
                              color: _charcoal,
                            ),
                          ),
                          if (provider.unreadNotifications > 0)
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                constraints: const BoxConstraints(
                                  minWidth: 14,
                                  minHeight: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: _urgent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _bgMain,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${provider.unreadNotifications}',
                                    style: const TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  HeaderActionIcon(
                    onTap: () => context.push('/feed/post/create'),
                    icon: const Icon(
                      CupertinoIcons.square_pencil,
                      size: 22,
                      color: _tealMain,
                    ),
                  ),
                ],
              ),
            ),

            // (Search now lives on a dedicated full-screen route.)

            // ── TAB ROW ──
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _tabs.length,
                separatorBuilder: (_, i) => const SizedBox(width: 22),
                itemBuilder: (context, i) {
                  final active = _tabIndex == i;
                  return GestureDetector(
                    onTap: () => setState(() => _tabIndex = i),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _tabs[i],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: active ? _charcoal : _tertiary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: active ? 28 : 0,
                          height: 2,
                          decoration: BoxDecoration(
                            color: _tealMain,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ── ROLE FILTER CHIPS (hidden on Saved tab) ──
            if (_tabIndex != 3)
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  itemCount: _roles.length,
                  separatorBuilder: (_, i) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final active = _roleIndex == i;
                    return GestureDetector(
                      onTap: () => setState(() => _roleIndex = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: active ? _tealMain : Colors.white,
                          borderRadius: BorderRadius.circular(100),
                          border: active
                              ? null
                              : Border.all(color: _border, width: 0.5),
                        ),
                        child: Center(
                          child: Text(
                            _roles[i],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: active
                                  ? Colors.white
                                  : const Color(0xFF3C3C43),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // ── POSTS ──
            Expanded(
              child: posts.isEmpty
                  ? _EmptyState(tab: _tabs[_tabIndex])
                  : RefreshIndicator(
                      color: _tealMain,
                      onRefresh: () async => await Future.delayed(
                        const Duration(milliseconds: 600),
                      ),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
                        itemCount: posts.length,
                        separatorBuilder: (_, i) => const SizedBox(height: 14),
                        itemBuilder: (context, i) => _PostCard(post: posts[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// EMPTY STATE
// ═══════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  final String tab;
  const _EmptyState({required this.tab});

  @override
  Widget build(BuildContext context) {
    final isSaved = tab == 'Saved';
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: _tealLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSaved
                    ? CupertinoIcons.bookmark
                    : CupertinoIcons.bubble_left_bubble_right,
                size: 22,
                color: _tealMain,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isSaved ? 'No saved posts yet' : 'Nothing here yet',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _charcoal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isSaved
                  ? 'Tap the bookmark on any post to keep it for later.'
                  : 'Be the first to share something with the community.',
              style: const TextStyle(fontSize: 13, color: _secondary),
              textAlign: TextAlign.center,
            ),
            if (!isSaved) ...[
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => context.push('/feed/post/create'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: _tealMain,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text(
                    'Create Post',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// POST CARD — fully wired interactions
// ═══════════════════════════════════════════════════════════════

class _PostCard extends StatelessWidget {
  final CommunityPost post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommunityProvider>();
    final isBusiness = post.authorKind == AuthorKind.business;

    return GestureDetector(
      onTap: () {
        provider.incrementViews(post.id);
        context.push('/feed/post/${post.id}');
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEFEFF4), width: 0.5),
          boxShadow: [_cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
              child: Row(
                children: [
                  // ── Real headshot — slightly larger (52 px), square for
                  //    businesses (brand), circle for candidates (personal).
                  //    Face-centered cropping for trust. ──
                  GestureDetector(
                    onTap: () => _openProfile(context),
                    child: ProfilePhoto(
                      photoUrl: post.authorPhotoUrl,
                      initials: post.authorInitials,
                      size: 52,
                      square: isBusiness,
                      verified: post.authorVerified,
                      hueSeed: post.authorName,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _openProfile(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  post.authorName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: _charcoal,
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isBusiness) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _tealLight,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: const Text(
                                    'Business',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: _tealMain,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 1),
                          Text(
                            '${post.authorRole}${post.authorLocation != null ? ' · ${post.authorLocation}' : ''} · ${post.timeAgo}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: _tertiary,
                              letterSpacing: -0.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Three-dot menu
                  GestureDetector(
                    onTap: () => _showPostMenu(context, post),
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        CupertinoIcons.ellipsis,
                        size: 18,
                        color: _tertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── BODY (text) ──
            if (post.body.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  post.body,
                  style: const TextStyle(
                    fontSize: 14.5,
                    color: _charcoal,
                    height: 1.4,
                    letterSpacing: -0.1,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // ── MEDIA ──
            if (post.images.isNotEmpty) _MediaBlock(post: post),

            // ── ENGAGEMENT ROW ──
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Row(
                children: [
                  _ActionPill(
                    icon: post.isLiked
                        ? CupertinoIcons.heart_fill
                        : CupertinoIcons.heart,
                    label: '${post.likes}',
                    color: post.isLiked ? _urgent : _secondary,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      provider.toggleLike(post.id);
                    },
                  ),
                  _ActionPill(
                    icon: CupertinoIcons.chat_bubble,
                    label: '${post.commentsCount}',
                    color: _secondary,
                    onTap: () {
                      provider.incrementViews(post.id);
                      context.push('/feed/post/${post.id}?focus=comment');
                    },
                  ),
                  _ActionPill(
                    icon: CupertinoIcons.eye,
                    label: '${post.views}',
                    color: _secondary,
                    // Tapping the eye opens Post Insights when the viewer is
                    // the post's author. For everyone else it's a no-op so
                    // we don't expose someone else's analytics.
                    onTap: post.authorId == provider.viewerId
                        ? () => _openInsights(context, provider, post)
                        : null,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      provider.toggleSave(post.id);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        post.isSaved
                            ? CupertinoIcons.bookmark_fill
                            : CupertinoIcons.bookmark,
                        size: 18,
                        color: post.isSaved ? _tealMain : _secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openProfile(BuildContext context) {
    if (post.authorKind == AuthorKind.business) {
      context.push('/business/profile');
    } else {
      // Candidate profile route — fall back to candidate profile view
      context.push('/candidate/profile');
    }
  }

  /// Opens the Post Insights bottom sheet for the current post.
  ///
  /// Premium status is read from whichever side the viewer is on:
  ///   • Candidate viewer → `CandidateAuthProvider.profile.isPremium`
  ///   • Business viewer  → assumed business has its own check (we default
  ///     to false here; business community surfaces pass premium explicitly).
  void _openInsights(
    BuildContext context,
    CommunityProvider provider,
    CommunityPost post,
  ) {
    HapticFeedback.lightImpact();
    final insights = provider.insightsFor(post.id);
    final candidateAuth = context.read<CandidateAuthProvider>();
    final isPremium = candidateAuth.profile?.isPremium ?? false;
    PostInsightsSheet.show(
      context,
      insights: insights,
      post: post,
      isPremium: isPremium,
    );
  }

  void _showPostMenu(BuildContext context, CommunityPost post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PostActionSheet(post: post),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MEDIA BLOCK — image / multi-image / video
// ═══════════════════════════════════════════════════════════════

class _MediaBlock extends StatelessWidget {
  final CommunityPost post;
  const _MediaBlock({required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: post.images.length == 1
            ? AspectRatio(
                aspectRatio: 16 / 10,
                child: _imageWidget(post.images.first),
              )
            : SizedBox(
                height: 180,
                child: Row(
                  children: post.images.take(3).toList().asMap().entries.map((
                    e,
                  ) {
                    final isFirst = e.key == 0;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: isFirst ? 0 : 4),
                        child: _imageWidget(e.value),
                      ),
                    );
                  }).toList(),
                ),
              ),
      ),
    );
  }

  Widget _imageWidget(String src) {
    final provider = src.startsWith('http')
        ? NetworkImage(src) as ImageProvider
        : AssetImage(src);
    return Image(
      image: provider,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        color: const Color(0xFFEFEFF4),
        child: const Center(
          child: Icon(CupertinoIcons.photo, color: _tertiary, size: 28),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ACTION PILL (like / comment / view counter)
// ═══════════════════════════════════════════════════════════════

class _ActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _ActionPill({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// POST ACTION SHEET (three-dot menu)
// ═══════════════════════════════════════════════════════════════

class _PostActionSheet extends StatelessWidget {
  final CommunityPost post;
  const _PostActionSheet({required this.post});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CommunityProvider>();
    final isOwn = post.authorId == provider.viewerId;

    return Container(
      decoration: const BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5EA),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            _SheetItem(
              icon: CupertinoIcons.person_circle,
              label: 'View profile',
              onTap: () {
                Navigator.pop(context);
                if (post.authorKind == AuthorKind.business) {
                  context.push('/business/profile');
                } else {
                  context.push('/candidate/profile');
                }
              },
            ),
            _SheetItem(
              icon: CupertinoIcons.link,
              label: 'Copy link',
              onTap: () {
                Clipboard.setData(
                  ClipboardData(text: 'https://plagit.app/post/${post.id}'),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Link copied'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            _SheetItem(
              icon: post.isSaved
                  ? CupertinoIcons.bookmark_fill
                  : CupertinoIcons.bookmark,
              label: post.isSaved ? 'Unsave post' : 'Save post',
              onTap: () {
                provider.toggleSave(post.id);
                Navigator.pop(context);
              },
            ),
            if (!isOwn) ...[
              _SheetItem(
                icon: CupertinoIcons.eye_slash,
                label: 'Hide this post',
                onTap: () {
                  provider.hide(post.id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Post hidden'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              _SheetItem(
                icon: CupertinoIcons.flag,
                label: 'Report post',
                color: _urgent,
                onTap: () {
                  provider.report(post.id);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Post reported — admin will review'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _charcoal,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _SheetItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = _charcoal,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 19, color: color),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: color,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
