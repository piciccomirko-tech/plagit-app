import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

/// Business Nearby Talent screen with list view, radius & role filters.
/// Mirrors BusinessNearbyTalentView.swift (list mode only, no native map).
class BusinessNearbyTalentView extends StatefulWidget {
  const BusinessNearbyTalentView({super.key});

  @override
  State<BusinessNearbyTalentView> createState() =>
      _BusinessNearbyTalentViewState();
}

class _BusinessNearbyTalentViewState extends State<BusinessNearbyTalentView> {
  bool _loading = true;
  String? _error;
  double _selectedRadius = 10;
  String _selectedRole = 'All';
  final Set<String> _shortlisted = {};

  final List<double> _radii = [3, 5, 10, 15, 20];
  final List<String> _roles = [
    'All',
    'Chef',
    'Waiter',
    'Bartender',
    'Manager',
    'Reception',
    'Kitchen Porter',
    'Relocate'
  ];

  List<Map<String, dynamic>> _candidates = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _candidates = _mockCandidates();
      _loading = false;
    });
  }

  List<Map<String, dynamic>> _mockCandidates() => [
        {
          'id': 'n1',
          'name': 'Luca Bianchi',
          'initials': 'LB',
          'hue': 0.15,
          'role': 'Chef',
          'experience': '6 years',
          'location': 'Soho, London',
          'distanceKm': 1.2,
          'isVerified': true,
          'jobType': 'Full-time',
        },
        {
          'id': 'n2',
          'name': 'Emma Wilson',
          'initials': 'EW',
          'hue': 0.65,
          'role': 'Waiter',
          'experience': '3 years',
          'location': 'Camden, London',
          'distanceKm': 3.8,
          'isVerified': false,
          'jobType': 'Part-time',
        },
        {
          'id': 'n3',
          'name': 'Kenji Tanaka',
          'initials': 'KT',
          'hue': 0.45,
          'role': 'Bartender',
          'experience': '5 years',
          'location': 'Shoreditch, London',
          'distanceKm': 4.5,
          'isVerified': true,
          'jobType': 'Full-time',
        },
        {
          'id': 'n4',
          'name': 'Priya Sharma',
          'initials': 'PS',
          'hue': 0.85,
          'role': 'Manager',
          'experience': '10 years',
          'location': 'Westminster, London',
          'distanceKm': 7.2,
          'isVerified': true,
          'jobType': 'Full-time',
        },
        {
          'id': 'n5',
          'name': 'Carlos Ruiz',
          'initials': 'CR',
          'hue': 0.30,
          'role': 'Kitchen Porter',
          'experience': '2 years',
          'location': 'Brixton, London',
          'distanceKm': 9.1,
          'isVerified': false,
          'jobType': 'Flexible',
        },
      ];

  List<Map<String, dynamic>> get _displayed {
    var list = _candidates;
    if (_selectedRole == 'Relocate') {
      return list; // mock: show all for relocate
    }
    if (_selectedRole != 'All') {
      list = list.where((c) => c['role'] == _selectedRole).toList();
    }
    list = list
        .where((c) => (c['distanceKm'] as double) <= _selectedRadius)
        .toList();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            _radiusRow(),
            const SizedBox(height: AppSpacing.xs),
            _roleChips(),
            const SizedBox(height: AppSpacing.sm),
            _summaryRow(),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  // ── Top Bar ──
  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const SizedBox(
                width: 36,
                height: 36,
                child: BackChevron(size: 22, color: AppColors.charcoal)),
          ),
          const Spacer(),
          const Text('Nearby Talent',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal)),
          const Spacer(),
          const SizedBox(width: 36, height: 36),
        ],
      ),
    );
  }

  // ── Radius selector ──
  Widget _radiusRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md + 2, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: active ? AppColors.teal : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: active
                        ? null
                        : Border.all(
                            color: AppColors.border, width: 0.5),
                  ),
                  child: Text('${r.toInt()} km',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: active ? Colors.white : AppColors.secondary)),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Role chips ──
  Widget _roleChips() {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        itemCount: _roles.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, i) {
          final r = _roles[i];
          final active = _selectedRole == r;
          return GestureDetector(
            onTap: () => setState(() => _selectedRole = r),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: active ? AppColors.teal : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border:
                    active ? null : Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Text(r,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: active ? Colors.white : AppColors.charcoal)),
            ),
          );
        },
      ),
    );
  }

  // ── Summary ──
  Widget _summaryRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _displayed.isEmpty ? AppColors.tertiary : AppColors.online,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
              _displayed.isEmpty
                  ? 'No results'
                  : '${_displayed.length} candidate${_displayed.length == 1 ? '' : 's'} found',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.charcoal)),
          Text(' \u00b7 ', style: TextStyle(color: AppColors.tertiary)),
          Text('${_selectedRadius.toInt()} km',
              style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
          if (_selectedRole != 'All') ...[
            Text(' \u00b7 ', style: TextStyle(color: AppColors.tertiary)),
            Text(_selectedRole,
                style: const TextStyle(fontSize: 11, color: AppColors.teal)),
          ],
          const Spacer(),
        ],
      ),
    );
  }

  // ── Body ──
  Widget _body() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.teal));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 32, color: AppColors.tertiary),
            const SizedBox(height: AppSpacing.md),
            Text(_error!,
                style:
                    const TextStyle(fontSize: 12, color: AppColors.secondary)),
            GestureDetector(
                onTap: _load,
                child: const Text('Retry',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.teal))),
          ],
        ),
      );
    }
    if (_displayed.isEmpty) {
      return _emptyState();
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
      itemCount: _displayed.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: _candidateCard(_displayed[i]),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  _selectedRole != 'All'
                      ? 'No ${_selectedRole.toLowerCase()}s nearby'
                      : 'No candidates found',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal)),
              const SizedBox(height: 4),
              Text('within ${_selectedRadius.toInt()} km',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.tertiary)),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_selectedRadius < 20)
                    GestureDetector(
                      onTap: () => setState(() =>
                          _selectedRadius = (_selectedRadius + 5).clamp(1, 20)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm + 2),
                        decoration: BoxDecoration(
                          color: AppColors.teal,
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                            'Expand to ${(_selectedRadius + 5).clamp(1, 20).toInt()} km',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.white)),
                      ),
                    ),
                  if (_selectedRole != 'All') ...[
                    const SizedBox(width: AppSpacing.sm),
                    GestureDetector(
                      onTap: () => setState(() => _selectedRole = 'All'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                        ),
                        child: const Text('All roles',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.tertiary)),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Candidate Card ──
  Widget _candidateCard(Map<String, dynamic> c) {
    final id = c['id'] as String;
    final isShort = _shortlisted.contains(id);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              _avatar(c['initials'] ?? '--', c['hue'] ?? 0.5, 48),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c['name'] ?? '',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.charcoal)),
                    if (c['role'] != null)
                      Text(c['role'],
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.secondary)),
                    Row(
                      children: [
                        if (c['experience'] != null)
                          Text(c['experience'],
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.tertiary)),
                        if (c['location'] != null) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Icon(Icons.place, size: 8, color: AppColors.tertiary),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(c['location'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.tertiary)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                      (c['distanceKm'] as double?)?.toStringAsFixed(1) ?? '0.0',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.teal)),
                  const Text('km',
                      style: TextStyle(fontSize: 11, color: AppColors.tertiary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Actions
          Row(
            children: [
              _smallAction('View', Icons.person, AppColors.teal, () {}),
              const SizedBox(width: AppSpacing.sm),
              _smallAction(
                  isShort ? 'Shortlisted' : 'Shortlist',
                  isShort ? Icons.star : Icons.star_border,
                  isShort ? AppColors.amber : AppColors.secondary, () {
                setState(() {
                  if (isShort) {
                    _shortlisted.remove(id);
                  } else {
                    _shortlisted.add(id);
                  }
                });
              }),
              const SizedBox(width: AppSpacing.sm),
              _smallAction(
                  'Message', Icons.chat_bubble_outline, AppColors.indigo, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallAction(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 11, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: color)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatar(String initials, double hue, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            HSLColor.fromAHSL(1, hue * 360, 0.45, 0.90).toColor(),
            HSLColor.fromAHSL(1, hue * 360, 0.55, 0.75).toColor(),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(initials,
          style: TextStyle(
              fontSize: size * 0.30,
              fontWeight: FontWeight.w700,
              color: Colors.white)),
    );
  }
}
