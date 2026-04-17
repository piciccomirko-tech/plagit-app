import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

/// Browse and search hospitality service providers.
/// Mirrors ServiceDiscoveryView.swift.
class ServiceDiscoveryView extends StatefulWidget {
  const ServiceDiscoveryView({super.key});

  @override
  State<ServiceDiscoveryView> createState() => _ServiceDiscoveryViewState();
}

class _MockCompany {
  final String id;
  final String name;
  final String initials;
  final double avatarHue;
  final String categoryName;
  final String subcategoryName;
  final String location;
  final String description;
  final double? rating;
  final int reviewCount;
  final bool isVerified;
  final bool isPremium;
  final bool isAvailable;

  const _MockCompany({
    required this.id,
    required this.name,
    required this.initials,
    this.avatarHue = 0.5,
    required this.categoryName,
    required this.subcategoryName,
    required this.location,
    required this.description,
    this.rating,
    this.reviewCount = 0,
    this.isVerified = false,
    this.isPremium = false,
    this.isAvailable = false,
  });
}

class _ServiceDiscoveryViewState extends State<ServiceDiscoveryView> {
  String _searchText = '';
  String? _selectedCategoryId;
  bool _verifiedOnly = false;
  bool _premiumOnly = false;
  bool _availableOnly = false;
  bool _showFilters = false;

  static const _categories = [
    ('catering', 'Catering', Icons.restaurant),
    ('cleaning', 'Cleaning', Icons.cleaning_services),
    ('consulting', 'Consulting', Icons.business_center),
    ('staffing', 'Staffing', Icons.people),
    ('events', 'Events', Icons.event),
    ('tech', 'Tech', Icons.computer),
  ];

  final List<_MockCompany> _companies = const [
    _MockCompany(
      id: '1', name: 'Elite Catering Co.', initials: 'EC', avatarHue: 0.1,
      categoryName: 'Catering', subcategoryName: 'Event Catering', location: 'London, UK',
      description: 'Premium event catering for hotels, conferences and private events. 15 years of experience.',
      rating: 4.8, reviewCount: 124, isVerified: true, isPremium: true, isAvailable: true,
    ),
    _MockCompany(
      id: '2', name: 'SparkleClean Services', initials: 'SC', avatarHue: 0.35,
      categoryName: 'Cleaning', subcategoryName: 'Hotel Cleaning', location: 'Manchester, UK',
      description: 'Specialized cleaning services for hotels and restaurants. Eco-friendly products.',
      rating: 4.5, reviewCount: 87, isVerified: true, isAvailable: true,
    ),
    _MockCompany(
      id: '3', name: 'Hospitality Pros', initials: 'HP', avatarHue: 0.55,
      categoryName: 'Consulting', subcategoryName: 'Business Consulting', location: 'Milan, Italy',
      description: 'Strategic consulting for hospitality businesses. From concept to execution.',
      rating: 4.9, reviewCount: 56, isVerified: true, isPremium: true,
    ),
    _MockCompany(
      id: '4', name: 'QuickStaff Agency', initials: 'QS', avatarHue: 0.7,
      categoryName: 'Staffing', subcategoryName: 'Temporary Staffing', location: 'Paris, France',
      description: 'Reliable temporary staff for events, hotels, and restaurants. Available 24/7.',
      rating: 4.3, reviewCount: 203, isAvailable: true,
    ),
    _MockCompany(
      id: '5', name: 'EventPlan Madrid', initials: 'EP', avatarHue: 0.85,
      categoryName: 'Events', subcategoryName: 'Event Planning', location: 'Madrid, Spain',
      description: 'Full-service event planning for corporate and social events in Spain.',
      rating: 4.7, reviewCount: 45, isVerified: true,
    ),
  ];

  List<_MockCompany> get _filtered {
    var result = _companies.toList();
    if (_selectedCategoryId != null) {
      result = result.where((c) => c.categoryName.toLowerCase() == _selectedCategoryId).toList();
    }
    if (_verifiedOnly) result = result.where((c) => c.isVerified).toList();
    if (_premiumOnly) result = result.where((c) => c.isPremium).toList();
    if (_availableOnly) result = result.where((c) => c.isAvailable).toList();
    if (_searchText.isNotEmpty) {
      final q = _searchText.toLowerCase();
      result = result.where((c) =>
          c.name.toLowerCase().contains(q) ||
          c.subcategoryName.toLowerCase().contains(q) ||
          c.location.toLowerCase().contains(q) ||
          c.description.toLowerCase().contains(q)).toList();
    }
    return result;
  }

  int get _activeFilterCount {
    int c = 0;
    if (_verifiedOnly) c++;
    if (_premiumOnly) c++;
    if (_availableOnly) c++;
    return c;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            _searchBar(),
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: _categoryChips(),
            ),
            if (_filtered.isEmpty)
              Expanded(child: _emptyState())
            else
              Expanded(child: _companyList()),
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
            child: const SizedBox(width: 36, height: 36, child: BackChevron(size: 22, color: AppColors.charcoal)),
          ),
          const Spacer(),
          const Text('Find Services', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
          const Spacer(),
          GestureDetector(
            onTap: () => _showFilterSheet(),
            child: SizedBox(
              width: 36,
              height: 36,
              child: Stack(
                children: [
                  const Center(child: Icon(Icons.tune, size: 22, color: AppColors.charcoal)),
                  if (_activeFilterCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 16, height: 16,
                        decoration: const BoxDecoration(color: AppColors.amber, shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: Text('$_activeFilterCount', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
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
              GestureDetector(
                onTap: () => setState(() => _searchText = ''),
                child: const Icon(Icons.cancel, size: 16, color: AppColors.tertiary),
              ),
          ],
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
            if (icon != null) ...[
              Icon(icon, size: 13, color: isActive ? Colors.white : AppColors.secondary),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isActive ? Colors.white : AppColors.secondary)),
          ],
        ),
      ),
    );
  }

  Widget _companyList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xxxl),
      itemCount: _filtered.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: _companyCard(_filtered[i]),
      ),
    );
  }

  Widget _companyCard(_MockCompany company) {
    final hsl = HSLColor.fromAHSL(1, company.avatarHue * 360, 0.15, 0.95);
    final hslText = HSLColor.fromAHSL(1, company.avatarHue * 360, 0.6, 0.5);

    return GestureDetector(
      onTap: () {
        // Navigate to company profile
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: hsl.toColor(), borderRadius: BorderRadius.circular(AppRadius.md)),
                  alignment: Alignment.center,
                  child: Text(company.initials, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: hslText.toColor())),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(child: Text(company.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal), overflow: TextOverflow.ellipsis)),
                          if (company.isVerified) ...[
                            const SizedBox(width: AppSpacing.sm),
                            const Icon(Icons.verified, size: 14, color: AppColors.teal),
                          ],
                          if (company.isPremium) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(color: AppColors.amber, borderRadius: BorderRadius.circular(AppRadius.full)),
                              child: const Text('PRO', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.white)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(company.subcategoryName, style: const TextStyle(fontSize: 13, color: AppColors.teal), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                if (company.rating != null)
                  Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 12, color: AppColors.amber),
                          const SizedBox(width: 2),
                          Text(company.rating!.toStringAsFixed(1), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
                        ],
                      ),
                      Text('${company.reviewCount}', style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Description
            Text(company.description, style: const TextStyle(fontSize: 13, color: AppColors.secondary), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: AppSpacing.md),

            // Footer
            Row(
              children: [
                const Icon(Icons.location_on, size: 12, color: AppColors.teal),
                const SizedBox(width: AppSpacing.xs),
                Text(company.location, style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
                const Spacer(),
                if (company.isAvailable)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.online, shape: BoxShape.circle)),
                      const SizedBox(width: 3),
                      const Text('Available', style: TextStyle(fontSize: 11, color: AppColors.online)),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.amber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppRadius.full)),
                  child: Text(company.categoryName, style: const TextStyle(fontSize: 11, color: AppColors.amber)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: AppColors.amber.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.search, size: 24, color: AppColors.amber),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('No services found', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
            const SizedBox(height: AppSpacing.xs),
            const Text('Try a different search, category, or adjust your filters.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.secondary)),
            if (_activeFilterCount > 0) ...[
              const SizedBox(height: AppSpacing.md),
              GestureDetector(
                onTap: () => setState(() { _verifiedOnly = false; _premiumOnly = false; _availableOnly = false; }),
                child: const Text('Clear Filters', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.teal)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl))),
      builder: (_) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    const Text('Filters', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: const Text('Done', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.teal)),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                SwitchListTile(
                  value: _verifiedOnly,
                  activeColor: AppColors.teal,
                  title: const Row(children: [
                    Icon(Icons.verified, size: 16, color: AppColors.teal),
                    SizedBox(width: AppSpacing.sm),
                    Text('Verified Only', style: TextStyle(fontSize: 15, color: AppColors.charcoal)),
                  ]),
                  onChanged: (v) { setState(() => _verifiedOnly = v); setSheetState(() {}); },
                ),
                SwitchListTile(
                  value: _premiumOnly,
                  activeColor: AppColors.teal,
                  title: const Row(children: [
                    Icon(Icons.workspace_premium, size: 16, color: AppColors.amber),
                    SizedBox(width: AppSpacing.sm),
                    Text('Premium Only', style: TextStyle(fontSize: 15, color: AppColors.charcoal)),
                  ]),
                  onChanged: (v) { setState(() => _premiumOnly = v); setSheetState(() {}); },
                ),
                SwitchListTile(
                  value: _availableOnly,
                  activeColor: AppColors.teal,
                  title: const Row(children: [
                    Icon(Icons.schedule, size: 16, color: AppColors.online),
                    SizedBox(width: AppSpacing.sm),
                    Text('Available Now', style: TextStyle(fontSize: 15, color: AppColors.charcoal)),
                  ]),
                  onChanged: (v) { setState(() => _availableOnly = v); setSheetState(() {}); },
                ),
                const SizedBox(height: AppSpacing.lg),
                GestureDetector(
                  onTap: () {
                    setState(() { _verifiedOnly = false; _premiumOnly = false; _availableOnly = false; });
                    setSheetState(() {});
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.urgent.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    alignment: Alignment.center,
                    child: const Text('Reset Filters', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.urgent)),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          );
        });
      },
    );
  }
}
