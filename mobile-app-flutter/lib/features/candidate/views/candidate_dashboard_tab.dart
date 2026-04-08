import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/services/candidate_service.dart';

/// Candidate home dashboard — mirrors HomeView.swift.
class CandidateDashboardTab extends StatefulWidget {
  const CandidateDashboardTab({super.key});

  @override
  State<CandidateDashboardTab> createState() => _CandidateDashboardTabState();
}

class _CandidateDashboardTabState extends State<CandidateDashboardTab> {
  final _service = CandidateService();
  Map<String, dynamic>? _homeData;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHome();
  }

  Future<void> _loadHome() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _service.getHome();
      if (mounted) setState(() { _homeData = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final userName = _homeData?['user']?['name']?.toString();
    final userFirstName = userName?.split(' ').first ?? 'there';
    final userLocation = _homeData?['user']?['location']?.toString() ?? '';
    final summary = _homeData?['applicationsSummary'] as Map<String, dynamic>?;
    final strength = (_homeData?['user']?['profileStrength'] as num?)?.toInt() ?? 0;
    final featuredJobs = (_homeData?['featuredJobs'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.teal,
        onRefresh: _loadHome,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
          children: [
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 80),
                child: Center(child: CircularProgressIndicator(color: AppColors.teal, strokeWidth: 2.5)),
              )
            else if (_error != null)
              _buildError()
            else ...[
              // ── Header (mirrors Swift headerSection) ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.teal, AppColors.tealDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Center(
                        child: Text(
                          (userFirstName.isNotEmpty ? userFirstName[0] : '?').toUpperCase(),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_greeting, $userFirstName',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                          ),
                          if (userLocation.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Row(children: [
                              const Icon(Icons.location_on, size: 12, color: AppColors.teal),
                              const SizedBox(width: 3),
                              Text(userLocation, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.teal)),
                            ]),
                          ],
                        ],
                      ),
                    ),
                    // Notification bell
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(Icons.notifications_outlined, size: 20, color: AppColors.charcoal),
                    ),
                  ],
                ),
              ),

              // ── Search bar (mirrors Swift searchSection) ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: const Row(children: [
                    Icon(Icons.search, size: 18, color: AppColors.tertiary),
                    SizedBox(width: 10),
                    Text('Search jobs, roles, companies...', style: TextStyle(fontSize: 15, color: AppColors.tertiary)),
                  ]),
                ),
              ),
              const SizedBox(height: 20),

              // ── Nearby banner (mirrors Swift nearbyBanner) ──
              _BannerCard(
                icon: Icons.map,
                gradientColors: const [AppColors.teal, AppColors.tealDark],
                title: 'Explore Nearby Jobs',
                subtitle: 'Discover opportunities close to you',
                chevronColor: AppColors.teal,
              ),
              const SizedBox(height: 14),

              // ── Matches banner (mirrors Swift matchesBanner) ──
              _BannerCard(
                icon: Icons.verified,
                gradientColors: const [AppColors.online, AppColors.teal],
                title: 'Your Matches',
                subtitle: 'Jobs matching your role and job type',
                chevronColor: AppColors.teal,
              ),
              const SizedBox(height: 20),

              // ── Featured Jobs horizontal scroll (mirrors Swift jobsNearYouSection) ──
              if (featuredJobs.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(children: [
                    const Text('Jobs Near You', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                    const Spacer(),
                    Row(children: [
                      Text('See All', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.teal)),
                      const SizedBox(width: 3),
                      Icon(Icons.chevron_right, size: 14, color: AppColors.teal),
                    ]),
                  ]),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Row(children: [
                    Icon(Icons.location_on, size: 12, color: AppColors.teal),
                    const SizedBox(width: 4),
                    Text('${featuredJobs.length} jobs available', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.secondary)),
                  ]),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 170,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: featuredJobs.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (_, i) => _FeaturedJobCard(job: featuredJobs[i]),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ── Applications overview (mirrors Swift applicationsSummary) ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: _cardDecoration(),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: AppColors.teal.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(AppRadius.md)),
                        child: const Icon(Icons.description_outlined, size: 17, color: AppColors.teal),
                      ),
                      const SizedBox(width: 12),
                      const Text('Your Applications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                    ]),
                    const SizedBox(height: 18),
                    Row(children: [
                      _StatCell(count: summary?['applied'] ?? 0, label: 'Applied', color: AppColors.teal),
                      const SizedBox(width: 10),
                      _StatCell(count: summary?['under_review'] ?? 0, label: 'In Review', color: AppColors.amber),
                      const SizedBox(width: 10),
                      _StatCell(count: summary?['interview'] ?? 0, label: 'Interview', color: AppColors.indigo),
                      const SizedBox(width: 10),
                      _StatCell(count: summary?['offer'] ?? 0, label: 'Offers', color: AppColors.online),
                    ]),
                  ]),
                ),
              ),
              const SizedBox(height: 14),

              // ── Quick actions ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  decoration: _cardDecoration(),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                    const SizedBox(height: 18),
                    Row(children: [
                      _ActionItem(icon: Icons.search, label: 'Find Jobs', color: AppColors.teal),
                      const SizedBox(width: 14),
                      _ActionItem(icon: Icons.chat_outlined, label: 'Messages', color: AppColors.indigo),
                      const SizedBox(width: 14),
                      _ActionItem(icon: Icons.person_outline, label: 'Profile', color: AppColors.amber),
                    ]),
                  ]),
                ),
              ),
              const SizedBox(height: 14),

              // ── Activity ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: _cardDecoration(),
                  child: Column(children: [
                    _ActivityItem(icon: Icons.mail_outline, label: 'Unread messages', count: _homeData?['unreadMessages'] ?? 0, color: AppColors.indigo),
                    Padding(
                      padding: const EdgeInsets.only(left: 48, top: 10, bottom: 10),
                      child: Divider(height: 1, color: AppColors.divider),
                    ),
                    _ActivityItem(icon: Icons.notifications_outlined, label: 'Notifications', count: _homeData?['unreadNotifications'] ?? 0, color: AppColors.amber),
                  ]),
                ),
              ),
              const SizedBox(height: 14),

              // ── Profile strength ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _ProfileStrengthCard(strength: strength),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildError() => Padding(
    padding: const EdgeInsets.all(20),
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.urgent.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Column(children: [
        const Icon(Icons.error_outline, size: 28, color: AppColors.urgent),
        const SizedBox(height: 10),
        Text(_error!, style: const TextStyle(fontSize: 14, color: AppColors.urgent), textAlign: TextAlign.center),
        const SizedBox(height: 12),
        TextButton(onPressed: _loadHome, child: const Text('Retry')),
      ]),
    ),
  );

  static BoxDecoration _cardDecoration() => BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: BorderRadius.circular(AppRadius.lg),
    border: Border.all(color: AppColors.border),
    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
  );
}

// ── Banner card (nearby, matches, premium) ──

class _BannerCard extends StatelessWidget {
  final IconData icon;
  final List<Color> gradientColors;
  final String title;
  final String subtitle;
  final Color chevronColor;

  const _BannerCard({
    required this.icon,
    required this.gradientColors,
    required this.title,
    required this.subtitle,
    required this.chevronColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
              const SizedBox(height: 3),
              Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
            ],
          )),
          Icon(Icons.chevron_right, size: 18, color: chevronColor),
        ]),
      ),
    );
  }
}

// ── Featured job card (horizontal scroll) ──

class _FeaturedJobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  const _FeaturedJobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final title = job['title'] ?? '';
    final business = job['businessName'] ?? job['business_name'] ?? '';
    final location = job['location'] ?? '';
    final salary = job['salary'] ?? '';
    final type = job['employmentType'] ?? job['employment_type'] ?? '';
    final isFeatured = job['isFeatured'] == true;

    // Generate a hue from the business name for the avatar
    final hue = (business.hashCode % 360).abs() / 360.0;

    return GestureDetector(
      onTap: () {
        final jobId = job['id']?.toString();
        if (jobId != null) context.push('/candidate/job/$jobId');
      },
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Business avatar + name
            Row(children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      HSLColor.fromAHSL(1, hue * 360, 0.45, 0.65).toColor(),
                      HSLColor.fromAHSL(1, hue * 360, 0.55, 0.50).toColor(),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    business.isNotEmpty ? business[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(business, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.charcoal), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (location.isNotEmpty)
                    Text(location, style: const TextStyle(fontSize: 10, color: AppColors.tertiary), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              )),
            ]),
            const SizedBox(height: 12),

            // Job title
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),

            // Salary + type
            Row(children: [
              if (salary.isNotEmpty) Text(salary, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.teal)),
              if (salary.isNotEmpty && type.isNotEmpty) const Text(' · ', style: TextStyle(color: AppColors.tertiary)),
              if (type.isNotEmpty) Flexible(child: Text(type, style: const TextStyle(fontSize: 12, color: AppColors.secondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),

            const Spacer(),

            // Featured badge
            if (isFeatured)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.amber.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: const Text('Featured', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.amber)),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Stat cell ──

class _StatCell extends StatelessWidget {
  final dynamic count;
  final String label;
  final Color color;
  const _StatCell({required this.count, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.08)),
      ),
      child: Column(children: [
        Text('$count', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: color)),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.secondary)),
      ]),
    ),
  );
}

// ── Quick action item ──

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _ActionItem({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(icon, color: color, size: 21),
      ),
      const SizedBox(height: 10),
      Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
    ]),
  );
}

// ── Activity row ──

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final dynamic count;
  final Color color;
  const _ActivityItem({required this.icon, required this.label, required this.count, required this.color});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(
      width: 36, height: 36,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Icon(icon, size: 17, color: color),
    ),
    const SizedBox(width: 14),
    Expanded(child: Text(label, style: const TextStyle(fontSize: 15, color: AppColors.charcoal))),
    Text('$count', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color)),
  ]);
}

// ── Profile strength card ──

class _ProfileStrengthCard extends StatelessWidget {
  final int strength;
  const _ProfileStrengthCard({required this.strength});
  @override
  Widget build(BuildContext context) {
    final Color barColor = strength >= 80 ? AppColors.online : strength >= 50 ? AppColors.amber : AppColors.urgent;
    final String hint = strength >= 80
        ? 'Looking great — you stand out to employers.'
        : strength >= 50
            ? 'A few more details will boost your visibility.'
            : 'Complete your profile to get noticed by recruiters.';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: barColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppRadius.md)),
            child: Icon(Icons.shield_outlined, size: 17, color: barColor),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Text('Profile Strength', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.charcoal))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: barColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppRadius.full)),
            child: Text('$strength%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: barColor)),
          ),
        ]),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: strength / 100, backgroundColor: AppColors.surface, color: barColor, minHeight: 5),
        ),
        const SizedBox(height: 12),
        Text(hint, style: const TextStyle(fontSize: 13, color: AppColors.tertiary, height: 1.4)),
      ]),
    );
  }
}
