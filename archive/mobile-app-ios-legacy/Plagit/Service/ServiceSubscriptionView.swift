//
//  ServiceSubscriptionView.swift
//  Plagit
//
//  Service provider subscription paywall — 3 tiers: Basic, Pro, Premium.
//

import SwiftUI
import StoreKit

struct ServiceSubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var sub = SubscriptionManager.shared
    @State private var selectedTier: Tier = .pro
    @State private var isAnnual = true

    enum Tier: String, CaseIterable { case basic, pro, premium }

    private struct TierInfo {
        let name: String
        let price: String
        let annualPrice: String
        let features: [(icon: String, text: String)]
        let color: Color
        let isPopular: Bool
    }

    private func tierInfo(_ tier: Tier) -> TierInfo {
        switch tier {
        case .basic:
            return TierInfo(name: "Basic", price: "$9.99/mo", annualPrice: "$99.99/yr", features: [
                ("checkmark.seal", "Verified Badge"),
                ("arrow.up.circle", "Improved Visibility"),
                ("doc.text", "Up to 10 Posts"),
                ("person.2", "20 Contacts/Month"),
            ], color: .plagitTeal, isPopular: false)
        case .pro:
            return TierInfo(name: "Pro", price: "$19.99/mo", annualPrice: "$199.99/yr", features: [
                ("sparkles", "Featured Placement"),
                ("chart.bar", "Advanced Analytics"),
                ("doc.text.fill", "Up to 50 Posts"),
                ("person.2.fill", "100 Contacts/Month"),
                ("list.star", "Priority Listing"),
            ], color: .plagitAmber, isPopular: true)
        case .premium:
            return TierInfo(name: "Premium", price: "$39.99/mo", annualPrice: "$399.99/yr", features: [
                ("crown", "Premium Badge"),
                ("arrow.up.circle.fill", "Top Placement"),
                ("bolt.fill", "Feed Boost"),
                ("chart.bar.fill", "Full Analytics"),
                ("infinity", "Unlimited Posts"),
                ("infinity", "Unlimited Contacts"),
            ], color: .plagitIndigo, isPopular: false)
        }
    }

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: PlagitSpacing.lg) {
                    topBar

                    // Header
                    VStack(spacing: PlagitSpacing.sm) {
                        Text("Grow Your Service Business")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.plagitCharcoal)
                        Text("Get discovered by more clients with a premium listing.")
                            .font(PlagitFont.body())
                            .foregroundColor(.plagitSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, PlagitSpacing.xl)

                    // Annual toggle
                    HStack(spacing: PlagitSpacing.md) {
                        Text("Monthly").font(PlagitFont.captionMedium()).foregroundColor(isAnnual ? .plagitTertiary : .plagitCharcoal)
                        Toggle("", isOn: $isAnnual).labelsHidden().tint(.plagitAmber)
                        HStack(spacing: PlagitSpacing.xs) {
                            Text("Annual").font(PlagitFont.captionMedium()).foregroundColor(isAnnual ? .plagitCharcoal : .plagitTertiary)
                            Text("Save 17%").font(PlagitFont.micro()).foregroundColor(.plagitOnline)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Capsule().fill(Color.plagitOnline.opacity(0.1)))
                        }
                    }

                    // Tier cards
                    ForEach(Tier.allCases, id: \.self) { tier in
                        tierCard(tier)
                    }

                    // Current plan info
                    if sub.currentPlan.isServiceAny {
                        HStack(spacing: PlagitSpacing.sm) {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.plagitOnline)
                            Text("Current plan: \(sub.currentPlan.displayName)")
                                .font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal)
                        }
                        .padding(PlagitSpacing.lg)
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitOnline.opacity(0.06)))
                        .padding(.horizontal, PlagitSpacing.xl)
                    }

                    // Subscribe button
                    Button {
                        // TODO: purchase service tier via StoreKit
                    } label: {
                        Text("Subscribe to \(tierInfo(selectedTier).name)")
                            .font(PlagitFont.subheadline())
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, PlagitSpacing.lg)
                            .background(
                                Capsule().fill(
                                    LinearGradient(colors: [tierInfo(selectedTier).color, tierInfo(selectedTier).color.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                                )
                            )
                    }
                    .padding(.horizontal, PlagitSpacing.xl)

                    // Restore
                    Button { Task { await sub.restorePurchases() } } label: {
                        Text("Restore Purchases").font(PlagitFont.caption()).foregroundColor(.plagitTertiary)
                    }

                    Spacer().frame(height: PlagitSpacing.xxxl)
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium))
                    .foregroundColor(.plagitCharcoal).frame(width: 36, height: 36)
            }
            Spacer()
            Text("Service Plans").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.sm)
    }

    // MARK: - Tier Card

    private func tierCard(_ tier: Tier) -> some View {
        let info = tierInfo(tier)
        let isSelected = selectedTier == tier

        return Button { withAnimation(.easeInOut(duration: 0.2)) { selectedTier = tier } } label: {
            VStack(alignment: .leading, spacing: PlagitSpacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: PlagitSpacing.sm) {
                            Text(info.name).font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
                            if info.isPopular {
                                Text("Most Popular").font(PlagitFont.micro()).foregroundColor(.white)
                                    .padding(.horizontal, 6).padding(.vertical, 2)
                                    .background(Capsule().fill(info.color))
                            }
                        }
                        Text(isAnnual ? info.annualPrice : info.price)
                            .font(PlagitFont.bodyMedium()).foregroundColor(info.color)
                    }
                    Spacer()
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22)).foregroundColor(isSelected ? info.color : .plagitBorder)
                }

                ForEach(info.features, id: \.text) { feature in
                    HStack(spacing: PlagitSpacing.sm) {
                        Image(systemName: feature.icon).font(.system(size: 12, weight: .medium))
                            .foregroundColor(info.color).frame(width: 18)
                        Text(feature.text).font(PlagitFont.caption()).foregroundColor(.plagitCharcoal)
                    }
                }
            }
            .padding(PlagitSpacing.xl)
            .background(
                RoundedRectangle(cornerRadius: PlagitRadius.xl)
                    .fill(Color.plagitCardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: PlagitRadius.xl)
                            .stroke(isSelected ? info.color : Color.plagitBorder.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                    )
                    .shadow(color: isSelected ? info.color.opacity(0.1) : .clear, radius: 8, y: 4)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, PlagitSpacing.xl)
    }
}
