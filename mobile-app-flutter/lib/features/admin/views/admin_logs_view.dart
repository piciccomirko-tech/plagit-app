import 'package:flutter/material.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';

class AdminLogsView extends StatefulWidget {
  const AdminLogsView({super.key});
  @override State<AdminLogsView> createState() => _S();
}

class _S extends State<AdminLogsView> {
  int _filterIdx = 0;
  final _filters = ['All', 'Today', 'Users', 'Jobs', 'Businesses', 'Reports', 'Billing', 'Settings'];
  final _logs = [
    ('Business verified', 'The Ritz London', 'Businesses', 'Admin M.', '2 min ago', 'Success', null, null),
    ('Candidate verified', 'Elena Rossi', 'Users', 'Admin M.', '15 min ago', 'Success', null, null),
    ('Report resolved', 'Spam post removed', 'Reports', 'Admin M.', '32 min ago', 'Success', 'Open', 'Resolved'),
    ('Job approved', 'Senior Chef at Nobu', 'Jobs', 'Admin M.', '1h ago', 'Success', 'Pending', 'Active'),
    ('Account suspended', 'Suspicious activity - John D.', 'Users', 'Admin M.', '2h ago', 'Success', 'Active', 'Suspended'),
    ('Subscription renewed', 'Nobu Restaurant - Premium', 'Billing', 'System', '3h ago', 'Success', null, null),
    ('Settings updated', 'Push notifications enabled', 'Settings', 'Admin M.', '5h ago', 'Success', 'Disabled', 'Enabled'),
    ('Failed payment retry', 'Sketch London - Basic', 'Billing', 'System', '6h ago', 'Failed', null, null),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final chipLabels = [
      loc.adminFilterAll,
      loc.adminFilterToday,
      loc.adminMenuUsers,
      loc.adminMenuJobs,
      loc.adminMenuBusinesses,
      loc.adminMenuReports,
      loc.adminFilterBilling,
      loc.adminMenuSettings,
    ];
    final filter = _filters[_filterIdx];
    final filtered = filter == 'All' ? _logs : filter == 'Today' ? _logs : _logs.where((l) => l.$3 == filter).toList();
    return Scaffold(backgroundColor: aBg, body: SafeArea(child: Column(children: [
      aTopBar(context, loc.adminTitleAdminLogs),
      Padding(padding: const EdgeInsets.only(top: 4), child: SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(children: [
        _summaryChip(loc.adminFilterAll, '${_logs.length}', aCharcoal), const SizedBox(width: 8),
        _summaryChip(loc.adminFilterToday, '${_logs.length}', aTeal), const SizedBox(width: 8),
        _summaryChip(loc.adminMenuUsers, '${_logs.where((l) => l.$3 == 'Users').length}', aTeal), const SizedBox(width: 8),
        _summaryChip(loc.adminMenuJobs, '${_logs.where((l) => l.$3 == 'Jobs').length}', aIndigo), const SizedBox(width: 8),
        _summaryChip(loc.adminMenuReports, '${_logs.where((l) => l.$3 == 'Reports').length}', aUrgent), const SizedBox(width: 8),
        _summaryChip(loc.adminFilterBilling, '${_logs.where((l) => l.$3 == 'Billing').length}', aGreen),
      ]))),
      Padding(padding: const EdgeInsets.only(top: 8), child: aChips(labels: chipLabels, selected: _filterIdx, onTap: (i) => setState(() => _filterIdx = i))),
      _sortRow(loc.adminCountLogs(filtered.length), loc),
      Expanded(child: filtered.isEmpty ? aEmpty(Icons.history, loc.adminEmptyLogsTitle, loc.adminEmptyAdjustFilters) : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Container(
          decoration: BoxDecoration(color: aCard, borderRadius: BorderRadius.circular(20), boxShadow: [aSubtleShadow]),
          child: Column(children: filtered.asMap().entries.map((e) {
            final l = e.value;
            final catColor = l.$3 == 'Users' ? aTeal : l.$3 == 'Jobs' ? aIndigo : l.$3 == 'Businesses' ? aAmber : l.$3 == 'Reports' ? aUrgent : l.$3 == 'Billing' ? aGreen : aSecondary;
            final catIcon = l.$3 == 'Users' ? Icons.person : l.$3 == 'Jobs' ? Icons.work : l.$3 == 'Businesses' ? Icons.business : l.$3 == 'Reports' ? Icons.flag : l.$3 == 'Billing' ? Icons.credit_card : Icons.settings;
            return Column(children: [
              if (e.key > 0) Padding(padding: const EdgeInsets.only(left: 68), child: const Divider(height: 1, color: aDivider)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 36, height: 36, decoration: BoxDecoration(color: catColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)), child: Icon(catIcon, size: 16, color: catColor)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.$1, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: aCharcoal)),
                  const SizedBox(height: 4),
                  Text(l.$2, style: const TextStyle(fontSize: 13, color: aSecondary)),
                  if (l.$7 != null && l.$8 != null) ...[const SizedBox(height: 4), Row(children: [Text(l.$7!, style: const TextStyle(fontSize: 10, color: aUrgent, decoration: TextDecoration.lineThrough)), const SizedBox(width: 4), const Icon(Icons.arrow_forward, size: 10, color: aTertiary), const SizedBox(width: 4), Text(l.$8!, style: const TextStyle(fontSize: 10, color: aGreen))])],
                  const SizedBox(height: 4),
                  Row(children: [Text(l.$4, style: const TextStyle(fontSize: 10, color: aTeal)), const Text(' · ', style: TextStyle(fontSize: 10, color: aTertiary)), Text(l.$5, style: const TextStyle(fontSize: 10, color: aTertiary)), const Text(' · ', style: TextStyle(fontSize: 10, color: aTertiary)), Text(aStatusLabel(loc, l.$6), style: TextStyle(fontSize: 10, color: l.$6 == 'Success' ? aGreen : aUrgent))]),
                ])),
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
