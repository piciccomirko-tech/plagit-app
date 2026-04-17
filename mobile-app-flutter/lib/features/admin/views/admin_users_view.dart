import 'package:flutter/material.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';

class AdminUsersView extends StatefulWidget {
  const AdminUsersView({super.key});
  @override State<AdminUsersView> createState() => _S();
}

class _S extends State<AdminUsersView> {
  int _filterIdx = 0;
  bool _showSearch = false;
  String _searchText = '';
  final _filters = ['All', 'Candidates', 'Businesses', 'Admins', 'Verified', 'Suspended', 'Banned'];
  final _users = [
    ('Elena Rossi', 'ER', 0.52, 'elena@email.com', 'Candidate', 'Executive Chef', 'London, UK', 'Active', true, 'Mar 2025', '2h ago'),
    ('Nobu Restaurant', 'NR', 0.55, 'admin@nobu.com', 'Business', 'Restaurant', 'Dubai, UAE', 'Active', true, 'Jan 2025', '30m ago'),
    ('Marco Bianchi', 'MB', 0.35, 'marco@email.com', 'Candidate', 'Sommelier', 'Milan, Italy', 'Active', true, 'Feb 2025', '1d ago'),
    ('Sketch London', 'SL', 0.42, 'info@sketch.com', 'Business', 'Restaurant', 'London, UK', 'Suspended', false, 'Feb 2025', '3d ago'),
    ('Super Admin', 'SA', 0.8, 'admin@plagit.com', 'Admin', 'Super Admin', '-', 'Active', true, 'Nov 2024', '5m ago'),
    ('Sofia Andersen', 'SA', 0.72, 'sofia@email.com', 'Candidate', 'Front Desk', 'Dubai, UAE', 'Active', false, 'Mar 2026', '3h ago'),
  ];

  List get _filtered {
    final filter = _filters[_filterIdx];
    var list = _users.toList();
    if (filter == 'Candidates') {
      list = list.where((u) => u.$5 == 'Candidate').toList();
    } else if (filter == 'Businesses') {
      list = list.where((u) => u.$5 == 'Business').toList();
    } else if (filter == 'Admins') {
      list = list.where((u) => u.$5 == 'Admin').toList();
    } else if (filter == 'Verified') {
      list = list.where((u) => u.$9).toList();
    } else if (filter == 'Suspended') {
      list = list.where((u) => u.$8 == 'Suspended').toList();
    }
    if (_searchText.isNotEmpty) {
      list = list.where((u) => u.$1.toLowerCase().contains(_searchText.toLowerCase()) || u.$4.toLowerCase().contains(_searchText.toLowerCase())).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final chipLabels = [
      l.adminFilterAll,
      l.adminFilterCandidates,
      l.adminFilterBusinesses,
      l.adminFilterAdmins,
      l.adminStatusVerified,
      l.adminStatusSuspended,
      l.adminStatusBanned,
    ];
    return Scaffold(backgroundColor: aBg, body: SafeArea(child: Column(children: [
      aTopBar(context, l.adminMenuUsers, trailing: GestureDetector(onTap: () => setState(() { _showSearch = !_showSearch; if (!_showSearch) _searchText = ''; }), child: Icon(_showSearch ? Icons.close : Icons.search, size: 22, color: aCharcoal))),
      if (_showSearch) _searchBar(l),
      Padding(padding: const EdgeInsets.only(top: 4), child: SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(children: [
        _summaryChip(l.adminFilterAll, '${_users.length}', aCharcoal, 72), const SizedBox(width: 8),
        _summaryChip(l.adminFilterCandidates, '${_users.where((u) => u.$5 == 'Candidate').length}', aTeal, 72), const SizedBox(width: 8),
        _summaryChip(l.adminFilterBusinesses, '${_users.where((u) => u.$5 == 'Business').length}', aIndigo, 72), const SizedBox(width: 8),
        _summaryChip(l.adminStatusVerified, '${_users.where((u) => u.$9).length}', aGreen, 72),
      ]))),
      Padding(padding: const EdgeInsets.only(top: 8), child: aChips(labels: chipLabels, selected: _filterIdx, onTap: (i) => setState(() => _filterIdx = i))),
      _sortRow(l.adminCountUsers(_filtered.length), l),
      Expanded(child: _filtered.isEmpty ? aEmpty(Icons.people, l.adminEmptyUsersTitle, l.adminEmptyAdjustFilters) : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Container(
          decoration: BoxDecoration(color: aCard, borderRadius: BorderRadius.circular(20), boxShadow: [aSubtleShadow]),
          child: Column(children: _filtered.asMap().entries.map((e) {
            final u = e.value;
            final typeColor = u.$5 == 'Candidate' ? aTeal : u.$5 == 'Business' ? aIndigo : aAmber;
            return Column(children: [
              if (e.key > 0) Padding(padding: const EdgeInsets.only(left: 76), child: const Divider(height: 1, color: aDivider)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                aAvatar(u.$2, 44, verified: u.$9),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Flexible(child: Text(u.$1, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: aCharcoal), maxLines: 1, overflow: TextOverflow.ellipsis)), const SizedBox(width: 4), Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2), decoration: BoxDecoration(color: typeColor, borderRadius: BorderRadius.circular(100)), child: Text(u.$5, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white))), if (u.$8 != 'Active') ...[const SizedBox(width: 4), aPill(aStatusLabel(l, u.$8), aUrgent)]]),
                  const SizedBox(height: 4),
                  Text(u.$4, style: const TextStyle(fontSize: 13, color: aSecondary)),
                  const SizedBox(height: 4),
                  Row(children: [Text(u.$6, style: const TextStyle(fontSize: 13, color: aCharcoal)), if (u.$7 != '-') ...[const Text(' · ', style: TextStyle(fontSize: 10, color: aTertiary)), Text(u.$7, style: const TextStyle(fontSize: 13, color: aTertiary))]]),
                  const SizedBox(height: 4),
                  Text('Joined ${u.$10} · Active ${u.$11}', style: const TextStyle(fontSize: 10, color: aTertiary)),
                ])),
                const Icon(Icons.more_horiz, size: 18, color: aTertiary),
              ])),
            ]);
          }).toList()),
        ),
      )),
    ])));
  }

  Widget _searchBar(AppLocalizations l) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: aSurface, borderRadius: BorderRadius.circular(12), border: Border.all(color: aBorder)),
      child: Row(children: [
        const Icon(Icons.search, size: 18, color: aTertiary),
        const SizedBox(width: 8),
        Expanded(child: TextField(
          onChanged: (v) => setState(() => _searchText = v),
          style: const TextStyle(fontSize: 14, color: aCharcoal),
          decoration: InputDecoration(hintText: l.adminSearchUsersHint, hintStyle: const TextStyle(fontSize: 14, color: aTertiary), border: InputBorder.none, isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 10)),
        )),
        if (_searchText.isNotEmpty) GestureDetector(onTap: () => setState(() => _searchText = ''), child: const Icon(Icons.close, size: 16, color: aTertiary)),
      ]),
    ),
  );

  Widget _summaryChip(String label, String count, Color color, double width) => Container(
    width: width, padding: const EdgeInsets.symmetric(vertical: 8),
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
