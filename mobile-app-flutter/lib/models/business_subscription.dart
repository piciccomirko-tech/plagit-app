/// Typed business subscription / feature-gate model.
///
/// Centralises plan checks so business screens never compare raw strings.
library;

// -----------------------------------------
// BusinessSubscriptionPlan
// -----------------------------------------

/// Available business subscription tiers.
enum BusinessSubscriptionPlan {
  free,
  basic,
  pro,
  premium;

  /// Whether this plan grants premium features.
  bool get isPremium => this == premium;

  /// Human-readable label for UI display.
  String get displayName => switch (this) {
        free => 'Free',
        basic => 'Basic',
        pro => 'Pro',
        premium => 'Premium',
      };

  /// Parse a string into the enum value. Falls back to [free].
  static BusinessSubscriptionPlan fromString(String s) {
    final lower = s
        .toLowerCase()
        .replaceAll(RegExp(r'[\s_-]+'), '');
    return switch (lower) {
      'free' => free,
      'basic' => basic,
      'pro' => pro,
      'premium' => premium,
      'businessfree' => free,
      'businessbasic' => basic,
      'businesspro' => pro,
      'businesspremium' => premium,
      'starter' => basic,
      'trial' => basic,
      _ => free,
    };
  }
}

// -----------------------------------------
// BusinessSubscription
// -----------------------------------------

/// Holds the business's current subscription state and exposes feature gates.
class BusinessSubscription {
  final BusinessSubscriptionPlan plan;
  final String? startDate;
  final String? renewalDate;

  const BusinessSubscription({
    this.plan = BusinessSubscriptionPlan.free,
    this.startDate,
    this.renewalDate,
  });

  // -- Feature gates --

  /// Pro and Premium can use the QuickPlug swipe feature.
  bool get canUseQuickPlug =>
      plan.isPremium || plan == BusinessSubscriptionPlan.pro;

  /// Only Premium can feature/boost job listings.
  bool get canFeatureJobs => plan.isPremium;

  /// All paid plans get advanced candidate filters.
  bool get hasAdvancedFilters => plan != BusinessSubscriptionPlan.free;

  /// Only Premium gets unlimited job postings.
  bool get hasUnlimitedJobs => plan.isPremium;

  /// Daily swipe limit depends on plan tier.
  int get dailySwipeLimit => plan.isPremium
      ? 999
      : (plan == BusinessSubscriptionPlan.pro ? 20 : 5);

  // -- JSON serialisation --

  factory BusinessSubscription.fromJson(Map<String, dynamic> json) {
    String? stringOf(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value == null) continue;
        final text = value.toString().trim();
        if (text.isNotEmpty) return text;
      }
      return null;
    }

    String? nestedString(List<String> keys, List<String> nestedKeys) {
      for (final key in keys) {
        final value = json[key];
        if (value is! Map<String, dynamic>) continue;
        for (final nestedKey in nestedKeys) {
          final nestedValue = value[nestedKey];
          if (nestedValue == null) continue;
          final text = nestedValue.toString().trim();
          if (text.isNotEmpty) return text;
        }
      }
      return null;
    }

    final planName =
        stringOf(const ['plan', 'tier', 'subscriptionPlan', 'subscription_plan']) ??
        nestedString(
          const ['subscription', 'subscription_data', 'planData', 'plan_data'],
          const ['plan', 'tier', 'name', 'slug', 'id'],
        ) ??
        'free';

    return BusinessSubscription(
      plan: BusinessSubscriptionPlan.fromString(planName),
      startDate: stringOf(
        const [
          'startDate',
          'start_date',
          'startedAt',
          'started_at',
          'subscriptionStart',
          'subscription_start',
        ],
      ),
      renewalDate: stringOf(
        const [
          'renewalDate',
          'renewal_date',
          'renewsAt',
          'renews_at',
          'expiresAt',
          'expires_at',
          'currentPeriodEnd',
          'current_period_end',
        ],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'plan': plan.displayName,
        'startDate': startDate,
        'renewalDate': renewalDate,
      };

  // -- Mock factory --

  /// Returns a basic-tier subscription (matching MockData.business default).
  static BusinessSubscription mock() => const BusinessSubscription(
        plan: BusinessSubscriptionPlan.basic,
      );
}
