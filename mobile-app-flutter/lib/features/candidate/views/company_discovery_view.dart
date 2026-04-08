import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';

/// Company discovery — mirrors CompanyDiscoveryView.swift (list mode).
class CompanyDiscoveryView extends StatefulWidget {
  const CompanyDiscoveryView({super.key});

  @override
  State<CompanyDiscoveryView> createState() => _CompanyDiscoveryViewState();
}

class _CompanyDiscoveryViewState extends State<CompanyDiscoveryView> {
  final _searchController = TextEditingController();
  String? _selectedCategoryId;
  double _selectedRadius = 10;
  bool _isListMode = true;
  bool _verifiedOnly = false;

  final List<double> _radii = [3, 5, 10, 15, 20];

  // Mock categories
  final List<Map<String, String>> _categories = [
    {'id': 'catering', 'name': 'Catering', 'icon': 'restaurant'},
    {'id': 'cleaning', 'name': 'Cleaning', 'icon': 'cleaning_services'},
    {'id': 'staffing', 'name': 'Staffing', 'icon': 'people'},
    {'id': 'consulting', 'name': 'Consulting', 'icon': 'business'},
    {'id': 'tech', 'name': 'Tech', 'icon': 'computer'},
  ];

  // Mock companies
  final List<Map<String, dynamic>> _companies = [
    {
      'id': 'c1',
      'name': 'Elite Catering Co.',
      'initials': 'EC',
      'avatarHue': 0.1,
      'subcategoryName': 'Event Catering',
      'description': 'Premium catering services for corporate events, weddings, and private parties across London.',
      'location': 'Westminster, London',
      'latitude': 51.501,
      'longitude': -0.125,
      'isVerified': true,
      'isPremium': true,
      'isAvailable': true,
      'rating': 4.8,
      'reviewCount': 156,
      'categoryId': 'catering',
    },
    {
      'id': 'c2',
      'name': 'SparkClean Services',
      'initials': 'SC',
      'avatarHue': 0.45,
      'subcategoryName': 'Commercial Cleaning',
      'description': 'Professional cleaning for hotels, restaurants, and hospitality venues.',
      'location': 'Shoreditch, London',
      'latitude': 51.523,
      'longitude': -0.077,
      'isVerified': true,
      'isPremium': false,
      'isAvailable': true,
      'rating': 4.5,
      'reviewCount': 89,
      'categoryId': 'cleaning',
    },
    {
      'id': 'c3',
      'name': 'Hospitality Staff Direct',
      'initials': 'HS',
      'avatarHue': 0.7,
      'subcategoryName': 'Temporary Staffing',
      'description': 'Reliable temporary staffing solutions for restaurants, bars, and hotels.',
      'location': 'Soho, London',
      'latitude': 51.513,
      'longitude': -0.136,
      'isVerified': false,
      'isPremium': false,
      'isAvailable': false,
      'rating': 4.2,
      'reviewCount': 43,
      'categoryId': 'staffing',
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    return _companies.where((co) {
      if (_verifiedOnly && co['isVerified'] != true) return false;
      if (_selectedCategoryId != null && co['categoryId'] != _selectedCategoryId) return false;
      final query = _searchController.text.toLowerCase();
      if (query.isNotEmpty) {
        final name = (co['name'] as String).toLowerCase();
        final desc = (co['description'] as String).toLowerCase();
        final loc = (co['location'] as String).toLowerCase();
        if (!name.contains(query) && !desc.contains(query) && !loc.contains(query)) return false;
      }
      return true;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildSearchBar(),
            const SizedBox(height: AppSpacing.xs),
            _buildRadiusAndToggle(),
            const SizedBox(height: AppSpacing.xs),
            _buildCategoryChips(),
            const SizedBox(height: AppSpacing.sm),
            _buildSummaryRow(),
            const SizedBox(height: AppSpacing.xs),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.sm),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const SizedBox(width: 36, height: 36, child: Icon(Icons.chevron_left, size: 22, color: AppColors.charcoal)),
          ),
          const Spacer(),
          const Text('Find Companies', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
          const Spacer(),
          GestureDetector(
            onTap: _showFilters,
            child: SizedBox(
              width: 36, height: 36,
              child: Stack(
                children: [
                  const Center(child: Icon(Icons.tune, size: 18, color: AppColors.charcoal)),
                  if (_verifiedOnly)
                    Positioned(
                      right: 4, top: 4,
                      child: Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.amber)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md)),
        child: Row(
          children: [
            const Icon(Icons.search, size: 14, color: AppColors.tertiary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
                decoration: const InputDecoration(
                  hintText: 'Search companies, services, locations...',
                  hintStyle: TextStyle(fontSize: 15, color: AppColors.tertiary),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              GestureDetector(
                onTap: () { _searchController.clear(); setState(() {}); },
                child: const Icon(Icons.cancel, size: 14, color: AppColors.tertiary),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadiusAndToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _radii.map((r) {
                  final active = _selectedRadius == r;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedRadius = r),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md + 2, vertical: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: active ? AppColors.amber : AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: active ? null : Border.all(color: AppColors.border, width: 0.5),
                        ),
                        child: Text('${r.toInt()} km', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: active ? Colors.white : AppColors.secondary)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.sm + 2)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildToggle(Icons.list, true),
                _buildToggle(Icons.map_outlined, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(IconData icon, bool isList) {
    final active = _isListMode == isList;
    return GestureDetector(
      onTap: () => setState(() => _isListMode = isList),
      child: Container(
        width: 34, height: 30,
        decoration: BoxDecoration(
          color: active ? AppColors.amber : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, size: 13, color: active ? Colors.white : AppColors.tertiary),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          _buildChip('All', null, _selectedCategoryId == null, () => setState(() => _selectedCategoryId = null)),
          ..._categories.map((cat) => _buildChip(
            cat['name']!, null, _selectedCategoryId == cat['id'],
            () => setState(() => _selectedCategoryId = _selectedCategoryId == cat['id'] ? null : cat['id']),
          )),
        ],
      ),
    );
  }

  Widget _buildChip(String label, IconData? icon, bool active, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: active ? AppColors.amber : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: active ? null : Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: active ? Colors.white : AppColors.secondary)),
        ),
      ),
    );
  }

  Widget _buildSummaryRow() {
    final companies = _filtered;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: companies.isEmpty ? AppColors.tertiary : AppColors.online)),
          const SizedBox(width: AppSpacing.xs),
          Text(companies.isEmpty ? 'No results' : '${companies.length} companies', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
          const SizedBox(width: AppSpacing.sm),
          const Text('\u00b7', style: TextStyle(color: AppColors.tertiary)),
          const SizedBox(width: AppSpacing.sm),
          Text('${_selectedRadius.toInt()} km', style: const TextStyle(fontSize: 10, color: AppColors.tertiary)),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (!_isListMode) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.amber.withValues(alpha: 0.1)),
              child: const Icon(Icons.map_outlined, size: 24, color: AppColors.amber),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('Map View', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
            const SizedBox(height: AppSpacing.xs),
            const Text('Map view coming soon.', style: TextStyle(fontSize: 13, color: AppColors.secondary)),
          ],
        ),
      );
    }
    final companies = _filtered;
    if (companies.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.amber.withValues(alpha: 0.1)),
                child: const Icon(Icons.business, size: 24, color: AppColors.amber),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text('No companies found', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
              const SizedBox(height: AppSpacing.xs),
              const Text('Try a wider radius or different category.', style: TextStyle(fontSize: 13, color: AppColors.secondary), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xxxl),
      itemCount: companies.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: _buildCompanyCard(companies[index]),
      ),
    );
  }

  Widget _buildCompanyCard(Map<String, dynamic> co) {
    final hue = (co['avatarHue'] as num).toDouble();
    final rating = co['rating'] as double?;

    return GestureDetector(
      onTap: () {
        // Would navigate to company profile
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: HSLColor.fromAHSL(1, hue * 360, 0.15, 0.95).toColor(),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  alignment: Alignment.center,
                  child: Text(co['initials'] as String, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: HSLColor.fromAHSL(1, hue * 360, 0.6, 0.5).toColor())),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(child: Text(co['name'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          if (co['isVerified'] == true) ...[
                            const SizedBox(width: AppSpacing.sm),
                            const Icon(Icons.verified, size: 12, color: AppColors.teal),
                          ],
                          if (co['isPremium'] == true) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(color: AppColors.amber, borderRadius: BorderRadius.circular(AppRadius.full)),
                              child: const Text('PRO', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(co['subcategoryName'] as String, style: const TextStyle(fontSize: 13, color: AppColors.teal), maxLines: 1),
                    ],
                  ),
                ),
                if (rating != null)
                  Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 10, color: AppColors.amber),
                          const SizedBox(width: 2),
                          Text(rating.toStringAsFixed(1), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
                        ],
                      ),
                      Text('${co['reviewCount']}', style: const TextStyle(fontSize: 10, color: AppColors.tertiary)),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(co['description'] as String, style: const TextStyle(fontSize: 13, color: AppColors.secondary), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Icon(Icons.location_on, size: 10, color: AppColors.teal),
                const SizedBox(width: AppSpacing.sm),
                Text(co['location'] as String, style: const TextStyle(fontSize: 10, color: AppColors.tertiary)),
                const Spacer(),
                if (co['isAvailable'] == true)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.online)),
                      const SizedBox(width: 3),
                      const Text('Available', style: TextStyle(fontSize: 10, color: AppColors.online)),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return Container(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: const Text('Done', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.amber)),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    const Icon(Icons.verified, size: 14, color: AppColors.teal),
                    const SizedBox(width: AppSpacing.sm),
                    const Expanded(child: Text('Verified Only', style: TextStyle(fontSize: 15, color: AppColors.charcoal))),
                    Switch(
                      value: _verifiedOnly,
                      onChanged: (v) {
                        setSheetState(() => _verifiedOnly = v);
                        setState(() {});
                      },
                      activeColor: AppColors.amber,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
                GestureDetector(
                  onTap: () {
                    setSheetState(() => _verifiedOnly = false);
                    setState(() {});
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
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          );
        });
      },
    );
  }
}
