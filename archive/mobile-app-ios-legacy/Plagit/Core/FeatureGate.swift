//
//  FeatureGate.swift
//  Plagit
//
//  Centralized premium feature gating.
//  Business: Free → Basic → Pro → Premium
//  Candidate: Free → Premium
//

import Foundation

enum FeatureGate {

    private static var sub: SubscriptionManager { .shared }

    // MARK: - Candidate Premium Features

    static var canUseAdvancedFilters: Bool { sub.isSubscribed }
    static var hasPriorityNotifications: Bool { sub.isCandidatePremium }
    static var hasImprovedVisibility: Bool { sub.isCandidatePremium }
    static var hasPremiumBadge: Bool { sub.isSubscribed }
    static var hasEarlyAccess: Bool { sub.isCandidatePremium }

    // MARK: - Business Tier Features

    // Basic+
    static var hasBusinessDashboard: Bool { sub.businessTier >= .basic }
    static var hasBasicFilters: Bool { sub.businessTier >= .basic }
    static var hasImprovedJobVisibility: Bool { sub.businessTier >= .basic }

    // Pro+
    static var hasUnlimitedJobPosts: Bool { sub.businessTier >= .pro }
    static var hasUnlimitedContacts: Bool { sub.businessTier >= .pro }
    static var hasBusinessAdvancedFilters: Bool { sub.businessTier >= .pro }
    static var hasAnalytics: Bool { sub.businessTier >= .pro }
    static var hasShortlistTools: Bool { sub.businessTier >= .pro }
    static var hasInterviewScheduling: Bool { sub.businessTier >= .pro }
    static var hasFullApplicantAccess: Bool { sub.businessTier >= .pro }

    // Premium only
    static var canFeatureJobs: Bool { sub.businessTier >= .premium }
    static var hasTopPlacement: Bool { sub.businessTier >= .premium }
    static var hasPriorityJobVisibility: Bool { sub.businessTier >= .premium }
    static var hasBusinessPremiumBadge: Bool { sub.businessTier >= .premium }
    static var hasAdvancedAnalytics: Bool { sub.businessTier >= .premium }
    static var hasFullPostInsights: Bool { sub.businessTier >= .premium }
    static var hasCommunityBoost: Bool { sub.businessTier >= .premium }
    static var hasPriorityCandidateAccess: Bool { sub.businessTier >= .premium }

    // MARK: - Business Tier Limits

    /// Active job post limit by tier
    static var jobPostLimit: Int {
        switch sub.businessTier {
        case .none:    return 1
        case .basic:   return 3
        case .pro:     return 10
        case .premium: return .max
        }
    }

    /// Monthly candidate contact/message limit by tier
    static var contactLimit: Int {
        switch sub.businessTier {
        case .none:    return 5
        case .basic:   return 15
        case .pro:     return 50
        case .premium: return .max
        }
    }

    /// Applicant views per job per month
    static var applicantViewLimit: Int {
        switch sub.businessTier {
        case .none:    return 5
        case .basic:   return 20
        case .pro:     return .max
        case .premium: return .max
        }
    }

    // MARK: - Service Provider Tier Features

    // Basic+
    static var hasServiceProfile: Bool { sub.currentPlan.serviceTier >= .basic }
    static var hasServiceBadge: Bool { sub.currentPlan.serviceTier >= .basic }
    static var hasServiceBasicVisibility: Bool { sub.currentPlan.serviceTier >= .basic }

    // Pro+
    static var hasServiceFeaturedPlacement: Bool { sub.currentPlan.serviceTier >= .pro }
    static var hasServiceAdvancedAnalytics: Bool { sub.currentPlan.serviceTier >= .pro }
    static var hasServiceUnlimitedPosts: Bool { sub.currentPlan.serviceTier >= .pro }
    static var hasServiceUnlimitedContacts: Bool { sub.currentPlan.serviceTier >= .pro }
    static var hasServicePriorityListing: Bool { sub.currentPlan.serviceTier >= .pro }

    // Premium only
    static var hasServicePremiumBadge: Bool { sub.currentPlan.serviceTier >= .premium }
    static var hasServiceTopPlacement: Bool { sub.currentPlan.serviceTier >= .premium }
    static var hasServiceFeedBoost: Bool { sub.currentPlan.serviceTier >= .premium }
    static var hasServiceFullAnalytics: Bool { sub.currentPlan.serviceTier >= .premium }

    // MARK: - Service Provider Limits

    /// Service feed posts limit by tier
    static var servicePostLimit: Int {
        switch sub.currentPlan.serviceTier {
        case .none:    return 2
        case .basic:   return 10
        case .pro:     return 50
        case .premium: return .max
        }
    }

    /// Monthly contact/message limit for service providers
    static var serviceContactLimit: Int {
        switch sub.currentPlan.serviceTier {
        case .none:    return 5
        case .basic:   return 20
        case .pro:     return 100
        case .premium: return .max
        }
    }

    // MARK: - Helpers

    static var isPremium: Bool { sub.isSubscribed }
    static var planDisplayName: String { sub.currentPlan.displayName }

    /// Minimum service tier for a feature
    static func requiredServiceTier(for feature: ServiceFeature) -> SubscriptionPlan.ServiceTier {
        switch feature {
        case .serviceProfile, .serviceBadge, .basicVisibility:
            return .basic
        case .featuredPlacement, .advancedServiceAnalytics, .unlimitedServicePosts,
             .unlimitedServiceContacts, .priorityListing:
            return .pro
        case .premiumServiceBadge, .topServicePlacement, .feedBoost, .fullServiceAnalytics:
            return .premium
        }
    }

    /// Human-readable service tier name
    static func serviceTierName(_ tier: SubscriptionPlan.ServiceTier) -> String {
        switch tier {
        case .none: return "Free"
        case .basic: return "Basic"
        case .pro: return "Pro"
        case .premium: return "Premium"
        }
    }

    /// The minimum tier required to use a feature — for upgrade prompts
    static func requiredTier(for feature: BusinessFeature) -> SubscriptionPlan.BusinessTier {
        switch feature {
        case .moreJobPosts, .moreContacts, .basicFilters, .improvedVisibility:
            return .basic
        case .unlimitedJobs, .unlimitedContacts, .advancedFilters, .analytics,
             .shortlist, .interviewScheduling, .fullApplicantAccess:
            return .pro
        case .featuredJobs, .topPlacement, .premiumBadge, .advancedAnalytics,
             .fullInsights, .communityBoost, .priorityCandidates:
            return .premium
        }
    }

    /// Human-readable tier name
    static func tierName(_ tier: SubscriptionPlan.BusinessTier) -> String {
        switch tier {
        case .none: return "Free"
        case .basic: return "Basic"
        case .pro: return "Pro"
        case .premium: return "Premium"
        }
    }
}

// MARK: - Business Feature Enum (for upgrade prompts)

enum BusinessFeature: String {
    // Basic+
    case moreJobPosts, moreContacts, basicFilters, improvedVisibility
    // Pro+
    case unlimitedJobs, unlimitedContacts, advancedFilters, analytics
    case shortlist, interviewScheduling, fullApplicantAccess
    // Premium
    case featuredJobs, topPlacement, premiumBadge, advancedAnalytics
    case fullInsights, communityBoost, priorityCandidates

    var label: String {
        switch self {
        case .moreJobPosts: return "More Job Posts"
        case .moreContacts: return "More Candidate Contacts"
        case .basicFilters: return "Basic Filters"
        case .improvedVisibility: return "Improved Job Visibility"
        case .unlimitedJobs: return "Unlimited Job Posts"
        case .unlimitedContacts: return "Unlimited Contacts"
        case .advancedFilters: return "Advanced Filters"
        case .analytics: return "Hiring Analytics"
        case .shortlist: return "Shortlist Tools"
        case .interviewScheduling: return "Interview Scheduling"
        case .fullApplicantAccess: return "Full Applicant Access"
        case .featuredJobs: return "Featured Job Listings"
        case .topPlacement: return "Top Placement"
        case .premiumBadge: return "Premium Business Badge"
        case .advancedAnalytics: return "Advanced Analytics"
        case .fullInsights: return "Full Post Insights"
        case .communityBoost: return "Community Content Boost"
        case .priorityCandidates: return "Priority Candidate Access"
        }
    }

    var icon: String {
        switch self {
        case .moreJobPosts, .unlimitedJobs: return "briefcase.fill"
        case .moreContacts, .unlimitedContacts: return "person.2.fill"
        case .basicFilters, .advancedFilters: return "slider.horizontal.3"
        case .improvedVisibility, .topPlacement: return "arrow.up.circle.fill"
        case .analytics, .advancedAnalytics: return "chart.bar.fill"
        case .shortlist: return "star.fill"
        case .interviewScheduling: return "calendar.badge.plus"
        case .fullApplicantAccess: return "person.badge.plus"
        case .featuredJobs: return "sparkles"
        case .premiumBadge: return "crown.fill"
        case .fullInsights: return "eye.fill"
        case .communityBoost: return "bolt.fill"
        case .priorityCandidates: return "person.fill.checkmark"
        }
    }
}

// MARK: - Service Feature Enum (for upgrade prompts)

enum ServiceFeature: String {
    // Basic+
    case serviceProfile, serviceBadge, basicVisibility
    // Pro+
    case featuredPlacement, advancedServiceAnalytics, unlimitedServicePosts
    case unlimitedServiceContacts, priorityListing
    // Premium
    case premiumServiceBadge, topServicePlacement, feedBoost, fullServiceAnalytics

    var label: String {
        switch self {
        case .serviceProfile: return "Enhanced Profile"
        case .serviceBadge: return "Verified Badge"
        case .basicVisibility: return "Improved Visibility"
        case .featuredPlacement: return "Featured Placement"
        case .advancedServiceAnalytics: return "Advanced Analytics"
        case .unlimitedServicePosts: return "Unlimited Posts"
        case .unlimitedServiceContacts: return "Unlimited Contacts"
        case .priorityListing: return "Priority Listing"
        case .premiumServiceBadge: return "Premium Badge"
        case .topServicePlacement: return "Top Placement"
        case .feedBoost: return "Feed Boost"
        case .fullServiceAnalytics: return "Full Analytics"
        }
    }

    var icon: String {
        switch self {
        case .serviceProfile: return "person.crop.rectangle"
        case .serviceBadge: return "checkmark.seal.fill"
        case .basicVisibility: return "arrow.up.circle.fill"
        case .featuredPlacement: return "sparkles"
        case .advancedServiceAnalytics, .fullServiceAnalytics: return "chart.bar.fill"
        case .unlimitedServicePosts: return "doc.text.fill"
        case .unlimitedServiceContacts: return "person.2.fill"
        case .priorityListing: return "list.star"
        case .premiumServiceBadge: return "crown.fill"
        case .topServicePlacement: return "arrow.up.circle.fill"
        case .feedBoost: return "bolt.fill"
        }
    }
}
