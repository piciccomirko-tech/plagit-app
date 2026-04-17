import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/providers/admin_providers.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

class AdminInterviewsView extends StatefulWidget {
  const AdminInterviewsView({super.key});
  @override
  State<AdminInterviewsView> createState() => _AdminInterviewsViewState();
}

class _AdminInterviewsViewState extends State<AdminInterviewsView> {
  int _chip = 0;
  static const _filters = ['All', 'Pending', 'Confirmed', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminInterviewsListProvider>().load();
    });
  }

  Color _statusColor(String s) => switch (s) { 'confirmed' => aTeal, 'completed' => aGreen, 'cancelled' => aUrgent, _ => aAmber };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final labels = [l.adminFilterAll, l.adminStatusPending, l.adminStatusConfirmed, l.adminStatusCompleted, l.adminStatusCancelled];
    final provider = context.watch<AdminInterviewsListProvider>();

    if (provider.loading) {
      return Scaffold(backgroundColor: aBg, body: SafeArea(child: Column(children: [
        aTopBar(context, l.adminMenuInterviews),
        const Expanded(child: Center(child: CircularProgressIndicator(color: aTeal))),
      ])));
    }

    if (provider.error != null) {
      return Scaffold(backgroundColor: aBg, body: SafeArea(child: Column(children: [
        aTopBar(context, l.adminMenuInterviews),
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
    if (_chip > 0) { items = items.where((iv) => iv['status'] == _filters[_chip].toLowerCase()).toList(); }

    return Scaffold(backgroundColor: aBg, body: SafeArea(child: Column(children: [
      aTopBar(context, l.adminMenuInterviews, trailing: aPill('${allItems.length}', aIndigo)),
      aChips(labels: labels, selected: _chip, onTap: (i) => setState(() => _chip = i)),
      if (items.isEmpty) Expanded(child: aEmpty(Icons.calendar_today, l.adminEmptyInterviewsTitle, l.adminEmptyInterviewsSub))
      else Expanded(child: ListView.separated(padding: const EdgeInsets.fromLTRB(20, 8, 20, 48), itemCount: items.length, separatorBuilder: (_, i) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final iv = items[i];
          final color = _statusColor(iv['status'] as String);
          return GestureDetector(onTap: () => context.push('/admin/interviews/${iv['candidate']}'),
            child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: aCard, borderRadius: BorderRadius.circular(20), boxShadow: [aCardShadow]),
              child: Row(children: [
                aAvatar(iv['initials'] as String, 44),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(iv['candidate'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: aCharcoal)),
                  Text(iv['job'] as String, style: const TextStyle(fontSize: 13, color: aSecondary)),
                  const SizedBox(height: 2), Text('${iv['date']} · ${iv['time']} · ${iv['type']}', style: const TextStyle(fontSize: 11, color: aTertiary)),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [aPill(aStatusLabel(l, iv['status'] as String), color), const SizedBox(height: 8), const ForwardChevron(size: 28, color: aTertiary)]),
              ])));
        },
      )),
    ])));
  }
}
