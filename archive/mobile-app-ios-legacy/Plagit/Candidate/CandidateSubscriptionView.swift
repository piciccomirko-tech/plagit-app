//
//  CandidateSubscriptionView.swift
//  Plagit
//
//  Candidate Premium subscription paywall.
//

import SwiftUI
import StoreKit

struct CandidateSubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var sub = SubscriptionManager.shared
    @State private var selectedPlan: PlanChoice = .annual

    enum PlanChoice { case monthly, annual }

    private let benefits: [(icon: String, key: String)] = [
        ("slider.horizontal.3", "sub_cand_benefit_filters"),
        ("bell.badge.fill", "sub_cand_benefit_notif"),
        ("eye.fill", "sub_cand_benefit_visibility"),
        ("sparkles", "sub_cand_benefit_badge"),
        ("star.fill", "sub_cand_benefit_early"),
    ]

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    topBar

                    if sub.isCandidatePremium {
                        activePlanSection.padding(.top, PlagitSpacing.xl)
                    } else {
                        heroSection.padding(.top, PlagitSpacing.xl)
                        planCards.padding(.top, PlagitSpacing.xxl)
                        benefitsList.padding(.top, PlagitSpacing.sectionGap)
                        actionButtons.padding(.top, PlagitSpacing.xxl)
                    }

                    restoreLink.padding(.top, PlagitSpacing.lg)
                    termsNote.padding(.top, PlagitSpacing.lg)
                    Spacer().frame(height: PlagitSpacing.xxxl)
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            await sub.loadProducts(for: "candidate")
            await sub.refreshFromStoreKit()
        }
        .onChange(of: sub.currentPlan) { _, newPlan in
            // If user just became premium (via restore or external transaction), auto-dismiss
            if newPlan.isCandidatePremium {
            }
        }
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
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color.plagitAmber.opacity(0.2), Color.plagitAmber.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 80, height: 80)
                Image(systemName: "crown.fill").font(.system(size: 32, weight: .medium)).foregroundColor(.plagitAmber)
            }

            Text(L10n.t("sub_cand_title"))
                .font(PlagitFont.displayMedium())
                .foregroundColor(.plagitCharcoal)

            Text(L10n.t("sub_cand_subtitle"))
                .font(PlagitFont.body())
                .foregroundColor(.plagitSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, PlagitSpacing.xxl)
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
        .padding(PlagitSpacing.xxl)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground)
                .shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY)
        )
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Plan Cards

    private var annualPrice: String {
        sub.products.first(where: { $0.id == PlagitProductID.candidateAnnual })?.displayPrice ?? "—"
    }
    private var monthlyPrice: String {
        sub.products.first(where: { $0.id == PlagitProductID.candidateMonthly })?.displayPrice ?? "—"
    }

    private var planCards: some View {
        VStack(spacing: PlagitSpacing.md) {
            // Annual — Best Value
            planCard(
                title: L10n.t("annual_plan"), price: annualPrice, period: L10n.t("per_year"),
                saving: L10n.t("save_amount_year"), badge: L10n.t("best_value"),
                isSelected: selectedPlan == .annual
            ) { selectedPlan = .annual }

            // Monthly
            planCard(
                title: L10n.t("monthly_plan"), price: monthlyPrice, period: L10n.t("per_month"),
                saving: nil, badge: nil,
                isSelected: selectedPlan == .monthly
            ) { selectedPlan = .monthly }
        }
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func planCard(title: String, price: String, period: String, saving: String?, badge: String?, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: PlagitSpacing.md) {
                ZStack {
                    Circle().stroke(isSelected ? Color.plagitTeal : Color.plagitBorder, lineWidth: 2).frame(width: 22, height: 22)
                    if isSelected { Circle().fill(Color.plagitTeal).frame(width: 12, height: 12) }
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: PlagitSpacing.sm) {
                        Text(title).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                        if let badge {
                            Text(badge).font(.system(size: 10, weight: .bold)).foregroundColor(.white)
                                .padding(.horizontal, 6).padding(.vertical, 2).background(Capsule().fill(Color.plagitAmber))
                        }
                    }
                    if let saving {
                        Text(saving).font(PlagitFont.caption()).foregroundColor(.plagitOnline)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 1) {
                    Text(price).font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
                    Text(period).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                }
            }
            .padding(PlagitSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitCardBackground)
                    .overlay(RoundedRectangle(cornerRadius: PlagitRadius.md).stroke(isSelected ? Color.plagitTeal : Color.plagitDivider, lineWidth: isSelected ? 2 : 1))
            )
        }
    }

    // MARK: - Benefits

    private var benefitsList: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            Text(L10n.t("whats_included")).font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)

            ForEach(benefits, id: \.key) { b in
                HStack(spacing: PlagitSpacing.md) {
                    Image(systemName: b.icon).font(.system(size: 14, weight: .medium)).foregroundColor(.plagitTeal)
                        .frame(width: 28, height: 28).background(Circle().fill(Color.plagitTealLight))
                    Text(L10n.t(b.key)).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
                    Spacer()
                    Image(systemName: "checkmark").font(.system(size: 12, weight: .bold)).foregroundColor(.plagitOnline)
                }
            }
        }
        .padding(PlagitSpacing.xxl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground)
            .shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: PlagitSpacing.sm) {
            if let msg = sub.errorMessage {
                Text(msg).font(PlagitFont.caption()).foregroundColor(.plagitUrgent)
            }

            if sub.products.isEmpty && sub.errorMessage == nil {
                HStack(spacing: PlagitSpacing.sm) {
                    ProgressView().tint(.plagitTeal)
                    Text("Loading plans...").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                }
            }

            Button { Task { await purchaseSelected() } } label: {
                Group {
                    if sub.purchaseInProgress { ProgressView().tint(.white) }
                    else { Text(selectedPlan == .annual ? L10n.t("choose_annual") : L10n.t("choose_monthly")) }
                }
                .font(PlagitFont.subheadline()).foregroundColor(.white)
                .frame(maxWidth: .infinity).padding(.vertical, PlagitSpacing.lg)
                .background(Capsule().fill(LinearGradient(colors: [Color.plagitTeal, Color.plagitTealDark], startPoint: .topLeading, endPoint: .bottomTrailing)))
                .shadow(color: Color.plagitTeal.opacity(0.18), radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY)
            }
            .disabled(sub.purchaseInProgress || sub.products.isEmpty)
        }
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Restore & Terms

    private var restoreLink: some View {
        VStack(spacing: PlagitSpacing.sm) {
            Button {
                Task { await sub.restorePurchases() }
            } label: {
                HStack(spacing: PlagitSpacing.sm) {
                    if sub.restoreInProgress {
                        ProgressView().tint(.plagitTeal).controlSize(.small)
                    }
                    Text(L10n.t("restore_purchases")).font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                }
            }
            .disabled(sub.restoreInProgress)

            if let result = sub.restoreResult {
                switch result {
                case .success:
                    Text(L10n.t("restore_success")).font(PlagitFont.caption()).foregroundColor(.plagitOnline)
                case .nothingToRestore:
                    Text(L10n.t("restore_nothing")).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                case .error(let msg):
                    Text(msg).font(PlagitFont.caption()).foregroundColor(.plagitUrgent)
                }
            }
        }
    }

    private var termsNote: some View {
        Text(L10n.t("sub_terms")).font(PlagitFont.micro()).foregroundColor(.plagitTertiary).multilineTextAlignment(.center).padding(.horizontal, PlagitSpacing.xxl)
    }

    // MARK: - Purchase

    private func purchaseSelected() async {
        sub.errorMessage = nil
        let targetID = selectedPlan == .annual ? PlagitProductID.candidateAnnual : PlagitProductID.candidateMonthly
        guard let product = sub.products.first(where: { $0.id == targetID }) else {
            sub.errorMessage = L10n.t("product_not_available")
            // Retry loading products
            await sub.loadProducts(for: "candidate")
            return
        }
        await sub.purchase(product)
        if sub.purchaseSuccess { dismiss() }
    }
}

#Preview { NavigationStack { CandidateSubscriptionView() } }
