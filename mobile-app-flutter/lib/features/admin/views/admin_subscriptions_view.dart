import 'package:flutter/material.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';

class AdminSubscriptionsView extends StatefulWidget {
  const AdminSubscriptionsView({super.key});
  @override
  State<AdminSubscriptionsView> createState() => _AdminSubscriptionsViewState();
}

class _AdminSubscriptionsViewState extends State<AdminSubscriptionsView> {
  int _chip = 0;
  static const _filters = ['All', 'Active', 'Expired', 'Cancelled'];
  static const _mock = [
    {'user': 'Marco Rossi', 'initials': 'MR', 'plan': 'Premium', 'price': '£9.99/mo', 'status': 'active', 'expiry': '2026-05-15'},
    {'user': 'The Ritz London', 'initials': 'TR', 'plan': 'Pro', 'price': '£29/mo', 'status': 'active', 'expiry': '2026-06-01'},
    {'user': 'Sarah Chen', 'initials': 'SC', 'plan': 'Premium', 'price': '£9.99/mo', 'status': 'expired', 'expiry': '2026-03-01'},
    {'user': 'Cipriani', 'initials': 'CI', 'plan': 'Basic', 'price': '£19/mo', 'status': 'cancelled', 'expiry': '2026-04-01'},
  ];

  Color _statusColor(String s) => switch (s) { 'active' => aGreen, 'expired' => aAmber, 'cancelled' => aUrgent, _ => aTertiary };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final labels = [l.adminFilterAll, l.adminStatusActive, l.adminStatusExpired, l.adminStatusCancelled];
    var items = _mock.toList();
    if (_chip > 0) { items = items.where((s) => s['status'] == _filters[_chip].toLowerCase()).toList(); }
    final activeCount = _mock.where((s) => s['status'] == 'active').length;

    return Scaffold(backgroundColor: aBg, body: SafeArea(child: Column(children: [
      aTopBar(context, l.adminMenuSubscriptions),
      // Summary stats
      Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 8), child: Row(children: [
        _miniStat('£194', l.adminStatRevenue, aTeal),
        const SizedBox(width: 16), _miniStat('$activeCount', l.adminStatActiveCount, aGreen),
        const SizedBox(width: 16), _miniStat('${_mock.length}', l.adminStatTotal, aCharcoal),
      ])),
      aChips(labels: labels, selected: _chip, onTap: (i) => setState(() => _chip = i)),
      if (items.isEmpty) Expanded(child: aEmpty(Icons.credit_card, l.adminEmptySubsTitle, l.adminEmptySubsSub))
      else Expanded(child: ListView.separated(padding: const EdgeInsets.fromLTRB(20, 8, 20, 48), itemCount: items.length, separatorBuilder: (_, i) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final s = items[i]; final color = _statusColor(s['status'] as String);
          return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: aCard, borderRadius: BorderRadius.circular(20), boxShadow: [aCardShadow]),
            child: Row(children: [
              aAvatar(s['initials'] as String, 40),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s['user'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: aCharcoal)),
                Row(children: [Text(s['plan'] as String, style: const TextStyle(fontSize: 13, color: aSecondary)), const Text(' · ', style: TextStyle(color: aTertiary)), Text(s['price'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: aCharcoal))]),
                Text('Expires ${s['expiry']}', style: const TextStyle(fontSize: 11, color: aTertiary)),
              ])),
              aPill(aStatusLabel(l, s['status'] as String), color),
            ]));
        },
      )),
    ])));
  }

  Widget _miniStat(String value, String label, Color color) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: const TextStyle(fontSize: 11, color: aSecondary)),
  ]);
}
