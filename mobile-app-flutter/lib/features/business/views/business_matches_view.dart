import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';

/// Business Matches screen — candidates matching a specific job.
/// Mirrors BusinessMatchesView.swift with mock data.
class BusinessMatchesView extends StatefulWidget {
  final String jobId;
  final String jobTitle;
  const BusinessMatchesView(
      {super.key, required this.jobId, required this.jobTitle});

  @override
  State<BusinessMatchesView> createState() => _BusinessMatchesViewState();
}

class _BusinessMatchesViewState extends State<BusinessMatchesView> {
  bool _loading = true;
  String? _error;
  final Set<String> _dismissed = {};

  final List<Map<String, dynamic>> _matches = [];

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
      _matches
        ..clear()
        ..addAll(_mockMatches());
      _loading = false;
    });
  }

  List<Map<String, dynamic>> _mockMatches() => [
        {
          'id': 'm1',
          'name': 'Marco Rossi',
          'initials': 'MR',
          'hue': 0.55,
          'role': 'Senior Chef',
          'jobType': 'Full-time',
          'location': 'London',
          'distanceKm': 3.2,
          'experience': '8 years',
          'isVerified': true,
          'availableToRelocate': false,
        },
        {
          'id': 'm2',
          'name': 'Sophie Chen',
          'initials': 'SC',
          'hue': 0.75,
          'role': 'Sous Chef',
          'jobType': 'Full-time',
          'location': 'Manchester',
          'distanceKm': 5.1,
          'experience': '5 years',
          'isVerified': false,
          'availableToRelocate': true,
        },
        {
          'id': 'm3',
          'name': 'Ahmed Hassan',
          'initials': 'AH',
          'hue': 0.35,
          'role': 'Head Chef',
          'jobType': 'Part-time',
          'location': 'Birmingham',
          'distanceKm': 8.7,
          'experience': '12 years',
          'isVerified': true,
          'availableToRelocate': false,
        },
      ];

  List<Map<String, dynamic>> get _visible =>
      _matches.where((c) => !_dismissed.contains(c['id'])).toList();

  void _deny(String id) {
    setState(() => _dismissed.add(id));
  }

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
                child: Icon(Icons.chevron_left,
                    size: 22, color: AppColors.charcoal)),
          ),
          const Spacer(),
          const Text('Your Matches',
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
            const Icon(Icons.warning_amber_rounded,
                size: 28, color: AppColors.tertiary),
            const SizedBox(height: AppSpacing.md),
            Text(_error!,
                style:
                    const TextStyle(fontSize: 12, color: AppColors.secondary)),
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: _load,
              child: const Text('Retry',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.teal)),
            ),
          ],
        ),
      );
    }
    if (_visible.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 36, color: AppColors.tertiary),
            const SizedBox(height: AppSpacing.lg),
            const Text('No matches yet',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoal)),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Text(
                  'Matches will appear here when candidates match your job requirements.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14, color: AppColors.secondary)),
            ),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
                '${_visible.length} matching candidates \u2014 ${widget.jobTitle}',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondary)),
          ),
          const SizedBox(height: AppSpacing.md),
          ..._visible.map((c) => _candidateCard(c)),
        ],
      ),
    );
  }

  Widget _candidateCard(Map<String, dynamic> c) {
    final id = c['id'] as String;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.charcoal)),
                      if (c['role'] != null)
                        Text(c['role'],
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.secondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.online.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified,
                          size: 12, color: AppColors.online),
                      const SizedBox(width: AppSpacing.xs),
                      Text('Match',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.online)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Tags
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                if (c['role'] != null)
                  _tagPill(c['role'], Icons.work, AppColors.indigo),
                if (c['jobType'] != null)
                  _tagPill(c['jobType'], Icons.access_time, AppColors.teal),
                if (c['location'] != null)
                  _tagPill(c['location'], Icons.place, AppColors.secondary),
                if (c['distanceKm'] != null)
                  _tagPill(
                      '${(c['distanceKm'] as double).toStringAsFixed(1)} km',
                      Icons.near_me,
                      AppColors.amber),
                if (c['availableToRelocate'] == true)
                  _tagPill('Relocate', Icons.public, AppColors.indigo),
              ],
            ),

            if (c['experience'] != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(c['experience'],
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.secondary)),
            ],

            const SizedBox(height: AppSpacing.md),

            // Actions
            Row(
              children: [
                _actionChip('Accept', Icons.check, AppColors.teal, true,
                    () {}),
                const SizedBox(width: AppSpacing.md),
                _actionChip(
                    'Deny', Icons.close, AppColors.urgent, false, () => _deny(id)),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: const Icon(Icons.chat_bubble_outline,
                      size: 14, color: AppColors.indigo),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tagPill(String text, IconData icon, Color color) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: color),
          const SizedBox(width: 3),
          Text(text,
              style: TextStyle(fontSize: 11, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _actionChip(
      String label, IconData icon, Color color, bool filled, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl, vertical: AppSpacing.sm + 2),
        decoration: BoxDecoration(
          color: filled ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 12, color: filled ? Colors.white : color),
            const SizedBox(width: AppSpacing.xs),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: filled ? Colors.white : color)),
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
