//
//  CandidateJobsView.swift
//  Plagit
//
//  Premium Jobs Discovery — Candidate
//

import SwiftUI

// MARK: - Applied Filter Snapshot

/// Immutable snapshot of the filter values that the jobs list actually uses.
/// The sheet edits draft @State; Apply copies them here atomically.
private struct AppliedFilters: Equatable {
    var distanceKm: Double = 50
    var salaryMin: String = ""
    var salaryMax: String = ""
    var contractType: String = "All"
    var shiftType: String = "All"
    var urgentOnly: Bool = false
    var verifiedOnly: Bool = false

    var activeCount: Int {
        var c = 0
        if distanceKm < 50 { c += 1 }
        if !salaryMin.isEmpty || !salaryMax.isEmpty { c += 1 }
        if contractType != "All" { c += 1 }
        if shiftType != "All" { c += 1 }
        if urgentOnly { c += 1 }
        if verifiedOnly { c += 1 }
        return c
    }

    static let defaults = AppliedFilters()
}

// MARK: - View

struct CandidateJobsView: View {
    @Environment(\.dismiss) private var dismiss
    private var sub = SubscriptionManager.shared

    @State private var searchText = ""
    @State private var showSearch = false
    @State private var selectedFilter = "All"
    @State private var selectedSort = "Best Match"
    @State private var showSortMenu = false
    @State private var showJobDetail = false
    @State private var selectedJobId: String?
    @State private var savedJobs: Set<String> = []
    @State private var recentSearches: [String] = []
    @State private var showFilters = false
    @State private var showSubscription = false

    // ── Applied filters (read by jobs list & badge) ──
    @State private var applied = AppliedFilters.defaults

    // ── Draft filters (edited inside the sheet) ──
    @State private var draftDistanceKm: Double = 50
    @State private var draftSalaryMin: String = ""
    @State private var draftSalaryMax: String = ""
    @State private var draftContractType: String = "All"
    @State private var draftShiftType: String = "All"
    @State private var draftUrgentOnly = false
    @State private var draftVerifiedOnly = false

    // Real data
    @State private var jobs: [FeaturedJobDTO] = []
    @State private var isLoading = true
    @State private var loadError: String?

    private let filters = ["All", "Full-time", "Part-time", "International"]
    private let sortOptions = ["Best Match", "Most Recent", "A–Z"]
    private let contractTypes = ["All", "Full-time", "Part-time", "Temporary", "Seasonal"]
    private let shiftTypes = ["All", "Morning", "Afternoon", "Evening", "Night", "Split"]

    private var isPremium: Bool { sub.isCandidatePremium }

    private func countFor(_ filter: String) -> Int {
        switch filter {
        case "All": return jobs.count
        case "Full-time": return jobs.filter { $0.employmentType == "Full-time" }.count
        case "Part-time": return jobs.filter { $0.employmentType == "Part-time" }.count
        case "International": return jobs.filter { $0.openToInternational == true }.count
        default: return 0
        }
    }

    private var filteredJobs: [FeaturedJobDTO] {
        var result = jobs
        switch selectedFilter {
        case "Full-time": result = result.filter { $0.employmentType == "Full-time" }
        case "Part-time": result = result.filter { $0.employmentType == "Part-time" }
        case "International": result = result.filter { $0.openToInternational == true }
        default: break
        }
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            result = result.filter {
                ($0.title.lowercased().contains(q))
                || ($0.businessName?.lowercased().contains(q) ?? false)
                || ($0.location?.lowercased().contains(q) ?? false)
                || ($0.category?.lowercased().contains(q) ?? false)
            }
        }
        // Client-side salary filter reads from APPLIED state
        if isPremium {
            if let minVal = Int(applied.salaryMin), minVal > 0 {
                result = result.filter { parseSalary($0.salary) >= minVal }
            }
            if let maxVal = Int(applied.salaryMax), maxVal > 0 {
                result = result.filter { parseSalary($0.salary) <= maxVal }
            }
        }
        switch selectedSort {
        case "A–Z": result.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case "Most Recent": result.sort { ($0.createdAt ?? "") > ($1.createdAt ?? "") }
        default: break
        }
        return result
    }

    private func parseSalary(_ salary: String?) -> Int {
        guard let s = salary else { return 0 }
        let digits = s.filter { $0.isNumber }
        return Int(digits) ?? 0
    }

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar.background(Color.plagitBackground).zIndex(1)
                if showSearch { searchBar.transition(.move(edge: .top).combined(with: .opacity)) }
                quickFilters.padding(.top, PlagitSpacing.xs)

                if isLoading {
                    Spacer()
                    ProgressView().tint(.plagitTeal)
                    Spacer()
                } else if let error = loadError {
                    Spacer()
                    VStack(spacing: PlagitSpacing.md) {
                        Image(systemName: "wifi.exclamationmark").font(.system(size: 32)).foregroundColor(.plagitTertiary)
                        Text(error).font(PlagitFont.caption()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center)
                        Button { Task { await loadJobs() } } label: {
                            Text(L10n.retry).font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                        }
                    }.padding(PlagitSpacing.xxl)
                    Spacer()
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            if showSearch && searchText.isEmpty {
                                RecentSearchesView(searches: $recentSearches, searchText: $searchText)
                            }

                            sortBar.padding(.top, PlagitSpacing.lg)

                            if filteredJobs.isEmpty {
                                emptyState.padding(.top, PlagitSpacing.xxxl * 2)
                            } else {
                                VStack(spacing: PlagitSpacing.md) {
                                    ForEach(filteredJobs) { job in
                                        jobCard(job)
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
        .navigationDestination(isPresented: $showJobDetail) {
            CandidateJobDetailView(jobId: selectedJobId ?? "").navigationBarHidden(true)
        }
        .navigationDestination(isPresented: $showSubscription) {
            CandidateSubscriptionView().navigationBarHidden(true)
        }
        .sheet(isPresented: $showFilters, onDismiss: nil) {
            advancedFiltersSheet
        }
        .task { await loadJobs() }
    }

    // MARK: - Load Jobs (reads APPLIED state only)

    private func loadJobs() async {
        isLoading = true; loadError = nil
        do {
            let urgentParam = isPremium && applied.urgentOnly
            let verifiedParam = isPremium && applied.verifiedOnly
            let shiftParam: String? = (isPremium && applied.shiftType != "All") ? applied.shiftType : nil
            let contractParam: String? = (isPremium && applied.contractType != "All") ? applied.contractType : nil


            jobs = try await CandidateAPIService.shared.fetchJobs(
                limit: 50,
                employmentType: contractParam,
                isUrgent: urgentParam,
                shiftHours: shiftParam,
                verifiedOnly: verifiedParam
            )

        } catch {
            loadError = L10n.apiError(error.localizedDescription)
        }
        isLoading = false
    }

    // MARK: - Draft ↔ Applied

    /// Copy applied → draft when opening the sheet
    private func populateDraft() {
        draftDistanceKm = applied.distanceKm
        draftSalaryMin = applied.salaryMin
        draftSalaryMax = applied.salaryMax
        draftContractType = applied.contractType
        draftShiftType = applied.shiftType
        draftUrgentOnly = applied.urgentOnly
        draftVerifiedOnly = applied.verifiedOnly
    }

    /// Snapshot draft → applied, dismiss sheet, reload jobs
    private func commitDraftAndReload() {
        let snapshot = AppliedFilters(
            distanceKm: draftDistanceKm,
            salaryMin: draftSalaryMin,
            salaryMax: draftSalaryMax,
            contractType: draftContractType,
            shiftType: draftShiftType,
            urgentOnly: draftUrgentOnly,
            verifiedOnly: draftVerifiedOnly
        )


        // Write applied state BEFORE dismiss
        applied = snapshot

        // Sync quick filter bar
        if snapshot.contractType != "All" && filters.contains(snapshot.contractType) {
            selectedFilter = snapshot.contractType
        } else if snapshot.contractType == "All" && (selectedFilter == "Full-time" || selectedFilter == "Part-time") {
            selectedFilter = "All"
        }

        // Dismiss sheet
        showFilters = false

        // Reload with new applied state
        Task { await loadJobs() }
    }

    private func resetDraft() {
        draftDistanceKm = 50
        draftSalaryMin = ""
        draftSalaryMax = ""
        draftContractType = "All"
        draftShiftType = "All"
        draftUrgentOnly = false
        draftVerifiedOnly = false
    }

    private func clearAllFilters() {
        applied = .defaults
        draftDistanceKm = 50
        draftSalaryMin = ""
        draftSalaryMax = ""
        draftContractType = "All"
        draftShiftType = "All"
        draftUrgentOnly = false
        draftVerifiedOnly = false
        selectedFilter = "All"
        searchText = ""
        Task { await loadJobs() }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36)
            }
            Spacer()
            Text(L10n.jobs).font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
            Spacer()
            HStack(spacing: PlagitSpacing.lg) {
                Button { withAnimation(.easeInOut(duration: 0.2)) { showSearch.toggle(); if !showSearch { searchText = "" } } } label: {
                    Image(systemName: showSearch ? "xmark" : "magnifyingglass").font(.system(size: 18, weight: .regular)).foregroundColor(.plagitCharcoal)
                }
                // Filter button — badge reads from APPLIED state
                Button { populateDraft(); showFilters = true } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "slider.horizontal.3").font(.system(size: 16, weight: .medium)).foregroundColor(.plagitCharcoal)
                        if applied.activeCount > 0 {
                            Text("\(applied.activeCount)")
                                .font(.system(size: 8, weight: .bold)).foregroundColor(.white)
                                .frame(width: 14, height: 14)
                                .background(Circle().fill(Color.plagitTeal))
                                .offset(x: 5, y: -5)
                        }
                    }
                }
                Button { showSortMenu = true } label: {
                    Image(systemName: "arrow.up.arrow.down").font(.system(size: 16, weight: .medium)).foregroundColor(.plagitCharcoal)
                }
            }
        }
        .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.lg)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: PlagitSpacing.md) {
            Image(systemName: "magnifyingglass").font(.system(size: 14, weight: .medium)).foregroundColor(.plagitTertiary)
            TextField(L10n.searchJobsPlaceholder, text: $searchText).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
                .submitLabel(.search).onSubmit { RecentSearchesView.addSearch(searchText, to: &recentSearches) }
            if !searchText.isEmpty { Button { searchText = "" } label: { Image(systemName: "xmark.circle.fill").font(.system(size: 14)).foregroundColor(.plagitTertiary) } }
        }
        .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.md)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Quick Filters

    private var quickFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PlagitSpacing.sm) {
                ForEach(filters, id: \.self) { filter in
                    let isActive = selectedFilter == filter
                    let count = countFor(filter)
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { selectedFilter = filter }
                    } label: {
                        HStack(spacing: PlagitSpacing.xs) {
                            Text(filter == "All" ? L10n.t("all") : L10n.employmentType(filter)).font(PlagitFont.captionMedium())
                            if filter != "All" && count > 0 {
                                Text("\(count)")
                                    .font(PlagitFont.micro())
                                    .foregroundColor(isActive ? .white.opacity(0.7) : .plagitTertiary)
                            }
                        }
                        .foregroundColor(isActive ? .white : .plagitSecondary)
                        .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm)
                        .background(Capsule().fill(isActive ? Color.plagitTeal : Color.plagitSurface))
                        .overlay(Capsule().stroke(isActive ? Color.clear : Color.plagitBorder, lineWidth: 0.5))
                    }
                }
            }.padding(.horizontal, PlagitSpacing.xl)
        }
    }

    // MARK: - Sort Bar

    private var sortBar: some View {
        HStack {
            Text("\(filteredJobs.count) \(L10n.t("jobs_found"))").font(PlagitFont.captionMedium()).foregroundColor(.plagitSecondary)
            Spacer()
            Button { showSortMenu = true } label: {
                HStack(spacing: PlagitSpacing.xs) {
                    Image(systemName: "arrow.up.arrow.down").font(.system(size: 11, weight: .medium)).foregroundColor(.plagitTeal)
                    Text(selectedSort == "Best Match" ? L10n.t("best_match") : selectedSort == "Most Recent" ? L10n.t("most_recent") : L10n.t("sort_az")).font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                }
            }
        }
        .padding(.horizontal, PlagitSpacing.xl)
        .confirmationDialog(L10n.t("sort_by"), isPresented: $showSortMenu) {
            ForEach(sortOptions, id: \.self) { opt in Button(opt == "Best Match" ? L10n.t("best_match") : opt == "Most Recent" ? L10n.t("most_recent") : L10n.t("sort_az")) { selectedSort = opt } }
            Button(L10n.cancel, role: .cancel) {}
        }
    }

    // MARK: - Advanced Filters Sheet (edits DRAFT state)

    private var advancedFiltersSheet: some View {
        NavigationStack {
            ZStack {
                Color.plagitBackground.ignoresSafeArea()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: PlagitSpacing.sectionGap) {

                        filterSection(title: "Distance Radius", icon: "location.circle", isPremiumFilter: true) {
                            VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
                                HStack {
                                    Text("Within").font(PlagitFont.body()).foregroundColor(.plagitSecondary)
                                    Spacer()
                                    Text(draftDistanceKm >= 50 ? "Any distance" : "\(Int(draftDistanceKm)) km")
                                        .font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                                }
                                Slider(value: $draftDistanceKm, in: 5...50, step: 5)
                                    .tint(.plagitTeal)
                                    .disabled(!isPremium)
                            }
                        }

                        filterSection(title: "Salary Range", icon: "banknote", isPremiumFilter: true) {
                            HStack(spacing: PlagitSpacing.md) {
                                salaryField("Min", text: $draftSalaryMin)
                                Text("–").foregroundColor(.plagitTertiary)
                                salaryField("Max", text: $draftSalaryMax)
                            }
                        }

                        filterSection(title: "Contract Type", icon: "doc.text", isPremiumFilter: true) {
                            chipPicker(options: contractTypes, selection: $draftContractType)
                        }

                        filterSection(title: "Shift Type", icon: "clock.arrow.2.circlepath", isPremiumFilter: true) {
                            chipPicker(options: shiftTypes, selection: $draftShiftType)
                        }

                        filterSection(title: "Urgent Jobs Only", icon: "bolt.fill", isPremiumFilter: true) {
                            Toggle(isOn: isPremium ? $draftUrgentOnly : .constant(false)) {
                                Text("Show only urgent hiring positions")
                                    .font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
                            }
                            .tint(.plagitTeal)
                            .disabled(!isPremium)
                        }

                        filterSection(title: "Verified Businesses Only", icon: "checkmark.seal", isPremiumFilter: true) {
                            Toggle(isOn: isPremium ? $draftVerifiedOnly : .constant(false)) {
                                Text("Show only verified employers")
                                    .font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
                            }
                            .tint(.plagitTeal)
                            .disabled(!isPremium)
                        }

                        Spacer().frame(height: PlagitSpacing.xxl)
                    }
                    .padding(.top, PlagitSpacing.lg)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Reset") { resetDraft() }
                        .font(PlagitFont.captionMedium())
                        .foregroundColor(.plagitSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") { commitDraftAndReload() }
                        .font(PlagitFont.captionMedium())
                        .foregroundColor(.plagitTeal)
                }
            }
        }
        .presentationDetents([.large])
    }

    @ViewBuilder
    private func filterSection<Content: View>(title: String, icon: String, isPremiumFilter: Bool, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.md) {
            HStack(spacing: PlagitSpacing.sm) {
                Image(systemName: icon).font(.system(size: 13, weight: .medium)).foregroundColor(.plagitTeal)
                Text(title).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                Spacer()
                if isPremiumFilter && !isPremium {
                    Button { dismissAndUpgrade() } label: {
                        HStack(spacing: 3) {
                            Image(systemName: "crown.fill").font(.system(size: 9, weight: .bold))
                            Text("PRO").font(.system(size: 9, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 7).padding(.vertical, 3)
                        .background(Capsule().fill(Color.plagitAmber))
                    }
                }
            }

            if isPremiumFilter && !isPremium {
                ZStack {
                    content().opacity(0.3).allowsHitTesting(false)

                    Button { dismissAndUpgrade() } label: {
                        HStack(spacing: PlagitSpacing.sm) {
                            Image(systemName: "lock.fill").font(.system(size: 12, weight: .medium))
                            Text("Upgrade to Premium").font(PlagitFont.captionMedium())
                        }
                        .foregroundColor(.plagitAmber)
                        .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm)
                        .background(Capsule().fill(Color.plagitAmber.opacity(0.1)))
                    }
                }
            } else {
                content()
            }
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground)
            .shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func salaryField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .keyboardType(.numberPad)
            .font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
            .padding(PlagitSpacing.md)
            .background(RoundedRectangle(cornerRadius: PlagitRadius.sm).fill(Color.plagitSurface))
            .disabled(!isPremium)
    }

    private func chipPicker(options: [String], selection: Binding<String>) -> some View {
        let columns = [GridItem(.adaptive(minimum: 80), spacing: PlagitSpacing.sm)]
        return LazyVGrid(columns: columns, alignment: .leading, spacing: PlagitSpacing.sm) {
            ForEach(options, id: \.self) { option in
                let isActive = selection.wrappedValue == option
                Button {
                    if isPremium { selection.wrappedValue = option }
                } label: {
                    Text(option)
                        .font(PlagitFont.caption()).foregroundColor(isActive ? .white : .plagitSecondary)
                        .padding(.horizontal, PlagitSpacing.md).padding(.vertical, PlagitSpacing.sm)
                        .background(Capsule().fill(isActive ? Color.plagitTeal : Color.plagitSurface))
                }
                .disabled(!isPremium)
            }
        }
    }

    private func dismissAndUpgrade() {
        showFilters = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            showSubscription = true
        }
    }

    // MARK: - Job Card

    private func jobCard(_ job: FeaturedJobDTO) -> some View {
        let hue = job.businessAvatarHue ?? job.avatarHue

        return VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: PlagitSpacing.md) {
                ProfileAvatarView(photoUrl: nil, initials: job.businessInitials ?? "?", hue: hue, size: 44, verified: job.businessVerified == true)

                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    HStack(spacing: PlagitSpacing.sm) {
                        Text(job.title).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                        if job.businessVerified == true {
                            Image(systemName: "checkmark.seal.fill").font(.system(size: 10)).foregroundColor(.plagitVerified)
                        }
                    }

                    Text(job.businessName ?? "Unknown").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)

                    HStack(spacing: PlagitSpacing.sm) {
                        if let salary = job.salary, !salary.isEmpty {
                            Text(salary).font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal)
                        }
                        if let loc = job.location, !loc.isEmpty {
                            Text("·").foregroundColor(.plagitTertiary)
                            Text(loc).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                        }
                    }

                    HStack(spacing: PlagitSpacing.sm) {
                        if let type = job.employmentType {
                            Text(L10n.employmentType(type)).font(PlagitFont.micro()).foregroundColor(.plagitTeal)
                                .padding(.horizontal, PlagitSpacing.sm - 2).padding(.vertical, 2)
                                .background(Capsule().fill(Color.plagitTeal.opacity(0.08)))
                        }
                        if job.isFeatured {
                            Text(L10n.featured).font(PlagitFont.micro()).foregroundColor(.plagitAmber)
                                .padding(.horizontal, PlagitSpacing.sm - 2).padding(.vertical, 2)
                                .background(Capsule().fill(Color.plagitAmber.opacity(0.08)))
                        }
                        if job.isUrgent == true {
                            Text("Urgent").font(PlagitFont.micro()).foregroundColor(.plagitUrgent)
                                .padding(.horizontal, PlagitSpacing.sm - 2).padding(.vertical, 2)
                                .background(Capsule().fill(Color.plagitUrgent.opacity(0.08)))
                        }
                    }
                }

                Spacer()
            }
            .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.xl)

            Rectangle().fill(Color.plagitDivider).frame(height: 1).padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg)

            Button { selectedJobId = job.id; DispatchQueue.main.async { showJobDetail = true } } label: {
                HStack(spacing: PlagitSpacing.sm) {
                    Text(L10n.viewDetails).font(PlagitFont.captionMedium())
                    Image(systemName: "chevron.right").font(.system(size: 10, weight: .semibold))
                }
                .foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 10)
                .background(Capsule().fill(Color.plagitTeal))
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
                Image(systemName: !searchText.isEmpty ? "magnifyingglass" : "briefcase").font(.system(size: 20, weight: .medium)).foregroundColor(.plagitTeal)
            }
            VStack(spacing: PlagitSpacing.xs) {
                Text(!searchText.isEmpty ? "\(L10n.t("no_results_for")) \"\(searchText)\"" : L10n.t("no_jobs_match")).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                Text(L10n.t("try_adjusting")).font(PlagitFont.caption()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center)
            }
            HStack(spacing: PlagitSpacing.md) {
                if selectedFilter != "All" || applied.activeCount > 0 {
                    Button { clearAllFilters() } label: {
                        Text(L10n.t("clear_filters")).font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                            .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm)
                            .background(Capsule().fill(Color.plagitTealLight))
                    }
                }
                Button { selectedFilter = "All"; searchText = "" } label: {
                    Text(L10n.t("all_jobs")).font(PlagitFont.captionMedium()).foregroundColor(.white)
                        .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm)
                        .background(Capsule().fill(Color.plagitTeal))
                }
            }
        }.frame(maxWidth: .infinity).padding(.horizontal, PlagitSpacing.xxl)
    }
}

#Preview {
    NavigationStack { CandidateJobsView() }.preferredColorScheme(.light)
}
