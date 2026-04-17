import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/city_helpers.dart';
import 'package:plagit/core/widgets/premium_crown_badge.dart';
import 'package:plagit/core/widgets/profile_photo.dart';
import 'package:plagit/core/l10n_helpers.dart';
import 'package:plagit/core/widgets/search_screen.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/models/candidate_home_data.dart';
import 'package:plagit/models/candidate_profile.dart';
import 'package:plagit/models/interview.dart';
import 'package:plagit/models/job.dart';
import 'package:plagit/providers/candidate_providers.dart';
import 'package:plagit/providers/recent_searches_provider.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

// ═══════════════════════════════════════════════════════════════
// Theme — exact match with the Business dashboard
// ═══════════════════════════════════════════════════════════════
const _tealMain = Color(0xFF2BB8B0);
const _tealLight = Color(0x1A2BB8B0);
const _bgMain = Color(0xFFF6F7F8);
const _cardBg = Color(0xFFFFFFFF);
const _charcoal = Color(0xFF1A1C24);
const _secondary = Color(0xFF707580);
const _tertiary = Color(0xFF9EA3AD);
const _green = Color(0xFF34C759);
const _amber = Color(0xFFFF9500);
const _indigo = Color(0xFF5856D6);
const _purple = Color(0xFFAF52DE);

BoxShadow get _subtleShadow => BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 10,
      offset: const Offset(0, 3),
    );

class WorkerHomeView extends StatefulWidget {
  const WorkerHomeView({super.key});

  @override
  State<WorkerHomeView> createState() => _WorkerHomeViewState();
}

class _WorkerHomeViewState extends State<WorkerHomeView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CandidateHomeProvider>().load();
      context.read<CandidateJobsProvider>().load();
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  String _greeting(BuildContext context) {
    final l = AppLocalizations.of(context);
    final h = DateTime.now().hour;
    if (h < 12) return l.goodMorning;
    if (h < 17) return l.goodAfternoon;
    return l.goodEvening;
  }

  /// Computed savedJobs count from the jobs provider — the home model itself
  /// doesn't carry it because saved-job state is mutable per session.
  int _savedJobsCount(BuildContext context) =>
      context.watch<CandidateJobsProvider>().savedIds.length;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CandidateHomeProvider>();
    // Single source of truth for premium state — the auth provider is
    // updated immediately when a purchase or restore completes, and
    // notifies listeners, so the home reacts without needing a home
    // data refetch. Do NOT read premium from `data.profile` — that
    // snapshot is loaded once and stays stale across purchases.
    final isPremium = context.watch<CandidateAuthProvider>().isPremium;

    if (provider.loading) {
      return Container(
        color: _bgMain,
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const CircularProgressIndicator(color: _tealMain),
            const SizedBox(height: 12),
            Text(AppLocalizations.of(context).loadingDashboard, style: const TextStyle(fontSize: 13, color: _secondary)),
          ]),
        ),
      );
    }

    if (provider.error != null) {
      return Container(
        color: _bgMain,
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(CupertinoIcons.wifi_slash, size: 40, color: _tertiary),
            const SizedBox(height: 16),
            Text(provider.error!, style: const TextStyle(fontSize: 14, color: _secondary), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => context.read<CandidateHomeProvider>().load(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(color: _tealMain, borderRadius: BorderRadius.circular(100)),
                child: Text(AppLocalizations.of(context).tryAgainCta, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)),
              ),
            ),
          ]),
        ),
      );
    }

    final data = provider.data;
    if (data == null) {
      return Container(color: _bgMain, child: const Center(child: CircularProgressIndicator(color: _tealMain)));
    }

    final profile = data.profile;
    final savedCount = _savedJobsCount(context);

    return Container(
      color: _bgMain,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ══════════════════════════════════════════
              // a. HEADER
              // ══════════════════════════════════════════
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    // Logo (matches business header)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/branding/plagit_logo.png',
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _tealMain,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text('P',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 20)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${_greeting(context)}, ${profile.firstName}',
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1C1C1E)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // ── Search icon — opens the dedicated Jobs search screen ──
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => SearchScreen(
                            scope: RecentSearchScope.candidateJobs,
                            title: AppLocalizations.of(context).searchJobs,
                            hintText: AppLocalizations.of(context).searchJobsHint,
                            resultsBuilder: (ctx, query) {
                              final jobs = ctx.watch<CandidateJobsProvider>().jobs;
                              final q = query.toLowerCase();
                              final results = jobs.where((j) =>
                                  j.title.toLowerCase().contains(q) ||
                                  j.company.toLowerCase().contains(q) ||
                                  j.location.toLowerCase().contains(q) ||
                                  j.contract.toLowerCase().contains(q)).toList();
                              // Smart rank: title starts-with → company starts-with → contains; alpha within rank.
                              results.sort((a, b) {
                                int r(j) {
                                  final t = j.title.toLowerCase(), c = j.company.toLowerCase();
                                  if (t == q) return 0;
                                  if (t.startsWith(q)) return 1;
                                  if (c.startsWith(q)) return 2;
                                  return 3;
                                }
                                final ra = r(a), rb = r(b);
                                if (ra != rb) return ra - rb;
                                return a.title.toLowerCase().compareTo(b.title.toLowerCase());
                              });
                              if (results.isEmpty) return SearchNoResults(query: query);
                              return ListView.separated(
                                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                                itemCount: results.length,
                                separatorBuilder: (_, _) => const SizedBox(height: 10),
                                itemBuilder: (_, i) {
                                  final job = results[i];
                                  return GestureDetector(
                                    onTap: () => ctx.push('/candidate/job/${job.id}'),
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: _cardBg,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                            color: const Color(0xFFEFEFF4), width: 0.5),
                                        boxShadow: [_subtleShadow],
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: _tealLight,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Icon(
                                              CupertinoIcons.briefcase_fill,
                                              size: 18,
                                              color: _tealMain,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  job.title,
                                                  style: const TextStyle(
                                                    fontSize: 14.5,
                                                    fontWeight: FontWeight.w700,
                                                    color: _charcoal,
                                                    letterSpacing: -0.2,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${localizedVenueName(ctx, job.company)} · ${localizedCity(ctx, job.location)}',
                                                  style: const TextStyle(
                                                      fontSize: 12, color: _tertiary),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  job.compensation.displayLocalized(ctx),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: _tealMain,
                                                    letterSpacing: -0.1,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const ForwardChevron(size: 28, color: Color(0xFFC7C7CC),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      child: const Icon(CupertinoIcons.search, size: 22, color: Color(0xFF3C3C43)),
                    ),
                    const SizedBox(width: 18),
                    GestureDetector(
                      onTap: () => context.push('/candidate/notifications'),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: Stack(clipBehavior: Clip.none, children: [
                          const Center(
                            child: Icon(CupertinoIcons.bell, size: 22, color: Color(0xFF3C3C43)),
                          ),
                          if (data.unreadMessages > 0)
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF3B30),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                              ),
                            ),
                        ]),
                      ),
                    ),
                    const SizedBox(width: 18),
                    GestureDetector(
                      onTap: () => context.push('/candidate/messages/1'),
                      child: const Icon(CupertinoIcons.bubble_left_bubble_right,
                          size: 22, color: Color(0xFF3C3C43)),
                    ),
                  ],
                ),
              ),

              // ══════════════════════════════════════════
              // b. HERO CARD — high-level momentum only
              // ══════════════════════════════════════════
              _buildHeroCard(data, savedCount, isPremium),

              // ══════════════════════════════════════════
              // c. NEXT IMPORTANT THING — single priority card
              // (interview / application update / complete profile / recommended job)
              // ══════════════════════════════════════════
              const SizedBox(height: 16),
              _buildPriorityCard(data),

              // ══════════════════════════════════════════
              // d. QUICK ACTIONS — 4 tiles
              // ══════════════════════════════════════════
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(children: [
                  _QuickAction(
                    icon: CupertinoIcons.search_circle_fill,
                    iconSize: 26,
                    label: AppLocalizations.of(context).findJobs,
                    gradient: true,
                    onTap: () => context.push('/candidate/jobs'),
                  ),
                  const SizedBox(width: 8),
                  _QuickAction(
                    icon: CupertinoIcons.doc_text_fill,
                    iconSize: 22,
                    label: AppLocalizations.of(context).applications,
                    onTap: () => context.push('/candidate/applications'),
                  ),
                  const SizedBox(width: 8),
                  _QuickAction(
                    icon: CupertinoIcons.bubble_left_bubble_right_fill,
                    iconSize: 24,
                    label: AppLocalizations.of(context).messages,
                    onTap: () => context.push('/candidate/messages/1'),
                  ),
                  const SizedBox(width: 8),
                  _QuickAction(
                    icon: CupertinoIcons.person_3_fill,
                    iconSize: 24,
                    label: AppLocalizations.of(context).community,
                    onTap: () => context.push('/feed'),
                  ),
                ]),
              ),

              // ══════════════════════════════════════════
              // e. MID-PRIORITY: My Applications pipeline
              // ══════════════════════════════════════════
              const SizedBox(height: 22),
              _buildApplicationsCard(data),

              // ══════════════════════════════════════════
              // f. MID-PRIORITY: Messages summary
              // ══════════════════════════════════════════
              const SizedBox(height: 14),
              _buildMessagesCard(data),

              // ══════════════════════════════════════════
              // g. ONE JOB RECOMMENDATION SECTION
              // (Featured > Nearby fallback — never both at home)
              // ══════════════════════════════════════════
              if (data.featuredJobs.isNotEmpty || data.nearbyJobs.isNotEmpty) ...[
                const SizedBox(height: 22),
                _buildSectionHeader(
                  context: context,
                  title: AppLocalizations.of(context).recommendedForYou,
                  onSeeAll: () => context.push('/candidate/jobs'),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 168,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: (data.featuredJobs.isNotEmpty ? data.featuredJobs : data.nearbyJobs).length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (_, i) {
                      final list = data.featuredJobs.isNotEmpty ? data.featuredJobs : data.nearbyJobs;
                      return _FeaturedJobCard(
                        job: list[i],
                        onTap: () => context.push('/candidate/job/${list[i].id}'),
                      );
                    },
                  ),
                ),
              ],

              // ══════════════════════════════════════════
              // h. PROFILE STRENGTH — only when NOT already in priority card
              // (profile completion is the #3 fallback in the priority card,
              //  so showing it twice would be redundant)
              // ══════════════════════════════════════════
              if (!_priorityIsProfile(data)) ...[
                const SizedBox(height: 22),
                _buildProfileStrengthCard(profile),
              ],

              // ══════════════════════════════════════════
              // i. PREMIUM BANNER
              //   • Free candidates → upsell card (tap → paywall)
              //   • Premium candidates → active-state card (tap → manage)
              // Gated on `isPremium` from CandidateAuthProvider so it
              // updates the instant a purchase or restore completes.
              // ══════════════════════════════════════════
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: isPremium ? _buildPremiumActiveCard(context) : _buildPremiumUpsellCard(context),
              ),

              const SizedBox(height: 96),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HERO CARD
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHeroCard(CandidateHomeData data, int savedCount, bool isPremium) {
    final l = AppLocalizations.of(context);
    final profile = data.profile;
    final hasMomentum = data.totalApplications > 0 ||
        data.interviewCount > 0 ||
        data.nearbyJobs.isNotEmpty;
    final headline = data.nextInterview != null
        ? l.yourNextInterview
        : data.interviewCount > 0
            ? l.yourCareerTakingOff
            : data.totalApplications > 0
                ? l.yourCareerOnTheMove
                : l.yourJourneyStartsHere;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero identity row — large text on the left, noticeably larger
          //    professional head-and-shoulders photo on the right. Reads
          //    like a work profile card, not a social avatar bubble. ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l.careerDashboard,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _tealMain,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      headline,
                      style: GoogleFonts.nunito(
                        // 25 pt keeps the 2-line headline readable while the
                        // photo takes the remaining width.
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1C1C1E),
                        height: 1.15,
                        letterSpacing: -0.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${profile.firstName} · ${profile.role ?? 'Hospitality Pro'}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _secondary,
                        letterSpacing: -0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // ── Candidate headshot — 118 px square ID-card ──
              //
              // Bumped from 76 → 118 (+55%) so the candidate reads as a real
              // person on the most-visible surface in the app. Square frame
              // with 21 px radius = staff-badge / passport-photo feel, not
              // a social avatar bubble. Verified seal + premium star badge
              // remain proportional to the new size.
              SizedBox(
                width: 124,
                height: 124,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ProfilePhoto(
                      photoUrl: profile.photoUrl,
                      initials: profile.initials,
                      size: 118,
                      square: true,
                      verified: profile.isVerified,
                      hueSeed: profile.name,
                    ),
                    if (isPremium)
                      Positioned(
                        // Sits on the photo's bottom-right corner,
                        // slightly overlapping it — reads as an
                        // integrated ID-card seal instead of a
                        // sticker floating above the photo. Hairline
                        // 1.5 px white ring is just enough to
                        // separate the champagne medallion from the
                        // photo edge.
                        bottom: -2,
                        right: -2,
                        child: Container(
                          padding: const EdgeInsets.all(1.5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const PremiumCrownBadge(size: 30),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Live signal row
          Row(children: [
            if (hasMomentum) ...[
              FadeTransition(
                opacity: _pulseCtrl.drive(Tween(begin: 0.4, end: 1.0)),
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(color: _green, shape: BoxShape.circle),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                data.totalApplications > 0
                    ? l.liveApplicationsCount(data.totalApplications)
                    : l.nearbyJobsCount(data.nearbyJobs.length),
                style: const TextStyle(fontSize: 11, color: _green),
              ),
              const SizedBox(width: 14),
            ],
            if (data.nearbyJobs.isNotEmpty) ...[
              const Icon(CupertinoIcons.location_solid, size: 10, color: _tealMain),
              const SizedBox(width: 4),
              Text(
                l.jobsNearYouCount(data.nearbyJobs.length),
                style: const TextStyle(fontSize: 11, color: _tealMain),
              ),
            ],
            if (!hasMomentum)
              Text(
                l.applyFirstJob,
                style: const TextStyle(fontSize: 11, color: _tertiary),
              ),
          ]),
          // Dynamic status updates
          if (data.underReviewCount > 0 ||
              data.interviewCount > 0 ||
              data.unreadMessages > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (data.underReviewCount > 0)
                    _statusLine(
                      CupertinoIcons.eye_fill,
                      l.applicationsUnderReviewCount(data.underReviewCount),
                      _indigo,
                    ),
                  if (data.interviewCount > 0) ...[
                    if (data.underReviewCount > 0) const SizedBox(height: 6),
                    _statusLine(
                      CupertinoIcons.calendar,
                      data.nextInterview != null
                          ? l.interviewComingUp
                          : l.interviewsScheduledCount(data.interviewCount),
                      _tealMain,
                    ),
                  ],
                  if (data.unreadMessages > 0) ...[
                    if (data.underReviewCount > 0 || data.interviewCount > 0)
                      const SizedBox(height: 6),
                    _statusLine(
                      CupertinoIcons.bubble_left_bubble_right_fill,
                      l.unreadMessagesCount(data.unreadMessages),
                      _purple,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PREMIUM BANNER — free upsell / active state
  // ═══════════════════════════════════════════════════════════════

  /// Free-tier upsell card — tap goes to the paywall.
  /// Aligned to the same tokens as [_buildPremiumActiveCard] so the
  /// premium/non-premium switch reads as one design.
  Widget _buildPremiumUpsellCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/candidate/premium'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [_subtleShadow],
        ),
        child: Row(children: [
          const PremiumCrownBadge(size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context).unlockPlagitPremium,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1C1C1E),
                    letterSpacing: -0.25,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppLocalizations.of(context).premiumSubtitle,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF8E8E93),
                    letterSpacing: -0.1,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ForwardChevron(size: 28, color: const Color(0xFFCFA15F).withValues(alpha: 0.75),
          ),
        ]),
      ),
    );
  }

  /// Premium-active state card — tap goes to the manage subscription
  /// screen. Same shape and footprint as the upsell card so the home
  /// layout is identical between the two states — only the content and
  /// the accent color change. The amber star gains a small green
  /// "active" dot so the state is unmistakable at a glance.
  Widget _buildPremiumActiveCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/candidate/subscription'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [_subtleShadow],
          border: Border.all(
            color: const Color(0xFFCFA15F).withValues(alpha: 0.14),
            width: 0.5,
          ),
        ),
        child: Row(children: [
          // Canonical premium medallion — shared widget, single
          // source of truth for the premium identity.
          const PremiumCrownBadge(size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context).premiumActive,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1C1C1E),
                    letterSpacing: -0.25,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppLocalizations.of(context).premiumActiveSubtitle,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF8E8E93),
                    letterSpacing: -0.1,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ForwardChevron(size: 28, color: const Color(0xFFCFA15F).withValues(alpha: 0.75),
          ),
        ]),
      ),
    );
  }

  Widget _statusLine(IconData icon, String text, Color color) {
    return Row(children: [
      Icon(icon, size: 11, color: color),
      const SizedBox(width: 6),
      Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    ]);
  }

  // ═══════════════════════════════════════════════════════════════
  // PRIORITY CARD — single focal block under the hero
  //
  // Replaces the previous CTA pill + Next Step header + card combo.
  // Picks ONE thing to highlight, in priority order:
  //   1. Next interview     → calendar block + role + status
  //   2. Application update → role + new status + chevron
  //   3. Complete profile   → progress bar + tagline
  //   4. Recommended job    → first featured job
  // ═══════════════════════════════════════════════════════════════

  /// Returns true when the priority card is currently showing the
  /// "Complete Your Profile" block — used to deduplicate the lower
  /// Profile Strength card.
  bool _priorityIsProfile(CandidateHomeData data) {
    return data.nextInterview == null
        && data.underReviewCount == 0
        && data.profile.profileStrength < 80;
  }

  Widget _buildPriorityCard(CandidateHomeData data) {
    // 1. Next interview wins
    if (data.nextInterview != null) {
      return _buildPrioritySection(
        title: AppLocalizations.of(context).nextInterview,
        icon: CupertinoIcons.calendar_badge_plus,
        iconColor: _indigo,
        seeAllRoute: '/candidate/interviews',
        child: _buildNextInterview(data.nextInterview!),
      );
    }
    // 2. Application update (under review)
    if (data.underReviewCount > 0) {
      return _buildPrioritySection(
        title: AppLocalizations.of(context).applicationUpdate,
        icon: CupertinoIcons.eye_fill,
        iconColor: _tealMain,
        seeAllRoute: '/candidate/applications',
        child: _buildApplicationUpdate(data),
      );
    }
    // 3. Profile completion (if low and no other priority)
    if (data.profile.profileStrength < 80) {
      return _buildPrioritySection(
        title: AppLocalizations.of(context).completeYourProfile,
        icon: CupertinoIcons.person_crop_circle_badge_checkmark,
        iconColor: _amber,
        seeAllRoute: '/candidate/profile',
        child: _buildCompleteProfilePriority(data.profile),
      );
    }
    // 4. Recommended job
    if (data.featuredJobs.isNotEmpty) {
      return _buildPrioritySection(
        title: AppLocalizations.of(context).recommendedForYou,
        icon: CupertinoIcons.sparkles,
        iconColor: _amber,
        seeAllRoute: '/candidate/jobs',
        child: _buildRecommendedJob(data.featuredJobs.first),
      );
    }
    // 5. Empty fallback
    return _buildPrioritySection(
      title: AppLocalizations.of(context).getStartedAction,
      icon: CupertinoIcons.search,
      iconColor: _tealMain,
      seeAllRoute: '/candidate/jobs',
      child: _buildEmptyPriority(),
    );
  }

  /// Wraps a priority block with a consistent header (icon + title + See All)
  /// and the section body — keeping the structure tight and predictable.
  Widget _buildPrioritySection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String seeAllRoute,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Row(children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1C1E),
                letterSpacing: -0.2,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => context.push(seeAllRoute),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  AppLocalizations.of(context).seeAll,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: _tealMain),
                ),
                const SizedBox(width: 2),
                const ForwardChevron(size: 28, color: _tealMain),
              ]),
            ),
          ]),
        ),
        child,
      ],
    );
  }

  /// Application-update card body (used when there is no interview).
  Widget _buildApplicationUpdate(CandidateHomeData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => context.push('/candidate/applications'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _tealMain.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(CupertinoIcons.eye_fill, size: 22, color: _tealMain),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  AppLocalizations.of(context).applicationsUnderReviewCount(data.underReviewCount),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C1C1E),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppLocalizations.of(context).employerCheckingProfile,
                  style: const TextStyle(fontSize: 12, color: _tertiary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ]),
            ),
            const ForwardChevron(size: 28, color: Color(0xFFC7C7CC)),
          ]),
        ),
      ),
    );
  }

  /// Complete-profile card body (used when profile strength is low).
  Widget _buildCompleteProfilePriority(CandidateProfile profile) {
    final strength = profile.profileStrength;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => context.push('/candidate/profile'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(CupertinoIcons.person_crop_circle_badge_checkmark, size: 22, color: _amber),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  AppLocalizations.of(context).profileStrengthPercent(strength),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C1C1E),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: strength / 100,
                    minHeight: 5,
                    backgroundColor: const Color(0xFFEFEFF4),
                    valueColor: const AlwaysStoppedAnimation(_amber),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context).profileGetsMoreViews,
                  style: const TextStyle(fontSize: 11, color: _tertiary),
                ),
              ]),
            ),
            const SizedBox(width: 8),
            const ForwardChevron(size: 28, color: Color(0xFFC7C7CC)),
          ]),
        ),
      ),
    );
  }

  Widget _buildEmptyPriority() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [_subtleShadow],
        ),
        child: Row(children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _tealMain.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(CupertinoIcons.search, size: 22, color: _tealMain),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).findYourFirstJob,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1C1C1E),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppLocalizations.of(context).browseHospitalityRolesNearby,
                  style: const TextStyle(fontSize: 12, color: _tertiary),
                ),
              ],
            ),
          ),
          const ForwardChevron(size: 28, color: Color(0xFFC7C7CC)),
        ]),
      ),
    );
  }

  Widget _buildNextInterview(Interview iv) {
    const formatColor = _indigo;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => context.push('/candidate/interviews'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(children: [
            // Date block
            Container(
              width: 62,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: _tealMain.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(children: [
                Text(
                  _dayFromDate(iv.date),
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: _tealMain),
                ),
                Text(
                  _monthAbbrFromDate(iv.date),
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF8E8E93)),
                ),
                const SizedBox(height: 2),
                Text(
                  iv.time.toLowerCase(),
                  maxLines: 1,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF3A3A3C)),
                ),
              ]),
            ),
            const SizedBox(width: 8),
            Container(width: 1, height: 50, color: const Color(0xFFE5E5EA)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(iv.jobTitle,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3A3A3C))),
                Text(iv.company,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93))),
                const SizedBox(height: 6),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      AppLocalizations.of(context).confirmed,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w500, color: _green),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: formatColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      localizedInterviewFormat(context, iv.format.displayName),
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w500, color: formatColor),
                    ),
                  ),
                ]),
              ]),
            ),
            const ForwardChevron(size: 28, color: Color(0xFFC7C7CC)),
          ]),
        ),
      ),
    );
  }

  Widget _buildRecommendedJob(Job job) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => context.push('/candidate/job/${job.id}'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _amber.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(CupertinoIcons.sparkles, size: 22, color: _amber),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(job.title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C1C1E),
                        letterSpacing: -0.2),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text('${localizedVenueName(context, job.company)} · ${localizedCity(context, job.location)}',
                    style: const TextStyle(fontSize: 12, color: _tertiary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _tealLight,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    job.compensation.displayLocalized(context),
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700, color: _tealMain),
                  ),
                ),
              ]),
            ),
            const ForwardChevron(size: 28, color: Color(0xFFC7C7CC)),
          ]),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MID-PRIORITY: My Applications card
  // ═══════════════════════════════════════════════════════════════

  Widget _buildApplicationsCard(CandidateHomeData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [_subtleShadow],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header row — only the "View all" affordance navigates to the
          // unfiltered Applications list. Tapping any individual pill below
          // deep-links to the matching filtered view instead.
          Row(children: [
            const Icon(CupertinoIcons.doc_text_fill, size: 14, color: _tealMain),
            const SizedBox(width: 6),
            Text(
              AppLocalizations.of(context).myApplications,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C1C1E),
                letterSpacing: -0.2,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => context.push('/candidate/applications'),
              behavior: HitTestBehavior.opaque,
              child: Row(children: [
                Text(
                  AppLocalizations.of(context).seeAll,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _tealMain),
                ),
                const SizedBox(width: 2),
                const ForwardChevron(size: 28, color: _tealMain),
              ]),
            ),
          ]),
          const SizedBox(height: 14),
          _buildMomentumStats(data),
        ]),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MID-PRIORITY: Messages card
  // ═══════════════════════════════════════════════════════════════

  Widget _buildMessagesCard(CandidateHomeData data) {
    final hasUnread = data.unreadMessages > 0;
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => context.push('/candidate/messages/1'),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [_subtleShadow],
          ),
          child: Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _purple.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(CupertinoIcons.bubble_left_bubble_right_fill, size: 20, color: _purple),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(
                    l.messagesTitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1C1E),
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (hasUnread) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _purple,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        '${data.unreadMessages}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ]),
                const SizedBox(height: 2),
                Text(
                  hasUnread
                      ? l.unreadMessagesFromEmployersCount(data.unreadMessages)
                      : l.noNewMessages,
                  style: TextStyle(
                    fontSize: 12,
                    color: hasUnread ? _purple : _tertiary,
                    fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ]),
            ),
            const ForwardChevron(size: 28, color: Color(0xFFC7C7CC)),
          ]),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // LOW-PRIORITY: Profile Strength card
  // ═══════════════════════════════════════════════════════════════

  Widget _buildProfileStrengthCard(CandidateProfile profile) {
    final strength = profile.profileStrength;
    final missing = profile.completionItems.where((i) => !i.done).length;
    final l = AppLocalizations.of(context);
    // Tinted accent flips green when nearly done — gives the card a positive
    // feel rather than a nagging one.
    final accent = strength >= 80 ? _green : _amber;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => context.push('/candidate/profile'),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [_subtleShadow],
          ),
          child: Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(CupertinoIcons.person_crop_circle_badge_checkmark, size: 17, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(
                      l.profileStrength,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1C1C1E),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$strength%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: accent,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: strength / 100,
                      minHeight: 4,
                      backgroundColor: const Color(0xFFEFEFF4),
                      valueColor: AlwaysStoppedAnimation(accent),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    missing > 0
                        ? l.stepsLeftCount(missing)
                        : l.profileCompleteGreatWork,
                    style: const TextStyle(fontSize: 11, color: _tertiary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const ForwardChevron(size: 28, color: Color(0xFFC7C7CC)),
          ]),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CAREER MOMENTUM (mirrors business "Hiring Progress")
  // ═══════════════════════════════════════════════════════════════

  Widget _buildMomentumStats(CandidateHomeData data) {
    // Each pill deep-links to /candidate/applications?filter=<key> so the
    // Applications screen opens with the matching chip pre-selected.
    final l = AppLocalizations.of(context);
    return Row(children: [
      _momentumPill(
        label: l.statusApplied,
        count: data.totalApplications,
        color: _tealMain,
        filterKey: 'applied',
      ),
      const SizedBox(width: 8),
      _momentumPill(
        label: l.statusInReview,
        count: data.underReviewCount,
        color: _indigo,
        filterKey: 'review',
      ),
      const SizedBox(width: 8),
      _momentumPill(
        label: l.statusInterview,
        count: data.interviewCount,
        color: _amber,
        filterKey: 'interview',
      ),
      const SizedBox(width: 8),
      _momentumPill(
        label: l.statusOffer,
        count: data.offerCount,
        color: _green,
        filterKey: 'offer',
      ),
    ]);
  }

  Widget _momentumPill({
    required String label,
    required int count,
    required Color color,
    required String filterKey,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => context.push('/candidate/applications?filter=$filterKey'),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(children: [
            Text('$count',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 1),
            Text(label,
                style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w600, color: color)),
          ]),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SECTION HEADER
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSectionHeader({
    required BuildContext context,
    required String title,
    required VoidCallback onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title,
            style: const TextStyle(
                fontSize: 19, fontWeight: FontWeight.bold, color: _charcoal)),
        GestureDetector(
          onTap: onSeeAll,
          child: Text('${AppLocalizations.of(context).seeAll} ›',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _tealMain)),
        ),
      ]),
    );
  }

  // ── helpers ──
  String _dayFromDate(String date) {
    if (date.length >= 10) return date.substring(8, 10);
    return date;
  }

  String _monthAbbrFromDate(String date) {
    if (date.length < 7) return '';
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    final m = int.tryParse(date.substring(5, 7));
    if (m == null || m < 1 || m > 12) return '';
    return months[m - 1];
  }
}

// ═══════════════════════════════════════════════════════════════
// QUICK ACTION — mirrors Business _QuickAction
// ═══════════════════════════════════════════════════════════════

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final String label;
  final bool gradient;
  final VoidCallback? onTap;
  const _QuickAction({
    required this.icon,
    this.iconSize = 26,
    required this.label,
    this.gradient = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: gradient ? null : _tealMain.withValues(alpha: 0.08),
            gradient: gradient
                ? const LinearGradient(
                    colors: [_tealMain, Color(0xFF1A9090)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: iconSize, color: gradient ? Colors.white : _tealMain),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: gradient ? Colors.white : const Color(0xFF3A3A3C),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// FEATURED JOB CARD (used in horizontal carousel)
// ═══════════════════════════════════════════════════════════════

class _FeaturedJobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;
  const _FeaturedJobCard({required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hue = (job.company.hashCode % 360).abs().toDouble();
    final initials = job.company.isNotEmpty ? job.company[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 224,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [_subtleShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ── Top block: logo + title + company/location ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        HSLColor.fromAHSL(1, hue, 0.42, 0.58).toColor(),
                        HSLColor.fromAHSL(1, (hue + 30) % 360, 0.38, 0.52).toColor(),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  job.title,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w500,
                    color: _charcoal,
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${localizedVenueName(context, job.company)} · ${localizedCity(context, job.location)}',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: _secondary.withValues(alpha: 0.92),
                    letterSpacing: -0.1,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),

            // ── Bottom block: salary + employment row ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  job.compensation.displayLocalized(context),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _tealMain,
                    letterSpacing: -0.2,
                    height: 1.25,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      localizedEmploymentType(context, job.employmentType),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: _tealMain.withValues(alpha: 0.85),
                        letterSpacing: -0.05,
                      ),
                    ),
                    if (job.featured) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _amber.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          AppLocalizations.of(context).featuredBadge,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: _amber.withValues(alpha: 0.92),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
