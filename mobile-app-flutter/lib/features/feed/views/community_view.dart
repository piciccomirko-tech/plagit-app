import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/widgets/profile_avatar.dart';

/// Social feed for the hospitality community.
/// Mirrors CandidateCommunityView.swift.
class CommunityView extends StatefulWidget {
  const CommunityView({super.key});

  @override
  State<CommunityView> createState() => _CommunityViewState();
}

class _MockPost {
  final String id;
  final String authorName;
  final String authorInitials;
  final double authorHue;
  final bool authorVerified;
  final String? authorSubtitle;
  final String? authorLocation;
  final String? authorType;
  final String body;
  final String? tag;
  final String? roleCategory;
  final String? location;
  final int likeCount;
  final int commentCount;
  final int viewCount;
  final String timeAgo;

  const _MockPost({
    required this.id,
    required this.authorName,
    required this.authorInitials,
    this.authorHue = 0.5,
    this.authorVerified = false,
    this.authorSubtitle,
    this.authorLocation,
    this.authorType,
    required this.body,
    this.tag,
    this.roleCategory,
    this.location,
    this.likeCount = 0,
    this.commentCount = 0,
    this.viewCount = 0,
    required this.timeAgo,
  });
}

class _CommunityViewState extends State<CommunityView> {
  bool _isLoading = true;
  String _selectedTab = 'For You';
  String _selectedRole = 'All';
  int _unreadCount = 3;
  final Set<String> _likedPosts = {};
  final Set<String> _savedPosts = {};

  static const _tabs = ['For You', 'Following', 'Nearby', 'Saved'];
  static const _roles = ['All', 'Chef', 'Waiter', 'Bartender', 'Manager', 'Reception', 'Kitchen Porter'];

  final List<_MockPost> _posts = const [
    _MockPost(
      id: '1', authorName: 'Marco Rossi', authorInitials: 'MR', authorHue: 0.55,
      authorVerified: true, authorSubtitle: 'Head Chef', authorLocation: 'Milan, Italy',
      body: 'Just finished a 14-hour shift preparing for the gala dinner. The team pulled off an incredible tasting menu with 8 courses. Hospitality is tough but moments like these make it worthwhile!',
      tag: 'open_to_work', roleCategory: 'Chef', location: 'Milan', likeCount: 42, commentCount: 8, viewCount: 156, timeAgo: '15m',
    ),
    _MockPost(
      id: '2', authorName: 'Sophie Laurent', authorInitials: 'SL', authorHue: 0.3,
      authorSubtitle: 'Bartender', authorLocation: 'Paris, France',
      body: 'Looking for a new challenge in London! 5 years experience in cocktail bars and fine dining. Open to relocation. DM me!',
      tag: 'available_immediately', roleCategory: 'Bartender', location: 'Paris', likeCount: 28, commentCount: 5, viewCount: 89, timeAgo: '1h',
    ),
    _MockPost(
      id: '3', authorName: 'The Grand Hotel', authorInitials: 'GH', authorHue: 0.7,
      authorVerified: true, authorType: 'business', authorSubtitle: '5-star luxury hotel',
      authorLocation: 'London, UK',
      body: 'We are hiring! Multiple positions available including Head Chef, Sous Chef, and Restaurant Manager. Competitive salary and excellent benefits package.',
      tag: 'hiring', roleCategory: 'Manager', location: 'London', likeCount: 65, commentCount: 12, viewCount: 342, timeAgo: '3h',
    ),
    _MockPost(
      id: '4', authorName: 'Carlos Mendez', authorInitials: 'CM', authorHue: 0.15,
      authorSubtitle: 'Waiter / Sommelier', authorLocation: 'Barcelona, Spain',
      body: 'Wine pairing tip: Don\'t be afraid to pair a light red with fish! A chilled Beaujolais works beautifully with grilled salmon.',
      roleCategory: 'Waiter', location: 'Barcelona', likeCount: 18, commentCount: 3, viewCount: 67, timeAgo: '5h',
    ),
    _MockPost(
      id: '5', authorName: 'Anna Schmidt', authorInitials: 'AS', authorHue: 0.85,
      authorSubtitle: 'Reception Manager', authorLocation: 'Berlin, Germany',
      body: 'First day at my new hotel! Excited to join the team at Adlon Kempinski. Thanks to Plagit for connecting us!',
      tag: 'available_full_time', roleCategory: 'Reception', location: 'Berlin', likeCount: 91, commentCount: 15, viewCount: 445, timeAgo: '1d',
    ),
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  Color _tagColor(String? tag) {
    switch (tag) {
      case 'open_to_work':
      case 'available_immediately':
        return AppColors.online;
      case 'available_for_shifts':
      case 'open_to_relocation':
        return AppColors.indigo;
      case 'available_full_time':
        return AppColors.teal;
      case 'available_part_time':
        return AppColors.amber;
      case 'hiring':
      case 'open_positions':
        return AppColors.teal;
      case 'looking_for_staff':
        return AppColors.amber;
      case 'urgent_hiring':
        return AppColors.urgent;
      default:
        return AppColors.secondary;
    }
  }

  String _tagLabel(String? tag) {
    switch (tag) {
      case 'open_to_work':
        return 'Open to Work';
      case 'available_immediately':
        return 'Available Immediately';
      case 'available_for_shifts':
        return 'Available for Shifts';
      case 'open_to_relocation':
        return 'Open to Relocation';
      case 'available_full_time':
        return 'Full Time';
      case 'available_part_time':
        return 'Part Time';
      case 'hiring':
        return 'Hiring';
      case 'open_positions':
        return 'Open Positions';
      case 'looking_for_staff':
        return 'Looking for Staff';
      case 'urgent_hiring':
        return 'Urgent Hiring';
      default:
        return tag ?? '';
    }
  }

  IconData _roleIcon(String? role) {
    switch (role?.toLowerCase()) {
      case 'chef':
        return Icons.local_fire_department;
      case 'waiter':
        return Icons.person;
      case 'bartender':
        return Icons.wine_bar;
      case 'manager':
        return Icons.star;
      case 'reception':
        return Icons.notifications;
      case 'kitchen porter':
      case 'kitchen_porter':
        return Icons.restaurant;
      default:
        return Icons.person;
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '$count';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _topBar(),
                _tabRow(),
                if (_selectedTab != 'Saved') _roleChips(),
                if (_selectedTab == 'Saved')
                  const Expanded(
                    child: Center(
                      child: Text('Saved posts view', style: TextStyle(color: AppColors.secondary)),
                    ),
                  )
                else if (_isLoading)
                  const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.teal)))
                else if (_posts.isEmpty)
                  Expanded(child: _emptyState())
                else
                  Expanded(
                    child: RefreshIndicator(
                      color: AppColors.teal,
                      onRefresh: () async {
                        await Future.delayed(const Duration(milliseconds: 500));
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xxxl),
                        itemCount: _posts.length,
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                          child: _postCard(_posts[i]),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Top bar ──
  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.sm),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const SizedBox(width: 36, height: 36, child: Icon(Icons.chevron_left, size: 22, color: AppColors.charcoal)),
          ),
          const Spacer(),
          const Text('Community', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
          const Spacer(),
          // Bell icon with badge
          GestureDetector(
            onTap: () {
              // Navigate to FeedActivityView
            },
            child: SizedBox(
              width: 36,
              height: 36,
              child: Stack(
                children: [
                  Icon(
                    _unreadCount > 0 ? Icons.notifications_active : Icons.notifications,
                    size: 22,
                    color: _unreadCount > 0 ? AppColors.teal : AppColors.charcoal,
                  ),
                  if (_unreadCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        decoration: const BoxDecoration(color: AppColors.urgent, shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: Text(
                          '${_unreadCount > 99 ? 99 : _unreadCount}',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: () {
              // Create post
            },
            child: const Icon(Icons.add_circle, size: 26, color: AppColors.teal),
          ),
        ],
      ),
    );
  }

  // ── Tab row ──
  Widget _tabRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xs, AppSpacing.xl, 0),
      child: Row(
        children: _tabs.map((tab) {
          final isActive = _selectedTab == tab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = tab),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (tab == 'Saved')
                        Icon(Icons.bookmark, size: 12, color: isActive ? AppColors.charcoal : AppColors.tertiary),
                      if (tab == 'Saved') const SizedBox(width: 3),
                      Text(
                        tab,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isActive ? AppColors.charcoal : AppColors.tertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(height: 2, color: isActive ? AppColors.teal : Colors.transparent),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Role chips ──
  Widget _roleChips() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
          itemCount: _roles.length,
          itemBuilder: (_, i) {
            final role = _roles[i];
            final isActive = _selectedRole == role;
            return GestureDetector(
              onTap: () => setState(() => _selectedRole = role),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.teal : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: isActive ? null : Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Text(
                  role,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isActive ? Colors.white : AppColors.secondary),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Post card ──
  Widget _postCard(_MockPost post) {
    final liked = _likedPosts.contains(post.id);
    final saved = _savedPosts.contains(post.id);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileAvatar(initials: post.authorInitials, hue: post.authorHue, size: 44, verified: post.authorVerified),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(child: Text(post.authorName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal))),
                        if (post.authorType == 'business') ...[
                          const SizedBox(width: AppSpacing.xs),
                          const Icon(Icons.apartment, size: 11, color: AppColors.teal),
                        ],
                      ],
                    ),
                    Row(
                      children: [
                        if (post.authorSubtitle != null)
                          Text(post.authorSubtitle!, style: const TextStyle(fontSize: 11, color: AppColors.secondary)),
                        if (post.authorLocation != null) ...[
                          const Text(' \u{00B7} ', style: TextStyle(fontSize: 11, color: AppColors.tertiary)),
                          Flexible(child: Text(post.authorLocation!, style: const TextStyle(fontSize: 11, color: AppColors.tertiary), overflow: TextOverflow.ellipsis)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(post.timeAgo, style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
                      const SizedBox(width: AppSpacing.sm),
                      const Icon(Icons.more_horiz, size: 16, color: AppColors.tertiary),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(AppRadius.full)),
                    child: const Text('Follow', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.teal)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Tag badge
          if (post.tag != null && post.tag!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: _tagColor(post.tag).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(_tagLabel(post.tag), style: TextStyle(fontSize: 11, color: _tagColor(post.tag))),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],

          // Body text
          Text(post.body, style: const TextStyle(fontSize: 15, color: AppColors.charcoal, height: 1.4), maxLines: 8, overflow: TextOverflow.ellipsis),
          const SizedBox(height: AppSpacing.md),

          // Role + location pills
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              if (post.roleCategory != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(color: AppColors.tealLight, borderRadius: BorderRadius.circular(AppRadius.full)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_roleIcon(post.roleCategory), size: 11, color: AppColors.teal),
                      const SizedBox(width: AppSpacing.xs),
                      Text(post.roleCategory!, style: const TextStyle(fontSize: 11, color: AppColors.teal)),
                    ],
                  ),
                ),
              if (post.location != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, size: 11, color: AppColors.secondary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(post.location!, style: const TextStyle(fontSize: 11, color: AppColors.secondary)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Action bar
          Row(
            children: [
              _actionBtn(
                icon: liked ? Icons.favorite : Icons.favorite_border,
                label: post.likeCount > 0 ? '${post.likeCount}' : 'Like',
                color: liked ? AppColors.urgent : AppColors.tertiary,
                onTap: () {
                  setState(() {
                    if (liked) {
                      _likedPosts.remove(post.id);
                    } else {
                      _likedPosts.add(post.id);
                    }
                  });
                },
              ),
              const SizedBox(width: AppSpacing.xl),
              _actionBtn(icon: Icons.chat_bubble_outline, label: post.commentCount > 0 ? '${post.commentCount}' : 'Comment', color: AppColors.tertiary, onTap: () {}),
              const SizedBox(width: AppSpacing.xl),
              _actionBtn(icon: Icons.ios_share, label: 'Share', color: AppColors.tertiary, onTap: () {}),
              const SizedBox(width: AppSpacing.xl),
              _actionBtn(
                icon: saved ? Icons.bookmark : Icons.bookmark_border,
                label: 'Save',
                color: saved ? AppColors.teal : AppColors.tertiary,
                onTap: () {
                  setState(() {
                    if (saved) {
                      _savedPosts.remove(post.id);
                    } else {
                      _savedPosts.add(post.id);
                    }
                  });
                },
              ),
              const Spacer(),
              if (post.viewCount > 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.visibility_outlined, size: 14, color: AppColors.tertiary),
                    const SizedBox(width: 5),
                    Text(_formatCount(post.viewCount), style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
                  ],
                ),
            ],
          ),

          // View comments link
          if (post.commentCount > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.chat_bubble, size: 12, color: AppColors.teal),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  post.commentCount == 1 ? 'View 1 comment' : 'View all ${post.commentCount} comments',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.teal),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionBtn({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }

  // ── Empty state ──
  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: AppColors.tealLight, shape: BoxShape.circle),
              child: const Icon(Icons.forum, size: 24, color: AppColors.teal),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              _selectedTab == 'Nearby' ? 'No posts nearby' : _selectedTab == 'Following' ? 'No posts from people you follow' : 'No posts yet',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _selectedTab == 'Following' ? 'Follow people to see their posts here.' : 'Be the first to share with the community!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.secondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.md),
                decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(AppRadius.full)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 14, color: Colors.white),
                    SizedBox(width: AppSpacing.sm),
                    Text('Create Post', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
