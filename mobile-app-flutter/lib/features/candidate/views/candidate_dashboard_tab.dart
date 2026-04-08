import 'package:flutter/material.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/services/candidate_service.dart';

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
    final summary = _homeData?['applicationsSummary'] as Map<String, dynamic>?;
    final strength = (_homeData?['user']?['profileStrength'] as num?)?.toInt() ?? 0;

    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.teal,
        onRefresh: _loadHome,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          children: [
            // ── Header ──
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_greeting, style: const TextStyle(fontSize: 14, color: AppColors.secondary)),
                const SizedBox(height: 3),
                Text(
                  userName ?? 'Welcome to Plagit',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                ),
              ])),
              // Subtle avatar badge
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(Icons.person_outline, size: 20, color: AppColors.teal),
              ),
            ]),
            const SizedBox(height: 28),

            if (_loading)
              const Padding(padding: EdgeInsets.symmetric(vertical: 60), child: Center(child: CircularProgressIndicator(color: AppColors.teal, strokeWidth: 2.5)))
            else if (_error != null)
              _buildError()
            else ...[
              // ── Applications overview ──
              Container(
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
              const SizedBox(height: 14),

              // ── Quick actions ──
              Container(
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
              const SizedBox(height: 14),

              // ── Activity ──
              Container(
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
              const SizedBox(height: 14),

              // ── Profile strength ──
              _ProfileStrengthCard(strength: strength),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildError() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: AppColors.urgent.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(AppRadius.lg)),
    child: Column(children: [
      const Icon(Icons.error_outline, size: 28, color: AppColors.urgent),
      const SizedBox(height: 10),
      Text(_error!, style: const TextStyle(fontSize: 14, color: AppColors.urgent), textAlign: TextAlign.center),
      const SizedBox(height: 12),
      TextButton(onPressed: _loadHome, child: const Text('Retry')),
    ]),
  );

  static BoxDecoration _cardDecoration() => BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: BorderRadius.circular(AppRadius.lg),
    border: Border.all(color: AppColors.border),
    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
  );
}

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
