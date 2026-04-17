import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/city_helpers.dart';
import 'package:plagit/core/l10n_helpers.dart';
import 'package:plagit/core/widgets/search_screen.dart';
import 'package:plagit/models/community_post.dart';
import 'package:plagit/providers/community_provider.dart';
import 'package:plagit/providers/recent_searches_provider.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

const _tealMain = Color(0xFF00B5B0);
const _tealLight = Color(0x1A00B5B0);
const _bgMain = Color(0xFFF6F7F8);
const _cardBg = Color(0xFFFFFFFF);
const _surface = Color(0xFFF9FAFB);
const _charcoal = Color(0xFF1A1C24);
const _secondary = Color(0xFF707580);
const _tertiary = Color(0xFF9EA3AD);
const _urgent = Color(0xFFFF3B30);

/// Business Community feed.
///
/// Reads the same `CommunityProvider` state as the candidate side, but
/// configures the viewer as a business so any post created from this
/// screen is attributed to the business identity. Has its own "My Posts"
/// tab so the business can see what they've shared.
class BusinessCommunityView extends StatefulWidget {
  const BusinessCommunityView({super.key});

  @override
  State<BusinessCommunityView> createState() => _BusinessCommunityViewState();
}

class _BusinessCommunityViewState extends State<BusinessCommunityView> {
  int _tab = 0;
  static const _tabs = ['Feed', 'My Posts', 'Saved'];

  String _localizedTabLabel(String key) {
    final t = AppLocalizations.of(context);
    switch (key) {
      case 'Feed':
        return t.feedTab;
      case 'My Posts':
        return t.myPostsTab;
      case 'Saved':
        return t.savedTab;
    }
    return key;
  }

  @override
  void initState() {
    super.initState();
    // Set business identity for the provider so create-post is attributed
    // to the business and "myPosts" returns this account's posts.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CommunityProvider>().setViewer(
            id: 'u_nobu',
            name: 'Nobu Restaurant',
            initials: 'NR',
            kind: AuthorKind.business,
            role: 'Restaurant',
            location: 'Dubai',
            verified: true,
          );
    });
  }

  void _openSearchScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SearchScreen(
          scope: RecentSearchScope.businessCommunity,
          title: AppLocalizations.of(context).search,
          hintText: AppLocalizations.of(context).searchTalentPostsRolesHint,
          resultsBuilder: (ctx, query) {
            final all = ctx.watch<CommunityProvider>().visible;
            final q = query.toLowerCase();
            final results = all.where((p) =>
                p.body.toLowerCase().contains(q) ||
                p.authorName.toLowerCase().contains(q) ||
                p.authorRole.toLowerCase().contains(q)).toList();
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
                      border: Border.all(color: const Color(0xFFEFEFF4), width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.authorName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _charcoal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          p.body,
                          style: const TextStyle(fontSize: 12.5, color: _secondary, height: 1.4),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
    final List<CommunityPost> posts = switch (_tab) {
      1 => provider.myPosts,
      2 => provider.saved,
      _ => provider.forYouFeed(),
    };

    return Scaffold(
      backgroundColor: _bgMain,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.canPop() ? context.pop() : null,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const BackChevron(size: 28, color: _charcoal),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context).communityTitle,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: _charcoal,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _openSearchScreen(context),
                    child: const Icon(
                      CupertinoIcons.search,
                      size: 20,
                      color: _charcoal,
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => context.push('/feed/activity'),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Center(
                            child: Icon(CupertinoIcons.bell, size: 20, color: _charcoal),
                          ),
                          if (provider.unreadNotifications > 0)
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                                decoration: BoxDecoration(
                                  color: _urgent,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: _bgMain, width: 1.5),
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
                  GestureDetector(
                    onTap: () => context.push('/feed/post/create'),
                    child: const Icon(CupertinoIcons.square_pencil, size: 22, color: _tealMain),
                  ),
                ],
              ),
            ),

            // (Search now lives on a dedicated full-screen route.)

            // ── Business identity strip ──
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEFEFF4), width: 0.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [_tealMain, Color(0xFF6676F0)],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'NR',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              AppLocalizations.of(context).postingAs('Nobu Restaurant'),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _charcoal,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(CupertinoIcons.checkmark_seal_fill, size: 13, color: _tealMain),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${provider.myPosts.length} posts published',
                          style: const TextStyle(fontSize: 11, color: _tertiary),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/feed/post/create'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _tealMain,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(CupertinoIcons.square_pencil, size: 12, color: Colors.white),
                          const SizedBox(width: 5),
                          Text(
                            AppLocalizations.of(context).post,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Tabs ──
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _tabs.length,
                separatorBuilder: (_, _) => const SizedBox(width: 22),
                itemBuilder: (_, i) {
                  final active = _tab == i;
                  return GestureDetector(
                    onTap: () => setState(() => _tab = i),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _localizedTabLabel(_tabs[i]),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                            color: active ? _charcoal : _tertiary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: active ? 28 : 0,
                          height: 2,
                          decoration: BoxDecoration(color: _tealMain, borderRadius: BorderRadius.circular(1)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ── Posts ──
            Expanded(
              child: posts.isEmpty
                  ? _emptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
                      itemCount: posts.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (_, i) => _BusinessPostCard(post: posts[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    final isMyPosts = _tab == 1;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(color: _tealLight, shape: BoxShape.circle),
              child: Icon(
                isMyPosts ? CupertinoIcons.square_pencil : CupertinoIcons.bubble_left_bubble_right,
                size: 22,
                color: _tealMain,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isMyPosts ? AppLocalizations.of(context).noPostsYet : AppLocalizations.of(context).nothingHereYet,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _charcoal),
            ),
            const SizedBox(height: 4),
            Text(
              isMyPosts
                  ? AppLocalizations.of(context).shareVenueUpdate
                  : AppLocalizations.of(context).communityPostsAppearHere,
              style: const TextStyle(fontSize: 13, color: _secondary),
              textAlign: TextAlign.center,
            ),
            if (isMyPosts) ...[
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => context.push('/feed/post/create'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                  decoration: BoxDecoration(
                    color: _tealMain,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    AppLocalizations.of(context).createFirstPost,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
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

class _BusinessPostCard extends StatelessWidget {
  final CommunityPost post;
  const _BusinessPostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final hue = (post.authorName.hashCode % 360).abs().toDouble();
    final provider = context.watch<CommunityProvider>();
    final isOwn = post.authorId == provider.viewerId;
    final isBusiness = post.authorKind == AuthorKind.business;

    return GestureDetector(
      onTap: () => context.push('/feed/post/${post.id}'),
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isOwn ? _tealMain.withValues(alpha: 0.30) : const Color(0xFFEFEFF4),
            width: isOwn ? 1 : 0.5,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isOwn)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: _tealLight,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.checkmark_seal_fill, size: 11, color: _tealMain),
                    const SizedBox(width: 5),
                    Text(
                      AppLocalizations.of(context).yourPostUpper,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _tealMain,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          HSLColor.fromAHSL(1, hue, 0.55, 0.55).toColor(),
                          HSLColor.fromAHSL(1, (hue + 30) % 360, 0.50, 0.50).toColor(),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        post.authorInitials,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                post.authorName,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _charcoal),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (post.authorVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(CupertinoIcons.checkmark_seal_fill, size: 13, color: _tealMain),
                            ],
                            if (isBusiness && !isOwn) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: _tealLight,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  AppLocalizations.of(context).businessLabel,
                                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: _tealMain),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 1),
                        Text(
                          '${localizedJobRole(context, post.authorRole)}${post.authorLocation != null ? ' · ${localizedCity(context, post.authorLocation)}' : ''} · ${post.timeAgo}',
                          style: const TextStyle(fontSize: 12, color: _tertiary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (post.body.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  post.body,
                  style: const TextStyle(fontSize: 14.5, color: _charcoal, height: 1.4),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            // Engagement
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      provider.toggleLike(post.id);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Icon(
                            post.isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                            size: 16,
                            color: post.isLiked ? _urgent : _secondary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${post.likes}',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: post.isLiked ? _urgent : _secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/feed/post/${post.id}?focus=comment'),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.chat_bubble, size: 16, color: _secondary),
                          const SizedBox(width: 5),
                          Text(
                            '${post.commentsCount}',
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: _secondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        const Icon(CupertinoIcons.eye, size: 16, color: _secondary),
                        const SizedBox(width: 5),
                        Text(
                          '${post.views}',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: _secondary),
                        ),
                      ],
                    ),
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
                        post.isSaved ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark,
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
}
