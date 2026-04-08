import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/models/candidate_profile.dart';
import 'package:plagit/providers/candidate_providers.dart';

class CandidateProfileTab extends StatefulWidget {
  const CandidateProfileTab({super.key});

  @override
  State<CandidateProfileTab> createState() => _CandidateProfileTabState();
}

class _CandidateProfileTabState extends State<CandidateProfileTab> {
  bool _loadAttempted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<CandidateAuthProvider>();
      if (auth.profile == null && !_loadAttempted) {
        _loadAttempted = true;
        auth.refreshProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<CandidateAuthProvider>();
    final profile = authProvider.profile;

    // Profile not loaded yet — show spinner briefly then fallback
    if (profile == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: _loadAttempted
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_outline, size: 48, color: AppColors.tertiary),
                    const SizedBox(height: 12),
                    const Text('Unable to load profile', style: TextStyle(fontSize: 15, color: AppColors.secondary)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _loadAttempted = false);
                        context.read<CandidateAuthProvider>().refreshProfile();
                        setState(() => _loadAttempted = true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                )
              : const CircularProgressIndicator(color: AppColors.teal),
        ),
      );
    }

    return _CandidateProfileContent(
      profile: profile,
      onLogout: () => _showSignOutDialog(authProvider),
    );
  }

  void _showSignOutDialog(CandidateAuthProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign out?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.secondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              provider.logout();
              context.go('/entry');
            },
            child: const Text('Sign Out', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _CandidateProfileContent extends StatelessWidget {
  final CandidateProfile profile;
  final VoidCallback onLogout;

  const _CandidateProfileContent({
    required this.profile,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final completion = profile.completionPercentage;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 40),
          children: [
            const SizedBox(height: 24),

            // -- Top section: Avatar + name --
            Center(
              child: Column(
                children: [
                  // Avatar with camera overlay
                  SizedBox(
                    width: 88,
                    height: 88,
                    child: Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.teal,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(profile.initials, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
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
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 4)],
                            ),
                            child: const Icon(Icons.camera_alt, size: 14, color: AppColors.charcoal),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.charcoal),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.role ?? '',
                    style: const TextStyle(fontSize: 14, color: AppColors.secondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\u{1F4CD} ${profile.location ?? 'London, UK'}',
                    style: const TextStyle(fontSize: 12, color: AppColors.secondary),
                  ),
                  const SizedBox(height: 16),

                  // Profile completion
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text('$completion%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.teal)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: completion / 100,
                                  backgroundColor: AppColors.divider,
                                  color: AppColors.teal,
                                  minHeight: 6,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () => context.push('/candidate/profile/edit'),
                            style: TextButton.styleFrom(
                              backgroundColor: AppColors.lightTeal.withValues(alpha: 0.2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: const Text('Complete Profile', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.teal)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // -- A. Personal Info --
            _SectionCard(
              title: 'Personal Info',
              onEdit: () => context.push('/candidate/profile/edit'),
              child: Column(
                children: [
                  _InfoRow(label: 'Name', value: profile.name),
                  const Divider(height: 1, color: AppColors.divider),
                  _InfoRow(label: 'Email', value: profile.email),
                  const Divider(height: 1, color: AppColors.divider),
                  _InfoRow(label: 'Phone', value: profile.phone ?? ''),
                  const Divider(height: 1, color: AppColors.divider),
                  _InfoRow(label: 'Nationality', value: profile.nationality ?? ''),
                ],
              ),
            ),

            // -- B. Work Preferences --
            _SectionCard(
              title: 'Work Preferences',
              onEdit: () => context.push('/candidate/profile/edit'),
              child: Column(
                children: [
                  _InfoRow(label: 'Target Role', value: profile.role ?? ''),
                  const Divider(height: 1, color: AppColors.divider),
                  _InfoRow(label: 'Contract', value: profile.contractPreference ?? ''),
                  const Divider(height: 1, color: AppColors.divider),
                  _InfoRow(label: 'Availability', value: profile.availability ?? ''),
                  const Divider(height: 1, color: AppColors.divider),
                  _InfoRow(label: 'Salary', value: profile.salary ?? ''),
                ],
              ),
            ),

            // -- C. Experience --
            _SectionCard(
              title: 'Experience',
              onEdit: () => context.push('/candidate/profile/edit'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      '${profile.experience ?? ''} experience',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  _ExperienceRow(role: 'Waiter at The Savoy', period: 'Jan 2023 - Present'),
                  const Divider(height: 1, color: AppColors.divider),
                  _ExperienceRow(role: 'Runner at Sketch', period: 'Jun 2021 - Dec 2022'),
                ],
              ),
            ),

            // -- D. Languages --
            _SectionCard(
              title: 'Languages',
              onEdit: () => context.push('/candidate/profile/edit'),
              child: Column(
                children: [
                  _LanguageRow(flag: '\u{1F1EC}\u{1F1E7}', language: 'English (Fluent)'),
                  const Divider(height: 1, color: AppColors.divider),
                  _LanguageRow(flag: '\u{1F1EE}\u{1F1F9}', language: 'Italian (Native)'),
                ],
              ),
            ),

            // -- E. Certifications --
            _SectionCard(
              title: 'Certifications',
              trailing: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, size: 16, color: AppColors.teal),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    const Text(
                      'Add certifications to stand out',
                      style: TextStyle(fontSize: 13, color: AppColors.secondary, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {},
                      child: const Text('Add', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.teal)),
                    ),
                  ],
                ),
              ),
            ),

            // -- F. CV --
            _SectionCard(
              title: 'CV',
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file_outlined, size: 20, color: AppColors.teal),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('CV_TestCandidate.pdf', style: TextStyle(fontSize: 14, color: AppColors.charcoal)),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: const Text('View', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.teal)),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Replace', style: TextStyle(fontSize: 12, color: AppColors.secondary)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // -- G. Verification --
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: AppColors.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shield_outlined, size: 20, color: profile.isVerified ? AppColors.teal : AppColors.amber),
                      const SizedBox(width: 8),
                      Text(
                        profile.isVerified ? 'Verified' : 'Not verified',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: profile.isVerified ? AppColors.teal : AppColors.amber),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.isVerified ? 'Your profile is verified' : 'Get verified for more opportunities',
                    style: const TextStyle(fontSize: 12, color: AppColors.secondary),
                  ),
                ],
              ),
            ),

            // -- Settings --
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
            ),
            const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: AppColors.cardDecoration,
              child: Column(
                children: [
                  _SettingsTile(icon: Icons.notifications_outlined, label: 'Notifications', onTap: () {}),
                  const Divider(height: 1, color: AppColors.divider, indent: 52),
                  _SettingsTile(icon: Icons.lock_outline, label: 'Privacy & Security', onTap: () {}),
                  const Divider(height: 1, color: AppColors.divider, indent: 52),
                  _SettingsTile(icon: Icons.workspace_premium_outlined, label: 'My Subscription', onTap: () => context.push('/candidate/subscription')),
                  const Divider(height: 1, color: AppColors.divider, indent: 52),
                  _SettingsTile(icon: Icons.help_outline, label: 'Help & Support', onTap: () {}),
                  const Divider(height: 1, color: AppColors.divider),
                  _SettingsTile(
                    icon: Icons.logout,
                    label: 'Sign Out',
                    color: AppColors.red,
                    showChevron: false,
                    onTap: onLogout,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// -- Section card with title + edit/trailing --
class _SectionCard extends StatelessWidget {
  final String title;
  final VoidCallback? onEdit;
  final Widget? trailing;
  final Widget child;

  const _SectionCard({
    required this.title,
    this.onEdit,
    this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: AppColors.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 8),
            child: Row(
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                const Spacer(),
                if (trailing != null)
                  trailing!
                else if (onEdit != null)
                  GestureDetector(
                    onTap: onEdit,
                    child: const Icon(Icons.edit_outlined, size: 18, color: AppColors.teal),
                  ),
              ],
            ),
          ),
          child,
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// -- Info row: label + value --
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.secondary)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 14, color: AppColors.charcoal)),
        ],
      ),
    );
  }
}

// -- Experience row --
class _ExperienceRow extends StatelessWidget {
  final String role;
  final String period;
  const _ExperienceRow({required this.role, required this.period});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(child: Text(role, style: const TextStyle(fontSize: 14, color: AppColors.charcoal))),
          Text(period, style: const TextStyle(fontSize: 12, color: AppColors.secondary)),
        ],
      ),
    );
  }
}

// -- Language row --
class _LanguageRow extends StatelessWidget {
  final String flag;
  final String language;
  const _LanguageRow({required this.flag, required this.language});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Text(language, style: const TextStyle(fontSize: 14, color: AppColors.charcoal)),
        ],
      ),
    );
  }
}

// -- Settings tile --
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool showChevron;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.color = AppColors.charcoal,
    this.showChevron = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: TextStyle(fontSize: 15, color: color))),
            if (showChevron) const Icon(Icons.chevron_right, size: 20, color: AppColors.tertiary),
          ],
        ),
      ),
    );
  }
}
