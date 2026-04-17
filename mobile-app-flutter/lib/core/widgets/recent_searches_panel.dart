import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/providers/recent_searches_provider.dart';

const _tealMain = Color(0xFF00B5B0);
const _tealLight = Color(0x1A00B5B0);
const _surface = Color(0xFFF9FAFB);
const _charcoal = Color(0xFF1A1C24);
const _secondary = Color(0xFF707580);
const _tertiary = Color(0xFF9EA3AD);

/// Shared "Recent searches" block shown below a search input when the
/// input is empty.
///
/// Pattern:
///   • Header row: "Recent searches" on the left, "Clear all" on the right
///   • List of chips, most-recent first, each with an inline `×` to remove
///     a single entry
///   • Clean empty state when the user has no history in this scope
///
/// Used by every search-enabled surface on Candidate, Business, and Admin
/// sides. The `scope` parameter guarantees role separation — a Candidate
/// searching "Milan" in Jobs never bleeds into the Business Applicants
/// history, and vice versa.
class RecentSearchesPanel extends StatelessWidget {
  final RecentSearchScope scope;

  /// Called when the user taps a recent term. Callers should set this to a
  /// closure that re-runs the search using the selected term (typically by
  /// setting their own `_searchText` state + controller text).
  final void Function(String term) onTapTerm;

  /// Optional — a short text that describes what this surface searches.
  /// Shown in the empty state. Defaults to a generic line.
  final String? emptyHint;

  const RecentSearchesPanel({
    super.key,
    required this.scope,
    required this.onTapTerm,
    this.emptyHint,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final store = context.watch<RecentSearchesProvider>();
    final recents = store.recentFor(scope);

    if (recents.isEmpty) return _buildEmptyState(context, l);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.clock, size: 13, color: _secondary),
              const SizedBox(width: 6),
              Text(
                l.recentSearches,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _charcoal,
                  letterSpacing: -0.1,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.read<RecentSearchesProvider>().clear(scope),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    l.clearAll,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _tealMain,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recents.map((term) => _RecentChip(
                  term: term,
                  onTap: () => onTapTerm(term),
                  onRemove: () =>
                      context.read<RecentSearchesProvider>().remove(scope, term),
                )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(color: _tealLight, shape: BoxShape.circle),
            child: const Icon(CupertinoIcons.search, size: 18, color: _tealMain),
          ),
          const SizedBox(height: 12),
          Text(
            l.recentSearchesEmptyTitle,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _charcoal,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            emptyHint ?? l.recentSearchesEmptyHint,
            style: const TextStyle(fontSize: 11, color: _tertiary, height: 1.4),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// RECENT CHIP
// ═══════════════════════════════════════════════════════════════

class _RecentChip extends StatelessWidget {
  final String term;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  const _RecentChip({
    required this.term,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 7, 6, 7),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: const Color(0xFFE6E8ED), width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.clock, size: 11, color: _tertiary),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 180),
              child: Text(
                term,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _charcoal,
                  letterSpacing: -0.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                child: const Icon(CupertinoIcons.xmark, size: 11, color: _tertiary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
