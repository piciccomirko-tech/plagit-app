import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/city_helpers.dart';
import 'package:plagit/core/l10n_helpers.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/models/applicant.dart';
import 'package:plagit/models/business_home_data.dart';
import 'package:plagit/models/business_interview.dart';
import 'package:plagit/providers/business_providers.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

// ═══════════════════════════════════════════════════════════════
// Theme (exact from Swift Theme.swift)
// ═══════════════════════════════════════════════════════════════
const _tealMain = Color(0xFF00B5B0);
const _tealLight = Color(0x1A00B5B0);
const _bgMain = Color(0xFFF6F7F8);
const _cardBg = Color(0xFFFFFFFF);
const _surface = Color(0xFFF9FAFB);
const _charcoal = Color(0xFF1A1C24);
const _secondary = Color(0xFF707580);
const _tertiary = Color(0xFF9EA3AD);
const _divider = Color(0xFFEBEDF0);
const _green = Color(0xFF2ECC70);
const _amber = Color(0xFFF59E33);
const _indigo = Color(0xFF6676F0);

extension _BusinessDashboardL10nX on AppLocalizations {
  String _local({
    required String en,
    required String it,
    required String ar,
  }) {
    if (localeName.startsWith('it')) return it;
    if (localeName.startsWith('ar')) return ar;
    return en;
  }

  String activeJobsShort(int count) => _local(
        en: '$count active jobs',
        it: '$count lavori attivi',
        ar: '$count وظائف نشطة',
      );

  String newThisWeekCount(int count) => _local(
        en: '+$count this week',
        it: '+$count questa settimana',
        ar: '+$count هذا الأسبوع',
      );

  String newApplicantsToReview(int count) => _local(
        en: '$count new applicants to review',
        it: '$count nuovi candidati da rivedere',
        ar: '$count متقدمين جدد للمراجعة',
      );

  String get comingSoonShort => _local(
        en: 'Coming soon',
        it: 'Prossimamente',
        ar: 'قريباً',
      );

  String get searchRecentApplicantsHint => _local(
        en: 'Search recent applicants',
        it: 'Cerca tra i candidati recenti',
        ar: 'ابحث في المتقدمين الجدد',
      );

  String get noMatchingApplicants => _local(
        en: 'No matching applicants',
        it: 'Nessun candidato corrispondente',
        ar: 'لا يوجد متقدمون مطابقون',
      );

  String get searchLooksAtRecentApplicants => _local(
        en: 'This search currently looks only through recent applicants.',
        it: 'Questa ricerca al momento controlla solo i candidati recenti.',
        ar: 'هذا البحث يبحث حالياً فقط ضمن المتقدمين الجدد.',
      );

  String monthAbbr(int month) => switch (month) {
        1 => _local(en: 'JAN', it: 'GEN', ar: 'ينا'),
        2 => _local(en: 'FEB', it: 'FEB', ar: 'فبر'),
        3 => _local(en: 'MAR', it: 'MAR', ar: 'مار'),
        4 => _local(en: 'APR', it: 'APR', ar: 'أبر'),
        5 => _local(en: 'MAY', it: 'MAG', ar: 'ماي'),
        6 => _local(en: 'JUN', it: 'GIU', ar: 'يون'),
        7 => _local(en: 'JUL', it: 'LUG', ar: 'يول'),
        8 => _local(en: 'AUG', it: 'AGO', ar: 'أغس'),
        9 => _local(en: 'SEP', it: 'SET', ar: 'سبت'),
        10 => _local(en: 'OCT', it: 'OTT', ar: 'أكت'),
        11 => _local(en: 'NOV', it: 'NOV', ar: 'نوف'),
        12 => _local(en: 'DEC', it: 'DIC', ar: 'ديس'),
        _ => '',
      };
}


BoxShadow get _subtleShadow => BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 14,
      offset: const Offset(0, 4),
    );

Border get _subtleBorder => Border.all(color: const Color(0xFFE6E8ED).withValues(alpha: 0.7));

class BusinessDashboardTab extends StatefulWidget {
  const BusinessDashboardTab({super.key});

  @override
  State<BusinessDashboardTab> createState() => _BusinessDashboardTabState();
}

class _BusinessDashboardTabState extends State<BusinessDashboardTab> with SingleTickerProviderStateMixin {
  int _tabIndex = 0;
  bool _showCreateMenu = false;
  bool _showSearch = false;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusinessHomeProvider>().load();
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  String _greeting() {
    final h = DateTime.now().hour;
    final t = AppLocalizations.of(context);
    return h < 12 ? t.goodMorning : h < 17 ? t.goodAfternoon : t.goodEvening;
  }

  String _candidateRouteId(Applicant applicant) =>
      applicant.candidateId ?? applicant.id;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BusinessHomeProvider>();
    final subscription = context.watch<BusinessAuthProvider>().subscription;

    // Loading
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

    // Error
    if (provider.error != null) {
      return Container(
        color: _bgMain,
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.wifi_off, size: 40, color: _tertiary),
            const SizedBox(height: 16),
            Text(provider.error!, style: const TextStyle(fontSize: 14, color: _secondary), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => context.read<BusinessHomeProvider>().load(),
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

    return Stack(
      children: [
        // ── SCROLLABLE CONTENT ──
        Container(
          color: _bgMain,
          child: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ══════════════════════════════════════
                  // a. HEADER
                  // ══════════════════════════════════════
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      children: [
                        // Plagit logo — matches candidate header for consistent brand identity
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/branding/plagit_logo.png',
                            width: 36, height: 36, fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(color: _tealMain, borderRadius: BorderRadius.circular(10)),
                              child: const Center(child: Text('P', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20))),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${_greeting()}, ${profile.name.split(' ').first}',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E)),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _showSearch = true),
                          child: const Icon(CupertinoIcons.search, size: 22, color: Color(0xFF3C3C43)),
                        ),
                        const SizedBox(width: 18),
                        GestureDetector(
                          onTap: () => context.push('/business/notifications'),
                          child: SizedBox(
                            width: 24, height: 24,
                            child: Stack(clipBehavior: Clip.none, children: [
                              const Center(child: Icon(CupertinoIcons.bell, size: 22, color: Color(0xFF3C3C43))),
                              if (data.unreadMessages > 0)
                                Positioned(
                                  top: -2, right: -2,
                                  child: Container(
                                    width: 7, height: 7,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF3B30), shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 1.5),
                                    ),
                                  ),
                                ),
                            ]),
                          ),
                        ),
                        const SizedBox(width: 18),
                        GestureDetector(
                          onTap: () => context.push('/business/messages'),
                          child: const Icon(CupertinoIcons.bubble_left_bubble_right, size: 22, color: Color(0xFF3C3C43)),
                        ),
                        const SizedBox(width: 18),
                        GestureDetector(
                          onTap: () => setState(() => _showCreateMenu = true),
                          child: const Icon(
                            CupertinoIcons.add_circled_solid,
                            size: 24,
                            color: _tealMain,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ══════════════════════════════════════
                  // b. HERO CARD
                  // ══════════════════════════════════════
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                    decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16), border: _subtleBorder, boxShadow: [_subtleShadow]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(AppLocalizations.of(context).hiringDashboard, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2BB8B0), letterSpacing: 1.2)),
                                const SizedBox(height: 7),
                                Text(AppLocalizations.of(context).yourPipelineActive, style: GoogleFonts.nunito(
                                  fontSize: 24, fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1C1C1E), height: 1.18, letterSpacing: -0.3,
                                )),
                                const SizedBox(height: 8),
                                Text(
                                  data.activeJobs.isEmpty && data.totalApplicants == 0
                                      ? AppLocalizations.of(context).postJobToStart
                                      : '${profile.name} · ${AppLocalizations.of(context).activeJobsCount(data.activeJobs.length)}',
                                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF4A4F5C), letterSpacing: -0.1),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                              ]),
                            ),
                            const SizedBox(width: 14),
                            // Square restaurant hero image — 118 px to match candidate hero ID-card footprint
                            ClipRRect(
                              borderRadius: BorderRadius.circular(21),
                              child: SizedBox(
                                width: 118, height: 118,
                                child: Stack(fit: StackFit.expand, children: [
                                  Image.network(
                                    'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=600&h=600&fit=crop&q=80',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(colors: [Color(0xFF2BB8B0), Color(0xFF1A9090)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                      ),
                                      child: Center(child: Text(profile.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 28, letterSpacing: 0.3))),
                                    ),
                                  ),
                                  DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
                                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.18)],
                                  ))),
                                ]),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Live signal row
                        Row(children: [
                          if (data.activeJobs.isNotEmpty) ...[
                            FadeTransition(opacity: _pulseCtrl.drive(Tween(begin: 0.4, end: 1.0)),
                              child: Container(width: 5, height: 5, decoration: const BoxDecoration(color: _green, shape: BoxShape.circle))),
                            const SizedBox(width: 6),
                            Text(AppLocalizations.of(context).activeJobsShort(data.activeJobs.length), style: const TextStyle(fontSize: 11, color: _green)),
                            const SizedBox(width: 14),
                          ],
                          if (data.totalApplicants > 0) ...[
                            const Icon(CupertinoIcons.arrow_up, size: 10, color: _tealMain),
                            const SizedBox(width: 4),
                            Text(AppLocalizations.of(context).newThisWeekCount(data.totalApplicants), style: const TextStyle(fontSize: 11, color: _tealMain)),
                          ],
                        ]),
                        // Dynamic status updates
                        if (data.totalApplicants > 0 || data.unreadMessages > 0 || data.nextInterview != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(10)),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              if (data.totalApplicants > 0)
                                _statusLine(CupertinoIcons.person_badge_plus, AppLocalizations.of(context).newApplicantsToReview(data.totalApplicants), const Color(0xFFFF9500)),
                              if (data.unreadMessages > 0) ...[
                                if (data.totalApplicants > 0) const SizedBox(height: 6),
                                _statusLine(CupertinoIcons.bubble_left_bubble_right, AppLocalizations.of(context).unreadMessagesCount(data.unreadMessages), const Color(0xFF5856D6)),
                              ],
                              if (data.nextInterview != null) ...[
                                if (data.totalApplicants > 0 || data.unreadMessages > 0) const SizedBox(height: 6),
                                _statusLine(CupertinoIcons.calendar, AppLocalizations.of(context).interviewComingUp, _indigo),
                              ],
                            ]),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // ══════════════════════════════════════
                  // c. STATS ROW
                  // ══════════════════════════════════════
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(children: [
                      _StatCard(icon: CupertinoIcons.briefcase_fill, color: const Color(0xFF2BB8B0), count: data.activeJobs.length, label: AppLocalizations.of(context).jobs, onTap: () => context.push('/business/jobs')),
                      const SizedBox(width: 8),
                      _StatCard(icon: CupertinoIcons.person_badge_plus_fill, color: const Color(0xFFFF9500), count: data.totalApplicants, label: AppLocalizations.of(context).newApplicants, badge: data.totalApplicants > 0 ? AppLocalizations.of(context).newNotification : null, onTap: () {
                        if (data.recentApplicants.isNotEmpty) {
                          context.push(
                            '/business/candidate/${_candidateRouteId(data.recentApplicants.first)}',
                          );
                        } else {
                          context.push('/business/applicants');
                        }
                      }),
                      const SizedBox(width: 8),
                      _StatCard(icon: CupertinoIcons.calendar, color: const Color(0xFF5856D6), count: data.interviewCount, label: AppLocalizations.of(context).statusInterview, onTap: () => context.push('/business/interviews')),
                    ]),
                  ),

                  // ══════════════════════════════════════
                  // d. NEXT ACTION CTA
                  // ══════════════════════════════════════
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: GestureDetector(
                      onTap: () {
                        if (data.totalApplicants > 0 && data.recentApplicants.isNotEmpty) {
                          context.push(
                            '/business/candidate/${_candidateRouteId(data.recentApplicants.first)}',
                          );
                        } else if (data.unreadMessages > 0) { context.push('/business/messages'); }
                        else if (data.nextInterview != null) { context.push('/business/interview/${data.nextInterview!.id}'); }
                        else { context.push('/business/post-job'); }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2BB8B0).withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF2BB8B0).withValues(alpha: 0.16)),
                        ),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                          Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(color: const Color(0xFF2BB8B0).withValues(alpha: 0.13), borderRadius: BorderRadius.circular(8)),
                            alignment: Alignment.center,
                            child: const Icon(CupertinoIcons.bolt_fill, size: 14, color: Color(0xFF1A9090)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(
                            data.totalApplicants > 0 ? AppLocalizations.of(context).reviewApplicants(data.totalApplicants)
                            : data.unreadMessages > 0 ? AppLocalizations.of(context).replyMessages(data.unreadMessages)
                            : data.nextInterview != null ? '${AppLocalizations.of(context).nextInterview} · ${data.nextInterview!.time}'
                            : AppLocalizations.of(context).postJobToStart,
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF0F6E6A), letterSpacing: -0.1),
                          )),
                          const ForwardChevron(size: 28, color: Color(0xFF1A9090)),
                        ]),
                      ),
                    ),
                  ),

                  // ══════════════════════════════════════
                  // e. NEXT INTERVIEW
                  // ══════════════════════════════════════
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(children: [
                      const Icon(CupertinoIcons.calendar_badge_plus, size: 16, color: _indigo),
                      const SizedBox(width: 5),
                      Text(AppLocalizations.of(context).nextInterview, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E), letterSpacing: -0.2)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => context.push('/business/interviews'),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(AppLocalizations.of(context).seeAll, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF2BB8B0))),
                          const SizedBox(width: 2),
                          const ForwardChevron(size: 28, color: Color(0xFF2BB8B0)),
                        ]),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  _buildNextInterview(data.nextInterview),

                  // ══════════════════════════════════════
                  // e. QUICK ACTIONS
                  // ══════════════════════════════════════
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(children: [
                      _QuickAction(icon: CupertinoIcons.plus_circle_fill, iconSize: 24, label: AppLocalizations.of(context).postJobShort, gradient: true, onTap: () => context.push('/business/post-job')),
                      const SizedBox(width: 8),
                      _QuickAction(icon: CupertinoIcons.placemark_fill, iconSize: 22, label: AppLocalizations.of(context).nearby, onTap: () => context.push('/business/nearby-talent')),
                      const SizedBox(width: 8),
                      _QuickAction(icon: CupertinoIcons.person_3_fill, iconSize: 24, label: AppLocalizations.of(context).community, onTap: () => context.push('/feed')),
                      const SizedBox(width: 8),
                      _QuickAction(icon: CupertinoIcons.bubble_left_bubble_right_fill, iconSize: 24, label: AppLocalizations.of(context).messages, onTap: () => context.push('/business/messages')),
                    ]),
                  ),

                  // ══════════════════════════════════════
                  // f2. HIRING PROGRESS
                  // ══════════════════════════════════════
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16), border: _subtleBorder, boxShadow: [_subtleShadow]),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(color: const Color(0xFF2BB8B0).withValues(alpha: 0.10), borderRadius: BorderRadius.circular(7)),
                            child: const Icon(CupertinoIcons.chart_bar_fill, size: 14, color: Color(0xFF2BB8B0)),
                          ),
                          const SizedBox(width: 8),
                          Text(AppLocalizations.of(context).hiringProgress, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E), letterSpacing: -0.2)),
                        ]),
                        const SizedBox(height: 12),
                        _buildHiringProgress(data),
                        const SizedBox(height: 10),
                        // Positive feedback
                        if (data.activeJobs.isNotEmpty || data.totalApplicants > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: const Color(0xFF34C759).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(CupertinoIcons.checkmark_seal_fill, size: 12, color: Color(0xFF34C759)),
                              const SizedBox(width: 5),
                              Text(
                                data.totalApplicants > 0 ? AppLocalizations.of(context).reviewApplicants(data.totalApplicants)
                                : AppLocalizations.of(context).jobLiveVisible,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF34C759)),
                              ),
                            ]),
                          ),
                      ]),
                    ),
                  ),

                  // ══════════════════════════════════════
                  // g. PREMIUM BANNER
                  // ══════════════════════════════════════
                  if (!subscription.plan.isPremium)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: GestureDetector(
                        onTap: () => context.push('/business/subscription'),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(20), border: _subtleBorder, boxShadow: [_subtleShadow]),
                          child: Row(children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), gradient: LinearGradient(colors: [_indigo, _indigo.withValues(alpha: 0.70)])),
                              alignment: Alignment.center,
                              child: const PhosphorIcon(PhosphorIconsFill.crown, size: 18, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(AppLocalizations.of(context).unlockBusinessPremium, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1C1C1E), letterSpacing: -0.2)),
                              const SizedBox(height: 1),
                              Text(AppLocalizations.of(context).businessPremiumSubtitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF8E8E93)), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ])),
                            const ForwardChevron(size: 28, color: _indigo),
                          ]),
                        ),
                      ),
                    ),

                  // ══════════════════════════════════════
                  // g. CONTENT TABS
                  // ══════════════════════════════════════
                  const SizedBox(height: 24),
                  _buildTabs(),
                  Container(height: 0.5, color: _divider),

                  // ══════════════════════════════════════
                  // h. TAB CONTENT
                  // ══════════════════════════════════════
                  if (_tabIndex == 0) _buildDashboardTab(data),
                  if (_tabIndex == 1) _buildCandidatesTab(data),
                  if (_tabIndex == 2) _buildActivityTab(data),

                  const SizedBox(height: 96),
                ],
              ),
            ),
          ),
        ),

        // ── CREATE MENU OVERLAY ──
        if (_showCreateMenu) _buildCreateOverlay(),

        // ── SEARCH OVERLAY ──
        if (_showSearch) _buildSearchOverlay(data),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // NEXT INTERVIEW
  // ═══════════════════════════════════════════════════════════════

  Widget _buildNextInterview(BusinessInterview? iv) {
    if (iv == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(20), border: _subtleBorder, boxShadow: [_subtleShadow]),
          child: Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.calendar_today, size: 16, color: _tertiary)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(AppLocalizations.of(context).noUpcomingInterviews, style: const TextStyle(fontSize: 15, color: _charcoal)),
              const SizedBox(height: 2),
              Text(AppLocalizations.of(context).scheduleFromApplicants, style: const TextStyle(fontSize: 11, color: _tertiary)),
            ])),
          ]),
        ),
      );
    }

    final isConfirmed = iv.status.toLowerCase() == 'confirmed';
    final statusColor = isConfirmed ? const Color(0xFF34C759) : _amber;
    const formatColor = Color(0xFF5856D6);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => context.push('/business/interview/${iv.id}'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardBg, borderRadius: BorderRadius.circular(16),
            border: _subtleBorder,
            boxShadow: [_subtleShadow],
          ),
          child: Row(children: [
            // Date block
            Container(
              width: 62, padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFF2BB8B0).withValues(alpha: 0.10), borderRadius: BorderRadius.circular(12)),
              child: Column(children: [
                Text(iv.date.length >= 10 ? iv.date.substring(8, 10) : iv.date, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2BB8B0))),
                Text(_monthAbbr(iv.date), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF8E8E93))),
                const SizedBox(height: 2),
                Text(iv.time.toLowerCase(), maxLines: 1, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF3A3A3C))),
              ]),
            ),
            const SizedBox(width: 8),
            Container(width: 1, height: 50, color: const Color(0xFFE5E5EA)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(iv.candidateName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF3A3A3C))),
              Text(iv.jobTitle, style: const TextStyle(fontSize: 13, color: Color(0xFF8E8E93))),
              const SizedBox(height: 6),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                  child: Text(localizedInterviewStatus(context, iv.status), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: statusColor)),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: formatColor.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(20)),
                  child: Text(iv.format, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: formatColor)),
                ),
              ]),
            ])),
            const ForwardChevron(size: 28, color: Color(0xFFC7C7CC)),
          ]),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TABS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildTabs() {
    final t = AppLocalizations.of(context);
    final labels = [t.tabDashboard, t.tabCandidates, t.tabActivity];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(3, (i) {
          final active = _tabIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _tabIndex = i),
            child: Padding(
              padding: const EdgeInsets.only(right: 24),
              child: Column(children: [
                Text(labels[i], style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: active ? _charcoal : _tertiary)),
                const SizedBox(height: 8),
                Container(width: 28, height: 2, decoration: BoxDecoration(color: active ? _tealMain : Colors.transparent, borderRadius: BorderRadius.circular(1))),
              ]),
            ),
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 0 - DASHBOARD
  // ═══════════════════════════════════════════════════════════════

  Widget _buildDashboardTab(BusinessHomeData data) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Recent Applicants
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(AppLocalizations.of(context).recentApplicants, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: _charcoal, letterSpacing: -0.3)),
          GestureDetector(onTap: () => context.push('/business/applicants'), child: Text(AppLocalizations.of(context).viewAll, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _tealMain))),
        ]),
      ),
      const SizedBox(height: 12),
      if (data.recentApplicants.isEmpty)
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text(AppLocalizations.of(context).noApplicantsYet, style: const TextStyle(fontSize: 13, color: _tertiary)))
      else
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: data.recentApplicants.length,
            separatorBuilder: (_, i) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final a = data.recentApplicants[i];
              return GestureDetector(
                onTap: () {
                  final routeId = _candidateRouteId(a);
                  debugPrint('[Dashboard] TAP applicant id=${a.id}, candidateId=${a.candidateId}, pushing /business/candidate/$routeId');
                  context.push('/business/candidate/$routeId');
                },
                child: Container(
                  width: 110, padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16), border: _subtleBorder, boxShadow: [_subtleShadow]),
                  child: Column(children: [
                    _avatarCircle(a.initials, 40, 13),
                    const SizedBox(height: 8),
                    Text(a.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _charcoal), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                    Text(localizedJobRole(context, a.role), style: const TextStyle(fontSize: 11, color: _secondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ]),
                ),
              );
            },
          ),
        ),

      // Recent Activity
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: Text(AppLocalizations.of(context).recentActivity, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: _charcoal, letterSpacing: -0.3)),
      ),
      const SizedBox(height: 12),
      ...data.recentApplicants.take(5).map((a) => _activityRow(a)),
    ]);
  }

  Widget _activityRow(Applicant a) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: GestureDetector(
        onTap: () => context.push('/business/candidate/${_candidateRouteId(a)}'),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16), border: _subtleBorder, boxShadow: [_subtleShadow]),
          child: Row(children: [
            _avatarCircle(a.initials, 36, 12),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(AppLocalizations.of(context).notifAppliedForRole(a.name, localizedJobRole(context, a.role)), style: const TextStyle(fontSize: 13, color: _charcoal)),
              Text(a.status.displayName, style: const TextStyle(fontSize: 11, color: _tertiary)),
            ])),
            const ForwardChevron(size: 28, color: Color(0xFFC7C7CC)),
          ]),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 1 - CANDIDATES
  // ═══════════════════════════════════════════════════════════════

  Widget _buildCandidatesTab(BusinessHomeData data) {
    if (data.recentApplicants.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.people_outline, size: 40, color: _tertiary),
          const SizedBox(height: 12),
          Text(AppLocalizations.of(context).noApplicantsYet, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: _charcoal)),
        ])),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(20, 28, 20, 12), child: Text(AppLocalizations.of(context).candidatePipeline, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: _charcoal, letterSpacing: -0.3))),
      ...data.recentApplicants.map((a) {
        final sColor = _applicantStatusColor(a.status);
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: GestureDetector(
            onTap: () => context.push('/business/candidate/${_candidateRouteId(a)}'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16), border: _subtleBorder, boxShadow: [_subtleShadow]),
              child: Row(children: [
                _avatarCircle(a.initials, 40, 13),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(a.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: _charcoal)),
                    const SizedBox(width: 8),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: sColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(100)),
                      child: Text(a.status.displayName, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: sColor))),
                  ]),
                  const SizedBox(height: 2),
                  Text('${localizedJobRole(context, a.role)} · ${localizedCity(context, a.location)}', style: const TextStyle(fontSize: 13, color: _secondary)),
                ])),
                const ForwardChevron(size: 28, color: Color(0xFFC7C7CC)),
              ]),
            ),
          ),
        );
      }),
    ]);
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB 2 - ACTIVITY
  // ═══════════════════════════════════════════════════════════════

  Widget _buildActivityTab(BusinessHomeData data) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(20, 28, 20, 12), child: Text(AppLocalizations.of(context).allApplicants, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: _charcoal))),
      if (data.recentApplicants.isEmpty)
        Padding(padding: const EdgeInsets.all(40), child: Center(child: Text(AppLocalizations.of(context).noActivityYet, style: const TextStyle(fontSize: 13, color: _tertiary))))
      else
        ...data.recentApplicants.map((a) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: GestureDetector(
            onTap: () => context.push('/business/candidate/${_candidateRouteId(a)}'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16), border: _subtleBorder, boxShadow: [_subtleShadow]),
              child: Row(children: [
                _avatarCircle(a.initials, 36, 12),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(a.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: _charcoal)),
                  Text('${localizedJobRole(context, a.role)} · ${localizedCity(context, a.location)}', style: const TextStyle(fontSize: 13, color: _secondary)),
                  Text(a.status.displayName, style: const TextStyle(fontSize: 11, color: _tertiary)),
                ])),
                const ForwardChevron(size: 28, color: Color(0xFFC7C7CC)),
              ]),
            ),
          ),
        )),
    ]);
  }

  // ═══════════════════════════════════════════════════════════════
  // SEARCH OVERLAY
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSearchOverlay(BusinessHomeData data) {
    final q = _searchQuery.toLowerCase();
    final recentSearches = data.recentApplicants
        .map((a) => a.name)
        .where((name) => name.trim().isNotEmpty)
        .take(3)
        .toList();
    final results = q.isEmpty ? <Applicant>[] : data.recentApplicants.where((a) =>
      a.name.toLowerCase().contains(q) || a.role.toLowerCase().contains(q) || a.location.toLowerCase().contains(q),
    ).toList();
    // Smart rank: name starts-with → role starts-with → contains; alpha within rank.
    results.sort((a, b) {
      int r(Applicant x) {
        final n = x.name.toLowerCase(), ro = x.role.toLowerCase();
        if (n == q) return 0;
        if (n.startsWith(q)) return 1;
        if (ro.startsWith(q)) return 2;
        return 3;
      }
      final ra = r(a), rb = r(b);
      if (ra != rb) return ra - rb;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return Positioned.fill(child: Material(
      color: _bgMain,
      child: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Search bar + Cancel
        Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 0), child: Row(children: [
          Expanded(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const Icon(CupertinoIcons.search, size: 16, color: _tertiary),
              const SizedBox(width: 8),
              Expanded(child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(fontSize: 15, color: _charcoal),
                decoration: InputDecoration(hintText: AppLocalizations.of(context).searchRecentApplicantsHint, hintStyle: const TextStyle(fontSize: 15, color: _tertiary), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 14)),
              )),
              if (_searchQuery.isNotEmpty) GestureDetector(onTap: () => setState(() { _searchQuery = ''; _searchCtrl.clear(); }), child: const Icon(Icons.close, size: 16, color: _tertiary)),
            ]),
          )),
          const SizedBox(width: 12),
          GestureDetector(onTap: () => setState(() { _showSearch = false; _searchQuery = ''; _searchCtrl.clear(); }),
            child: Text(AppLocalizations.of(context).cancel, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: _tealMain))),
        ])),

        // Results or recent
        Expanded(
          child: _searchQuery.isEmpty
              ? ListView(
                  padding: const EdgeInsets.fromLTRB(0, 24, 0, 24),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Text(
                        AppLocalizations.of(context).recentSearches,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _secondary,
                        ),
                      ),
                    ),
                    if (recentSearches.isEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context).recentSearchesEmptyTitle,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: _charcoal,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppLocalizations.of(context).recentSearchesEmptyHint,
                              style: const TextStyle(
                                fontSize: 13,
                                color: _secondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...recentSearches.map(_recentSearchRow),
                  ],
                )
              : results.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              AppLocalizations.of(context).noMatchingApplicants,
                              style: const TextStyle(fontSize: 15, color: _tertiary),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context).searchLooksAtRecentApplicants,
                              style: const TextStyle(fontSize: 13, color: _secondary),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      itemCount: results.length,
                      itemBuilder: (context, i) {
                        final a = results[i];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _showSearch = false;
                              _searchQuery = '';
                              _searchCtrl.clear();
                            });
                            context.push('/business/candidate/${_candidateRouteId(a)}');
                          },
                          child: Padding(padding: const EdgeInsets.only(bottom: 8), child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))]),
                            child: Row(children: [
                              _avatarCircle(a.initials, 36, 12),
                              const SizedBox(width: 12),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(a.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: _charcoal)),
                                Text('${localizedJobRole(context, a.role)} · ${localizedCity(context, a.location)}', style: const TextStyle(fontSize: 13, color: _secondary)),
                              ])),
                              const ForwardChevron(size: 28, color: Color(0xFFC7C7CC)),
                            ]),
                          )),
                        );
                      },
                    ),
        ),
      ])),
    ));
  }

  Widget _recentSearchRow(String text) {
    return Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 0), child: GestureDetector(
      onTap: () => setState(() { _searchQuery = text; _searchCtrl.text = text; }),
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Row(children: [
        const Icon(Icons.access_time, size: 16, color: _tertiary),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 15, color: _charcoal))),
        const Icon(Icons.close, size: 14, color: _tertiary),
      ])),
    ));
  }

  // ═══════════════════════════════════════════════════════════════
  // CREATE MENU OVERLAY
  // ═══════════════════════════════════════════════════════════════

  Widget _buildCreateOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _showCreateMenu = false),
        child: Container(
          color: Colors.black.withValues(alpha: 0.30),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(20)),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  _menuItem(
                    CupertinoIcons.briefcase,
                    AppLocalizations.of(context).postJobShort,
                    AppLocalizations.of(context).hireBestTalent,
                    onTap: () {
                      setState(() => _showCreateMenu = false);
                      context.push('/business/post-job');
                    },
                  ),
                  const SizedBox(height: 12),
                  _menuItem(
                    CupertinoIcons.pencil,
                    AppLocalizations.of(context).createUpdate,
                    AppLocalizations.of(context).shareCompanyNews,
                    enabled: false,
                  ),
                  const SizedBox(height: 12),
                  _menuItem(
                    CupertinoIcons.camera,
                    AppLocalizations.of(context).addStory,
                    AppLocalizations.of(context).showWorkplace,
                    enabled: false,
                  ),
                  const SizedBox(height: 12),
                  _menuItem(
                    CupertinoIcons.star,
                    AppLocalizations.of(context).viewShortlist,
                    AppLocalizations.of(context).yourSavedCandidates,
                    onTap: () {
                      setState(() => _showCreateMenu = false);
                      context.push('/business/shortlist');
                    },
                  ),
                  const SizedBox(height: 12),
                  _menuItem(
                    CupertinoIcons.person_badge_plus,
                    AppLocalizations.of(context).inviteCandidate,
                    AppLocalizations.of(context).reachOutDirectly,
                    enabled: false,
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    final l = AppLocalizations.of(context);
    final titleColor =
        enabled ? _charcoal : _charcoal.withValues(alpha: 0.6);
    final subtitleColor =
        enabled ? _secondary : _secondary.withValues(alpha: 0.7);
    final iconBg = enabled ? _tealLight : _surface;
    final iconColor = enabled ? _tealMain : _tertiary;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: Icon(icon, size: 18, color: iconColor)),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: titleColor,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: subtitleColor),
          ),
        ])),
        if (enabled)
          const ForwardChevron(size: 28, color: Color(0xFFC7C7CC))
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: _divider),
            ),
            child: Text(
              l.comingSoonShort,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _tertiary,
              ),
            ),
          ),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════

  Widget _avatarCircle(String initials, double size, double fontSize) {
    final hue = (initials.hashCode % 360).abs().toDouble();
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HSVColor.fromAHSV(1, hue, 0.45, 0.90).toColor(),
            HSVColor.fromAHSV(1, hue, 0.55, 0.75).toColor(),
          ],
        ),
      ),
      child: Center(child: Text(initials, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white))),
    );
  }

  String _monthAbbr(String date) {
    if (date.length < 7) return '';
    final m = int.tryParse(date.substring(5, 7));
    if (m == null || m < 1 || m > 12) return '';
    return AppLocalizations.of(context).monthAbbr(m);
  }

  Widget _statusLine(IconData icon, String text, Color color) {
    return Row(children: [
      Icon(icon, size: 12, color: color),
      const SizedBox(width: 6),
      Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
    ]);
  }

  Widget _buildHiringProgress(BusinessHomeData data) {
    final t = AppLocalizations.of(context);
    final steps = [
      (t.statusPosted, data.activeJobs.isNotEmpty),
      (t.statusApplicants, data.totalApplicants > 0),
      (t.statusInterviewsShort, data.interviewCount > 0),
      (t.statusHiredShort, data.hiredCount > 0),
    ];
    return Row(children: [
      for (int i = 0; i < steps.length; i++) ...[
        if (i > 0) Expanded(child: Container(height: 2, color: steps[i].$2 ? const Color(0xFF2BB8B0) : const Color(0xFFE5E5EA))),
        Container(
          width: 24, height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: steps[i].$2 ? const Color(0xFF2BB8B0) : const Color(0xFFE5E5EA),
          ),
          child: Center(child: steps[i].$2
            ? const Icon(CupertinoIcons.checkmark, size: 12, color: Colors.white)
            : Text('${i + 1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF8E8E93)))),
        ),
      ],
    ]);
  }

  Color _applicantStatusColor(ApplicantStatus s) => switch (s) {
        ApplicantStatus.applied => _tealMain,
        ApplicantStatus.underReview => _amber,
        ApplicantStatus.shortlisted => const Color(0xFFAF52DE),
        ApplicantStatus.interviewInvited => const Color(0xFFFF9500),
        ApplicantStatus.interviewScheduled => _indigo,
        ApplicantStatus.hired => const Color(0xFF34C759),
        ApplicantStatus.rejected => _tertiary,
        ApplicantStatus.withdrawn => _tertiary,
      };
}

// ═══════════════════════════════════════════════════════════════
// STAT CARD
// ═══════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int count;
  final String label;
  final String? badge;
  final VoidCallback? onTap;
  const _StatCard({required this.icon, required this.color, required this.count, required this.label, this.badge, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEFEFF4), width: 0.5),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.035), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.11), borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                child: Icon(icon, size: 17, color: color),
              ),
              const Spacer(),
              if (badge != null) Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(7)),
                child: Text(badge!, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.2)),
              ),
            ]),
            const SizedBox(height: 14),
            Text('$count', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E), letterSpacing: -0.6, height: 1)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: Color(0xFF707580), letterSpacing: -0.1), maxLines: 1, overflow: TextOverflow.clip, softWrap: false),
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// QUICK ACTION
// ═══════════════════════════════════════════════════════════════

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final String label;
  final bool gradient;
  final VoidCallback? onTap;
  const _QuickAction({required this.icon, this.iconSize = 26, required this.label, this.gradient = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: gradient ? null : const Color(0xFF2BB8B0).withValues(alpha: 0.08),
            gradient: gradient ? const LinearGradient(colors: [Color(0xFF2BB8B0), Color(0xFF1A9090)], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: iconSize, color: gradient ? Colors.white : const Color(0xFF2BB8B0)),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: gradient ? Colors.white : const Color(0xFF3A3A3C)),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
      ),
    );
  }
}
