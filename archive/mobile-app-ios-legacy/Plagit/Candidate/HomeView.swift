//
//  HomeView.swift
//  Plagit
//
//  Ultra-Premium Home Screen
//

import SwiftUI

struct HomeView: View {
    @State private var auth = CandidateAuthService.shared

    // Navigation state
    @State private var showJobDetail = false
    @State private var selectedJobId: String?
    @State private var showMyApplications = false
    @State private var showMessages = false
    @State private var showFindWork = false
    @State private var showNearbyJobs = false
    @State private var showInterviews = false
    @State private var showProfile = false
    @State private var applicationsInitialFilter = "All"
    @State private var showCommunityFeed = false
    @State private var showSearch = false
    @State private var showNotifications = false
    @State private var showQuickPlug = false
    @State private var showMatches = false
    @State private var showSubscription = false
    @State private var candUnreadCount = 0
    @State private var searchText = ""
    @State private var homeRecentSearches: [String] = []

    // Real data state
    @State private var homeData: CandidateHomeDTO?
    @State private var featuredJobs: [FeaturedJobDTO] = []
    @State private var communityPosts: [FeedPostDTO] = []
    @State private var isLoadingHome = true
    @State private var homeError: String?

    // (quick filters removed — handled in CandidateJobsView now)

    // Greeting based on time of day
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return L10n.goodMorning }
        if hour < 17 { return L10n.goodAfternoon }
        return L10n.goodEvening
    }

    private var userName: String {
        homeData?.user.name ?? auth.currentUserName ?? "there"
    }

    private var userFirstName: String {
        userName.split(separator: " ").first.map(String.init) ?? userName
    }

    private var userLocation: String {
        homeData?.user.location ?? ""
    }

    private var hasNextInterview: Bool {
        homeData?.nextInterview != nil
    }

    private func formatInterviewDate(_ iso: String?) -> String? {
        guard let iso else { return nil }
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = f.date(from: iso) ?? ISO8601DateFormatter().date(from: iso) else { return nil }
        let df = DateFormatter()
        df.dateFormat = "EEE, MMM d · h:mm a"
        return df.string(from: date)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.plagitBackground.ignoresSafeArea()

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
                    Button { Task { await loadDashboard() } } label: {
                        Text(L10n.tryAgain).font(PlagitFont.captionMedium()).foregroundColor(.white)
                            .padding(.horizontal, PlagitSpacing.xxl).padding(.vertical, PlagitSpacing.md)
                            .background(Capsule().fill(Color.plagitTeal))
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        headerSection
                        searchSection.padding(.top, PlagitSpacing.md)
                        nearbyBanner.padding(.top, PlagitSpacing.lg)
                        nextStepSection.padding(.top, PlagitSpacing.xl)
                        matchesBanner.padding(.top, PlagitSpacing.xl)
                        if !SubscriptionManager.shared.isCandidatePremium {
                            premiumBanner.padding(.top, PlagitSpacing.xl)
                        }
                        jobsNearYouSection.padding(.top, PlagitSpacing.xl)
                        recommendedJobsSection.padding(.top, PlagitSpacing.xl)
                        applicationsSummary.padding(.top, PlagitSpacing.xl)
                        if hasNextInterview { nextInterviewCard.padding(.top, PlagitSpacing.xl) }
                        messagesPreview.padding(.top, PlagitSpacing.xl)
                        profileStrength.padding(.top, PlagitSpacing.xl)
                        communityPreview.padding(.top, PlagitSpacing.xl)
                        Spacer().frame(height: 96)
                    }
                }

                candidateBottomNav
            }
        }
        .navigationBarHidden(true)
        .task { await loadDashboard() }
        .navigationDestination(isPresented: $showJobDetail) {
            CandidateJobDetailView(jobId: selectedJobId ?? "").navigationBarHidden(true)
        }
        .navigationDestination(isPresented: $showMyApplications) { MyApplicationsView(initialFilter: applicationsInitialFilter).navigationBarHidden(true) }
        .navigationDestination(isPresented: $showMessages) { CandidateMessagesView().navigationBarHidden(true) }
        .navigationDestination(isPresented: $showMatches) { CandidateMatchesView().navigationBarHidden(true) }
        .navigationDestination(isPresented: $showSubscription) { CandidateSubscriptionView().navigationBarHidden(true) }
        .navigationDestination(isPresented: $showFindWork) { CandidateJobsView().navigationBarHidden(true) }
        .navigationDestination(isPresented: $showNearbyJobs) {
            CandidateNearbyRealView(
                profileLat: homeData?.user.profileLat,
                profileLng: homeData?.user.profileLng
            ).navigationBarHidden(true)
        }
        .navigationDestination(isPresented: $showInterviews) { CandidateInterviewsListView().navigationBarHidden(true) }
        .navigationDestination(isPresented: $showProfile) { CandidateRealProfileView().navigationBarHidden(true) }
        .navigationDestination(isPresented: $showNotifications) { ActivityView(isBusiness: false).navigationBarHidden(true) }
        .navigationDestination(isPresented: $showQuickPlug) { CandidateQuickPlugView().navigationBarHidden(true) }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .center, spacing: PlagitSpacing.md) {
            Button { showProfile = true } label: {
                ProfileAvatarView(
                    photoUrl: homeData?.user.photoUrl,
                    initials: homeData?.user.initials ?? "?",
                    hue: homeData?.user.avatarHue ?? 0.5,
                    size: 56,
                    countryCode: homeData?.user.countryCode
                )
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: PlagitSpacing.sm) {
                    Text("\(greeting), \(userFirstName)")
                        .font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
                    if SubscriptionManager.shared.isCandidatePremium {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.plagitAmber)
                    }
                }
                if !userLocation.isEmpty {
                    HStack(spacing: PlagitSpacing.xs) {
                        Image(systemName: "mappin").font(.system(size: 9, weight: .semibold)).foregroundColor(.plagitTeal)
                        Text(userLocation).font(PlagitFont.micro()).foregroundColor(.plagitTeal)
                    }
                }
            }
            Spacer()
            HStack(spacing: PlagitSpacing.md + 2) {
                // Language toggle pill
                LanguageTogglePill()

                Button { showNotifications = true } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: candUnreadCount > 0 ? "bell.badge.fill" : "bell")
                            .font(.system(size: 19, weight: .regular))
                            .foregroundColor(candUnreadCount > 0 ? .plagitTeal : .plagitCharcoal)
                        if candUnreadCount > 0 {
                            Text("\(min(candUnreadCount, 99))")
                                .font(.system(size: 9, weight: .bold)).foregroundColor(.white)
                                .frame(minWidth: 16, minHeight: 16)
                                .background(Circle().fill(Color.plagitUrgent))
                                .offset(x: 6, y: -4)
                        }
                    }
                }
                Button { showMessages = true } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bubble.left.and.bubble.right").font(.system(size: 18, weight: .regular)).foregroundColor(.plagitCharcoal)
                        if (homeData?.unreadMessages ?? 0) > 0 {
                            Circle().fill(Color.plagitUrgent).frame(width: 6, height: 6).offset(x: 3, y: -1)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.xxl).padding(.bottom, PlagitSpacing.md)
    }

    // MARK: - Search

    private var searchSection: some View {
        HStack(spacing: PlagitSpacing.md) {
            Image(systemName: "magnifyingglass").font(.system(size: 15, weight: .medium)).foregroundColor(.plagitTertiary)
            TextField(L10n.searchJobsPlaceholder, text: $searchText).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
                .submitLabel(.search).onSubmit { RecentSearchesView.addSearch(searchText, to: &homeRecentSearches) }
            if !searchText.isEmpty { Button { searchText = "" } label: { Image(systemName: "xmark.circle.fill").font(.system(size: 15)).foregroundColor(.plagitTertiary) } }
        }
        .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.md + 2)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.lg).fill(Color.plagitSurface))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Nearby Banner

    // MARK: - Matches Banner

    private var matchesBanner: some View {
        Button { showMatches = true } label: {
            HStack(spacing: PlagitSpacing.lg) {
                ZStack {
                    RoundedRectangle(cornerRadius: PlagitRadius.md)
                        .fill(LinearGradient(colors: [Color.plagitOnline, Color.plagitTeal], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 48, height: 48)
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    Text("Your Matches")
                        .font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                    Text("Jobs matching your role and job type")
                        .font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.plagitTeal)
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

    // MARK: - Premium Banner

    private var premiumBanner: some View {
        Button { showSubscription = true } label: {
            HStack(spacing: PlagitSpacing.lg) {
                ZStack {
                    RoundedRectangle(cornerRadius: PlagitRadius.md)
                        .fill(LinearGradient(colors: [Color.plagitAmber, Color.plagitAmber.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 48, height: 48)
                    Image(systemName: "crown.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    Text(L10n.t("unlock_candidate_premium"))
                        .font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                    Text(L10n.t("home_premium_sub"))
                        .font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.plagitAmber)
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

    private var nearbyBanner: some View {
        Button { showNearbyJobs = true } label: {
            HStack(spacing: PlagitSpacing.lg) {
                ZStack {
                    RoundedRectangle(cornerRadius: PlagitRadius.md)
                        .fill(LinearGradient(colors: [Color.plagitTeal, Color.plagitTealDark], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 48, height: 48)
                    Image(systemName: "map.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    Text(L10n.exploreNearbyJobs)
                        .font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                    Text(L10n.exploreNearbySub)
                        .font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.plagitTeal)
            }
            .padding(PlagitSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: PlagitRadius.xl)
                    .fill(Color.plagitCardBackground)
                    .shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY)
            )
            .overlay(
                RoundedRectangle(cornerRadius: PlagitRadius.xl)
                    .stroke(Color.plagitTeal.opacity(0.10), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Next Step

    private var nextStepSection: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.md) {
            HStack(spacing: PlagitSpacing.sm) {
                Image(systemName: "sparkles").font(.system(size: 11, weight: .bold)).foregroundColor(.plagitAmber)
                Text(L10n.yourNextStep).font(PlagitFont.micro()).foregroundColor(.plagitAmber).textCase(.uppercase).tracking(0.8)
            }

            if let iv = homeData?.nextInterview {
                let typeLabel = L10n.interviewType(iv.interviewType)
                let dateLabel = formatInterviewDate(iv.scheduledAt)

                Text(L10n.interviewScheduled)
                    .font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)

                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    Text(iv.jobTitle ?? "Role").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)

                    HStack(spacing: PlagitSpacing.sm) {
                        if let d = dateLabel {
                            Text(d).font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal)
                        }
                        Text(typeLabel).font(PlagitFont.micro()).foregroundColor(.plagitIndigo)
                            .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 2)
                            .background(Capsule().fill(Color.plagitIndigo.opacity(0.06)))
                    }
                }

                Button { showInterviews = true } label: {
                    Text(L10n.viewDetails).font(PlagitFont.captionMedium()).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, PlagitSpacing.md)
                        .background(Capsule().fill(LinearGradient(colors: [Color.plagitTeal, Color.plagitTealDark], startPoint: .topLeading, endPoint: .bottomTrailing)))
                }
            } else {
                Text(L10n.completeProfile)
                    .font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                Text(L10n.completeProfileSub)
                    .font(PlagitFont.caption()).foregroundColor(.plagitSecondary)

                Button { showProfile = true } label: {
                    Text(L10n.completeProfile).font(PlagitFont.captionMedium()).foregroundColor(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, PlagitSpacing.md)
                        .background(Capsule().fill(Color.plagitTeal))
                }
            }
        }
        .padding(.horizontal, PlagitSpacing.xl).padding(.vertical, PlagitSpacing.lg + 2)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground)
            .shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        .overlay(RoundedRectangle(cornerRadius: PlagitRadius.xl).stroke(Color.plagitAmber.opacity(0.10), lineWidth: 1))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Jobs Near You (real data)

    private var jobsNearYouSection: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            HStack {
                Text(L10n.jobsNearYou).font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
                Spacer()
                Button { showNearbyJobs = true } label: {
                    HStack(spacing: 4) { Text(L10n.seeAll).font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal); Image(systemName: "chevron.right").font(.system(size: 10, weight: .semibold)).foregroundColor(.plagitTeal) }
                }
            }.padding(.horizontal, PlagitSpacing.xl)

            HStack(spacing: PlagitSpacing.xs) {
                Image(systemName: "mappin.circle.fill").font(.system(size: 12, weight: .medium)).foregroundColor(.plagitTeal)
                Text("\(featuredJobs.count) \(L10n.t("jobs_available_count"))").font(PlagitFont.micro()).foregroundColor(.plagitSecondary)
            }.padding(.horizontal, PlagitSpacing.xl)

            if featuredJobs.isEmpty {
                Text(L10n.noJobsNearby).font(PlagitFont.caption()).foregroundColor(.plagitTertiary)
                    .frame(maxWidth: .infinity).padding(PlagitSpacing.xl)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: PlagitSpacing.md + 2) {
                        ForEach(featuredJobs.prefix(5)) { job in
                            nearbyMiniCard(job)
                        }
                    }.padding(.horizontal, PlagitSpacing.xl)
                }
            }
        }
    }

    private func nearbyMiniCard(_ job: FeaturedJobDTO) -> some View {
        let hue = job.businessAvatarHue ?? job.avatarHue
        return Button { selectedJobId = job.id; DispatchQueue.main.async { showJobDetail = true } } label: {
            VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
                HStack(spacing: PlagitSpacing.sm) {
                    Circle()
                        .fill(LinearGradient(colors: [Color(hue: hue, saturation: 0.45, brightness: 0.90), Color(hue: hue, saturation: 0.55, brightness: 0.75)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 28, height: 28)
                        .overlay(Text(job.businessInitials ?? "?").font(.system(size: 9, weight: .bold, design: .rounded)).foregroundColor(.white))

                    VStack(alignment: .leading, spacing: 1) {
                        Text(job.businessName ?? "Unknown").font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal).lineLimit(1)
                        if let loc = job.location { Text(loc).font(PlagitFont.micro()).foregroundColor(.plagitTertiary).lineLimit(1) }
                    }
                }

                Text(job.title).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal).lineLimit(1)

                HStack(spacing: PlagitSpacing.xs) {
                    if let sal = job.salary { Text(sal).font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal) }
                    if let type = job.employmentType {
                        Text("·").foregroundColor(.plagitTertiary)
                        Text(L10n.employmentType(type)).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                    }
                }

                if job.isFeatured {
                    Text(L10n.featured).font(PlagitFont.micro()).foregroundColor(.plagitAmber)
                        .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 2)
                        .background(Capsule().fill(Color.plagitAmber.opacity(0.08)))
                }
            }
            .frame(width: 180)
            .padding(PlagitSpacing.lg)
            .background(RoundedRectangle(cornerRadius: PlagitRadius.lg).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Recommended Jobs (from API)

    private var recommendedJobsSection: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.md) {
            HStack {
                Text(L10n.featuredJobs).font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
                Spacer()
                Button { showFindWork = true } label: {
                    HStack(spacing: 4) { Text(L10n.seeAll).font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal); Image(systemName: "chevron.right").font(.system(size: 10, weight: .semibold)).foregroundColor(.plagitTeal) }
                }
            }.padding(.horizontal, PlagitSpacing.xl)

            if featuredJobs.isEmpty {
                Text(L10n.noJobsAvailable)
                    .font(PlagitFont.caption()).foregroundColor(.plagitTertiary)
                    .frame(maxWidth: .infinity).padding(PlagitSpacing.xxl)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: PlagitSpacing.md) {
                        ForEach(featuredJobs) { job in
                            featuredJobCard(job)
                        }
                    }.padding(.horizontal, PlagitSpacing.xl)
                }
            }
        }
    }

    private func featuredJobCard(_ job: FeaturedJobDTO) -> some View {
        Button { showFindWork = true } label: {
            HStack(spacing: PlagitSpacing.md) {
                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(LinearGradient(colors: [Color(hue: job.businessAvatarHue ?? job.avatarHue, saturation: 0.45, brightness: 0.90), Color(hue: job.businessAvatarHue ?? job.avatarHue, saturation: 0.55, brightness: 0.75)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 46, height: 46)
                        .overlay(Text(job.businessInitials ?? "?").font(.system(size: 15, weight: .bold, design: .rounded)).foregroundColor(.white))
                    if job.businessVerified == true {
                        Image(systemName: "checkmark.seal.fill").font(.system(size: 13)).foregroundColor(.plagitVerified)
                            .background(Circle().fill(.white).frame(width: 11, height: 11)).offset(x: 2, y: 2)
                    }
                }
                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    Text(job.title).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                    HStack(spacing: PlagitSpacing.xs) {
                        Text("\(job.businessName ?? "Unknown") \(job.location.map { "· \($0)" } ?? "")").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                    }
                    if let salary = job.salary, !salary.isEmpty {
                        Text(salary).font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal)
                    }
                    HStack(spacing: PlagitSpacing.xs) {
                        if let type = job.employmentType { Text(L10n.employmentType(type)).font(PlagitFont.micro()).foregroundColor(.plagitTeal) }
                        if job.isFeatured { Text(L10n.featured).font(PlagitFont.micro()).foregroundColor(.plagitAmber).padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 4).background(Capsule().fill(Color.plagitAmber.opacity(0.10))) }
                    }
                }
                Spacer()
            }
            .padding(PlagitSpacing.lg)
            .frame(width: 300)
            .background(RoundedRectangle(cornerRadius: PlagitRadius.lg).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Applications Summary

    private var applicationsSummary: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            HStack {
                Text(L10n.myApplications).font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
                Spacer()
                Button { applicationsInitialFilter = "All"; showMyApplications = true } label: { Text(L10n.viewAll).font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal) }
            }

            HStack(spacing: PlagitSpacing.md) {
                appStat("\(homeData?.applicationsSummary.total ?? 0)", L10n.total, .plagitCharcoal) { applicationsInitialFilter = "All"; showMyApplications = true }
                appStat("\(homeData?.applicationsSummary.underReview ?? 0)", L10n.underReview, .plagitAmber) { applicationsInitialFilter = "In Review"; showMyApplications = true }
                appStat("\(homeData?.applicationsSummary.interview ?? 0)", L10n.interview, .plagitIndigo) { applicationsInitialFilter = "Interview"; showMyApplications = true }
                appStat("\(homeData?.applicationsSummary.offer ?? 0)", L10n.offer, .plagitOnline) { applicationsInitialFilter = "Offer"; showMyApplications = true }
            }
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func appStat(_ n: String, _ label: String, _ color: Color, action: @escaping () -> Void = {}) -> some View {
        Button(action: action) {
            VStack(spacing: PlagitSpacing.xs) {
                Text(n).font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
                Text(label).font(PlagitFont.micro()).foregroundColor(color)
            }.frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Next Interview (real data)

    private var nextInterviewCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.md) {
            if let iv = homeData?.nextInterview {
                HStack(spacing: PlagitSpacing.sm) {
                    Image(systemName: "calendar").font(.system(size: 12, weight: .medium)).foregroundColor(.plagitIndigo)
                    Text(L10n.nextInterview).font(PlagitFont.captionMedium()).foregroundColor(.plagitIndigo)
                }

                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    Text(iv.jobTitle ?? "Interview").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                    HStack(spacing: PlagitSpacing.sm) {
                        Text(formatInterviewDate(iv.scheduledAt) ?? "TBD").font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal)
                        Text(L10n.interviewType(iv.interviewType))
                            .font(PlagitFont.micro()).foregroundColor(.plagitIndigo)
                            .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 2)
                            .background(Capsule().fill(Color.plagitIndigo.opacity(0.06)))
                    }
                }

                Button { showInterviews = true } label: {
                    Text(L10n.viewInterviews).font(PlagitFont.captionMedium()).foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 10).background(Capsule().fill(Color.plagitTeal))
                }
            }
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Messages Preview

    private var messagesPreview: some View {
        let unread = homeData?.unreadMessages ?? 0
        return VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            HStack {
                Text(L10n.messages).font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
                if unread > 0 {
                    Text("\(unread)").font(PlagitFont.micro()).foregroundColor(.white)
                        .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 2)
                        .background(Capsule().fill(Color.plagitTeal))
                }
                Spacer()
                Button { showMessages = true } label: { Text(L10n.viewAll).font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal) }
            }

            Button { showMessages = true } label: {
                HStack(spacing: PlagitSpacing.md) {
                    ZStack {
                        Circle().fill(Color.plagitTealLight).frame(width: 36, height: 36)
                        Image(systemName: "bubble.left.and.bubble.right").font(.system(size: 14, weight: .medium)).foregroundColor(.plagitTeal)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(unread > 0 ? "\(unread) \(unread > 1 ? L10n.t("unread_messages_plural") : L10n.t("unread_messages"))" : L10n.t("no_new_messages"))
                            .font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                        Text(L10n.tapToViewConversations).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right").font(.system(size: 11, weight: .medium)).foregroundColor(.plagitTertiary)
                }
            }.buttonStyle(.plain)
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Community Preview (real data)

    private var communityPreview: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            HStack {
                Text(L10n.fromTheCommunity).font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
                Spacer()
                Button { showCommunityFeed = true } label: {
                    HStack(spacing: 4) { Text(L10n.seeAll).font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal); Image(systemName: "chevron.right").font(.system(size: 10, weight: .semibold)).foregroundColor(.plagitTeal) }
                }
            }

            if communityPosts.isEmpty {
                HStack(spacing: PlagitSpacing.md) {
                    ZStack {
                        Circle().fill(Color.plagitTealLight).frame(width: 36, height: 36)
                        Image(systemName: "bubble.left.and.bubble.right").font(.system(size: 14, weight: .medium)).foregroundColor(.plagitTeal)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(L10n.noCommunityPosts).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                        Text(L10n.beFirstToShare).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                    }
                }
            } else {
                ForEach(communityPosts.prefix(2)) { post in
                    Button { showCommunityFeed = true } label: {
                        HStack(spacing: PlagitSpacing.md) {
                            ProfileAvatarView(photoUrl: post.authorPhotoUrl, initials: post.authorInitials ?? "?", hue: post.authorAvatarHue ?? 0.5, size: 36, verified: post.authorVerified == true)

                            VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                                Text(post.authorName ?? "Unknown").font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal).lineLimit(1)
                                Text(post.body).font(PlagitFont.caption()).foregroundColor(.plagitSecondary).lineLimit(1)
                            }

                            Spacer()
                            if post.likeCount > 0 {
                                HStack(spacing: 3) {
                                    Image(systemName: "heart.fill").font(.system(size: 9)).foregroundColor(.plagitUrgent)
                                    Text("\(post.likeCount)").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                                }
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
        .navigationDestination(isPresented: $showCommunityFeed) { CandidateCommunityView().navigationBarHidden(true) }
    }

    // MARK: - Profile Strength

    private var profileStrength: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            HStack {
                Text(L10n.profileStrength).font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
                Spacer()
                Text("\(homeData?.user.profileStrength ?? 0)%").font(PlagitFont.bodyMedium()).foregroundColor(.plagitTeal)
            }

            // Progress bar
            GeometryReader { geo in
                let pct = Double(homeData?.user.profileStrength ?? 0) / 100.0
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(Color.plagitSurface).frame(height: 6)
                    RoundedRectangle(cornerRadius: 4).fill(Color.plagitTeal).frame(width: geo.size.width * pct, height: 6)
                }
            }.frame(height: 6)

            VStack(spacing: PlagitSpacing.sm) {
                profileItem("camera", L10n.t("add_profile_photo"), homeData?.user.hasPhoto ?? false)
                profileItem("mappin", L10n.t("set_location"), homeData?.user.hasLocation ?? false)
                profileItem("briefcase", L10n.t("add_role_title"), homeData?.user.hasRole ?? false)
                profileItem("clock", L10n.t("add_experience"), homeData?.user.hasExperience ?? false)
                profileItem("globe", L10n.t("add_languages"), homeData?.user.hasLanguages ?? false)
                profileItem("phone", L10n.t("add_phone_number"), homeData?.user.hasPhone ?? false)
                profileItem("checkmark.seal", L10n.t("get_verified"), homeData?.user.isVerified ?? false)
            }

            if (homeData?.user.profileStrength ?? 0) < 100 {
                Button { showProfile = true } label: {
                    Text(L10n.completeProfile).font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                        .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm)
                        .background(Capsule().fill(Color.plagitTealLight))
                }
            }
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func profileItem(_ icon: String, _ text: String, _ done: Bool) -> some View {
        HStack(spacing: PlagitSpacing.md) {
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(done ? .plagitOnline : .plagitTertiary)
            Text(text)
                .font(PlagitFont.body())
                .foregroundColor(done ? .plagitSecondary : .plagitCharcoal)
        }
    }

    // MARK: - Load Dashboard Data

    private func loadDashboard() async {
        // Skip full reload if we already have data (returning from a sub-page)
        let isFirstLoad = homeData == nil
        if isFirstLoad {
            isLoadingHome = true
        }
        homeError = nil
        do {
            async let homeResult = CandidateAPIService.shared.fetchHome()
            async let jobsResult = CandidateAPIService.shared.fetchFeaturedJobs(limit: 10)
            let (h, j) = try await (homeResult, jobsResult)
            homeData = h
            featuredJobs = j
            // Update auth service with fresh profile data
            auth.currentUserName = h.user.name
            auth.currentUserLocation = h.user.location
            auth.currentUserInitials = h.user.initials
            auth.currentUserAvatarHue = h.user.avatarHue
            // Sync locale data
            if let lang = h.user.appLanguageCode, !lang.isEmpty { AppLocaleManager.shared.setLanguage(lang) }
            if let cc = h.user.countryCode { AppLocaleManager.shared.countryCode = cc }
            if let spoken = h.user.spokenLanguages {
                AppLocaleManager.shared.spokenLanguages = spoken.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            }
        } catch {
            if isFirstLoad { homeError = L10n.apiError(error.localizedDescription) }
        }
        isLoadingHome = false
        // Load notification count and feed in background — don't block UI
        async let _ : () = {
            do {
                struct CountResp: Decodable { let count: Int }
                struct Wrapper: Decodable { let success: Bool; let data: CountResp }
                let w: Wrapper = try await APIClient.shared.request(.GET, path: "/candidate/notifications/count")
                await MainActor.run { candUnreadCount = w.data.count }
            } catch {}
        }()
        if isFirstLoad {
            communityPosts = await FeedService.shared.fetchPosts(limit: 5)
        }
    }

    // MARK: - Bottom Navigation

    private var candidateBottomNav: some View {
        VStack(spacing: 0) {
            Rectangle().fill(Color.plagitDivider.opacity(0.4)).frame(height: 0.5)
            HStack(spacing: 0) {
                BottomTabItem(icon: "house.fill", label: L10n.home, isActive: true)
                BottomTabItem(icon: "briefcase", label: L10n.jobs, isActive: false).onTapGesture { showFindWork = true }
                BottomTabItem(icon: "doc.text", label: L10n.applications, isActive: false).onTapGesture { showMyApplications = true }
                BottomTabItem(icon: "bolt.fill", label: "Quick Plug", isActive: false, isPremium: true).onTapGesture { showQuickPlug = true }
                BottomTabItem(icon: "person.crop.circle", label: L10n.profile, isActive: false).onTapGesture { showProfile = true }
            }
            .padding(.horizontal, PlagitSpacing.sm).padding(.top, PlagitSpacing.xs + 2).padding(.bottom, PlagitSpacing.xxl)
            .background(Rectangle().fill(.ultraThinMaterial).ignoresSafeArea(edges: .bottom))
        }
    }

}


// MARK: - Stat Card Component

struct StatCard: View {
    let number: String
    let label: String
    let icon: String
    let color: Color
    var action: () -> Void = {}

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
        VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(color)
                .frame(width: 34, height: 34)
                .background(
                    RoundedRectangle(cornerRadius: PlagitRadius.md)
                        .fill(color.opacity(0.10))
                )

            Spacer().frame(height: PlagitSpacing.xs)

            // Number
            Text(number)
                .font(PlagitFont.statNumber())
                .foregroundColor(.plagitCharcoal)

            // Label
            Text(label)
                .font(PlagitFont.statLabel())
                .foregroundColor(.plagitSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(PlagitSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: PlagitRadius.lg)
                .fill(Color.plagitCardBackground)
                .shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY)
        )
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Quick Action Button

enum QuickActionStyle {
    case primary
    case secondary
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let style: QuickActionStyle
    var action: () -> Void = {}

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: PlagitSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .regular))

                Text(title)
                    .font(PlagitFont.captionMedium())
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, PlagitSpacing.xl)
            .foregroundColor(style == .primary ? .white : .plagitTeal)
            .background(
                RoundedRectangle(cornerRadius: PlagitRadius.lg)
                    .fill(style == .primary
                          ? AnyShapeStyle(LinearGradient(
                              colors: [Color.plagitTeal, Color.plagitTealDark],
                              startPoint: .topLeading,
                              endPoint: .bottomTrailing
                          ))
                          : AnyShapeStyle(Color.plagitTealSubtle)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: PlagitRadius.lg)
                    .stroke(
                        style == .secondary ? Color.plagitTeal.opacity(0.15) : Color.clear,
                        lineWidth: 0.5
                    )
            )
            .shadow(
                color: style == .primary ? Color.plagitTeal.opacity(0.18) : Color.clear,
                radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Recommended Job Card

struct RecommendedJobCard: View {
    let job: RecommendedJob
    var onTap: () -> Void = {}

    var body: some View {
        HStack(spacing: PlagitSpacing.md) {
            // Company avatar
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hue: job.avatarHue, saturation: 0.45, brightness: 0.90),
                                Color(hue: job.avatarHue, saturation: 0.55, brightness: 0.75)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 46, height: 46)
                    .overlay(
                        Text(job.initials)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    )

                if job.isVerified {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 13))
                        .foregroundColor(.plagitVerified)
                        .background(Circle().fill(.white).frame(width: 11, height: 11))
                        .offset(x: 2, y: 2)
                }
            }

            VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                Text(job.jobTitle)
                    .font(PlagitFont.bodyMedium())
                    .foregroundColor(.plagitCharcoal)

                HStack(spacing: PlagitSpacing.xs) {
                    Text("\(job.company) · \(job.location)")
                        .font(PlagitFont.caption())
                        .foregroundColor(.plagitSecondary)

                    if job.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.plagitVerified)
                    }
                }

                Text(job.salary)
                    .font(PlagitFont.captionMedium())
                    .foregroundColor(.plagitCharcoal)

                HStack(spacing: PlagitSpacing.xs) {
                    Text(L10n.employmentType(job.employmentType))
                        .font(PlagitFont.micro())
                        .foregroundColor(.plagitTeal)

                    if !job.tag.isEmpty {
                        Text(job.tag)
                            .font(PlagitFont.micro())
                            .foregroundColor(.plagitAmber)
                            .padding(.horizontal, PlagitSpacing.sm)
                            .padding(.vertical, 4)
                            .background(
                                Capsule().fill(Color.plagitAmber.opacity(0.10))
                            )
                    }
                }
            }

            Spacer()

            // CTA button
            Button { onTap() } label: {
                Text("Apply")
                    .font(PlagitFont.captionMedium())
                    .foregroundColor(.plagitTeal)
                    .padding(.horizontal, PlagitSpacing.lg)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color.plagitTealLight)
                    )
            }
        }
        .padding(PlagitSpacing.lg)
        .frame(width: 300)
        .background(
            RoundedRectangle(cornerRadius: PlagitRadius.lg)
                .fill(Color.plagitCardBackground)
                .shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY)
        )
    }
}

// MARK: - Feed Card

struct FeedCardView: View {
    let post: FeedPost
    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Author header
            HStack(spacing: PlagitSpacing.md) {
                // Avatar
                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hue: post.avatarHue, saturation: 0.45, brightness: 0.90),
                                    Color(hue: post.avatarHue, saturation: 0.55, brightness: 0.75)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .overlay(
                            Text(post.authorInitials)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        )

                    if post.isOnline {
                        Circle()
                            .fill(Color.plagitOnline)
                            .frame(width: 11, height: 11)
                            .overlay(
                                Circle().stroke(Color.white, lineWidth: 2)
                            )
                            .offset(x: 1, y: 1)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: PlagitSpacing.xs) {
                        Text(post.authorName)
                            .font(PlagitFont.bodyMedium())
                            .foregroundColor(.plagitCharcoal)

                        if post.isVerified {
                            HStack(spacing: 2) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 11))
                                    .foregroundColor(.plagitVerified)
                                Text("Verified")
                                    .font(PlagitFont.micro())
                                    .foregroundColor(.plagitVerified)
                            }
                        }
                    }

                    HStack(spacing: 4) {
                        Text(post.authorRole)
                            .font(PlagitFont.caption())
                            .foregroundColor(.plagitSecondary)

                        Text("·")
                            .foregroundColor(.plagitTertiary)

                        Text(post.authorCountry)
                            .font(PlagitFont.caption())
                            .foregroundColor(.plagitSecondary)

                        Text("·")
                            .foregroundColor(.plagitTertiary)

                        Text(post.timeAgo)
                            .font(PlagitFont.caption())
                            .foregroundColor(.plagitTertiary)
                    }
                }

                Spacer()

                // More menu
                Button {} label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.plagitTertiary)
                        .frame(width: 32, height: 32)
                }
            }
            .padding(.horizontal, PlagitSpacing.xl)
            .padding(.top, PlagitSpacing.xl)

            // Title
            Text(post.title)
                .font(PlagitFont.headline())
                .foregroundColor(.plagitCharcoal)
                .padding(.horizontal, PlagitSpacing.xl)
                .padding(.top, PlagitSpacing.lg)

            // Badges
            if !post.badges.isEmpty {
                HStack(spacing: PlagitSpacing.sm) {
                    ForEach(post.badges.prefix(2), id: \.self) { badge in
                        Text(L10n.t(badge.lowercased()))
                            .font(PlagitFont.micro())
                            .foregroundColor(badge == "Urgent" ? .plagitUrgent : .plagitTeal)
                            .lineLimit(1)
                            .padding(.horizontal, PlagitSpacing.sm)
                            .padding(.vertical, 4)
                            .background(
                                Capsule().fill(
                                    (badge == "Urgent" ? Color.plagitUrgent : Color.plagitTeal).opacity(0.08)
                                )
                            )
                    }
                }
                .padding(.horizontal, PlagitSpacing.xl)
                .padding(.top, PlagitSpacing.sm)
            }

            // Body
            Text(post.body)
                .font(PlagitFont.body())
                .foregroundColor(.plagitSecondary)
                .lineSpacing(4)
                .lineLimit(3)
                .padding(.horizontal, PlagitSpacing.xl)
                .padding(.top, PlagitSpacing.sm)

            // Salary
            if !post.salary.isEmpty {
                Text(post.salary)
                    .font(PlagitFont.captionMedium())
                    .foregroundColor(.plagitTeal)
                    .padding(.horizontal, PlagitSpacing.xl)
                    .padding(.top, PlagitSpacing.xs)
            }

            // Engagement stats
            HStack(spacing: PlagitSpacing.lg) {
                EngagementStat(icon: "heart", count: post.likes)
                EngagementStat(icon: "bubble.right", count: post.comments)
                EngagementStat(icon: "eye", count: post.views)

                Spacer()

                Button {} label: {
                    Image(systemName: "bookmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.plagitTertiary)
                }

                Button {} label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.plagitTertiary)
                }
            }
            .padding(.horizontal, PlagitSpacing.xl)
            .padding(.top, PlagitSpacing.lg)

            // Divider
            Rectangle()
                .fill(Color.plagitDivider)
                .frame(height: 1)
                .padding(.horizontal, PlagitSpacing.xl)
                .padding(.top, PlagitSpacing.lg)

            // Action buttons
            HStack(spacing: PlagitSpacing.md) {
                FeedActionButton(label: post.primaryCTA, style: .primary)
                FeedActionButton(label: post.secondaryCTA, style: .secondary)
                FeedActionButton(label: post.tertiaryCTA, style: .secondary)
            }
            .padding(.horizontal, PlagitSpacing.xl)
            .padding(.top, PlagitSpacing.md)
            .padding(.bottom, PlagitSpacing.xl)
        }
        .background(
            RoundedRectangle(cornerRadius: PlagitRadius.xl)
                .fill(Color.plagitCardBackground)
                .shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY)
        )
        .scaleEffect(isPressed ? 0.985 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - Engagement Stat

struct EngagementStat: View {
    let icon: String
    let count: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.plagitTertiary)

            Text("\(count)")
                .font(PlagitFont.caption())
                .foregroundColor(.plagitTertiary)
        }
    }
}

// MARK: - Feed Action Button

struct FeedActionButton: View {
    let label: String
    let style: QuickActionStyle

    var body: some View {
        Button {} label: {
            Text(label)
                .font(PlagitFont.captionMedium())
                .foregroundColor(style == .primary ? .white : .plagitTeal)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(style == .primary ? Color.plagitTeal : Color.plagitTealLight)
                )
        }
    }
}

// MARK: - Bottom Tab Item

struct BottomTabItem: View {
    let icon: String
    let label: String
    let isActive: Bool
    var isPremium: Bool = false

    var body: some View {
        VStack(spacing: PlagitSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: isPremium || isActive ? .medium : .regular))
                .foregroundStyle(isPremium
                    ? AnyShapeStyle(LinearGradient(colors: [Color.plagitPurple, Color.plagitPurpleDark], startPoint: .top, endPoint: .bottom))
                    : AnyShapeStyle(isActive ? Color.plagitTeal : Color.plagitTertiary))

            Text(label)
                .font(PlagitFont.tabLabel())
                .foregroundColor(isPremium ? .plagitPurple : (isActive ? .plagitTeal : .plagitTertiary))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Create Menu Item

struct CreateMenuItem: View {
    let icon: String
    let title: String
    let subtitle: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: PlagitSpacing.lg) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.plagitTeal)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: PlagitRadius.md)
                            .fill(Color.plagitTealLight)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(PlagitFont.bodyMedium())
                        .foregroundColor(.plagitCharcoal)

                    Text(subtitle)
                        .font(PlagitFont.caption())
                        .foregroundColor(.plagitSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.plagitTertiary)
            }
            .padding(PlagitSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: PlagitRadius.lg)
                    .fill(Color.plagitSurface)
            )
        }
    }
}

// MARK: - Preview

#Preview {
    HomeView()
}
