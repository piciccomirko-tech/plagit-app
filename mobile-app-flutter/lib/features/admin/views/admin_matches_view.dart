import 'package:flutter/material.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';

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
    final l = AppLocalizations.of(context);
    return Scaffold(backgroundColor: aBg, body: SafeArea(child: Column(children: [
      aTopBar(context, l.adminTitleMatchManagement),
      _tabRow(l),
      Expanded(child: _tab == 'Matches' ? _matchesList(l) : _tab == 'Stats' ? _statsView(l) : _tab == 'Feedback' ? _feedbackList(l) : _notifList(l)),
    ])));
  }

  String _tabLabel(AppLocalizations l, String t) {
    switch (t) {
      case 'Matches': return l.adminMenuMatches;
      case 'Notifications': return l.adminMenuNotifications;
      case 'Feedback': return l.adminTabFeedback;
      case 'Stats': return l.adminTabStats;
      default: return t;
    }
  }

  Widget _tabRow(AppLocalizations l) => Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), child: Row(children: _tabs.map((t) {
    final active = _tab == t;
    return Padding(padding: const EdgeInsets.only(right: 8), child: GestureDetector(onTap: () => setState(() => _tab = t), child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: active ? aTeal : aSurface, borderRadius: BorderRadius.circular(100)),
      child: Text(_tabLabel(l, t), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: active ? Colors.white : aSecondary)),
    )));
  }).toList()));

  Widget _matchesList(AppLocalizations l) => ListView.builder(padding: const EdgeInsets.fromLTRB(20, 12, 20, 32), itemCount: _matches.length, itemBuilder: (_, i) {
    final m = _matches[i];
    final sc = m.$10 == 'accepted' ? aGreen : m.$10 == 'denied' ? aUrgent : aAmber;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: aCard, borderRadius: BorderRadius.circular(16), boxShadow: [aSubtleShadow]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          aAvatar(m.$2, 36, verified: true),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(m.$1, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: aCharcoal)), Text(m.$4, style: const TextStyle(fontSize: 10, color: aTertiary))])),
          const Icon(Icons.arrow_forward, size: 13, color: aTeal),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(m.$7, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: aCharcoal)), Text(m.$8, style: const TextStyle(fontSize: 10, color: aTertiary))])),
          aPill(aStatusLabel(l, m.$10.toString()), sc),
        ]),
        const SizedBox(height: 12),
        Wrap(spacing: 8, children: [
          _tag(Icons.work, m.$5, aIndigo), _tag(Icons.schedule, m.$6, aTeal), _tag(Icons.attach_money, m.$9, aAmber),
        ]),
      ]),
    );
  });

  Widget _tag(IconData i, String t, Color c) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: c.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(100)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(i, size: 11, color: c), const SizedBox(width: 3), Text(t, style: TextStyle(fontSize: 10, color: c))]));

  Widget _statsView(AppLocalizations l) => SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
    GridView.count(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.8, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), children: [
      _statCard(l.adminStatTotalMatches, '48', Icons.verified, aGreen), _statCard(l.adminStatPendingCount, '12', Icons.schedule, aAmber),
      _statCard(l.adminStatAccepted, '28', Icons.check_circle, aGreen), _statCard(l.adminStatDenied, '8', Icons.cancel, aUrgent),
      _statCard(l.adminStatNotificationsCount, '36', Icons.notifications, aAmber), _statCard(l.adminStatFeedbackCount, '18', Icons.star, aIndigo),
    ]),
    const SizedBox(height: 16),
    Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: aCard, borderRadius: BorderRadius.circular(16), boxShadow: [aSubtleShadow]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l.adminStatMatchQuality, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: aSecondary)),
        const SizedBox(height: 8),
        Row(children: [const Text('78%', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: aTeal)), const SizedBox(width: 8), Text(l.adminMiscPositive, style: const TextStyle(fontSize: 13, color: aSecondary))]),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: 0.78, backgroundColor: aSurface, color: aTeal, minHeight: 8, borderRadius: BorderRadius.circular(4)),
      ]),
    ),
  ]));

  Widget _statCard(String t, String v, IconData i, Color c) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: aCard, borderRadius: BorderRadius.circular(16), boxShadow: [aSubtleShadow]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(i, size: 14, color: c), const SizedBox(width: 4), Expanded(child: Text(t, style: const TextStyle(fontSize: 10, color: aSecondary)))]), const SizedBox(height: 8), Text(v, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: aCharcoal))]));

  Widget _feedbackList(AppLocalizations l) => Center(child: Text(l.adminEmptyFeedback, style: const TextStyle(color: aSecondary)));
  Widget _notifList(AppLocalizations l) => Center(child: Text(l.adminEmptyMatchNotifs, style: const TextStyle(color: aSecondary)));
}
