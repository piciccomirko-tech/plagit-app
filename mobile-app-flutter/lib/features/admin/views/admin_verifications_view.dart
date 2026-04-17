import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';
import 'package:plagit/core/widgets/status_badge.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/providers/admin_providers.dart';

class AdminVerificationsView extends StatefulWidget {
  const AdminVerificationsView({super.key});
  @override
  State<AdminVerificationsView> createState() => _AdminVerificationsViewState();
}

class _AdminVerificationsViewState extends State<AdminVerificationsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminVerificationsListProvider>().load();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filteredQueue(List<Map<String, dynamic>> allItems) {
    final type = _tabController.index == 0 ? 'Candidate' : 'Business';
    return List<Map<String, dynamic>>.from(
      allItems.where((v) => v['type'] == type),
    );
  }

  int _daysWaiting(String submitted) {
    if (submitted.contains('1 day')) return 1;
    if (submitted.contains('2 day')) return 2;
    if (submitted.contains('3 day')) return 3;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = context.watch<AdminVerificationsListProvider>();

    if (provider.loading) {
      return Scaffold(backgroundColor: AppColors.background, body: SafeArea(child: Column(children: [
        aTopBar(context, l.adminMenuVerifications),
        const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.teal))),
      ])));
    }

    if (provider.error != null) {
      return Scaffold(backgroundColor: AppColors.background, body: SafeArea(child: Column(children: [
        aTopBar(context, l.adminMenuVerifications),
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
    final filtered = _filteredQueue(allItems);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            aTopBar(context, l.adminMenuVerifications, trailing: aPill('${allItems.length}', AppColors.amber)),
            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.divider.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.teal,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.secondary,
                labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                dividerHeight: 0,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Tab(text: l.adminMenuCandidates),
                  Tab(text: l.adminMenuBusinesses),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Queue list
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(l.adminEmptyVerificationsTitle, style: const TextStyle(color: AppColors.secondary)),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final v = filtered[index];
                        final days = _daysWaiting(v['submitted'] as String);
                        return GestureDetector(
                          onTap: () => context.push('/admin/verifications/${v['id']}'),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: AppColors.cardDecoration,
                            child: Row(
                              children: [
                                // Avatar
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.teal.withValues(alpha: 0.1),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    v['initials'] as String,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.teal,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        v['name'] as String,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.charcoal,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          StatusBadge(status: v['type'] as String),
                                          const SizedBox(width: 8),
                                          Text(
                                            v['submitted'] as String,
                                            style: const TextStyle(fontSize: 11, color: AppColors.tertiary),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            l.adminBadgeNDaysWaiting(days),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: days >= 3 ? AppColors.red : AppColors.amber,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => context.push('/admin/verifications/${v['id']}'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.amber,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      l.adminActionReview,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
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
