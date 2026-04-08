import 'package:flutter/material.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';

/// Admin Dashboard -- Platform Control Center with KPIs, activity, and funnel views.
class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});
  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  bool _showSearch = false;
  String _searchText = '';
  String _selectedRange = 'Today';
  final _dateRanges = ['Today', '7 Days', '30 Days', '90 Days', 'Year'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(
              title: 'Admin Dashboard',
              subtitle: 'Super Admin',
              onBack: () => Navigator.of(context).pop(),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => setState(() { _showSearch = !_showSearch; if (!_showSearch) _searchText = ''; }),
                    child: Icon(_showSearch ? Icons.close : Icons.search, size: 22, color: AppColors.charcoal),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.notifications_outlined, size: 22, color: AppColors.charcoal),
                      Positioned(right: -2, top: -2, child: Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.urgent, shape: BoxShape.circle))),
                    ],
                  ),
                ],
              ),
            ),
            if (_showSearch) AdminSearchBar(hint: 'Search users, jobs, businesses...', text: _searchText, onChanged: (v) => setState(() => _searchText = v), onClear: () => setState(() => _searchText = '')),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    _dateRangeFilter(),
                    const SizedBox(height: AppSpacing.lg),
                    _primaryKPIs(),
                    const SizedBox(height: AppSpacing.md),
                    _secondaryKPIs(),
                    const SizedBox(height: AppSpacing.sectionGap),
                    _needsAttention(),
                    const SizedBox(height: AppSpacing.sectionGap),
                    _recentActivity(),
                    const SizedBox(height: AppSpacing.sectionGap),
                    _dashboardSection('Users Overview', Icons.people, _usersContent()),
                    const SizedBox(height: AppSpacing.sectionGap),
                    _dashboardSection('Jobs Health', Icons.work, _jobsHealth()),
                    const SizedBox(height: AppSpacing.sectionGap),
                    _dashboardSection('Applications Funnel', Icons.description, _appsFunnel()),
                    const SizedBox(height: AppSpacing.sectionGap),
                    _dashboardSection('Interviews', Icons.calendar_today, _interviewsContent()),
                    const SizedBox(height: AppSpacing.sectionGap),
                    _dashboardSection('Reports & Moderation', Icons.flag, _reportsContent()),
                    const SizedBox(height: AppSpacing.sectionGap),
                    _dashboardSection('Community', Icons.chat_bubble, _communityContent()),
                    const SizedBox(height: AppSpacing.sectionGap),
                    _dashboardSection('Billing & Subscriptions', Icons.credit_card, _billingContent()),
                    const SizedBox(height: AppSpacing.sectionGap),
                    _quickActions(),
                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateRangeFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: _dateRanges.map((r) {
          final active = _selectedRange == r;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => setState(() => _selectedRange = r),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: active ? AppColors.teal : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: active ? Colors.transparent : AppColors.border, width: 0.5),
                ),
                child: Text(r, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: active ? Colors.white : AppColors.secondary)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _primaryKPIs() {
    final kpis = [
      ('1,247', 'Total Users', '+8%', Icons.people, AppColors.teal),
      ('89', 'Active Jobs', '3 need review', Icons.work, AppColors.indigo),
      ('24', 'Applications Today', '+22%', Icons.description, AppColors.amber),
      ('8', 'Interviews Scheduled', '2 pending', Icons.calendar_today, AppColors.online),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: GridView.count(
        crossAxisCount: 2, mainAxisSpacing: AppSpacing.md, crossAxisSpacing: AppSpacing.md, childAspectRatio: 1.4, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        children: kpis.map((k) => _kpiCard(k.$1, k.$2, k.$3, k.$4, k.$5)).toList(),
      ),
    );
  }

  Widget _kpiCard(String number, String label, String insight, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(width: 30, height: 30, decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(AppRadius.sm)), child: Icon(icon, size: 15, color: color)),
            const Spacer(),
            Text(insight, style: TextStyle(fontSize: 10, color: color)),
          ]),
          const SizedBox(height: AppSpacing.sm),
          Text(number, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
        ],
      ),
    );
  }

  Widget _secondaryKPIs() {
    final items = [('12', 'New Businesses', AppColors.indigo), ('28', 'New Candidates', AppColors.teal), ('3', 'Open Reports', AppColors.urgent), ('6', 'Active Plans', AppColors.online)];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: GridView.count(
        crossAxisCount: 2, mainAxisSpacing: AppSpacing.md, crossAxisSpacing: AppSpacing.md, childAspectRatio: 3.2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        children: items.map((i) => Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md)),
          child: Row(children: [
            Text(i.$1, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: i.$3)),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(i.$2, style: const TextStyle(fontSize: 13, color: AppColors.secondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
            const Icon(Icons.chevron_right, size: 12, color: AppColors.tertiary),
          ]),
        )).toList(),
      ),
    );
  }

  Widget _needsAttention() {
    final items = [
      (Icons.flag, AppColors.urgent, '2 high-priority reports', 'High'),
      (Icons.work, AppColors.amber, '5 jobs with no applicants', 'Review'),
      (Icons.business, AppColors.amber, '1 business pending verification', 'Review'),
      (Icons.calendar_today, AppColors.indigo, '3 interviews pending confirmation', 'Action'),
      (Icons.credit_card, AppColors.urgent, '2 failed payments', 'Urgent'),
    ];
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('Needs Attention', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
            const SizedBox(width: AppSpacing.sm),
            Container(width: 20, height: 20, decoration: const BoxDecoration(color: AppColors.urgent, shape: BoxShape.circle), alignment: Alignment.center, child: const Text('7', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: AppSpacing.lg),
          ...items.asMap().entries.map((e) {
            final i = e.value;
            return Column(children: [
              if (e.key > 0) Padding(padding: const EdgeInsets.only(left: 36), child: const Divider(height: 1, color: AppColors.divider)),
              Padding(padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2), child: Row(children: [
                Container(width: 24, height: 24, decoration: BoxDecoration(color: i.$2.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(AppRadius.sm)), child: Icon(i.$1, size: 12, color: i.$2)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(i.$3, style: const TextStyle(fontSize: 13, color: AppColors.secondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                StatusPill(text: i.$4, color: i.$4 == 'High' || i.$4 == 'Urgent' ? AppColors.urgent : AppColors.amber),
                const SizedBox(width: AppSpacing.sm),
                const Icon(Icons.chevron_right, size: 12, color: AppColors.tertiary),
              ])),
            ]);
          }),
        ],
      ),
    );
  }

  Widget _recentActivity() {
    final items = [
      (AppColors.online, 'Business verified - The Ritz London', '2m ago'),
      (AppColors.teal, 'Candidate verified - Elena Rossi', '15m ago'),
      (AppColors.urgent, 'Report resolved - Spam removed', '32m ago'),
      (AppColors.indigo, 'Job approved - Senior Chef at Nobu', '1h ago'),
      (AppColors.amber, 'Account suspended - Suspicious activity', '2h ago'),
    ];
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text('Recent Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              decoration: BoxDecoration(color: AppColors.online.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppRadius.full)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.online, shape: BoxShape.circle)),
                const SizedBox(width: AppSpacing.xs),
                const Text('Live', style: TextStyle(fontSize: 10, color: AppColors.online)),
              ]),
            ),
            const Spacer(),
            const Text('All Logs', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.teal)),
          ]),
          const SizedBox(height: AppSpacing.lg),
          ...items.map((i) => Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
            child: Row(children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(color: i.$1, shape: BoxShape.circle)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(i.$2, style: const TextStyle(fontSize: 13, color: AppColors.secondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
              Text(i.$3, style: const TextStyle(fontSize: 10, color: AppColors.tertiary)),
            ]),
          )),
        ],
      ),
    );
  }

  Widget _dashboardSection(String title, IconData icon, Widget content) {
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminSectionTitle(title: title, icon: icon),
          const SizedBox(height: AppSpacing.lg),
          content,
        ],
      ),
    );
  }

  Widget _miniStatRow(List<(String, String, Color)> items) {
    return Row(
      children: items.map((i) => Expanded(
        child: Column(children: [
          Text(i.$1, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: i.$3)),
          const SizedBox(height: 2),
          Text(i.$2, style: const TextStyle(fontSize: 10, color: AppColors.secondary)),
        ]),
      )).toList(),
    );
  }

  Widget _usersContent() => _miniStatRow([('892', 'Candidates', AppColors.teal), ('355', 'Businesses', AppColors.indigo), ('1,100', 'Verified', AppColors.online), ('5', 'Suspended', AppColors.urgent)]);
  Widget _jobsHealth() => _miniStatRow([('89', 'Active', AppColors.online), ('7', 'Expiring', AppColors.amber), ('5', 'No Applicants', AppColors.urgent), ('3', 'Paused', AppColors.tertiary)]);

  Widget _appsFunnel() {
    final steps = [('Applied', '120', AppColors.teal), ('Review', '68', AppColors.amber), ('Interview', '32', AppColors.indigo), ('Offer', '12', AppColors.online), ('Hired', '8', AppColors.teal)];
    return Row(children: steps.map((s) => Expanded(
      child: Column(children: [
        Text(s.$2, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: s.$3)),
        const SizedBox(height: AppSpacing.xs),
        Text(s.$1, style: const TextStyle(fontSize: 10, color: AppColors.secondary)),
        const SizedBox(height: AppSpacing.xs),
        Container(height: 4, decoration: BoxDecoration(color: s.$3, borderRadius: BorderRadius.circular(2))),
      ]),
    )).toList());
  }

  Widget _interviewsContent() => _miniStatRow([('5', 'Today', AppColors.teal), ('3', 'Tomorrow', AppColors.indigo), ('12', 'This Week', AppColors.amber), ('2', 'Pending', AppColors.urgent)]);

  Widget _reportsContent() {
    final pills = [('Fake Jobs', '2', AppColors.urgent), ('Spam', '1', AppColors.amber), ('Fake Profiles', '1', AppColors.urgent), ('Abusive Messages', '2', AppColors.amber), ('Community Flags', '0', AppColors.tertiary)];
    return Wrap(
      spacing: AppSpacing.md, runSpacing: AppSpacing.sm,
      children: pills.map((p) => Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(color: p.$3.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(AppRadius.md)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(p.$2, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: p.$3)),
          const SizedBox(width: AppSpacing.xs),
          Text(p.$1, style: const TextStyle(fontSize: 10, color: AppColors.secondary)),
        ]),
      )).toList(),
    );
  }

  Widget _communityContent() => _miniStatRow([('18', 'Published', AppColors.online), ('3', 'Drafts', AppColors.tertiary), ('4', 'Featured', AppColors.amber), ('2,100', 'Views', AppColors.teal)]);
  Widget _billingContent() => _miniStatRow([('6', 'Active', AppColors.online), ('2', 'Trial', AppColors.amber), ('3', 'Renewing', AppColors.indigo), ('1', 'Failed', AppColors.urgent)]);

  Widget _quickActions() {
    final actions = [
      (Icons.star, 'Featured Content'), (Icons.star, 'Add Featured Employer'), (Icons.chat_bubble, 'Create Community Post'),
      (Icons.flag, 'Review Reports'), (Icons.work, 'No-Applicant Jobs'), (Icons.notifications, 'Send Notification'),
      (Icons.settings, 'Settings'), (Icons.history, 'Admin Logs'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl), child: Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.charcoal))),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Row(children: actions.map((a) => Padding(padding: const EdgeInsets.only(right: AppSpacing.sm), child: QuickActionChip(icon: a.$1, label: a.$2, onTap: () {}))).toList()),
        ),
      ],
    );
  }
}
