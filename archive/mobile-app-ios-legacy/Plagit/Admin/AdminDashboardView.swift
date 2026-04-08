//
//  AdminDashboardView.swift
//  Plagit
//
//  Admin Dashboard — Platform Control Center
//

import SwiftUI

struct AdminDashboardView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AdminDashboardViewModel()

    // Navigation
    @State private var showUsers = false
    @State private var showCandidates = false
    @State private var showBusinesses = false
    @State private var showJobs = false
    @State private var showApplications = false
    @State private var showInterviews = false
    @State private var showMessages = false
    @State private var showReports = false
    @State private var showSettings = false
    @State private var showCommunity = false
    @State private var showContentFeatured = false
    @State private var showSubscriptions = false
    @State private var showLogs = false
    @State private var showNotifications = false

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar.background(Color.plagitBackground).zIndex(1)

                if viewModel.showSearch {
                    adminSearchBar.transition(.move(edge: .top).combined(with: .opacity))
                }

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        dateRangeFilter.padding(.top, PlagitSpacing.md)
                        primaryKPIs.padding(.top, PlagitSpacing.lg)
                        secondaryKPIs.padding(.top, PlagitSpacing.md)
                        needsAttention.padding(.top, PlagitSpacing.sectionGap)
                        recentActivity.padding(.top, PlagitSpacing.sectionGap)
                        usersOverview.padding(.top, PlagitSpacing.sectionGap)
                        jobsHealth.padding(.top, PlagitSpacing.sectionGap)
                        applicationsFunnel.padding(.top, PlagitSpacing.sectionGap)
                        interviewsOverview.padding(.top, PlagitSpacing.sectionGap)
                        reportsModeration.padding(.top, PlagitSpacing.sectionGap)
                        communityOverview.padding(.top, PlagitSpacing.sectionGap)
                        billingOverview.padding(.top, PlagitSpacing.sectionGap)
                        quickActions.padding(.top, PlagitSpacing.sectionGap)
                        Spacer().frame(height: PlagitSpacing.xxxl)
                    }
                }
            }
        }
        .task { await viewModel.loadStats() }
        .navigationBarHidden(true)
        .animation(.easeInOut(duration: 0.2), value: viewModel.showSearch)
        .navigationDestination(isPresented: $showCandidates) { AdminCandidatesView().navigationBarHidden(true) }
        .navigationDestination(isPresented: $showBusinesses) { AdminBusinessesView().navigationBarHidden(true) }
        .navigationDestination(isPresented: $showJobs) { AdminJobsView().navigationBarHidden(true) }
        .navigationDestination(isPresented: $showApplications) { AdminApplicationsView().navigationBarHidden(true) }
        .navigationDestination(isPresented: $showInterviews) { AdminInterviewsView().navigationBarHidden(true) }
        .navigationDestination(isPresented: $showMessages) { AdminMessagesView().navigationBarHidden(true) }
        .navigationDestination(isPresented: $showReports) { AdminReportsView().navigationBarHidden(true) }
        .navigationDestination(isPresented: $showSettings) { AdminSettingsView().navigationBarHidden(true) }
    }

    // MARK: - Formatting

    private func fmt(_ n: Int) -> String {
        let f = NumberFormatter(); f.numberStyle = .decimal; return f.string(from: NSNumber(value: n)) ?? "\(n)"
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(alignment: .center) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text("Admin Dashboard").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
                Text("Super Admin").font(PlagitFont.micro()).foregroundColor(.plagitIndigo)
            }

            Spacer()

            HStack(spacing: PlagitSpacing.lg) {
                Button { withAnimation { viewModel.showSearch.toggle(); if !viewModel.showSearch { viewModel.searchText = "" } } } label: {
                    Image(systemName: viewModel.showSearch ? "xmark" : "magnifyingglass").font(.system(size: 18, weight: .regular)).foregroundColor(.plagitCharcoal)
                }

                Button { showNotifications = true } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell").font(.system(size: 18, weight: .regular)).foregroundColor(.plagitCharcoal)
                        Circle().fill(Color.plagitUrgent).frame(width: 7, height: 7).offset(x: 2, y: -2)
                    }
                }

                Circle().fill(Color.plagitIndigo).frame(width: 28, height: 28)
                    .overlay(Text("M").font(.system(size: 11, weight: .bold, design: .rounded)).foregroundColor(.white))
            }
        }
        .padding(.horizontal, PlagitSpacing.xl)
        .padding(.top, PlagitSpacing.lg)
        .padding(.bottom, PlagitSpacing.lg)
    }

    // MARK: - Search

    private var adminSearchBar: some View {
        HStack(spacing: PlagitSpacing.md) {
            Image(systemName: "magnifyingglass").font(.system(size: 14, weight: .medium)).foregroundColor(.plagitTertiary)
            TextField("Search users, jobs, businesses…", text: $viewModel.searchText).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
            if !viewModel.searchText.isEmpty { Button { viewModel.searchText = "" } label: { Image(systemName: "xmark.circle.fill").font(.system(size: 14)).foregroundColor(.plagitTertiary) } }
        }
        .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.md)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Date Range

    private var dateRangeFilter: some View {
        HStack(spacing: PlagitSpacing.sm) {
            ForEach(viewModel.dateRanges, id: \.self) { range in
                let isActive = viewModel.selectedRange == range
                Button { withAnimation { viewModel.selectedRange = range } } label: {
                    Text(range).font(PlagitFont.captionMedium()).foregroundColor(isActive ? .white : .plagitSecondary)
                        .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm)
                        .background(Capsule().fill(isActive ? Color.plagitTeal : Color.plagitSurface))
                        .overlay(Capsule().stroke(isActive ? Color.clear : Color.plagitBorder, lineWidth: 0.5))
                }
            }
            Spacer()
        }
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Primary KPIs

    private var primaryKPIs: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: PlagitSpacing.md), GridItem(.flexible(), spacing: PlagitSpacing.md)], spacing: PlagitSpacing.md) {
            kpiCard(fmt(viewModel.stats.totalUsers), "Total Users", "+8%", "person.2.fill", .plagitTeal) { showUsers = true }
            kpiCard(fmt(viewModel.stats.activeJobs), "Active Jobs", "\(viewModel.stats.jobsNeedReview) need review", "briefcase.fill", .plagitIndigo) { showJobs = true }
            kpiCard(fmt(viewModel.stats.applicationsToday), "Applications Today", "+22%", "doc.text.fill", .plagitAmber) { showApplications = true }
            kpiCard(fmt(viewModel.stats.interviewsToday + viewModel.stats.interviewsTomorrow), "Interviews Scheduled", "\(viewModel.stats.pendingInterviews) pending", "calendar", .plagitOnline) { showInterviews = true }
        }
        .padding(.horizontal, PlagitSpacing.xl)
        .navigationDestination(isPresented: $showUsers) { AdminUsersView().navigationBarHidden(true) }
    }

    // MARK: - Secondary KPIs

    private var secondaryKPIs: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: PlagitSpacing.md), GridItem(.flexible(), spacing: PlagitSpacing.md)], spacing: PlagitSpacing.md) {
            kpiCardSmall(fmt(viewModel.stats.newBusinesses), "New Businesses", .plagitIndigo) { showBusinesses = true }
            kpiCardSmall(fmt(viewModel.stats.newCandidates), "New Candidates", .plagitTeal) { showCandidates = true }
            kpiCardSmall(fmt(viewModel.stats.openReports), "Open Reports", .plagitUrgent) { showReports = true }
            kpiCardSmall(fmt(viewModel.stats.activePlans), "Active Plans", .plagitOnline) { showSubscriptions = true }
        }
        .padding(.horizontal, PlagitSpacing.xl)
        .navigationDestination(isPresented: $showSubscriptions) { AdminSubscriptionsView().navigationBarHidden(true) }
    }

    private func kpiCard(_ number: String, _ label: String, _ insight: String, _ icon: String, _ color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
                HStack {
                    Image(systemName: icon).font(.system(size: 14, weight: .medium)).foregroundColor(color)
                        .frame(width: 30, height: 30)
                        .background(RoundedRectangle(cornerRadius: PlagitRadius.sm).fill(color.opacity(0.10)))
                    Spacer()
                    Text(insight).font(PlagitFont.micro()).foregroundColor(color)
                }
                Text(number).font(PlagitFont.displayMedium()).foregroundColor(.plagitCharcoal)
                Text(label).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
            }
            .padding(PlagitSpacing.lg)
            .background(RoundedRectangle(cornerRadius: PlagitRadius.lg).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        }
    }

    private func kpiCardSmall(_ number: String, _ label: String, _ color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: PlagitSpacing.md) {
                Text(number).font(PlagitFont.headline()).foregroundColor(color)
                Text(label).font(PlagitFont.caption()).foregroundColor(.plagitSecondary).lineLimit(1)
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 9, weight: .medium)).foregroundColor(.plagitTertiary)
            }
            .padding(PlagitSpacing.lg)
            .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
        }
    }

    // MARK: - Needs Attention

    private var needsAttention: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            HStack {
                Text("Needs Attention").font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
                Text("7").font(PlagitFont.micro()).foregroundColor(.white).frame(width: 20, height: 20).background(Circle().fill(Color.plagitUrgent))
                Spacer()
            }

            VStack(spacing: 0) {
                attentionRow("flag.fill", .plagitUrgent, "2 high-priority reports", "High") { showReports = true }
                attentionDivider
                attentionRow("briefcase", .plagitAmber, "5 jobs with no applicants", "Review") { showJobs = true }
                attentionDivider
                attentionRow("building.2", .plagitAmber, "1 business pending verification", "Review") { showBusinesses = true }
                attentionDivider
                attentionRow("calendar", .plagitIndigo, "3 interviews pending confirmation", "Action") { showInterviews = true }
                attentionDivider
                attentionRow("creditcard", .plagitUrgent, "2 failed payments", "Urgent") { showSubscriptions = true }
            }
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
        .overlay(RoundedRectangle(cornerRadius: PlagitRadius.xl).stroke(Color.plagitUrgent.opacity(0.12), lineWidth: 1))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func attentionRow(_ icon: String, _ color: Color, _ text: String, _ badge: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: PlagitSpacing.md) {
                Image(systemName: icon).font(.system(size: 11, weight: .medium)).foregroundColor(color)
                    .frame(width: 24, height: 24).background(RoundedRectangle(cornerRadius: PlagitRadius.sm).fill(color.opacity(0.10)))
                Text(text).font(PlagitFont.caption()).foregroundColor(.plagitSecondary).lineLimit(1)
                Spacer()
                Text(badge).font(PlagitFont.micro()).foregroundColor(badge == "High" || badge == "Urgent" ? .plagitUrgent : .plagitAmber)
                    .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 2)
                    .background(Capsule().fill((badge == "High" || badge == "Urgent" ? Color.plagitUrgent : Color.plagitAmber).opacity(0.08)))
                Image(systemName: "chevron.right").font(.system(size: 9, weight: .medium)).foregroundColor(.plagitTertiary)
            }.padding(.vertical, PlagitSpacing.sm + 2)
        }
    }

    private var attentionDivider: some View {
        Rectangle().fill(Color.plagitDivider).frame(height: 1).padding(.leading, PlagitSpacing.md + 24)
    }

    // MARK: - Recent Activity

    private var recentActivity: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            HStack {
                Text("Recent Activity").font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
                HStack(spacing: PlagitSpacing.xs) {
                    Circle().fill(Color.plagitOnline).frame(width: 6, height: 6)
                        .opacity(viewModel.livePulse ? 1.0 : 0.3)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: viewModel.livePulse)
                    Text("Live").font(PlagitFont.micro()).foregroundColor(.plagitOnline)
                }.padding(.horizontal, PlagitSpacing.sm).padding(.vertical, PlagitSpacing.xs).background(Capsule().fill(Color.plagitOnline.opacity(0.08)))
                Spacer()
                Button { showLogs = true } label: { Text("All Logs").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal) }
            }

            VStack(spacing: 0) {
                activityItem(.plagitOnline, "Business verified — The Ritz London", "2m ago")
                activityItem(.plagitTeal, "Candidate verified — Elena Rossi", "15m ago")
                activityItem(.plagitUrgent, "Report resolved — Spam removed", "32m ago")
                activityItem(.plagitIndigo, "Job approved — Senior Chef at Nobu", "1h ago")
                activityItem(.plagitAmber, "Account suspended — Suspicious activity", "2h ago")
            }
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
        .navigationDestination(isPresented: $showLogs) { AdminLogsView().navigationBarHidden(true) }
    }

    private func activityItem(_ color: Color, _ text: String, _ time: String) -> some View {
        HStack(spacing: PlagitSpacing.md) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(text).font(PlagitFont.caption()).foregroundColor(.plagitSecondary).lineLimit(1)
            Spacer()
            Text(time).font(PlagitFont.micro()).foregroundColor(.plagitTertiary).fixedSize()
        }.padding(.vertical, PlagitSpacing.sm + 2)
    }

    // MARK: - Users Overview

    private var usersOverview: some View {
        dashboardSection("Users Overview", "person.2") {
            HStack(spacing: PlagitSpacing.md) {
                miniStat(fmt(viewModel.stats.totalCandidates), "Candidates", .plagitTeal) { showCandidates = true }
                miniStat(fmt(viewModel.stats.totalBusinesses), "Businesses", .plagitIndigo) { showBusinesses = true }
                miniStat(fmt(viewModel.stats.verifiedUsers), "Verified", .plagitOnline) {}
                miniStat(fmt(viewModel.stats.suspendedUsers), "Suspended", .plagitUrgent) {}
            }
        }
    }

    // MARK: - Jobs Health

    private var jobsHealth: some View {
        dashboardSection("Jobs Health", "briefcase") {
            HStack(spacing: PlagitSpacing.md) {
                miniStat(fmt(viewModel.stats.activeJobs), "Active", .plagitOnline) { showJobs = true }
                miniStat(fmt(viewModel.stats.expiringJobs), "Expiring", .plagitAmber) { showJobs = true }
                miniStat(fmt(viewModel.stats.noApplicantJobs), "No Applicants", .plagitUrgent) { showJobs = true }
                miniStat(fmt(viewModel.stats.pausedJobs), "Paused", .plagitTertiary) { showJobs = true }
            }
        }
    }

    // MARK: - Applications Funnel

    private var applicationsFunnel: some View {
        dashboardSection("Applications Funnel", "doc.text") {
            HStack(spacing: 0) {
                funnelStep("Applied", fmt(viewModel.stats.appliedCount), .plagitTeal, isFirst: true)
                funnelStep("Review", fmt(viewModel.stats.reviewCount), .plagitAmber, isFirst: false)
                funnelStep("Interview", fmt(viewModel.stats.interviewCount), .plagitIndigo, isFirst: false)
                funnelStep("Offer", fmt(viewModel.stats.offerCount), .plagitOnline, isFirst: false)
                funnelStep("Hired", fmt(viewModel.stats.hiredCount), .plagitTeal, isFirst: false)
            }
        }
    }

    private func funnelStep(_ label: String, _ count: String, _ color: Color, isFirst: Bool) -> some View {
        VStack(spacing: PlagitSpacing.xs) {
            Text(count).font(PlagitFont.headline()).foregroundColor(color)
            Text(label).font(PlagitFont.micro()).foregroundColor(.plagitSecondary)
            RoundedRectangle(cornerRadius: 2).fill(color).frame(height: 4)
        }.frame(maxWidth: .infinity)
    }

    // MARK: - Interviews Overview

    private var interviewsOverview: some View {
        dashboardSection("Interviews", "calendar") {
            HStack(spacing: PlagitSpacing.md) {
                miniStat(fmt(viewModel.stats.interviewsToday), "Today", .plagitTeal) { showInterviews = true }
                miniStat(fmt(viewModel.stats.interviewsTomorrow), "Tomorrow", .plagitIndigo) { showInterviews = true }
                miniStat(fmt(viewModel.stats.interviewsThisWeek), "This Week", .plagitAmber) { showInterviews = true }
                miniStat(fmt(viewModel.stats.pendingInterviews), "Pending", .plagitUrgent) { showInterviews = true }
            }
        }
    }

    // MARK: - Reports / Moderation

    private var reportsModeration: some View {
        dashboardSection("Reports & Moderation", "flag") {
            VStack(spacing: PlagitSpacing.sm) {
                HStack(spacing: PlagitSpacing.md) {
                    moderationPill("Fake Jobs", "2", .plagitUrgent)
                    moderationPill("Spam", "1", .plagitAmber)
                    moderationPill("Fake Profiles", "1", .plagitUrgent)
                }
                HStack(spacing: PlagitSpacing.md) {
                    moderationPill("Abusive Messages", "2", .plagitAmber)
                    moderationPill("Community Flags", "0", .plagitTertiary)
                    Spacer()
                }
            }
        }
    }

    private func moderationPill(_ label: String, _ count: String, _ color: Color) -> some View {
        Button { showReports = true } label: {
            HStack(spacing: PlagitSpacing.xs) {
                Text(count).font(PlagitFont.captionMedium()).foregroundColor(color)
                Text(label).font(PlagitFont.micro()).foregroundColor(.plagitSecondary)
            }
            .padding(.horizontal, PlagitSpacing.md).padding(.vertical, PlagitSpacing.sm)
            .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(color.opacity(0.06)))
        }
    }

    // MARK: - Community Overview

    private var communityOverview: some View {
        dashboardSection("Community", "text.bubble") {
            HStack(spacing: PlagitSpacing.md) {
                miniStat(fmt(viewModel.stats.publishedPosts), "Published", .plagitOnline) { showCommunity = true }
                miniStat(fmt(viewModel.stats.draftPosts), "Drafts", .plagitTertiary) { showCommunity = true }
                miniStat(fmt(viewModel.stats.featuredPosts), "Featured", .plagitAmber) { showCommunity = true }
                miniStat(fmt(viewModel.stats.totalViews), "Views", .plagitTeal) {}
            }
        }
        .navigationDestination(isPresented: $showCommunity) { AdminCommunityView().navigationBarHidden(true) }
    }

    // MARK: - Billing Overview

    private var billingOverview: some View {
        dashboardSection("Billing & Subscriptions", "creditcard") {
            HStack(spacing: PlagitSpacing.md) {
                miniStat(fmt(viewModel.stats.activePlans), "Active", .plagitOnline) { showSubscriptions = true }
                miniStat(fmt(viewModel.stats.trialPlans), "Trial", .plagitAmber) { showSubscriptions = true }
                miniStat(fmt(viewModel.stats.renewingPlans), "Renewing", .plagitIndigo) { showSubscriptions = true }
                miniStat(fmt(viewModel.stats.failedPayments), "Failed", .plagitUrgent) { showSubscriptions = true }
            }
        }
    }

    // MARK: - Quick Actions

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            Text("Quick Actions").font(PlagitFont.headline()).foregroundColor(.plagitCharcoal).padding(.horizontal, PlagitSpacing.xl)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: PlagitSpacing.sm) {
                    quickActionChip("star", "Featured Content") { showContentFeatured = true }
                    quickActionChip("star.fill", "Add Featured Employer") { showBusinesses = true }
                    quickActionChip("text.bubble", "Create Community Post") { showCommunity = true }
                    quickActionChip("flag", "Review Reports") { showReports = true }
                    quickActionChip("briefcase", "No-Applicant Jobs") { showJobs = true }
                    quickActionChip("bell", "Send Notification") { showNotifications = true }
                    quickActionChip("gearshape", "Settings") { showSettings = true }
                    quickActionChip("clock.arrow.circlepath", "Admin Logs") { showLogs = true }
                }.padding(.horizontal, PlagitSpacing.xl)
            }
        }
        .navigationDestination(isPresented: $showNotifications) { AdminNotificationsManageView().navigationBarHidden(true) }
        .navigationDestination(isPresented: $showContentFeatured) { AdminContentFeaturedView().navigationBarHidden(true) }
    }

    private func quickActionChip(_ icon: String, _ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: PlagitSpacing.xs) {
                Image(systemName: icon).font(.system(size: 11, weight: .medium))
                Text(label).font(PlagitFont.captionMedium())
            }
            .foregroundColor(.plagitTeal)
            .padding(.horizontal, PlagitSpacing.md).padding(.vertical, PlagitSpacing.sm)
            .background(Capsule().fill(Color.plagitTealLight))
        }
    }

    // MARK: - Shared Helpers

    private func dashboardSection(_ title: String, _ icon: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            HStack(spacing: PlagitSpacing.sm) {
                Image(systemName: icon).font(.system(size: 12, weight: .medium)).foregroundColor(.plagitTeal)
                Text(title).font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
            }
            content()
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func miniStat(_ number: String, _ label: String, _ color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(number).font(PlagitFont.headline()).foregroundColor(color)
                Text(label).font(PlagitFont.micro()).foregroundColor(.plagitSecondary)
            }.frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack { AdminDashboardView() }.preferredColorScheme(.light)
}
