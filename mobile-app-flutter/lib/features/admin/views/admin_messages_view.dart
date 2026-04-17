import 'package:flutter/material.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';

class AdminMessagesView extends StatefulWidget {
  const AdminMessagesView({super.key});
  @override
  State<AdminMessagesView> createState() => _AdminMessagesViewState();
}

class _AdminMessagesViewState extends State<AdminMessagesView> {
  int _chip = 0;
  static const _mock = [
    {'candidate': 'Marco Rossi', 'cinitials': 'MR', 'business': 'The Ritz', 'binitials': 'TR', 'lastMsg': 'Thank you for the opportunity!', 'unread': 2},
    {'candidate': 'Sarah Chen', 'cinitials': 'SC', 'business': 'Nobu', 'binitials': 'NR', 'lastMsg': 'I am available for the interview.', 'unread': 0},
    {'candidate': 'James Wilson', 'cinitials': 'JW', 'business': 'Cipriani', 'binitials': 'CI', 'lastMsg': 'Could you share more details?', 'unread': 1},
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final labels = [l.adminFilterAll, l.adminFilterUnread];
    var items = _mock.toList();
    if (_chip == 1) { items = items.where((m) => (m['unread'] as int) > 0).toList(); }

    return Scaffold(backgroundColor: aBg, body: SafeArea(child: Column(children: [
      aTopBar(context, l.adminMenuMessages),
      aChips(labels: labels, selected: _chip, onTap: (i) => setState(() => _chip = i)),
      if (items.isEmpty) Expanded(child: aEmpty(Icons.chat_bubble_outline, l.adminEmptyMessagesTitle, l.adminEmptyMessagesSub))
      else Expanded(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 48), child: Container(decoration: BoxDecoration(color: aCard, borderRadius: BorderRadius.circular(20), boxShadow: [aCardShadow]),
        child: Column(children: List.generate(items.length, (i) {
          final m = items[i]; final unread = (m['unread'] as int) > 0;
          return Column(children: [
            Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), child: Row(children: [
              aAvatar(m['cinitials'] as String, 40),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Text(m['candidate'] as String, style: TextStyle(fontSize: 15, fontWeight: unread ? FontWeight.w500 : FontWeight.w400, color: aCharcoal)), const Text(' ↔ ', style: TextStyle(fontSize: 11, color: aTertiary)), Text(m['business'] as String, style: const TextStyle(fontSize: 13, color: aSecondary)), const Spacer(), if (unread) Container(width: 8, height: 8, decoration: const BoxDecoration(color: aTeal, shape: BoxShape.circle))]),
                const SizedBox(height: 2), Text(m['lastMsg'] as String, style: TextStyle(fontSize: 13, fontWeight: unread ? FontWeight.w500 : FontWeight.w400, color: unread ? aCharcoal : aSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
              ])),
            ])),
            if (i < items.length - 1) Padding(padding: const EdgeInsets.only(left: 72), child: Container(height: 1, color: aDivider)),
          ]);
        }))))),
    ])));
  }
}
