import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/models/employment.dart';
import 'package:plagit/models/job.dart';
import 'package:plagit/providers/admin_providers.dart';

class AdminJobsView extends StatefulWidget {
  const AdminJobsView({super.key});
  @override
  State<AdminJobsView> createState() => _AdminJobsViewState();
}

class _AdminJobsViewState extends State<AdminJobsView> {
  int _chip = 0;
  static const _filters = ['All', 'Active', 'Paused', 'Flagged'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminJobsListProvider>().load();
    });
  }

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'active': return aGreen;
      case 'paused': return aAmber;
      case 'closed': return aTertiary;
      case 'draft': return aIndigo;
      case 'flagged': return aUrgent;
      default: return aTertiary;
    }
  }

  Compensation _compFor(Map<String, dynamic> j) {
    final empType = EmploymentType.fromString(j['contract'] as String? ?? 'Full-time');
    final rawComp = j['compensation'];
    if (rawComp is Map) {
      return Compensation.fromJson(Map<String, dynamic>.from(rawComp), empType);
    }
    return Compensation.fromLegacy(j['salary'] as String? ?? '', empType);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final labels = [l.adminFilterAll, l.adminStatusActive, l.adminStatusPaused, l.adminStatusFlagged];
    final provider = context.watch<AdminJobsListProvider>();

    if (provider.loading) {
      return Scaffold(backgroundColor: aBg, body: SafeArea(child: Column(children: [
        aTopBar(context, l.adminMenuJobs),
        const Expanded(child: Center(child: CircularProgressIndicator(color: aTeal))),
      ])));
    }

    if (provider.error != null) {
      return Scaffold(backgroundColor: aBg, body: SafeArea(child: Column(children: [
        aTopBar(context, l.adminMenuJobs),
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

    final allJobs = provider.items;
    var items = allJobs.toList();
    if (_chip > 0) {
      final target = _filters[_chip].toLowerCase();
      items = allJobs.where((j) => (j['status'] as String).toLowerCase() == target).toList();
    }

    return Scaffold(backgroundColor: aBg, body: SafeArea(child: Column(children: [
      aTopBar(context, l.adminMenuJobs, trailing: aPill('${allJobs.length}', aAmber)),
      Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 8), child: Row(children: [
        Text('${allJobs.length} ${l.adminStatTotal.toLowerCase()}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: aCharcoal)),
        const SizedBox(width: 12),
        Text(l.adminBadgeNActive(allJobs.where((j) => (j['status'] as String).toLowerCase() == 'active').length), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: aGreen)),
      ])),
      aChips(labels: labels, selected: _chip, onTap: (i) => setState(() => _chip = i)),
      if (items.isEmpty) Expanded(child: aEmpty(Icons.work, l.adminEmptyJobsTitle, l.adminEmptyJobsSub))
      else Expanded(child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
        itemCount: items.length,
        separatorBuilder: (_, i) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final j = items[i];
          final empType = EmploymentType.fromString(j['contract'] as String? ?? 'Full-time');
          final comp = _compFor(j);
          final status = j['status'] as String;
          return GestureDetector(
            onTap: () => context.push('/admin/jobs/${j['id']}'),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: aCard, borderRadius: BorderRadius.circular(20), boxShadow: [aCardShadow]),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Flexible(child: Text(j['title'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: aCharcoal), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8),
                    aPill(aStatusLabel(l, status), _statusColor(status)),
                  ]),
                  const SizedBox(height: 4),
                  Text('${j['business']} · ${j['location']}', style: const TextStyle(fontSize: 13, color: aSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  // Compensation on its own line — never truncates.
                  Text(
                    comp.display,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: aCharcoal, letterSpacing: -0.1, height: 1.2),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: aTealLight, borderRadius: BorderRadius.circular(100)),
                        child: Text(empType.label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: aTeal)),
                      ),
                      if (j['urgent'] == true) aPill(l.adminBadgeUrgent, aUrgent),
                      if (j['featured'] == true) aPill(l.adminActionFeatured, aAmber),
                    ],
                  ),
                ])),
                const SizedBox(width: 12),
                Column(children: [
                  const Icon(Icons.people_outline, size: 14, color: aTeal),
                  const SizedBox(height: 2),
                  Text('${j['applicants']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: aTeal)),
                ]),
              ]),
            ),
          );
        },
      )),
    ])));
  }
}
