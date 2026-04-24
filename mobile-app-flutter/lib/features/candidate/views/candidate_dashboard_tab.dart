import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/providers/candidate_providers.dart';

class CandidateDashboardTab extends StatefulWidget {
  const CandidateDashboardTab({super.key});

  @override
  State<CandidateDashboardTab> createState() => _CandidateDashboardTabState();
}

class _CandidateDashboardTabState extends State<CandidateDashboardTab> {
  static const _tealLight = Color(0xFFE0F7F6);
  static const _purpleLight = Color(0xFFF0EEFF);
  static const _orangeLight = Color(0xFFFFF4E5);
  static const _greenLight = Color(0xFFE5F7EE);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CandidateHomeProvider>().load();
    });
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    final l10n = Localizations.localeOf(context).languageCode;
    if (hour < 12) {
      return switch (l10n) {
        'it' => 'Buongiorno',
        'ar' => 'صباح الخير',
        _ => 'Good morning',
      };
    }
    if (hour < 17) {
      return switch (l10n) {
        'it' => 'Buon pomeriggio',
        'ar' => 'مساء الخير',
        _ => 'Good afternoon',
      };
    }
    return switch (l10n) {
      'it' => 'Buonasera',
      'ar' => 'مساء الخير',
      _ => 'Good evening',
    };
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CandidateHomeProvider>();

    if (provider.loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.teal)),
      );
    }

    if (provider.error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                provider.error!,
                style: const TextStyle(fontSize: 14, color: AppColors.secondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<CandidateHomeProvider>().load(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                ),
                child: Text(context.dashboardRetryLabel),
              ),
            ],
          ),
        ),
      );
    }

    final data = provider.data;
    if (data == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.teal)),
      );
    }

    final profile = data.profile;
    final nextInterview = data.nextInterview;
    final unreadMessages = data.unreadMessages;
    final hasNotifications = unreadMessages > 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _buildHeader(
              firstName: profile.firstName,
              hasNotifications: hasNotifications,
            ),
            const SizedBox(height: 16),
            _buildHeaderCard(
              fullName: profile.name,
              photoUrl: profile.photoUrl,
              initials: profile.initials,
              unreadMessages: unreadMessages,
              hasNextInterview: nextInterview != null,
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(
              title: context.dashboardNextInterviewTitle,
              linkText: context.dashboardSeeAllLabel,
              onLinkTap: () => context.push('/candidate/interviews'),
            ),
            const SizedBox(height: 10),
            nextInterview != null
                ? _buildNextInterviewCard(
                    title: nextInterview.jobTitle,
                    date: nextInterview.date,
                    time: nextInterview.time,
                    format: nextInterview.format.displayName,
                    status: nextInterview.status.displayName,
                    onTap: () =>
                        context.push('/candidate/interview/${nextInterview.id}'),
                  )
                : _buildNoInterviewCard(
                    onTap: () => context.push('/candidate/interviews'),
                  ),
            const SizedBox(height: 24),
            _buildActionsGrid(),
            const SizedBox(height: 24),
            _buildApplicationsSection(
              applied: data.totalApplications,
              inReview: data.underReviewCount,
              interview: data.interviewCount,
              offer: data.offerCount,
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── HEADER ──────────────────────────────────────────────

  Widget _buildHeader({
    required String firstName,
    required bool hasNotifications,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.teal,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Text(
              'P',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${_greeting()}, $firstName',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () => context.push('/candidate/nearby'),
            icon: const Icon(Icons.search, color: AppColors.charcoal, size: 22),
            splashRadius: 22,
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () => context.push('/candidate/notifications'),
                icon: const Icon(Icons.notifications_outlined,
                    color: AppColors.charcoal, size: 22),
                splashRadius: 22,
              ),
              if (hasNotifications)
                Positioned(
                  right: 10,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            onPressed: () => context.push('/candidate/messages'),
            icon: const Icon(Icons.chat_bubble_outline,
                color: AppColors.charcoal, size: 22),
            splashRadius: 22,
          ),
        ],
      ),
    );
  }

  // ── CAREER DASHBOARD HERO CARD ─────────────────────────

  Widget _buildHeaderCard({
    required String fullName,
    required String? photoUrl,
    required String initials,
    required int unreadMessages,
    required bool hasNextInterview,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.dashboardHeroEyebrow,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.teal,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        hasNextInterview
                            ? context.dashboardHeroWithInterviewTitle
                            : context.dashboardHeroWithoutInterviewTitle,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.charcoal,
                          letterSpacing: -0.3,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$fullName \u00B7 ${context.dashboardHospitalityProLabel}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: hasNextInterview
                                  ? AppColors.green
                                  : AppColors.tertiary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            hasNextInterview
                                ? context.dashboardInterviewScheduledLabel
                                : context.dashboardNoInterviewScheduledLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: hasNextInterview
                                  ? AppColors.green
                                  : AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _buildAvatar(photoUrl: photoUrl, initials: initials),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _purpleLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 16, color: AppColors.purple),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      hasNextInterview
                          ? context.dashboardInterviewComingUpLabel
                          : context.dashboardNoUpcomingInterviewLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.charcoal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Icon(Icons.chat_bubble_outline,
                      size: 16, color: AppColors.purple),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      context.dashboardUnreadMessagesLabel(unreadMessages),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.charcoal,
                      ),
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildAvatar({required String? photoUrl, required String initials}) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.teal.withValues(alpha: 0.12),
              image: photoUrl != null && photoUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(photoUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: photoUrl == null || photoUrl.isEmpty
                ? Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.teal,
                    ),
                  )
                : null,
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.teal,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
              ),
              child: const Icon(Icons.check, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ── NEXT INTERVIEW CARD ────────────────────────────────

  Widget _buildSectionHeader({
    required String title,
    required String linkText,
    required VoidCallback onLinkTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.charcoal,
            ),
          ),
          GestureDetector(
            onTap: onLinkTap,
            child: Row(
              children: [
                Text(
                  linkText,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.teal,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.chevron_right, size: 18, color: AppColors.teal),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextInterviewCard({
    required String title,
    required String date,
    required String time,
    required String format,
    required String status,
    required VoidCallback onTap,
  }) {
    final dateParts = _splitDate(date);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _tealLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      dateParts.month,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.teal,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateParts.day,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.teal,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.teal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _chip(
                          label: status,
                          bg: _greenLight,
                          fg: AppColors.green,
                        ),
                        const SizedBox(width: 6),
                        _chip(
                          label: format,
                          bg: _purpleLight,
                          fg: AppColors.purple,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  size: 22, color: AppColors.tertiary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoInterviewCard({
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: AppColors.tertiary,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.dashboardNoInterviewScheduledLabel,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      context.dashboardNoInterviewBody,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 22,
                color: AppColors.tertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip({
    required String label,
    required Color bg,
    required Color fg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  ({String month, String day}) _splitDate(String date) {
    final trimmed = date.trim();
    if (trimmed.isEmpty) return (month: 'APR', day: '15');
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      final first = parts.first;
      final second = parts[1];
      if (int.tryParse(first) != null) {
        return (month: second.toUpperCase(), day: first);
      }
      return (month: first.toUpperCase(), day: second);
    }
    return (month: trimmed.toUpperCase(), day: '');
  }

  // ── ACTIONS GRID (2×2) ─────────────────────────────────

  Widget _buildActionsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildActionTile(
                  label: context.dashboardFindJobsLabel,
                  icon: Icons.search,
                  filled: true,
                  onTap: () => context.push('/candidate/jobs'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionTile(
                  label: context.dashboardApplicationsLabel,
                  icon: Icons.description_outlined,
                  filled: false,
                  onTap: () => context.push('/candidate/applications'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionTile(
                  label: context.dashboardMessagesLabel,
                  icon: Icons.chat_bubble_outline,
                  filled: false,
                  onTap: () => context.push('/candidate/messages'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionTile(
                  label: context.dashboardCommunityLabel,
                  icon: Icons.people_alt_outlined,
                  filled: false,
                  onTap: () => context.push('/feed'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String label,
    required IconData icon,
    required bool filled,
    required VoidCallback onTap,
  }) {
    final bg = filled ? AppColors.teal : _tealLight;
    final iconBg = filled ? Colors.white.withValues(alpha: 0.22) : Colors.white;
    final iconColor = filled ? Colors.white : AppColors.teal;
    final labelColor = filled ? Colors.white : AppColors.charcoal;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 18, color: iconColor),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: labelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── MY APPLICATIONS ────────────────────────────────────

  Widget _buildApplicationsSection({
    required int applied,
    required int inReview,
    required int interview,
    required int offer,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.dashboardMyApplicationsTitle,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.charcoal,
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/candidate/applications'),
                child: Row(
                  children: [
                    Text(
                      context.dashboardViewAllLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.teal,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right, size: 18, color: AppColors.teal),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricColumn(
                  count: applied,
                  label: context.dashboardAppliedLabel,
                  bg: _tealLight,
                  fg: AppColors.teal,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricColumn(
                  count: inReview,
                  label: context.dashboardInReviewLabel,
                  bg: _purpleLight,
                  fg: AppColors.purple,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricColumn(
                  count: interview,
                  label: context.dashboardInterviewLabel,
                  bg: _orangeLight,
                  fg: AppColors.amber,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricColumn(
                  count: offer,
                  label: context.dashboardOfferLabel,
                  bg: _greenLight,
                  fg: AppColors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn({
    required int count,
    required String label,
    required Color bg,
    required Color fg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: fg,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── BOTTOM NAV ─────────────────────────────────────────

  Widget _buildBottomNav() {
    return Material(
      color: Colors.white,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildNavTab(
                icon: Icons.home,
                label: context.dashboardHomeLabel,
                active: true,
                color: AppColors.teal,
                onTap: () {},
              ),
              _buildNavTab(
                icon: Icons.work_outline,
                label: context.dashboardJobsLabel,
                active: false,
                color: AppColors.tertiary,
                onTap: () => context.push('/candidate/jobs'),
              ),
              _buildCenterPlus(),
              _buildNavTab(
                icon: Icons.bolt,
                label: context.dashboardQuickPlugLabel,
                active: false,
                color: AppColors.purple,
                onTap: () => context.push('/candidate/quick-plug'),
              ),
              _buildNavTab(
                icon: Icons.person_outline,
                label: context.dashboardProfileLabel,
                active: false,
                color: AppColors.tertiary,
                onTap: () => context.push('/candidate/profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavTab({
    required IconData icon,
    required String label,
    required bool active,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterPlus() {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => context.push('/candidate/quick-plug'),
        child: Center(
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.teal,
              boxShadow: [
                BoxShadow(
                  color: AppColors.teal.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add, size: 28, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

extension _CandidateDashboardL10n on BuildContext {
  String get _lang => Localizations.localeOf(this).languageCode;

  String get dashboardRetryLabel => switch (_lang) {
        'it' => 'Riprova',
        'ar' => 'إعادة المحاولة',
        _ => 'Retry',
      };

  String get dashboardNextInterviewTitle => switch (_lang) {
        'it' => 'Prossima intervista',
        'ar' => 'المقابلة القادمة',
        _ => 'Next Interview',
      };

  String get dashboardSeeAllLabel => switch (_lang) {
        'it' => 'Vedi tutto',
        'ar' => 'عرض الكل',
        _ => 'See All',
      };

  String get dashboardHeroEyebrow => switch (_lang) {
        'it' => 'DASHBOARD CARRIERA',
        'ar' => 'لوحة المسار المهني',
        _ => 'CAREER DASHBOARD',
      };

  String get dashboardHeroWithInterviewTitle => switch (_lang) {
        'it' => 'La tua prossima intervista',
        'ar' => 'مقابلتك القادمة',
        _ => 'Your next interview',
      };

  String get dashboardHeroWithoutInterviewTitle => switch (_lang) {
        'it' => 'La tua dashboard carriera',
        'ar' => 'لوحة مسارك المهني',
        _ => 'Your career dashboard',
      };

  String get dashboardHospitalityProLabel => switch (_lang) {
        'it' => 'Professionista hospitality',
        'ar' => 'محترف ضيافة',
        _ => 'Hospitality Pro',
      };

  String get dashboardInterviewScheduledLabel => switch (_lang) {
        'it' => 'Intervista programmata',
        'ar' => 'تمت جدولة مقابلة',
        _ => 'Interview scheduled',
      };

  String get dashboardNoInterviewScheduledLabel => switch (_lang) {
        'it' => 'Nessuna intervista programmata',
        'ar' => 'لا توجد مقابلة مجدولة',
        _ => 'No interview scheduled',
      };

  String get dashboardInterviewComingUpLabel => switch (_lang) {
        'it' => 'Intervista in arrivo',
        'ar' => 'هناك مقابلة قادمة',
        _ => 'Interview coming up',
      };

  String get dashboardNoUpcomingInterviewLabel => switch (_lang) {
        'it' => 'Nessuna intervista in arrivo',
        'ar' => 'لا توجد مقابلة قادمة',
        _ => 'No upcoming interview',
      };

  String dashboardUnreadMessagesLabel(int count) => switch (_lang) {
        'it' => '$count messagg${count == 1 ? 'io non letto' : 'i non letti'}',
        'ar' => count == 1 ? 'رسالة واحدة غير مقروءة' : '$count رسائل غير مقروءة',
        _ => '$count unread message${count == 1 ? '' : 's'}',
      };

  String get dashboardNoInterviewBody => switch (_lang) {
        'it' => 'Gli aggiornamenti sulle interviste appariranno qui quando ne verrà fissata una.',
        'ar' => 'ستظهر تحديثات المقابلات هنا عندما يتم حجز واحدة.',
        _ => 'Interview updates will appear here when one is booked.',
      };

  String get dashboardFindJobsLabel => switch (_lang) {
        'it' => 'Trova lavori',
        'ar' => 'ابحث عن وظائف',
        _ => 'Find Jobs',
      };

  String get dashboardApplicationsLabel => switch (_lang) {
        'it' => 'Candidature',
        'ar' => 'الطلبات',
        _ => 'Applications',
      };

  String get dashboardMessagesLabel => switch (_lang) {
        'it' => 'Messaggi',
        'ar' => 'الرسائل',
        _ => 'Messages',
      };

  String get dashboardCommunityLabel => switch (_lang) {
        'it' => 'Community',
        'ar' => 'المجتمع',
        _ => 'Community',
      };

  String get dashboardMyApplicationsTitle => switch (_lang) {
        'it' => 'Le mie candidature',
        'ar' => 'طلباتي',
        _ => 'My Applications',
      };

  String get dashboardViewAllLabel => switch (_lang) {
        'it' => 'Vedi tutto',
        'ar' => 'عرض الكل',
        _ => 'View all',
      };

  String get dashboardAppliedLabel => switch (_lang) {
        'it' => 'Inviate',
        'ar' => 'تم التقديم',
        _ => 'Applied',
      };

  String get dashboardInReviewLabel => switch (_lang) {
        'it' => 'In revisione',
        'ar' => 'قيد المراجعة',
        _ => 'In Review',
      };

  String get dashboardInterviewLabel => switch (_lang) {
        'it' => 'Colloquio',
        'ar' => 'مقابلة',
        _ => 'Interview',
      };

  String get dashboardOfferLabel => switch (_lang) {
        'it' => 'Offerta',
        'ar' => 'عرض',
        _ => 'Offer',
      };

  String get dashboardHomeLabel => switch (_lang) {
        'it' => 'Home',
        'ar' => 'الرئيسية',
        _ => 'Home',
      };

  String get dashboardJobsLabel => switch (_lang) {
        'it' => 'Lavori',
        'ar' => 'الوظائف',
        _ => 'Jobs',
      };

  String get dashboardQuickPlugLabel => switch (_lang) {
        'it' => 'Quick Plug',
        'ar' => 'كويك بلج',
        _ => 'Quick Plug',
      };

  String get dashboardProfileLabel => switch (_lang) {
        'it' => 'Profilo',
        'ar' => 'الملف الشخصي',
        _ => 'Profile',
      };
}
