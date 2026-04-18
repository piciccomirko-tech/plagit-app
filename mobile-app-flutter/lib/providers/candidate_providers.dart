/// ChangeNotifier providers for all candidate-side state.
///
/// Mirrors the Swift @Observable pattern — each provider owns a domain
/// slice (auth, home, jobs, applications, messages, interviews) and
/// exposes a three-state pattern: loading -> error (with retry) -> content.
library;

import 'package:flutter/material.dart';
import 'package:plagit/core/services/auth_expired_handler.dart';
import 'package:plagit/models/application.dart';
import 'package:plagit/models/candidate_home_data.dart';
import 'package:plagit/models/candidate_profile.dart';
import 'package:plagit/models/conversation.dart';
import 'package:plagit/models/interview.dart';
import 'package:plagit/models/job.dart';
import 'package:plagit/models/notification_item.dart';
import 'package:plagit/models/quick_plug_match.dart';
import 'package:plagit/models/subscription_state.dart';
import 'package:plagit/repositories/candidate_repository.dart';
import 'package:plagit/repositories/auth_repository.dart';

// ══════════════════════════════════════════════════════════════
// Auth — mirrors CandidateAuthService @Observable
// ══════════════════════════════════════════════════════════════

class CandidateAuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isRestoring = true;
  CandidateProfile? _profile;
  CandidateSubscription _subscription = CandidateSubscription.mock();
  final CandidateRepository _repo;
  final AuthRepository _authRepo;

  CandidateAuthProvider({CandidateRepository? repo, AuthRepository? authRepo})
      : _repo = repo ?? CandidateRepository(),
        _authRepo = authRepo ?? AuthRepository();

  bool get isAuthenticated => _isAuthenticated;
  bool get isRestoring => _isRestoring;
  CandidateProfile? get profile => _profile;
  CandidateSubscription get subscription => _subscription;

  /// Fast premium check — mirrors Swift `SubscriptionManager.isPremium`.
  /// Reads directly from the current subscription so UI reacts the
  /// instant a purchase / restore / dev-activation mutates state.
  bool get isPremium => _subscription.plan.isPremium;

  // ── Dev / billing harness (used by BillingDevPanel) ──
  //
  // These mutate [_subscription] in-memory only. The real StoreKit /
  // backend wiring lives in the billing services — the provider is
  // kept as the single source of truth for UI gating.
  SubscriptionPlan? _pendingRestorePlan;

  /// Flip the subscription to [plan] immediately. Used by the dev
  /// panel's "Activate Premium" button.
  Future<void> devActivatePremium(SubscriptionPlan plan) async {
    _subscription = CandidateSubscription.forPlan(plan);
    notifyListeners();
  }

  /// Drop back to the free tier. Used by the dev panel's
  /// "Deactivate Premium" button.
  Future<void> devDeactivatePremium() async {
    _subscription = CandidateSubscription.mock();
    notifyListeners();
  }

  /// Stage a successful restore for the next [restorePurchases] call.
  /// Synchronous — the panel awaits [restorePurchases] separately.
  void devSimulateRestoreSuccess(SubscriptionPlan plan) {
    _pendingRestorePlan = plan;
  }

  /// Stage a "nothing to restore" outcome for the next
  /// [restorePurchases] call.
  Future<void> devSimulateRestoreNothing() async {
    _pendingRestorePlan = null;
  }

  /// Consume whatever was staged by the dev harness and apply it.
  /// With a real billing service this would round-trip StoreKit /
  /// Play Billing — here it just replays the staged plan (if any).
  Future<void> restorePurchases() async {
    final pending = _pendingRestorePlan;
    _pendingRestorePlan = null;
    if (pending != null) {
      _subscription = CandidateSubscription.forPlan(pending);
      notifyListeners();
    }
  }

  /// Login via AuthRepository. Persists token, loads profile.
  Future<void> login(String email, String password) async {
    final result = await _authRepo.login(email: email, password: password);
    if (result.role != 'candidate') {
      throw Exception('Not a candidate account');
    }
    _profile = await _repo.fetchProfile();
    _subscription = await _repo.fetchSubscription();
    _isAuthenticated = true;
    notifyListeners();
  }

  /// Restore session from stored token.
  Future<void> restoreSession() async {
    _isRestoring = true;
    notifyListeners();
    try {
      final result = await _authRepo.restoreSession();
      if (result != null && result.role == 'candidate') {
        _profile = await _repo.fetchProfile();
        _subscription = await _repo.fetchSubscription();
        _isAuthenticated = true;
      }
    } catch (_) {
      // No valid session — stay logged out
    }
    _isRestoring = false;
    notifyListeners();
  }

  /// Clear auth state and tokens.
  Future<void> logout() async {
    await _authRepo.logout();
    _isAuthenticated = false;
    _profile = null;
    _subscription = CandidateSubscription.mock();
    notifyListeners();
  }

  /// Refresh profile from the repository.
  Future<void> refreshProfile() async {
    _profile = await _repo.fetchProfile();
    notifyListeners();
  }
}

// ══════════════════════════════════════════════════════════════
// Home dashboard
// ══════════════════════════════════════════════════════════════

class CandidateHomeProvider extends ChangeNotifier {
  CandidateHomeData? _data;
  bool _loading = true;
  String? _error;
  final CandidateRepository _repo;

  CandidateHomeProvider({CandidateRepository? repo})
      : _repo = repo ?? CandidateRepository();

  CandidateHomeData? get data => _data;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _data = await _repo.fetchHome();
    } catch (e) {
      if (!AuthExpiredHandler.instance.handleIfAuthError(e)) {
        _error = e.toString();
      }
    }
    _loading = false;
    notifyListeners();
  }
}

// ══════════════════════════════════════════════════════════════
// Jobs — search, filter, sort, save
// ══════════════════════════════════════════════════════════════

class CandidateJobsProvider extends ChangeNotifier {
  List<Job> _jobs = [];
  bool _loading = true;
  String? _error;
  String _filter = 'All';
  String _sort = 'Newest';
  String _search = '';
  Set<String> _savedIds = {};
  final CandidateRepository _repo;

  CandidateJobsProvider({CandidateRepository? repo})
      : _repo = repo ?? CandidateRepository();

  List<Job> get jobs => _jobs;
  bool get loading => _loading;
  String? get error => _error;
  String get filter => _filter;
  String get sort => _sort;
  String get search => _search;
  Set<String> get savedIds => _savedIds;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _jobs = await _repo.fetchJobs(
        search: _search.isEmpty ? null : _search,
        filter: _filter,
        sort: _sort,
      );
      _savedIds = await _repo.fetchSavedJobIds();
    } catch (e) {
      if (!AuthExpiredHandler.instance.handleIfAuthError(e)) {
        _error = e.toString();
      }
    }
    _loading = false;
    notifyListeners();
  }

  void setFilter(String f) {
    _filter = f;
    load();
  }

  void setSort(String s) {
    _sort = s;
    load();
  }

  void setSearch(String s) {
    _search = s;
    load();
  }

  void toggleSave(String jobId) {
    if (_savedIds.contains(jobId)) {
      _savedIds.remove(jobId);
      _repo.unsaveJob(jobId);
    } else {
      _savedIds.add(jobId);
      _repo.saveJob(jobId);
    }
    notifyListeners();
  }

  bool isSaved(String jobId) => _savedIds.contains(jobId);
}

// ══════════════════════════════════════════════════════════════
// Applications
// ══════════════════════════════════════════════════════════════

class CandidateApplicationsProvider extends ChangeNotifier {
  List<Application> _applications = [];
  bool _loading = true;
  String? _error;
  String _filter = 'All';
  final CandidateRepository _repo;

  CandidateApplicationsProvider({CandidateRepository? repo})
      : _repo = repo ?? CandidateRepository();

  List<Application> get applications => _applications;
  bool get loading => _loading;
  String? get error => _error;
  String get filter => _filter;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _applications = await _repo.fetchApplications(statusFilter: _filter);
    } catch (e) {
      if (!AuthExpiredHandler.instance.handleIfAuthError(e)) {
        _error = e.toString();
      }
    }
    _loading = false;
    notifyListeners();
  }

  void setFilter(String f) {
    _filter = f;
    load();
  }
}

// ══════════════════════════════════════════════════════════════
// Messages / Conversations
// ══════════════════════════════════════════════════════════════

class CandidateMessagesProvider extends ChangeNotifier {
  List<Conversation> _conversations = [];
  bool _loading = true;
  String? _error;
  final CandidateRepository _repo;

  CandidateMessagesProvider({CandidateRepository? repo})
      : _repo = repo ?? CandidateRepository();

  List<Conversation> get conversations => _conversations;
  bool get loading => _loading;
  String? get error => _error;
  int get totalUnread =>
      _conversations.fold(0, (sum, c) => sum + c.unread);

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _conversations = await _repo.fetchConversations();
    } catch (e) {
      if (!AuthExpiredHandler.instance.handleIfAuthError(e)) {
        _error = e.toString();
      }
    }
    _loading = false;
    notifyListeners();
  }

  /// Remove a single conversation by [id]. In-memory only for now —
  /// the repository does not yet expose a delete endpoint, so the
  /// state reverts on next [load]. Keeps the UI (swipe-to-delete)
  /// responsive in the meantime.
  void deleteConversation(String id) {
    final before = _conversations.length;
    _conversations = _conversations.where((c) => c.id != id).toList();
    if (_conversations.length != before) notifyListeners();
  }

  /// Remove every conversation whose id is in [ids].
  void deleteConversations(Set<String> ids) {
    if (ids.isEmpty) return;
    final before = _conversations.length;
    _conversations = _conversations.where((c) => !ids.contains(c.id)).toList();
    if (_conversations.length != before) notifyListeners();
  }

  /// Clear all conversations from the in-memory list.
  void deleteAllConversations() {
    if (_conversations.isEmpty) return;
    _conversations = [];
    notifyListeners();
  }
}

// ══════════════════════════════════════════════════════════════
// Interviews
// ══════════════════════════════════════════════════════════════

class CandidateInterviewsProvider extends ChangeNotifier {
  List<Interview> _interviews = [];
  bool _loading = true;
  String? _error;
  String _filter = 'Upcoming';
  final CandidateRepository _repo;

  CandidateInterviewsProvider({CandidateRepository? repo})
      : _repo = repo ?? CandidateRepository();

  List<Interview> get interviews => _interviews;
  bool get loading => _loading;
  String? get error => _error;
  String get filter => _filter;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _interviews = await _repo.fetchInterviews(filter: _filter);
    } catch (e) {
      if (!AuthExpiredHandler.instance.handleIfAuthError(e)) {
        _error = e.toString();
      }
    }
    _loading = false;
    notifyListeners();
  }

  void setFilter(String f) {
    _filter = f;
    load();
  }
}

// ══════════════════════════════════════════════════════════════
// Notifications
// ══════════════════════════════════════════════════════════════

class CandidateNotificationsProvider extends ChangeNotifier {
  List<NotificationItem> _notifications = [];
  bool _loading = true;
  String? _error;
  final CandidateRepository _repo;

  CandidateNotificationsProvider({CandidateRepository? repo})
      : _repo = repo ?? CandidateRepository();

  List<NotificationItem> get notifications => _notifications;
  bool get loading => _loading;
  String? get error => _error;
  int get unreadCount => _notifications.where((n) => !n.read).length;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _notifications = await _repo.fetchNotifications();
    } catch (e) {
      if (!AuthExpiredHandler.instance.handleIfAuthError(e)) {
        _error = e.toString();
      }
    }
    _loading = false;
    notifyListeners();
  }

  void markRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx >= 0) {
      _notifications[idx].read = true;
      notifyListeners();
    }
  }

  void markAllRead() {
    for (final n in _notifications) {
      n.read = true;
    }
    notifyListeners();
  }
}

class CandidateQuickPlugProvider extends ChangeNotifier {
  CandidateQuickPlugProvider({CandidateRepository? repo});

  List<QuickPlugLike> _pendingLikes = [];
  bool _loading = false;
  String? _error;

  List<QuickPlugLike> get pendingLikes => _pendingLikes;
  int get pendingCount => _pendingLikes.length;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    _pendingLikes = const [];
    _loading = false;
    notifyListeners();
  }

  Future<void> accept(String likeId) async {
    _pendingLikes = _pendingLikes.where((l) => l.id != likeId).toList();
    notifyListeners();
  }

  Future<void> reject(String likeId) async {
    _pendingLikes = _pendingLikes.where((l) => l.id != likeId).toList();
    notifyListeners();
  }
}
