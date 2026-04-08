//
//  CandidateQuickPlugView.swift
//  Plagit
//
//  Quick Plug — fast-action hub for candidate accounts.
//  Boost profile, apply faster, get discovered.
//

import SwiftUI

struct CandidateQuickPlugView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showSubscription = false
    @State private var showJobs = false
    @State private var showProfile = false

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: PlagitSpacing.lg) {
                        headerSection
                        quickActions
                        premiumSection
                        Spacer().frame(height: PlagitSpacing.xxxl)
                    }
                    .padding(.top, PlagitSpacing.lg)
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showSubscription) {
            CandidateSubscriptionView().navigationBarHidden(true)
        }
        .navigationDestination(isPresented: $showJobs) {
            CandidateJobsView().navigationBarHidden(true)
        }
        .navigationDestination(isPresented: $showProfile) {
            CandidateRealProfileView().navigationBarHidden(true)
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
            Text("Quick Plug")
                .font(PlagitFont.subheadline())
                .foregroundColor(.plagitCharcoal)
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, PlagitSpacing.xl)
        .padding(.top, PlagitSpacing.lg)
        .padding(.bottom, PlagitSpacing.lg)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: PlagitSpacing.md) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color.plagitPurple, Color.plagitPurpleDark], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 56, height: 56)
                Image(systemName: "bolt.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
            }
            Text("Quick Actions")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.plagitCharcoal)
            Text("Boost your profile, get discovered faster, and land your next role.")
                .font(PlagitFont.body())
                .foregroundColor(.plagitSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, PlagitSpacing.xxl)
    }

    // MARK: - Quick Actions

    private var quickActions: some View {
        VStack(spacing: PlagitSpacing.md) {
            actionCard(
                icon: "arrow.up.circle.fill",
                color: .plagitPurple,
                title: "Boost My Profile",
                subtitle: FeatureGate.hasImprovedVisibility ? "Your profile is boosted — you're more visible to employers" : "Upgrade to get seen by more employers"
            ) {
                if FeatureGate.hasImprovedVisibility { showProfile = true }
                else { showSubscription = true }
            }

            actionCard(
                icon: "briefcase.fill",
                color: .plagitAmber,
                title: "Quick Apply",
                subtitle: "Browse and apply to the latest jobs near you"
            ) { showJobs = true }

            actionCard(
                icon: "bell.badge.fill",
                color: .plagitIndigo,
                title: "Priority Notifications",
                subtitle: FeatureGate.hasPriorityNotifications ? "You receive priority alerts for new matches" : "Upgrade to get notified first when jobs match"
            ) {
                if FeatureGate.hasPriorityNotifications { /* already active */ }
                else { showSubscription = true }
            }

            actionCard(
                icon: "slider.horizontal.3",
                color: .plagitPurple,
                title: "Advanced Filters",
                subtitle: FeatureGate.canUseAdvancedFilters ? "Use distance, salary, contract filters" : "Upgrade to unlock premium search filters"
            ) {
                if FeatureGate.canUseAdvancedFilters { showJobs = true }
                else { showSubscription = true }
            }
        }
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func actionCard(icon: String, color: Color, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: PlagitSpacing.lg) {
                ZStack {
                    RoundedRectangle(cornerRadius: PlagitRadius.lg)
                        .fill(color.opacity(0.1))
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(color)
                }
                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    Text(title)
                        .font(PlagitFont.bodyMedium())
                        .foregroundColor(.plagitCharcoal)
                    Text(subtitle)
                        .font(PlagitFont.caption())
                        .foregroundColor(.plagitSecondary)
                        .lineLimit(2)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.plagitTertiary)
            }
            .padding(PlagitSpacing.xl)
            .background(
                RoundedRectangle(cornerRadius: PlagitRadius.xl)
                    .fill(Color.plagitCardBackground)
                    .shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Premium Section

    private var premiumSection: some View {
        VStack(spacing: PlagitSpacing.md) {
            if !FeatureGate.isPremium {
                Button { showSubscription = true } label: {
                    HStack(spacing: PlagitSpacing.md) {
                        ZStack {
                            Circle().fill(Color.plagitPurple.opacity(0.1)).frame(width: 40, height: 40)
                            Image(systemName: "crown.fill").font(.system(size: 16, weight: .medium)).foregroundColor(.plagitPurple)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Go Premium").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                            Text("Unlock all filters, boost your profile, and get priority access.")
                                .font(PlagitFont.caption()).foregroundColor(.plagitSecondary).lineLimit(2)
                        }
                        Spacer()
                        Text("Upgrade")
                            .font(PlagitFont.captionMedium())
                            .foregroundColor(.white)
                            .padding(.horizontal, PlagitSpacing.md)
                            .padding(.vertical, PlagitSpacing.sm)
                            .background(Capsule().fill(Color.plagitPurple))
                    }
                    .padding(PlagitSpacing.xl)
                    .background(
                        RoundedRectangle(cornerRadius: PlagitRadius.xl)
                            .fill(Color.plagitPurple.opacity(0.04))
                            .overlay(RoundedRectangle(cornerRadius: PlagitRadius.xl).stroke(Color.plagitPurple.opacity(0.15), lineWidth: 1))
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, PlagitSpacing.xl)
    }
}
