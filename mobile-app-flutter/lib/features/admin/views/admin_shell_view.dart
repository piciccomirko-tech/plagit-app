import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/features/admin/views/admin_dashboard_view.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

class AdminShellView extends StatefulWidget {
  const AdminShellView({super.key});
  @override
  State<AdminShellView> createState() => _AdminShellViewState();
}

class _AdminShellViewState extends State<AdminShellView> {
  int _currentIndex = 0;

  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      const AdminDashboardView(),
      const _AdminUsersTab(),
      const _AdminContentTab(),
      const _AdminModerationTab(),
      const _AdminMoreTab(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.navy,
        ),
        child: SafeArea(
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                _navItem(0, Icons.grid_view, 'Dashboard'),
                _navItem(1, Icons.people, 'Users'),
                _navItem(2, Icons.work, 'Content'),
                _navItem(3, Icons.shield, 'Moderation'),
                _navItem(4, Icons.more_horiz, 'More'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final active = _currentIndex == index;
    final color =
        active ? AppColors.teal : Colors.white.withValues(alpha: 0.6);
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    fontSize: 10, color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ── Tab: Users ──────────────────────────────────────────────────────────────

class _AdminUsersTab extends StatelessWidget {
  const _AdminUsersTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('Users',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal)),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _navCard(
              context,
              icon: Icons.person,
              color: AppColors.teal,
              title: 'Candidates',
              subtitle: 'Manage all candidate profiles',
              onTap: () => context.push('/admin/candidates'),
            ),
            const SizedBox(height: 14),
            _navCard(
              context,
              icon: Icons.business,
              color: AppColors.purple,
              title: 'Businesses',
              subtitle: 'Manage all business accounts',
              onTap: () => context.push('/admin/businesses'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab: Content ────────────────────────────────────────────────────────────

class _AdminContentTab extends StatelessWidget {
  const _AdminContentTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('Content',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal)),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _navCard(
              context,
              icon: Icons.work,
              color: AppColors.teal,
              title: 'Jobs',
              subtitle: 'Review and manage job listings',
              onTap: () => context.push('/admin/jobs'),
            ),
            const SizedBox(height: 14),
            _navCard(
              context,
              icon: Icons.description,
              color: AppColors.amber,
              title: 'Applications',
              subtitle: 'View all applications',
              onTap: () => context.push('/admin/applications'),
            ),
            const SizedBox(height: 14),
            _navCard(
              context,
              icon: Icons.calendar_today,
              color: AppColors.purple,
              title: 'Interviews',
              subtitle: 'Manage scheduled interviews',
              onTap: () => context.push('/admin/interviews'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab: Moderation ─────────────────────────────────────────────────────────

class _AdminModerationTab extends StatelessWidget {
  const _AdminModerationTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('Moderation',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal)),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _navCard(
              context,
              icon: Icons.verified_user,
              color: AppColors.teal,
              title: 'Verifications',
              subtitle: 'Review pending verifications',
              onTap: () => context.push('/admin/verifications'),
            ),
            const SizedBox(height: 14),
            _navCard(
              context,
              icon: Icons.flag,
              color: AppColors.red,
              title: 'Reports',
              subtitle: 'Handle reported content',
              onTap: () => context.push('/admin/reports'),
            ),
            const SizedBox(height: 14),
            _navCard(
              context,
              icon: Icons.support_agent,
              color: AppColors.amber,
              title: 'Support',
              subtitle: 'Manage support issues',
              onTap: () => context.push('/admin/support'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab: More ───────────────────────────────────────────────────────────────

class _AdminMoreTab extends StatelessWidget {
  const _AdminMoreTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('More',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal)),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _navCard(
              context,
              icon: Icons.bar_chart,
              color: AppColors.teal,
              title: 'Analytics',
              subtitle: 'Platform metrics and insights',
              onTap: () => context.push('/admin/analytics'),
            ),
            const SizedBox(height: 14),
            _navCard(
              context,
              icon: Icons.credit_card,
              color: AppColors.purple,
              title: 'Subscriptions',
              subtitle: 'Manage user subscriptions',
              onTap: () => context.push('/admin/subscriptions'),
            ),
            const SizedBox(height: 14),
            _navCard(
              context,
              icon: Icons.history,
              color: AppColors.amber,
              title: 'Audit Log',
              subtitle: 'Review admin actions',
              onTap: () => context.push('/admin/audit'),
            ),
            const SizedBox(height: 14),
            _navCard(
              context,
              icon: Icons.settings,
              color: AppColors.secondary,
              title: 'Settings',
              subtitle: 'Platform configuration',
              onTap: () => context.push('/admin/settings'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared nav card helper ──────────────────────────────────────────────────

Widget _navCard(
  BuildContext context, {
  required IconData icon,
  required Color color,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.charcoal)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.secondary)),
              ],
            ),
          ),
          const ForwardChevron(size: 20, color: AppColors.tertiary),
        ],
      ),
    ),
  );
}
