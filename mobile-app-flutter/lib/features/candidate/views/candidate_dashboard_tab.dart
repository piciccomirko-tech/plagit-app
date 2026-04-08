import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/widgets/empty_state.dart';
import 'package:plagit/models/job.dart';
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

    // Loading state
    if (provider.loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.teal)),
      );
    }

    // Error state
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
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final data = provider.data;
    if (data == null) {
      // Auth handler may have intercepted — show loading while redirecting
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.teal)),
      );
    }
    final profile = data.profile;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            // ── HEADER ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.teal,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        profile.initials,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_greeting()}, ${profile.firstName}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.charcoal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '\u{1F4CD} ${profile.location ?? 'Unknown'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.go('/candidate/messages/1'),
                    icon: const Icon(Icons.chat_bubble_outline, color: AppColors.charcoal, size: 22),
                  ),
                  IconButton(
                    onPressed: () => context.push('/candidate/notifications'),
                    icon: const Icon(Icons.notifications_outlined, color: AppColors.charcoal, size: 22),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── SEARCH BAR ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEF0),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: AppColors.secondary, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Search jobs, roles, restaurants...',
                      style: TextStyle(fontSize: 14, color: AppColors.tertiary),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── 1. EXPLORE NEARBY JOBS ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _TapCard(
                onTap: () => context.push('/candidate/nearby'),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.teal,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.map, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Explore Nearby Jobs',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                          SizedBox(height: 2),
                          Text('Find opportunities on the map around you',
                              style: TextStyle(fontSize: 12, color: AppColors.secondary)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.tertiary),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── 2. YOUR NEXT STEP ──
            if (data.nextInterview != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: AppColors.cardDecoration,
                  clipBehavior: Clip.antiAlias,
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        Container(width: 3, color: AppColors.gold),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '\u2726 YOUR NEXT STEP',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.gold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text('Interview scheduled',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                                const SizedBox(height: 4),
                                Text(data.nextInterview!.jobTitle,
                                    style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
                                const SizedBox(height: 2),
                                Text('${data.nextInterview!.date} \u00B7 ${data.nextInterview!.time}',
                                    style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.purple.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(data.nextInterview!.format.displayName,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.purple)),
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => context.push('/candidate/interviews/${data.nextInterview!.id}'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.teal,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: const Text('View Details', style: TextStyle(fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            if (data.nextInterview != null) const SizedBox(height: 16),

            // ── 3. YOUR MATCHES ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _TapCard(
                onTap: () => context.push('/candidate/matches'),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.teal,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your Matches',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                          SizedBox(height: 2),
                          Text('Jobs matching your role and job type',
                              style: TextStyle(fontSize: 12, color: AppColors.secondary)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.tertiary),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── 4. UNLOCK PREMIUM ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _TapCard(
                onTap: () => context.push('/candidate/subscription'),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.amber,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.workspace_premium, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Unlock Premium',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                          SizedBox(height: 2),
                          Text('Get more visibility and better matches',
                              style: TextStyle(fontSize: 12, color: AppColors.secondary)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.amber),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── 5. JOBS NEAR YOU ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Jobs Near You',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                  GestureDetector(
                    onTap: () => context.push('/candidate/nearby'),
                    child: const Text('See All >',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.teal)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 4),
              child: Text(
                '\u{1F4CD} ${data.nearbyJobs.length} jobs available',
                style: const TextStyle(fontSize: 12, color: AppColors.secondary),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 155,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: data.nearbyJobs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final job = data.nearbyJobs[i];
                  return _CompactJobCard(
                    job: job,
                    onTap: () => context.push('/candidate/job/${job.id}'),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // ── 6. FEATURED JOBS ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Featured Jobs',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                  GestureDetector(
                    onTap: () => context.push('/candidate/nearby'),
                    child: const Text('See All >',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.teal)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: data.featuredJobs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final job = data.featuredJobs[i];
                  return _FeaturedJobCard(
                    job: job,
                    onTap: () => context.push('/candidate/job/${job.id}'),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // ── 7. MY APPLICATIONS ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: AppColors.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('My Applications',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                        GestureDetector(
                          onTap: () => context.push('/candidate/applications'),
                          child: const Text('View All',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.teal)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _StatCell(count: '${data.totalApplications}', label: 'Applied', color: AppColors.secondary),
                        const SizedBox(width: 8),
                        _StatCell(count: '${data.underReviewCount}', label: 'Under Review', color: AppColors.amber),
                        const SizedBox(width: 8),
                        _StatCell(count: '${data.interviewCount}', label: 'Interview', color: AppColors.teal),
                        const SizedBox(width: 8),
                        _StatCell(count: '${data.offerCount}', label: 'Offer', color: AppColors.green),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── 8. NEXT INTERVIEW ──
            if (data.nextInterview != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AppColors.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.calendar_today, color: AppColors.teal, size: 18),
                          SizedBox(width: 8),
                          Text('Next Interview',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${data.nextInterview!.jobTitle} \u00B7 ${data.nextInterview!.date} \u00B7 ${data.nextInterview!.time} \u00B7 ${data.nextInterview!.format.displayName}',
                        style: const TextStyle(fontSize: 13, color: AppColors.secondary),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => context.push('/candidate/interviews'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.teal,
                            side: const BorderSide(color: AppColors.teal),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: const Text('View Interviews', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (data.nextInterview != null) const SizedBox(height: 16),

            // ── 9. MESSAGES ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () => context.push('/candidate/messages/1'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: AppColors.cardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.chat_bubble_outline, color: AppColors.teal, size: 18),
                          const SizedBox(width: 8),
                          const Text('Messages',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.teal,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text('${data.unreadMessages}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                          ),
                          const Spacer(),
                          const Text('View All',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.teal)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${data.unreadMessages} unread message${data.unreadMessages == 1 ? '' : 's'}',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                                const SizedBox(height: 2),
                                const Text('Tap to view all conversations',
                                    style: TextStyle(fontSize: 12, color: AppColors.secondary)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.tertiary),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── 10. PROFILE STRENGTH ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: AppColors.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Profile Strength',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.teal.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text('${profile.profileStrength}%',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.teal)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: profile.profileStrength / 100.0,
                        minHeight: 8,
                        backgroundColor: AppColors.teal.withValues(alpha: 0.12),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...profile.completionItems.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              item.done ? Icons.check_circle : Icons.radio_button_unchecked,
                              size: 18,
                              color: item.done ? AppColors.teal : AppColors.tertiary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 13,
                                color: item.done ? AppColors.charcoal : AppColors.secondary,
                                decoration: item.done ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.push('/candidate/profile/edit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightTeal.withValues(alpha: 0.25),
                          foregroundColor: AppColors.teal,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Complete Profile', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── 11. FROM THE COMMUNITY ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: AppColors.cardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('From the Community',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                        GestureDetector(
                          onTap: () {},
                          child: const Text('See All >',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.teal)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const EmptyState(
                      icon: Icons.chat_bubble_outline,
                      title: 'No community posts yet',
                      subtitle: 'Be the first to share something.',
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
}

// ── Helper Widgets ──

class _TapCard extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _TapCard({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppColors.cardDecoration,
        child: child,
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String count;
  final String label;
  final Color color;
  const _StatCell({required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(count,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 10, color: AppColors.secondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _CompactJobCard extends StatelessWidget {
  final Job job;
  final VoidCallback? onTap;
  const _CompactJobCard({required this.job, this.onTap});

  @override
  Widget build(BuildContext context) {
    final hue = (job.company.hashCode % 360).abs().toDouble();
    final initials = job.company.isNotEmpty ? job.company[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 185,
        padding: const EdgeInsets.all(14),
        decoration: AppColors.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: HSLColor.fromAHSL(1, hue, 0.30, 0.88).toColor(),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(initials,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: HSLColor.fromAHSL(1, hue, 0.50, 0.45).toColor())),
              ),
            ),
            const SizedBox(height: 10),
            Text(job.title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.charcoal),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text('${job.company} \u00B7 ${job.location}',
                style: const TextStyle(fontSize: 11, color: AppColors.secondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const Spacer(),
            Row(
              children: [
                Text(job.salary,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.teal)),
                const Text(' \u00B7 ', style: TextStyle(color: AppColors.tertiary, fontSize: 11)),
                Flexible(
                  child: Text(job.contract,
                      style: const TextStyle(fontSize: 10, color: AppColors.secondary),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            if (job.featured || job.urgent) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  if (job.featured) _pill('Featured', AppColors.amber),
                  if (job.featured && job.urgent) const SizedBox(width: 4),
                  if (job.urgent) _pill('Urgent', AppColors.red),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(text, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _FeaturedJobCard extends StatelessWidget {
  final Job job;
  final VoidCallback? onTap;
  const _FeaturedJobCard({required this.job, this.onTap});

  @override
  Widget build(BuildContext context) {
    final hue = (job.company.hashCode % 360).abs().toDouble();
    final initials = job.company.isNotEmpty ? job.company[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(16),
        decoration: AppColors.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: HSLColor.fromAHSL(1, hue, 0.30, 0.88).toColor(),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(initials,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: HSLColor.fromAHSL(1, hue, 0.50, 0.45).toColor())),
              ),
            ),
            const SizedBox(height: 10),
            Text(job.title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.charcoal),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Text('${job.company} \u00B7 ${job.location}',
                style: const TextStyle(fontSize: 12, color: AppColors.secondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const Spacer(),
            Text(job.salary,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.teal)),
            const SizedBox(height: 6),
            Row(
              children: [
                if (job.featured) _pill('Featured', AppColors.amber),
                if (job.featured && job.urgent) const SizedBox(width: 4),
                if (job.urgent) _pill('Urgent', AppColors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(text, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
