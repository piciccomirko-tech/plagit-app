import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/city_helpers.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';

const Color _orange = Color(0xFFF97316);

class ServiceCompanyProfileView extends StatefulWidget {
  final String companyId;
  const ServiceCompanyProfileView({super.key, required this.companyId});

  @override
  State<ServiceCompanyProfileView> createState() => _ServiceCompanyProfileViewState();
}

class _ServiceCompanyProfileViewState extends State<ServiceCompanyProfileView> {
  bool _isSaved = false;

  Map<String, dynamic> get _company {
    final match = MockData.serviceCompanies.cast<Map<String, dynamic>>().where((c) => c['id'] == widget.companyId);
    if (match.isNotEmpty) return match.first;
    return MockData.serviceCompanies.first as Map<String, dynamic>;
  }

  Color _colorFromName(String name) {
    final hash = name.hashCode.abs();
    return HSLColor.fromAHSL(1, (hash % 360).toDouble(), 0.5, 0.45).toColor();
  }

  Color _bgColorFromName(String name) {
    final hash = name.hashCode.abs();
    return HSLColor.fromAHSL(1, (hash % 360).toDouble(), 0.25, 0.92).toColor();
  }

  Color _gradientFromName(String name) {
    final hash = name.hashCode.abs();
    return HSLColor.fromAHSL(1, (hash % 360).toDouble(), 0.6, 0.35).toColor();
  }

  @override
  void initState() {
    super.initState();
    _isSaved = MockData.serviceSavedCompanyIds.contains(widget.companyId);
  }

  @override
  Widget build(BuildContext context) {
    final c = _company;
    final name = c['name'] as String;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: _gradientFromName(name),
              foregroundColor: Colors.white,
              actions: [
                IconButton(icon: const Icon(Icons.share), onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).shareComingSoon)));
                }),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_gradientFromName(name), _gradientFromName(name).withValues(alpha: 0.7)],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: _profileHeader(c)),
            SliverToBoxAdapter(child: _actionRow(c)),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  labelColor: _orange,
                  unselectedLabelColor: AppColors.secondary,
                  indicatorColor: _orange,
                  indicatorWeight: 2,
                  labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: const TextStyle(fontSize: 13),
                  tabs: [
                    Tab(text: AppLocalizations.of(context).about),
                    Tab(text: AppLocalizations.of(context).postsTab),
                    Tab(text: AppLocalizations.of(context).promotionsTab),
                    Tab(text: AppLocalizations.of(context).galleryTab),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _aboutTab(c),
              _postsTab(c),
              _promotionsTab(c),
              _galleryTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileHeader(Map<String, dynamic> c) {
    final name = c['name'] as String;
    final initials = c['initials'] as String;
    final category = c['category'] as String;
    final location = c['location'] as String;
    final verified = c['verified'] == true;
    final featured = c['featured'] == true;

    return Transform.translate(
      offset: const Offset(0, -30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _bgColorFromName(name),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
              ),
              alignment: Alignment.center,
              child: Text(initials, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _colorFromName(name))),
            ),
            const SizedBox(height: 10),
            Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: _orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Text(category, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _orange)),
            ),
            const SizedBox(height: 6),
            Text('\u{1F4CD} ${localizedCity(context, location)}', style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (verified) ...[
                  const Icon(Icons.verified, size: 16, color: AppColors.teal),
                  const SizedBox(width: 4),
                  Text(AppLocalizations.of(context).verified, style: const TextStyle(fontSize: 12, color: AppColors.teal)),
                  const SizedBox(width: 12),
                ],
                if (featured) ...[
                  const Icon(Icons.star, size: 16, color: AppColors.gold),
                  const SizedBox(width: 4),
                  Text(AppLocalizations.of(context).featuredBadge, style: const TextStyle(fontSize: 12, color: AppColors.gold)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionRow(Map<String, dynamic> c) {
    final id = c['id'] as String;
    final name = c['name'] as String;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          // Heart toggle
          GestureDetector(
            onTap: () => setState(() => _isSaved = !_isSaved),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(
                _isSaved ? Icons.favorite : Icons.favorite_border,
                size: 22,
                color: _isSaved ? Colors.red : AppColors.tertiary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Message button
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/services/messages/$id'),
              child: Container(
                height: 44,
                decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: Text(AppLocalizations.of(context).message, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Request Quote button
          Expanded(
            child: GestureDetector(
              onTap: () => _showQuoteDialog(name),
              child: Container(
                height: 44,
                decoration: BoxDecoration(color: _orange, borderRadius: BorderRadius.circular(12)),
                alignment: Alignment.center,
                child: Text(AppLocalizations.of(context).requestQuote, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _aboutTab(Map<String, dynamic> c) {
    final description = c['description'] as String;
    final services = (c['services'] as List).cast<String>();
    final phone = c['phone'] as String;
    final website = c['website'] as String;
    final location = c['location'] as String;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context).aboutUs, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(fontSize: 14, color: AppColors.secondary, height: 1.5)),
          const SizedBox(height: 20),

          Text(AppLocalizations.of(context).servicesOffered, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: services.map((s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.teal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
              child: Text(s, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.teal)),
            )).toList(),
          ),
          const SizedBox(height: 20),

          Text(AppLocalizations.of(context).serviceArea, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: AppColors.secondary),
              const SizedBox(width: 6),
              Text(location, style: const TextStyle(fontSize: 14, color: AppColors.secondary)),
            ],
          ),
          const SizedBox(height: 20),

          Text(AppLocalizations.of(context).contactLabel, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
          const SizedBox(height: 8),
          if (phone.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.phone, size: 16, color: AppColors.secondary),
                  const SizedBox(width: 8),
                  Text(phone, style: const TextStyle(fontSize: 14, color: AppColors.secondary)),
                ],
              ),
            ),
          if (website.isNotEmpty)
            Row(
              children: [
                const Icon(Icons.language, size: 16, color: AppColors.secondary),
                const SizedBox(width: 8),
                Text(website, style: const TextStyle(fontSize: 14, color: AppColors.teal)),
              ],
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _postsTab(Map<String, dynamic> c) {
    final companyId = c['id'] as String;
    final posts = MockData.serviceFeedPosts.cast<Map<String, dynamic>>().where((p) => p['companyId'] == companyId).toList();

    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.article_outlined, size: 48, color: AppColors.tertiary),
            SizedBox(height: 12),
            Text(AppLocalizations.of(context).noPostsYetCompany, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
            SizedBox(height: 4),
            Text(AppLocalizations.of(context).companyHasNoUpdates, style: TextStyle(fontSize: 13, color: AppColors.secondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      itemBuilder: (_, i) {
        final p = posts[i];
        final mediaType = p['mediaType'] as String;
        Color mediaColor;
        switch (mediaType) {
          case 'video':
            mediaColor = Colors.purple;
          case 'promo':
            mediaColor = _orange;
          default:
            mediaColor = Colors.blue;
        }
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p['text'] as String, style: const TextStyle(fontSize: 14, color: AppColors.secondary, height: 1.4)),
              const SizedBox(height: 10),
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(colors: [mediaColor.withValues(alpha: 0.3), mediaColor.withValues(alpha: 0.6)]),
                ),
                alignment: Alignment.center,
                child: mediaType == 'video'
                    ? const Icon(Icons.play_circle_fill, size: 40, color: Colors.white)
                    : Text(mediaType.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
              const SizedBox(height: 8),
              Text(p['time'] as String, style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
            ],
          ),
        );
      },
    );
  }

  Widget _promotionsTab(Map<String, dynamic> c) {
    final companyId = c['id'] as String;
    final promos = MockData.servicePromotions.cast<Map<String, dynamic>>().where((p) => p['companyId'] == companyId).toList();

    if (promos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_offer_outlined, size: 48, color: AppColors.tertiary),
            SizedBox(height: 12),
            Text(AppLocalizations.of(context).noPromotions, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
            SizedBox(height: 4),
            Text(AppLocalizations.of(context).companyHasNoPromotions, style: TextStyle(fontSize: 13, color: AppColors.secondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: promos.length,
      itemBuilder: (_, i) {
        final p = promos[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _orange.withValues(alpha: 0.3)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: _orange, borderRadius: BorderRadius.circular(8)),
                    child: Text(AppLocalizations.of(context).offer, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(p['title'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal))),
                ],
              ),
              const SizedBox(height: 8),
              Text(p['description'] as String, style: const TextStyle(fontSize: 13, color: AppColors.secondary, height: 1.4)),
              const SizedBox(height: 8),
              Text(AppLocalizations.of(context).validUntilDate(p['validUntil'] as String), style: TextStyle(fontSize: 12, color: _orange, fontWeight: FontWeight.w500)),
            ],
          ),
        );
      },
    );
  }

  Widget _galleryTab() {
    final pastelColors = [
      const Color(0xFFFFCDD2),
      const Color(0xFFC8E6C9),
      const Color(0xFFBBDEFB),
      const Color(0xFFFFF9C4),
      const Color(0xFFE1BEE7),
      const Color(0xFFFFE0B2),
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (ctx, i) => GestureDetector(
        onTap: () => ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).fullImageViewerComingSoon))),
        child: Container(
          decoration: BoxDecoration(
            color: pastelColors[i],
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Icon(Icons.image, size: 32, color: Colors.white.withValues(alpha: 0.8)),
        ),
      ),
    );
  }

  void _showQuoteDialog(String companyName) {
    showDialog(
      context: context,
      builder: (ctx) {
        final serviceController = TextEditingController();
        final dateController = TextEditingController();
        final detailsController = TextEditingController();

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(AppLocalizations.of(context).requestQuoteFromCompany(companyName), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: serviceController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).serviceType,
                    labelStyle: const TextStyle(fontSize: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).dateNeeded,
                    labelStyle: const TextStyle(fontSize: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: detailsController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).details,
                    labelStyle: const TextStyle(fontSize: 14),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(ctx).cancel, style: const TextStyle(color: AppColors.secondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).quoteRequestSent)));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(AppLocalizations.of(context).sendRequest),
            ),
          ],
        );
      },
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
