import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/models/business_profile.dart';
import 'package:plagit/providers/business_providers.dart';

/// Business profile tab — the Profile TAB in business bottom nav.
class BusinessProfileView extends StatefulWidget {
  const BusinessProfileView({super.key});

  @override
  State<BusinessProfileView> createState() => _BusinessProfileViewState();
}

class _BusinessProfileViewState extends State<BusinessProfileView> {
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<BusinessAuthProvider>();
    final profile = authProvider.profile;

    // Loading / no profile
    if (profile == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.teal),
        ),
      );
    }

    final completion = profile.profileCompletion;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 24),

            // -- Top Section (centered, no card) --
            _buildTopSection(profile, completion),

            const SizedBox(height: 24),

            // A. Business Info
            _buildSectionCard(
              title: 'Business Info',
              onEdit: () => _snack('Profile editor coming soon'),
              children: [
                _infoRow('Name', profile.name),
                _divider(),
                _infoRow('Category', profile.category),
                _divider(),
                _infoRow('Size', profile.size),
                _divider(),
                _infoRow('Website', profile.website ?? ''),
              ],
            ),

            // B. Contact Details
            _buildSectionCard(
              title: 'Contact Details',
              onEdit: () => _snack('Profile editor coming soon'),
              children: [
                _infoRow('Contact Person', profile.contactName),
                _divider(),
                _infoRow('Email', profile.email),
                _divider(),
                _infoRow('Phone', profile.phone ?? ''),
              ],
            ),

            // C. Location
            _buildSectionCard(
              title: 'Location',
              onEdit: () => _snack('Profile editor coming soon'),
              children: [
                _infoRow('Address', profile.location),
              ],
            ),

            // D. About Us
            _buildSectionCard(
              title: 'About Us',
              onEdit: () => _snack('Profile editor coming soon'),
              children: [
                Text(
                  profile.description ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.charcoal,
                    height: 1.5,
                  ),
                ),
              ],
            ),

            // E. Verification
            _buildVerificationCard(),

            // F. Active Jobs Summary
            _buildActiveJobsCard(),

            // -- Settings Section --
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoal,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildSettingsCard(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // -- Top Section --
  Widget _buildTopSection(BusinessProfile profile, int completion) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Avatar with camera overlay
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.teal,
                child: Text(
                  profile.initials,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [AppColors.cardShadow],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 14,
                    color: AppColors.charcoal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            profile.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.charcoal,
            ),
          ),
          Text(
            profile.category,
            style: const TextStyle(fontSize: 14, color: AppColors.secondary),
          ),
          const SizedBox(height: 4),
          Text(
            '\u{1F4CD} ${profile.location}',
            style: const TextStyle(fontSize: 12, color: AppColors.secondary),
          ),
          const SizedBox(height: 16),

          // Profile completion
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: completion / 100,
                    minHeight: 5,
                    backgroundColor: AppColors.divider,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.teal),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$completion%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Complete Profile button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _snack('Profile editor coming soon'),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.teal.withValues(alpha: 0.08),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Complete Profile',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.teal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -- Section Card --
  Widget _buildSectionCard({
    required String title,
    required VoidCallback onEdit,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: AppColors.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoal,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onEdit,
                child: const Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: AppColors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  // -- Info Row --
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.secondary),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 14, color: AppColors.charcoal),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(color: AppColors.divider, height: 12);
  }

  // -- Verification Card --
  Widget _buildVerificationCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: AppColors.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, size: 20, color: AppColors.amber),
              const SizedBox(width: 8),
              const Text(
                'Not verified',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Get verified to build trust with candidates',
            style: TextStyle(fontSize: 12, color: AppColors.secondary),
          ),
        ],
      ),
    );
  }

  // -- Active Jobs Card --
  Widget _buildActiveJobsCard() {
    final jobsProvider = context.watch<BusinessJobsProvider>();
    final activeCount = jobsProvider.jobs.where((j) => j.status.displayName == 'Active').length;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: AppColors.cardDecoration,
      child: Row(
        children: [
          Text(
            '$activeCount Active Jobs',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.charcoal,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _snack('Switch to Jobs tab'),
            child: const Text(
              'Manage Jobs',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.teal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -- Settings Card --
  Widget _buildSettingsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: AppColors.cardDecoration,
      child: Column(
        children: [
          _settingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () => _snack('Notifications settings coming soon'),
          ),
          const Divider(height: 0, indent: 16, endIndent: 16, color: AppColors.divider),
          _settingsTile(
            icon: Icons.lock_outline,
            title: 'Privacy',
            onTap: () => _snack('Privacy settings coming soon'),
          ),
          const Divider(height: 0, indent: 16, endIndent: 16, color: AppColors.divider),
          _settingsTile(
            icon: Icons.workspace_premium_outlined,
            title: 'My Subscription',
            onTap: () => context.push('/business/subscription'),
          ),
          const Divider(height: 0, indent: 16, endIndent: 16, color: AppColors.divider),
          _settingsTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () => _snack('Help & Support coming soon'),
          ),
          const Divider(height: 0, indent: 16, endIndent: 16, color: AppColors.divider),
          _settingsTile(
            icon: Icons.logout,
            title: 'Sign Out',
            isDestructive: true,
            onTap: _showSignOutDialog,
          ),
        ],
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.red : AppColors.charcoal;
    return ListTile(
      leading: Icon(icon, size: 22, color: color),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isDestructive ? FontWeight.w600 : FontWeight.w400,
          color: color,
        ),
      ),
      trailing: isDestructive
          ? null
          : const Icon(Icons.chevron_right, size: 20, color: AppColors.tertiary),
      onTap: onTap,
    );
  }

  // -- Sign Out Dialog --
  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<BusinessAuthProvider>().logout();
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

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
