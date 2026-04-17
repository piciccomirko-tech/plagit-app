import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/providers/admin_providers.dart';

class AdminBusinessesView extends StatefulWidget {
  const AdminBusinessesView({super.key});
  @override
  State<AdminBusinessesView> createState() => _AdminBusinessesViewState();
}

class _AdminBusinessesViewState extends State<AdminBusinessesView> {
  int _chip = 0;
  static const _filters = ['All', 'Active', 'Suspended', 'Pending'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminBusinessesListProvider>().load();
    });
  }

  Color _statusColor(String s) => switch (s) { 'active' => aGreen, 'suspended' => aUrgent, 'pending' => aAmber, _ => aTertiary };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final labels = [l.adminFilterAll, l.adminStatusActive, l.adminStatusSuspended, l.adminStatusPending];
    final provider = context.watch<AdminBusinessesListProvider>();

    if (provider.loading) {
      return Scaffold(backgroundColor: aBg, body: SafeArea(child: Column(children: [
        aTopBar(context, l.adminMenuBusinesses),
        const Expanded(child: Center(child: CircularProgressIndicator(color: aTeal))),
      ])));
    }

    if (provider.error != null) {
      return Scaffold(backgroundColor: aBg, body: SafeArea(child: Column(children: [
        aTopBar(context, l.adminMenuBusinesses),
        Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(provider.error!, style: const TextStyle(fontSize: 14, color: aSecondary), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          GestureDetector(onTap: () => provider.load(), child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(color: aTeal, borderRadius: BorderRadius.circular(100)),
            child: Text(l.adminActionRetry, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          )),
        ]))),
      ])));
    }

    final allItems = provider.items;
    var items = allItems.toList();
    if (_chip > 0) { items = items.where((b) => b['status'] == _filters[_chip].toLowerCase()).toList(); }

    return Scaffold(backgroundColor: aBg, body: SafeArea(child: Column(children: [
      aTopBar(context, l.adminMenuBusinesses, trailing: aPill('${allItems.length}', aIndigo)),
      Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 8), child: Row(children: [
        Text('${allItems.length} ${l.adminStatTotal.toLowerCase()}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: aCharcoal)),
        const SizedBox(width: 12), Text(l.adminBadgeNActive(allItems.where((b) => b['status'] == 'active').length), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: aGreen)),
        const SizedBox(width: 12), Text(l.adminBadgeNPending(allItems.where((b) => b['status'] == 'pending').length), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: aAmber)),
      ])),
      aChips(labels: labels, selected: _chip, onTap: (i) => setState(() => _chip = i)),
      if (items.isEmpty) Expanded(child: aEmpty(Icons.business, l.adminEmptyBusinessesTitle, l.adminEmptyBusinessesSub))
      else Expanded(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 48), child: Container(decoration: BoxDecoration(color: aCard, borderRadius: BorderRadius.circular(20), boxShadow: [aCardShadow]),
        child: Column(children: List.generate(items.length, (i) {
          final b = items[i];
          return Column(children: [
            GestureDetector(onTap: () => context.push('/admin/businesses/${b['name']}'), behavior: HitTestBehavior.opaque,
              child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), child: Row(children: [
                aAvatar(b['initials'] as String, 40),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(b['name'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: aCharcoal)),
                  Text('${b['type']} · ${b['location']}', style: const TextStyle(fontSize: 13, color: aSecondary)),
                  Text(b['email'] as String, style: const TextStyle(fontSize: 11, color: aTertiary)),
                ])),
                aPill(aStatusLabel(l, b['status'] as String), _statusColor(b['status'] as String)),
              ]))),
            if (i < items.length - 1) Padding(padding: const EdgeInsets.only(left: 72), child: Container(height: 1, color: aDivider)),
          ]);
        }))))),
    ])));
  }
}
