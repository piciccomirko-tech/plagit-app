import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';

/// Business Quick Plug — Tinder-style candidate discovery.
/// Mirrors BusinessQuickPlugView.swift with swipe card deck.
class BusinessQuickPlugView extends StatefulWidget {
  const BusinessQuickPlugView({super.key});

  @override
  State<BusinessQuickPlugView> createState() => _BusinessQuickPlugViewState();
}

class _BusinessQuickPlugViewState extends State<BusinessQuickPlugView> {
  bool _loading = true;
  int _currentIndex = 0;
  double _dragX = 0;
  String? _swipeLabel; // 'PASS' or 'INTERESTED'

  // Refine state
  double _filterRadius = 15;
  String _filterJobType = 'All';
  final List<String> _jobTypes = ['All', 'Full-time', 'Part-time', 'Flexible'];

  List<Map<String, dynamic>> _candidates = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _candidates = _mockCandidates();
      _currentIndex = 0;
      _loading = false;
    });
  }

  List<Map<String, dynamic>> _mockCandidates() => [
        {
          'id': 'qp1',
          'name': 'Elena Petrova',
          'initials': 'EP',
          'hue': 0.70,
          'role': 'Sous Chef',
          'location': 'Mayfair, London',
          'distanceKm': 2.4,
          'experience': '7 years',
          'jobType': 'Full-time',
          'isVerified': true,
          'availableToRelocate': false,
        },
        {
          'id': 'qp2',
          'name': 'James O\'Connor',
          'initials': 'JO',
          'hue': 0.20,
          'role': 'Bartender',
          'location': 'Covent Garden, London',
          'distanceKm': 1.8,
          'experience': '4 years',
          'jobType': 'Part-time',
          'isVerified': false,
          'availableToRelocate': true,
        },
        {
          'id': 'qp3',
          'name': 'Yuki Nakamura',
          'initials': 'YN',
          'hue': 0.50,
          'role': 'Head Chef',
          'location': 'Chelsea, London',
          'distanceKm': 5.3,
          'experience': '12 years',
          'jobType': 'Full-time',
          'isVerified': true,
          'availableToRelocate': false,
        },
        {
          'id': 'qp4',
          'name': 'Fatima Al-Rashid',
          'initials': 'FA',
          'hue': 0.90,
          'role': 'Restaurant Manager',
          'location': 'Knightsbridge, London',
          'distanceKm': 3.7,
          'experience': '9 years',
          'jobType': 'Full-time',
          'isVerified': true,
          'availableToRelocate': false,
        },
      ];

  bool get _done => _currentIndex >= _candidates.length;

  Map<String, dynamic>? get _front =>
      _done ? null : _candidates[_currentIndex];

  void _completeSwipe(bool right) {
    setState(() {
      _dragX = 0;
      _swipeLabel = null;
      _currentIndex++;
    });
  }

  void _showRefine() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => _RefineSheet(
        radius: _filterRadius,
        jobType: _filterJobType,
        jobTypes: _jobTypes,
        onApply: (r, jt) {
          Navigator.pop(context);
          setState(() {
            _filterRadius = r;
            _filterJobType = jt;
          });
          _load();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Expanded(
              child: _loading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.purple))
                  : _candidates.isEmpty
                      ? _emptyState()
                      : _done
                          ? _doneState()
                          : _cardArea(),
            ),
            if (!_loading && _candidates.isNotEmpty && !_done)
              _actionButtons(),
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bolt, size: 14, color: AppColors.purple),
              const SizedBox(width: AppSpacing.sm),
              const Text('Quick Plug',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal)),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: _showRefine,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.tune, size: 16, color: AppColors.purple),
                const SizedBox(width: 4),
                const Text('Refine',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.purple)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Card Area ──
  Widget _cardArea() {
    final front = _front;
    if (front == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: GestureDetector(
        onHorizontalDragUpdate: (d) {
          setState(() {
            _dragX += d.delta.dx;
            if (_dragX > 40) {
              _swipeLabel = 'INTERESTED';
            } else if (_dragX < -40) {
              _swipeLabel = 'PASS';
            } else {
              _swipeLabel = null;
            }
          });
        },
        onHorizontalDragEnd: (d) {
          if (_dragX.abs() > 120) {
            _completeSwipe(_dragX > 0);
          } else {
            setState(() {
              _dragX = 0;
              _swipeLabel = null;
            });
          }
        },
        child: Transform.translate(
          offset: Offset(_dragX, 0),
          child: Transform.rotate(
            angle: _dragX / 1500,
            child: Stack(
              children: [
                _candidateCard(front),
                if (_swipeLabel == 'PASS')
                  Positioned(
                    top: AppSpacing.xl,
                    left: AppSpacing.xl,
                    child: Opacity(
                      opacity: (_dragX.abs() / 120).clamp(0, 1),
                      child: const Text('PASS',
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: AppColors.urgent)),
                    ),
                  ),
                if (_swipeLabel == 'INTERESTED')
                  Positioned(
                    top: AppSpacing.xl,
                    right: AppSpacing.xl,
                    child: Opacity(
                      opacity: (_dragX.abs() / 120).clamp(0, 1),
                      child: const Text('INTERESTED',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.online)),
                    ),
                  ),
                // Tap hint
                Positioned(
                  top: AppSpacing.lg,
                  right: AppSpacing.lg,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: const Text('Tap for profile',
                        style: TextStyle(fontSize: 11, color: Colors.white60)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _candidateCard(Map<String, dynamic> c) {
    final hue = (c['hue'] as double?) ?? 0.5;
    final screenH = MediaQuery.of(context).size.height;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl + 4),
      child: Container(
        width: double.infinity,
        height: screenH * 0.58,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              HSLColor.fromAHSL(1, hue * 360, 0.20, 0.92).toColor(),
              HSLColor.fromAHSL(1, hue * 360, 0.15, 0.85).toColor(),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Stack(
          children: [
            // Large initials placeholder
            Center(
              child: Text(
                  c['initials'] ??
                      (c['name'] as String? ?? '').substring(0, 2).toUpperCase(),
                  style: TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.w700,
                      color: HSLColor.fromAHSL(1, hue * 360, 0.35, 0.55)
                          .toColor())),
            ),
            // Bottom gradient overlay with info
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.25),
                      Colors.black.withValues(alpha: 0.75),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(c['name'] ?? '',
                            style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        if (c['isVerified'] == true) ...[
                          const SizedBox(width: AppSpacing.sm),
                          const Icon(Icons.verified,
                              size: 16, color: AppColors.teal),
                        ],
                      ],
                    ),
                    if (c['role'] != null)
                      Text(c['role'],
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.92))),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        if (c['location'] != null) ...[
                          Icon(Icons.place,
                              size: 12,
                              color: Colors.white.withValues(alpha: 0.7)),
                          const SizedBox(width: AppSpacing.xs),
                          Text(c['location'],
                              style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      Colors.white.withValues(alpha: 0.8))),
                          const SizedBox(width: AppSpacing.lg),
                        ],
                        if (c['distanceKm'] != null) ...[
                          const Icon(Icons.near_me,
                              size: 11, color: AppColors.teal),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                              '${(c['distanceKm'] as double).toStringAsFixed(1)} km',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      Colors.white.withValues(alpha: 0.9))),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      children: [
                        if (c['jobType'] != null) _badge(c['jobType']),
                        if (c['experience'] != null) _badge(c['experience']),
                        if (c['availableToRelocate'] == true)
                          _badge('Open to Relocate'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(text,
          style: const TextStyle(fontSize: 11, color: Colors.white)),
    );
  }

  // ── Action Buttons ──
  Widget _actionButtons() {
    return Padding(
      padding: const EdgeInsets.only(
          top: AppSpacing.lg, bottom: AppSpacing.xxl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pass
          GestureDetector(
            onTap: () => _completeSwipe(false),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.urgent.withValues(alpha: 0.1),
              ),
              child: const Icon(Icons.close,
                  size: 22, color: AppColors.urgent),
            ),
          ),
          const SizedBox(width: AppSpacing.xxl),
          // Interested
          GestureDetector(
            onTap: () => _completeSwipe(true),
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.online,
                    AppColors.online.withValues(alpha: 0.8)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.online.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.check,
                  size: 28, color: Colors.white),
            ),
          ),
          const SizedBox(width: AppSpacing.xxl),
          // Profile
          GestureDetector(
            onTap: () {
              // Tap to view profile placeholder
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.teal.withValues(alpha: 0.1),
              ),
              child: const Icon(Icons.person,
                  size: 20, color: AppColors.teal),
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty state ──
  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.purple.withValues(alpha: 0.1),
              ),
              child: const Icon(Icons.bolt, size: 28, color: AppColors.purple),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('No candidates found',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoal)),
            const SizedBox(height: AppSpacing.sm),
            const Text(
                'Try adjusting your Refine filters or expanding the search radius.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.secondary)),
            const SizedBox(height: AppSpacing.lg),
            GestureDetector(
              onTap: _showRefine,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl, vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.purple,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: const Text('Open Refine',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Done state ──
  Widget _doneState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.online.withValues(alpha: 0.1),
              ),
              child: const Icon(Icons.check_circle,
                  size: 28, color: AppColors.online),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('All caught up!',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoal)),
            const SizedBox(height: AppSpacing.sm),
            Text(
                'You\'ve reviewed all ${_candidates.length} candidates. Adjust filters to discover more.',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 14, color: AppColors.secondary)),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _showRefine,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxl, vertical: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.purple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: const Text('Refine',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.purple)),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                GestureDetector(
                  onTap: () => setState(() => _currentIndex = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxl, vertical: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.purple,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: const Text('Start Over',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white)),
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

// ── Refine bottom sheet ──
class _RefineSheet extends StatefulWidget {
  final double radius;
  final String jobType;
  final List<String> jobTypes;
  final void Function(double radius, String jobType) onApply;

  const _RefineSheet({
    required this.radius,
    required this.jobType,
    required this.jobTypes,
    required this.onApply,
  });

  @override
  State<_RefineSheet> createState() => _RefineSheetState();
}

class _RefineSheetState extends State<_RefineSheet> {
  late double _radius;
  late String _jobType;

  @override
  void initState() {
    super.initState();
    _radius = widget.radius;
    _jobType = widget.jobType;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Refine Search',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal)),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _radius = 15;
                    _jobType = 'All';
                  });
                },
                child: const Text('Reset',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.urgent)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Distance
          Text('DISTANCE',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondary,
                  letterSpacing: 0.5)),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text('${_radius.toInt()} km',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.teal)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Slider(
                  value: _radius,
                  min: 1,
                  max: 50,
                  divisions: 49,
                  activeColor: AppColors.teal,
                  onChanged: (v) => setState(() => _radius = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),

          // Job Type
          Text('JOB TYPE',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondary,
                  letterSpacing: 0.5)),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            children: widget.jobTypes.map((jt) {
              final active = _jobType == jt;
              return GestureDetector(
                onTap: () => setState(() => _jobType = jt),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.sm + 2),
                  decoration: BoxDecoration(
                    color: active ? AppColors.teal : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: active
                        ? null
                        : Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Text(jt,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: active ? Colors.white : AppColors.secondary)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Apply
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () => widget.onApply(_radius, _jobType),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                alignment: Alignment.center,
                child: const Text('Apply',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
