/// ChangeNotifier providers for all candidate-side state.
///
/// Mirrors the Swift @Observable pattern — each provider owns a domain
/// slice (auth, home, jobs, applications, messages, interviews) and
/// exposes a three-state pattern: loading -> error (with retry) -> content.
library;

import 'package:flutter/material.dart';
import 'package:plagit/models/application.dart';
import 'package:plagit/models/candidate_home_data.dart';
import 'package:plagit/models/candidate_profile.dart';
import 'package:plagit/models/conversation.dart';
import 'package:plagit/models/interview.dart';
import 'package:plagit/models/job.dart';
import 'package:plagit/models/notification_item.dart';
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
      _error = e.toString();
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
      _error = e.toString();
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
      _error = e.toString();
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
      _error = e.toString();
    }
    _loading = false;
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
      _error = e.toString();
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
      _error = e.toString();
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
