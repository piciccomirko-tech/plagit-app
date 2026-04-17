import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/widgets/post_insights_sheet.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/models/community_post.dart';
import 'package:plagit/providers/community_provider.dart';

/// Admin Community moderation screen.
///
/// Reads from the same `CommunityProvider` the candidate / business sides
/// use, so reports / hides made by users are immediately visible here. The
/// admin can hide, restore, or hard-remove posts and review reported items.
class AdminCommunityView extends StatefulWidget {
  const AdminCommunityView({super.key});
  @override
  State<AdminCommunityView> createState() => _AdminCommunityViewState();
}

class _AdminCommunityViewState extends State<AdminCommunityView> {
  int _filter = 0;
  static const _filters = ['All', 'Reported', 'Hidden', 'Business', 'Candidate'];

  List<CommunityPost> _filtered(CommunityProvider p) {
    final all = p.all;
    return switch (_filter) {
      1 => all.where((x) => x.isReported).toList(),
      2 => all.where((x) => x.isHidden).toList(),
      3 => all.where((x) => x.authorKind == AuthorKind.business).toList(),
      4 => all.where((x) => x.authorKind == AuthorKind.candidate).toList(),
      _ => all,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = context.watch<CommunityProvider>();
    final all = provider.all;
    final items = _filtered(provider);
    final reportedCount = all.where((p) => p.isReported).length;
    final hiddenCount = all.where((p) => p.isHidden).length;
    final filterLabels = [
      l.adminFilterAll,
      l.adminFilterReported,
      l.adminFilterHidden,
      l.adminFilterBusiness,
      l.adminFilterCandidate,
    ];

    return Scaffold(
      backgroundColor: aBg,
      body: SafeArea(
        child: Column(
          children: [
            aTopBar(
              context,
              l.adminMenuCommunity,
              trailing: aPill('${all.length}', aTeal),
            ),

            // ── Summary stats ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Row(
                children: [
                  Text(
                    l.adminCountTotal(all.length),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: aCharcoal),
                  ),
                  if (reportedCount > 0) ...[
                    const SizedBox(width: 12),
                    Text(
                      l.adminCountReported(reportedCount),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: aUrgent),
                    ),
                  ],
                  if (hiddenCount > 0) ...[
                    const SizedBox(width: 12),
                    Text(
                      l.adminCountHidden(hiddenCount),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: aSecondary),
                    ),
                  ],
                ],
              ),
            ),

            // ── Filter chips ──
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                itemCount: _filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final active = _filter == i;
                  final isReported = _filters[i] == 'Reported';
                  final accent = isReported ? aUrgent : aTeal;
                  final count = i == 0
                      ? all.length
                      : i == 1
                          ? reportedCount
                          : i == 2
                              ? hiddenCount
                              : i == 3
                                  ? all.where((p) => p.authorKind == AuthorKind.business).length
                                  : all.where((p) => p.authorKind == AuthorKind.candidate).length;
                  return GestureDetector(
                    onTap: () => setState(() => _filter = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: active ? accent : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: active ? null : Border.all(color: aBorder, width: 0.5),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(
                          filterLabels[i],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: active ? Colors.white : aCharcoal,
                          ),
                        ),
                        if (count > 0 && i != 0) ...[
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
                                fontWeight: FontWeight.w800,
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
                  ? aEmpty(
                      Icons.forum_outlined,
                      l.adminEmptyPostsTitle,
                      _filter == 1 ? l.adminEmptyReportsSub : l.adminEmptyContentFilter,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _AdminPostCard(post: items[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ADMIN POST CARD
// ═══════════════════════════════════════════════════════════════

class _AdminPostCard extends StatelessWidget {
  final CommunityPost post;
  const _AdminPostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final hue = (post.authorName.hashCode % 360).abs().toDouble();
    final isBusiness = post.authorKind == AuthorKind.business;

    return Container(
      decoration: BoxDecoration(
        color: aCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: post.isReported
              ? aUrgent.withValues(alpha: 0.30)
              : post.isHidden
                  ? const Color(0xFFE5E5EA)
                  : const Color(0xFFEFEFF4),
          width: post.isReported ? 1 : 0.5,
        ),
        boxShadow: [aCardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status banner (only when relevant)
          if (post.isReported || post.isHidden)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: post.isReported
                    ? aUrgent.withValues(alpha: 0.10)
                    : aSecondary.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    post.isReported ? CupertinoIcons.flag_fill : CupertinoIcons.eye_slash_fill,
                    size: 11,
                    color: post.isReported ? aUrgent : aSecondary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    post.isReported ? l.adminBannerReportedReview : l.adminBannerHiddenFromFeed,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: post.isReported ? aUrgent : aSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        HSLColor.fromAHSL(1, hue, 0.55, 0.55).toColor(),
                        HSLColor.fromAHSL(1, (hue + 30) % 360, 0.50, 0.50).toColor(),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      post.authorInitials,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              post.authorName,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: aCharcoal),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (post.authorVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(CupertinoIcons.checkmark_seal_fill, size: 12, color: aTeal),
                          ],
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: aTealLight,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              isBusiness ? l.adminFilterBusiness : l.adminFilterCandidate,
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: aTeal),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${post.authorRole}${post.authorLocation != null ? ' · ${post.authorLocation}' : ''} · ${post.timeAgo}',
                        style: const TextStyle(fontSize: 12, color: aTertiary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body preview
          if (post.body.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                post.body,
                style: const TextStyle(fontSize: 14, color: aCharcoal, height: 1.4),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Stats row — tappable, opens Insights in admin mode
          GestureDetector(
            onTap: () => _openAdminInsights(context, post),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  _statChip(CupertinoIcons.heart, '${post.likes}'),
                  const SizedBox(width: 12),
                  _statChip(CupertinoIcons.chat_bubble, '${post.commentsCount}'),
                  const SizedBox(width: 12),
                  _statChip(CupertinoIcons.eye, '${post.views}'),
                  const SizedBox(width: 12),
                  _statChip(CupertinoIcons.bookmark, '${post.saves}'),
                  const Spacer(),
                  const Icon(CupertinoIcons.chart_bar_alt_fill, size: 11, color: aTeal),
                  const SizedBox(width: 4),
                  Text(
                    l.adminActionInsights,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: aTeal,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Moderation actions
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: aDivider, width: 0.5)),
            ),
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
            child: Row(
              children: [
                if (post.isReported)
                  Expanded(
                    child: _modBtn(
                      icon: CupertinoIcons.checkmark_circle,
                      label: l.adminActionApprove,
                      color: aGreen,
                      onTap: () {
                        context.read<CommunityProvider>().unreport(post.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l.adminSnackbarReportCleared), duration: const Duration(seconds: 1)),
                        );
                      },
                    ),
                  ),
                if (!post.isHidden)
                  Expanded(
                    child: _modBtn(
                      icon: CupertinoIcons.eye_slash,
                      label: l.adminActionHide,
                      color: aAmber,
                      onTap: () {
                        context.read<CommunityProvider>().hide(post.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l.adminSnackbarPostHidden), duration: const Duration(seconds: 1)),
                        );
                      },
                    ),
                  ),
                Expanded(
                  child: _modBtn(
                    icon: CupertinoIcons.trash,
                    label: l.adminActionRemove,
                    color: aUrgent,
                    onTap: () => _confirmRemove(context, post),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: aTertiary),
        const SizedBox(width: 3),
        Text(
          value,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: aSecondary),
        ),
      ],
    );
  }

  /// Opens the same Post Insights sheet author/business sees, but in admin
  /// mode — bypasses premium gating and shows the suspicious-engagement
  /// banner if the heuristic flags the post.
  void _openAdminInsights(BuildContext context, CommunityPost post) {
    final provider = context.read<CommunityProvider>();
    PostInsightsSheet.show(
      context,
      insights: provider.insightsFor(post.id),
      post: post,
      isPremium: true,
      isAdmin: true,
    );
  }

  Widget _modBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemove(BuildContext context, CommunityPost post) {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l.adminDialogRemovePostTitle,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: aCharcoal),
        ),
        content: Text(
          l.adminDialogRemovePostBody,
          style: const TextStyle(fontSize: 14, color: aSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.adminActionCancel, style: const TextStyle(color: aSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CommunityProvider>().remove(post.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l.adminSnackbarPostRemoved), duration: const Duration(seconds: 1)),
              );
            },
            child: Text(
              l.adminActionRemove,
              style: const TextStyle(color: aUrgent, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
