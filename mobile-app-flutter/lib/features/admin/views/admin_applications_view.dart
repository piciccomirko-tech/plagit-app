import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/widgets/application_status_pill.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/providers/admin_providers.dart';

/// Admin Applications screen — list of every application across all
/// businesses with the unified status taxonomy and a moderation flag.
class AdminApplicationsView extends StatefulWidget {
  const AdminApplicationsView({super.key});
  @override
  State<AdminApplicationsView> createState() => _AdminApplicationsViewState();
}

class _AdminApplicationsViewState extends State<AdminApplicationsView> {
  int _chip = 0;

  // Filter chips — driven by the unified status taxonomy. Mirrors the
  // candidate / business sides so the same pipeline is visible everywhere.
  static const _filters = [
    'All',
    'Applied',
    'Under Review',
    'Shortlisted',
    'Interview',
    'Hired',
    'Rejected',
    'Flagged',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminApplicationsListProvider>().load();
    });
  }

  bool _matchesChip(Map<String, dynamic> a, int chipIndex) {
    if (chipIndex == 0) return true;
    final filter = _filters[chipIndex];
    if (filter == 'Flagged') return a['flagged'] == true;
    final s = (a['status'] as String).toLowerCase().replaceAll(' ', '');
    final key = filter.toLowerCase().replaceAll(' ', '');
    if (key == 'interview') {
      return s == 'interviewinvited' || s == 'interviewscheduled';
    }
    return s == key;
  }

  int _countFor(List<Map<String, dynamic>> allItems, int chipIndex) =>
      allItems.where((a) => _matchesChip(a, chipIndex)).length;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = context.watch<AdminApplicationsListProvider>();

    if (provider.loading) {
      return Scaffold(backgroundColor: aBg, body: SafeArea(child: Column(children: [
        aTopBar(context, l.adminMenuApplications),
        const Expanded(child: Center(child: CircularProgressIndicator(color: aTeal))),
      ])));
    }

    if (provider.error != null) {
      return Scaffold(backgroundColor: aBg, body: SafeArea(child: Column(children: [
        aTopBar(context, l.adminMenuApplications),
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

    final allItems = provider.items;
    final all = allItems.toList();
    final items = all.where((a) => _matchesChip(a, _chip)).toList();
    final flaggedCount = all.where((a) => a['flagged'] == true).length;

    final filterLabels = [
      l.adminFilterAll,
      l.adminStatusApplied,
      l.adminStatusUnderReview,
      l.adminStatusShortlisted,
      l.adminStatusInterview,
      l.adminStatusHired,
      l.adminStatusRejected,
      l.adminStatusFlagged,
    ];

    return Scaffold(
      backgroundColor: aBg,
      body: SafeArea(
        child: Column(
          children: [
            aTopBar(
              context,
              l.adminMenuApplications,
              trailing: aPill('${all.length}', aTeal),
            ),

            // ── Summary row ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  Text(
                    l.adminCountTotal(all.length),
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w500, color: aCharcoal),
                  ),
                  if (flaggedCount > 0) ...[
                    const SizedBox(width: 12),
                    Text(
                      l.adminBadgeNFlagged(flaggedCount),
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600, color: aUrgent),
                    ),
                  ],
                ],
              ),
            ),

            // ── Filter chips with counts ──
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                itemCount: _filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final active = _chip == i;
                  final label = filterLabels[i];
                  final count = i == 0 ? all.length : _countFor(all, i);
                  final hasCount = count > 0;
                  final isFlagged = _filters[i] == 'Flagged';
                  final accent = isFlagged ? aUrgent : aTeal;
                  return GestureDetector(
                    onTap: () => setState(() => _chip = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: active ? accent : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: active ? null : Border.all(color: aBorder, width: 0.5),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: active ? Colors.white : aCharcoal,
                          ),
                        ),
                        if (hasCount && i != 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: active
                                  ? Colors.white.withValues(alpha: 0.22)
                                  : accent.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              '$count',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: active ? Colors.white : accent,
                              ),
                            ),
                          ),
                        ],
                      ]),
                    ),
                  );
                },
              ),
            ),

            // ── List ──
            Expanded(
              child: items.isEmpty
                  ? aEmpty(Icons.description_outlined, l.adminEmptyApplicationsTitle, l.adminEmptyAdjustFilters)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
                      itemCount: items.length,
                      separatorBuilder: (_, i) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final a = items[i];
                        return _AdminAppCard(
                          data: a,
                          onTap: () => context.push('/admin/applications/${a['id']}'),
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

// ═══════════════════════════════════════════════════════════════
// ADMIN APPLICATION CARD
// ═══════════════════════════════════════════════════════════════

class _AdminAppCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;
  const _AdminAppCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final candidateName = data['candidateName'] as String? ?? l.adminMiscUnknown;
    final initials = (data['candidateInitials'] as String?) ??
        (candidateName.length >= 2
            ? candidateName.substring(0, 2).toUpperCase()
            : candidateName.toUpperCase());
    final jobTitle = data['jobTitle'] as String? ?? '';
    final business = data['business'] as String? ?? '';
    final status = data['status'] as String? ?? 'Applied';
    final date = data['date'] as String? ?? '';
    final flagged = data['flagged'] == true;
    final hue = (initials.hashCode % 360).abs().toDouble();

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: aCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: flagged ? aUrgent.withValues(alpha: 0.30) : const Color(0xFFEFEFF4),
            width: flagged ? 1 : 0.5,
          ),
          boxShadow: [aCardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Premium gradient avatar ──
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        HSLColor.fromAHSL(1, hue, 0.55, 0.55).toColor(),
                        HSLColor.fromAHSL(1, (hue + 30) % 360, 0.50, 0.50).toColor(),
                      ],
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Job title
                      Text(
                        jobTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: aCharcoal,
                          letterSpacing: -0.3,
                          height: 1.15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      // Candidate · Business (the linkage admin needs)
                      Row(
                        children: [
                          const Icon(CupertinoIcons.person_fill, size: 10, color: Color(0xFFAEAEB2)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              candidateName,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: aSecondary,
                                letterSpacing: -0.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Text('  →  ', style: TextStyle(fontSize: 11, color: Color(0xFFC7C7CC))),
                          const Icon(CupertinoIcons.building_2_fill, size: 10, color: Color(0xFFAEAEB2)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              business,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: aSecondary,
                                letterSpacing: -0.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ApplicationStatusPill(status: status, compact: true),
                const SizedBox(width: 8),
                if (flagged) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: aUrgent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(CupertinoIcons.flag_fill, size: 10, color: aUrgent),
                        const SizedBox(width: 4),
                        Text(
                          l.adminStatusFlagged,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: aUrgent,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(CupertinoIcons.clock, size: 10, color: aTertiary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          date,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: aTertiary,
                            letterSpacing: -0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(CupertinoIcons.chevron_right, size: 28, color: aTertiary),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
