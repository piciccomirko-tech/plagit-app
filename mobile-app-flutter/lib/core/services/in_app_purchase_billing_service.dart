/// Real `in_app_purchase`-backed billing service.
///
/// This is the production-path billing service. It handles **restore**
/// through the canonical Flutter pattern:
///
///   1. `InAppPurchase.instance.restorePurchases()` kicks off the
///      restore operation — it returns void; results do NOT arrive
///      from that call.
///   2. Results arrive asynchronously through the global
///      `purchaseStream` as `PurchaseDetails` objects with
///      `PurchaseStatus.restored`.
///   3. We subscribe to that stream once at construction, collect
///      restored purchases in an in-flight buffer, and resolve the
///      restore with the outcome after a short "quiet period" (1.5s
///      of no new events) or a hard timeout (6s).
///   4. Restored purchases that carry `pendingCompletePurchase` MUST
///      be completed via `completePurchase` — otherwise StoreKit
///      will keep replaying them on every subsequent restore.
///
/// **Purchase** is delegated to a fallback `MockBillingService`. The
/// user explicitly asked to fix only the restore logic in this pass,
/// and the mock purchase flow is still the path the UI currently
/// exercises in dev. When real products are wired up on the store
/// side, the purchase method can be swapped to call
/// `InAppPurchase.instance.buyNonConsumable(...)` without touching
/// the UI or the provider.
library;

import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:plagit/core/services/billing_service.dart';
import 'package:plagit/models/subscription_state.dart';

class InAppPurchaseBillingService implements BillingService {
  InAppPurchaseBillingService({BillingService? purchaseFallback})
      : _purchaseFallback = purchaseFallback ?? MockBillingService() {
    _streamSubscription = _iap.purchaseStream.listen(
      _onPurchaseStreamUpdate,
      onError: (Object error) {
        // If we're awaiting a restore, surface the error.
        final completer = _restoreCompleter;
        if (completer != null && !completer.isCompleted) {
          completer.complete(RestoreError('Purchase stream error: $error'));
        }
      },
    );
  }

  final InAppPurchase _iap = InAppPurchase.instance;
  final BillingService _purchaseFallback;

  /// Product IDs this service recognises as Candidate Premium. Kept in
  /// sync with the StoreKit configuration files used by the project
  /// (the current active one uses `plagit.candidate.premium.*`, the
  /// legacy one used `com.plagit.candidate.*`).
  static const Set<String> _premiumAnnualIds = {
    'plagit.candidate.premium.annual',
    'com.plagit.candidate.annual',
  };
  static const Set<String> _premiumMonthlyIds = {
    'plagit.candidate.premium.monthly',
    'com.plagit.candidate.monthly',
  };
  static Set<String> get allKnownPremiumIds =>
      _premiumAnnualIds.union(_premiumMonthlyIds);

  // ── Restore state ──
  StreamSubscription<List<PurchaseDetails>>? _streamSubscription;
  Completer<RestoreResult>? _restoreCompleter;
  final List<PurchaseDetails> _restoredBuffer = <PurchaseDetails>[];
  Timer? _quietPeriodTimer;
  Timer? _hardTimeoutTimer;

  /// Quiet-period threshold — once this much time has passed without
  /// any new `restored` events, we assume the restore is done.
  static const Duration _quietPeriod = Duration(milliseconds: 1500);

  /// Absolute upper bound on a restore operation. Guarantees the
  /// completer resolves even if no events arrive at all.
  static const Duration _hardTimeout = Duration(seconds: 6);

  /// Releases the stream listener. Called when the provider owning
  /// this service is disposed (rare — providers at app root are
  /// typically never disposed).
  void dispose() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    _quietPeriodTimer?.cancel();
    _hardTimeoutTimer?.cancel();
  }

  // ─────────────────────────────────────────────
  // PurchaseStream handling
  // ─────────────────────────────────────────────

  void _onPurchaseStreamUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.restored:
          _restoredBuffer.add(purchase);
          // Restored purchases MUST be completed so StoreKit doesn't
          // replay them on every subsequent restore.
          if (purchase.pendingCompletePurchase) {
            _iap.completePurchase(purchase);
          }
          _bumpQuietPeriod();

        case PurchaseStatus.error:
          final completer = _restoreCompleter;
          if (completer != null && !completer.isCompleted) {
            final msg = purchase.error?.message ?? 'Restore failed';
            completer.complete(RestoreError(msg));
            _cleanupRestoreTimers();
          }
          if (purchase.pendingCompletePurchase) {
            _iap.completePurchase(purchase);
          }

        case PurchaseStatus.purchased:
        case PurchaseStatus.pending:
        case PurchaseStatus.canceled:
          // Not part of the restore flow. Still complete any pending
          // purchases so the store queue stays clean.
          if (purchase.pendingCompletePurchase) {
            _iap.completePurchase(purchase);
          }
      }
    }
  }

  /// Bumps the "quiet period" timer each time a new restored purchase
  /// arrives. When no new events fire for [_quietPeriod], the restore
  /// is considered complete and is finalised.
  void _bumpQuietPeriod() {
    _quietPeriodTimer?.cancel();
    _quietPeriodTimer = Timer(_quietPeriod, _finaliseRestore);
  }

  void _finaliseRestore() {
    final completer = _restoreCompleter;
    if (completer == null || completer.isCompleted) return;

    if (_restoredBuffer.isEmpty) {
      completer.complete(const RestoreNothingFound());
      _cleanupRestoreTimers();
      return;
    }

    // Pick the best tier: annual wins over monthly.
    final hasAnnual = _restoredBuffer.any(
      (p) => _premiumAnnualIds.contains(p.productID),
    );
    final hasMonthly = _restoredBuffer.any(
      (p) => _premiumMonthlyIds.contains(p.productID),
    );

    if (!hasAnnual && !hasMonthly) {
      // Restored purchases exist but none are Candidate Premium
      // (e.g., a different subscription on the account).
      completer.complete(const RestoreNothingFound());
      _cleanupRestoreTimers();
      return;
    }

    final plan = hasAnnual
        ? SubscriptionPlan.candidateAnnual
        : SubscriptionPlan.candidateMonthly;
    completer.complete(
      RestoreSuccess(CandidateSubscription.forPlan(plan)),
    );
    _cleanupRestoreTimers();
  }

  void _cleanupRestoreTimers() {
    _quietPeriodTimer?.cancel();
    _quietPeriodTimer = null;
    _hardTimeoutTimer?.cancel();
    _hardTimeoutTimer = null;
  }

  // ─────────────────────────────────────────────
  // BillingService interface
  // ─────────────────────────────────────────────

  @override
  Future<PurchaseResult> purchase(SubscriptionPlan plan) {
    // Delegated to the mock purchase backend. Swap this to
    // `_iap.buyNonConsumable(purchaseParam: ...)` when real products
    // are configured in the store, then use the purchaseStream to
    // resolve the result (same pattern as restore).
    return _purchaseFallback.purchase(plan);
  }

  @override
  Future<RestoreResult> restore() async {
    // 1. Availability check — in_app_purchase can be unavailable on
    //    simulators without StoreKit config, desktop builds, etc.
    bool available;
    try {
      available = await _iap.isAvailable();
    } catch (e) {
      return RestoreError('Could not reach the store. $e');
    }
    if (!available) {
      return const RestoreError('In-app purchases are not available on this device.');
    }

    // 2. Reset the restore buffer and completer for this attempt.
    _restoredBuffer.clear();
    _cleanupRestoreTimers();
    final completer = Completer<RestoreResult>();
    _restoreCompleter = completer;

    // 3. Kick off the real StoreKit / Google Play restore. Results
    //    come back via the purchaseStream listener above, NOT as a
    //    return value.
    try {
      await _iap.restorePurchases();
    } catch (e) {
      if (!completer.isCompleted) {
        completer.complete(RestoreError('Restore failed: $e'));
      }
      _cleanupRestoreTimers();
      _restoreCompleter = null;
      return completer.future;
    }

    // 4. Start the hard timeout. If no events ever arrive (common on
    //    a simulator without StoreKit config, or an account with no
    //    prior purchases), this guarantees the completer resolves.
    _hardTimeoutTimer = Timer(_hardTimeout, _finaliseRestore);
    // Also start a quiet-period countdown — if we never receive even
    // one event, the quiet timer is a no-op and the hard timeout
    // takes over.
    _bumpQuietPeriod();

    final result = await completer.future;
    _restoreCompleter = null;
    _cleanupRestoreTimers();
    return result;
  }
}
