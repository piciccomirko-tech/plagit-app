/// Typed subscription / feature-gate model — mirrors Swift SubscriptionManager + FeatureGate.
///
/// Centralises plan checks so screens never compare raw strings.
library;

// ─────────────────────────────────────────────
// SubscriptionPlan
// ─────────────────────────────────────────────

/// Available candidate subscription tiers.
enum SubscriptionPlan {
  free,
  candidateMonthly,
  candidateAnnual;

  /// Whether this plan grants premium features.
  bool get isPremium => this != free;

  /// Human-readable label for UI display.
  String get displayName => switch (this) {
        free => 'Free',
        candidateMonthly => 'Premium Monthly',
        candidateAnnual => 'Premium Annual',
      };

  /// Billing-period label shown next to the plan name
  /// (e.g. in the dev panel readout).
  String get periodLabel => switch (this) {
        free => 'Free',
        candidateMonthly => 'Monthly',
        candidateAnnual => 'Annual',
      };

  /// Parse a string into the enum value. Falls back to [free].
  static SubscriptionPlan fromString(String s) {
    final lower = s.toLowerCase().replaceAll(' ', '');
    return switch (lower) {
      'free' => free,
      'candidatemonthly' || 'premiummonthly' => candidateMonthly,
      'candidateannual' || 'premiumannual' => candidateAnnual,
      'premium' => candidateMonthly, // default premium to monthly
      _ => free,
    };
  }
}

// ─────────────────────────────────────────────
// CandidateSubscription
// ─────────────────────────────────────────────

/// Holds the candidate's current subscription state and exposes feature gates.
class CandidateSubscription {
  final SubscriptionPlan plan;
  final String? startDate;
  final String? renewalDate;

  const CandidateSubscription({
    this.plan = SubscriptionPlan.free,
    this.startDate,
    this.renewalDate,
  });

  // ── Feature gates (mirror FeatureGate.swift) ──

  /// Premium users can apply to jobs with one tap.
  bool get canQuickApply => plan.isPremium;

  /// Premium users can boost their profile visibility.
  bool get canBoostProfile => plan.isPremium;

  /// Premium users get priority push notifications.
  bool get hasPriorityNotifications => plan.isPremium;

  /// Premium users can use advanced search filters.
  bool get hasAdvancedFilters => plan.isPremium;

  /// Premium users appear higher in business search results.
  bool get hasIncreasedVisibility => plan.isPremium;

  /// Parsed renewal date, or null when absent / unparseable.
  /// Accepts ISO 8601 strings produced by [toJson] / [forPlan].
  DateTime? get renewalDateParsed {
    final raw = renewalDate;
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  // ── JSON serialisation ──

  factory CandidateSubscription.fromJson(Map<String, dynamic> json) {
    return CandidateSubscription(
      plan: SubscriptionPlan.fromString(json['plan'] as String? ?? 'free'),
      startDate: json['startDate'] as String?,
      renewalDate: json['renewalDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'plan': plan.displayName,
        'startDate': startDate,
        'renewalDate': renewalDate,
      };

  // ── Mock factory ──

  /// Returns a free-tier subscription (same as current MockData default).
  static CandidateSubscription mock() => const CandidateSubscription();

  /// Build a subscription for [plan] with start = now and a renewal date
  /// matching the plan's billing period. Used by billing services right
  /// after a successful purchase / restore.
  factory CandidateSubscription.forPlan(SubscriptionPlan plan) {
    final now = DateTime.now();
    final renewal = switch (plan) {
      SubscriptionPlan.candidateAnnual =>
        DateTime(now.year + 1, now.month, now.day),
      SubscriptionPlan.candidateMonthly =>
        DateTime(now.year, now.month + 1, now.day),
      SubscriptionPlan.free => null,
    };
    return CandidateSubscription(
      plan: plan,
      startDate: now.toIso8601String(),
      renewalDate: renewal?.toIso8601String(),
    );
  }
}
