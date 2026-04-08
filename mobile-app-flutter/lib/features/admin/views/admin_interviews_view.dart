import 'package:flutter/material.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';

class AdminInterviewsView extends StatefulWidget {
  const AdminInterviewsView({super.key});
  @override State<AdminInterviewsView> createState() => _S();
}

class _S extends State<AdminInterviewsView> {
  String _filter = 'All';
  String _viewMode = 'list';
  final _filters = ['All', 'Today', 'Pending', 'Confirmed', 'Rescheduled', 'Cancelled', 'Flagged'];
  final _interviews = [
    ('Elena Rossi', 'ER', 0.52, 'Senior Chef', 'Nobu Restaurant', 'Confirmed', 'Apr 8', '10:00', 'GST', 'Video Call', true, 0, 0, ''),
    ('Marco Bianchi', 'MB', 0.35, 'Head Sommelier', 'The Ritz London', 'Pending', 'Apr 8', '14:00', 'GMT', 'In Person', true, 4, 0, 'Mayfair Office'),
    ('Sofia Andersen', 'SA', 0.72, 'Concierge', 'Burj Al Arab', 'Confirmed', 'Apr 9', '11:00', 'GST', 'Phone', true, 0, 0, ''),
    ('Ahmed Al-Rashid', 'AA', 0.15, 'Bartender', 'Sketch London', 'Rescheduled', 'Apr 10', '16:00', 'GMT', 'Video Call', false, 0, 2, ''),
    ('Liam O\'Brien', 'LO', 0.88, 'Pastry Chef', 'Zuma Dubai', 'Cancelled', 'Apr 7', '09:00', 'GST', 'In Person', true, 0, 0, 'Dubai Marina'),
    ('Maria Garcia', 'MG', 0.6, 'Room Attendant', 'The Ritz London', 'Pending', 'Apr 11', '15:00', 'GMT', 'Video Call', true, 5, 0, ''),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'All' ? _interviews : _filter == 'Today' ? _interviews.where((i) => i.$7 == 'Apr 8').toList() : _interviews.where((i) => i.$6 == _filter).toList();
    return Scaffold(backgroundColor: AppColors.background, body: SafeArea(child: Column(children: [
      AdminTopBar(title: 'Interviews', onBack: () => Navigator.pop(context)),
      Padding(padding: const EdgeInsets.only(top: AppSpacing.xs), child: SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl), child: Row(children: [
        AdminSummaryChip(label: 'All', count: '${_interviews.length}', color: AppColors.charcoal, width: 68), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Today', count: '${_interviews.where((i) => i.$7 == 'Apr 8').length}', color: AppColors.teal, width: 68), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Pending', count: '${_interviews.where((i) => i.$6 == 'Pending').length}', color: AppColors.amber, width: 68), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Confirmed', count: '${_interviews.where((i) => i.$6 == 'Confirmed').length}', color: AppColors.online, width: 68),
      ]))),
      Padding(padding: const EdgeInsets.only(top: AppSpacing.sm), child: AdminFilterChips(filters: _filters, selected: _filter, onSelected: (f) => setState(() => _filter = f))),
      Padding(padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, 0), child: Row(children: [
        Text('${filtered.length} interviews', style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
        const Spacer(),
        _viewToggle(),
      ])),
      Expanded(child: filtered.isEmpty ? AdminEmptyState(icon: Icons.calendar_today, title: 'No interviews match', subtitle: 'Try adjusting filters.') : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xxxl),
        child: Container(
          decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(AppRadius.xl), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
          child: Column(children: filtered.asMap().entries.map((e) {
            final iv = e.value;
            final sc = iv.$6 == 'Pending' ? AppColors.amber : iv.$6 == 'Confirmed' ? AppColors.online : iv.$6 == 'Rescheduled' ? AppColors.indigo : iv.$6 == 'Cancelled' ? AppColors.tertiary : AppColors.teal;
            final tc = iv.$10 == 'Video Call' ? AppColors.indigo : iv.$10 == 'Phone' ? AppColors.teal : AppColors.amber;
            final ti = iv.$10 == 'Video Call' ? Icons.videocam : iv.$10 == 'Phone' ? Icons.phone : Icons.location_on;
            return Column(children: [
              if (e.key > 0) Padding(padding: EdgeInsets.only(left: AppSpacing.xl + 44 + AppSpacing.md), child: const Divider(height: 1, color: AppColors.divider)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                AvatarCircle(initials: iv.$2, hue: iv.$3),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Flexible(child: Text(iv.$1, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal), maxLines: 1)), const SizedBox(width: AppSpacing.sm), StatusPill(text: iv.$6, color: sc)]),
                  const SizedBox(height: AppSpacing.xs),
                  Row(children: [Text(iv.$4, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.charcoal)), const Text(' · ', style: TextStyle(fontSize: 10, color: AppColors.tertiary)), Expanded(child: Text(iv.$5, style: const TextStyle(fontSize: 13, color: AppColors.secondary), maxLines: 1))]),
                  const SizedBox(height: AppSpacing.xs),
                  Row(children: [const Icon(Icons.calendar_today, size: 11, color: AppColors.teal), const SizedBox(width: 3), Text('${iv.$7} · ${iv.$8} ${iv.$9}', style: const TextStyle(fontSize: 10, color: AppColors.secondary)), const SizedBox(width: AppSpacing.md), Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), decoration: BoxDecoration(color: tc.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(AppRadius.full)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(ti, size: 10, color: tc), const SizedBox(width: 2), Text(iv.$10, style: TextStyle(fontSize: 10, color: tc))]))]),
                  const SizedBox(height: AppSpacing.xs),
                  Row(children: [
                    if (iv.$12 >= 3 && iv.$6 == 'Pending') ...[Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.full), border: Border.all(color: AppColors.amber.withValues(alpha: 0.3), width: 0.5)), child: Text('Pending ${iv.$12}d', style: const TextStyle(fontSize: 10, color: AppColors.amber))), const SizedBox(width: AppSpacing.sm)],
                    if (iv.$13 >= 2) ...[Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.full), border: Border.all(color: AppColors.amber.withValues(alpha: 0.3), width: 0.5)), child: Text('Rescheduled x${iv.$13}', style: const TextStyle(fontSize: 10, color: AppColors.amber)))],
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

  Widget _viewToggle() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.sm + 2)),
      child: Row(children: [
        _toggleBtn(Icons.list, 'list'),
        _toggleBtn(Icons.calendar_today, 'calendar'),
      ]),
    );
  }

  Widget _toggleBtn(IconData icon, String mode) {
    final active = _viewMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _viewMode = mode),
      child: Container(
        width: 32, height: 28,
        decoration: BoxDecoration(color: active ? AppColors.teal : Colors.transparent, borderRadius: BorderRadius.circular(AppRadius.sm)),
        child: Icon(icon, size: 14, color: active ? Colors.white : AppColors.secondary),
      ),
    );
  }
}
