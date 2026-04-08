import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';

class AccountSettingsView extends StatelessWidget {
  const AccountSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Account Settings',
          style: TextStyle(
            color: AppColors.charcoal,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: [
          // ── Current Role Card ──
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [AppColors.cardShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACTIVE ROLE',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.teal,
                      child: const Text(
                        'TC',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Candidate',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.charcoal,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/auth/role-select'),
                      child: const Text(
                        'Switch',
                        style: TextStyle(
                          color: AppColors.teal,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Account Section ──
          _SectionCard(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            children: [
              _SettingsTile(
                title: 'Email',
                subtitle: MockData.candidate['email'] as String? ?? '',
                showChevron: false,
              ),
              const Divider(height: 1, color: AppColors.divider),
              _SettingsTile(
                title: 'Change Password',
                onTap: () => _showSnackbar(context, 'Change Password coming soon'),
              ),
              const Divider(height: 1, color: AppColors.divider),
              _SettingsTile(
                title: 'Phone',
                subtitle: MockData.candidate['phone'] as String? ?? '',
                onTap: () => _showSnackbar(context, 'Phone settings coming soon'),
              ),
            ],
          ),

          // ── Roles Section ──
          _SectionCard(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'My Roles',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.charcoal,
                  ),
                ),
              ),
              const Divider(height: 1, color: AppColors.divider),
              _RoleTile(
                icon: Icons.person,
                iconColor: AppColors.teal,
                title: 'Candidate',
                badgeText: 'Active',
                badgeColor: AppColors.teal,
              ),
              const Divider(height: 1, indent: 56, color: AppColors.divider),
              _RoleTile(
                icon: Icons.business,
                iconColor: AppColors.purple,
                title: 'Business',
                badgeText: 'Active',
                badgeColor: AppColors.teal,
              ),
              const Divider(height: 1, indent: 56, color: AppColors.divider),
              _RoleTile(
                icon: Icons.shield,
                iconColor: AppColors.navy,
                title: 'Admin',
                badgeText: 'Active',
                badgeColor: AppColors.teal,
              ),
              const Divider(height: 1, indent: 56, color: AppColors.divider),
              _RoleTile(
                icon: Icons.grid_view,
                iconColor: AppColors.amber,
                title: 'Services',
                badgeText: 'Browse',
                badgeColor: AppColors.secondary,
              ),
              const Divider(height: 1, color: AppColors.divider),
              InkWell(
                onTap: () => context.push('/entry'),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'Add new role',
                      style: TextStyle(
                        color: AppColors.teal,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Subscriptions Section ──
          _SectionCard(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Subscriptions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.charcoal,
                  ),
                ),
              ),
              const Divider(height: 1, color: AppColors.divider),
              _SubscriptionRow(
                plan: 'Candidate Plan',
                tier: 'Free',
                onUpgrade: () => context.push('/candidate/subscription'),
              ),
              const Divider(height: 1, color: AppColors.divider),
              _SubscriptionRow(
                plan: 'Business Plan',
                tier: 'Basic',
                onUpgrade: () => context.push('/business/subscription'),
              ),
            ],
          ),

          // ── Settings List ──
          _SectionCard(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            children: [
              _SettingsTile(
                title: 'Privacy & Security',
                onTap: () => _showSnackbar(context, 'Privacy & Security coming soon'),
              ),
              const Divider(height: 1, color: AppColors.divider),
              _SettingsTile(
                title: 'Notification Settings',
                onTap: () =>
                    _showSnackbar(context, 'Notification Settings coming soon'),
              ),
              const Divider(height: 1, color: AppColors.divider),
              _SettingsTile(
                title: 'Language',
                subtitle: 'English',
                onTap: () => _showSnackbar(context, 'Language settings coming soon'),
              ),
              const Divider(height: 1, color: AppColors.divider),
              _SettingsTile(
                title: 'Help & Support',
                onTap: () => _showSnackbar(context, 'Help & Support coming soon'),
              ),
              const Divider(height: 1, color: AppColors.divider),
              InkWell(
                onTap: () => _showSignOutDialog(context),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Text(
                    'Sign Out of All Roles',
                    style: TextStyle(
                      color: AppColors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of all roles?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/entry');
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Card ──

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets margin;

  const _SectionCard({
    required this.children,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadow],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

// ── Settings Tile ──

class _SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showChevron;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.title,
    this.subtitle,
    this.showChevron = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.charcoal,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showChevron && onTap != null)
              Icon(Icons.chevron_right, size: 20, color: AppColors.tertiary),
          ],
        ),
      ),
    );
  }
}

// ── Role Tile ──

class _RoleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String badgeText;
  final Color badgeColor;

  const _RoleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.badgeText,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: iconColor.withValues(alpha: 0.12),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.charcoal,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: badgeColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Subscription Row ──

class _SubscriptionRow extends StatelessWidget {
  final String plan;
  final String tier;
  final VoidCallback onUpgrade;

  const _SubscriptionRow({
    required this.plan,
    required this.tier,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              plan,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.charcoal,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              tier,
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onUpgrade,
            child: const Text(
              'Upgrade',
              style: TextStyle(
                color: AppColors.teal,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
