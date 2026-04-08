import 'package:flutter/material.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';

class AdminSubscriptionsView extends StatefulWidget {
  const AdminSubscriptionsView({super.key});
  @override State<AdminSubscriptionsView> createState() => _S();
}

class _S extends State<AdminSubscriptionsView> {
  String _filter = 'All';
  final _filters = ['All', 'Active', 'Trial', 'Expiring Soon', 'Failed Payment', 'Cancelled', 'Grace Period', 'Comp Access'];
  final _subs = [
    ('Nobu Restaurant', 'NR', 0.55, 'business', 'Premium', 'Active', '\$299/mo', 'Monthly', 'Paid', 'Apr 15', true, 0, 'Mar 15', 4),
    ('The Ritz London', 'RL', 0.3, 'business', 'Enterprise', 'Active', '\$4,999/mo', 'Monthly', 'Paid', 'Apr 1', true, 0, 'Mar 1', 8),
    ('Zuma Dubai', 'ZD', 0.7, 'business', 'Basic', 'Trial', '\$99/mo', 'Monthly', 'Trial', '-', true, 10, 'Mar 20', 0),
    ('Burj Al Arab', 'BA', 0.1, 'business', 'Enterprise', 'Active', '\$4,999/mo', 'Annual', 'Paid', 'Jun 1', true, 0, 'Mar 10', 12),
    ('Sketch London', 'SL', 0.42, 'business', 'Basic', 'Failed Payment', '\$99/mo', 'Monthly', 'Failed', '-', false, 0, 'Mar 5', 2),
    ('Elena Rossi', 'ER', 0.52, 'candidate', 'Premium', 'Active', '\$29/mo', 'Monthly', 'Paid', 'Apr 10', true, 0, 'Mar 10', 3),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'All' ? _subs : _filter == 'Failed Payment' ? _subs.where((s) => s.$9 == 'Failed').toList() : _subs.where((s) => s.$6 == _filter).toList();
    return Scaffold(backgroundColor: AppColors.background, body: SafeArea(child: Column(children: [
      AdminTopBar(title: 'Subscriptions & Billing', onBack: () => Navigator.pop(context)),
      Expanded(child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: AppSpacing.md),
        _revenueMetrics(),
        const SizedBox(height: AppSpacing.lg),
        SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl), child: Row(children: [
          AdminSummaryChip(label: 'All', count: '${_subs.length}', color: AppColors.charcoal), const SizedBox(width: AppSpacing.sm),
          AdminSummaryChip(label: 'Active', count: '${_subs.where((s) => s.$6 == 'Active').length}', color: AppColors.online), const SizedBox(width: AppSpacing.sm),
          AdminSummaryChip(label: 'Trial', count: '${_subs.where((s) => s.$6 == 'Trial').length}', color: AppColors.amber), const SizedBox(width: AppSpacing.sm),
          AdminSummaryChip(label: 'Failed', count: '${_subs.where((s) => s.$9 == 'Failed').length}', color: AppColors.urgent),
        ])),
        const SizedBox(height: AppSpacing.sm),
        AdminFilterChips(filters: _filters, selected: _filter, onSelected: (f) => setState(() => _filter = f)),
        Padding(padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, 0), child: AdminSortRow(count: filtered.length, entityName: 'subscriptions', sortLabel: 'Amount', onSort: () {})),
        if (_subs.where((s) => s.$9 == 'Failed').isNotEmpty) _failedSection(),
        const SizedBox(height: AppSpacing.md),
        Padding(padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xxxl), child: Container(
          decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(AppRadius.xl), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
          child: Column(children: filtered.asMap().entries.map((e) {
            final s = e.value;
            final planColor = s.$5 == 'Enterprise' ? AppColors.indigo : s.$5 == 'Premium' ? AppColors.teal : AppColors.secondary;
            final statusColor = s.$6 == 'Active' ? AppColors.online : s.$6 == 'Trial' ? AppColors.amber : s.$6 == 'Failed Payment' ? AppColors.urgent : AppColors.tertiary;
            final paymentColor = s.$9 == 'Paid' ? AppColors.online : s.$9 == 'Failed' ? AppColors.urgent : AppColors.amber;
            return Column(children: [
              if (e.key > 0) Padding(padding: EdgeInsets.only(left: AppSpacing.xl + 40 + AppSpacing.md), child: const Divider(height: 1, color: AppColors.divider)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                AvatarCircle(initials: s.$2, hue: s.$3, size: 40),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Flexible(child: Text(s.$1, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal), maxLines: 1, overflow: TextOverflow.ellipsis)), const SizedBox(width: AppSpacing.xs), Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2), decoration: BoxDecoration(color: s.$4 == 'candidate' ? AppColors.teal : AppColors.indigo, borderRadius: BorderRadius.circular(AppRadius.full)), child: Text(s.$4.toString().substring(0, 1).toUpperCase() + s.$4.toString().substring(1), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white))), const SizedBox(width: AppSpacing.xs), StatusPill(text: s.$5, color: planColor), const SizedBox(width: AppSpacing.xs), StatusPill(text: s.$6, color: statusColor)]),
                  const SizedBox(height: AppSpacing.xs),
                  Row(children: [Text(s.$7, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.charcoal)), const SizedBox(width: AppSpacing.sm), Text(s.$8, style: const TextStyle(fontSize: 10, color: AppColors.secondary)), const SizedBox(width: AppSpacing.sm), Row(mainAxisSize: MainAxisSize.min, children: [Icon(s.$9 == 'Paid' ? Icons.check_circle : s.$9 == 'Failed' ? Icons.cancel : Icons.schedule, size: 10, color: paymentColor), const SizedBox(width: 2), Text(s.$9, style: TextStyle(fontSize: 10, color: paymentColor))])]),
                  const SizedBox(height: AppSpacing.xs),
                  Row(children: [if (s.$6 == 'Trial' && s.$12 > 0) ...[StatusPill(text: '${s.$12}d left', color: AppColors.amber), const SizedBox(width: AppSpacing.sm)], if (s.$10 != '-') Text('Renews ${s.$10}', style: const TextStyle(fontSize: 10, color: AppColors.tertiary)), if (!s.$11 && s.$6 != 'Cancelled') ...[const SizedBox(width: AppSpacing.sm), Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.full), border: Border.all(color: AppColors.urgent.withValues(alpha: 0.3), width: 0.5)), child: const Text('Auto-renew off', style: TextStyle(fontSize: 10, color: AppColors.urgent)))]]),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Last payment: ${s.$13} · ${s.$14} invoices', style: const TextStyle(fontSize: 10, color: AppColors.tertiary)),
                ])),
                const Icon(Icons.more_horiz, size: 18, color: AppColors.tertiary),
              ])),
            ]);
          }).toList()),
        )),
      ]))),
    ])));
  }

  Widget _revenueMetrics() {
    return AdminCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const AdminSectionTitle(title: 'Billing Health', icon: Icons.bar_chart),
      const SizedBox(height: AppSpacing.md),
      Row(children: [_rv('\$2,894', 'MRR', AppColors.teal), _rv('6', 'Paying', AppColors.online), _rv('33%', 'Trial Conv.', AppColors.amber), _rv('20%', 'Failed Rate', AppColors.urgent), _rv('3', 'Renewing', AppColors.indigo)]),
    ]));
  }

  Widget _rv(String v, String l, Color c) => Expanded(child: Column(children: [Text(v, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c)), const SizedBox(height: 2), Text(l, style: const TextStyle(fontSize: 10, color: AppColors.secondary))]));

  Widget _failedSection() {
    final failed = _subs.where((s) => s.$9 == 'Failed').toList();
    return Container(
      margin: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, 0),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(AppRadius.xl), border: Border.all(color: AppColors.urgent.withValues(alpha: 0.15)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Icon(Icons.warning, size: 14, color: AppColors.urgent), const SizedBox(width: AppSpacing.sm), const Text('Failed Payments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.charcoal)), const SizedBox(width: AppSpacing.sm), Container(width: 20, height: 20, decoration: const BoxDecoration(color: AppColors.urgent, shape: BoxShape.circle), alignment: Alignment.center, child: Text('${failed.length}', style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)))]),
        const SizedBox(height: AppSpacing.md),
        ...failed.map((s) => Padding(padding: const EdgeInsets.only(bottom: AppSpacing.sm), child: Row(children: [Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.urgent, shape: BoxShape.circle)), const SizedBox(width: AppSpacing.md), Text(s.$1, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.charcoal)), const SizedBox(width: AppSpacing.sm), Text(s.$5, style: const TextStyle(fontSize: 10, color: AppColors.secondary)), const Spacer(), Text(s.$7, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.urgent)), const SizedBox(width: AppSpacing.sm), const Text('Resend', style: TextStyle(fontSize: 10, color: AppColors.teal))]))),
      ]),
    );
  }
}
