//
//  SuperAdminHomeView.swift
//  Plagit
//
//  Super Admin Control Center — Central entry point for all admin sections.
//

import SwiftUI

struct SuperAdminHomeView: View {
    @State private var viewModel = SuperAdminHomeViewModel()

    // Navigation
    @State private var showDashboard = false
    @State private var showUsers = false
    @State private var showBusinesses = false
    @State private var showCandidates = false
    @State private var showJobs = false
    @State private var showApplications = false
    @State private var showInterviews = false
    @State private var showMessages = false
    @State private var showCommunity = false
    @State private var showContentFeatured = false
    @State private var showNotifications = false
    @State private var showReports = false
    @State private var showSubscriptions = false
    @State private var showLogs = false
    @State private var showSettings = false
    @State private var showChangePassword = false
    @State private var showMatches = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.plagitBackground.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        headerSection
                        summaryStats.padding(.top, PlagitSpacing.lg)
                        needsAttentionBanner.padding(.top, PlagitSpacing.sectionGap)
                        quickActions.padding(.top, PlagitSpacing.sectionGap)
                        platformOverview.padding(.top, PlagitSpacing.sectionGap)
                        peopleSection.padding(.top, PlagitSpacing.sectionGap)
                        hiringSection.padding(.top, PlagitSpacing.sectionGap)
                        contentCommSection.padding(.top, PlagitSpacing.sectionGap)
                        revenueSection.padding(.top, PlagitSpacing.sectionGap)
                        systemSection.padding(.top, PlagitSpacing.sectionGap)
                        Spacer().frame(height: PlagitSpacing.xxxl * 2)
                    }
                }
            }
            .navigationBarHidden(true)
            .task { await viewModel.loadStats() }
        }
    }

    // MARK: - Formatting

    private func fmt(_ n: Int) -> String {
        let f = NumberFormatter(); f.numberStyle = .decimal; return f.string(from: NSNumber(value: n)) ?? "\(n)"
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.greeting)
                    .font(PlagitFont.caption())
                    .foregroundColor(.plagitSecondary)
                Text("Super Admin")
                    .font(PlagitFont.displayLarge())
                    .foregroundColor(.plagitCharcoal)
            }

            Spacer()

            HStack(spacing: PlagitSpacing.lg) {
                Button { showNotifications = true } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(.plagitCharcoal)
                        Circle().fill(Color.plagitUrgent)
                            .frame(width: 7, height: 7)
                            .offset(x: 2, y: -2)
                    }
                }

                Menu {
                    Section {
                        Label(AdminAuthService.shared.currentUserName ?? "Admin", systemImage: "person.circle")
                        if let email = AdminAuthService.shared.currentUserEmail {
                            Text(email)
                        }
                    }
                    Divider()
                    Button { showChangePassword = true } label: {
                        Label("Change Password", systemImage: "lock.rotation")
                    }
                    Button(role: .destructive) {
                        AdminAuthService.shared.logout()
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                } label: {
                    Circle().fill(Color.plagitIndigo)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text(String((AdminAuthService.shared.currentUserName ?? "A").prefix(1)))
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        )
                }
            }
        }
        .padding(.horizontal, PlagitSpacing.xl)
        .padding(.top, PlagitSpacing.xl)
        .padding(.bottom, PlagitSpacing.sm)
        .navigationDestination(isPresented: $showNotifications) {
            AdminNotificationsManageView().navigationBarHidden(true)
        }
    }

    // MARK: - Summary Stats

    private var summaryStats: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PlagitSpacing.md) {
                summaryStatCard(fmt(viewModel.stats.totalUsers), "Total Users", "person.2.fill", .plagitTeal) { showUsers = true }
                summaryStatCard(fmt(viewModel.stats.totalBusinesses), "Active Businesses", "building.2.fill", .plagitIndigo) { showBusinesses = true }
                summaryStatCard(fmt(viewModel.stats.activeJobs), "Live Jobs", "briefcase.fill", .plagitOnline) { showJobs = true }
                summaryStatCard(fmt(viewModel.stats.applicationsToday), "Applications Today", "doc.text.fill", .plagitAmber) { showApplications = true }
                summaryStatCard(fmt(viewModel.stats.interviewsToday), "Interviews Today", "calendar", .plagitTeal) { showInterviews = true }
                summaryStatCard(fmt(viewModel.stats.flaggedContent), "Flagged Content", "flag.fill", .plagitUrgent) { showReports = true }
                summaryStatCard(fmt(viewModel.stats.activePlans), "Active Subs", "creditcard.fill", .plagitOnline) { showSubscriptions = true }
            }
            .padding(.horizontal, PlagitSpacing.xl)
        }
    }

    private func summaryStatCard(_ value: String, _ label: String, _ icon: String, _ color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: PlagitSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color)
                    .frame(width: 36, height: 36)
                    .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(color.opacity(0.10)))

                Text(value)
                    .font(PlagitFont.displayMedium())
                    .foregroundColor(.plagitCharcoal)

                Text(label)
                    .font(PlagitFont.micro())
                    .foregroundColor(.plagitSecondary)
                    .lineLimit(1)
            }
            .frame(width: 120)
            .padding(.vertical, PlagitSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: PlagitRadius.lg)
                    .fill(Color.plagitCardBackground)
                    .shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY)
            )
        }
    }

    // MARK: - Needs Attention

    private var attentionItems: [(icon: String, color: Color, text: String, badge: String, action: () -> Void)] {
        var items: [(icon: String, color: Color, text: String, badge: String, action: () -> Void)] = []
        let s = viewModel.stats
        if s.urgentReports > 0 { items.append(("flag.fill", .plagitUrgent, "\(s.urgentReports) high-priority report\(s.urgentReports == 1 ? "" : "s")", "Urgent", { showReports = true })) }
        if s.failedPayments > 0 { items.append(("creditcard", .plagitUrgent, "\(s.failedPayments) failed payment\(s.failedPayments == 1 ? "" : "s")", "Urgent", { showSubscriptions = true })) }
        if s.pendingInterviews > 0 { items.append(("calendar", .plagitIndigo, "\(s.pendingInterviews) interview\(s.pendingInterviews == 1 ? "" : "s") pending confirmation", "Action", { showInterviews = true })) }
        if s.pendingBusinessVerification > 0 { items.append(("building.2", .plagitAmber, "\(s.pendingBusinessVerification) business\(s.pendingBusinessVerification == 1 ? "" : "es") pending verification", "Review", { showBusinesses = true })) }
        if s.noApplicantJobs > 0 { items.append(("briefcase", .plagitAmber, "\(s.noApplicantJobs) job\(s.noApplicantJobs == 1 ? "" : "s") with no applicants", "Review", { showJobs = true })) }
        return items
    }

    private var needsAttentionBanner: some View {
        let items = attentionItems
        return VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            HStack {
                Text("Needs Attention")
                    .font(PlagitFont.headline())
                    .foregroundColor(.plagitCharcoal)
                if items.count > 0 {
                    Text("\(items.count)")
                        .font(PlagitFont.micro())
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .background(Circle().fill(Color.plagitUrgent))
                }
                Spacer()
            }

            if items.isEmpty {
                HStack(spacing: PlagitSpacing.sm) {
                    Image(systemName: "checkmark.circle.fill").font(.system(size: 14, weight: .medium)).foregroundColor(.plagitOnline)
                    Text("All clear — nothing needs attention right now.").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                }.padding(.vertical, PlagitSpacing.sm)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                        if index > 0 { attentionDivider }
                        attentionRow(item.icon, item.color, item.text, item.badge, action: item.action)
                    }
                }
            }
        }
        .padding(PlagitSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: PlagitRadius.xl)
                .fill(Color.plagitCardBackground)
                .shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY)
        )
        .overlay(
            RoundedRectangle(cornerRadius: PlagitRadius.xl)
                .stroke(Color.plagitUrgent.opacity(0.12), lineWidth: 1)
        )
        .padding(.horizontal, PlagitSpacing.xl)
        .navigationDestination(isPresented: $showReports) {
            AdminReportsView().navigationBarHidden(true)
        }
        .navigationDestination(isPresented: $showSubscriptions) {
            AdminSubscriptionsView().navigationBarHidden(true)
        }
        .navigationDestination(isPresented: $showInterviews) {
            AdminInterviewsView().navigationBarHidden(true)
        }
    }

    private func attentionRow(_ icon: String, _ color: Color, _ text: String, _ badge: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: PlagitSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(color)
                    .frame(width: 24, height: 24)
                    .background(RoundedRectangle(cornerRadius: PlagitRadius.sm).fill(color.opacity(0.10)))

                Text(text)
                    .font(PlagitFont.caption())
                    .foregroundColor(.plagitSecondary)
                    .lineLimit(1)

                Spacer()

                Text(badge)
                    .font(PlagitFont.micro())
                    .foregroundColor(badge == "Urgent" ? .plagitUrgent : .plagitAmber)
                    .padding(.horizontal, PlagitSpacing.sm)
                    .padding(.vertical, 2)
                    .background(
                        Capsule().fill((badge == "Urgent" ? Color.plagitUrgent : Color.plagitAmber).opacity(0.08))
                    )

                Image(systemName: "chevron.right")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.plagitTertiary)
            }
            .padding(.vertical, PlagitSpacing.sm + 2)
        }
    }

    private var attentionDivider: some View {
        Rectangle().fill(Color.plagitDivider).frame(height: 1)
            .padding(.leading, PlagitSpacing.md + 24)
    }

    // MARK: - Quick Actions

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.md) {
            Text("Quick Actions")
                .font(PlagitFont.headline())
                .foregroundColor(.plagitCharcoal)
                .padding(.horizontal, PlagitSpacing.xl)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: PlagitSpacing.sm) {
                    quickActionChip("flag", "Review Flagged Content") { showReports = true }
                    quickActionChip("calendar", "Today's Interviews") { showInterviews = true }
                    quickActionChip("exclamationmark.triangle", "Open Reports") { showReports = true }
                    quickActionChip("creditcard", "Manage Subscriptions") { showSubscriptions = true }
                    quickActionChip("star", "Featured Content") { showContentFeatured = true }
                    quickActionChip("text.bubble", "Create Community Post") { showCommunity = true }
                    quickActionChip("bell", "Send Notification") { showNotifications = true }
                    quickActionChip("chart.bar.xaxis", "Analytics Dashboard") { showDashboard = true }
                }
                .padding(.horizontal, PlagitSpacing.xl)
            }
        }
    }

    private func quickActionChip(_ icon: String, _ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: PlagitSpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .medium))
                Text(label)
                    .font(PlagitFont.captionMedium())
            }
            .foregroundColor(.plagitTeal)
            .padding(.horizontal, PlagitSpacing.md)
            .padding(.vertical, PlagitSpacing.sm)
            .background(Capsule().fill(Color.plagitTealLight))
        }
    }

    // MARK: - Platform Overview

    private var platformOverview: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.md) {
            Text("Platform Overview")
                .font(PlagitFont.sectionTitle())
                .foregroundColor(.plagitCharcoal)
                .padding(.horizontal, PlagitSpacing.xl)

            // Dashboard hero card
            Button { showDashboard = true } label: {
                HStack(spacing: PlagitSpacing.lg) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.plagitTeal)
                        .frame(width: 40, height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: PlagitRadius.md)
                                .fill(Color.plagitTeal.opacity(0.12))
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Analytics Dashboard")
                            .font(PlagitFont.headline())
                            .foregroundColor(.plagitCharcoal)
                        Text("KPIs, trends, and platform health")
                            .font(PlagitFont.caption())
                            .foregroundColor(.plagitSecondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.plagitTeal)
                }
                .padding(PlagitSpacing.xl)
                .background(
                    RoundedRectangle(cornerRadius: PlagitRadius.xl)
                        .fill(
                            LinearGradient(
                                colors: [Color.plagitTeal.opacity(0.08), Color.plagitTeal.opacity(0.03)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: PlagitRadius.xl)
                        .stroke(Color.plagitTeal.opacity(0.15), lineWidth: 1)
                )
            }
            .padding(.horizontal, PlagitSpacing.xl)

            // Platform health mini stats
            HStack(spacing: PlagitSpacing.md) {
                platformMiniStat(fmt(viewModel.stats.totalUsers), "Users", .plagitTeal)
                platformMiniStat(fmt(viewModel.stats.activeJobs), "Jobs", .plagitIndigo)
                platformMiniStat(fmt(viewModel.stats.applicationsToday), "Apps Today", .plagitOnline)
                platformMiniStat(fmt(viewModel.stats.openReports), "Reports", viewModel.stats.openReports > 0 ? .plagitUrgent : .plagitOnline)
            }
            .padding(.horizontal, PlagitSpacing.xl)
        }
        .navigationDestination(isPresented: $showDashboard) {
            AdminDashboardView().navigationBarHidden(true)
        }
    }

    private func platformMiniStat(_ value: String, _ label: String, _ color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(PlagitFont.headline())
                .foregroundColor(color)
            Text(label)
                .font(PlagitFont.micro())
                .foregroundColor(.plagitSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, PlagitSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: PlagitRadius.md)
                .fill(Color.plagitSurface)
        )
    }

    // MARK: - People

    private var peopleSection: some View {
        sectionGroup("People") {
            sectionRow("person.2.fill", .plagitTeal, "Users", "All platform users", fmt(viewModel.stats.totalUsers), .plagitTeal) { showUsers = true }
            sectionDivider
            sectionRow("person.text.rectangle", .plagitIndigo, "Candidates", "Job seeker profiles", fmt(viewModel.stats.totalCandidates), .plagitIndigo) { showCandidates = true }
            sectionDivider
            sectionRow("building.2.fill", .plagitAmber, "Businesses", "Employer accounts", fmt(viewModel.stats.totalBusinesses), .plagitAmber) { showBusinesses = true }
        }
        .navigationDestination(isPresented: $showUsers) {
            AdminUsersView().navigationBarHidden(true)
        }
        .navigationDestination(isPresented: $showCandidates) {
            AdminCandidatesView().navigationBarHidden(true)
        }
        .navigationDestination(isPresented: $showBusinesses) {
            AdminBusinessesView().navigationBarHidden(true)
        }
    }

    // MARK: - Hiring Operations

    private var hiringSection: some View {
        sectionGroup("Hiring Operations") {
            sectionRow("briefcase.fill", .plagitIndigo, "Jobs", "Active job listings", fmt(viewModel.stats.activeJobs), .plagitIndigo) { showJobs = true }
            sectionDivider
            sectionRow("checkmark.seal.fill", .plagitOnline, "Matches", "Role + job type matches", "", .plagitOnline) { showMatches = true }
            sectionDivider
            sectionRow("doc.text.fill", .plagitTeal, "Applications", "Submitted applications", "\(fmt(viewModel.stats.applicationsToday)) today", .plagitTeal) { showApplications = true }
            sectionDivider
            sectionRow("calendar", .plagitOnline, "Interviews", "Scheduled interviews", fmt(viewModel.stats.interviewsToday + viewModel.stats.interviewsTomorrow), .plagitOnline) { showInterviews = true }
        }
        .navigationDestination(isPresented: $showJobs) {
            AdminJobsView().navigationBarHidden(true)
        }
        .navigationDestination(isPresented: $showMatches) {
            AdminMatchesView().navigationBarHidden(true)
        }
        .navigationDestination(isPresented: $showApplications) {
            AdminApplicationsView().navigationBarHidden(true)
        }
    }

    // MARK: - Content & Communication

    private var contentCommSection: some View {
        sectionGroup("Content & Communication") {
            sectionRow("bubble.left.and.bubble.right.fill", .plagitTeal, "Messages", "User conversations", "\(fmt(viewModel.stats.unreadMessages)) unread", .plagitAmber) { showMessages = true }
            sectionDivider
            sectionRow("bell.fill", .plagitAmber, "Notifications", "Push & in-app alerts", "\(fmt(viewModel.stats.pendingNotifications)) pending", .plagitAmber) { showNotifications = true }
            sectionDivider
            sectionRow("text.bubble.fill", .plagitTeal, "Community", "Posts and discussions", "\(fmt(viewModel.stats.publishedPosts)) posts", .plagitTeal) { showCommunity = true }
            sectionDivider
            sectionRow("star.fill", .plagitAmber, "Featured Content", "Highlighted content", "\(fmt(viewModel.stats.featuredPosts)) featured", .plagitAmber) { showContentFeatured = true }
        }
        .navigationDestination(isPresented: $showMessages) {
            AdminMessagesView().navigationBarHidden(true)
        }
        .navigationDestination(isPresented: $showCommunity) {
            AdminCommunityView().navigationBarHidden(true)
        }
        .navigationDestination(isPresented: $showContentFeatured) {
            AdminContentFeaturedView().navigationBarHidden(true)
        }
    }

    // MARK: - Business & Revenue

    private var revenueSection: some View {
        sectionGroup("Business & Revenue") {
            sectionRow("creditcard.fill", .plagitOnline, "Subscriptions", "Plans and billing", "\(fmt(viewModel.stats.activePlans)) active", .plagitOnline) { showSubscriptions = true }
            sectionDivider
            sectionRow("flag.fill", .plagitUrgent, "Reports", "Flags and moderation", "\(fmt(viewModel.stats.openReports)) open", .plagitUrgent) { showReports = true }
        }
    }

    // MARK: - System Control

    private var systemSection: some View {
        sectionGroup("System Control") {
            sectionRow("clock.arrow.circlepath", .plagitIndigo, "Logs", "Admin activity logs", "", .plagitTertiary) { showLogs = true }
            sectionDivider
            sectionRow("gearshape.fill", .plagitSecondary, "Settings", "Platform configuration", "", .plagitTertiary) { showSettings = true }
        }
        .navigationDestination(isPresented: $showLogs) {
            AdminLogsView().navigationBarHidden(true)
        }
        .navigationDestination(isPresented: $showSettings) {
            AdminSettingsView().navigationBarHidden(true)
        }
        .navigationDestination(isPresented: $showChangePassword) {
            AdminChangePasswordView().navigationBarHidden(true)
        }
    }

    // MARK: - Shared Helpers

    private func sectionGroup(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.md) {
            Text(title)
                .font(PlagitFont.sectionTitle())
                .foregroundColor(.plagitCharcoal)
                .padding(.horizontal, PlagitSpacing.xl)

            VStack(spacing: 0) {
                content()
            }
            .padding(.horizontal, PlagitSpacing.xl)
            .background(
                RoundedRectangle(cornerRadius: PlagitRadius.xl)
                    .fill(Color.plagitCardBackground)
                    .shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY)
            )
            .padding(.horizontal, PlagitSpacing.xl)
        }
    }

    private func sectionRow(_ icon: String, _ iconColor: Color, _ title: String, _ subtitle: String, _ badge: String, _ badgeColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: PlagitSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(iconColor)
                    .frame(width: 28, height: 28)
                    .background(RoundedRectangle(cornerRadius: PlagitRadius.sm).fill(iconColor.opacity(0.10)))

                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(PlagitFont.bodyMedium())
                        .foregroundColor(.plagitCharcoal)
                    Text(subtitle)
                        .font(PlagitFont.caption())
                        .foregroundColor(.plagitTertiary)
                }

                Spacer()

                if !badge.isEmpty {
                    Text(badge)
                        .font(PlagitFont.micro())
                        .foregroundColor(badgeColor)
                        .padding(.horizontal, PlagitSpacing.sm)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(badgeColor.opacity(0.08)))
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.plagitTertiary)
            }
            .padding(.vertical, PlagitSpacing.md)
        }
    }

    private var sectionDivider: some View {
        Rectangle().fill(Color.plagitDivider).frame(height: 1)
            .padding(.leading, 28 + PlagitSpacing.md)
    }
}

// MARK: - Preview

#Preview {
    SuperAdminHomeView()
        .preferredColorScheme(.light)
}
