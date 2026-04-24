import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/features/admin/views/admin_account_sheet.dart';
import 'package:plagit/providers/admin_providers.dart';

const Color _adminIndigo = Color(0xFF6676F0);

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Color _activityColor(String color) {
    switch (color) {
      case 'green':
        return AppColors.green;
      case 'teal':
        return AppColors.teal;
      case 'amber':
        return AppColors.amber;
      case 'red':
        return AppColors.red;
      case 'purple':
        return AppColors.purple;
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = MockData.adminStats;
    final activities = MockData.adminRecentActivity;
    final issues = MockData.adminSupportIssues;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            // ── HEADER ──
            _AdminDashboardHeader(greeting: _greeting()),

            // ── STATS GRID ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.person,
                          iconBg: AppColors.teal,
                          value: '${stats['totalCandidates']}',
                          label: 'Candidates',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.business,
                          iconBg: AppColors.purple,
                          value: '${stats['totalBusinesses']}',
                          label: 'Businesses',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.work,
                          iconBg: AppColors.amber,
                          value: '${stats['activeJobs']}',
                          label: 'Active Jobs',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.description,
                          iconBg: AppColors.green,
                          value: '${stats['applicationsToday']}',
                          label: 'Applications Today',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── ALERT CARDS ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                children: [
                  // Pending Verifications
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: const Border(
                        left: BorderSide(color: AppColors.amber, width: 3),
                      ),
                      boxShadow: [AppColors.cardShadow],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '\u26A0 ${stats['pendingVerifications']} Pending Verifications',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.charcoal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Review and approve verifications',
                                style: TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/admin/verifications'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.amber.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Review Now',
                              style: TextStyle(
                                color: AppColors.amber,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Reported Content
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: const Border(
                        left: BorderSide(color: AppColors.red, width: 3),
                      ),
                      boxShadow: [AppColors.cardShadow],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '\uD83D\uDEA8 ${stats['reportedContent']} Reports Need Review',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.charcoal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Flagged content requiring moderation',
                                style: TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/admin/moderation'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.red.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Review Reports',
                              style: TextStyle(
                                color: AppColors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── RECENT ACTIVITY ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [AppColors.cardShadow],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Activity',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.charcoal,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              color: AppColors.teal,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ...List.generate(activities.length, (i) {
                      final a = activities[i];
                      return Column(
                        children: [
                          if (i > 0) const SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: _activityColor(a['color'] as String),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  a['text'] as String,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.charcoal,
                                  ),
                                ),
                              ),
                              Text(
                                a['time'] as String,
                                style: const TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),

            // ── QUICK STATS ROW ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _MiniStatCard(
                      icon: Icons.calendar_today,
                      iconColor: AppColors.teal,
                      value: '${stats['interviewsThisWeek']}',
                      label: 'Interviews',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniStatCard(
                      icon: Icons.star,
                      iconColor: AppColors.amber,
                      value: '${stats['premiumSubscribers']}',
                      label: 'Premium',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniStatCard(
                      icon: Icons.help_outline,
                      iconColor: AppColors.red,
                      value: '${MockData.adminSupportIssues.length}',
                      label: 'Support',
                    ),
                  ),
                ],
              ),
            ),

            // ── SUPPORT PREVIEW ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [AppColors.cardShadow],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Open Support Issues',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.charcoal,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/admin/support'),
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              color: AppColors.teal,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(issues.length, (i) {
                      final issue = issues[i];
                      return Column(
                        children: [
                          if (i > 0)
                            const Divider(color: AppColors.divider, height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      issue['title'] as String,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: AppColors.charcoal,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      issue['userName'] as String,
                                      style: const TextStyle(
                                        color: AppColors.secondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _StatusBadge(status: issue['status'] as String),
                                  const SizedBox(height: 4),
                                  Text(
                                    issue['created'] as String,
                                    style: const TextStyle(
                                      color: AppColors.secondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
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

// ── Header (Search / Notifications / Account) ──
class _AdminDashboardHeader extends StatelessWidget {
  final String greeting;
  const _AdminDashboardHeader({required this.greeting});

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
    final auth = context.watch<AdminAuthProvider>();
    final unread = context.watch<AdminNotificationsProvider>().unreadCount;
    final initials = _initials(auth.userName.isEmpty ? 'Admin User' : auth.userName);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
      decoration: const BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Admin Portal',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$greeting, ${auth.userName.isEmpty ? 'Admin' : auth.userName.split(' ').first}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          _HeaderIconButton(
            icon: Icons.search,
            tooltip: 'Search',
            onTap: () => context.push('/admin/search'),
          ),
          const SizedBox(width: 4),
          _HeaderIconButton(
            icon: Icons.notifications_outlined,
            tooltip: 'Notifications',
            badgeCount: unread,
            onTap: () => context.push('/admin/notifications'),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => showAdminAccountSheet(context),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_adminIndigo, AppColors.teal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final int badgeCount;

  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              if (badgeCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: AppColors.red,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.navy, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      badgeCount > 99 ? '99+' : '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
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
}

// ── Stat Card Widget ──
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconBg,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: iconBg, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.secondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mini Stat Card Widget ──
class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _MiniStatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.secondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status Badge Widget ──
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  Color get _color {
    switch (status) {
      case 'Open':
        return AppColors.amber;
      case 'In Review':
        return AppColors.teal;
      case 'Waiting':
        return AppColors.red;
      case 'Resolved':
        return AppColors.green;
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
