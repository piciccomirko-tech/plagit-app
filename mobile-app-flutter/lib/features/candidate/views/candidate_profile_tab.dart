import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/models/candidate_profile.dart';
import 'package:plagit/providers/candidate_providers.dart';

/// Candidate profile — mirrors CandidateRealProfileView.swift exactly.
class CandidateProfileTab extends StatefulWidget {
  const CandidateProfileTab({super.key});

  @override
  State<CandidateProfileTab> createState() => _CandidateProfileTabState();
}

class _CandidateProfileTabState extends State<CandidateProfileTab> {
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<CandidateAuthProvider>().profile == null) _load();
    });
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      await context.read<CandidateAuthProvider>().refreshProfile();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<CandidateAuthProvider>();
    final profile = auth.profile;

    // Loading / error / null gate
    if (profile == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: _loading
              ? const CircularProgressIndicator(color: AppColors.teal, strokeWidth: 2.5)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_outline, size: 40, color: AppColors.tertiary),
                    const SizedBox(height: 12),
                    Text(_error ?? 'Profile not available', style: const TextStyle(fontSize: 14, color: AppColors.secondary)),
                    const SizedBox(height: 16),
                    TextButton(onPressed: _load, child: const Text('Retry', style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.w600))),
                  ],
                ),
        ),
      );
    }

    final sub = auth.subscription;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── TOP BAR (matches Swift topBar) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const SizedBox(width: 36, height: 36, child: Icon(Icons.chevron_left, size: 24, color: AppColors.charcoal)),
                  ),
                  const Spacer(),
                  const Text('Profile', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.push('/candidate/profile/edit'),
                    child: const Text('Edit', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.teal)),
                  ),
                ],
              ),
            ),

            // ── SCROLLABLE CONTENT ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 4, bottom: 32),
                child: Column(
                  children: [
                    _heroCard(profile, sub.plan.isPremium),
                    const SizedBox(height: 20),
                    _subscriptionCard(sub.plan.isPremium),
                    const SizedBox(height: 20),
                    _profileStrengthCard(profile),
                    const SizedBox(height: 20),
                    _detailsCard(profile),
                    const SizedBox(height: 20),
                    _contactCard(profile),
                    const SizedBox(height: 28),
                    _logoutButton(auth),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // HERO CARD — matches Swift heroCard exactly
  // ═══════════════════════════════════════════

  Widget _heroCard(CandidateProfile p, bool isPremium) {
    final hue = p.avatarHue;
    final avatarColor = HSLColor.fromAHSL(1, hue * 360, 0.5, 0.55).toColor();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          // Avatar row: avatar left + text right (Swift HStack)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar 72px with camera badge
              SizedBox(
                width: 76,
                height: 76,
                child: Stack(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: avatarColor),
                      child: Center(child: Text(p.initials, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white))),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(color: AppColors.teal, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, size: 10, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Name + role + location (Swift VStack)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + PRO badge
                    Row(
                      children: [
                        Flexible(child: Text(p.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.charcoal))),
                        if (isPremium) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [AppColors.amber, Color(0xCCF59E0B)]),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.workspace_premium, size: 9, color: Colors.white),
                                SizedBox(width: 3),
                                Text('PRO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (p.role != null && p.role!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(p.role!.trim(), style: const TextStyle(fontSize: 15, color: AppColors.secondary)),
                    ],
                    if (p.location != null && p.location!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.place, size: 10, color: AppColors.teal),
                          const SizedBox(width: 4),
                          Text(p.location!.trim(), style: const TextStyle(fontSize: 13, color: AppColors.teal)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          // Badges row
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isPremium) _badge('Premium', AppColors.amber),
              if (isPremium) const SizedBox(width: 12),
              if (p.isVerified) _badge('Verified', AppColors.green),
              if (p.isVerified) const SizedBox(width: 12),
              _badge(
                _verificationLabel(p.verificationStatus),
                p.verificationStatus == 'verified' ? AppColors.green : AppColors.amber,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(100)),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color)),
    );
  }

  String _verificationLabel(String? status) {
    return switch (status) {
      'verified' => 'Verified',
      'pending' => 'Pending Review',
      'rejected' => 'Rejected',
      _ => 'New',
    };
  }

  // ═══════════════════════════════════════════
  // SUBSCRIPTION CARD — matches Swift subscriptionCard
  // ═══════════════════════════════════════════

  Widget _subscriptionCard(bool isPremium) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: isPremium
          ? Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.amber.withValues(alpha: 0.2), AppColors.amber.withValues(alpha: 0.05)]),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.workspace_premium, size: 16, color: AppColors.amber),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current Plan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.secondary)),
                      SizedBox(height: 2),
                      Text('Premium', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                    ],
                  ),
                ),
                _badge('Active', AppColors.amber),
              ],
            )
          : Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: const Color(0xFFF5F5F7), shape: BoxShape.circle),
                      child: const Icon(Icons.workspace_premium, size: 16, color: AppColors.tertiary),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Current Plan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.secondary)),
                          SizedBox(height: 2),
                          Text('Free', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () => context.push('/candidate/subscription'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.teal, AppColors.darkTeal]),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.workspace_premium, size: 12, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Unlock Premium', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // ═══════════════════════════════════════════
  // PROFILE STRENGTH — matches Swift profileStrengthCard
  // ═══════════════════════════════════════════

  Widget _profileStrengthCard(CandidateProfile p) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Profile Strength', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.secondary)),
              const Spacer(),
              Text('${p.profileStrength}%', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.teal)),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(height: 6, decoration: BoxDecoration(color: const Color(0xFFF5F5F7), borderRadius: BorderRadius.circular(4))),
                  Container(
                    height: 6,
                    width: constraints.maxWidth * (p.profileStrength / 100.0),
                    decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(4)),
                  ),
                ],
              );
            },
          ),
          if (p.profileStrength < 100) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('CV upload coming soon'), behavior: SnackBarBehavior.floating),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.teal.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.description_outlined, size: 13, color: AppColors.teal),
                    SizedBox(width: 8),
                    Text('Upload CV', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.teal)),
                    Spacer(),
                    Text('Auto-fill your profile', style: TextStyle(fontSize: 11, color: AppColors.tertiary)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // DETAILS CARD — matches Swift detailSections infoCard("Details")
  // ═══════════════════════════════════════════

  Widget _detailsCard(CandidateProfile p) {
    return _infoCard('Details', [
      (Icons.place, 'Based In', p.location?.trim() ?? 'Not set'),
      (Icons.schedule, 'Experience', p.experience != null ? '${p.experience} years' : 'Not set'),
      (Icons.language, 'Languages', p.languages?.isNotEmpty == true ? p.languages! : 'Not set'),
      (Icons.verified_user_outlined, 'Verification', _verificationLabel(p.verificationStatus)),
    ]);
  }

  Widget _contactCard(CandidateProfile p) {
    return _infoCard('Contact', [
      (Icons.email_outlined, 'Email', p.email),
      (Icons.phone_outlined, 'Phone', p.phone ?? 'Not set'),
    ]);
  }

  Widget _infoCard(String title, List<(IconData, String, String)> rows) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.secondary)),
          const SizedBox(height: 16),
          ...rows.map((row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Icon(row.$1, size: 13, color: AppColors.teal),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(row.$2, style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
                        const SizedBox(height: 2),
                        Text(row.$3, style: const TextStyle(fontSize: 15, color: AppColors.charcoal)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // LOGOUT — matches Swift logoutSection
  // ═══════════════════════════════════════════

  Widget _logoutButton(CandidateAuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => _showSignOutDialog(auth),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.red.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, size: 14, color: AppColors.red),
              SizedBox(width: 8),
              Text('Sign Out', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.red)),
            ],
          ),
        ),
      ),
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
