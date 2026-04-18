import 'package:flutter/material.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';

class AdminReportsView extends StatefulWidget {
  const AdminReportsView({super.key});
  @override
  State<AdminReportsView> createState() => _AdminReportsViewState();
}

class _AdminReportsViewState extends State<AdminReportsView> {
  int _chip = 0;
  static const _filters = ['All', 'Pending', 'Resolved'];
  static const _mock = [
    {'reporter': 'Marco Rossi', 'reported': 'Fake Business Ltd', 'reason': 'Fraudulent job posting', 'status': 'pending', 'initials': 'MR'},
    {'reporter': 'Sarah Chen', 'reported': 'John Doe', 'reason': 'Inappropriate messages', 'status': 'pending', 'initials': 'SC'},
    {'reporter': 'The Ritz', 'reported': 'Spam Account', 'reason': 'Spam applications', 'status': 'resolved', 'initials': 'TR'},
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final labels = [l.adminFilterAll, l.adminStatusPending, l.adminStatusResolved];
    var items = _mock.toList();
    if (_chip > 0) { items = items.where((r) => r['status'] == _filters[_chip].toLowerCase()).toList(); }

    return Scaffold(backgroundColor: aBg, body: SafeArea(child: Column(children: [
      aTopBar(context, l.adminMenuReports),
      aChips(labels: labels, selected: _chip, onTap: (i) => setState(() => _chip = i)),
      if (items.isEmpty) Expanded(child: aEmpty(Icons.flag, l.adminEmptyReportsTitle, l.adminEmptyReportsSub))
      else Expanded(child: ListView.separated(padding: const EdgeInsets.fromLTRB(20, 8, 20, 48), itemCount: items.length, separatorBuilder: (_, i) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final r = items[i]; final isPending = r['status'] == 'pending';
          return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: aCard, borderRadius: BorderRadius.circular(20), boxShadow: [aCardShadow]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                aAvatar(r['initials'] as String, 36),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Text(r['reporter'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: aCharcoal)), const Text(' → ', style: TextStyle(fontSize: 11, color: aTertiary)), Flexible(child: Text(r['reported'] as String, style: const TextStyle(fontSize: 13, color: aSecondary), maxLines: 1, overflow: TextOverflow.ellipsis))]),
                  const SizedBox(height: 2), Text(r['reason'] as String, style: const TextStyle(fontSize: 13, color: aTertiary)),
                ])),
                aPill(aStatusLabel(l, r['status'] as String), isPending ? aAmber : aGreen),
              ]),
              if (isPending) ...[const SizedBox(height: 12), Row(children: [
                _actionBtn(l.adminActionResolve, aTeal), const SizedBox(width: 8),
                _actionBtn(l.adminActionDismiss, aTertiary), const SizedBox(width: 8),
                _actionBtn(l.adminActionBanUser, aUrgent),
              ])],
            ]));
        },
      )),
    ])));
  }

  Widget _actionBtn(String label, Color color) => GestureDetector(onTap: () {}, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(100)), child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color))));
}
