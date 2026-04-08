import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/core/widgets/status_badge.dart';

class BusinessDashboardTab extends StatelessWidget {
  const BusinessDashboardTab({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final biz = MockData.business;
    final applicants = MockData.businessApplicants;
    final activeJobs = MockData.activeBusinessJobs;
    final conversations = MockData.businessConversations;
    final profileItems = MockData.businessProfileItems;
    final quickPlug = MockData.quickPlugCandidates;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            // ── HEADER ──
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.teal,
                    child: Text(
                      biz['initials'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_greeting()}, ${biz['name']}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.charcoal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '\u{1F4CD} ${biz['location']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: AppColors.charcoal),
                    onPressed: () => context.push('/business/notifications'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: AppColors.charcoal),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // ── SEARCH BAR ──
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEF0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: AppColors.tertiary, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Search candidates, roles...',
                      style: TextStyle(color: AppColors.tertiary, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            // ── STATS ROW ──
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Row(
                children: [
                  _StatCard(count: '${activeJobs.length}', label: 'Active Jobs', color: AppColors.teal),
                  const SizedBox(width: 10),
                  _StatCard(count: '${applicants.length}', label: 'Applicants', color: AppColors.purple),
                  const SizedBox(width: 10),
                  _StatCard(count: '${MockData.businessInterviews.length}', label: 'Interviews', color: AppColors.amber),
                  const SizedBox(width: 10),
                  const _StatCard(count: '0', label: 'Hired', color: AppColors.green),
                ],
              ),
            ),

            // ── RECENT APPLICANTS ──
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [AppColors.cardShadow],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Row(
                        children: [
                          const Text(
                            'Recent Applicants',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.charcoal),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => context.push('/business/applicants'),
                            child: const Text('View All', style: TextStyle(fontSize: 13, color: AppColors.teal, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(3, (i) {
                      final a = applicants[i];
                      final colors = [AppColors.teal, AppColors.purple, AppColors.amber];
                      return Column(
                        children: [
                          if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.divider),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: colors[i % colors.length].withValues(alpha: 0.15),
                                  child: Text(
                                    a['initials'] as String,
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: colors[i % colors.length]),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(a['name'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
                                      Text(a['role'] as String, style: const TextStyle(fontSize: 12, color: AppColors.secondary)),
                                    ],
                                  ),
                                ),
                                StatusBadge(status: a['status'] as String),
                                const SizedBox(width: 8),
                                Text(a['date'] as String, style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => context.push('/business/applicants'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.teal,
                            side: const BorderSide(color: AppColors.teal),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('View All Applicants'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── ACTIVE JOBS ──
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [AppColors.cardShadow],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Row(
                        children: [
                          const Text('Active Jobs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => context.push('/business/post-job'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.teal,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('Post New Job', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(activeJobs.length > 3 ? 3 : activeJobs.length, (i) {
                      final job = activeJobs[i];
                      return Column(
                        children: [
                          if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.divider),
                          InkWell(
                            onTap: () => context.push('/business/job/${job['id']}'),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(job['title'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(job['location'] as String, style: const TextStyle(fontSize: 12, color: AppColors.secondary)),
                                            const SizedBox(width: 10),
                                            Text(job['salary'] as String, style: const TextStyle(fontSize: 12, color: AppColors.teal, fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.teal.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(100),
                                        ),
                                        child: Text(
                                          '${job['applicants']} applicants',
                                          style: const TextStyle(fontSize: 11, color: AppColors.teal, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      if (job['urgent'] == true) ...[
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.red.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(100),
                                          ),
                                          child: const Text('Urgent', style: TextStyle(fontSize: 10, color: AppColors.red, fontWeight: FontWeight.w600)),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // ── YOUR NEXT STEP ──
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: const Border(left: BorderSide(color: AppColors.gold, width: 3)),
                  boxShadow: [AppColors.cardShadow],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '\u2726 YOUR NEXT STEP',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.gold, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Interview with Yuki Tanaka',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.charcoal),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Waiter \u00B7 Sat Apr 11 \u00B7 2:00 PM \u00B7 Video',
                            style: TextStyle(fontSize: 13, color: AppColors.secondary),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.purple.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Text('Video', style: TextStyle(fontSize: 11, color: AppColors.purple, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.push('/business/interview/bi1'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('View Interview', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── RECOMMENDED CANDIDATES ──
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Row(
                children: [
                  const Text('Recommended for You', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {},
                    child: const Text('See All', style: TextStyle(fontSize: 13, color: AppColors.teal, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: quickPlug.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final c = quickPlug[i];
                  final colors = [AppColors.teal, AppColors.purple, AppColors.amber, AppColors.green, AppColors.red];
                  final color = colors[i % colors.length];
                  return Container(
                    width: 150,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [AppColors.cardShadow],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: color.withValues(alpha: 0.15),
                              child: Text(c['initials'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                            ),
                            if (c['verified'] == true) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.verified, size: 16, color: AppColors.teal),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(c['name'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.charcoal), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(c['role'] as String, style: const TextStyle(fontSize: 11, color: AppColors.secondary)),
                        const SizedBox(height: 2),
                        Text(c['experience'] as String, style: const TextStyle(fontSize: 10, color: AppColors.tertiary)),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ── MESSAGES ──
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [AppColors.cardShadow],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Row(
                        children: [
                          const Text('Messages', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.teal,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              '${conversations.length}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => context.push('/business/messages'),
                            child: const Text('View All', style: TextStyle(fontSize: 13, color: AppColors.teal, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(2, (i) {
                      final conv = conversations[i];
                      final colors = [AppColors.teal, AppColors.purple];
                      return Column(
                        children: [
                          if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.divider),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: colors[i].withValues(alpha: 0.15),
                                  child: Text(
                                    conv['candidateInitials'] as String,
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors[i]),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(conv['candidateName'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
                                      const SizedBox(height: 2),
                                      Text(
                                        conv['lastMessage'] as String,
                                        style: const TextStyle(fontSize: 12, color: AppColors.secondary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(conv['time'] as String, style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => context.push('/business/messages'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.teal,
                            side: const BorderSide(color: AppColors.teal),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('View All Messages'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── PROFILE STRENGTH ──
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [AppColors.cardShadow],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Business Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.teal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            '${biz['profileCompletion']}%',
                            style: const TextStyle(fontSize: 12, color: AppColors.teal, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (biz['profileCompletion'] as int) / 100,
                        backgroundColor: AppColors.divider,
                        valueColor: const AlwaysStoppedAnimation(AppColors.teal),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...profileItems
                        .where((item) => item['done'] == false)
                        .take(3)
                        .map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  const Icon(Icons.radio_button_unchecked, size: 18, color: AppColors.tertiary),
                                  const SizedBox(width: 10),
                                  Text(item['label'] as String, style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
                                ],
                              ),
                            )),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightTeal.withValues(alpha: 0.2),
                          foregroundColor: AppColors.teal,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Complete Profile', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── UPGRADE CARD ──
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
              child: GestureDetector(
                onTap: () => context.push('/business/subscription'),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [AppColors.cardShadow],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.workspace_premium, color: AppColors.amber, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Upgrade to Premium', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
                            const SizedBox(height: 2),
                            const Text('Post featured jobs and find talent faster', style: TextStyle(fontSize: 12, color: AppColors.secondary)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.teal,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Upgrade Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, color: AppColors.tertiary, size: 20),
                    ],
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

class _StatCard extends StatelessWidget {
  final String count;
  final String label;
  final Color color;

  const _StatCard({required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Column(
          children: [
            Text(count, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.secondary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
