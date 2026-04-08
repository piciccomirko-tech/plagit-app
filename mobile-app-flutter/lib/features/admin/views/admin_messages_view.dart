import 'package:flutter/material.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';

class AdminMessagesView extends StatefulWidget {
  const AdminMessagesView({super.key});
  @override State<AdminMessagesView> createState() => _S();
}

class _S extends State<AdminMessagesView> {
  String _filter = 'All';
  final _filters = ['All', 'Flagged', 'Under Review', 'Interview Related', 'Support Issues', 'Restricted', 'No Reply'];
  final _convos = [
    ('Elena Rossi', 'ER', 0.52, 'Nobu Restaurant', 'Senior Chef', 'Normal', 'Thank you for the interview details...', '2h ago', 0, 'None', true, 0),
    ('Marco Bianchi', 'MB', 0.35, 'The Ritz London', 'Head Sommelier', 'Flagged', 'This is inappropriate language in...', '1d ago', 2, 'None', false, 0),
    ('Sofia Andersen', 'SA', 0.72, 'Burj Al Arab', 'Concierge', 'Under Review', 'Can you provide more details about...', '3h ago', 0, 'Open', false, 5),
    ('Ahmed Al-Rashid', 'AA', 0.15, 'Sketch London', 'Bartender', 'Normal', 'When can I start the trial shift?', '5h ago', 0, 'None', true, 0),
    ('Liam O\'Brien', 'LO', 0.88, 'Zuma Dubai', 'Pastry Chef', 'Restricted', 'Account under review...', '3d ago', 1, 'Resolved', false, 8),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'All' ? _convos : _filter == 'Interview Related' ? _convos.where((c) => c.$11).toList() : _filter == 'No Reply' ? _convos.where((c) => c.$12 >= 3).toList() : _convos.where((c) => c.$6 == _filter || (_filter == 'Support Issues' && c.$10 != 'None' && c.$10 != 'Resolved')).toList();
    return Scaffold(backgroundColor: AppColors.background, body: SafeArea(child: Column(children: [
      AdminTopBar(title: 'Messages', onBack: () => Navigator.pop(context)),
      Padding(padding: const EdgeInsets.only(top: AppSpacing.xs), child: SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl), child: Row(children: [
        AdminSummaryChip(label: 'All', count: '${_convos.length}', color: AppColors.charcoal), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Flagged', count: '${_convos.where((c) => c.$6 == 'Flagged').length}', color: AppColors.urgent), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Review', count: '${_convos.where((c) => c.$6 == 'Under Review').length}', color: AppColors.amber),
      ]))),
      Padding(padding: const EdgeInsets.only(top: AppSpacing.sm), child: AdminFilterChips(filters: _filters, selected: _filter, onSelected: (f) => setState(() => _filter = f))),
      Padding(padding: const EdgeInsets.only(top: AppSpacing.sm), child: AdminSortRow(count: filtered.length, entityName: 'conversations', sortLabel: 'Recent', onSort: () {})),
      Expanded(child: filtered.isEmpty ? AdminEmptyState(icon: Icons.forum, title: 'No conversations match', subtitle: 'Try adjusting filters.') : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xxxl),
        child: Container(
          decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(AppRadius.xl), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
          child: Column(children: filtered.asMap().entries.map((e) {
            final c = e.value;
            final sc = c.$6 == 'Flagged' ? AppColors.urgent : c.$6 == 'Under Review' ? AppColors.amber : c.$6 == 'Restricted' ? AppColors.tertiary : AppColors.online;
            return Column(children: [
              if (e.key > 0) Padding(padding: EdgeInsets.only(left: AppSpacing.xl + 44 + AppSpacing.md), child: const Divider(height: 1, color: AppColors.divider)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                AvatarCircle(initials: c.$2, hue: c.$3),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Flexible(child: Text('${c.$1} x ${c.$4}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal), maxLines: 1, overflow: TextOverflow.ellipsis)), if (c.$6 != 'Normal') ...[const SizedBox(width: AppSpacing.xs), StatusPill(text: c.$6, color: sc)]]),
                  const SizedBox(height: AppSpacing.xs),
                  Row(children: [Text('Re: ${c.$5}', style: const TextStyle(fontSize: 13, color: AppColors.teal), maxLines: 1), const Text(' · ', style: TextStyle(fontSize: 10, color: AppColors.tertiary)), Text(c.$8, style: const TextStyle(fontSize: 10, color: AppColors.tertiary))]),
                  const SizedBox(height: AppSpacing.xs),
                  Text(c.$7, style: const TextStyle(fontSize: 13, color: AppColors.secondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: AppSpacing.xs),
                  Row(children: [
                    if (c.$9 > 0) ...[Container(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 1), decoration: BoxDecoration(color: AppColors.urgent.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppRadius.full)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.flag, size: 10, color: AppColors.urgent), Text('${c.$9}', style: const TextStyle(fontSize: 10, color: AppColors.urgent))])), const SizedBox(width: AppSpacing.sm)],
                    if (c.$11) ...[Container(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 1), decoration: BoxDecoration(color: AppColors.online.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(AppRadius.full)), child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.calendar_today, size: 10, color: AppColors.online), SizedBox(width: 2), Text('Interview', style: TextStyle(fontSize: 10, color: AppColors.online))])), const SizedBox(width: AppSpacing.sm)],
                    if (c.$12 >= 3) Text('No reply ${c.$12}d', style: const TextStyle(fontSize: 10, color: AppColors.amber)),
                  ]),
                ])),
                const Icon(Icons.more_horiz, size: 18, color: AppColors.tertiary),
              ])),
            ]);
          }).toList()),
        ),
      )),
    ])));
  }
}
