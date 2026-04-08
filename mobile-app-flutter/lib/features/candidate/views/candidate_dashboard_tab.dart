import 'package:flutter/material.dart';
import 'package:plagit/services/candidate_service.dart';

// ── Premium Plagit Colors ──
class _C {
  static const bg = Color(0xFFF5F5F7);
  static const card = Colors.white;
  static const teal = Color(0xFF2BB8B0);
  static const gold = Color(0xFFFFD700);
  static const charcoal = Color(0xFF1A1C24);
  static const secondary = Color(0xFF707580);
  static const tertiary = Color(0xFF9EA0AD);
  static const amber = Color(0xFFF59E33);
  static const green = Color(0xFF2ECC71);
}

BoxDecoration _cardDeco() => BoxDecoration(
  color: _C.card,
  borderRadius: BorderRadius.circular(16),
  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 2))],
);

/// Premium candidate home dashboard.
class CandidateDashboardTab extends StatefulWidget {
  const CandidateDashboardTab({super.key});
  @override
  State<CandidateDashboardTab> createState() => _CandidateDashboardTabState();
}

class _CandidateDashboardTabState extends State<CandidateDashboardTab> {
  final _service = CandidateService();
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final d = await _service.getHome();
      if (mounted) setState(() { _data = d; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final name = _data?['user']?['name']?.toString();
    final first = name?.split(' ').first ?? 'there';
    final loc = _data?['user']?['location']?.toString() ?? '';
    final summary = _data?['applicationsSummary'] as Map<String, dynamic>?;
    final jobs = (_data?['featuredJobs'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: _C.teal, strokeWidth: 2.5))
            : RefreshIndicator(
                color: _C.teal,
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    _header(first, loc, name ?? ''),
                    _searchBar(),
                    _bannerCard(Icons.map_outlined, 'Explore Nearby Jobs', 'Discover opportunities close to you', _C.teal),
                    _nextStepCard(),
                    _bannerCard(Icons.verified_outlined, 'Your Matches', 'Jobs matching your role and preferences', _C.teal),
                    _premiumCard(context),
                    if (jobs.isNotEmpty) _jobsNearYou(jobs, context),
                    if (jobs.isNotEmpty) _featuredJobs(jobs, context),
                    _applicationsCard(summary),
                    _nextInterviewCard(),
                    _messagesCard(),
                    _profileStrengthCard(),
                    _communityCard(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
      ),
    );
  }

  // ── Header ──
  Widget _header(String name, String location, String fullName) {
    // Initials: first letter of first name + first letter of last name
    final parts = fullName.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : (name.isNotEmpty ? name[0].toUpperCase() : '?');

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Row(children: [
        // Avatar
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: _C.teal,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(child: Text(
            initials,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5),
          )),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$_greeting, $name', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _C.charcoal)),
            if (location.isNotEmpty) ...[
              const SizedBox(height: 2),
              Row(children: [
                const Icon(Icons.location_on, size: 13, color: _C.teal),
                const SizedBox(width: 3),
                Text(location, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _C.teal)),
              ]),
            ],
          ],
        )),
        _iconBtn(Icons.chat_bubble_outline, () {}),
        const SizedBox(width: 6),
        _iconBtn(Icons.notifications_outlined, () {}),
      ]),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(color: _C.bg, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 20, color: _C.secondary),
      ),
    );
  }

  // ── Search Bar ──
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(color: const Color(0xFFEEEEF0), borderRadius: BorderRadius.circular(14)),
        child: const Row(children: [
          Icon(Icons.search, size: 19, color: _C.tertiary),
          SizedBox(width: 10),
          Text('Search jobs, roles, restaurants...', style: TextStyle(fontSize: 15, color: _C.tertiary)),
        ]),
      ),
    );
  }

  // ── Your Next Step Card ──
  Widget _nextStepCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        decoration: _cardDeco(),
        child: IntrinsicHeight(child: Row(children: [
          // Gold left accent bar
          Container(
            width: 4,
            decoration: const BoxDecoration(
              color: _C.gold,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
            ),
          ),
          Expanded(child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Label
              Row(children: [
                Text('✦', style: TextStyle(fontSize: 11, color: _C.gold)),
                const SizedBox(width: 5),
                Text('YOUR NEXT STEP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _C.gold, letterSpacing: 0.8)),
              ]),
              const SizedBox(height: 10),
              const Text('Interview scheduled', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _C.charcoal)),
              const SizedBox(height: 5),
              Text('Waiter · Sat, Apr 11 · 4:09 pm · Video', style: TextStyle(fontSize: 13, color: _C.secondary)),
              const SizedBox(height: 16),
              // CTA
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.teal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('View Details'),
                ),
              ),
            ]),
          )),
        ])),
      ),
    );
  }

  // ── Full-width Banner Card ──
  Widget _bannerCard(IconData icon, String title, String subtitle, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDeco(),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 22, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _C.charcoal)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: _C.secondary)),
          ])),
          Icon(Icons.chevron_right, size: 18, color: _C.tertiary),
        ]),
      ),
    );
  }

  // ── Jobs Near You ──
  Widget _jobsNearYou(List<Map<String, dynamic>> jobs, BuildContext ctx) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
        child: Row(children: [
          const Text('Jobs Near You', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _C.charcoal)),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: Row(children: [
              const Text('See All', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _C.teal)),
              const SizedBox(width: 3),
              const Icon(Icons.chevron_right, size: 16, color: _C.teal),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 14),
      SizedBox(
        height: 180,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: jobs.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) => _JobCard(job: jobs[i]),
        ),
      ),
    ]);
  }

  // ── Featured Jobs (large horizontal scroll) ──
  Widget _featuredJobs(List<Map<String, dynamic>> jobs, BuildContext ctx) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
        child: Row(children: [
          const Text('Featured Jobs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _C.charcoal)),
          const Spacer(),
          GestureDetector(onTap: () {}, child: const Row(children: [
            Text('See All', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _C.teal)),
            SizedBox(width: 3),
            Icon(Icons.chevron_right, size: 16, color: _C.teal),
          ])),
        ]),
      ),
      const SizedBox(height: 14),
      SizedBox(
        height: 195,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: jobs.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, i) => _LargeJobCard(job: jobs[i]),
        ),
      ),
    ]);
  }

  // ── My Applications (compact) ──
  Widget _applicationsCard(Map<String, dynamic>? summary) {
    final total = (summary?['applied'] ?? 3) + (summary?['under_review'] ?? 1) + (summary?['interview'] ?? 1) + (summary?['offer'] ?? 0);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: _cardDeco(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(color: _C.teal.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.description_outlined, size: 17, color: _C.teal),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('My Applications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _C.charcoal))),
            Text('$total total', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _C.secondary)),
          ]),
          const SizedBox(height: 16),
          _appRow('Under Review', summary?['under_review'] ?? 1, _C.amber),
          const SizedBox(height: 10),
          _appRow('Interview', summary?['interview'] ?? 1, _C.teal),
          const SizedBox(height: 10),
          _appRow('Offer', summary?['offer'] ?? 0, _C.green),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {},
            child: const Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text('View All', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _C.teal)),
              SizedBox(width: 3),
              Icon(Icons.chevron_right, size: 16, color: _C.teal),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _appRow(String label, dynamic count, Color color) {
    return Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 10),
      Expanded(child: Text(label, style: const TextStyle(fontSize: 14, color: _C.charcoal))),
      Text('$count', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
    ]);
  }

  // ── Next Interview ──
  Widget _nextInterviewCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: _cardDeco(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(color: _C.teal.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.calendar_today, size: 16, color: _C.teal),
            ),
            const SizedBox(width: 12),
            const Text('Next Interview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _C.charcoal)),
          ]),
          const SizedBox(height: 14),
          const Text('Waiter · Sat, Apr 11 · 4:53 pm · Video', style: TextStyle(fontSize: 13, color: _C.secondary, height: 1.4)),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity, height: 42,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.teal, foregroundColor: Colors.white, elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              child: const Text('View Interviews'),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Messages ──
  Widget _messagesCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: _cardDeco(),
          child: Row(children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(color: _C.teal.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.chat_bubble_outline, size: 16, color: _C.teal),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('Messages', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _C.charcoal)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: _C.teal, borderRadius: BorderRadius.circular(100)),
                  child: const Text('2', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ]),
              const SizedBox(height: 3),
              const Text('2 unread messages · Tap to view all conversations', style: TextStyle(fontSize: 12, color: _C.secondary)),
            ])),
            const Icon(Icons.chevron_right, size: 18, color: _C.tertiary),
          ]),
        ),
      ),
    );
  }

  // ── Profile Strength ──
  Widget _profileStrengthCard() {
    const strength = 65;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: _cardDeco(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(color: _C.teal.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.shield_outlined, size: 17, color: _C.teal),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('Profile Strength', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _C.charcoal))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(color: _C.teal.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(100)),
              child: const Text('$strength%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _C.teal)),
            ),
          ]),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(value: strength / 100, backgroundColor: Color(0xFFEEEEF0), color: _C.teal, minHeight: 5),
          ),
          const SizedBox(height: 16),
          _checkItem('Photo uploaded', true),
          const SizedBox(height: 8),
          _checkItem('Location set', true),
          const SizedBox(height: 8),
          _checkItem('Role selected', true),
          const SizedBox(height: 8),
          _checkItem('Experience added', true),
          const SizedBox(height: 8),
          _checkItem('Languages added', true),
          const SizedBox(height: 8),
          _checkItem('CV uploaded', false),
          const SizedBox(height: 8),
          _checkItem('Phone verified', false),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity, height: 42,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: _C.teal,
                side: const BorderSide(color: _C.teal, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              child: const Text('Complete Profile'),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _checkItem(String label, bool done) {
    return Row(children: [
      Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, size: 18, color: done ? _C.green : _C.tertiary),
      const SizedBox(width: 10),
      Text(label, style: TextStyle(fontSize: 13, color: done ? _C.charcoal : _C.tertiary, decoration: done ? null : null)),
    ]);
  }

  // ── From the Community ──
  Widget _communityCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: _cardDeco(),
        child: Column(children: [
          Row(children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(color: _C.teal.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.people_outline, size: 17, color: _C.teal),
            ),
            const SizedBox(width: 12),
            const Text('From the Community', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _C.charcoal)),
          ]),
          const SizedBox(height: 20),
          Icon(Icons.forum_outlined, size: 32, color: _C.tertiary.withValues(alpha: 0.5)),
          const SizedBox(height: 10),
          const Text('No community posts yet', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _C.secondary)),
          const SizedBox(height: 4),
          const Text('Be the first to share something', style: TextStyle(fontSize: 12, color: _C.tertiary)),
          const SizedBox(height: 4),
        ]),
      ),
    );
  }

  // ── Unlock Premium ──
  Widget _premiumCard(BuildContext ctx) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: _cardDeco(),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: _C.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.workspace_premium, size: 22, color: _C.amber),
            ),
            const SizedBox(width: 14),
            const Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Unlock Premium', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _C.charcoal)),
                SizedBox(height: 2),
                Text('Get more visibility and priority access', style: TextStyle(fontSize: 12, color: _C.secondary)),
              ],
            )),
            const Icon(Icons.chevron_right, size: 20, color: _C.amber),
          ]),
        ),
      ),
    );
  }
}

// ── Featured Job Card ──
class _JobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  const _JobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final title = job['title'] ?? '';
    final biz = job['businessName'] ?? job['business_name'] ?? '';
    final loc = job['location'] ?? '';
    final salary = job['salary'] ?? '';
    final type = job['employmentType'] ?? job['employment_type'] ?? '';
    final featured = job['isFeatured'] == true;
    final hue = ((biz.hashCode % 360).abs() / 360.0 * 360).clamp(0.0, 360.0);

    return Container(
      width: 185,
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Company avatar + name
        Row(children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: HSLColor.fromAHSL(1, hue, 0.30, 0.88).toColor(),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text(
              biz.isNotEmpty ? biz[0].toUpperCase() : '?',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: HSLColor.fromAHSL(1, hue, 0.50, 0.45).toColor()),
            )),
          ),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(biz, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _C.charcoal), maxLines: 1, overflow: TextOverflow.ellipsis),
            if (loc.isNotEmpty) Text(loc, style: const TextStyle(fontSize: 10, color: _C.tertiary), maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
        ]),
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _C.charcoal), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 6),
        Row(children: [
          if (salary.isNotEmpty) Text(salary, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _C.teal)),
          if (salary.isNotEmpty && type.isNotEmpty) const Text(' · ', style: TextStyle(color: _C.tertiary)),
          if (type.isNotEmpty) Flexible(child: Text(type, style: const TextStyle(fontSize: 11, color: _C.secondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ]),
        const Spacer(),
        if (featured)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: _C.amber.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(100)),
            child: const Text('Featured', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _C.amber)),
          ),
      ]),
    );
  }
}

// ── Large Featured Job Card ──
class _LargeJobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  const _LargeJobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final title = job['title'] ?? '';
    final biz = job['businessName'] ?? job['business_name'] ?? '';
    final loc = job['location'] ?? '';
    final salary = job['salary'] ?? '';
    final type = job['employmentType'] ?? job['employment_type'] ?? '';
    final featured = job['isFeatured'] == true;
    final hue = ((biz.hashCode % 360).abs() / 360.0 * 360).clamp(0.0, 360.0);

    return Container(
      width: 220,
      padding: const EdgeInsets.all(18),
      decoration: _cardDeco(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Company avatar + name + location
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: HSLColor.fromAHSL(1, hue, 0.30, 0.88).toColor(),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(
              biz.isNotEmpty ? biz[0].toUpperCase() : '?',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: HSLColor.fromAHSL(1, hue, 0.50, 0.45).toColor()),
            )),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(biz, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _C.charcoal), maxLines: 1, overflow: TextOverflow.ellipsis),
            if (loc.isNotEmpty) Text(loc, style: const TextStyle(fontSize: 10, color: _C.tertiary), maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
        ]),
        const SizedBox(height: 14),
        // Job title
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _C.charcoal), maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 8),
        // Salary
        if (salary.isNotEmpty)
          Text(salary, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _C.teal)),
        const Spacer(),
        // Badges row
        Wrap(spacing: 6, runSpacing: 4, children: [
          if (type.isNotEmpty) _badge(type, _C.secondary),
          if (featured) _badge('Featured', _C.amber),
        ]),
      ]),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(100)),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
