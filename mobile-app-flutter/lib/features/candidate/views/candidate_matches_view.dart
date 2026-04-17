import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

/// Candidate matches — mirrors CandidateMatchesView.swift.
class CandidateMatchesView extends StatefulWidget {
  const CandidateMatchesView({super.key});

  @override
  State<CandidateMatchesView> createState() => _CandidateMatchesViewState();
}

class _CandidateMatchesViewState extends State<CandidateMatchesView> {
  bool _loading = true;
  String? _error;
  final Set<String> _dismissed = {};
  final Set<String> _accepted = {};

  // Mock data
  final List<Map<String, dynamic>> _matches = [
    {
      'id': 'm1',
      'matchId': 'match-1',
      'title': 'Head Chef',
      'businessName': 'The Grand Hotel',
      'businessInitials': 'GH',
      'businessAvatarHue': 0.55,
      'businessVerified': true,
      'category': 'Chef',
      'employmentType': 'Full-time',
      'location': 'London, UK',
      'salary': '\u00a335,000 - \u00a345,000',
      'openToInternational': false,
      'isFeatured': true,
    },
    {
      'id': 'm2',
      'matchId': 'match-2',
      'title': 'Sous Chef',
      'businessName': 'Bella Italia',
      'businessInitials': 'BI',
      'businessAvatarHue': 0.1,
      'businessVerified': false,
      'category': 'Chef',
      'employmentType': 'Full-time',
      'location': 'Manchester, UK',
      'salary': '\u00a328,000 - \u00a332,000',
      'openToInternational': true,
      'isFeatured': false,
    },
    {
      'id': 'm3',
      'matchId': 'match-3',
      'title': 'Bar Manager',
      'businessName': 'Sky Lounge',
      'businessInitials': 'SL',
      'businessAvatarHue': 0.7,
      'businessVerified': true,
      'category': 'Bartender',
      'employmentType': 'Part-time',
      'location': 'Birmingham, UK',
      'salary': null,
      'openToInternational': false,
      'isFeatured': false,
    },
  ];

  List<Map<String, dynamic>> get _visible =>
      _matches.where((j) => !_dismissed.contains(j['id'])).toList();

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
            child: const SizedBox(width: 36, height: 36, child: BackChevron(size: 22, color: AppColors.charcoal)),
          ),
          const Spacer(),
          const Text('Your Matches', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
          const Spacer(),
          const SizedBox(width: 36, height: 36),
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
            const Icon(Icons.warning_amber_rounded, size: 28, color: AppColors.tertiary),
            const SizedBox(height: AppSpacing.md),
            Text(_error!, style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: () => setState(() { _loading = true; _error = null; }),
              child: const Text('Retry', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.teal)),
            ),
          ],
        ),
      );
    }
    if (_visible.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.people_outline, size: 36, color: AppColors.tertiary),
              SizedBox(height: AppSpacing.lg),
              Text('No matches yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Complete your profile to get matched with relevant jobs.',
                style: TextStyle(fontSize: 15, color: AppColors.secondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, AppSpacing.md, 0, AppSpacing.xxxl),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Text('${_visible.length} matching jobs', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.secondary)),
        ),
        const SizedBox(height: AppSpacing.md),
        ..._visible.map((job) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _buildMatchCard(job),
        )),
      ],
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> job) {
    final id = job['id'] as String;
    final hue = (job['businessAvatarHue'] as num?)?.toDouble() ?? 0.5;
    final isAccepted = _accepted.contains(id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              _buildAvatar(job['businessInitials'] ?? '—', hue, job['businessVerified'] == true),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job['title'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal), maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (job['businessName'] != null)
                      Text(job['businessName']!, style: const TextStyle(fontSize: 13, color: AppColors.secondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                decoration: BoxDecoration(color: AppColors.online.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppRadius.full)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.verified, size: 12, color: AppColors.online),
                    SizedBox(width: AppSpacing.xs),
                    Text('Match', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.online)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Tags
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (job['category'] != null) _buildTagPill(job['category']!, Icons.work, AppColors.indigo),
                if (job['employmentType'] != null) _buildTagPill(job['employmentType']!, Icons.schedule, AppColors.teal),
                if (job['location'] != null && (job['location'] as String).isNotEmpty) _buildTagPill(job['location']!, Icons.location_on, AppColors.secondary),
                if (job['openToInternational'] == true) _buildTagPill('International', Icons.public, AppColors.indigo),
              ],
            ),
          ),
          // Salary
          if (job['salary'] != null && (job['salary'] as String).isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(job['salary']!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.teal)),
          ],
          const SizedBox(height: AppSpacing.md),
          // Actions
          if (isAccepted)
            Row(
              children: [
                const Icon(Icons.check_circle, size: 16, color: AppColors.online),
                const SizedBox(width: AppSpacing.sm),
                const Text('Accepted', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.online)),
                const Spacer(),
                if (job['isFeatured'] == true) _buildFeaturedBadge(),
              ],
            )
          else
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _accepted.add(id)),
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 90),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
                    decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(AppRadius.full)),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.check, size: 12, color: Colors.white),
                        SizedBox(width: AppSpacing.xs),
                        Text('Accept', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                GestureDetector(
                  onTap: () => setState(() => _dismissed.add(id)),
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 80),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
                    decoration: BoxDecoration(color: AppColors.urgent.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppRadius.full)),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.close, size: 12, color: AppColors.urgent),
                        SizedBox(width: AppSpacing.xs),
                        Text('Deny', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.urgent)),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                if (job['isFeatured'] == true) _buildFeaturedBadge(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String initials, double hue, bool verified) {
    return SizedBox(
      width: 48, height: 48,
      child: Stack(
        children: [
          Container(
            width: 48, height: 48,
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
                width: 16, height: 16,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                child: const Icon(Icons.verified, size: 14, color: AppColors.teal),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTagPill(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppRadius.full)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 9, color: color),
            const SizedBox(width: 3),
            Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: color), maxLines: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedBadge() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(Icons.star, size: 10, color: AppColors.amber),
        SizedBox(width: AppSpacing.xs),
        Text('Featured', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.amber)),
      ],
    );
  }
}
