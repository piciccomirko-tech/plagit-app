import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';
import 'package:plagit/features/admin/views/admin_dashboard_view.dart';
import 'package:plagit/features/admin/views/admin_users_view.dart';
import 'package:plagit/features/admin/views/admin_candidates_view.dart';
import 'package:plagit/features/admin/views/admin_businesses_view.dart';
import 'package:plagit/features/admin/views/admin_jobs_view.dart';
import 'package:plagit/features/admin/views/admin_applications_view.dart';
import 'package:plagit/features/admin/views/admin_interviews_view.dart';
import 'package:plagit/features/admin/views/admin_matches_view.dart';
import 'package:plagit/features/admin/views/admin_messages_view.dart';
import 'package:plagit/features/admin/views/admin_community_view.dart';
import 'package:plagit/features/admin/views/admin_content_featured_view.dart';
import 'package:plagit/features/admin/views/admin_notifications_view.dart';
import 'package:plagit/features/admin/views/admin_subscriptions_view.dart';
import 'package:plagit/features/admin/views/admin_reports_view.dart';
import 'package:plagit/features/admin/views/admin_logs_view.dart';
import 'package:plagit/features/admin/views/admin_settings_view.dart';
import 'package:plagit/features/admin/views/admin_global_search_view.dart';
import 'package:plagit/features/admin/views/admin_account_sheet.dart';
import 'package:plagit/providers/admin_providers.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

class SuperAdminHomeView extends StatefulWidget {
  final VoidCallback onLogout;
  const SuperAdminHomeView({super.key, required this.onLogout});

  @override
  State<SuperAdminHomeView> createState() => _SuperAdminHomeViewState();
}

class _SuperAdminHomeViewState extends State<SuperAdminHomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final notifs = context.read<AdminNotificationsProvider>();
      if (notifs.items.isEmpty && !notifs.loading) {
        notifs.load();
      }
    });
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  void _openSearch(BuildContext context) {
    _push(context, const AdminGlobalSearchView());
  }

  void _openAccountSheet(BuildContext context) {
    showAdminAccountSheet(context, onLogout: widget.onLogout);
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'AU';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length.clamp(0, 2)).toUpperCase();
    }
    return (parts.first.characters.first + parts[1].characters.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _headerSection(context),
              const SizedBox(height: AppSpacing.lg),
              _summaryStats(context),
              const SizedBox(height: AppSpacing.sectionGap),
              _needsAttentionBanner(context),
              const SizedBox(height: AppSpacing.sectionGap),
              _quickActions(context),
              const SizedBox(height: AppSpacing.sectionGap),
              _platformOverview(context),
              const SizedBox(height: AppSpacing.sectionGap),
              _sectionGroup('People', [
                _SectionRowData(Icons.people, AppColors.teal, 'Users', 'All platform users', '1,247', AppColors.teal, () => _push(context, const AdminUsersView())),
                _SectionRowData(Icons.person_outline, AppColors.indigo, 'Candidates', 'Job seeker profiles', '892', AppColors.indigo, () => _push(context, const AdminCandidatesView())),
                _SectionRowData(Icons.business, AppColors.amber, 'Businesses', 'Employer accounts', '355', AppColors.amber, () => _push(context, const AdminBusinessesView())),
              ]),
              const SizedBox(height: AppSpacing.sectionGap),
              _sectionGroup('Hiring Operations', [
                _SectionRowData(Icons.work, AppColors.indigo, 'Jobs', 'Active job listings', '89', AppColors.indigo, () => _push(context, const AdminJobsView())),
                _SectionRowData(Icons.verified, AppColors.online, 'Matches', 'Role + job type matches', '', AppColors.online, () => _push(context, const AdminMatchesView())),
                _SectionRowData(Icons.description, AppColors.teal, 'Applications', 'Submitted applications', '24 today', AppColors.teal, () => _push(context, const AdminApplicationsView())),
                _SectionRowData(Icons.calendar_today, AppColors.online, 'Interviews', 'Scheduled interviews', '8', AppColors.online, () => _push(context, const AdminInterviewsView())),
              ]),
              const SizedBox(height: AppSpacing.sectionGap),
              _sectionGroup('Content & Communication', [
                _SectionRowData(Icons.forum, AppColors.teal, 'Messages', 'User conversations', '12 unread', AppColors.amber, () => _push(context, const AdminMessagesView())),
                _SectionRowData(Icons.notifications, AppColors.amber, 'Notifications', 'Push & in-app alerts', '5 pending', AppColors.amber, () => _push(context, const AdminNotificationsView())),
                _SectionRowData(Icons.chat_bubble, AppColors.teal, 'Community', 'Posts and discussions', '18 posts', AppColors.teal, () => _push(context, const AdminCommunityView())),
                _SectionRowData(Icons.star, AppColors.amber, 'Featured Content', 'Highlighted content', '4 featured', AppColors.amber, () => _push(context, const AdminContentFeaturedView())),
              ]),
              const SizedBox(height: AppSpacing.sectionGap),
              _sectionGroup('Business & Revenue', [
                _SectionRowData(Icons.credit_card, AppColors.online, 'Subscriptions', 'Plans and billing', '6 active', AppColors.online, () => _push(context, const AdminSubscriptionsView())),
                _SectionRowData(Icons.flag, AppColors.urgent, 'Reports', 'Flags and moderation', '3 open', AppColors.urgent, () => _push(context, const AdminReportsView())),
              ]),
              const SizedBox(height: AppSpacing.sectionGap),
              _sectionGroup('System Control', [
                _SectionRowData(Icons.history, AppColors.indigo, 'Logs', 'Admin activity logs', '', AppColors.tertiary, () => _push(context, const AdminLogsView())),
                _SectionRowData(Icons.settings, AppColors.secondary, 'Settings', 'Platform configuration', '', AppColors.tertiary, () => _push(context, const AdminSettingsView())),
              ]),
              const SizedBox(height: AppSpacing.xxxl * 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerSection(BuildContext context) {
    final auth = context.watch<AdminAuthProvider>();
    final unread = context.watch<AdminNotificationsProvider>().unreadCount;
    final initials = _initials(auth.userName.isEmpty ? 'Admin User' : auth.userName);

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_greeting(), style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
                const SizedBox(height: 2),
                const Text('Super Admin', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.charcoal)),
              ],
            ),
          ),
          _headerIconButton(
            icon: Icons.search,
            onTap: () => _openSearch(context),
            tooltip: 'Search',
          ),
          const SizedBox(width: AppSpacing.sm),
          _headerIconButton(
            icon: Icons.notifications_outlined,
            onTap: () => _push(context, const AdminNotificationsView()),
            tooltip: 'Notifications',
            badgeCount: unread,
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: () => _openAccountSheet(context),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.indigo, AppColors.teal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
    int badgeCount = 0,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 36, height: 36,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(icon, size: 22, color: AppColors.charcoal),
              if (badgeCount > 0)
                Positioned(
                  right: 4, top: 4,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: AppColors.urgent,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: AppColors.background, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      badgeCount > 99 ? '99+' : '$badgeCount',
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _summaryStats(BuildContext context) {
    final items = [
      ('1,247', 'Total Users', Icons.people, AppColors.teal, () => _push(context, const AdminUsersView())),
      ('355', 'Active Businesses', Icons.business, AppColors.indigo, () => _push(context, const AdminBusinessesView())),
      ('89', 'Live Jobs', Icons.work, AppColors.online, () => _push(context, const AdminJobsView())),
      ('24', 'Applications Today', Icons.description, AppColors.amber, () => _push(context, const AdminApplicationsView())),
      ('5', 'Interviews Today', Icons.calendar_today, AppColors.teal, () => _push(context, const AdminInterviewsView())),
      ('3', 'Flagged Content', Icons.flag, AppColors.urgent, () => _push(context, const AdminReportsView())),
      ('6', 'Active Subs', Icons.credit_card, AppColors.online, () => _push(context, const AdminSubscriptionsView())),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: GestureDetector(
              onTap: item.$5,
              child: Container(
                width: 120,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: item.$4.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(AppRadius.md)),
                      child: Icon(item.$3, size: 18, color: item.$4),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(item.$1, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                    Text(item.$2, style: const TextStyle(fontSize: 10, color: AppColors.secondary), maxLines: 1),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _needsAttentionBanner(BuildContext context) {
    final items = [
      (Icons.flag, AppColors.urgent, '2 high-priority reports', 'Urgent', () => _push(context, const AdminReportsView())),
      (Icons.credit_card, AppColors.urgent, '1 failed payment', 'Urgent', () => _push(context, const AdminSubscriptionsView())),
      (Icons.calendar_today, AppColors.indigo, '3 interviews pending confirmation', 'Action', () => _push(context, const AdminInterviewsView())),
      (Icons.business, AppColors.amber, '1 business pending verification', 'Review', () => _push(context, const AdminBusinessesView())),
    ];
    return AdminCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Needs Attention', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
              const SizedBox(width: AppSpacing.sm),
              Container(
                width: 20, height: 20,
                decoration: const BoxDecoration(color: AppColors.urgent, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text('${items.length}', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...items.asMap().entries.map((e) {
            final i = e.value;
            return Column(
              children: [
                if (e.key > 0) Padding(padding: const EdgeInsets.only(left: 36), child: const Divider(height: 1, color: AppColors.divider)),
                GestureDetector(
                  onTap: i.$5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
                    child: Row(
                      children: [
                        Container(
                          width: 24, height: 24,
                          decoration: BoxDecoration(color: i.$2.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(AppRadius.sm)),
                          child: Icon(i.$1, size: 12, color: i.$2),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: Text(i.$3, style: const TextStyle(fontSize: 13, color: AppColors.secondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        StatusPill(text: i.$4, color: i.$4 == 'Urgent' ? AppColors.urgent : AppColors.amber),
                        const SizedBox(width: AppSpacing.sm),
                        const ForwardChevron(size: 12, color: AppColors.tertiary),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _quickActions(BuildContext context) {
    final actions = [
      (Icons.flag, 'Review Flagged Content', () => _push(context, const AdminReportsView())),
      (Icons.calendar_today, "Today's Interviews", () => _push(context, const AdminInterviewsView())),
      (Icons.credit_card, 'Manage Subscriptions', () => _push(context, const AdminSubscriptionsView())),
      (Icons.star, 'Featured Content', () => _push(context, const AdminContentFeaturedView())),
      (Icons.chat_bubble, 'Create Community Post', () => _push(context, const AdminCommunityView())),
      (Icons.notifications, 'Send Notification', () => _push(context, const AdminNotificationsView())),
      (Icons.bar_chart, 'Analytics Dashboard', () => _push(context, const AdminDashboardView())),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
        ),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Row(children: actions.map((a) => Padding(padding: const EdgeInsets.only(right: AppSpacing.sm), child: QuickActionChip(icon: a.$1, label: a.$2, onTap: a.$3))).toList()),
        ),
      ],
    );
  }

  Widget _platformOverview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Text('Platform Overview', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
        ),
        const SizedBox(height: AppSpacing.md),
        GestureDetector(
          onTap: () => _push(context, const AdminDashboardView()),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.teal.withValues(alpha: 0.08), AppColors.teal.withValues(alpha: 0.03)]),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.teal.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: AppColors.teal.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppRadius.md)),
                  child: const Icon(Icons.bar_chart, size: 20, color: AppColors.teal),
                ),
                const SizedBox(width: AppSpacing.lg),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Analytics Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                      SizedBox(height: 2),
                      Text('KPIs, trends, and platform health', style: TextStyle(fontSize: 13, color: AppColors.secondary)),
                    ],
                  ),
                ),
                const ForwardChevron(size: 16, color: AppColors.teal),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Row(
            children: [
              _miniStat('1,247', 'Users', AppColors.teal),
              const SizedBox(width: AppSpacing.md),
              _miniStat('89', 'Jobs', AppColors.indigo),
              const SizedBox(width: AppSpacing.md),
              _miniStat('24', 'Apps Today', AppColors.online),
              const SizedBox(width: AppSpacing.md),
              _miniStat('3', 'Reports', AppColors.urgent),
            ],
          ),
        ),
      ],
    );
  }

  Widget _miniStat(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md)),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.secondary)),
          ],
        ),
      ),
    );
  }

  Widget _sectionGroup(String title, List<_SectionRowData> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
        ),
        const SizedBox(height: AppSpacing.md),
        AdminCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: rows.asMap().entries.map((e) {
              return Column(
                children: [
                  if (e.key > 0) Padding(padding: const EdgeInsets.only(left: 28 + AppSpacing.md), child: const Divider(height: 1, color: AppColors.divider)),
                  GestureDetector(
                    onTap: e.value.action,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Row(
                        children: [
                          Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(color: e.value.iconColor.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(AppRadius.sm)),
                            child: Icon(e.value.icon, size: 15, color: e.value.iconColor),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e.value.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
                                const SizedBox(height: 1),
                                Text(e.value.subtitle, style: const TextStyle(fontSize: 12, color: AppColors.tertiary)),
                              ],
                            ),
                          ),
                          if (e.value.badge.isNotEmpty) ...[
                            StatusPill(text: e.value.badge, color: e.value.badgeColor),
                            const SizedBox(width: AppSpacing.sm),
                          ],
                          const ForwardChevron(size: 14, color: AppColors.tertiary),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SectionRowData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final VoidCallback action;
  _SectionRowData(this.icon, this.iconColor, this.title, this.subtitle, this.badge, this.badgeColor, this.action);
}
