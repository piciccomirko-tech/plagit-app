//
//  BusinessUpgradePrompt.swift
//  Plagit
//
//  Reusable upgrade prompt for gated business features.
//  Shows inline or as an overlay when a business hits a plan limit.
//

import SwiftUI

// MARK: - Inline Upgrade Banner

/// Compact banner shown inline when a feature is locked.
/// Usage: `BusinessUpgradeBanner(feature: .advancedFilters, showSubscription: $showSub)`
struct BusinessUpgradeBanner: View {
    let feature: BusinessFeature
    @Binding var showSubscription: Bool

    private var tier: SubscriptionPlan.BusinessTier { FeatureGate.requiredTier(for: feature) }

    var body: some View {
        Button { showSubscription = true } label: {
            HStack(spacing: PlagitSpacing.md) {
                ZStack {
                    Circle().fill(Color.plagitIndigo.opacity(0.1)).frame(width: 36, height: 36)
                    Image(systemName: feature.icon).font(.system(size: 14, weight: .medium)).foregroundColor(.plagitIndigo)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(feature.label).font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal)
                    Text("Upgrade to \(FeatureGate.tierName(tier))").font(PlagitFont.micro()).foregroundColor(.plagitIndigo)
                }
                Spacer()
                Image(systemName: "lock.fill").font(.system(size: 12, weight: .medium)).foregroundColor(.plagitIndigo)
            }
            .padding(PlagitSpacing.lg)
            .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitIndigo.opacity(0.04))
                .overlay(RoundedRectangle(cornerRadius: PlagitRadius.md).stroke(Color.plagitIndigo.opacity(0.15), lineWidth: 1)))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Limit Reached Card

/// Shown when a business hits their plan limit (e.g., max job posts).
/// Usage: `BusinessLimitCard(current: 3, limit: 3, feature: .unlimitedJobs, showSubscription: $showSub)`
struct BusinessLimitCard: View {
    let current: Int
    let limit: Int
    let feature: BusinessFeature
    @Binding var showSubscription: Bool

    var body: some View {
        VStack(spacing: PlagitSpacing.md) {
            HStack(spacing: PlagitSpacing.md) {
                ZStack {
                    Circle().fill(Color.plagitAmber.opacity(0.1)).frame(width: 40, height: 40)
                    Image(systemName: "exclamationmark.triangle").font(.system(size: 16, weight: .medium)).foregroundColor(.plagitAmber)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Limit Reached").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                    Text("You're using \(current) of \(limit) \(feature.label.lowercased()).")
                        .font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                }
                Spacer()
            }

            Button { showSubscription = true } label: {
                HStack(spacing: PlagitSpacing.sm) {
                    Image(systemName: "arrow.up.circle.fill").font(.system(size: 14, weight: .medium))
                    Text("Upgrade Plan")
                }
                .font(PlagitFont.captionMedium()).foregroundColor(.white)
                .frame(maxWidth: .infinity).padding(.vertical, PlagitSpacing.md)
                .background(Capsule().fill(LinearGradient(colors: [Color.plagitIndigo, Color.plagitIndigo.opacity(0.8)], startPoint: .leading, endPoint: .trailing)))
            }
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground)
            .shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
    }
}

// MARK: - Tier Badge

/// Small badge showing the minimum tier for a feature — used next to locked UI elements.
struct TierBadge: View {
    let tier: SubscriptionPlan.BusinessTier

    var body: some View {
        let color: Color = tier == .premium ? .plagitAmber : tier == .pro ? .plagitIndigo : .plagitTeal
        HStack(spacing: 3) {
            Image(systemName: tier == .premium ? "crown.fill" : "lock.fill").font(.system(size: 8, weight: .bold))
            Text(FeatureGate.tierName(tier).uppercased()).font(.system(size: 8, weight: .bold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 6).padding(.vertical, 2)
        .background(Capsule().fill(color))
    }
}
