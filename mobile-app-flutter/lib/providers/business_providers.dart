/// ChangeNotifier providers for all business-side state.
///
/// Mirrors the Swift @Observable pattern — each provider owns a domain
/// slice (auth, home, jobs, applicants, messages, interviews, quickplug)
/// and exposes a three-state pattern: loading -> error (with retry) -> content.
library;

import 'package:flutter/material.dart';
import 'package:plagit/core/services/auth_expired_handler.dart';
import 'package:plagit/models/applicant.dart';
import 'package:plagit/models/business_conversation.dart';
import 'package:plagit/models/business_home_data.dart';
import 'package:plagit/models/business_interview.dart';
import 'package:plagit/models/business_job.dart';
import 'package:plagit/models/business_profile.dart';
import 'package:plagit/models/business_subscription.dart';
import 'package:plagit/models/notification_item.dart';
import 'package:plagit/models/quick_plug_candidate.dart';
import 'package:plagit/repositories/business_repository.dart';
import 'package:plagit/repositories/auth_repository.dart';

// ================================================================
// Auth — mirrors BusinessAuthService @Observable
// ================================================================

class BusinessAuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isRestoring = true;
  BusinessProfile? _profile;
  BusinessSubscription _subscription = BusinessSubscription.mock();
  final BusinessRepository _repo;
  final AuthRepository _authRepo;

  BusinessAuthProvider({BusinessRepository? repo, AuthRepository? authRepo})
      : _repo = repo ?? BusinessRepository(),
        _authRepo = authRepo ?? AuthRepository();

  bool get isAuthenticated => _isAuthenticated;
  bool get isRestoring => _isRestoring;
  BusinessProfile? get profile => _profile;
  BusinessSubscription get subscription => _subscription;

  /// Login via AuthRepository. Persists token, loads profile.
  Future<void> login(String email, String password) async {
    final result = await _authRepo.login(email: email, password: password);
    if (result.role != 'business') {
      throw Exception('Not a business account');
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
      if (result != null && result.role == 'business') {
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
    _subscription = BusinessSubscription.mock();
    notifyListeners();
  }

  /// Refresh profile from the repository.
  Future<void> refreshProfile() async {
    _profile = await _repo.fetchProfile();
    _subscription = await _repo.fetchSubscription();
    notifyListeners();
  }
}

// ================================================================
// Home dashboard
// ================================================================

class BusinessHomeProvider extends ChangeNotifier {
  BusinessHomeData? _data;
  bool _loading = true;
  String? _error;
  final BusinessRepository _repo;

  BusinessHomeProvider({BusinessRepository? repo})
      : _repo = repo ?? BusinessRepository();

  BusinessHomeData? get data => _data;
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

// ================================================================
// Jobs — filter by status, post job
// ================================================================

class BusinessJobsProvider extends ChangeNotifier {
  List<BusinessJob> _jobs = [];
  bool _loading = true;
  String? _error;
  String _filter = 'All';
  final BusinessRepository _repo;

  BusinessJobsProvider({BusinessRepository? repo})
      : _repo = repo ?? BusinessRepository();

  List<BusinessJob> get jobs => _jobs;
  bool get loading => _loading;
  String? get error => _error;
  String get filter => _filter;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _jobs = await _repo.fetchJobs(filter: _filter);
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

  Future<void> postJob(Map<String, dynamic> data) async {
    await _repo.postJob(data);
    // Reload jobs to reflect the new listing.
    await load();
  }
}

// ================================================================
// Applicants — filter by status, quick actions
// ================================================================

class BusinessApplicantsProvider extends ChangeNotifier {
  List<Applicant> _applicants = [];
  bool _loading = true;
  String? _error;
  String _filter = 'All';
  String? _jobId;
  final BusinessRepository _repo;

  BusinessApplicantsProvider({BusinessRepository? repo})
      : _repo = repo ?? BusinessRepository();

  List<Applicant> get applicants => _applicants;
  bool get loading => _loading;
  String? get error => _error;
  String get filter => _filter;
  String? get jobId => _jobId;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _applicants = await _repo.fetchApplicants(
        jobId: _jobId,
        statusFilter: _filter,
      );
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

  void setJobId(String? id) {
    _jobId = id;
    load();
  }

  /// Shortlist an applicant (optimistic UI update).
  void shortlist(String applicantId) {
    final idx = _applicants.indexWhere((a) => a.id == applicantId);
    if (idx >= 0) {
      final old = _applicants[idx];
      _applicants[idx] = Applicant(
        id: old.id,
        name: old.name,
        initials: old.initials,
        role: old.role,
        jobId: old.jobId,
        status: ApplicantStatus.shortlisted,
        date: old.date,
        experience: old.experience,
        location: old.location,
        verified: old.verified,
        bio: old.bio,
        languages: old.languages,
        availability: old.availability,
        salaryExpectation: old.salaryExpectation,
        interviewDate: old.interviewDate,
        interviewType: old.interviewType,
      );
      notifyListeners();
    }
    // TODO: _repo.updateApplicantStatus(applicantId, 'Shortlisted');
  }

  /// Reject an applicant (optimistic UI update).
  void reject(String applicantId) {
    final idx = _applicants.indexWhere((a) => a.id == applicantId);
    if (idx >= 0) {
      final old = _applicants[idx];
      _applicants[idx] = Applicant(
        id: old.id,
        name: old.name,
        initials: old.initials,
        role: old.role,
        jobId: old.jobId,
        status: ApplicantStatus.rejected,
        date: old.date,
        experience: old.experience,
        location: old.location,
        verified: old.verified,
        bio: old.bio,
        languages: old.languages,
        availability: old.availability,
        salaryExpectation: old.salaryExpectation,
        interviewDate: old.interviewDate,
        interviewType: old.interviewType,
      );
      notifyListeners();
    }
    // TODO: _repo.updateApplicantStatus(applicantId, 'Rejected');
  }
}

// ================================================================
// Messages / Conversations
// ================================================================

class BusinessMessagesProvider extends ChangeNotifier {
  List<BusinessConversation> _conversations = [];
  bool _loading = true;
  String? _error;
  final BusinessRepository _repo;

  BusinessMessagesProvider({BusinessRepository? repo})
      : _repo = repo ?? BusinessRepository();

  List<BusinessConversation> get conversations => _conversations;
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
}

// ================================================================
// Interviews — filter, schedule
// ================================================================

class BusinessInterviewsProvider extends ChangeNotifier {
  List<BusinessInterview> _interviews = [];
  bool _loading = true;
  String? _error;
  String _filter = 'All';
  final BusinessRepository _repo;

  BusinessInterviewsProvider({BusinessRepository? repo})
      : _repo = repo ?? BusinessRepository();

  List<BusinessInterview> get interviews => _interviews;
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

  Future<void> scheduleInterview(Map<String, dynamic> data) async {
    await _repo.scheduleInterview(data);
    // Reload to reflect the new interview.
    await load();
  }
}

// ================================================================
// QuickPlug — deck, swipe, usage tracking
// ================================================================

class BusinessQuickPlugProvider extends ChangeNotifier {
  List<QuickPlugCandidate> _deck = [];
  int _currentIndex = 0;
  int _swipesUsed = 0;
  bool _loading = true;
  String? _error;
  bool _showUpgrade = false;
  final BusinessRepository _repo;

  /// The daily swipe limit — injected from subscription state.
  int _dailyLimit = 5;

  BusinessQuickPlugProvider({BusinessRepository? repo})
      : _repo = repo ?? BusinessRepository();

  List<QuickPlugCandidate> get deck => _deck;
  int get currentIndex => _currentIndex;
  int get swipesUsed => _swipesUsed;
  bool get loading => _loading;
  String? get error => _error;
  bool get showUpgrade => _showUpgrade;
  int get swipesRemaining => (_dailyLimit - _swipesUsed).clamp(0, _dailyLimit);
  bool get hasCards => _currentIndex < _deck.length;
  QuickPlugCandidate? get currentCard =>
      hasCards ? _deck[_currentIndex] : null;

  /// Set the daily swipe limit (call when subscription changes).
  void setDailyLimit(int limit) {
    _dailyLimit = limit;
    _showUpgrade = _swipesUsed >= _dailyLimit;
    notifyListeners();
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    _currentIndex = 0;
    _swipesUsed = 0;
    _showUpgrade = false;
    notifyListeners();
    try {
      _deck = await _repo.fetchQuickPlugDeck();
    } catch (e) {
      if (!AuthExpiredHandler.instance.handleIfAuthError(e)) {
        _error = e.toString();
      }
    }
    _loading = false;
    notifyListeners();
  }

  /// Swipe on the current candidate.
  Future<void> swipe(bool interested) async {
    if (!hasCards) return;

    if (_swipesUsed >= _dailyLimit) {
      _showUpgrade = true;
      notifyListeners();
      return;
    }

    final candidate = _deck[_currentIndex];
    _currentIndex++;
    _swipesUsed++;
    _showUpgrade = _swipesUsed >= _dailyLimit;
    notifyListeners();

    // Fire-and-forget to backend.
    _repo.swipeCandidate(candidate.id, interested);
  }
}

// ================================================================
// Notifications
// ================================================================

class BusinessNotificationsProvider extends ChangeNotifier {
  List<NotificationItem> _notifications = [];
  bool _loading = true;
  String? _error;
  final BusinessRepository _repo;

  BusinessNotificationsProvider({BusinessRepository? repo})
      : _repo = repo ?? BusinessRepository();

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
