import 'package:flutter/material.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';

class AdminNotificationsView extends StatefulWidget {
  const AdminNotificationsView({super.key});
  @override State<AdminNotificationsView> createState() => _S();
}

class _S extends State<AdminNotificationsView> {
  int _filterIdx = 0;
  final _filters = ['All', 'Unread', 'Failed', 'Read', 'Candidate', 'Business', 'System'];
  final _notifs = [
    ('Interview Confirmed', 'Elena Rossi', 'Candidate', 'Push', 'Delivered', 'Interview #1234', 'interviews/detail', true, 0, 'Mar 20'),
    ('New Application Received', 'Nobu Restaurant', 'Business', 'Push', 'Delivered', 'Application #5678', 'applications/detail', true, 0, 'Mar 19'),
    ('Account Verification Required', 'Sofia Andersen', 'Candidate', 'Email', 'Failed', 'Profile Verification', 'profile/verify', false, 2, 'Mar 18'),
    ('Subscription Expiring', 'Sketch London', 'Business', 'In-App', 'Pending', 'Subscription #90', 'billing/detail', false, 0, 'Mar 17'),
    ('Welcome to Plagit', 'Ahmed Al-Rashid', 'Candidate', 'Push', 'Delivered', 'Onboarding', 'home', true, 0, 'Mar 16'),
    ('Payment Failed', 'Zuma Dubai', 'Business', 'Email', 'Failed', 'Invoice #456', 'billing/invoice', false, 3, 'Mar 15'),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final chipLabels = [
      l.adminFilterAll,
      l.adminFilterUnread,
      l.adminStatusFailed,
      l.adminFilterRead,
      l.adminFilterCandidate,
      l.adminFilterBusiness,
      l.adminFilterSystem,
    ];
    final filter = _filters[_filterIdx];
    final filtered = filter == 'All' ? _notifs : filter == 'Unread' ? _notifs.where((n) => !n.$8).toList() : filter == 'Failed' ? _notifs.where((n) => n.$5 == 'Failed').toList() : filter == 'Read' ? _notifs.where((n) => n.$8 && n.$5 != 'Failed').toList() : _notifs.where((n) => n.$3 == filter).toList();
    return Scaffold(backgroundColor: aBg, body: SafeArea(child: Column(children: [
      aTopBar(context, l.adminMenuNotifications),
      Padding(padding: const EdgeInsets.only(top: 4), child: SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(children: [
        _summaryChip(l.adminFilterAll, '${_notifs.length}', aCharcoal), const SizedBox(width: 8),
        _summaryChip(l.adminFilterUnread, '${_notifs.where((n) => !n.$8).length}', aAmber), const SizedBox(width: 8),
        _summaryChip(l.adminStatusFailed, '${_notifs.where((n) => n.$5 == 'Failed').length}', aUrgent), const SizedBox(width: 8),
        _summaryChip(l.adminFilterCandidate, '${_notifs.where((n) => n.$3 == 'Candidate').length}', aTeal), const SizedBox(width: 8),
        _summaryChip(l.adminFilterBusiness, '${_notifs.where((n) => n.$3 == 'Business').length}', aIndigo),
      ]))),
      Padding(padding: const EdgeInsets.only(top: 8), child: aChips(labels: chipLabels, selected: _filterIdx, onTap: (i) => setState(() => _filterIdx = i))),
      _sortRow(l.adminCountNotifs(filtered.length), l),
      Expanded(child: filtered.isEmpty ? aEmpty(Icons.notifications_off, l.adminEmptyNotifsTitle, l.adminEmptyAdjustFilters) : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Container(
          decoration: BoxDecoration(color: aCard, borderRadius: BorderRadius.circular(20), boxShadow: [aSubtleShadow]),
          child: Column(children: filtered.asMap().entries.map((e) {
            final n = e.value;
            final typeColor = n.$4 == 'Push' ? aTeal : n.$4 == 'Email' ? aIndigo : n.$4 == 'In-App' ? aAmber : aGreen;
            final typeIcon = n.$4 == 'Push' ? Icons.notifications : n.$4 == 'Email' ? Icons.email : n.$4 == 'In-App' ? Icons.phone_android : Icons.sms;
            final deliveryColor = n.$5 == 'Delivered' ? aGreen : n.$5 == 'Failed' ? aUrgent : aAmber;
            final deliveryIcon = n.$5 == 'Delivered' ? Icons.check_circle : n.$5 == 'Failed' ? Icons.cancel : Icons.schedule;
            return Column(children: [
              if (e.key > 0) Padding(padding: const EdgeInsets.only(left: 68), child: const Divider(height: 1, color: aDivider)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 36, height: 36, decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)), child: Icon(typeIcon, size: 16, color: typeColor)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Flexible(child: Text(n.$1, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: aCharcoal), maxLines: 1, overflow: TextOverflow.ellipsis)), const SizedBox(width: 4), Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), decoration: BoxDecoration(color: deliveryColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(100)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(deliveryIcon, size: 10, color: deliveryColor), const SizedBox(width: 2), Text(aStatusLabel(l, n.$5), style: TextStyle(fontSize: 10, color: deliveryColor))]))]),
                  const SizedBox(height: 4),
                  Row(children: [Text(n.$2, style: const TextStyle(fontSize: 13, color: aSecondary)), const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), decoration: BoxDecoration(color: (n.$3 == 'Candidate' ? aTeal : aIndigo).withValues(alpha: 0.06), borderRadius: BorderRadius.circular(100)), child: Text(n.$3 == 'Candidate' ? l.adminFilterCandidate : l.adminFilterBusiness, style: TextStyle(fontSize: 10, color: n.$3 == 'Candidate' ? aTeal : aIndigo))), const Text(' · ', style: TextStyle(fontSize: 10, color: aTertiary)), Text(n.$4, style: TextStyle(fontSize: 10, color: typeColor))]),
                  const SizedBox(height: 4),
                  Row(children: [const Icon(Icons.link, size: 10, color: aTertiary), const SizedBox(width: 2), Text(n.$6, style: const TextStyle(fontSize: 10, color: aSecondary))]),
                  const SizedBox(height: 4),
                  Row(children: [if (!n.$8 && n.$5 != 'Failed') ...[Container(width: 5, height: 5, decoration: const BoxDecoration(color: aTeal, shape: BoxShape.circle)), const SizedBox(width: 8)], if (n.$9 > 0) ...[aPill(l.adminBadgeNRetried(n.$9), aAmber), const SizedBox(width: 8)], Text(n.$10, style: const TextStyle(fontSize: 10, color: aTertiary))]),
                ])),
                const Icon(Icons.more_horiz, size: 18, color: aTertiary),
              ])),
            ]);
          }).toList()),
        ),
      )),
    ])));
  }

  Widget _summaryChip(String label, String count, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(count, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(fontSize: 10, color: aSecondary)),
    ]),
  );

  Widget _sortRow(String countLabel, AppLocalizations l) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    child: Row(children: [
      Text(countLabel, style: const TextStyle(fontSize: 13, color: aSecondary)),
      const Spacer(),
      GestureDetector(onTap: () {}, child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(l.adminSortNewest, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: aTeal)),
        const SizedBox(width: 4),
        const Icon(Icons.swap_vert, size: 14, color: aTeal),
      ])),
    ]),
  );
}
