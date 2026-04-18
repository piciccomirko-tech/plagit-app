import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/widgets/search_screen.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/providers/admin_providers.dart';
import 'package:plagit/providers/recent_searches_provider.dart';

class AdminCandidatesView extends StatefulWidget {
  const AdminCandidatesView({super.key});
  @override
  State<AdminCandidatesView> createState() => _AdminCandidatesViewState();
}

class _AdminCandidatesViewState extends State<AdminCandidatesView> {
  int _chip = 0;
  static const _filters = ['All', 'Active', 'Suspended', 'Pending'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminCandidatesListProvider>().load();
    });
  }

  void _openSearchScreen(BuildContext context) {
    final l = AppLocalizations.of(context);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SearchScreen(
          scope: RecentSearchScope.adminCandidates,
          title: l.adminSearchCandidatesTitle,
          hintText: l.adminSearchCandidatesHint,
          resultsBuilder: (ctx, query) {
            final q = query.toLowerCase();
            final allItems = context.read<AdminCandidatesListProvider>().items;
            final results = allItems
                .where((c) =>
                    (c['name'] as String).toLowerCase().contains(q) ||
                    (c['email'] as String).toLowerCase().contains(q))
                .toList();
            if (results.isEmpty) return SearchNoResults(query: query);
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              itemCount: results.length,
              separatorBuilder: (_, _) => Padding(
                padding: const EdgeInsets.only(left: 72),
                child: Container(height: 1, color: aDivider),
              ),
              itemBuilder: (_, i) {
                final c = results[i];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(ctx).pop();
                    ctx.push('/admin/candidates/${c['name']}');
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    color: aCard,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    child: Row(
                      children: [
                        aAvatar(
                          c['initials'] as String,
                          40,
                          verified: c['verified'] == true,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c['name'] as String,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: aCharcoal)),
                              Text(c['role'] as String,
                                  style: const TextStyle(
                                      fontSize: 13, color: aSecondary)),
                              Text(c['email'] as String,
                                  style: const TextStyle(
                                      fontSize: 11, color: aTertiary)),
                            ],
                          ),
                        ),
                        aPill(aStatusLabel(l, c['status'] as String),
                            _statusColor(c['status'] as String)),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Color _statusColor(String s) => switch (s) { 'active' => aGreen, 'suspended' => aUrgent, 'pending' => aAmber, _ => aTertiary };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = context.watch<AdminCandidatesListProvider>();

    if (provider.loading) {
      return Scaffold(backgroundColor: aBg, body: SafeArea(child: Column(children: [
        aTopBar(context, l.adminMenuCandidates),
        const Expanded(child: Center(child: CircularProgressIndicator(color: aTeal))),
      ])));
    }

    if (provider.error != null) {
      return Scaffold(backgroundColor: aBg, body: SafeArea(child: Column(children: [
        aTopBar(context, l.adminMenuCandidates),
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
    if (_chip > 0) { items = items.where((c) => (c['status'] as String).toLowerCase() == _filters[_chip].toLowerCase()).toList(); }

    final chipLabels = [
      l.adminFilterAll,
      l.adminStatusActive,
      l.adminStatusSuspended,
      l.adminStatusPending,
    ];

    return Scaffold(backgroundColor: aBg, body: SafeArea(child: Column(children: [
      aTopBar(context, l.adminMenuCandidates, trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        GestureDetector(onTap: () => _openSearchScreen(context), child: const Icon(Icons.search, size: 20, color: aCharcoal)),
        const SizedBox(width: 8),
        aPill('${allItems.length}', aTeal),
      ])),
      aChips(labels: chipLabels, selected: _chip, onTap: (i) => setState(() => _chip = i)),
      if (items.isEmpty) Expanded(child: aEmpty(Icons.people, l.adminEmptyCandidatesTitle, l.adminEmptyAdjustFilters))
      else Expanded(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 48), child: Container(decoration: BoxDecoration(color: aCard, borderRadius: BorderRadius.circular(20), boxShadow: [aCardShadow]),
        child: Column(children: List.generate(items.length, (i) {
          final c = items[i];
          return Column(children: [
            GestureDetector(onTap: () => context.push('/admin/candidates/${c['name']}'), onLongPress: () => _showMenu(c, l),
              behavior: HitTestBehavior.opaque,
              child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), child: Row(children: [
                aAvatar(
                  c['initials'] as String,
                  40,
                  verified: c['verified'] == true || c['verified'] == 'Verified',
                  photoUrl: c['photoUrl'] as String?,
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(c['name'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: aCharcoal)),
                  Text(c['role'] as String, style: const TextStyle(fontSize: 13, color: aSecondary)),
                  Text(c['email'] as String, style: const TextStyle(fontSize: 11, color: aTertiary)),
                ])),
                aPill(aStatusLabel(l, c['status'] as String), _statusColor(c['status'] as String)),
                const SizedBox(width: 8),
                GestureDetector(onTap: () => _showMenu(c, l), child: const Icon(Icons.more_vert, size: 16, color: aTertiary)),
              ]))),
            if (i < items.length - 1) Padding(padding: const EdgeInsets.only(left: 72), child: Container(height: 1, color: aDivider)),
          ]);
        }))))),
    ])));
  }

  void _showMenu(Map<String, dynamic> c, AppLocalizations l) {
    showModalBottomSheet(context: context, backgroundColor: aCard, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [
        _menuItem(l.adminActionViewProfile, Icons.person, aTeal, () { Navigator.pop(ctx); context.push('/admin/candidates/${c['name']}'); }),
        _menuItem(l.adminActionVerify, Icons.verified, aGreen, () => Navigator.pop(ctx)),
        _menuItem(l.adminActionSuspend, Icons.block, aAmber, () => Navigator.pop(ctx)),
        _menuItem(l.adminActionDelete, Icons.delete, aUrgent, () => Navigator.pop(ctx)),
      ]))));
  }

  Widget _menuItem(String label, IconData icon, Color color, VoidCallback onTap) => GestureDetector(onTap: onTap, child: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Row(children: [Icon(icon, size: 18, color: color), const SizedBox(width: 14), Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color))])));
}
