//
//  EntryView.swift
//  Plagit
//
//  Role Selection — Choose Candidate or Business
//

import SwiftUI

struct EntryView: View {
    @State private var showCandidateFlow = false
    @State private var showBusinessFlow = false
    @State private var showServicesFlow = false

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo + title
                VStack(spacing: PlagitSpacing.lg) {
                    Image("PlagitLogo")
                        .resizable().scaledToFit()
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: PlagitRadius.lg))
                        .shadow(color: Color.plagitTeal.opacity(0.15), radius: 12, y: 4)

                    VStack(spacing: PlagitSpacing.sm) {
                        Text("Plagit")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.plagitCharcoal)

                        Text(L10n.appTagline)
                            .font(PlagitFont.body())
                            .foregroundColor(.plagitSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                    }
                }

                Spacer().frame(height: PlagitSpacing.xxxl)

                // Role cards
                VStack(spacing: PlagitSpacing.md) {
                    roleCard(
                        icon: "person.fill",
                        color: .plagitTeal,
                        title: L10n.findWork,
                        subtitle: L10n.findWorkSub
                    ) { showCandidateFlow = true }

                    roleCard(
                        icon: "building.2.fill",
                        color: .plagitIndigo,
                        title: L10n.hireStaff,
                        subtitle: L10n.hireStaffSub
                    ) { showBusinessFlow = true }

                    roleCard(
                        icon: "building.2.crop.circle",
                        color: .plagitAmber,
                        title: L10n.findCompanies,
                        subtitle: L10n.findCompaniesSub
                    ) { showServicesFlow = true }
                }
                .padding(.horizontal, PlagitSpacing.xl)

                Spacer()

                // Sign in + legal
                VStack(spacing: PlagitSpacing.md) {
                    Button { showCandidateFlow = true } label: {
                        HStack(spacing: PlagitSpacing.xs) {
                            Text(L10n.alreadyHaveAccount)
                                .font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                            Text(L10n.signIn)
                                .font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                        }
                    }

                    Text(L10n.termsNotice)
                        .font(PlagitFont.micro())
                        .foregroundColor(.plagitTertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, PlagitSpacing.xxl)
                }
                .padding(.bottom, PlagitSpacing.xxxl)
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showCandidateFlow) {
            CandidateRootView().navigationBarHidden(true)
        }
        .navigationDestination(isPresented: $showBusinessFlow) {
            BusinessRootView().navigationBarHidden(true)
        }
        .navigationDestination(isPresented: $showServicesFlow) {
            ServiceEntryView().navigationBarHidden(true)
        }
    }

    // MARK: - Role Card

    private func roleCard(icon: String, color: Color, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
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

#Preview {
    NavigationStack {
        EntryView()
    }
    .preferredColorScheme(.light)
}
