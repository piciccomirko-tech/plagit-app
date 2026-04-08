//
//  AdminSettingsView.swift
//  Plagit
//
//  Admin — Platform Settings & Configuration
//

import SwiftUI

struct AdminSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AdminSettingsViewModel()
    @State private var showConfirmAlert = false
    @State private var confirmTitle = ""
    @State private var confirmAction: (() -> Void)?
    @State private var showChangePassword = false

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()

            switch viewModel.loadingState {
            case .idle, .loading:
                VStack(spacing: 0) {
                    settingsTopBar
                    Spacer()
                    ProgressView("Loading settings...").frame(maxWidth: .infinity)
                    Spacer()
                }
            case .error(let message):
                errorView(message)
            case .loaded:
                loadedContent
            }
        }
        .navigationBarHidden(true)
        .alert(confirmTitle, isPresented: $showConfirmAlert) { Button("Confirm", role: .destructive) { confirmAction?() }; Button("Cancel", role: .cancel) {} } message: { Text("This change takes effect immediately.") }
        .navigationDestination(isPresented: $showChangePassword) {
            AdminChangePasswordView().navigationBarHidden(true)
        }
        .task { await viewModel.loadSettings() }
    }

    // MARK: - Top Bar
    private var settingsTopBar: some View {
        HStack {
            Button { dismiss() } label: { Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36) }
            Spacer(); Text("Settings").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal); Spacer()
            Color.clear.frame(width: 36, height: 36)
        }.padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.xxl).padding(.bottom, PlagitSpacing.lg).background(Color.plagitBackground)
    }

    // MARK: - Error View
    private func errorView(_ message: String) -> some View {
        VStack(spacing: PlagitSpacing.lg) {
            settingsTopBar
            Spacer()
            ZStack { Circle().fill(Color.plagitUrgent.opacity(0.08)).frame(width: 48, height: 48); Image(systemName: "exclamationmark.triangle").font(.system(size: 20, weight: .medium)).foregroundColor(.plagitUrgent) }
            Text(message).font(PlagitFont.body()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center).padding(.horizontal, PlagitSpacing.xxl)
            Button { Task { await viewModel.loadSettings() } } label: { Text("Retry").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal).padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm).background(Capsule().fill(Color.plagitTealLight)) }
            Spacer()
        }
    }

    // MARK: - Loaded Content
    private var loadedContent: some View {
        VStack(spacing: 0) {
            settingsTopBar

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: PlagitSpacing.sectionGap) {
                    card("General", "gearshape") { row("App Name", "Plagit"); row("Support Email", "support@plagit.com"); row("Support Phone", "+971 800 PLAGIT"); tog("Maintenance Mode", Binding(get: { viewModel.settings.maintenanceMode }, set: { viewModel.settings.maintenanceMode = $0; viewModel.saveSettings() }), true); tog("Onboarding Enabled", Binding(get: { viewModel.settings.onboardingEnabled }, set: { viewModel.settings.onboardingEnabled = $0; viewModel.saveSettings() })) }
                    card("Notifications", "bell") { tog("Push", Binding(get: { viewModel.settings.pushEnabled }, set: { viewModel.settings.pushEnabled = $0; viewModel.saveSettings() })); tog("Email", Binding(get: { viewModel.settings.emailEnabled }, set: { viewModel.settings.emailEnabled = $0; viewModel.saveSettings() })); tog("SMS", Binding(get: { viewModel.settings.smsEnabled }, set: { viewModel.settings.smsEnabled = $0; viewModel.saveSettings() })); tog("In-App", Binding(get: { viewModel.settings.inAppEnabled }, set: { viewModel.settings.inAppEnabled = $0; viewModel.saveSettings() })); row("Reminder", "24h before interview"); row("Retry", "3 retries, 1h apart") }
                    card("Map & Location", "map") { tog("Map Enabled", Binding(get: { viewModel.settings.mapEnabled }, set: { viewModel.settings.mapEnabled = $0; viewModel.saveSettings() })); row("Default Radius", "5 km"); row("Max Radius", "20 km"); row("Location Prompt", "On first launch") }
                    card("Moderation", "shield") { tog("Auto-Flag Suspicious", Binding(get: { viewModel.settings.autoFlagEnabled }, set: { viewModel.settings.autoFlagEnabled = $0; viewModel.saveSettings() })); tog("Abuse Filter", Binding(get: { viewModel.settings.abuseFilterEnabled }, set: { viewModel.settings.abuseFilterEnabled = $0; viewModel.saveSettings() })); row("Report Types", "Spam, Fake, Scam, Harassment"); row("Auto-Suspend", "3 confirmed reports"); row("Restricted Rules", "No messaging, no applying") }
                    card("Community", "text.bubble") { tog("Community Enabled", Binding(get: { viewModel.settings.communityEnabled }, set: { viewModel.settings.communityEnabled = $0; viewModel.saveSettings() })); tog("Home Preview", Binding(get: { viewModel.settings.homePreviewEnabled }, set: { viewModel.settings.homePreviewEnabled = $0; viewModel.saveSettings() })); row("Max Home Cards", "2"); row("Featured Limit", "3 employers"); row("Scheduling", "Draft \u{2192} Scheduled \u{2192} Published") }
                    card("Billing", "creditcard") { row("Plans", "Basic $99 \u{00B7} Premium $299 \u{00B7} Enterprise $4,999"); row("Trial", "14 days"); row("Grace Period", "7 days"); row("Failed Payment", "Retry 3x then suspend"); row("Invoice Reminders", "7d, 3d, 1d before") }
                    card("Feature Flags", "flag") { tog("Near Me Jobs", Binding(get: { viewModel.settings.nearMeEnabled }, set: { viewModel.settings.nearMeEnabled = $0; viewModel.saveSettings() })); tog("Map Mode", Binding(get: { viewModel.settings.mapModeEnabled }, set: { viewModel.settings.mapModeEnabled = $0; viewModel.saveSettings() })); tog("Offer Flow", Binding(get: { viewModel.settings.offerFlowEnabled }, set: { viewModel.settings.offerFlowEnabled = $0; viewModel.saveSettings() })); tog("Experimental Onboarding", Binding(get: { viewModel.settings.experimentalOnboarding }, set: { viewModel.settings.experimentalOnboarding = $0; viewModel.saveSettings() })); row("Community Feed", viewModel.settings.communityEnabled ? "Enabled" : "Disabled") }
                    card("Localization", "globe") { row("Default", "English"); row("Supported", "English, Arabic, French"); row("Regions", "UAE, UK, EU"); row("Currency", "Multi (USD, GBP, EUR)") }
                    card("Support", "questionmark.circle") { row("Help Center", "help.plagit.com"); row("Terms", "plagit.com/terms"); row("Privacy", "plagit.com/privacy"); row("Contact Form", "Enabled") }
                    card("Account Security", "lock.shield") {
                        Button { showChangePassword = true } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Change Password").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                                    Text("Update your admin login password").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right").font(.system(size: 10, weight: .medium)).foregroundColor(.plagitTertiary)
                            }.padding(.vertical, PlagitSpacing.xs)
                        }
                    }
                    dangerZone
                    VStack(spacing: PlagitSpacing.xs) { Text("Plagit Admin v1.0.0").font(PlagitFont.caption()).foregroundColor(.plagitTertiary); Text("Build 2026.03.30").font(PlagitFont.micro()).foregroundColor(.plagitTertiary) }.frame(maxWidth: .infinity).padding(.vertical, PlagitSpacing.lg)
                }.padding(.top, PlagitSpacing.md).padding(.bottom, PlagitSpacing.xxxl)
            }
        }
    }

    private var dangerZone: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            HStack(spacing: PlagitSpacing.sm) { Image(systemName: "exclamationmark.triangle").font(.system(size: 12, weight: .medium)).foregroundColor(.plagitUrgent); Text("Danger Zone").font(PlagitFont.headline()).foregroundColor(.plagitCharcoal) }
            Button { confirmTitle = "Clear Cache"; confirmAction = { }; showConfirmAlert = true } label: { dRow("Clear Platform Cache", "Remove all cached data") }
            Button { confirmTitle = "Maintenance Mode"; confirmAction = { viewModel.settings.maintenanceMode = true; viewModel.saveSettings() }; showConfirmAlert = true } label: { dRow("Maintenance Mode", "Take platform offline") }
            Button { confirmTitle = "Purge Accounts"; confirmAction = { }; showConfirmAlert = true } label: { dRow("Purge Inactive Accounts", "Remove accounts inactive >6 months") }
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
        .overlay(RoundedRectangle(cornerRadius: PlagitRadius.xl).stroke(Color.plagitUrgent.opacity(0.12), lineWidth: 1))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func dRow(_ t: String, _ s: String) -> some View { HStack { VStack(alignment: .leading, spacing: 2) { Text(t).font(PlagitFont.bodyMedium()).foregroundColor(.plagitUrgent); Text(s).font(PlagitFont.micro()).foregroundColor(.plagitTertiary) }; Spacer(); Image(systemName: "chevron.right").font(.system(size: 10, weight: .medium)).foregroundColor(.plagitTertiary) }.padding(.vertical, PlagitSpacing.xs) }

    private func card(_ title: String, _ icon: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) { HStack(spacing: PlagitSpacing.sm) { Image(systemName: icon).font(.system(size: 12, weight: .medium)).foregroundColor(.plagitTeal); Text(title).font(PlagitFont.headline()).foregroundColor(.plagitCharcoal) }; content() }
            .padding(PlagitSpacing.xl).background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY)).padding(.horizontal, PlagitSpacing.xl)
    }

    private func row(_ l: String, _ v: String) -> some View { HStack { Text(l).font(PlagitFont.body()).foregroundColor(.plagitSecondary); Spacer(); Text(v).font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal).lineLimit(1) }.padding(.vertical, PlagitSpacing.xs) }

    private func tog(_ l: String, _ b: Binding<Bool>, _ d: Bool = false) -> some View { HStack { Text(l).font(PlagitFont.body()).foregroundColor(d ? .plagitUrgent : .plagitSecondary); Spacer(); Toggle("", isOn: b).labelsHidden().tint(d ? .plagitUrgent : .plagitTeal) }.padding(.vertical, PlagitSpacing.xs) }
}

#Preview { NavigationStack { AdminSettingsView() }.preferredColorScheme(.light) }
