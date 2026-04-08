import 'package:plagit/models/subscription_state.dart';
import 'package:plagit/models/business_subscription.dart';

/// Centralized feature gate checks for premium features.
/// Wraps model-level booleans into a clean API.
class EntitlementService {
  // ── Candidate gates ──
  static bool canBoostProfile(CandidateSubscription sub) => sub.canBoostProfile;
  static bool canQuickApply(CandidateSubscription sub) => sub.canQuickApply;
  static bool hasPriorityNotifications(CandidateSubscription sub) => sub.hasPriorityNotifications;
  static bool hasAdvancedFilters(CandidateSubscription sub) => sub.hasAdvancedFilters;
  static bool hasIncreasedVisibility(CandidateSubscription sub) => sub.hasIncreasedVisibility;
  static bool isCandidatePremium(CandidateSubscription sub) => sub.plan.isPremium;

  // ── Business gates ──
  static bool canUseQuickPlug(BusinessSubscription sub) => sub.canUseQuickPlug;
  static bool canFeatureJobs(BusinessSubscription sub) => sub.canFeatureJobs;
  static bool hasBusinessAdvancedFilters(BusinessSubscription sub) => sub.hasAdvancedFilters;
  static bool hasUnlimitedJobs(BusinessSubscription sub) => sub.hasUnlimitedJobs;
  static int dailySwipeLimit(BusinessSubscription sub) => sub.dailySwipeLimit;
  static bool isBusinessPremium(BusinessSubscription sub) => sub.plan.isPremium;

  // ── Generic ──
  static String candidatePlanName(CandidateSubscription sub) => sub.plan.displayName;
  static String businessPlanName(BusinessSubscription sub) => sub.plan.displayName;
}
