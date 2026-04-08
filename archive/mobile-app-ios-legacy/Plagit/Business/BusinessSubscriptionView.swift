//
//  BusinessSubscriptionView.swift
//  Plagit
//
//  Business subscription paywall — 3 tiers: Basic, Pro, Premium.
//

import SwiftUI
import StoreKit

struct BusinessSubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var sub = SubscriptionManager.shared
    @State private var selectedTier: Tier = .pro
    @State private var isAnnual = true

    enum Tier: String, CaseIterable { case basic, pro, premium }

    struct TierConfig {
        let name: String
        let descKey: String
        let monthlyPrice: String
        let annualPrice: String
        let savingKey: String
        let features: [(icon: String, key: String)]
        let color: Color
        let isPopular: Bool
        let topLabel: String?  // e.g. "Most Popular" or "Best for Maximum Visibility"
    }

    private var tierConfigs: [Tier: TierConfig] {
        [
            .basic: TierConfig(
                name: L10n.t("biz_basic"), descKey: "biz_basic_desc",
                monthlyPrice: "$19", annualPrice: "$190", savingKey: "save_38_year",
                features: [
                    ("briefcase", "sub_limited_posts"),
                    ("person.2", "sub_limited_contacts"),
                    ("slider.horizontal.3", "sub_basic_filters"),
                    ("eye", "sub_improved_visibility"),
                ],
                color: .plagitTeal, isPopular: false, topLabel: nil
            ),
            .pro: TierConfig(
                name: L10n.t("biz_pro"), descKey: "biz_pro_desc",
                monthlyPrice: "$29", annualPrice: "$290", savingKey: "save_58_year",
                features: [
                    ("briefcase.fill", "sub_unlimited_job_posts"),
                    ("person.2.fill", "sub_unlimited_contacts"),
                    ("slider.horizontal.3", "sub_advanced_filters"),
                    ("chart.bar.fill", "sub_analytics"),
                    ("eye.fill", "sub_improved_visibility"),
                ],
                color: .plagitIndigo, isPopular: true, topLabel: "most_popular"
            ),
            .premium: TierConfig(
                name: L10n.t("biz_premium"), descKey: "biz_premium_desc",
                monthlyPrice: "$49", annualPrice: "$490", savingKey: "save_98_year",
                features: [
                    ("checkmark.seal", "sub_everything_pro"),
                    ("sparkles", "sub_featured_listings"),
                    ("arrow.up.circle.fill", "sub_top_placement"),
                    ("crown.fill", "sub_premium_badge"),
                    ("building.2.fill", "sub_highlighted_profile"),
                    ("chart.line.uptrend.xyaxis", "sub_advanced_insights"),
                ],
                color: .plagitAmber, isPopular: false, topLabel: "biz_premium_label"
            ),
        ]
    }

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    topBar

                    if sub.isBusinessPaid {
                        activePlanSection.padding(.top, PlagitSpacing.xl)
                    } else {
                        heroSection.padding(.top, PlagitSpacing.xl)
                    }

                    billingToggle.padding(.top, PlagitSpacing.xxl)

                    // Comparison intro
                    Text(L10n.t("sub_biz_intro"))
                        .font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                        .multilineTextAlignment(.center).padding(.horizontal, PlagitSpacing.xxl)
                        .padding(.top, PlagitSpacing.lg)

                    tierCards.padding(.top, PlagitSpacing.lg)
                    restoreLink.padding(.top, PlagitSpacing.xxl)
                    termsNote.padding(.top, PlagitSpacing.lg)
                    Spacer().frame(height: PlagitSpacing.xxxl)
                }
            }
        }
        .navigationBarHidden(true)
        .task { await sub.loadProducts(for: "business") }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark").font(.system(size: 16, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36)
            }
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg)
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: PlagitSpacing.md) {
            Image(systemName: "building.2.fill").font(.system(size: 36)).foregroundColor(.plagitIndigo)
            Text(L10n.t("sub_biz_title")).font(PlagitFont.displayMedium()).foregroundColor(.plagitCharcoal).multilineTextAlignment(.center)
            Text(L10n.t("sub_biz_subtitle")).font(PlagitFont.body()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center).lineSpacing(3).padding(.horizontal, PlagitSpacing.xxl)
        }
    }

    // MARK: - Active Plan

    private var activePlanSection: some View {
        VStack(spacing: PlagitSpacing.md) {
            Image(systemName: "checkmark.seal.fill").font(.system(size: 44)).foregroundColor(.plagitOnline)
            Text(L10n.t("current_plan")).font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
            Text(L10n.t("you_are_on_plan").replacingOccurrences(of: "%@", with: sub.currentPlan.displayName))
                .font(PlagitFont.body()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center)
            if let exp = sub.expiryDate {
                Text("\(L10n.t("renews_on")) \(exp.formatted(date: .abbreviated, time: .omitted))")
                    .font(PlagitFont.caption()).foregroundColor(.plagitTertiary)
            }
        }
        .padding(PlagitSpacing.xxl).frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground)
            .shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Billing Toggle

    private var billingToggle: some View {
        VStack(spacing: PlagitSpacing.xs) {
            HStack(spacing: 0) {
                toggleBtn(L10n.t("monthly_plan"), selected: !isAnnual) { isAnnual = false }
                toggleBtn(L10n.t("yearly"), selected: isAnnual) { isAnnual = true }
            }
            .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))

            if isAnnual {
                Text(L10n.t("save_more_annual"))
                    .font(PlagitFont.micro()).foregroundColor(.plagitOnline)
            }
        }
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func toggleBtn(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title).font(PlagitFont.captionMedium())
                .foregroundColor(selected ? .white : .plagitSecondary)
                .frame(maxWidth: .infinity).padding(.vertical, PlagitSpacing.md)
                .background(selected ? RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitIndigo) : nil)
        }
    }

    // MARK: - Tier Cards

    private var tierCards: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ForEach(Tier.allCases, id: \.self) { tier in
                if let cfg = tierConfigs[tier] { tierCard(tier: tier, cfg: cfg) }
            }
        }
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func tierCard(tier: Tier, cfg: TierConfig) -> some View {
        let isSelected = selectedTier == tier
        return VStack(alignment: .leading, spacing: PlagitSpacing.md) {
            // Top label
            if let labelKey = cfg.topLabel {
                HStack(spacing: 4) {
                    if cfg.isPopular { Image(systemName: "flame.fill").font(.system(size: 10, weight: .bold)) }
                    Text(L10n.t(labelKey)).font(.system(size: 10, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 3)
                .background(Capsule().fill(cfg.color))
            }

            // Name + price
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(cfg.name).font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
                    Text(L10n.t(cfg.descKey)).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 1) {
                    Text(isAnnual ? cfg.annualPrice : cfg.monthlyPrice)
                        .font(cfg.isPopular ? PlagitFont.displayMedium() : PlagitFont.headline())
                        .foregroundColor(cfg.isPopular ? cfg.color : .plagitCharcoal)
                    Text(isAnnual ? L10n.t("per_year") : L10n.t("per_month")).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                    if isAnnual {
                        Text(L10n.t(cfg.savingKey)).font(PlagitFont.micro()).foregroundColor(.plagitOnline)
                    }
                }
            }

            // Features
            VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
                ForEach(cfg.features, id: \.key) { f in
                    HStack(spacing: PlagitSpacing.sm) {
                        Image(systemName: "checkmark.circle.fill").font(.system(size: 12, weight: .medium)).foregroundColor(.plagitOnline)
                        Text(L10n.t(f.key)).font(PlagitFont.caption()).foregroundColor(.plagitCharcoal)
                    }
                }
            }

            // CTA button
            Button { selectedTier = tier; Task { await purchaseSelected(tier) } } label: {
                Group {
                    if sub.purchaseInProgress && selectedTier == tier { ProgressView().tint(.white) }
                    else {
                        let btnKey = tier == .basic ? "choose_basic" : tier == .pro ? "choose_pro" : "choose_premium"
                        Text(L10n.t(btnKey))
                    }
                }
                .font(PlagitFont.captionMedium()).foregroundColor(cfg.isPopular ? .white : cfg.color)
                .frame(maxWidth: .infinity).padding(.vertical, PlagitSpacing.md)
                .background(
                    Capsule().fill(cfg.isPopular
                        ? AnyShapeStyle(LinearGradient(colors: [cfg.color, cfg.color.opacity(0.8)], startPoint: .leading, endPoint: .trailing))
                        : AnyShapeStyle(cfg.color.opacity(0.1)))
                )
            }
            .disabled(sub.purchaseInProgress)
        }
        .padding(cfg.isPopular ? PlagitSpacing.xl : PlagitSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: PlagitRadius.lg).fill(Color.plagitCardBackground)
                .overlay(RoundedRectangle(cornerRadius: PlagitRadius.lg)
                    .stroke(isSelected || cfg.isPopular ? cfg.color : Color.plagitDivider, lineWidth: isSelected ? 2.5 : cfg.isPopular ? 1.5 : 1))
                .shadow(color: cfg.isPopular ? cfg.color.opacity(0.12) : .clear, radius: cfg.isPopular ? 12 : 0, y: 4)
        )
    }

    // MARK: - Restore & Terms

    private var restoreLink: some View {
        Button { Task { await sub.restorePurchases() } } label: {
            Text(L10n.t("restore_purchases")).font(PlagitFont.captionMedium()).foregroundColor(.plagitIndigo)
        }
    }

    private var termsNote: some View {
        Text(L10n.t("sub_terms")).font(PlagitFont.micro()).foregroundColor(.plagitTertiary).multilineTextAlignment(.center).padding(.horizontal, PlagitSpacing.xxl)
    }

    // MARK: - Purchase

    private func purchaseSelected(_ tier: Tier) async {
        let targetID: String
        switch (tier, isAnnual) {
        case (.basic, false):   targetID = PlagitProductID.businessBasicMonthly
        case (.basic, true):    targetID = PlagitProductID.businessBasicAnnual
        case (.pro, false):     targetID = PlagitProductID.businessProMonthly
        case (.pro, true):      targetID = PlagitProductID.businessProAnnual
        case (.premium, false): targetID = PlagitProductID.businessPremiumMonthly
        case (.premium, true):  targetID = PlagitProductID.businessPremiumAnnual
        }
        guard let product = sub.products.first(where: { $0.id == targetID }) else {
            sub.errorMessage = L10n.t("product_not_available"); return
        }
        await sub.purchase(product)
        if sub.purchaseSuccess { dismiss() }
    }
}

#Preview { NavigationStack { BusinessSubscriptionView() } }
