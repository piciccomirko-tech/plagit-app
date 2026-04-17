import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/widgets/status_badge.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/providers/admin_providers.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

class AdminModerationView extends StatefulWidget {
  const AdminModerationView({super.key});
  @override
  State<AdminModerationView> createState() => _AdminModerationViewState();
}

class _AdminModerationViewState extends State<AdminModerationView> {
  String _filter = 'All';
  final _filters = ['All', 'High', 'Medium', 'Low', 'Resolved'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminReportsListProvider>().load();
    });
  }

  List<Map<String, dynamic>> _filtered(List<Map<String, dynamic>> allItems) {
    if (_filter == 'All') return allItems.toList();
    if (_filter == 'Resolved') {
      return allItems.where((r) => r['status'] == 'Resolved').toList();
    }
    return allItems.where((r) => r['priority'] == _filter).toList();
  }

  int _openCount(List<Map<String, dynamic>> allItems) {
    return allItems.where((r) => r['status'] == 'Open').length;
  }

  IconData _entityIcon(String entityType) {
    switch (entityType) {
      case 'Job':
        return Icons.work;
      case 'Message':
        return Icons.chat;
      case 'Business':
        return Icons.business;
      default:
        return Icons.flag;
    }
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'High':
        return AppColors.red;
      case 'Medium':
        return AppColors.amber;
      case 'Low':
        return AppColors.secondary;
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = context.watch<AdminReportsListProvider>();

    if (provider.loading) {
      return Scaffold(backgroundColor: AppColors.background, body: SafeArea(child: Column(children: [
        aTopBar(context, l.adminMenuModeration),
        const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.teal))),
      ])));
    }

    if (provider.error != null) {
      return Scaffold(backgroundColor: AppColors.background, body: SafeArea(child: Column(children: [
        aTopBar(context, l.adminMenuModeration),
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
    final filtered = _filtered(allItems);
    final filterLabel = {
      'All': l.adminFilterAll,
      'High': l.adminPriorityHigh,
      'Medium': l.adminPriorityMedium,
      'Low': l.adminPriorityLow,
      'Resolved': l.adminStatusResolved,
    };
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            aTopBar(context, l.adminMenuModeration, trailing: aPill('${_openCount(allItems)}', AppColors.red)),
            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: _filters.map((f) {
                  final isActive = _filter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.teal : Colors.white,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: isActive ? Colors.transparent : AppColors.divider,
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          filterLabel[f] ?? f,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isActive ? Colors.white : AppColors.secondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            // List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(l.adminEmptyReportsTitle, style: const TextStyle(color: AppColors.secondary)),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final r = filtered[index];
                        final priorityColor = _priorityColor(r['priority'] as String);
                        return GestureDetector(
                          onTap: () => context.push('/admin/moderation/${r['id']}'),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: AppColors.cardDecoration,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: priorityColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    _entityIcon(r['entityType'] as String),
                                    size: 18,
                                    color: priorityColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r['title'] as String,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.charcoal,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        r['entity'] as String,
                                        style: const TextStyle(fontSize: 12, color: AppColors.secondary),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          // Priority badge
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: priorityColor,
                                              borderRadius: BorderRadius.circular(100),
                                            ),
                                            child: Text(
                                              aPriorityLabel(l, r['priority'] as String),
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          StatusBadge(status: r['status'] as String),
                                          const Spacer(),
                                          Text(
                                            r['date'] as String,
                                            style: const TextStyle(fontSize: 11, color: AppColors.tertiary),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: ForwardChevron(size: 28, color: AppColors.tertiary),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
