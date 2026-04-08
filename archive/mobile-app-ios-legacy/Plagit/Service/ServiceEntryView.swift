//
//  ServiceEntryView.swift
//  Plagit
//
//  Entry screen for the Find Services section.
//  Two options: Register as a Business / I'm Looking for a Business
//

import SwiftUI

struct ServiceEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showRegister = false
    @State private var showDiscover = false

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                Spacer()

                // Header
                VStack(spacing: PlagitSpacing.md) {
                    ZStack {
                        Circle()
                            .fill(Color.plagitAmber.opacity(0.1))
                            .frame(width: 64, height: 64)
                        Image(systemName: "building.2.crop.circle")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(.plagitAmber)
                    }
                    Text("Hospitality Services")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.plagitCharcoal)
                    Text("Register your service company or find hospitality providers near you.")
                        .font(PlagitFont.body())
                        .foregroundColor(.plagitSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, PlagitSpacing.xl)
                }

                Spacer().frame(height: PlagitSpacing.xxxl)

                // Option cards
                VStack(spacing: PlagitSpacing.md) {
                    optionCard(
                        icon: "plus.circle.fill",
                        color: .plagitAmber,
                        title: "Register as a Business",
                        subtitle: "List your hospitality service and get discovered by clients"
                    ) { showRegister = true }

                    optionCard(
                        icon: "magnifyingglass.circle.fill",
                        color: .plagitTeal,
                        title: "I'm Looking for a Business",
                        subtitle: "Find hospitality service providers near you"
                    ) { showDiscover = true }
                }
                .padding(.horizontal, PlagitSpacing.xl)

                Spacer()
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showRegister) {
            ServiceProviderSignUpView().navigationBarHidden(true)
        }
        .navigationDestination(isPresented: $showDiscover) {
            ServiceFeedView().navigationBarHidden(true)
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.plagitCharcoal)
                    .frame(width: 36, height: 36)
            }
            Spacer()
            Text(L10n.findCompanies)
                .font(PlagitFont.subheadline())
                .foregroundColor(.plagitCharcoal)
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, PlagitSpacing.xl)
        .padding(.top, PlagitSpacing.lg)
        .padding(.bottom, PlagitSpacing.lg)
    }

    // MARK: - Option Card

    private func optionCard(icon: String, color: Color, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: PlagitSpacing.lg) {
                ZStack {
                    RoundedRectangle(cornerRadius: PlagitRadius.lg)
                        .fill(color.opacity(0.1))
                        .frame(width: 52, height: 52)
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(color)
                }

                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.plagitCharcoal)
                    Text(subtitle)
                        .font(PlagitFont.caption())
                        .foregroundColor(.plagitSecondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundStyle(color, color.opacity(0.12))
            }
            .padding(PlagitSpacing.xl)
            .background(
                RoundedRectangle(cornerRadius: PlagitRadius.xl)
                    .fill(Color.plagitCardBackground)
                    .shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY)
            )
        }
    }
}
