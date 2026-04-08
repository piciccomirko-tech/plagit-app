//
//  MyApplicationsView.swift
//  Plagit
//
//  Premium Applications Dashboard — Candidate
//

import SwiftUI

struct MyApplicationsView: View {
    var initialFilter: String = "All"
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFilter: String

    init(initialFilter: String = "All") {
        self.initialFilter = initialFilter
        _selectedFilter = State(initialValue: initialFilter)
    }

    @State private var selectedSort = "Most Recent"
    @State private var showDetail = false
    @State private var showMessages = false
    @State private var showFindWork = false
    @State private var showSearch = false
    @State private var searchText = ""
    @State private var showSortMenu = false
    @State private var selectedApp: CandidateApplicationDTO?
    @State private var recentSearches: [String] = []

    // Real data
    @State private var applications: [CandidateApplicationDTO] = []
    @State private var isLoading = true
    @State private var loadError: String?

    private let filters = ["All", "applied", "under_review", "interview", "offer", "withdrawn"]
    private var filterLabels: [String: String] {
        ["All": L10n.all, "applied": L10n.appStatus("applied"), "under_review": L10n.appStatus("under_review"), "interview": L10n.appStatus("interview"), "offer": L10n.appStatus("offer"), "withdrawn": L10n.appStatus("withdrawn")]
    }
    private let sortOptions = ["Most Recent", "Company A–Z"]

    private func statusColor(_ status: String) -> Color {
        switch status {
        case "applied": return .plagitTeal
        case "under_review", "shortlisted": return .plagitAmber
        case "interview": return .plagitIndigo
        case "offer": return .plagitOnline
        case "rejected", "withdrawn": return .plagitTertiary
        default: return .plagitSecondary
        }
    }

    private func statusLabel(_ status: String) -> String {
        L10n.appStatus(status)
    }

    private var totalCount: Int { applications.count }
    private var reviewCount: Int { applications.filter { $0.status == "under_review" || $0.status == "shortlisted" }.count }
    private var interviewCount: Int { applications.filter { $0.status == "interview" }.count }

    private var filteredApplications: [CandidateApplicationDTO] {
        var result = applications
        if selectedFilter != "All" { result = result.filter { $0.status == selectedFilter } }
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            result = result.filter {
                ($0.jobTitle?.lowercased().contains(q) ?? false)
                || ($0.businessName?.lowercased().contains(q) ?? false)
                || ($0.jobLocation?.lowercased().contains(q) ?? false)
            }
        }
        switch selectedSort {
        case "Company A–Z": result.sort { ($0.businessName ?? "").localizedCaseInsensitiveCompare($1.businessName ?? "") == .orderedAscending }
        case "Most Recent": result.sort { ($0.appliedAt ?? "") > ($1.appliedAt ?? "") }
        default: break
        }
        return result
    }

    private func countFor(_ filter: String) -> Int {
        if filter == "All" { return applications.count }
        return applications.filter { $0.status == filter }.count
    }

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar.background(Color.plagitBackground).zIndex(1)
                if showSearch { searchBar.transition(.move(edge: .top).combined(with: .opacity)) }

                if isLoading {
                    Spacer()
                    ProgressView().tint(.plagitTeal)
                    Spacer()
                } else if let error = loadError {
                    Spacer()
                    VStack(spacing: PlagitSpacing.md) {
                        Image(systemName: "wifi.exclamationmark").font(.system(size: 32)).foregroundColor(.plagitTertiary)
                        Text(error).font(PlagitFont.caption()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center)
                        Button { Task { await loadApplications() } } label: {
                            Text(L10n.retry).font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                        }
                    }.padding(PlagitSpacing.xxl)
                    Spacer()
                } else {
                    summaryRow
                    filterChips.padding(.top, PlagitSpacing.xs)

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            if showSearch && searchText.isEmpty {
                                RecentSearchesView(searches: $recentSearches, searchText: $searchText)
                            }

                            if selectedFilter == "All" && searchText.isEmpty && interviewCount > 0 {
                                needsAttention.padding(.top, PlagitSpacing.lg)
                            }

                            sortBar.padding(.top, PlagitSpacing.lg)

                            if filteredApplications.isEmpty {
                                emptyState.padding(.top, PlagitSpacing.xxxl * 2)
                            } else {
                                VStack(spacing: PlagitSpacing.md) {
                                    ForEach(filteredApplications) { app in
                                        applicationCard(app)
                                    }
                                }
                                .padding(.horizontal, PlagitSpacing.xl)
                                .padding(.top, PlagitSpacing.md)
                                .padding(.bottom, PlagitSpacing.xxxl)
                            }
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showDetail) {
            if let app = selectedApp {
                CandidateRealAppDetailView(app: app).navigationBarHidden(true)
            }
        }
        .navigationDestination(isPresented: $showFindWork) {
            CandidateJobsView().navigationBarHidden(true)
        }
        .task { await loadApplications() }
    }

    private func loadApplications() async {
        isLoading = true; loadError = nil
        do {
            applications = try await CandidateAPIService.shared.fetchApplications()
        } catch {
            loadError = L10n.apiError(error.localizedDescription)
        }
        isLoading = false
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36)
            }
            Spacer()
            Text(L10n.applications).font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
            Spacer()
            Button { withAnimation(.easeInOut(duration: 0.2)) { showSearch.toggle(); if !showSearch { searchText = "" } } } label: {
                Image(systemName: showSearch ? "xmark" : "magnifyingglass").font(.system(size: 18, weight: .regular)).foregroundColor(.plagitCharcoal)
            }
        }
        .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.lg)
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: PlagitSpacing.md) {
            Image(systemName: "magnifyingglass").font(.system(size: 14, weight: .medium)).foregroundColor(.plagitTertiary)
            TextField(L10n.t("search_applications"), text: $searchText).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
                .submitLabel(.search).onSubmit { RecentSearchesView.addSearch(searchText, to: &recentSearches) }
            if !searchText.isEmpty { Button { searchText = "" } label: { Image(systemName: "xmark.circle.fill").font(.system(size: 14)).foregroundColor(.plagitTertiary) } }
        }
        .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.md)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Summary Row

    private var summaryRow: some View {
        HStack(spacing: PlagitSpacing.lg) {
            Text("\(totalCount) \(L10n.t("total"))").font(PlagitFont.micro()).foregroundColor(.plagitCharcoal)
            if reviewCount > 0 { Text("\(reviewCount) \(L10n.t("under_review_count"))").font(PlagitFont.micro()).foregroundColor(.plagitAmber) }
            if interviewCount > 0 { Text("\(interviewCount) \(L10n.t("interview_count"))").font(PlagitFont.micro()).foregroundColor(.plagitIndigo) }
            Spacer()
        }
        .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.sm)
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PlagitSpacing.sm) {
                ForEach(filters, id: \.self) { filter in
                    let count = countFor(filter)
                    let isActive = selectedFilter == filter
                    Button { withAnimation(.easeInOut(duration: 0.2)) { selectedFilter = filter } } label: {
                        HStack(spacing: PlagitSpacing.xs) {
                            Text(filterLabels[filter] ?? filter).font(PlagitFont.captionMedium()).foregroundColor(isActive ? .white : .plagitSecondary)
                            if count > 0 { Text("\(count)").font(PlagitFont.micro()).foregroundColor(isActive ? .white.opacity(0.8) : .plagitTertiary) }
                        }
                        .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm)
                        .background(Capsule().fill(isActive ? Color.plagitTeal : Color.plagitSurface))
                        .overlay(Capsule().stroke(isActive ? Color.clear : Color.plagitBorder, lineWidth: 0.5))
                    }
                }
            }.padding(.horizontal, PlagitSpacing.xl)
        }
    }

    // MARK: - Needs Attention

    private var needsAttention: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.md) {
            HStack(spacing: PlagitSpacing.sm) {
                Image(systemName: "sparkles").font(.system(size: 12, weight: .bold)).foregroundColor(.plagitAmber)
                Text(L10n.t("needs_attention")).font(PlagitFont.captionMedium()).foregroundColor(.plagitAmber)
            }
            Text("\(interviewCount) \(L10n.t("interviews_scheduled_msg"))").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
            Button { selectedFilter = "Interview" } label: {
                Text(L10n.t("review_now")).font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                    .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm)
                    .background(Capsule().fill(Color.plagitTealLight))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        .overlay(RoundedRectangle(cornerRadius: PlagitRadius.xl).stroke(Color.plagitAmber.opacity(0.12), lineWidth: 1))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Sort Bar

    private var sortBar: some View {
        HStack {
            Text("\(filteredApplications.count) \(L10n.t("n_applications"))").font(PlagitFont.captionMedium()).foregroundColor(.plagitSecondary)
            Spacer()
            Button { showSortMenu = true } label: {
                HStack(spacing: PlagitSpacing.xs) {
                    Image(systemName: "arrow.up.arrow.down").font(.system(size: 11, weight: .medium)).foregroundColor(.plagitTeal)
                    Text(selectedSort == "Most Recent" ? L10n.t("most_recent") : L10n.t("company_az")).font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                }
            }
        }
        .padding(.horizontal, PlagitSpacing.xl)
        .confirmationDialog(L10n.t("sort_by"), isPresented: $showSortMenu) {
            ForEach(sortOptions, id: \.self) { opt in Button(opt == "Most Recent" ? L10n.t("most_recent") : L10n.t("company_az")) { selectedSort = opt } }
            Button(L10n.cancel, role: .cancel) {}
        }
    }

    // MARK: - Application Card

    private func applicationCard(_ app: CandidateApplicationDTO) -> some View {
        let sc = statusColor(app.status)
        let hue = app.businessAvatarHue ?? app.jobAvatarHue ?? 0.5

        return VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: PlagitSpacing.md) {
                Circle()
                    .fill(LinearGradient(colors: [Color(hue: hue, saturation: 0.45, brightness: 0.90), Color(hue: hue, saturation: 0.55, brightness: 0.75)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 44, height: 44)
                    .overlay(Text(app.businessInitials ?? "?").font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(.white))

                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    HStack(spacing: PlagitSpacing.sm) {
                        Text(app.jobTitle ?? "Unknown").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                        Text(statusLabel(app.status)).font(PlagitFont.micro()).foregroundColor(sc)
                            .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 3)
                            .background(Capsule().fill(sc.opacity(0.08)))
                    }
                    HStack(spacing: PlagitSpacing.xs) {
                        Text(app.businessName ?? "Unknown").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                        if app.businessVerified == true { Image(systemName: "checkmark.seal.fill").font(.system(size: 9)).foregroundColor(.plagitVerified) }
                    }
                    HStack(spacing: PlagitSpacing.sm) {
                        if let loc = app.jobLocation, !loc.isEmpty {
                            Text(loc).font(PlagitFont.caption()).foregroundColor(.plagitTertiary)
                        }
                        if let sal = app.salary, !sal.isEmpty {
                            Text("·").foregroundColor(.plagitTertiary)
                            Text(sal).font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal)
                        }
                    }

                    if app.status == "interview" {
                        Text(L10n.t("interview_scheduled_check")).font(PlagitFont.micro()).foregroundColor(.plagitIndigo)
                    } else if app.status == "under_review" {
                        Text(L10n.t("employer_reviewing")).font(PlagitFont.micro()).foregroundColor(.plagitAmber)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.xl)

            // Progress indicator — highlight applied (first) + current stage only
            HStack(spacing: 0) {
                let steps = ["applied", "under_review", "interview", "offer"]
                let currentIdx = steps.firstIndex(of: app.status) ?? 0
                ForEach(Array(steps.enumerated()), id: \.offset) { idx, _ in
                    let isFilled = idx == 0 || idx == currentIdx
                    Rectangle().fill(isFilled ? sc : Color.plagitBorder).frame(height: 3)
                    if idx < steps.count - 1 { Spacer().frame(width: 2) }
                }
            }
            .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.md)

            Rectangle().fill(Color.plagitDivider).frame(height: 1).padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg)

            HStack(spacing: PlagitSpacing.md) {
                Button { selectedApp = app; DispatchQueue.main.async { showDetail = true } } label: {
                    Text(L10n.viewDetails).font(PlagitFont.captionMedium()).foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 10).background(Capsule().fill(Color.plagitTeal))
                }
            }
            .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.md).padding(.bottom, PlagitSpacing.xl)
        }
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack {
                Circle().fill(Color.plagitTealLight).frame(width: 48, height: 48)
                Image(systemName: !searchText.isEmpty ? "magnifyingglass" : "doc.text").font(.system(size: 20, weight: .medium)).foregroundColor(.plagitTeal)
            }
            VStack(spacing: PlagitSpacing.xs) {
                Text(!searchText.isEmpty ? "\(L10n.t("no_results_for")) \"\(searchText)\"" : L10n.t("no_applications_yet")).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                Text(L10n.t("start_applying")).font(PlagitFont.caption()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center)
            }
            Button { showFindWork = true } label: {
                Text(L10n.t("browse_jobs")).font(PlagitFont.captionMedium()).foregroundColor(.white)
                    .padding(.horizontal, PlagitSpacing.xxl).padding(.vertical, PlagitSpacing.md)
                    .background(Capsule().fill(Color.plagitTeal))
            }
        }.frame(maxWidth: .infinity).padding(.horizontal, PlagitSpacing.xxl)
    }
}

#Preview {
    NavigationStack { MyApplicationsView() }.preferredColorScheme(.light)
}
