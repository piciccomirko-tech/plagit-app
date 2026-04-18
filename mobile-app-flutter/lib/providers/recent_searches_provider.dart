import 'package:flutter/foundation.dart';

/// Which side of the app a recent-search scope belongs to.
///
/// Candidate, Business, and Admin each keep their **own** recent-search
/// history, partitioned by scope. A candidate searching "Milan" in Jobs
/// never leaks into the Business applicants search and vice versa.
enum RecentSearchScope {
  // ── Candidate ──
  candidateJobs,
  candidateApplications,
  candidateMessages,
  candidateCommunity,

  // ── Business ──
  businessJobs,
  businessApplicants,
  businessMessages,
  businessCommunity,
  businessDashboard,

  // ── Admin ──
  adminCandidates,
  adminBusinesses,
  adminApplications,

  // ── Shared pickers ──
  hospitalityCategory,
  language,
}

/// Shared recent-searches store.
///
/// Rules:
///   • Most recent first
///   • Deduplicated (adding an existing term moves it to the top)
///   • Capped at `maxEntries` per scope — default 8
///   • `remove(scope, term)` drops one item
///   • `clear(scope)` wipes the whole history for a scope
///
/// In-memory only for now — when persistence lands, swap the internal Map
/// for `SharedPreferences` without changing any call sites.
class RecentSearchesProvider extends ChangeNotifier {
  /// Maximum recent entries kept per scope. Capped to 3 so the UI stays
  /// clean and the most relevant history is always at hand.
  static const int maxEntries = 3;

  final Map<RecentSearchScope, List<String>> _store = {};

  /// Returns the recent searches for [scope], most recent first.
  List<String> recentFor(RecentSearchScope scope) {
    return List.unmodifiable(_store[scope] ?? const []);
  }

  /// Records a new search for [scope].
  ///
  /// Behaviour:
  ///   • Empty / whitespace-only terms are ignored
  ///   • Case-insensitive deduplication — if the term already exists (in any
  ///     case) it is removed from its old position and re-inserted at the top
  ///   • Trims to [maxEntries] by dropping the oldest entries
  void record(RecentSearchScope scope, String rawTerm) {
    final term = rawTerm.trim();
    if (term.isEmpty) return;
    final list = _store[scope] ?? <String>[];
    // Case-insensitive dedupe
    list.removeWhere((e) => e.toLowerCase() == term.toLowerCase());
    list.insert(0, term);
    if (list.length > maxEntries) {
      list.removeRange(maxEntries, list.length);
    }
    _store[scope] = list;
    notifyListeners();
  }

  /// Removes a single term from a scope. No-op if the term isn't there.
  void remove(RecentSearchScope scope, String term) {
    final list = _store[scope];
    if (list == null || list.isEmpty) return;
    final before = list.length;
    list.removeWhere((e) => e.toLowerCase() == term.toLowerCase());
    if (list.length != before) notifyListeners();
  }

  /// Clears every entry in a single scope.
  void clear(RecentSearchScope scope) {
    if (_store[scope] == null || _store[scope]!.isEmpty) return;
    _store[scope] = <String>[];
    notifyListeners();
  }

  /// Admin tool — wipes every scope at once. Not exposed to users.
  void wipeAll() {
    if (_store.isEmpty) return;
    _store.clear();
    notifyListeners();
  }
}
