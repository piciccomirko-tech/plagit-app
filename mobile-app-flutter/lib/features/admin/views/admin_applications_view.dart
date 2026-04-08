import 'package:flutter/material.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';

class AdminApplicationsView extends StatefulWidget {
  const AdminApplicationsView({super.key});
  @override State<AdminApplicationsView> createState() => _S();
}

class _S extends State<AdminApplicationsView> {
  String _filter = 'All';
  final _filters = ['All', 'Applied', 'Under Review', 'Shortlisted', 'Interview', 'Offer', 'Rejected', 'Flagged'];
  final _apps = [
    ('Elena Rossi', 'ER', 0.52, 'Executive Chef', 'Senior Chef', 'Nobu Restaurant', 'Dubai, UAE', 'Shortlisted', true, true, 'Mar 15', '2 days ago', false, false, 0, 0),
    ('Marco Bianchi', 'MB', 0.35, 'Sommelier', 'Head Sommelier', 'The Ritz London', 'London, UK', 'Interview', true, true, 'Mar 12', '1 day ago', true, false, 0, 0),
    ('Sofia Andersen', 'SA', 0.72, 'Front Desk', 'Concierge', 'Burj Al Arab', 'Dubai, UAE', 'Applied', false, true, 'Mar 20', '3 hours ago', false, false, 0, 0),
    ('Ahmed Al-Rashid', 'AA', 0.15, 'Barista', 'Bartender', 'Sketch London', 'London, UK', 'Under Review', false, false, 'Mar 18', '5 days ago', false, false, 0, 8),
    ('Liam O\'Brien', 'LO', 0.88, 'Chef de Partie', 'Pastry Chef', 'Zuma Dubai', 'Dubai, UAE', 'Offer', true, true, 'Mar 10', '1 day ago', false, true, 0, 0),
    ('Maria Garcia', 'MG', 0.6, 'Hostess', 'Room Attendant', 'The Ritz London', 'London, UK', 'Flagged', false, true, 'Mar 8', '10 days ago', false, false, 1, 0),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'All' ? _apps : _apps.where((a) => a.$8 == _filter).toList();
    return Scaffold(backgroundColor: AppColors.background, body: SafeArea(child: Column(children: [
      AdminTopBar(title: 'Applications', onBack: () => Navigator.pop(context)),
      Padding(padding: const EdgeInsets.only(top: AppSpacing.xs), child: SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl), child: Row(children: [
        AdminSummaryChip(label: 'All', count: '${_apps.length}', color: AppColors.charcoal), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Applied', count: '${_apps.where((a) => a.$8 == 'Applied').length}', color: AppColors.teal), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Review', count: '${_apps.where((a) => a.$8 == 'Under Review').length}', color: AppColors.amber), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Shortlist', count: '${_apps.where((a) => a.$8 == 'Shortlisted').length}', color: AppColors.indigo), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Interview', count: '${_apps.where((a) => a.$8 == 'Interview').length}', color: AppColors.online), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Flagged', count: '${_apps.where((a) => a.$8 == 'Flagged').length}', color: AppColors.urgent),
      ]))),
      Padding(padding: const EdgeInsets.only(top: AppSpacing.sm), child: AdminFilterChips(filters: _filters, selected: _filter, onSelected: (f) => setState(() => _filter = f))),
      Padding(padding: const EdgeInsets.only(top: AppSpacing.sm), child: AdminSortRow(count: filtered.length, entityName: 'applications', sortLabel: 'Newest', onSort: () {})),
      Expanded(child: filtered.isEmpty ? AdminEmptyState(icon: Icons.description, title: 'No applications match', subtitle: 'Try adjusting filters.') : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xxxl),
        child: Container(
          decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(AppRadius.xl), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
          child: Column(children: filtered.asMap().entries.map((e) {
            final a = e.value;
            final sc = a.$8 == 'Applied' ? AppColors.teal : a.$8 == 'Under Review' ? AppColors.amber : a.$8 == 'Shortlisted' ? AppColors.indigo : a.$8 == 'Interview' ? AppColors.online : a.$8 == 'Offer' ? AppColors.teal : a.$8 == 'Flagged' ? AppColors.urgent : AppColors.tertiary;
            return Column(children: [
              if (e.key > 0) Padding(padding: EdgeInsets.only(left: AppSpacing.xl + 44 + AppSpacing.md), child: const Divider(height: 1, color: AppColors.divider)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                AvatarCircle(initials: a.$2, hue: a.$3, verified: a.$9),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Flexible(child: Text(a.$1, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal), maxLines: 1, overflow: TextOverflow.ellipsis)), const SizedBox(width: AppSpacing.xs), StatusPill(text: a.$8, color: sc)]),
                  const SizedBox(height: AppSpacing.xs),
                  Row(children: [Text(a.$4, style: const TextStyle(fontSize: 13, color: AppColors.secondary)), const SizedBox(width: 4), const Icon(Icons.arrow_forward, size: 10, color: AppColors.tertiary), const SizedBox(width: 4), Expanded(child: Text(a.$5, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.charcoal), maxLines: 1, overflow: TextOverflow.ellipsis))]),
                  const SizedBox(height: AppSpacing.xs),
                  Row(children: [Text(a.$6, style: const TextStyle(fontSize: 13, color: AppColors.secondary)), if (a.$10) ...[const SizedBox(width: 3), const Icon(Icons.verified, size: 10, color: AppColors.teal)], const Text(' · ', style: TextStyle(fontSize: 10, color: AppColors.tertiary)), Text(a.$7, style: const TextStyle(fontSize: 10, color: AppColors.tertiary))]),
                  const SizedBox(height: AppSpacing.xs),
                  Row(children: [
                    if (a.$13) ...[_indicator(Icons.calendar_today, 'Interview', AppColors.online), const SizedBox(width: AppSpacing.sm)],
                    if (a.$14) ...[_indicator(Icons.card_giftcard, 'Offer', AppColors.teal), const SizedBox(width: AppSpacing.sm)],
                    if (a.$16 >= 7) ...[_indicator(Icons.access_alarm, 'Stale ${a.$16}d', AppColors.amber), const SizedBox(width: AppSpacing.sm)],
                    if (a.$15 > 0) ...[Icon(Icons.flag, size: 10, color: AppColors.urgent), Text('${a.$15}', style: const TextStyle(fontSize: 10, color: AppColors.urgent))],
                  ]),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Applied ${a.$11} · ${a.$12}', style: const TextStyle(fontSize: 10, color: AppColors.tertiary)),
                ])),
                const Icon(Icons.more_horiz, size: 18, color: AppColors.tertiary),
              ])),
            ]);
          }).toList()),
        ),
      )),
    ])));
  }

  Widget _indicator(IconData i, String t, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.full), border: Border.all(color: c.withValues(alpha: 0.3), width: 0.5)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(i, size: 10, color: c), const SizedBox(width: 2), Text(t, style: TextStyle(fontSize: 10, color: c))]),
  );
}
