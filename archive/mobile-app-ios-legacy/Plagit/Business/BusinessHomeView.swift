//
//  BusinessHomeView.swift
//  Plagit
//
//  Premium Business Home Screen — Employer
//

import SwiftUI

struct BusinessHomeView: View {
    @State private var selectedContentTab = 0
    @State private var showCreateMenu = false
    @State private var insightPulse = false
    @State private var showApplicants = false
    @State private var showFindStaff = false
    @State private var showActiveJob = false
    @State private var showMessages = false
    @State private var showPostJob = false
    @State private var showInterviews = false
    // (reschedule removed — handled in interview detail view)
    @State private var showDirectChat = false
    @State private var showCandidateProfile = false
    @State private var showHomeSearch = false
    @State private var showNotifications = false
    @State private var showQuickPlug = false
    @State private var bizUnreadCount = 0
    @State private var showInsights = false
    @State private var showShortlist = false
    @State private var showSubscription = false
    @State private var showJobMenu = false
    @State private var showCompanyProfile = false
    @State private var showCommunity = false
    @State private var showJobDetailNav = false
    @State private var selectedJobIdForNav: String?
    @State private var selectedCandidateIdForNav: String?
    @State private var homeSearchText = ""
    @State private var homeRecentSearches: [String] = ["Elena", "Senior Chef", "Interview"]
    @Namespace private var tabAnimation

    // Real data
    @State private var homeData: BusinessHomeDTO?
    @State private var recentApplicants: [BusinessRecentApplicantDTO] = []
    @State private var isLoadingHome = true
    @State private var homeError: String?
    @State private var showWelcome = false

    private var companyName: String { homeData?.business.companyName ?? BusinessAuthService.shared.currentUserName ?? "Your Business" }

    private var hasNextInterview: Bool { homeData?.nextInterview != nil }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.plagitBackground
                .ignoresSafeArea()

            if isLoadingHome {
                VStack(spacing: PlagitSpacing.md) {
                    ProgressView().tint(.plagitTeal)
                    Text(L10n.loadingDashboard).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = homeError {
                VStack(spacing: PlagitSpacing.lg) {
                    Image(systemName: "wifi.exclamationmark").font(.system(size: 36)).foregroundColor(.plagitTertiary)
                    Text(L10n.couldntLoadDashboard).font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
                    Text(error).font(PlagitFont.caption()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center).padding(.horizontal, PlagitSpacing.xxl)
                    Button { Task { await loadHome() } } label: {
                        Text(L10n.tryAgain).font(PlagitFont.captionMedium()).foregroundColor(.white)
                            .padding(.horizontal, PlagitSpacing.xxl).padding(.vertical, PlagitSpacing.md)
                            .background(Capsule().fill(Color.plagitTeal))
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // 1. Header
                    headerSection

                    // 2. Hero
                    if selectedContentTab == 0 {
                        heroSection
                            .padding(.top, PlagitSpacing.sm)

                        // 3. Stats
                        statsSection
                            .padding(.top, PlagitSpacing.lg)

                        // 3b. Next Interview
                        nextInterviewSection
                            .padding(.top, PlagitSpacing.xl)

                        // 4. Quick Actions
                        quickActionsSection
                            .padding(.top, PlagitSpacing.xl)

                        // 4b. Premium upsell
                        if !SubscriptionManager.shared.isBusinessPremium {
                            bizPremiumBanner
                                .padding(.top, PlagitSpacing.xl)
                        }
                    }

                    // 5. Tabs
                    contentTabsSection
                        .padding(.top, selectedContentTab == 0 ? PlagitSpacing.xxl : PlagitSpacing.sm)

                    // Tab content
                    switch selectedContentTab {
                    case 1:
                        candidatesPipelineSection
                            .padding(.top, PlagitSpacing.sectionGap)
                    case 2:
                        operationalActivitySection
                            .padding(.top, PlagitSpacing.sectionGap)
                    default:
                        recommendedTalentSection
                            .padding(.top, PlagitSpacing.sectionGap)
                        activityFeedSection
                            .padding(.top, PlagitSpacing.xxl)
                    }

                    Spacer()
                        .frame(height: 96)
                }
            }

            } // end else (loaded)

            // 8. Bottom Navigation
            bottomNavigationBar

            if showCreateMenu {
                createMenuOverlay
            }

            if showHomeSearch {
                homeSearchOverlay
            }
        }
        .navigationBarHidden(true)
        .task { await loadHome() }
        .onAppear {
            Task { await refreshUnreadCount() }
            if UserDefaults.standard.bool(forKey: "plagit_show_business_welcome") {
                UserDefaults.standard.removeObject(forKey: "plagit_show_business_welcome")
                showWelcome = true
            }
        }
        .alert(L10n.t("welcome_title"), isPresented: $showWelcome) {
            Button("OK") {}
        } message: {
            Text(L10n.t("welcome_business_body"))
        }
        .navigationDestination(isPresented: $showCandidateProfile) {
            if let id = selectedCandidateIdForNav { BusinessRealCandidateProfileView(candidateId: id).navigationBarHidden(true) }
        }
        .navigationDestination(isPresented: $showDirectChat) {
            BusinessRealMessagesView().navigationBarHidden(true)
        }
        .navigationDestination(isPresented: $showApplicants) {
            BusinessRealJobsView().navigationBarHidden(true)
        }
        .navigationDestination(isPresented: $showFindStaff) {
            BusinessNearbyTalentView(
                profileLat: homeData?.business.profileLat,
                profileLng: homeData?.business.profileLng
            ).navigationBarHidden(true)
        }
        .navigationDestination(isPresented: $showJobDetailNav) {
            if let id = selectedJobIdForNav { BusinessRealJobDetailView(jobId: id).navigationBarHidden(true) }
        }
        .navigationDestination(isPresented: $showActiveJob) {
            BusinessRealJobsView().navigationBarHidden(true)
        }
        .navigationDestination(isPresented: $showMessages) {
            BusinessRealMessagesView().navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $showPostJob) {
            NavigationStack { BusinessRealPostJobView().navigationBarHidden(true) }
        }
        .navigationDestination(isPresented: $showInterviews) {
            BusinessRealInterviewsView().navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $showNotifications) {
            NavigationStack { ActivityView(isBusiness: true).navigationBarHidden(true) }
        }
        .navigationDestination(isPresented: $showShortlist) {
            BusinessShortlistView().navigationBarHidden(true)
        }
        .navigationDestination(isPresented: $showInsights) {
            BusinessInsightsView().navigationBarHidden(true)
        }
        .navigationDestination(isPresented: $showSubscription) {
            BusinessSubscriptionView().navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $showCommunity) {
            NavigationStack { CandidateCommunityView().navigationBarHidden(true) }
        }
        .fullScreenCover(isPresented: $showCompanyProfile) {
            NavigationStack { BusinessRealProfileView().navigationBarHidden(true) }
        }
        .navigationDestination(isPresented: $showQuickPlug) {
            BusinessQuickPlugView().navigationBarHidden(true)
        }
        .confirmationDialog("Job Actions", isPresented: $showJobMenu) {
            Button("View Jobs") { showActiveJob = true }
            Button("View Interviews") { showInterviews = true }
            Button(L10n.cancel, role: .cancel) {}
        }
    }

    // MARK: - 1. Header

    private var headerSection: some View {
        HStack(alignment: .center) {
            HStack(spacing: PlagitSpacing.sm) {
                Image("PlagitLogo")
                    .resizable().scaledToFit()
                    .frame(width: 28, height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: PlagitRadius.sm))

                Text(companyName)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.plagitCharcoal)
                    .lineLimit(1)
            }

            Spacer()

            HStack(spacing: PlagitSpacing.lg) {
                // Language toggle pill
                LanguageTogglePill()

                Button {
                    withAnimation(.easeInOut(duration: 0.25)) { showHomeSearch = true }
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.plagitCharcoal)
                }

                Button { showNotifications = true } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: bizUnreadCount > 0 ? "bell.badge.fill" : "bell")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundColor(bizUnreadCount > 0 ? .plagitTeal : .plagitCharcoal)

                        if bizUnreadCount > 0 {
                            Text("\(min(bizUnreadCount, 99))")
                                .font(.system(size: 9, weight: .bold)).foregroundColor(.white)
                                .frame(minWidth: 16, minHeight: 16)
                                .background(Circle().fill(Color.plagitUrgent))
                                .offset(x: 6, y: -4)
                        }
                    }
                }

                Button { showMessages = true } label: {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 19, weight: .regular))
                        .foregroundColor(.plagitCharcoal)
                }
            }
        }
        .padding(.horizontal, PlagitSpacing.xl)
        .padding(.top, PlagitSpacing.xxl)
        .padding(.bottom, PlagitSpacing.lg)
    }

    // MARK: - 2. Hero

    private var heroSection: some View {
        let biz = homeData?.business
        let hue = biz?.avatarHue ?? 0.5
        let initials = biz?.companyInitials ?? "—"
        let newApps = homeData?.stats.newApplicants ?? 0
        let activeJobs = homeData?.stats.activeJobs ?? 0

        return VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            HStack(alignment: .top, spacing: PlagitSpacing.lg) {
                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    Text(L10n.hiringDashboard)
                        .font(PlagitFont.micro())
                        .foregroundColor(.plagitTeal)
                        .textCase(.uppercase)
                        .tracking(1.6)

                    Text(L10n.pipelineActive)
                        .font(PlagitFont.displayLarge())
                        .foregroundColor(.plagitCharcoal)
                        .lineSpacing(2)
                }

                Spacer()

                ProfileAvatarView(
                    photoUrl: biz?.photoUrl,
                    initials: initials,
                    hue: hue,
                    size: 50,
                    verified: biz?.isVerified == true,
                    countryCode: biz?.countryCode
                )
            }

            // Live signal strip
            HStack(spacing: PlagitSpacing.lg) {
                if activeJobs > 0 {
                    HStack(spacing: PlagitSpacing.xs) {
                        Circle().fill(Color.plagitOnline).frame(width: 5, height: 5)
                            .opacity(insightPulse ? 1.0 : 0.3)
                            .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: insightPulse)
                        Text("\(activeJobs) \(L10n.active)").font(PlagitFont.micro()).foregroundColor(.plagitOnline)
                    }.onAppear { insightPulse = true }
                }
                if newApps > 0 {
                    HStack(spacing: PlagitSpacing.xs) {
                        Image(systemName: "arrow.up.right").font(.system(size: 8, weight: .bold)).foregroundColor(.plagitTeal)
                        Text("\(newApps) \(L10n.newThisWeek)").font(PlagitFont.micro()).foregroundColor(.plagitTeal)
                    }
                }
                if activeJobs == 0 && newApps == 0 {
                    Text(L10n.postJobToStart).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                }
            }
        }
        .padding(.horizontal, PlagitSpacing.xxl)
        .padding(.vertical, PlagitSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: PlagitRadius.xl)
                .fill(Color.plagitCardBackground)
                .shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY)
        )
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - 3. Stats

    private var statsSection: some View {
        HStack(spacing: PlagitSpacing.sm + 2) {
            StatCard(number: "\(homeData?.stats.activeJobs ?? 0)", label: "Jobs", icon: "briefcase.fill", color: .plagitTeal) {
                showActiveJob = true
            }
            StatCard(number: "\(homeData?.stats.newApplicants ?? 0)", label: "New Applicants", icon: "person.badge.plus", color: .plagitAmber) {
                showApplicants = true
            }
            StatCard(number: "\(homeData?.stats.interviews ?? 0)", label: "Interviews", icon: "calendar", color: .plagitIndigo) {
                showInterviews = true
            }
        }
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - 4. Quick Actions

    // MARK: - Premium Banner

    private var bizPremiumBanner: some View {
        Button { showSubscription = true } label: {
            HStack(spacing: PlagitSpacing.lg) {
                ZStack {
                    RoundedRectangle(cornerRadius: PlagitRadius.md)
                        .fill(LinearGradient(colors: [Color.plagitIndigo, Color.plagitIndigo.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 48, height: 48)
                    Image(systemName: "crown.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    Text(L10n.t("unlock_business_premium"))
                        .font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                    Text(L10n.t("home_biz_premium_sub"))
                        .font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.plagitIndigo)
            }
            .padding(PlagitSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: PlagitRadius.xl)
                    .fill(Color.plagitCardBackground)
                    .shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private var quickActionsSection: some View {
        HStack(spacing: PlagitSpacing.sm) {
            QuickActionButton(title: "Post Job", icon: "plus.circle.fill", style: .primary, action: { showPostJob = true })
            QuickActionButton(title: "Nearby", icon: "mappin.circle.fill", style: .secondary, action: { showFindStaff = true })
            QuickActionButton(title: "Community", icon: "bubble.left.and.bubble.right.fill", style: .secondary, action: { showCommunity = true })
            QuickActionButton(title: "Messages", icon: "bubble.left.fill", style: .secondary, action: { showMessages = true })
        }
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - 5. Tabs

    private var contentTabsSection: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(Array(["Dashboard", "Candidates", "Activity"].enumerated()), id: \.offset) { index, title in
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            selectedContentTab = index
                        }
                    } label: {
                        VStack(spacing: PlagitSpacing.md) {
                            Text(title)
                                .font(PlagitFont.subheadline())
                                .foregroundColor(selectedContentTab == index ? .plagitCharcoal : .plagitTertiary)

                            ZStack {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 2)

                                if selectedContentTab == index {
                                    Rectangle()
                                        .fill(Color.plagitTeal)
                                        .frame(width: 28, height: 2)
                                        .clipShape(Capsule())
                                        .matchedGeometryEffect(id: "businessTabIndicator", in: tabAnimation)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, PlagitSpacing.xl)

            Rectangle()
                .fill(Color.plagitDivider)
                .frame(height: 1)
        }
    }

    // MARK: - Next Interview (real data)

    private var nextInterviewSection: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.md) {
            HStack {
                HStack(spacing: PlagitSpacing.sm) {
                    Image(systemName: "calendar.badge.clock").font(.system(size: 13, weight: .medium)).foregroundColor(.plagitIndigo)
                    Text(L10n.nextInterview).font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
                }
                Spacer()
                Button { showInterviews = true } label: {
                    Text(L10n.all).font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                }
            }.padding(.horizontal, PlagitSpacing.xl)

            if let iv = homeData?.nextInterview {
                let typeLabel = L10n.interviewType(iv.interviewType)
                let statusColor: Color = iv.status == "confirmed" ? .plagitOnline : .plagitAmber

                Button { showInterviews = true } label: {
                    HStack(spacing: PlagitSpacing.md) {
                        // Date block
                        if let scheduled = iv.scheduledAt {
                            let dateStr = formatInterviewDate(scheduled)
                            let timeStr = formatInterviewTime(scheduled)
                            VStack(spacing: 2) {
                                Text(dateStr.0).font(.system(size: 20, weight: .bold, design: .rounded)).foregroundColor(.plagitTeal)
                                Text(dateStr.1).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                                Text(timeStr).font(PlagitFont.micro()).foregroundColor(.plagitCharcoal)
                            }
                            .frame(width: 52)
                            .padding(.vertical, PlagitSpacing.sm)
                            .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitTealLight))

                            Rectangle().fill(Color.plagitDivider).frame(width: 1, height: 50)
                        }

                        VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
                            Text(iv.candidateName ?? "Candidate")
                                .font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                            Text(iv.jobTitle ?? "")
                                .font(PlagitFont.caption()).foregroundColor(.plagitSecondary)

                            HStack(spacing: PlagitSpacing.sm) {
                                Text(L10n.interviewStatus(iv.status)).font(PlagitFont.micro()).foregroundColor(statusColor)
                                    .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 3)
                                    .background(Capsule().fill(statusColor.opacity(0.08)))
                                Text(typeLabel).font(PlagitFont.micro()).foregroundColor(.plagitIndigo)
                                    .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 3)
                                    .background(Capsule().fill(Color.plagitIndigo.opacity(0.06)))
                            }
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.plagitTertiary)
                    }
                }
                .buttonStyle(.plain)
                .padding(PlagitSpacing.xl)
                .background(
                    RoundedRectangle(cornerRadius: PlagitRadius.xl)
                        .fill(Color.plagitCardBackground)
                        .shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY)
                )
                .overlay(RoundedRectangle(cornerRadius: PlagitRadius.xl).stroke(Color.plagitIndigo.opacity(0.08), lineWidth: 1))
                .padding(.horizontal, PlagitSpacing.xl)
            } else {
                HStack(spacing: PlagitSpacing.md) {
                    ZStack {
                        Circle().fill(Color.plagitSurface).frame(width: 40, height: 40)
                        Image(systemName: "calendar").font(.system(size: 16, weight: .medium)).foregroundColor(.plagitTertiary)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(L10n.noUpcomingInterviews).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
                        Text(L10n.scheduleFromApplicants).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                    }
                    Spacer()
                }
                .padding(PlagitSpacing.xl)
                .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
                .padding(.horizontal, PlagitSpacing.xl)
            }
        }
    }

    // MARK: - 6. Recent Applicants (real data)

    private var recommendedTalentSection: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            HStack {
                Text(L10n.recentApplicants).font(PlagitFont.sectionTitle()).foregroundColor(.plagitCharcoal)
                Spacer()
                Button { showActiveJob = true } label: {
                    HStack(spacing: 4) { Text(L10n.viewAll).font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal); Image(systemName: "chevron.right").font(.system(size: 10, weight: .semibold)).foregroundColor(.plagitTeal) }
                }
            }.padding(.horizontal, PlagitSpacing.xl)

            if recentApplicants.isEmpty {
                Text(L10n.noApplicantsYet)
                    .font(PlagitFont.caption()).foregroundColor(.plagitTertiary).padding(.horizontal, PlagitSpacing.xl)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: PlagitSpacing.md) {
                        ForEach(recentApplicants.prefix(8)) { app in
                            recentApplicantCard(app)
                        }
                    }.padding(.horizontal, PlagitSpacing.xl)
                }
            }
        }
    }

    private func recentApplicantCard(_ app: BusinessRecentApplicantDTO) -> some View {
        let hue = app.candidateAvatarHue ?? 0.5
        return Button { if let jid = app.jobId { selectedJobIdForNav = jid; showJobDetailNav = true } } label: {
            VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
                ProfileAvatarView(photoUrl: app.candidatePhotoUrl, initials: app.candidateInitials ?? "—", hue: hue, size: 40, verified: app.candidateVerified == true)
                Text(app.candidateName ?? "Unknown").font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal).lineLimit(1)
                if let role = app.candidateRole { Text(role).font(PlagitFont.micro()).foregroundColor(.plagitSecondary).lineLimit(1) }
                if let jt = app.jobTitle { Text("for \(jt)").font(PlagitFont.micro()).foregroundColor(.plagitTeal).lineLimit(1) }
            }
            .frame(width: 110).padding(PlagitSpacing.md)
            .background(RoundedRectangle(cornerRadius: PlagitRadius.lg).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        }.buttonStyle(.plain)
    }

    // MARK: - 7. Activity Feed (real data — recent applicants as activity)

    private var activityFeedSection: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            Text(L10n.recentActivity).font(PlagitFont.sectionTitle()).foregroundColor(.plagitCharcoal).padding(.horizontal, PlagitSpacing.xl)

            if recentApplicants.isEmpty {
                Text(L10n.noRecentActivity).font(PlagitFont.caption()).foregroundColor(.plagitTertiary).padding(.horizontal, PlagitSpacing.xl)
            } else {
                ForEach(recentApplicants.prefix(5)) { app in
                    HStack(spacing: PlagitSpacing.md) {
                        let hue = app.candidateAvatarHue ?? 0.5
                        ProfileAvatarView(photoUrl: app.candidatePhotoUrl, initials: app.candidateInitials ?? "—", hue: hue, size: 36, verified: app.candidateVerified == true)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(app.candidateName ?? "Someone") applied for \(app.jobTitle ?? "a job")").font(PlagitFont.caption()).foregroundColor(.plagitCharcoal)
                            Text(L10n.appStatus(app.status)).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                        }; Spacer()
                    }.padding(.horizontal, PlagitSpacing.xl)
                }
            }
        }
    }

    // MARK: - Candidates Pipeline Tab (real data)

    private func appStatusColor(_ s: String) -> Color {
        switch s { case "applied": return .plagitTeal; case "under_review","shortlisted": return .plagitAmber; case "interview": return .plagitIndigo; case "offer": return .plagitOnline; default: return .plagitTertiary }
    }

    private var candidatesPipelineSection: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            Text(L10n.candidatePipeline)
                .font(PlagitFont.sectionTitle()).foregroundColor(.plagitCharcoal)
                .padding(.horizontal, PlagitSpacing.xl)

            if recentApplicants.isEmpty {
                VStack(spacing: PlagitSpacing.md) {
                    Image(systemName: "person.2").font(.system(size: 28)).foregroundColor(.plagitTertiary)
                    Text("No applicants yet").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                    Text("Applicants will appear here when candidates apply to your jobs.").font(PlagitFont.caption()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center)
                }.frame(maxWidth: .infinity).padding(PlagitSpacing.xl).padding(.horizontal, PlagitSpacing.xl)
            } else {
                ForEach(recentApplicants) { app in
                    let hue = app.candidateAvatarHue ?? 0.5
                    let sc = appStatusColor(app.status)
                    Button {
                        if let cid = app.candidateId { selectedCandidateIdForNav = cid; showCandidateProfile = true }
                    } label: {
                        HStack(spacing: PlagitSpacing.md) {
                            ProfileAvatarView(photoUrl: app.candidatePhotoUrl, initials: app.candidateInitials ?? "—", hue: hue, size: 40, verified: app.candidateVerified == true)
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: PlagitSpacing.sm) {
                                    Text(app.candidateName ?? "Unknown").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                                    Text(L10n.appStatus(app.status)).font(PlagitFont.micro()).foregroundColor(sc)
                                        .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 2)
                                        .background(Capsule().fill(sc.opacity(0.08)))
                                }
                                Text("\(app.candidateRole ?? "") · \(app.jobTitle ?? "")").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 10, weight: .medium)).foregroundColor(.plagitTertiary)
                        }
                    }.buttonStyle(.plain)
                    .padding(.horizontal, PlagitSpacing.xl).padding(.vertical, PlagitSpacing.md)
                    .background(RoundedRectangle(cornerRadius: PlagitRadius.lg).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
                    .padding(.horizontal, PlagitSpacing.xl)
                }
            }
        }
    }

    // MARK: - Operational Activity Tab

    private var operationalActivitySection: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            Text(L10n.allApplicants).font(PlagitFont.sectionTitle()).foregroundColor(.plagitCharcoal).padding(.horizontal, PlagitSpacing.xl)

            if recentApplicants.isEmpty {
                Text("No applicant activity yet.").font(PlagitFont.caption()).foregroundColor(.plagitTertiary).padding(.horizontal, PlagitSpacing.xl)
            } else {
                ForEach(recentApplicants) { app in
                    let hue = app.candidateAvatarHue ?? 0.5
                    Button { if let jid = app.jobId { selectedJobIdForNav = jid; showJobDetailNav = true } } label: {
                        HStack(alignment: .top, spacing: PlagitSpacing.md) {
                            ProfileAvatarView(photoUrl: app.candidatePhotoUrl, initials: app.candidateInitials ?? "—", hue: hue, size: 36, verified: app.candidateVerified == true)
                            VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                                Text(app.candidateName ?? "Unknown").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                                Text("\(app.candidateRole ?? "") · \(app.jobTitle ?? "")").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                                Text(L10n.appStatus(app.status)).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                            }; Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 10, weight: .medium)).foregroundColor(.plagitTertiary).padding(.top, 4)
                        }
                    }.buttonStyle(.plain)
                    .padding(PlagitSpacing.lg)
                    .background(RoundedRectangle(cornerRadius: PlagitRadius.lg).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
                    .padding(.horizontal, PlagitSpacing.xl)
                }
            }
        }
    }

    // activityItems removed — using real recentApplicants data instead

    // MARK: - Home Search Overlay

    private var searchApplicantResults: [BusinessRecentApplicantDTO] {
        guard !homeSearchText.isEmpty else { return [] }
        let q = homeSearchText.lowercased()
        return recentApplicants.filter {
            ($0.candidateName?.lowercased().contains(q) ?? false) ||
            ($0.candidateRole?.lowercased().contains(q) ?? false) ||
            ($0.jobTitle?.lowercased().contains(q) ?? false)
        }
    }

    private var homeSearchOverlay: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Search header
                HStack(spacing: PlagitSpacing.md) {
                    Image(systemName: "magnifyingglass").font(.system(size: 16, weight: .medium)).foregroundColor(.plagitTertiary)

                    TextField(L10n.searchCandidates, text: $homeSearchText)
                        .font(PlagitFont.body())
                        .foregroundColor(.plagitCharcoal)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.search)
                        .onSubmit { RecentSearchesView.addSearch(homeSearchText, to: &homeRecentSearches) }

                    if !homeSearchText.isEmpty {
                        Button { homeSearchText = "" } label: {
                            Image(systemName: "xmark.circle.fill").font(.system(size: 16)).foregroundColor(.plagitTertiary)
                        }
                    }

                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) { showHomeSearch = false; homeSearchText = "" }
                    } label: {
                        Text(L10n.cancel).font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                    }
                }
                .padding(.horizontal, PlagitSpacing.xl)
                .padding(.top, PlagitSpacing.xxl)
                .padding(.bottom, PlagitSpacing.lg)

                Rectangle().fill(Color.plagitDivider).frame(height: 1)

                if homeSearchText.isEmpty {
                    if !homeRecentSearches.isEmpty {
                        RecentSearchesView(searches: $homeRecentSearches, searchText: $homeSearchText)
                    } else {
                        VStack(spacing: PlagitSpacing.lg) {
                            Spacer().frame(height: PlagitSpacing.xxxl)
                            Image(systemName: "magnifyingglass").font(.system(size: 32, weight: .light)).foregroundColor(.plagitTertiary)
                            Text("Search across your hiring pipeline").font(PlagitFont.body()).foregroundColor(.plagitSecondary)
                            Text("Find candidates, jobs, interviews, and messages").font(PlagitFont.caption()).foregroundColor(.plagitTertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, PlagitSpacing.xxl)
                    }
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: PlagitSpacing.sectionGap) {
                            if searchApplicantResults.isEmpty {
                                VStack(spacing: PlagitSpacing.lg) {
                                    Spacer().frame(height: PlagitSpacing.xxxl)
                                    Image(systemName: "magnifyingglass").font(.system(size: 28, weight: .light)).foregroundColor(.plagitTertiary)
                                    Text("No results for \"\(homeSearchText)\"").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                                    Text("Try a different search term").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                                }.frame(maxWidth: .infinity)
                            } else {
                                VStack(alignment: .leading, spacing: PlagitSpacing.md) {
                                    Text("Applicants").font(PlagitFont.captionMedium()).foregroundColor(.plagitTertiary).padding(.horizontal, PlagitSpacing.xl)
                                    ForEach(searchApplicantResults) { app in
                                        Button {
                                            showHomeSearch = false; homeSearchText = ""
                                            if let jid = app.jobId { selectedJobIdForNav = jid; showJobDetailNav = true }
                                        } label: {
                                            let hue = app.candidateAvatarHue ?? 0.5
                                            HStack(spacing: PlagitSpacing.md) {
                                                ProfileAvatarView(photoUrl: app.candidatePhotoUrl, initials: app.candidateInitials ?? "—", hue: hue, size: 36, verified: app.candidateVerified == true)
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(app.candidateName ?? "Unknown").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                                                    Text("\(app.candidateRole ?? "") · \(app.jobTitle ?? "")").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                                                }; Spacer()
                                                Image(systemName: "chevron.right").font(.system(size: 10, weight: .medium)).foregroundColor(.plagitTertiary)
                                            }.padding(.horizontal, PlagitSpacing.xl).padding(.vertical, PlagitSpacing.md)
                                        }.buttonStyle(.plain)
                                    }
                                }
                            }
                        }.padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.xxxl)
                    }
                }

                Spacer()
            }
        }
        .transition(.opacity)
    }

    // MARK: - 8. Bottom Navigation

    private var bottomNavigationBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.plagitDivider.opacity(0.4))
                .frame(height: 0.5)

            HStack(spacing: 0) {
                BottomTabItem(icon: "house.fill", label: L10n.home, isActive: true)
                BottomTabItem(icon: "briefcase", label: L10n.jobs, isActive: false)
                    .onTapGesture { showActiveJob = true }

                // Center action button
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showCreateMenu.toggle()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [Color.plagitTeal, Color.plagitTealDark], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 42, height: 42)
                            .shadow(color: Color.plagitTeal.opacity(0.14), radius: 6, y: 2)

                        Image(systemName: showCreateMenu ? "xmark" : "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(showCreateMenu ? 90 : 0))
                    }
                    .offset(y: -2)
                }
                .frame(maxWidth: .infinity)

                BottomTabItem(icon: "bolt.fill", label: "Quick Plug", isActive: false, isPremium: true)
                    .onTapGesture { showQuickPlug = true }
                BottomTabItem(icon: "building.2", label: L10n.profile, isActive: false)
                    .onTapGesture { showCompanyProfile = true }
            }
            .padding(.horizontal, PlagitSpacing.sm)
            .padding(.top, PlagitSpacing.xs + 2)
            .padding(.bottom, PlagitSpacing.xxl)
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea(edges: .bottom)
            )
        }
    }

    // MARK: - Create Menu

    private var createMenuOverlay: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        showCreateMenu = false
                    }
                }

            VStack(spacing: PlagitSpacing.md) {
                CreateMenuItem(icon: "briefcase.fill", title: "Post Job", subtitle: "Reach top candidates") { showCreateMenu = false; DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { showPostJob = true } }
                CreateMenuItem(icon: "square.and.pencil", title: "Create Update", subtitle: "Share company news") { showCreateMenu = false; DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { showCommunity = true } }
                CreateMenuItem(icon: "camera.fill", title: "Add Story", subtitle: "Show your workplace") { showCreateMenu = false }
                CreateMenuItem(icon: "star.fill", title: "View Shortlist", subtitle: "Your saved candidates") { showCreateMenu = false; DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { showShortlist = true } }
                CreateMenuItem(icon: "person.badge.plus", title: "Invite Candidate", subtitle: "Reach out directly") { showCreateMenu = false; DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { showFindStaff = true } }
            }
            .padding(PlagitSpacing.xl)
            .padding(.bottom, 96)
            .background(
                RoundedRectangle(cornerRadius: PlagitRadius.xxl)
                    .fill(Color.plagitCardBackground)
                    .ignoresSafeArea(edges: .bottom)
            )
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    // MARK: - Load Dashboard

    private func formatInterviewDate(_ iso: String) -> (String, String) {
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = f.date(from: iso) ?? ISO8601DateFormatter().date(from: iso) else { return ("?", "") }
        let day = DateFormatter(); day.dateFormat = "d"
        let month = DateFormatter(); month.dateFormat = "MMM"
        return (day.string(from: date), month.string(from: date).uppercased())
    }
    private func formatInterviewTime(_ iso: String) -> String {
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = f.date(from: iso) ?? ISO8601DateFormatter().date(from: iso) else { return "" }
        let tf = DateFormatter(); tf.dateFormat = "h:mm a"; return tf.string(from: date)
    }

    private func refreshUnreadCount() async {
        if let notifs = try? await BusinessAPIService.shared.fetchNotifications(isRead: false) {
            bizUnreadCount = notifs.count
        }
    }

    private func loadHome() async {
        isLoadingHome = true; homeError = nil
        do {
            async let h = BusinessAPIService.shared.fetchHome()
            async let a = BusinessAPIService.shared.fetchRecentApplicants(limit: 10)
            (homeData, recentApplicants) = try await (h, a)
            // Sync locale from backend
            if let lang = homeData?.business.appLanguageCode, !lang.isEmpty { AppLocaleManager.shared.setLanguage(lang) }
            if let cc = homeData?.business.countryCode { AppLocaleManager.shared.countryCode = cc }
            if let spoken = homeData?.business.spokenLanguages, !spoken.isEmpty {
                AppLocaleManager.shared.spokenLanguages = spoken.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            }
        } catch {
            homeError = error.localizedDescription
        }
        isLoadingHome = false
        // Load unread notification count
        if let notifs = try? await BusinessAPIService.shared.fetchNotifications(isRead: false) {
            bizUnreadCount = notifs.count
        }
    }
}

// MARK: - Preview

#Preview {
    BusinessHomeView()
        .preferredColorScheme(.light)
}

// Legacy components (RecommendedCandidateCard, BusinessActivityCard) removed — no longer used

