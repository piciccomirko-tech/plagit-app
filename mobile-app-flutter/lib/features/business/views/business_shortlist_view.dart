import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

/// Business Shortlist screen — shortlisted candidates.
/// Mirrors BusinessShortlistView.swift with mock data.
class BusinessShortlistView extends StatefulWidget {
  const BusinessShortlistView({super.key});

  @override
  State<BusinessShortlistView> createState() => _BusinessShortlistViewState();
}

class _BusinessShortlistViewState extends State<BusinessShortlistView> {
  bool _loading = true;
  List<Map<String, dynamic>> _candidates = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _candidates = _mockCandidates();
      _loading = false;
    });
  }

  List<Map<String, dynamic>> _mockCandidates() => [
        {
          'id': 'sl1',
          'name': 'Marco Rossi',
          'initials': 'MR',
          'hue': 0.55,
          'role': 'Senior Chef',
          'experience': '8 years',
          'location': 'London',
          'isVerified': true,
          'nationalityCode': 'IT',
        },
        {
          'id': 'sl2',
          'name': 'Sophie Chen',
          'initials': 'SC',
          'hue': 0.75,
          'role': 'Sous Chef',
          'experience': '5 years',
          'location': 'Manchester',
          'isVerified': false,
          'nationalityCode': 'CN',
        },
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

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
          const Text('Shortlist',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.tealLight,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text('${_candidates.length}',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.teal)),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.teal));
    }
    if (_candidates.isEmpty) {
      return _emptyState();
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
      itemCount: _candidates.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: _candidateCard(_candidates[i]),
      ),
    );
  }

  Widget _candidateCard(Map<String, dynamic> c) {
    return GestureDetector(
      onTap: () {
        // Navigate to candidate profile placeholder
      },
      child: Container(
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
        child: Row(
          children: [
            _avatar(c['initials'] ?? '--', c['hue'] ?? 0.5, 48),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(c['name'] ?? '',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.charcoal)),
                      // Flag placeholder
                    ],
                  ),
                  if (c['role'] != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(c['role'],
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.secondary)),
                  ],
                  Row(
                    children: [
                      if (c['experience'] != null)
                        Text(c['experience'],
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.tertiary)),
                      if (c['location'] != null) ...[
                        Text(' \u00b7 ',
                            style: TextStyle(color: AppColors.tertiary)),
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
            const Icon(Icons.star, size: 14, color: AppColors.amber),
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
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.amber.withValues(alpha: 0.08),
              ),
              child:
                  const Icon(Icons.star_border, size: 24, color: AppColors.amber),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('No shortlisted candidates',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.charcoal)),
            const SizedBox(height: AppSpacing.sm),
            const Text(
                'Shortlist candidates from Nearby, Applicants, or search results.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.secondary)),
          ],
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
