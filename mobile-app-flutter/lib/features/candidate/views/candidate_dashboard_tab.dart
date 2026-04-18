import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/models/interview.dart';
import 'package:plagit/providers/candidate_providers.dart';

class CandidateDashboardTab extends StatefulWidget {
  const CandidateDashboardTab({super.key});

  @override
  State<CandidateDashboardTab> createState() => _CandidateDashboardTabState();
}

class _CandidateDashboardTabState extends State<CandidateDashboardTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CandidateHomeProvider>().load();
    });
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CandidateHomeProvider>();

    if (provider.loading) {
      return Container(
        color: AppColors.background,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: AppColors.teal),
      );
    }

    if (provider.error != null) {
      return Container(
        color: AppColors.background,
        alignment: Alignment.center,
        child: Center(
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
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final data = provider.data;
    if (data == null) {
      return Container(
        color: AppColors.background,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: AppColors.teal),
      );
    }

    final profile = data.profile;
    final interview = data.nextInterview;
    final role = profile.role ?? 'Hospitality Pro';

    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            // ── 1. HEADER (logo + greeting + actions) ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
              child: Row(
                children: [
                  Image.asset(
                    'assets/branding/plagit_logo.png',
                    height: 28,
                    errorBuilder: (_, _, _) => const Text(
                      'Plagit',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.teal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${_greeting()}, ${profile.firstName}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.charcoal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _HeaderIconButton(
                    icon: Icons.search,
                    onTap: () => context.push('/candidate/nearby'),
                  ),
                  _HeaderIconButton(
                    icon: Icons.notifications_outlined,
                    onTap: () => context.push('/candidate/notifications'),
                    showDot: true,
                  ),
                  _HeaderIconButton(
                    icon: Icons.chat_bubble_outline,
                    onTap: () => context.push('/candidate/messages/1'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ── 2. HERO CARD ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _HeroCard(
                profileInitials: profile.initials,
                profilePhotoUrl: profile.photoUrl,
                firstName: profile.firstName,
                role: role,
                hasLiveInterview: interview != null,
                unreadMessages: data.unreadMessages,
                onTap: () {
                  if (interview != null) {
                    context.push('/candidate/interviews/${interview.id}');
                  }
                },
              ),
            ),

            const SizedBox(height: 26),

            // ── 3. NEXT INTERVIEW ──
            if (interview != null) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: _SectionTitle('Next Interview'),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _InterviewCard(
                  interview: interview,
                  onTap: () => context.push('/candidate/interviews/${interview.id}'),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ── 4. 4-TILE GRID ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: [
                  _ActionTile(
                    icon: Icons.search,
                    label: 'Find Jobs',
                    color: AppColors.teal,
                    onTap: () => context.push('/candidate/nearby'),
                  ),
                  _ActionTile(
                    icon: Icons.description_outlined,
                    label: 'Applications',
                    color: AppColors.amber,
                    badge: data.totalApplications > 0 ? '${data.totalApplications}' : null,
                    onTap: () => context.push('/candidate/applications'),
                  ),
                  _ActionTile(
                    icon: Icons.chat_bubble_outline,
                    label: 'Messages',
                    color: AppColors.purple,
                    badge: data.unreadMessages > 0 ? '${data.unreadMessages}' : null,
                    onTap: () => context.push('/candidate/messages/1'),
                  ),
                  _ActionTile(
                    icon: Icons.forum_outlined,
                    label: 'Community',
                    color: AppColors.green,
                    onTap: () => context.push('/feed'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── 5. MY APPLICATIONS ──
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: _SectionTitle('My Applications'),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _StatCard(
                    count: '${data.totalApplications}',
                    label: 'Applied',
                    color: AppColors.teal,
                  ),
                  const SizedBox(width: 10),
                  _StatCard(
                    count: '${data.underReviewCount}',
                    label: 'In Review',
                    color: AppColors.amber,
                  ),
                  const SizedBox(width: 10),
                  _StatCard(
                    count: '${data.interviewCount}',
                    label: 'Interview',
                    color: AppColors.purple,
                  ),
                  const SizedBox(width: 10),
                  _StatCard(
                    count: '${data.offerCount}',
                    label: 'Offer',
                    color: AppColors.green,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header icon with optional red dot ──
// (unchanged)

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool showDot;

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, size: 22, color: AppColors.charcoal),
            if (showDot)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Section title ──

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.charcoal,
      ),
    );
  }
}

// ── Hero card ──

class _HeroCard extends StatelessWidget {
  final String profileInitials;
  final String? profilePhotoUrl;
  final String firstName;
  final String role;
  final bool hasLiveInterview;
  final int unreadMessages;
  final VoidCallback onTap;

  const _HeroCard({
    required this.profileInitials,
    required this.profilePhotoUrl,
    required this.firstName,
    required this.role,
    required this.hasLiveInterview,
    required this.unreadMessages,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E4A52), Color(0xFF0D3035)],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0D3035).withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 10),
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
                        'CAREER DASHBOARD',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.6,
                          color: AppColors.lightTeal.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Your next interview',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$firstName · $role',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (hasLiveInterview)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.green.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: AppColors.green.withValues(alpha: 0.45),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppColors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                '1 live',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Profile avatar on the right
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.lightTeal.withValues(alpha: 0.25),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 2,
                    ),
                    image: (profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty)
                        ? DecorationImage(
                            image: NetworkImage(profilePhotoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: (profilePhotoUrl == null || profilePhotoUrl!.isEmpty)
                      ? Center(
                          child: Text(
                            profileInitials,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Inner status box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.10),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _HeroStatusRow(
                      icon: Icons.event_available,
                      label: hasLiveInterview
                          ? 'Interview coming up'
                          : 'No interview scheduled',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 28,
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                  Expanded(
                    child: _HeroStatusRow(
                      icon: Icons.mark_email_unread_outlined,
                      label: unreadMessages == 1
                          ? '1 unread message'
                          : '$unreadMessages unread messages',
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
}

class _HeroStatusRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroStatusRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 15, color: AppColors.lightTeal),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── Interview card ──

class _InterviewCard extends StatelessWidget {
  final Interview interview;
  final VoidCallback onTap;

  const _InterviewCard({required this.interview, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final parts = interview.date.split(' ');
    final dateDay = parts.isNotEmpty ? parts.first : interview.date;
    final dateMonth = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppColors.cardDecoration,
        child: Row(
          children: [
            // Date box
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dateDay,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.teal,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateMonth.isNotEmpty ? dateMonth : interview.time,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.teal,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    interview.time,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
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
                    interview.jobTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (interview.company.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      interview.company,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _Pill(
                        label: interview.status.displayName,
                        color: AppColors.green,
                        filled: interview.status == InterviewStatus.confirmed,
                      ),
                      _Pill(
                        label: interview.format.displayName,
                        color: AppColors.purple,
                        icon: _iconForFormat(interview.format),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.tertiary),
          ],
        ),
      ),
    );
  }

  IconData _iconForFormat(InterviewFormat f) {
    switch (f) {
      case InterviewFormat.video:
        return Icons.videocam_outlined;
      case InterviewFormat.phone:
        return Icons.call_outlined;
      case InterviewFormat.inPerson:
        return Icons.place_outlined;
    }
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;
  final IconData? icon;

  const _Pill({
    required this.label,
    required this.color,
    this.filled = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bg = filled ? color : color.withValues(alpha: 0.12);
    final fg = filled ? Colors.white : color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action tile ──

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String? badge;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppColors.cardDecoration,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                  ),
                ),
              ],
            ),
            if (badge != null)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Stat card (My Applications) ──

class _StatCard extends StatelessWidget {
  final String count;
  final String label;
  final Color color;

  const _StatCard({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
                height: 1,
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
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
