import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';

/// Nearby jobs list — mirrors CandidateNearbyRealView.swift (list mode only, no MapKit).
class CandidateNearbyView extends StatefulWidget {
  const CandidateNearbyView({super.key});

  @override
  State<CandidateNearbyView> createState() => _CandidateNearbyViewState();
}

class _CandidateNearbyViewState extends State<CandidateNearbyView> {
  bool _loading = true;
  String? _error;
  double _selectedRadius = 10;
  String _selectedCategory = 'All';
  bool _isListMode = true;

  final List<double> _radii = [3, 5, 10, 15, 20];
  final List<String> _categories = ['All', 'Chef', 'Waiter', 'Bartender', 'Manager', 'Reception', 'Kitchen Porter'];

  // Mock nearby jobs
  final List<Map<String, dynamic>> _allJobs = [
    {
      'id': 'n1',
      'title': 'Head Chef',
      'businessName': 'The Grand Hotel',
      'businessInitials': 'GH',
      'businessAvatarHue': 0.55,
      'businessVerified': true,
      'location': 'Mayfair, London',
      'salary': '\u00a340,000 - \u00a350,000',
      'employmentType': 'Full-time',
      'distanceKm': 2.3,
      'category': 'Chef',
      'isFeatured': true,
    },
    {
      'id': 'n2',
      'title': 'Bartender',
      'businessName': 'Sky Lounge',
      'businessInitials': 'SL',
      'businessAvatarHue': 0.7,
      'businessVerified': false,
      'location': 'Soho, London',
      'salary': '\u00a325,000',
      'employmentType': 'Part-time',
      'distanceKm': 4.8,
      'category': 'Bartender',
      'isFeatured': false,
    },
    {
      'id': 'n3',
      'title': 'Restaurant Manager',
      'businessName': 'Bella Italia',
      'businessInitials': 'BI',
      'businessAvatarHue': 0.1,
      'businessVerified': true,
      'location': 'Covent Garden, London',
      'salary': '\u00a335,000 - \u00a342,000',
      'employmentType': 'Full-time',
      'distanceKm': 7.2,
      'category': 'Manager',
      'isFeatured': false,
    },
    {
      'id': 'n4',
      'title': 'Waiter',
      'businessName': 'Nobu London',
      'businessInitials': 'NL',
      'businessAvatarHue': 0.35,
      'businessVerified': true,
      'location': 'Park Lane, London',
      'salary': '\u00a322,000',
      'employmentType': 'Contract',
      'distanceKm': 12.5,
      'category': 'Waiter',
      'isFeatured': true,
    },
  ];

  List<Map<String, dynamic>> get _filteredJobs {
    return _allJobs.where((j) {
      final dist = (j['distanceKm'] as num).toDouble();
      if (dist > _selectedRadius) return false;
      if (_selectedCategory != 'All' && j['category'] != _selectedCategory) return false;
      return true;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
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
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.lg),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const SizedBox(width: 36, height: 36, child: Icon(Icons.chevron_left, size: 22, color: AppColors.charcoal)),
          ),
          const Spacer(),
          const Text('Jobs Near You', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
          const Spacer(),
          const SizedBox(width: 36, height: 36),
        ],
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
                          color: active ? AppColors.teal : AppColors.surface,
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
                _buildToggleButton(Icons.list, true),
                _buildToggleButton(Icons.map_outlined, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(IconData icon, bool isList) {
    final active = _isListMode == isList;
    return GestureDetector(
      onTap: () => setState(() => _isListMode = isList),
      child: Container(
        width: 34, height: 30,
        decoration: BoxDecoration(
          color: active ? AppColors.teal : Colors.transparent,
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
        children: _categories.map((cat) {
          final active = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: active ? AppColors.teal : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: active ? null : Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Text(cat, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: active ? Colors.white : AppColors.charcoal)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryRow() {
    final jobs = _filteredJobs;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: jobs.isEmpty ? AppColors.tertiary : AppColors.online),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            jobs.isEmpty ? 'No results' : '${jobs.length} jobs found',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.charcoal),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Text('\u00b7', style: TextStyle(color: AppColors.tertiary)),
          const SizedBox(width: AppSpacing.sm),
          Text('${_selectedRadius.toInt()} km', style: const TextStyle(fontSize: 10, color: AppColors.tertiary)),
          if (_selectedCategory != 'All') ...[
            const SizedBox(width: AppSpacing.sm),
            const Text('\u00b7', style: TextStyle(color: AppColors.tertiary)),
            const SizedBox(width: AppSpacing.sm),
            Text(_selectedCategory, style: const TextStyle(fontSize: 10, color: AppColors.teal)),
          ],
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.teal, strokeWidth: 2.5));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 32, color: AppColors.tertiary),
            const SizedBox(height: AppSpacing.md),
            Text(_error!, style: const TextStyle(fontSize: 13, color: AppColors.secondary), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: () {},
              child: const Text('Retry', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.teal)),
            ),
          ],
        ),
      );
    }
    if (!_isListMode) {
      return _buildMapPlaceholder();
    }
    final jobs = _filteredJobs;
    if (jobs.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xxxl),
      itemCount: jobs.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: _buildJobCard(jobs[index]),
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    final hue = (job['businessAvatarHue'] as num?)?.toDouble() ?? 0.5;
    final distKm = (job['distanceKm'] as num).toDouble();

    return GestureDetector(
      onTap: () => context.push('/candidate/job/${job['id']}'),
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
                _buildAvatar(job['businessInitials'] ?? '?', hue, job['businessVerified'] == true),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job['title'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                      const SizedBox(height: AppSpacing.xs),
                      Text(job['businessName'] ?? 'Unknown', style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
                      if (job['location'] != null && (job['location'] as String).isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 9, color: AppColors.tertiary),
                            const SizedBox(width: AppSpacing.xs),
                            Flexible(child: Text(job['location'] as String, style: const TextStyle(fontSize: 10, color: AppColors.tertiary))),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(distKm.toStringAsFixed(1), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.teal)),
                    const Text('km', style: TextStyle(fontSize: 10, color: AppColors.tertiary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Tags
            Row(
              children: [
                if (job['salary'] != null && (job['salary'] as String).isNotEmpty) _buildTag(job['salary']!, AppColors.charcoal),
                if (job['employmentType'] != null) _buildTag(job['employmentType']!, AppColors.teal),
                if (job['isFeatured'] == true) _buildTag('Featured', AppColors.amber),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: const [
                Text('View Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.teal)),
                SizedBox(width: AppSpacing.sm),
                Icon(Icons.chevron_right, size: 10, color: AppColors.teal),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String initials, double hue, bool verified) {
    return SizedBox(
      width: 44, height: 44,
      child: Stack(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  HSLColor.fromAHSL(1, hue * 360, 0.45, 0.82).toColor(),
                  HSLColor.fromAHSL(1, hue * 360, 0.55, 0.70).toColor(),
                ],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
            ),
            alignment: Alignment.center,
            child: Text(initials, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          if (verified)
            Positioned(
              right: 0, bottom: 0,
              child: Container(
                width: 14, height: 14,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                child: const Icon(Icons.verified, size: 12, color: AppColors.teal),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppRadius.full)),
        child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: color)),
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.tealLight),
            child: const Icon(Icons.map_outlined, size: 24, color: AppColors.teal),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('Map View', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
          const SizedBox(height: AppSpacing.xs),
          const Text('Map view coming soon.\nSwitch to list to browse jobs.', style: TextStyle(fontSize: 13, color: AppColors.secondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.lg),
            Text(
              _selectedCategory != 'All' ? '$_selectedCategory \u2014 No jobs found' : 'No jobs found',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.charcoal),
            ),
            const SizedBox(height: 4),
            Text('Within ${_selectedRadius.toInt()} km', style: const TextStyle(fontSize: 13, color: AppColors.tertiary)),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_selectedRadius < 20)
                  GestureDetector(
                    onTap: () => setState(() => _selectedRadius = (_selectedRadius + 5).clamp(3, 20)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm + 2),
                      decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(AppRadius.full)),
                      child: Text('Expand to ${(_selectedRadius + 5).clamp(3, 20).toInt()} km', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                    ),
                  ),
                if (_selectedCategory != 'All') ...[
                  const SizedBox(width: AppSpacing.sm),
                  GestureDetector(
                    onTap: () => setState(() => _selectedCategory = 'All'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.full)),
                      child: const Text('All roles', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.tertiary)),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
