import 'package:flutter/material.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';

class AdminMatchesView extends StatefulWidget {
  const AdminMatchesView({super.key});
  @override State<AdminMatchesView> createState() => _S();
}

class _S extends State<AdminMatchesView> {
  String _tab = 'Matches';
  final _tabs = ['Matches', 'Notifications', 'Feedback', 'Stats'];

  final _matches = [
    ('Elena Rossi', 'ER', 0.52, 'London, UK', 'Executive Chef', 'Full-time', 'Senior Chef', 'Nobu Restaurant', '\$5,500/mo', 'accepted'),
    ('Marco Bianchi', 'MB', 0.35, 'Milan, Italy', 'Sommelier', 'Full-time', 'Head Sommelier', 'The Ritz London', '\$4,200/mo', 'pending'),
    ('Sofia Andersen', 'SA', 0.72, 'Dubai, UAE', 'Front Desk', 'Full-time', 'Concierge', 'Burj Al Arab', '\$3,800/mo', 'pending'),
    ('Ahmed Al-Rashid', 'AA', 0.15, 'Dubai, UAE', 'Barista', 'Part-time', 'Bartender', 'Sketch London', '\$18/hr', 'denied'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppColors.background, body: SafeArea(child: Column(children: [
      AdminTopBar(title: 'Match Management', onBack: () => Navigator.pop(context)),
      _tabRow(),
      Expanded(child: _tab == 'Matches' ? _matchesList() : _tab == 'Stats' ? _statsView() : _tab == 'Feedback' ? _feedbackList() : _notifList()),
    ])));
  }

  Widget _tabRow() => Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm), child: Row(children: _tabs.map((t) {
    final active = _tab == t;
    return Padding(padding: const EdgeInsets.only(right: AppSpacing.sm), child: GestureDetector(onTap: () => setState(() => _tab = t), child: Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      decoration: BoxDecoration(color: active ? AppColors.teal : AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.full)),
      child: Text(t, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: active ? Colors.white : AppColors.secondary)),
    )));
  }).toList()));

  Widget _matchesList() => ListView.builder(padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xxxl), itemCount: _matches.length, itemBuilder: (_, i) {
    final m = _matches[i];
    final sc = m.$10 == 'accepted' ? AppColors.online : m.$10 == 'denied' ? AppColors.urgent : AppColors.amber;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          AvatarCircle(initials: m.$2, hue: m.$3, size: 36, verified: true),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(m.$1, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.charcoal)), Text(m.$4, style: const TextStyle(fontSize: 10, color: AppColors.tertiary))])),
          const Icon(Icons.arrow_forward, size: 13, color: AppColors.teal),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(m.$7, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.charcoal)), Text(m.$8, style: const TextStyle(fontSize: 10, color: AppColors.tertiary))])),
          StatusPill(text: m.$10.toString().substring(0, 1).toUpperCase() + m.$10.toString().substring(1), color: sc),
        ]),
        const SizedBox(height: AppSpacing.md),
        Wrap(spacing: AppSpacing.sm, children: [
          _tag(Icons.work, m.$5, AppColors.indigo), _tag(Icons.schedule, m.$6, AppColors.teal), _tag(Icons.attach_money, m.$9, AppColors.amber),
        ]),
      ]),
    );
  });

  Widget _tag(IconData i, String t, Color c) => Container(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3), decoration: BoxDecoration(color: c.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppRadius.full)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(i, size: 11, color: c), const SizedBox(width: 3), Text(t, style: TextStyle(fontSize: 10, color: c))]));

  Widget _statsView() => SingleChildScrollView(padding: const EdgeInsets.all(AppSpacing.xl), child: Column(children: [
    GridView.count(crossAxisCount: 2, mainAxisSpacing: AppSpacing.md, crossAxisSpacing: AppSpacing.md, childAspectRatio: 1.8, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), children: [
      _statCard('Total Matches', '48', Icons.verified, AppColors.online), _statCard('Pending', '12', Icons.schedule, AppColors.amber),
      _statCard('Accepted', '28', Icons.check_circle, AppColors.online), _statCard('Denied', '8', Icons.cancel, AppColors.urgent),
      _statCard('Notifications', '36', Icons.notifications, AppColors.amber), _statCard('Feedback', '18', Icons.star, AppColors.indigo),
    ]),
    const SizedBox(height: AppSpacing.lg),
    AdminCard(margin: EdgeInsets.zero, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Match Quality Score', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.secondary)),
      const SizedBox(height: AppSpacing.sm),
      const Row(children: [Text('78%', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.teal)), SizedBox(width: AppSpacing.sm), Text('positive', style: TextStyle(fontSize: 13, color: AppColors.secondary))]),
      const SizedBox(height: AppSpacing.sm),
      LinearProgressIndicator(value: 0.78, backgroundColor: AppColors.surface, color: AppColors.teal, minHeight: 8, borderRadius: BorderRadius.circular(4)),
    ])),
  ]));

  Widget _statCard(String t, String v, IconData i, Color c) => Container(padding: const EdgeInsets.all(AppSpacing.lg), decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(AppRadius.lg), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(i, size: 14, color: c), const SizedBox(width: AppSpacing.xs), Expanded(child: Text(t, style: const TextStyle(fontSize: 10, color: AppColors.secondary)))]), const SizedBox(height: AppSpacing.sm), Text(v, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.charcoal))]));

  Widget _feedbackList() => const Center(child: Text('Feedback data will appear here', style: TextStyle(color: AppColors.secondary)));
  Widget _notifList() => const Center(child: Text('Match notifications will appear here', style: TextStyle(color: AppColors.secondary)));
}
