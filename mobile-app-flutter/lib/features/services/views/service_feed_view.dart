import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';

/// Social feed + discovery for hospitality service businesses.
/// Tabs: Feed (posts), Nearby (list), Browse (categories).
/// Mirrors ServiceFeedView.swift.
class ServiceFeedView extends StatefulWidget {
  const ServiceFeedView({super.key});

  @override
  State<ServiceFeedView> createState() => _ServiceFeedViewState();
}

class _MockServicePost {
  final String id;
  final String companyName;
  final String companyInitials;
  final double companyHue;
  final bool companyVerified;
  final String subcategoryName;
  final String categoryName;
  final String companyLocation;
  final String body;
  final int likeCount;
  final int commentCount;
  final String timeAgo;

  const _MockServicePost({
    required this.id,
    required this.companyName,
    required this.companyInitials,
    this.companyHue = 0.5,
    this.companyVerified = false,
    required this.subcategoryName,
    required this.categoryName,
    required this.companyLocation,
    required this.body,
    this.likeCount = 0,
    this.commentCount = 0,
    required this.timeAgo,
  });
}

class _MockServiceCompany {
  final String id;
  final String name;
  final String initials;
  final double avatarHue;
  final String subcategoryName;
  final String location;
  final bool isVerified;
  final double? rating;
  final int reviewCount;

  const _MockServiceCompany({
    required this.id,
    required this.name,
    required this.initials,
    this.avatarHue = 0.5,
    required this.subcategoryName,
    required this.location,
    this.isVerified = false,
    this.rating,
    this.reviewCount = 0,
  });
}

class _ServiceFeedViewState extends State<ServiceFeedView> {
  int _selectedTab = 0;
  String _searchText = '';
  String? _selectedCategoryId;
  bool _verifiedOnly = false;

  static const _categories = [
    ('catering', 'Catering', Icons.restaurant),
    ('cleaning', 'Cleaning', Icons.cleaning_services),
    ('consulting', 'Consulting', Icons.business_center),
    ('staffing', 'Staffing', Icons.people),
    ('events', 'Events', Icons.event),
  ];

  final List<_MockServicePost> _posts = const [
    _MockServicePost(
      id: '1', companyName: 'Elite Catering Co.', companyInitials: 'EC', companyHue: 0.1, companyVerified: true,
      subcategoryName: 'Event Catering', categoryName: 'Catering', companyLocation: 'London, UK',
      body: 'Just finished catering for a 500-guest corporate gala at The Shard. Our team delivered an exceptional multi-course dining experience!',
      likeCount: 34, commentCount: 7, timeAgo: '25m',
    ),
    _MockServicePost(
      id: '2', companyName: 'SparkleClean', companyInitials: 'SC', companyHue: 0.35,
      subcategoryName: 'Hotel Cleaning', categoryName: 'Cleaning', companyLocation: 'Manchester, UK',
      body: 'New eco-friendly cleaning protocol now available for all hotel partners. 40% reduction in chemical usage with better results!',
      likeCount: 18, commentCount: 3, timeAgo: '2h',
    ),
    _MockServicePost(
      id: '3', companyName: 'Hospitality Pros', companyInitials: 'HP', companyHue: 0.55, companyVerified: true,
      subcategoryName: 'Business Consulting', categoryName: 'Consulting', companyLocation: 'Milan, Italy',
      body: 'Our latest case study: How we helped a boutique hotel increase revenue by 35% in 6 months through operational optimization.',
      likeCount: 52, commentCount: 11, timeAgo: '4h',
    ),
  ];

  final List<_MockServiceCompany> _companies = const [
    _MockServiceCompany(id: '1', name: 'Elite Catering Co.', initials: 'EC', avatarHue: 0.1, subcategoryName: 'Event Catering', location: 'London, UK', isVerified: true, rating: 4.8, reviewCount: 124),
    _MockServiceCompany(id: '2', name: 'SparkleClean Services', initials: 'SC', avatarHue: 0.35, subcategoryName: 'Hotel Cleaning', location: 'Manchester, UK', rating: 4.5, reviewCount: 87),
    _MockServiceCompany(id: '3', name: 'Hospitality Pros', initials: 'HP', avatarHue: 0.55, subcategoryName: 'Business Consulting', location: 'Milan, Italy', isVerified: true, rating: 4.9, reviewCount: 56),
    _MockServiceCompany(id: '4', name: 'QuickStaff Agency', initials: 'QS', avatarHue: 0.7, subcategoryName: 'Temporary Staffing', location: 'Paris, France', rating: 4.3, reviewCount: 203),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            _searchBarWidget(),
            Padding(padding: const EdgeInsets.only(top: AppSpacing.xs), child: _tabBar()),
            Padding(padding: const EdgeInsets.only(top: AppSpacing.xs), child: _categoryChips()),
            if (_selectedTab == 1)
              Padding(padding: const EdgeInsets.only(top: AppSpacing.xs), child: _radiusRow()),
            Expanded(child: _content()),
          ],
        ),
      ),
    );
  }

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
          const Text('Services', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: SizedBox(
              width: 36, height: 36,
              child: Stack(
                children: [
                  const Center(child: Icon(Icons.tune, size: 22, color: AppColors.charcoal)),
                  if (_verifiedOnly)
                    Positioned(right: 3, top: 3, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.amber, shape: BoxShape.circle))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBarWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md)),
        child: Row(
          children: [
            const Icon(Icons.search, size: 18, color: AppColors.tertiary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: TextField(
                onChanged: (v) => setState(() => _searchText = v),
                style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
                decoration: const InputDecoration.collapsed(hintText: 'Search services, companies, locations...', hintStyle: TextStyle(color: AppColors.tertiary, fontSize: 15)),
              ),
            ),
            if (_searchText.isNotEmpty)
              GestureDetector(onTap: () => setState(() => _searchText = ''), child: const Icon(Icons.cancel, size: 16, color: AppColors.tertiary)),
          ],
        ),
      ),
    );
  }

  Widget _tabBar() {
    const tabs = [('Feed', Icons.view_agenda), ('Nearby', Icons.map), ('Browse', Icons.grid_view)];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md)),
        child: Row(
          children: tabs.asMap().entries.map((e) {
            final i = e.key;
            final t = e.value;
            final isActive = _selectedTab == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.amber : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.sm + 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(t.$2, size: 14, color: isActive ? Colors.white : AppColors.secondary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(t.$1, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isActive ? Colors.white : AppColors.secondary)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _categoryChips() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        children: [
          _chip('All', null, _selectedCategoryId == null, () => setState(() => _selectedCategoryId = null)),
          const SizedBox(width: AppSpacing.sm),
          ..._categories.map((cat) => Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: _chip(cat.$2, cat.$3, _selectedCategoryId == cat.$1, () {
              setState(() => _selectedCategoryId = _selectedCategoryId == cat.$1 ? null : cat.$1);
            }),
          )),
        ],
      ),
    );
  }

  Widget _chip(String label, IconData? icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isActive ? AppColors.amber : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: isActive ? null : Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 13, color: isActive ? Colors.white : AppColors.secondary), const SizedBox(width: AppSpacing.xs)],
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isActive ? Colors.white : AppColors.secondary)),
          ],
        ),
      ),
    );
  }

  Widget _radiusRow() {
    const radii = [3, 5, 10, 15, 20];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: SizedBox(
        height: 34,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: radii.map((r) {
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md + 2, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: r == 10 ? AppColors.teal : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: r == 10 ? null : Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Text('$r km', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: r == 10 ? Colors.white : AppColors.secondary)),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _content() {
    switch (_selectedTab) {
      case 0:
        return _feedContent();
      case 1:
        return _nearbyContent();
      default:
        return _browseContent();
    }
  }

  Widget _feedContent() {
    if (_posts.isEmpty) return _emptyState('No posts found', 'Try a different search or category.');
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xxxl),
      itemCount: _posts.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: _feedPostCard(_posts[i]),
      ),
    );
  }

  Widget _nearbyContent() {
    if (_companies.isEmpty) return _emptyState('No companies nearby', 'Try a wider radius or different category.');
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xxxl),
      itemCount: _companies.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: _companyRow(_companies[i]),
      ),
    );
  }

  Widget _browseContent() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xxxl),
      itemCount: _companies.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: _companyRow(_companies[i]),
      ),
    );
  }

  Widget _feedPostCard(_MockServicePost post) {
    final hsl = HSLColor.fromAHSL(1, post.companyHue * 360, 0.15, 0.95);
    final hslText = HSLColor.fromAHSL(1, post.companyHue * 360, 0.6, 0.5);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: hsl.toColor(), borderRadius: BorderRadius.circular(AppRadius.sm)),
                  alignment: Alignment.center,
                  child: Text(post.companyInitials, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: hslText.toColor())),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Flexible(child: Text(post.companyName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal), overflow: TextOverflow.ellipsis)),
                        if (post.companyVerified) ...[const SizedBox(width: AppSpacing.sm), const Icon(Icons.verified, size: 13, color: AppColors.teal)],
                      ]),
                      Text(post.subcategoryName, style: const TextStyle(fontSize: 11, color: AppColors.teal)),
                    ],
                  ),
                ),
                Text(post.timeAgo, style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
              ],
            ),
          ),

          // Body
          if (post.body.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
              child: Text(post.body, style: const TextStyle(fontSize: 15, color: AppColors.charcoal, height: 1.4)),
            ),

          // Placeholder image
          Container(
            height: 200,
            width: double.infinity,
            color: hsl.toColor(),
            child: Icon(Icons.apartment, size: 32, color: hslText.toColor().withValues(alpha: 0.4)),
          ),

          // Action bar
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
            child: Row(
              children: [
                _actionButton(Icons.favorite_border, '${post.likeCount}'),
                const SizedBox(width: AppSpacing.xxl),
                _actionButton(Icons.chat_bubble_outline, '${post.commentCount}'),
                const SizedBox(width: AppSpacing.xxl),
                _actionButton(Icons.bookmark_border, ''),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(color: AppColors.amber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppRadius.full)),
                  child: const Text('View Profile', style: TextStyle(fontSize: 11, color: AppColors.amber)),
                ),
              ],
            ),
          ),

          // Location
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 11, color: AppColors.teal),
                const SizedBox(width: AppSpacing.xs),
                Text(post.companyLocation, style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
                const Spacer(),
                Text(post.categoryName, style: const TextStyle(fontSize: 11, color: AppColors.amber)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.secondary),
        if (count.isNotEmpty && count != '0') ...[
          const SizedBox(width: 4),
          Text(count, style: const TextStyle(fontSize: 11, color: AppColors.secondary)),
        ],
      ],
    );
  }

  Widget _companyRow(_MockServiceCompany co) {
    final hsl = HSLColor.fromAHSL(1, co.avatarHue * 360, 0.15, 0.95);
    final hslText = HSLColor.fromAHSL(1, co.avatarHue * 360, 0.6, 0.5);

    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: hsl.toColor(), borderRadius: BorderRadius.circular(AppRadius.md)),
              alignment: Alignment.center,
              child: Text(co.initials, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: hslText.toColor())),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Flexible(child: Text(co.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal), overflow: TextOverflow.ellipsis)),
                    if (co.isVerified) ...[const SizedBox(width: AppSpacing.sm), const Icon(Icons.verified, size: 13, color: AppColors.teal)],
                  ]),
                  Text(co.subcategoryName, style: const TextStyle(fontSize: 13, color: AppColors.teal), overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Row(children: [
                    const Icon(Icons.location_on, size: 11, color: AppColors.amber),
                    const SizedBox(width: AppSpacing.xs),
                    Text(co.location, style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
                  ]),
                ],
              ),
            ),
            if (co.rating != null)
              Column(
                children: [
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.star, size: 12, color: AppColors.amber),
                    const SizedBox(width: 2),
                    Text(co.rating!.toStringAsFixed(1), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
                  ]),
                  Text('${co.reviewCount}', style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: AppColors.amber.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.apartment, size: 24, color: AppColors.amber),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
            const SizedBox(height: AppSpacing.xs),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
          ],
        ),
      ),
    );
  }
}
