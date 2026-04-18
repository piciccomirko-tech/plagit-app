import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plagit/core/city_helpers.dart';
import 'package:plagit/core/l10n_helpers.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/models/community_post.dart';

const _tealMain = Color(0xFF00B5B0);
const _bgMain = Color(0xFFF6F7F8);
const _cardBg = Color(0xFFFFFFFF);
const _surface = Color(0xFFF2F3F5);
const _charcoal = Color(0xFF1A1C24);
const _secondary = Color(0xFF707580);
const _tertiary = Color(0xFF9EA3AD);
const _amber = Color(0xFFFF9500);
const _verified = Color(0xFF34C759);
const _indigo = Color(0xFF5856D6);
const _purple = Color(0xFFAF52DE);

/// **Premium / unlocked** Post Insights bottom sheet — opened automatically
/// by `PostInsightsSheet.show()` when the viewer has Premium or is an Admin.
///
/// This is the *fully unlocked* experience: real viewer cards, type filters,
/// and the full set of analytics. The free / locked flow lives in
/// `post_insights_sheet.dart` and is intentionally kept as a separate file
/// so the two experiences can evolve independently.
///
/// All viewer data here is **mocked** (`_mockViewers`) until the backend
/// exposes a real "who viewed" feed. The aggregate metrics (top cities,
/// roles, viewer kinds) come from the same `PostInsights` source the free
/// sheet uses, so the numbers stay consistent across both versions.
class PostInsightsPremiumSheet extends StatefulWidget {
  final PostInsights insights;
  final CommunityPost post;
  final bool isAdmin;

  const PostInsightsPremiumSheet({
    super.key,
    required this.insights,
    required this.post,
    this.isAdmin = false,
  });

  static Future<void> show(
    BuildContext context, {
    required PostInsights insights,
    required CommunityPost post,
    bool isAdmin = false,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PostInsightsPremiumSheet(
        insights: insights,
        post: post,
        isAdmin: isAdmin,
      ),
    );
  }

  @override
  State<PostInsightsPremiumSheet> createState() => _PostInsightsPremiumSheetState();
}

// ─────────────────────────────────────────────
// VIEWER MODEL (mock)
// ─────────────────────────────────────────────

enum _ViewerType { business, candidate, recruiter, hiringManager }

extension _ViewerTypeX on _ViewerType {
  /// Locale-aware display label, routed through the shared
  /// `localizedViewerKind` helper so every surface agrees.
  String labelLocalized(BuildContext context) {
    final l = AppLocalizations.of(context);
    return switch (this) {
      _ViewerType.business => l.viewerKindBusiness,
      _ViewerType.candidate => l.viewerKindCandidate,
      _ViewerType.recruiter => l.viewerKindRecruiter,
      _ViewerType.hiringManager => l.viewerKindHiringManager,
    };
  }

  Color get color => switch (this) {
        _ViewerType.business => _indigo,
        _ViewerType.candidate => _tealMain,
        _ViewerType.recruiter => _amber,
        _ViewerType.hiringManager => _purple,
      };

  IconData get icon => switch (this) {
        _ViewerType.business => CupertinoIcons.building_2_fill,
        _ViewerType.candidate => CupertinoIcons.person_fill,
        _ViewerType.recruiter => CupertinoIcons.search,
        _ViewerType.hiringManager => CupertinoIcons.briefcase_fill,
      };
}

class _PremiumViewer {
  final String name;
  final String initials;
  final String role;
  final String? company;
  final String city;
  final bool verified;
  final String ago;
  final _ViewerType type;

  const _PremiumViewer({
    required this.name,
    required this.initials,
    required this.role,
    this.company,
    required this.city,
    required this.verified,
    required this.ago,
    required this.type,
  });
}

class _PostInsightsPremiumSheetState extends State<PostInsightsPremiumSheet> {
  // ── Mock viewer feed (premium-only data) ──
  static const List<_PremiumViewer> _mockViewers = [
    _PremiumViewer(
      name: 'The Ritz London',
      initials: 'RL',
      role: 'Luxury Hotel',
      company: 'Mayfair',
      city: 'London',
      verified: true,
      ago: '12m',
      type: _ViewerType.business,
    ),
    _PremiumViewer(
      name: 'Sofia Marchetti',
      initials: 'SM',
      role: 'Talent Lead',
      company: 'Marriott Group',
      city: 'Milan',
      verified: true,
      ago: '32m',
      type: _ViewerType.recruiter,
    ),
    _PremiumViewer(
      name: 'Marco Romano',
      initials: 'MR',
      role: 'Head Chef',
      company: null,
      city: 'London',
      verified: true,
      ago: '1h',
      type: _ViewerType.candidate,
    ),
    _PremiumViewer(
      name: "Claridge's HR",
      initials: 'CH',
      role: 'General Manager',
      company: "Claridge's",
      city: 'London',
      verified: true,
      ago: '2h',
      type: _ViewerType.hiringManager,
    ),
    _PremiumViewer(
      name: 'Nobu Group',
      initials: 'NG',
      role: 'Restaurant Group',
      company: 'Worldwide',
      city: 'Dubai',
      verified: true,
      ago: '3h',
      type: _ViewerType.business,
    ),
    _PremiumViewer(
      name: 'Emma Walker',
      initials: 'EW',
      role: 'Sommelier',
      company: null,
      city: 'Paris',
      verified: false,
      ago: '4h',
      type: _ViewerType.candidate,
    ),
    _PremiumViewer(
      name: 'Four Seasons Talent',
      initials: 'FS',
      role: 'Talent Acquisition',
      company: 'Four Seasons',
      city: 'Paris',
      verified: true,
      ago: '6h',
      type: _ViewerType.recruiter,
    ),
    _PremiumViewer(
      name: 'James Chen',
      initials: 'JC',
      role: 'F&B Director',
      company: 'Mandarin Oriental',
      city: 'Hong Kong',
      verified: true,
      ago: '8h',
      type: _ViewerType.hiringManager,
    ),
    _PremiumViewer(
      name: 'Carlo Rossi',
      initials: 'CR',
      role: 'Bartender',
      company: null,
      city: 'Rome',
      verified: true,
      ago: '10h',
      type: _ViewerType.candidate,
    ),
    _PremiumViewer(
      name: 'Kempinski Hotels',
      initials: 'KH',
      role: 'Hotel Group',
      company: 'Europe',
      city: 'Berlin',
      verified: true,
      ago: '14h',
      type: _ViewerType.business,
    ),
  ];

  static const List<({String label, _ViewerType? type})> _filters = [
    (label: 'All', type: null),
    (label: 'Businesses', type: _ViewerType.business),
    (label: 'Candidates', type: _ViewerType.candidate),
    (label: 'Recruiters', type: _ViewerType.recruiter),
    (label: 'Hiring Managers', type: _ViewerType.hiringManager),
  ];

  _ViewerType? _activeFilter;

  // ── Derived ──
  PostInsights get _insights => widget.insights;
  CommunityPost get _post => widget.post;
  int get _seed => _post.id.hashCode.abs();
  int get _businessViews => _insights.viewerKinds['Business'] ?? 0;
  int get _candidateViews => _insights.viewerKinds['Candidate'] ?? 0;

  int get _verifiedViewers {
    if (_insights.views == 0) return 0;
    final pct = 0.40 + ((_seed % 15) / 100.0);
    return (_insights.views * pct).round().clamp(1, _insights.views);
  }

  List<_PremiumViewer> get _filteredViewers {
    if (_activeFilter == null) return _mockViewers;
    return _mockViewers.where((v) => v.type == _activeFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPad = MediaQuery.of(context).padding.bottom + 24;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Container(
        height: screenHeight * 0.93,
        color: _bgMain,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 38,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D1D6),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 18),
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(bottom: bottomPad),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildOverviewCard(context),
                    const SizedBox(height: 16),
                    _buildViewerBreakdownCard(context),
                    const SizedBox(height: 16),
                    _buildRecentViewersSection(context),
                    const SizedBox(height: 16),
                    _buildRolesCard(context),
                    if (_insights.topCities.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildLocationsCard(context),
                    ],
                    const SizedBox(height: 16),
                    _buildPremiumActiveFooter(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context).postInsightsTitle,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                        color: _charcoal,
                        letterSpacing: -0.3,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: _amber.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.star_fill,
                            size: 9,
                            color: _amber.withValues(alpha: 0.90),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.isAdmin ? AppLocalizations.of(context).badgeAdmin : AppLocalizations.of(context).badgePro,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: _amber.withValues(alpha: 0.90),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  AppLocalizations.of(context).fullViewerAccessLine,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: _tertiary.withValues(alpha: 0.90),
                    letterSpacing: -0.05,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: Color(0xFFD9DBE0),
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.xmark, size: 11, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // OVERVIEW CARD
  // ─────────────────────────────────────────

  Widget _buildOverviewCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF3F4F7), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.014),
              blurRadius: 14,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _statBox(
              icon: CupertinoIcons.eye_fill,
              color: _tealMain,
              label: AppLocalizations.of(context).totalViews,
              value: _insights.views,
            ),
            _statBox(
              icon: CupertinoIcons.checkmark_seal_fill,
              color: _verified,
              label: AppLocalizations.of(context).verified,
              value: _verifiedViewers,
            ),
            _statBox(
              icon: CupertinoIcons.building_2_fill,
              color: _indigo,
              label: AppLocalizations.of(context).businesses,
              value: _businessViews,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBox({
    required IconData icon,
    required Color color,
    required String label,
    required int value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 11),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              color: _charcoal,
              letterSpacing: -0.55,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: _tertiary.withValues(alpha: 0.92),
              letterSpacing: -0.05,
            ),
          ),
        ],
      ),
    );
  }

  String _formatComma(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  // ─────────────────────────────────────────
  // VIEWER BREAKDOWN
  // ─────────────────────────────────────────

  Widget _buildViewerBreakdownCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        decoration: _cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(AppLocalizations.of(context).viewerBreakdown, CupertinoIcons.person_2_fill),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _breakdownBar(
                    label: AppLocalizations.of(context).candidates,
                    count: _candidateViews,
                    total: _insights.views,
                    color: _tealMain,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _breakdownBar(
                    label: AppLocalizations.of(context).businesses,
                    count: _businessViews,
                    total: _insights.views,
                    color: _indigo,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _breakdownBar({
    required String label,
    required int count,
    required int total,
    required Color color,
  }) {
    final pct = total > 0 ? (count / total).clamp(0.0, 1.0) : 0.0;
    final pctLabel = (pct * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
            color: _secondary.withValues(alpha: 0.95),
            letterSpacing: -0.1,
          ),
        ),
        const SizedBox(height: 9),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              Container(height: 7, color: _surface),
              FractionallySizedBox(
                widthFactor: pct,
                child: Container(height: 7, color: color.withValues(alpha: 0.95)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 9),
        Text(
          '${_formatComma(count)} ($pctLabel%)',
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
            color: _charcoal,
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  // RECENT VIEWERS — premium-only section with filters
  // ─────────────────────────────────────────

  Widget _buildRecentViewersSection(BuildContext context) {
    final viewers = _filteredViewers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
          child: Row(
            children: [
              const Icon(
                CupertinoIcons.clock_fill,
                size: 17,
                color: _tealMain,
              ),
              const SizedBox(width: 9),
              Text(
                AppLocalizations.of(context).recentViewers,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w400,
                  color: _charcoal,
                  letterSpacing: -0.25,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _amber.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.star_fill,
                      size: 8,
                      color: _amber.withValues(alpha: 0.90),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      AppLocalizations.of(context).badgePro,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: _amber.withValues(alpha: 0.90),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${viewers.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _tertiary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Filter chips ──
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            itemCount: _filters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final f = _filters[i];
              final selected = _activeFilter == f.type;
              final l = AppLocalizations.of(context);
              final label = switch (f.label) {
                'All' => l.filterAll,
                'Businesses' => l.viewerKindBusinessesPlural,
                'Candidates' => l.viewerKindCandidatesPlural,
                'Recruiters' => l.viewerKindRecruitersPlural,
                'Hiring Managers' => l.viewerKindHiringManagersPlural,
                _ => f.label,
              };
              return _filterChip(label, f.type, selected);
            },
          ),
        ),
        const SizedBox(height: 14),

        // ── Viewer cards ──
        if (viewers.isEmpty)
          _emptyFilterState(context)
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Container(
              decoration: _cardDecoration,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  for (int i = 0; i < viewers.length; i++) ...[
                    _viewerRow(context, viewers[i]),
                    if (i != viewers.length - 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        child: Divider(height: 0.5, color: Color(0xFFF1F2F5)),
                      ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _filterChip(String label, _ViewerType? type, bool selected) {
    final accent = type?.color ?? _tealMain;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = type),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.10) : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected
                ? accent.withValues(alpha: 0.40)
                : const Color(0xFFE9EBEF),
            width: 0.6,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? accent : _secondary,
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }

  Widget _emptyFilterState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: _cardDecoration,
        child: Center(
          child: Text(
            AppLocalizations.of(context).noViewersInCategory,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _tertiary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _viewerRow(BuildContext context, _PremiumViewer v) {
    final localizedRole = localizedJobRole(context, v.role);
    final localizedCompany = v.company == null
        ? null
        : localizedVenueName(context, v.company!);
    final roleLine = localizedCompany == null
        ? localizedRole
        : '$localizedRole · $localizedCompany';
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar (initials) ──
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: v.type.color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              v.initials,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: v.type.color.withValues(alpha: 0.90),
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ── Body ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        localizedVenueName(context, v.name),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _charcoal,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    if (v.verified) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        CupertinoIcons.checkmark_seal_fill,
                        size: 12,
                        color: _verified,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  roleLine,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _secondary,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.location_solid,
                      size: 10,
                      color: _tertiary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      localizedCity(context, v.city),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _tertiary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 2,
                      height: 2,
                      decoration: const BoxDecoration(
                        color: _tertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      v.ago,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: _tertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // ── Type pill ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: v.type.color.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  v.type.icon,
                  size: 9,
                  color: v.type.color.withValues(alpha: 0.90),
                ),
                const SizedBox(width: 4),
                Text(
                  v.type.labelLocalized(context),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: v.type.color.withValues(alpha: 0.95),
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // ROLES — Viewers by Role
  // ─────────────────────────────────────────

  Widget _buildRolesCard(BuildContext context) {
    final roles = _insights.audienceRoles;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
        decoration: _cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(AppLocalizations.of(context).viewersByRole, CupertinoIcons.briefcase_fill),
            const SizedBox(height: 10),
            if (roles.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  AppLocalizations.of(context).notEnoughDataYet,
                  style: const TextStyle(fontSize: 11, color: _tertiary),
                ),
              )
            else
              ...roles.map(
                (r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        _iconForRole(r.role),
                        size: 17,
                        color: _tealMain,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          localizedJobRole(context, r.role),
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w400,
                            color: _charcoal,
                            letterSpacing: -0.25,
                          ),
                        ),
                      ),
                      Text(
                        _formatComma(r.count),
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w400,
                          color: _charcoal,
                          letterSpacing: -0.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  IconData _iconForRole(String role) {
    final r = role.toLowerCase();
    if (r.contains('chef')) return CupertinoIcons.flame_fill;
    if (r.contains('waiter') || r.contains('server')) return Icons.room_service;
    if (r.contains('bartender') || r.contains('cocktail')) return Icons.local_bar;
    if (r.contains('sommelier') || r.contains('wine')) return Icons.wine_bar;
    if (r.contains('host') || r.contains('concierge')) return CupertinoIcons.bell_fill;
    if (r.contains('manager')) return CupertinoIcons.person_badge_plus_fill;
    if (r.contains('recruiter') || r.contains('hr')) return CupertinoIcons.person_2_square_stack_fill;
    if (r.contains('hotel')) return CupertinoIcons.building_2_fill;
    if (r.contains('restaurant')) return Icons.restaurant_menu;
    if (r.contains('cafe')) return Icons.local_cafe;
    if (r.contains('catering')) return Icons.set_meal;
    return CupertinoIcons.briefcase_fill;
  }

  // ─────────────────────────────────────────
  // LOCATIONS
  // ─────────────────────────────────────────

  Widget _buildLocationsCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 6),
        decoration: _cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(AppLocalizations.of(context).topLocations, CupertinoIcons.location_solid),
            const SizedBox(height: 8),
            ..._insights.topCities.map(
              (c) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        localizedCity(context, c.city),
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w400,
                          color: _charcoal,
                          letterSpacing: -0.25,
                        ),
                      ),
                    ),
                    Text(
                      _formatComma(c.count),
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w400,
                        color: _charcoal,
                        letterSpacing: -0.25,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 3),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // PREMIUM ACTIVE FOOTER (replaces upsell)
  // ─────────────────────────────────────────

  Widget _buildPremiumActiveFooter(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: _tealMain.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _tealMain.withValues(alpha: 0.16), width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: _tealMain.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.checkmark_seal_fill,
                size: 15,
                color: _tealMain.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.premiumActiveBadge,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _charcoal,
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l.fullInsightsUnlocked,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: _secondary,
                      height: 1.3,
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

  // ─────────────────────────────────────────
  // SHARED HELPERS
  // ─────────────────────────────────────────

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 17, color: _tealMain),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w400,
            color: _charcoal,
            letterSpacing: -0.25,
          ),
        ),
      ],
    );
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F7), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.014),
            blurRadius: 14,
            offset: const Offset(0, 2),
          ),
        ],
      );
}
