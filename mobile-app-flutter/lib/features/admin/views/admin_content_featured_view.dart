import 'package:flutter/material.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';

class AdminContentFeaturedView extends StatefulWidget {
  const AdminContentFeaturedView({super.key});
  @override State<AdminContentFeaturedView> createState() => _S();
}

class _S extends State<AdminContentFeaturedView> {
  int _filterIdx = 0;
  final _filters = ['All', 'Featured Employer', 'Featured Job', 'Home Banner', 'Active', 'Scheduled', 'Pinned', 'Expired'];
  final _items = [
    ('Nobu Restaurant Spotlight', 'Featured Employer', 'Active', 'Home Banner', 'Nobu Restaurant', true, 450, 120, 1, 'Mar 15'),
    ('Senior Chef at Nobu', 'Featured Job', 'Active', 'Job Feed Top', 'Senior Chef', false, 320, 85, 2, 'Mar 12'),
    ('Spring Hiring Season Banner', 'Home Banner', 'Active', 'Home Hero', '', true, 800, 200, 1, 'Mar 1'),
    ('Luxury Hotels Hiring', 'Featured Employer', 'Scheduled', 'Home Banner', 'The Ritz London', false, 0, 0, 3, 'Mar 20'),
    ('Bartender of the Month', 'Featured Job', 'Expired', 'Job Feed', 'Bartender Role', false, 150, 30, 5, 'Feb 28'),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final chipLabels = [
      l.adminFilterAll,
      l.adminFilterFeaturedEmployer,
      l.adminFilterFeaturedJob,
      l.adminFilterHomeBanner,
      l.adminStatusActive,
      l.adminStatusScheduled,
      l.adminFilterPinned,
      l.adminStatusExpired,
    ];
    final filter = _filters[_filterIdx];
    final filtered = filter == 'All' ? _items : filter == 'Pinned' ? _items.where((i) => i.$6).toList() : _items.where((i) => i.$2 == filter || i.$3 == filter).toList();
    return Scaffold(backgroundColor: aBg, body: SafeArea(child: Column(children: [
      aTopBar(context, l.adminTitleContentFeatured, trailing: const Icon(Icons.add_circle, size: 24, color: aTeal)),
      Padding(padding: const EdgeInsets.only(top: 4), child: SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(children: [
        _summaryChip(l.adminFilterAll, '${_items.length}', aCharcoal), const SizedBox(width: 8),
        _summaryChip(l.adminFilterEmployers, '${_items.where((i) => i.$2 == 'Featured Employer').length}', aTeal), const SizedBox(width: 8),
        _summaryChip(l.adminMenuJobs, '${_items.where((i) => i.$2 == 'Featured Job').length}', aIndigo), const SizedBox(width: 8),
        _summaryChip(l.adminFilterBanners, '${_items.where((i) => i.$2 == 'Home Banner').length}', aAmber), const SizedBox(width: 8),
        _summaryChip(l.adminStatusActive, '${_items.where((i) => i.$3 == 'Active').length}', aGreen),
      ]))),
      Padding(padding: const EdgeInsets.only(top: 8), child: aChips(labels: chipLabels, selected: _filterIdx, onTap: (i) => setState(() => _filterIdx = i))),
      _sortRow(l.adminCountItems(filtered.length), l.adminSortPriority, l),
      Expanded(child: filtered.isEmpty ? aEmpty(Icons.star, l.adminEmptyContentTitle, l.adminEmptyAdjustFilters) : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Container(
          decoration: BoxDecoration(color: aCard, borderRadius: BorderRadius.circular(20), boxShadow: [aSubtleShadow]),
          child: Column(children: filtered.asMap().entries.map((e) {
            final it = e.value;
            final typeColor = it.$2 == 'Featured Employer' ? aTeal : it.$2 == 'Featured Job' ? aIndigo : aAmber;
            final typeIcon = it.$2 == 'Featured Employer' ? Icons.business : it.$2 == 'Featured Job' ? Icons.work : Icons.view_carousel;
            final statusColor = it.$3 == 'Active' ? aGreen : it.$3 == 'Scheduled' ? aIndigo : aTertiary;
            return Column(children: [
              if (e.key > 0) Padding(padding: const EdgeInsets.only(left: 68), child: const Divider(height: 1, color: aDivider)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 36, height: 36, decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)), child: Icon(typeIcon, size: 16, color: typeColor)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Flexible(child: Text(it.$1, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: aCharcoal), maxLines: 1, overflow: TextOverflow.ellipsis)), const SizedBox(width: 4), aPill(aStatusLabel(l, it.$3), statusColor), if (it.$6) ...[const SizedBox(width: 4), aPill(l.adminFilterPinned, aAmber)]]),
                  const SizedBox(height: 4),
                  Row(children: [aPill(_typeLabel(l, it.$2), typeColor), const SizedBox(width: 8), Text(it.$4, style: const TextStyle(fontSize: 10, color: aTertiary))]),
                  if (it.$5.isNotEmpty) ...[const SizedBox(height: 4), Row(children: [const Icon(Icons.link, size: 10, color: aTertiary), const SizedBox(width: 2), Text(it.$5, style: const TextStyle(fontSize: 10, color: aSecondary))])],
                  const SizedBox(height: 4),
                  Row(children: [if (it.$7 > 0) ...[const Icon(Icons.visibility, size: 10, color: aTertiary), const SizedBox(width: 2), Text('${it.$7}', style: const TextStyle(fontSize: 10, color: aSecondary)), const SizedBox(width: 12)], if (it.$8 > 0) ...[const Icon(Icons.touch_app, size: 10, color: aTertiary), const SizedBox(width: 2), Text('${it.$8}', style: const TextStyle(fontSize: 10, color: aSecondary)), const SizedBox(width: 12)], Text('#${it.$9}', style: const TextStyle(fontSize: 10, color: aTeal)), const SizedBox(width: 12), Text(it.$10, style: const TextStyle(fontSize: 10, color: aTertiary))]),
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
    width: 66, padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(count, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(fontSize: 10, color: aSecondary)),
    ]),
  );

  Widget _sortRow(String countLabel, String sortLabel, AppLocalizations l) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    child: Row(children: [
      Text(countLabel, style: const TextStyle(fontSize: 13, color: aSecondary)),
      const Spacer(),
      GestureDetector(onTap: () {}, child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(sortLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: aTeal)),
        const SizedBox(width: 4),
        const Icon(Icons.swap_vert, size: 14, color: aTeal),
      ])),
    ]),
  );

  String _typeLabel(AppLocalizations l, String type) {
    switch (type) {
      case 'Featured Employer': return l.adminFilterFeaturedEmployer;
      case 'Featured Job': return l.adminFilterFeaturedJob;
      case 'Home Banner': return l.adminFilterHomeBanner;
      default: return type;
    }
  }
}
