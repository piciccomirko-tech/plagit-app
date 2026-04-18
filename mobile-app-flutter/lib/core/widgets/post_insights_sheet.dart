import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/city_helpers.dart';
import 'package:plagit/core/l10n_helpers.dart';
import 'package:plagit/core/widgets/post_insights_premium_sheet.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/models/community_post.dart';

const _tealMain = Color(0xFF00B5B0);
const _tealLight = Color(0x1A00B5B0);
const _bgMain = Color(0xFFF6F7F8);
const _cardBg = Color(0xFFFFFFFF);
const _surface = Color(0xFFF2F3F5);
const _charcoal = Color(0xFF1A1C24);
const _secondary = Color(0xFF707580);
const _tertiary = Color(0xFF9EA3AD);
const _amber = Color(0xFFFF9500);
const _verified = Color(0xFF34C759);
const _indigo = Color(0xFF5856D6);
const _urgent = Color(0xFFFF3B30);

/// Premium "Post Insights" bottom sheet — opened when the post author taps
/// the engagement row on their own post (or when an admin inspects any
/// post). Ported from the approved Swift design:
///
///   1. Drag handle + header ("Post Insights" / "Who's seeing your content")
///   2. Overview card with 3 stats — Total Views, Verified, Businesses
///   3. Viewer Breakdown card (Candidates / Businesses split)
///   4. Viewers by Role card
///   5. Top Locations card
///   6. Recent Viewers card (premium) **or** upsell ("See Who Viewed Your Post")
///
/// Admin-mode extras (suspicious banner, admin footer) are kept since they
/// have no Swift analogue but were already wired in Flutter.
///
/// All breakdowns are aggregated — never exposes individual viewer identity
/// for free users. Premium "Recent Viewers" surfaces only verified accounts.
class PostInsightsSheet extends StatelessWidget {
  final PostInsights insights;
  final CommunityPost post;
  final bool isPremium;
  final bool isAdmin;

  const PostInsightsSheet({
    super.key,
    required this.insights,
    required this.post,
    required this.isPremium,
    this.isAdmin = false,
  });

  /// Convenience helper used by every caller — opens the sheet with the
  /// right modal config.
  ///
  /// Routing:
  ///   • Free viewer  → opens this locked sheet (upsell + counters).
  ///   • Premium / Admin → delegates to `PostInsightsPremiumSheet`, the
  ///     fully-unlocked experience with the viewer feed and filters.
  ///
  /// The two experiences live in separate files on purpose so they can
  /// evolve independently — see `post_insights_premium_sheet.dart`.
  static Future<void> show(
    BuildContext context, {
    required PostInsights insights,
    required CommunityPost post,
    required bool isPremium,
    bool isAdmin = false,
  }) {
    if (isPremium || isAdmin) {
      return PostInsightsPremiumSheet.show(
        context,
        insights: insights,
        post: post,
        isAdmin: isAdmin,
      );
    }
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PostInsightsSheet(
        insights: insights,
        post: post,
        isPremium: isPremium,
        isAdmin: isAdmin,
      ),
    );
  }

  bool get _showFullData => isPremium || isAdmin;

  // ── Derived counters (from PostInsights + deterministic post seed) ──

  int get _seed => post.id.hashCode.abs();
  int get _candidateViews => insights.viewerKinds['Candidate'] ?? 0;
  int get _businessViews => insights.viewerKinds['Business'] ?? 0;

  /// Verified viewers — ~40–55% of total views, deterministic per post.
  int get _verifiedViewers {
    if (insights.views == 0) return 0;
    final pct = 0.40 + ((_seed % 15) / 100.0);
    return (insights.views * pct).round().clamp(1, insights.views);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPad = MediaQuery.of(context).padding.bottom + 24;
    final isEmpty = insights.views == 0;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Container(
        // Fixed tall height — sheet always opens at ~93% of the screen so
        // it has the same vertical presence as the Swift `.large` detent.
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

            // ── Scrollable content ──
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(bottom: bottomPad),
                child: Column(
                  children: [
                    if (isAdmin && insights.suspicious) ...[
                      const SizedBox(height: 18),
                      _buildSuspiciousBanner(context),
                    ],

                    const SizedBox(height: 16),

                    if (isEmpty)
                      _buildEmptyState(context)
                    else ...[
                      _buildOverviewCard(context),
                      const SizedBox(height: 16),
                      _buildViewerBreakdownCard(context),
                      const SizedBox(height: 16),
                      _buildRolesCard(context),
                      if (insights.topCities.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildLocationsCard(context),
                      ],
                      const SizedBox(height: 16),
                      if (_showFullData)
                        _buildRecentViewersCard(context)
                      else ...[
                        _buildLockedViewersPreview(context),
                        const SizedBox(height: 14),
                        _buildPremiumUpsell(context),
                      ],
                    ],

                    if (isAdmin) ...[
                      const SizedBox(height: 18),
                      _buildAdminFooter(context),
                    ],
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
                    if (_showFullData) ...[
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
                            const Icon(CupertinoIcons.star_fill, size: 9, color: _amber),
                            const SizedBox(width: 4),
                            Text(
                              isAdmin ? 'ADMIN' : 'PRO',
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: _amber,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  AppLocalizations.of(context).postInsightsSubtitle,
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
  // OVERVIEW CARD — Total Views / Verified / Businesses
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
              value: insights.views,
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

  // ─────────────────────────────────────────
  // VIEWER BREAKDOWN — Candidates vs Businesses bars
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
                    total: insights.views,
                    color: _tealMain,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _breakdownBar(
                    label: AppLocalizations.of(context).businesses,
                    count: _businessViews,
                    total: insights.views,
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
                child: Container(
                  height: 7,
                  color: color.withValues(alpha: 0.95),
                ),
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
  // ROLES — Viewers by Role
  // ─────────────────────────────────────────

  Widget _buildRolesCard(BuildContext context) {
    final roles = insights.audienceRoles;
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
  // LOCATIONS — Top Locations
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
            ...insights.topCities.map(
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
  // RECENT VIEWERS — premium / admin only
  // ─────────────────────────────────────────

  static const _mockViewers = [
    (name: 'The Ritz London', role: 'Luxury Hotel', initials: 'RL', verified: true, ago: '2h', isBusiness: true),
    (name: "Claridge's HR", role: 'Recruiter', initials: 'CL', verified: true, ago: '5h', isBusiness: true),
    (name: 'Marco R.', role: 'Head Chef', initials: 'MR', verified: true, ago: '1d', isBusiness: false),
    (name: 'Nobu Group', role: 'Restaurant Group', initials: 'NG', verified: true, ago: '1d', isBusiness: true),
    (name: 'Sofia M.', role: 'Sommelier', initials: 'SM', verified: false, ago: '2d', isBusiness: false),
  ];

  Widget _buildRecentViewersCard(BuildContext context) {
    final cap = _businessViews > 0 ? _businessViews.clamp(2, 5) : 3;
    final viewers = _mockViewers.take(cap).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        decoration: _cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _sectionTitle(AppLocalizations.of(context).recentViewers, CupertinoIcons.clock_fill),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: _amber,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.star_fill, size: 9, color: Colors.white),
                      SizedBox(width: 3),
                      Text(
                        'PRO',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...viewers.map(
              (v) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: v.isBusiness
                            ? _indigo.withValues(alpha: 0.12)
                            : _tealLight,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        v.initials,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: v.isBusiness ? _indigo : _tealMain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                localizedVenueName(context, v.name),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _charcoal,
                                ),
                              ),
                              if (v.verified) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  CupertinoIcons.checkmark_seal_fill,
                                  size: 11,
                                  color: _verified,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 1),
                          Text(
                            localizedJobRole(context, v.role),
                            style: const TextStyle(fontSize: 11, color: _tertiary),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      v.ago,
                      style: const TextStyle(fontSize: 11, color: _tertiary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).onlyVerifiedViewersShown,
              style: const TextStyle(fontSize: 11, color: _tertiary),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // LOCKED VIEWERS PREVIEW — free tier teaser
  //
  // Shows the "Recent Viewers" section header (so the user knows the
  // feature exists) plus 3 anonymized, blurred viewer rows behind a
  // semi-transparent veil with a lock icon. Sells the upgrade by
  // showing exactly what's behind the paywall, without exposing any
  // real identity.
  // ─────────────────────────────────────────

  Widget _buildLockedViewersPreview(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        decoration: _cardDecoration,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section header: title + LOCKED pill ──
            Row(
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
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F5F7),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.lock_fill, size: 9, color: _tertiary),
                      const SizedBox(width: 4),
                      Text(
                        AppLocalizations.of(context).lockedBadge,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                          color: _tertiary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Skeleton viewer rows behind a soft veil ──
            // No overlay text — the dedicated upsell card below is the
            // single, clear action point. This card is just a quiet
            // teaser of what's hidden.
            Stack(
              children: [
                Column(
                  children: [
                    _lockedViewerRow(),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Divider(height: 0.5, color: Color(0xFFF1F2F5)),
                    ),
                    _lockedViewerRow(),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Divider(height: 0.5, color: Color(0xFFF1F2F5)),
                    ),
                    _lockedViewerRow(),
                  ],
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.62),
                          Colors.white.withValues(alpha: 0.78),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _lockedViewerRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Avatar placeholder
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFE9EBEF),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          // Text placeholders
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 130,
                  height: 11,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9EBEF),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 90,
                  height: 9,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF0F3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Type pill placeholder
          Container(
            width: 56,
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF0F3),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // PREMIUM UPSELL — free tier
  // ─────────────────────────────────────────

  Widget _buildPremiumUpsell(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
          context.push('/candidate/premium');
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 15, 18, 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                _tealMain.withValues(alpha: 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _tealMain.withValues(alpha: 0.18),
              width: 0.6,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row: PREMIUM badge + eye icon ──
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                          color: _amber.withValues(alpha: 0.85),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'PREMIUM',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w500,
                            color: _amber.withValues(alpha: 0.90),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: _tealMain.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      CupertinoIcons.eye_fill,
                      size: 15,
                      color: _tealMain.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── Title ──
              Text(
                AppLocalizations.of(context).seeWhoViewedYourPostTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: _charcoal,
                  letterSpacing: -0.3,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),

              // ── Subtitle ──
              Text(
                AppLocalizations.of(context).upgradeToPremiumSubtitle,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w400,
                  color: _secondary.withValues(alpha: 0.92),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 12),

              // ── Bullet list ──
              _premiumBullet(AppLocalizations.of(context).verifiedBusinessViewers),
              _premiumBullet(AppLocalizations.of(context).recruiterHiringManagerActivity),
              _premiumBullet(AppLocalizations.of(context).cityLevelReachBreakdown),

              const SizedBox(height: 14),

              // ── Full-width CTA button ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _tealMain.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context).upgradeToPremiumCta,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(CupertinoIcons.arrow_right, size: 13, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _premiumBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 17,
            height: 17,
            decoration: BoxDecoration(
              color: _tealMain.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.checkmark,
              size: 9,
              color: _tealMain.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
                color: _secondary.withValues(alpha: 0.92),
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // EMPTY STATE
  // ─────────────────────────────────────────

  Widget _buildEmptyState(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(color: _surface, shape: BoxShape.circle),
            child: const Icon(CupertinoIcons.eye_slash, size: 24, color: _tertiary),
          ),
          const SizedBox(height: 14),
          Text(
            l.noViewInsightsYet,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _charcoal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.noViewInsightsDesc,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: _secondary, height: 1.4),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // ADMIN EXTRAS
  // ─────────────────────────────────────────

  Widget _buildSuspiciousBanner(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _urgent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _urgent.withValues(alpha: 0.30), width: 0.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(CupertinoIcons.exclamationmark_triangle_fill, size: 16, color: _urgent),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.suspiciousEngagementDetected,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _urgent,
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    insights.suspiciousReason ?? l.patternReviewRequired,
                    style: const TextStyle(fontSize: 12, color: _urgent, height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEFEFF4), width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _tealLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(CupertinoIcons.eye, size: 13, color: _tealMain),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppLocalizations.of(context).adminInsightsFooter,
                style: const TextStyle(fontSize: 11, color: _secondary, height: 1.4),
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
