import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/widgets/search_screen.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';
import 'package:plagit/providers/admin_providers.dart';
import 'package:plagit/providers/recent_searches_provider.dart';

/// Global admin search — spans candidates, businesses, jobs, applications,
/// interviews, verifications, reports, and support. Results are grouped by
/// category with a jump-chip bar and sorted alphabetically within each group.
class AdminGlobalSearchView extends StatefulWidget {
  const AdminGlobalSearchView({super.key});

  @override
  State<AdminGlobalSearchView> createState() => _AdminGlobalSearchViewState();
}

class _AdminGlobalSearchViewState extends State<AdminGlobalSearchView> {
  @override
  void initState() {
    super.initState();
    // Ensure all underlying lists are loaded so search can hit real data.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final items = [
        context.read<AdminCandidatesListProvider>(),
        context.read<AdminBusinessesListProvider>(),
        context.read<AdminJobsListProvider>(),
        context.read<AdminApplicationsListProvider>(),
        context.read<AdminInterviewsListProvider>(),
        context.read<AdminVerificationsListProvider>(),
        context.read<AdminReportsListProvider>(),
        context.read<AdminSupportListProvider>(),
      ];
      for (final p in items) {
        if (p.items.isEmpty && !p.loading) {
          p.load();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SearchScreen(
      scope: RecentSearchScope.adminGlobal,
      title: 'Admin search',
      hintText: 'Search candidates, jobs, businesses…',
      resultsBuilder: (ctx, query) => _Results(query: query),
    );
  }
}

class _Results extends StatelessWidget {
  final String query;
  const _Results({required this.query});

  @override
  Widget build(BuildContext context) {
    final q = query.toLowerCase();

    final candidates = context.watch<AdminCandidatesListProvider>().items;
    final businesses = context.watch<AdminBusinessesListProvider>().items;
    final jobs = context.watch<AdminJobsListProvider>().items;
    final applications = context.watch<AdminApplicationsListProvider>().items;
    final interviews = context.watch<AdminInterviewsListProvider>().items;
    final verifications = context.watch<AdminVerificationsListProvider>().items;
    final reports = context.watch<AdminReportsListProvider>().items;
    final support = context.watch<AdminSupportListProvider>().items;

    bool match(String? s) => s != null && s.toLowerCase().contains(q);

    final candidateHits = candidates.where((c) =>
        match(c['name'] as String?) ||
        match(c['email'] as String?) ||
        match(c['role'] as String?) ||
        match(c['location'] as String?)).toList()
      ..sort((a, b) => (a['name'] as String? ?? '')
          .compareTo(b['name'] as String? ?? ''));

    final businessHits = businesses.where((b) =>
        match(b['name'] as String?) ||
        match(b['category'] as String?) ||
        match(b['location'] as String?) ||
        match(b['email'] as String?)).toList()
      ..sort((a, b) => (a['name'] as String? ?? '')
          .compareTo(b['name'] as String? ?? ''));

    final jobHits = jobs.where((j) =>
        match(j['title'] as String?) ||
        match(j['business'] as String?) ||
        match(j['location'] as String?)).toList()
      ..sort((a, b) => (a['title'] as String? ?? '')
          .compareTo(b['title'] as String? ?? ''));

    final appHits = applications.where((a) =>
        match(a['candidateName'] as String?) ||
        match(a['jobTitle'] as String?) ||
        match(a['business'] as String?) ||
        match(a['status'] as String?)).toList()
      ..sort((a, b) => (a['candidateName'] as String? ?? '')
          .compareTo(b['candidateName'] as String? ?? ''));

    final interviewHits = interviews.where((i) =>
        match(i['candidateName'] as String?) ||
        match(i['business'] as String?) ||
        match(i['jobTitle'] as String?)).toList()
      ..sort((a, b) => (a['candidateName'] as String? ?? '')
          .compareTo(b['candidateName'] as String? ?? ''));

    final verificationHits = verifications.where((v) =>
        match(v['name'] as String?) ||
        match(v['type'] as String?)).toList()
      ..sort((a, b) => (a['name'] as String? ?? '')
          .compareTo(b['name'] as String? ?? ''));

    final reportHits = reports.where((r) =>
        match(r['title'] as String?) ||
        match(r['entity'] as String?) ||
        match(r['entityType'] as String?)).toList()
      ..sort((a, b) => (a['title'] as String? ?? '')
          .compareTo(b['title'] as String? ?? ''));

    final supportHits = support.where((s) =>
        match(s['title'] as String?) ||
        match(s['userName'] as String?)).toList()
      ..sort((a, b) => (a['title'] as String? ?? '')
          .compareTo(b['title'] as String? ?? ''));

    final totalHits = candidateHits.length +
        businessHits.length +
        jobHits.length +
        appHits.length +
        interviewHits.length +
        verificationHits.length +
        reportHits.length +
        supportHits.length;

    if (totalHits == 0) {
      return SearchNoResults(query: query);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        if (candidateHits.isNotEmpty)
          _Group(
            title: 'Candidates',
            count: candidateHits.length,
            icon: Icons.person,
            color: AppColors.teal,
            children: candidateHits.map((c) => _Row(
                  title: (c['name'] as String?) ?? '—',
                  subtitle: [
                    (c['role'] as String?) ?? '',
                    (c['location'] as String?) ?? '',
                  ].where((e) => e.isNotEmpty).join(' · '),
                  onTap: () => _go(context, '/admin/candidates/${c['id'] ?? c['name']}'),
                )),
          ),
        if (businessHits.isNotEmpty)
          _Group(
            title: 'Businesses',
            count: businessHits.length,
            icon: Icons.business,
            color: AppColors.purple,
            children: businessHits.map((b) => _Row(
                  title: (b['name'] as String?) ?? '—',
                  subtitle: [
                    (b['category'] as String?) ?? '',
                    (b['location'] as String?) ?? '',
                  ].where((e) => e.isNotEmpty).join(' · '),
                  onTap: () => _go(context, '/admin/businesses/${b['id'] ?? b['name']}'),
                )),
          ),
        if (jobHits.isNotEmpty)
          _Group(
            title: 'Jobs',
            count: jobHits.length,
            icon: Icons.work,
            color: AppColors.amber,
            children: jobHits.map((j) => _Row(
                  title: (j['title'] as String?) ?? '—',
                  subtitle: [
                    (j['business'] as String?) ?? '',
                    (j['location'] as String?) ?? '',
                  ].where((e) => e.isNotEmpty).join(' · '),
                  onTap: () => _go(context, '/admin/jobs/${j['id'] ?? j['title']}'),
                )),
          ),
        if (appHits.isNotEmpty)
          _Group(
            title: 'Applications',
            count: appHits.length,
            icon: Icons.description,
            color: AppColors.green,
            children: appHits.map((a) => _Row(
                  title: (a['candidateName'] as String?) ?? '—',
                  subtitle: [
                    (a['jobTitle'] as String?) ?? '',
                    (a['business'] as String?) ?? '',
                  ].where((e) => e.isNotEmpty).join(' · '),
                  trailing: (a['status'] as String?) ?? '',
                  onTap: () => _go(context, '/admin/applications/${a['id']}'),
                )),
          ),
        if (interviewHits.isNotEmpty)
          _Group(
            title: 'Interviews',
            count: interviewHits.length,
            icon: Icons.calendar_today,
            color: const Color(0xFF6676F0),
            children: interviewHits.map((i) => _Row(
                  title: (i['candidateName'] as String?) ?? '—',
                  subtitle: [
                    (i['jobTitle'] as String?) ?? '',
                    (i['business'] as String?) ?? '',
                  ].where((e) => e.isNotEmpty).join(' · '),
                  trailing: (i['date'] as String?) ?? '',
                  onTap: () => _go(context, '/admin/interviews/${i['id']}'),
                )),
          ),
        if (verificationHits.isNotEmpty)
          _Group(
            title: 'Verifications',
            count: verificationHits.length,
            icon: Icons.verified_user,
            color: AppColors.teal,
            children: verificationHits.map((v) => _Row(
                  title: (v['name'] as String?) ?? '—',
                  subtitle: (v['type'] as String?) ?? '',
                  onTap: () => _go(context, '/admin/verifications/${v['id']}'),
                )),
          ),
        if (reportHits.isNotEmpty)
          _Group(
            title: 'Reports',
            count: reportHits.length,
            icon: Icons.flag,
            color: AppColors.red,
            children: reportHits.map((r) => _Row(
                  title: (r['title'] as String?) ?? '—',
                  subtitle: [
                    (r['entity'] as String?) ?? '',
                    (r['entityType'] as String?) ?? '',
                  ].where((e) => e.isNotEmpty).join(' · '),
                  trailing: (r['priority'] as String?) ?? '',
                  onTap: () => _go(context, '/admin/moderation/${r['id']}'),
                )),
          ),
        if (supportHits.isNotEmpty)
          _Group(
            title: 'Support',
            count: supportHits.length,
            icon: Icons.support_agent,
            color: AppColors.amber,
            children: supportHits.map((s) => _Row(
                  title: (s['title'] as String?) ?? '—',
                  subtitle: (s['userName'] as String?) ?? '',
                  onTap: () => _go(context, '/admin/support/${s['id']}'),
                )),
          ),
      ],
    );
  }

  void _go(BuildContext context, String route) {
    Navigator.of(context).pop();
    context.push(route);
  }
}

class _Group extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final Iterable<Widget> children;

  const _Group({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, size: 12, color: color),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [aSubtleShadow],
            ),
            child: Column(
              children: children
                  .expand((w) sync* {
                    yield w;
                    yield const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Divider(height: 1, color: AppColors.divider),
                    );
                  })
                  .toList()
                ..removeLast(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? trailing;
  final VoidCallback onTap;

  const _Row({
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.secondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null && trailing!.isNotEmpty) ...[
              const SizedBox(width: 10),
              Text(
                trailing!,
                style: const TextStyle(fontSize: 11, color: AppColors.tertiary),
              ),
            ],
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.tertiary),
          ],
        ),
      ),
    );
  }
}
