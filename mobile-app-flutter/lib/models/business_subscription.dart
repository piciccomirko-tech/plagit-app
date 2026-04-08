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
    final lower = s.toLowerCase().replaceAll(' ', '');
    return switch (lower) {
      'free' => free,
      'basic' => basic,
      'pro' => pro,
      'premium' => premium,
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
    return BusinessSubscription(
      plan: BusinessSubscriptionPlan.fromString(
          json['plan'] as String? ?? 'free'),
      startDate: json['startDate'] as String?,
      renewalDate: json['renewalDate'] as String?,
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
