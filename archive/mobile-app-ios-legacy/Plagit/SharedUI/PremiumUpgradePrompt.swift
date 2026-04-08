//
//  PremiumUpgradePrompt.swift
//  Plagit
//
//  Reusable inline upgrade prompt shown when a gated feature is tapped.
//

import SwiftUI

struct PremiumUpgradePrompt: View {
    let featureName: String
    let userType: String  // "candidate" or "business"
    @Binding var showSubscription: Bool

    var body: some View {
        VStack(spacing: PlagitSpacing.md) {
            Image(systemName: "lock.fill")
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(userType == "business" ? .plagitIndigo : .plagitAmber)

            Text(userType == "business" ? L10n.t("unlock_business_premium") : L10n.t("unlock_candidate_premium"))
                .font(PlagitFont.headline())
                .foregroundColor(.plagitCharcoal)

            Text(userType == "business" ? L10n.t("unlock_biz_sub") : L10n.t("unlock_cand_sub"))
                .font(PlagitFont.body())
                .foregroundColor(.plagitSecondary)
                .multilineTextAlignment(.center)

            Button { showSubscription = true } label: {
                Text(L10n.t("subscribe_now"))
                    .font(PlagitFont.captionMedium())
                    .foregroundColor(.white)
                    .padding(.horizontal, PlagitSpacing.xxl)
                    .padding(.vertical, PlagitSpacing.md)
                    .background(
                        Capsule().fill(userType == "business"
                            ? Color.plagitIndigo
                            : Color.plagitTeal)
                    )
            }
        }
        .padding(PlagitSpacing.xxl)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: PlagitRadius.xl)
                .fill(Color.plagitCardBackground)
                .shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY)
        )
        .padding(.horizontal, PlagitSpacing.xl)
    }
}

/// Modifier to present a premium gate sheet
struct PremiumGateModifier: ViewModifier {
    let isGated: Bool
    let userType: String
    @Binding var showSubscription: Bool

    func body(content: Content) -> some View {
        if isGated {
            content
                .disabled(true)
                .opacity(0.5)
                .overlay(
                    Button {
                        showSubscription = true
                    } label: {
                        HStack(spacing: PlagitSpacing.xs) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 10, weight: .bold))
                            Text(L10n.t("premium"))
                                .font(PlagitFont.micro())
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, PlagitSpacing.sm)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.plagitAmber))
                    }
                    , alignment: .topTrailing
                )
        } else {
            content
        }
    }
}

extension View {
    func premiumGate(isGated: Bool, userType: String = "candidate", showSubscription: Binding<Bool>) -> some View {
        modifier(PremiumGateModifier(isGated: isGated, userType: userType, showSubscription: showSubscription))
    }
}
