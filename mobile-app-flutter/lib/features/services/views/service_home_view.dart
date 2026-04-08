import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';

const _orange = Color(0xFFF97316);

class ServiceHomeView extends StatelessWidget {
  const ServiceHomeView({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Color _colorForCategory(String category) {
    switch (category) {
      case 'Food & Beverage Suppliers':
        return _orange;
      case 'Event Services':
        return AppColors.purple;
      case 'Decor & Design':
        return const Color(0xFFEC4899);
      case 'Entertainment':
        return AppColors.amber;
      case 'Equipment & Operations':
        return const Color(0xFF3B82F6);
      case 'Cleaning & Maintenance':
        return AppColors.teal;
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final featured = MockData.featuredCompanies;
    final nearby = MockData.londonCompanies;
    final feedPosts = MockData.serviceFeedPosts;
    final promotions = MockData.servicePromotions;
    final savedIds = MockData.serviceSavedCompanyIds;
    final savedCompanies = MockData.serviceCompanies
        .where((c) => savedIds.contains(c['id']))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            // ── HEADER ──
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting(),
                    style: const TextStyle(fontSize: 13, color: AppColors.secondary),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Find Hospitality Services',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Search bar
                  GestureDetector(
                    onTap: () => context.push('/services/search'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.search, color: AppColors.secondary, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Search companies, services...',
                              style: TextStyle(fontSize: 14, color: AppColors.tertiary),
                            ),
                          ),
                          Icon(Icons.tune, color: AppColors.secondary, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── CATEGORIES ROW ──
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _CategoryChip(label: 'All', selected: true),
                    ...MockData.serviceCategories.map((c) =>
                        _CategoryChip(label: c['name'] as String, selected: false)),
                  ],
                ),
              ),
            ),

            // ── FEATURED COMPANIES ──
            _sectionHeader(context, 'Featured', 'See All', () => context.push('/services/discover')),
            const SizedBox(height: 14),
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: featured.length,
                separatorBuilder: (_, i) => const SizedBox(width: 14),
                itemBuilder: (context, i) {
                  final c = featured[i];
                  final catColor = _colorForCategory(c['category'] as String);
                  return _FeaturedCard(company: c, catColor: catColor);
                },
              ),
            ),

            // ── NEARBY ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                children: [
                  const Text('Near You',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.push('/services/nearby'),
                    child: const Text('See All',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.teal)),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('\u{1F4CD} London, UK',
                  style: TextStyle(fontSize: 11, color: AppColors.secondary)),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: nearby.length,
                separatorBuilder: (_, i) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final c = nearby[i];
                  return _NearbyCard(company: c);
                },
              ),
            ),

            // ── FEED PREVIEW ──
            _sectionHeader(context, 'Latest Updates', 'See Feed', () => context.push('/services/feed')),
            const SizedBox(height: 14),
            ...feedPosts.take(2).map((post) => _FeedPostCard(post: post)),

            // ── PROMOTIONS ──
            _sectionHeader(context, 'Active Promotions', 'See All', () => context.push('/services/promotions')),
            const SizedBox(height: 14),
            ...promotions.take(2).map((promo) => _PromoCard(promo: promo)),

            // ── SAVED PREVIEW ──
            _sectionHeader(context, 'Your Saved Companies', 'View All', () => context.push('/services/saved')),
            const SizedBox(height: 14),
            ...savedCompanies.take(3).map((c) => _SavedRow(company: c, onTap: () {
              context.push('/services/companies/${c['id']}');
            })),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title, String action, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Row(
        children: [
          Text(title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
          const Spacer(),
          GestureDetector(
            onTap: onTap,
            child: Text(action,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.teal)),
          ),
        ],
      ),
    );
  }
}

// ── Category Chip ──
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _CategoryChip({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.teal : Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: selected ? null : Border.all(color: AppColors.divider),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: selected ? Colors.white : AppColors.secondary,
        ),
      ),
    );
  }
}

// ── Featured Card ──
class _FeaturedCard extends StatelessWidget {
  final Map<String, dynamic> company;
  final Color catColor;

  const _FeaturedCard({required this.company, required this.catColor});

  @override
  Widget build(BuildContext context) {
    final name = company['name'] as String;
    final initials = company['initials'] as String;
    final category = company['category'] as String;
    final verified = company['verified'] == true;
    final featured = company['featured'] == true;

    return SizedBox(
      width: 220,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppColors.cardShadow],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient header
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [catColor.withValues(alpha: 0.7), catColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Logo circle overlapping
                      Transform.translate(
                        offset: const Offset(0, -28),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: catColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (verified)
                        Transform.translate(
                          offset: const Offset(0, -28),
                          child: const Icon(Icons.verified, color: AppColors.teal, size: 16),
                        ),
                      if (featured)
                        Transform.translate(
                          offset: const Offset(0, -28),
                          child: const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(Icons.star, color: AppColors.gold, size: 16),
                          ),
                        ),
                    ],
                  ),
                  Transform.translate(
                    offset: const Offset(0, -18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.charcoal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _orange),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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

// ── Nearby Card ──
class _NearbyCard extends StatelessWidget {
  final Map<String, dynamic> company;

  const _NearbyCard({required this.company});

  @override
  Widget build(BuildContext context) {
    final name = company['name'] as String;
    final initials = company['initials'] as String;
    final category = company['category'] as String;
    final distance = company['distance'] as String? ?? '';

    return SizedBox(
      width: 180,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.teal,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.charcoal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    category,
                    style: const TextStyle(fontSize: 11, color: AppColors.secondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    distance,
                    style: const TextStyle(fontSize: 10, color: AppColors.teal),
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

// ── Feed Post Card ──
class _FeedPostCard extends StatelessWidget {
  final Map<String, dynamic> post;

  const _FeedPostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final company = post['company'] as String;
    final initials = post['companyInitials'] as String;
    final time = post['time'] as String;
    final text = post['text'] as String;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.teal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(company,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
                    Text(time,
                        style: const TextStyle(fontSize: 11, color: AppColors.secondary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              text,
              style: const TextStyle(fontSize: 13, color: AppColors.secondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {},
                child: const Text(
                  'View Post',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.teal),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Promo Card ──
class _PromoCard extends StatelessWidget {
  final Map<String, dynamic> promo;

  const _PromoCard({required this.promo});

  @override
  Widget build(BuildContext context) {
    final company = promo['company'] as String;
    final title = promo['title'] as String;
    final validUntil = promo['validUntil'] as String;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: const Border(left: BorderSide(color: _orange, width: 3)),
          boxShadow: [AppColors.cardShadow],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(company,
                style: const TextStyle(fontSize: 12, color: AppColors.secondary)),
            const SizedBox(height: 4),
            Text(title,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
            const SizedBox(height: 6),
            Row(
              children: [
                Text('Valid until $validUntil',
                    style: const TextStyle(fontSize: 11, color: _orange)),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: _orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'View Offer',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _orange,
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
}

// ── Saved Row ──
class _SavedRow extends StatelessWidget {
  final Map<String, dynamic> company;
  final VoidCallback onTap;

  const _SavedRow({required this.company, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = company['name'] as String;
    final initials = company['initials'] as String;
    final category = company['category'] as String;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [AppColors.cardShadow],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.teal,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
                    Text(category,
                        style: const TextStyle(fontSize: 11, color: AppColors.secondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.secondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
