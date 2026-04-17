/// Billing service abstraction.
///
/// Sits between the UI/provider layer and whichever billing backend is
/// active. The UI never calls StoreKit / Google Billing / `in_app_purchase`
/// directly — it goes through this interface. That means:
///
///   • The same UI code works for mock purchases (today) and real
///     purchases (later) with zero changes.
///   • Swapping the real implementation in only requires registering a
///     different `BillingService` in the provider constructor.
///
/// Until a real billing backend is wired, the default implementation is
/// [MockBillingService] which simulates the full purchase / cancel /
/// restore flow locally.
library;

import 'package:plagit/models/subscription_state.dart';

// ─────────────────────────────────────────────
// Result types
// ─────────────────────────────────────────────

/// Outcome of a purchase or restore call.
sealed class PurchaseResult {
  const PurchaseResult();
}

/// Purchase completed — the user now holds an active subscription.
class PurchaseSuccess extends PurchaseResult {
  final CandidateSubscription subscription;
  const PurchaseSuccess(this.subscription);
}

/// User dismissed the purchase sheet / tapped cancel. No state change.
class PurchaseCancelled extends PurchaseResult {
  const PurchaseCancelled();
}

/// Billing reported an error (network, declined card, store unavailable).
class PurchaseError extends PurchaseResult {
  final String message;
  const PurchaseError(this.message);
}

/// Outcome of a restore call.
sealed class RestoreResult {
  const RestoreResult();
}

/// Restore found a previously-purchased active subscription.
class RestoreSuccess extends RestoreResult {
  final CandidateSubscription subscription;
  const RestoreSuccess(this.subscription);
}

/// Restore completed but found nothing to restore, and the client
/// wasn't claiming premium anyway (normal "no-op" outcome).
class RestoreNothingFound extends RestoreResult {
  const RestoreNothingFound();
}

/// Restore completed, found nothing valid, AND the client was
/// previously in a premium state that has now been revoked. Distinct
/// from [RestoreNothingFound] so the UI can explain the state change
/// ("your premium access was removed because no valid subscription
/// was found").
class RestoreRevoked extends RestoreResult {
  const RestoreRevoked();
}

/// Restore failed (network, sync error, etc.).
class RestoreError extends RestoreResult {
  final String message;
  const RestoreError(this.message);
}

// ─────────────────────────────────────────────
// Interface
// ─────────────────────────────────────────────

/// Abstract billing interface. Implement this to plug in a real billing
/// backend (StoreKit via `in_app_purchase`, Google Play, RevenueCat, etc.).
abstract class BillingService {
  /// Attempt to purchase [plan]. Must be one of the premium plans —
  /// passing [SubscriptionPlan.free] is a programmer error.
  Future<PurchaseResult> purchase(SubscriptionPlan plan);

  /// Attempt to restore any previously-purchased subscription.
  Future<RestoreResult> restore();
}

// ─────────────────────────────────────────────
// Mock implementation
// ─────────────────────────────────────────────

/// In-memory / simulated billing. Used until a real billing backend is
/// wired. Simulates a ~700ms purchase sheet and always succeeds. Cancel
/// is surfaced by the UI layer (confirmation dialog) — the mock itself
/// does not randomly cancel.
///
/// Restore is driven by **two** caches, in priority order:
///
/// 1. **One-shot cache** ([primeOneShotRestore]) — consumed on the
///    next `restore()` call and immediately cleared. Used by the
///    dev panel's "Restore Success" action so a single tap simulates
///    a one-time restore, and subsequent taps don't keep resurrecting
///    the same entitlement.
/// 2. **Persistent cache** ([primeLastPurchase]) — survives multiple
///    restore calls. Used by the normal purchase flow: when
///    `purchase()` completes, the purchased subscription stays in
///    the cache so cross-session restores keep finding it until
///    explicitly cleared.
class MockBillingService implements BillingService {
  CandidateSubscription? _lastPurchased;
  CandidateSubscription? _oneShotRestore;

  /// Seed the persistent cache. Set by `purchase()` on success and by
  /// the provider's `devActivatePremium()`. Cleared by the provider's
  /// `devDeactivatePremium()` and `devSimulateRestoreNothing()`.
  void primeLastPurchase(CandidateSubscription? subscription) {
    _lastPurchased = subscription;
  }

  /// Seed a **one-shot** restore outcome. The next call to `restore()`
  /// will return this subscription as `RestoreSuccess` and immediately
  /// clear the cache, so the subsequent call returns `RestoreNothingFound`
  /// (unless the persistent cache holds something too).
  void primeOneShotRestore(CandidateSubscription? subscription) {
    _oneShotRestore = subscription;
  }

  @override
  Future<PurchaseResult> purchase(SubscriptionPlan plan) async {
    assert(plan.isPremium, 'Cannot purchase the free plan');
    // Simulate the StoreKit / Google Play purchase sheet round-trip.
    await Future.delayed(const Duration(milliseconds: 700));
    final subscription = CandidateSubscription.forPlan(plan);
    _lastPurchased = subscription;
    return PurchaseSuccess(subscription);
  }

  @override
  Future<RestoreResult> restore() async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Check the one-shot cache first. Consume it regardless of
    // outcome so the next restore is independent.
    final oneShot = _oneShotRestore;
    if (oneShot != null) {
      _oneShotRestore = null;
      if (oneShot.plan.isPremium) {
        return RestoreSuccess(oneShot);
      }
      return const RestoreNothingFound();
    }

    // Fall back to the persistent cache.
    final last = _lastPurchased;
    if (last == null || !last.plan.isPremium) {
      return const RestoreNothingFound();
    }
    return RestoreSuccess(last);
  }
}
