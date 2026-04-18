import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/widgets/status_badge.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/providers/admin_providers.dart';

class AdminSupportView extends StatefulWidget {
  const AdminSupportView({super.key});
  @override
  State<AdminSupportView> createState() => _AdminSupportViewState();
}

class _AdminSupportViewState extends State<AdminSupportView> {
  String _filter = 'All';
  final _filters = ['All', 'Open', 'In Review', 'Waiting', 'Resolved'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminSupportListProvider>().load();
    });
  }

  List<Map<String, dynamic>> _filtered(List<Map<String, dynamic>> allItems) {
    if (_filter == 'All') return allItems.toList();
    return allItems.where((s) => s['status'] == _filter).toList();
  }

  int _openCount(List<Map<String, dynamic>> allItems) =>
      allItems.where((s) => s['status'] == 'Open').length;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = context.watch<AdminSupportListProvider>();

    if (provider.loading) {
      return Scaffold(backgroundColor: AppColors.background, body: SafeArea(child: Column(children: [
        aTopBar(context, l.adminMenuSupport),
        const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.teal))),
      ])));
    }

    if (provider.error != null) {
      return Scaffold(backgroundColor: AppColors.background, body: SafeArea(child: Column(children: [
        aTopBar(context, l.adminMenuSupport),
        Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(provider.error!, style: const TextStyle(fontSize: 14, color: AppColors.secondary), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          GestureDetector(onTap: () => provider.load(), child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(100)),
            child: Text(l.adminActionRetry, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          )),
        ]))),
      ])));
    }

    final allItems = provider.items;
    final results = _filtered(allItems);
    final filterLabel = {
      'All': l.adminFilterAll,
      'Open': l.adminStatusOpen,
      'In Review': l.adminStatusInReview,
      'Waiting': l.adminStatusWaiting,
      'Resolved': l.adminStatusResolved,
    };
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
        children: [
          aTopBar(context, l.adminMenuSupport, trailing: aPill(l.adminBadgeNOpen(_openCount(allItems)), AppColors.red)),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: _filters.map((f) {
                final sel = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.teal
                            : AppColors.teal.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(filterLabel[f] ?? f,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: sel ? Colors.white : AppColors.teal)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // List
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.support_agent,
                            size: 48, color: AppColors.tertiary),
                        const SizedBox(height: 12),
                        Text(l.adminEmptyIssuesTitle,
                            style: const TextStyle(
                                fontSize: 15, color: AppColors.secondary)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    itemCount: results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _issueCard(results[i], l),
                  ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _issueCard(Map<String, dynamic> s, AppLocalizations l) {
    final priority = s['priority'] as String;
    final priorityColor =
        priority == 'High' ? AppColors.red : AppColors.amber;
    return GestureDetector(
      onTap: () => context.push('/admin/support/${s['id']}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(s['title'] as String,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.charcoal),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                StatusBadge(status: s['status'] as String),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(s['userName'] as String,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.secondary)),
                const SizedBox(width: 8),
                _typeBadge(s['userType'] as String, l),
                const Spacer(),
                _priorityBadge(priority, priorityColor, l),
              ],
            ),
            const SizedBox(height: 4),
            Text(s['created'] as String,
                style:
                    const TextStyle(fontSize: 11, color: AppColors.tertiary)),
          ],
        ),
      ),
    );
  }

  Widget _typeBadge(String type, AppLocalizations l) {
    final isBusiness = type == 'Business';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isBusiness
            ? AppColors.purple.withValues(alpha: 0.10)
            : AppColors.teal.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(isBusiness ? l.adminFilterBusiness : l.adminFilterCandidate,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isBusiness ? AppColors.purple : AppColors.teal)),
    );
  }

  Widget _priorityBadge(String priority, Color color, AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(aPriorityLabel(l, priority),
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
