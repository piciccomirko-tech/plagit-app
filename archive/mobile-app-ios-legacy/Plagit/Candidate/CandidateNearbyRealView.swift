//
//  CandidateNearbyRealView.swift
//  Plagit
//
//  Real nearby jobs with list/map toggle, backed by GET /candidate/jobs/nearby.
//  Uses CoreLocation for device position and MapKit for map view.
//

import SwiftUI
import MapKit
import CoreLocation

struct CandidateNearbyRealView: View {
    var profileLat: Double?
    var profileLng: Double?

    @Environment(\.dismiss) private var dismiss
    @State private var location = LocationManager.shared

    // Effective coordinates: device GPS if granted, else profile stored coords
    private var effectiveLat: Double? { location.hasLocation ? location.latitude : profileLat }
    private var effectiveLng: Double? { location.hasLocation ? location.longitude : profileLng }
    private var hasCoordinates: Bool { effectiveLat != nil && effectiveLng != nil }

    @State private var jobs: [NearbyJobDTO] = []
    @State private var hasLoadedOnce = false
    @State private var isRefreshing = false
    @State private var loadError: String?
    @State private var selectedRadius: Double = 10
    @State private var selectedCategory = "All"
    @State private var viewMode: ViewMode = .list
    @State private var showJobDetail = false
    @State private var selectedJobId: String?
    @State private var selectedMapJob: NearbyJobDTO?
    @State private var mapPosition: MapCameraPosition = .automatic

    // Cache: key = "radius-category"
    @State private var cache: [String: [NearbyJobDTO]] = [:]
    // Debounce
    @State private var loadTask: Task<Void, Never>?

    private let radii: [Double] = [3, 5, 10, 15, 20]
    private let categories = ["All", "Chef", "Waiter", "Bartender", "Manager", "Reception", "Kitchen Porter"]

    private var cacheKey: String { "\(Int(selectedRadius))-\(selectedCategory)" }

    enum ViewMode { case list, map }

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                radiusAndToggle.padding(.top, PlagitSpacing.xs)
                categoryChips.padding(.top, PlagitSpacing.xs)
                summaryRow.padding(.top, PlagitSpacing.sm)

                if !hasCoordinates && location.authorizationStatus == .notDetermined {
                    Spacer(); locationPrompt; Spacer()
                } else if !hasCoordinates {
                    Spacer(); locationDenied; Spacer()
                } else if !hasLoadedOnce {
                    Spacer(); ProgressView().tint(.plagitTeal); Spacer()
                } else if let error = loadError, jobs.isEmpty {
                    Spacer()
                    VStack(spacing: PlagitSpacing.md) {
                        Image(systemName: "wifi.exclamationmark").font(.system(size: 32)).foregroundColor(.plagitTertiary)
                        Text(error).font(PlagitFont.caption()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center)
                        Button { Task { await loadFresh() } } label: { Text(L10n.retry).font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal) }
                    }.padding(PlagitSpacing.xxl)
                    Spacer()
                } else {
                    // Show content — keep visible during refreshes
                    ZStack(alignment: .top) {
                        switch viewMode {
                        case .list:
                            if jobs.isEmpty && !isRefreshing { ScrollView { emptyState.padding(.top, PlagitSpacing.xxl) } }
                            else { listContent }
                        case .map:
                            mapContent
                        }

                        // No spinner — results update in place
                    }
                }
            }

            // Floating pin card
            if let job = selectedMapJob, viewMode == .map {
                VStack {
                    Spacer()
                    pinCard(job)
                        .padding(.horizontal, PlagitSpacing.xl)
                        .padding(.bottom, PlagitSpacing.xl)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.easeInOut(duration: 0.25), value: selectedMapJob?.id)
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showJobDetail) {
            if let id = selectedJobId { CandidateJobDetailView(jobId: id).navigationBarHidden(true) }
        }
        .onAppear { location.requestLocation() }
        .onChange(of: location.latitude) { _, _ in if hasLoadedOnce { debouncedLoad() } }
        .onChange(of: selectedRadius) { _, _ in if hasLoadedOnce { debouncedLoad() } }
        .onChange(of: selectedCategory) { _, _ in if hasLoadedOnce { debouncedLoad() } }
        .task {
            // Wait briefly for GPS, then load with whatever coords we have
            if !hasCoordinates { try? await Task.sleep(nanoseconds: 500_000_000) }
            if hasCoordinates { await loadFresh() }
        }
    }

    /// Debounce rapid filter changes — waits 150ms before firing
    private func debouncedLoad() {
        loadTask?.cancel()
        loadTask = Task {
            try? await Task.sleep(nanoseconds: 150_000_000) // 150ms
            guard !Task.isCancelled else { return }
            await loadWithCache()
        }
    }

    private func loadFresh() async {
        guard let lat = effectiveLat, let lng = effectiveLng else { return }
        loadError = nil
        let cat = selectedCategory == "All" ? nil : selectedCategory
        do {
            let result = try await CandidateAPIService.shared.fetchNearbyJobs(lat: lat, lng: lng, radius: selectedRadius, category: cat)
            jobs = result
            cache[cacheKey] = result
        } catch { loadError = error.localizedDescription }
        hasLoadedOnce = true
        // Pre-warm wider radii for smart suggestions
        prewarmCache(lat: lat, lng: lng)
    }

    /// Cached load for filter/radius changes — keeps UI stable
    private func loadWithCache() async {
        guard let lat = effectiveLat, let lng = effectiveLng else { return }

        if let cached = cache[cacheKey] {
            withAnimation(.easeInOut(duration: 0.15)) { jobs = cached }
            hasLoadedOnce = true
            Task {
                let cat = selectedCategory == "All" ? nil : selectedCategory
                if let fresh = try? await CandidateAPIService.shared.fetchNearbyJobs(lat: lat, lng: lng, radius: selectedRadius, category: cat) {
                    cache[cacheKey] = fresh
                    if cacheKey == "\(Int(selectedRadius))-\(selectedCategory)" {
                        withAnimation(.easeInOut(duration: 0.15)) { jobs = fresh }
                    }
                }
            }
            return
        }

        // No cache — fetch without any central spinner
        loadError = nil
        let cat = selectedCategory == "All" ? nil : selectedCategory
        do {
            let result = try await CandidateAPIService.shared.fetchNearbyJobs(lat: lat, lng: lng, radius: selectedRadius, category: cat)
            cache[cacheKey] = result
            withAnimation(.easeInOut(duration: 0.15)) { jobs = result }
        } catch { loadError = error.localizedDescription }
        hasLoadedOnce = true
    }

    private func prewarmCache(lat: Double, lng: Double) {
        let currentCat = selectedCategory
        let currentR = selectedRadius
        Task {
            // Pre-warm wider radii for same category
            let cat = currentCat == "All" ? nil : currentCat
            for r in [10.0, 15.0, 20.0] where r > currentR {
                let key = "\(Int(r))-\(currentCat)"
                guard cache[key] == nil else { continue }
                if let data = try? await CandidateAPIService.shared.fetchNearbyJobs(lat: lat, lng: lng, radius: r, category: cat) {
                    cache[key] = data
                }
            }
            // Pre-warm "All" roles for current radius (for smart suggestion)
            if currentCat != "All" {
                let allKey = "\(Int(currentR))-All"
                if cache[allKey] == nil {
                    if let data = try? await CandidateAPIService.shared.fetchNearbyJobs(lat: lat, lng: lng, radius: currentR, category: nil) {
                        cache[allKey] = data
                    }
                }
            }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: { Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36) }
            Spacer()
            Text(L10n.jobsNearYou).font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.lg)
    }

    // MARK: - Radius + Toggle Row

    private var radiusAndToggle: some View {
        HStack(spacing: PlagitSpacing.md) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: PlagitSpacing.sm) {
                    ForEach(radii, id: \.self) { r in
                        let active = selectedRadius == r
                        Button { withAnimation(.easeInOut(duration: 0.2)) { selectedRadius = r } } label: {
                            Text("\(Int(r)) km").font(PlagitFont.captionMedium())
                                .foregroundColor(active ? .white : .plagitSecondary)
                                .padding(.horizontal, PlagitSpacing.md + 2).padding(.vertical, PlagitSpacing.sm)
                                .background(Capsule().fill(active ? Color.plagitTeal : Color.plagitSurface))
                                .overlay(Capsule().stroke(active ? Color.clear : Color.plagitBorder, lineWidth: 0.5))
                        }
                    }
                }
            }

            // List / Map toggle
            HStack(spacing: 0) {
                toggleButton("list.bullet", .list)
                toggleButton("map", .map)
            }
            .background(RoundedRectangle(cornerRadius: PlagitRadius.sm + 2).fill(Color.plagitSurface))
        }
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func toggleButton(_ icon: String, _ mode: ViewMode) -> some View {
        Button { withAnimation(.easeInOut(duration: 0.2)) { selectedMapJob = nil; viewMode = mode } } label: {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(viewMode == mode ? .white : .plagitTertiary)
                .frame(width: 34, height: 30)
                .background(RoundedRectangle(cornerRadius: PlagitRadius.sm).fill(viewMode == mode ? Color.plagitTeal : Color.clear))
        }
    }

    // MARK: - Category Chips

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PlagitSpacing.sm) {
                ForEach(categories, id: \.self) { cat in
                    let active = selectedCategory == cat
                    Button { withAnimation(.easeInOut(duration: 0.2)) { selectedCategory = cat } } label: {
                        Text(cat == "All" ? L10n.all : L10n.roleCategory(cat)).font(PlagitFont.captionMedium())
                            .foregroundColor(active ? .white : .plagitCharcoal)
                            .padding(.horizontal, PlagitSpacing.md).padding(.vertical, PlagitSpacing.sm)
                            .background(Capsule().fill(active ? Color.plagitTeal : Color.plagitSurface))
                            .overlay(Capsule().stroke(active ? Color.clear : Color.plagitBorder, lineWidth: 0.5))
                    }
                }
            }.padding(.horizontal, PlagitSpacing.xl)
        }
    }

    // MARK: - Summary

    private var summaryRow: some View {
        HStack(spacing: PlagitSpacing.sm) {
            HStack(spacing: PlagitSpacing.xs) {
                Circle().fill(jobs.isEmpty ? Color.plagitTertiary : Color.plagitOnline).frame(width: 6, height: 6)
                Text(jobs.isEmpty ? L10n.noResults : "\(jobs.count) \(L10n.t("jobs_found"))")
                    .font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal)
            }
            Text("·").foregroundColor(.plagitTertiary)
            Text("\(Int(selectedRadius)) km").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
            if selectedCategory != "All" {
                Text("·").foregroundColor(.plagitTertiary)
                Text(L10n.roleCategory(selectedCategory)).font(PlagitFont.micro()).foregroundColor(.plagitTeal)
            }
            Spacer()
        }.padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - List Content

    private var listContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: PlagitSpacing.md) {
                ForEach(jobs) { job in jobCard(job) }
            }
            .padding(.horizontal, PlagitSpacing.xl)
            .padding(.top, PlagitSpacing.lg)
            .padding(.bottom, PlagitSpacing.xxxl)
        }
    }

    // MARK: - Map Content

    private func recenterMap() {
        guard let lat = effectiveLat, let lng = effectiveLng else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            mapPosition = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: lat, longitude: lng),
                latitudinalMeters: selectedRadius * 1000 * 2.2,
                longitudinalMeters: selectedRadius * 1000 * 2.2))
        }
    }

    private var mapContent: some View {
        let userCoord = CLLocationCoordinate2D(latitude: effectiveLat ?? 0, longitude: effectiveLng ?? 0)

        return ZStack(alignment: .topTrailing) {
            Map(position: $mapPosition) {
                Annotation("You", coordinate: userCoord) {
                    ZStack {
                        Circle().fill(Color.plagitTeal.opacity(0.15)).frame(width: 32, height: 32)
                        Circle().fill(Color.plagitTeal).frame(width: 12, height: 12).overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }
                }
                ForEach(jobs.filter { $0.latitude != nil && $0.longitude != nil }) { job in
                    Annotation(job.title, coordinate: CLLocationCoordinate2D(latitude: job.latitude!, longitude: job.longitude!)) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { selectedMapJob = selectedMapJob?.id == job.id ? nil : job }
                        } label: {
                            ZStack {
                                Circle().fill(selectedMapJob?.id == job.id ? Color.plagitTeal : Color.plagitCardBackground)
                                    .frame(width: 36, height: 36).shadow(color: .black.opacity(0.12), radius: 4, y: 2)
                                Image(systemName: "briefcase.fill").font(.system(size: 14, weight: .medium))
                                    .foregroundColor(selectedMapJob?.id == job.id ? .white : .plagitTeal)
                            }
                        }
                    }
                }
            }
            .mapStyle(.standard(pointsOfInterest: .excludingAll))
            .mapControls { MapCompass() }
            .onTapGesture { withAnimation { selectedMapJob = nil } }

            // Recenter button
            Button { recenterMap() } label: {
                Image(systemName: "location.fill").font(.system(size: 14, weight: .medium)).foregroundColor(.plagitTeal)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.plagitCardBackground).shadow(color: .black.opacity(0.10), radius: 4, y: 2))
            }
            .padding(PlagitSpacing.md)

            // Slim floating empty pill on map
            if jobs.isEmpty {
                VStack {
                    Spacer()
                    HStack(spacing: PlagitSpacing.sm) {
                        Image(systemName: "location.magnifyingglass").font(.system(size: 13, weight: .medium)).foregroundColor(.plagitTeal)
                        Text(emptyTitle).font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal).lineLimit(1)
                        if let (r, c) = widerRadiusSuggestion {
                            Text("· \(c) at \(Int(r)) km").font(PlagitFont.micro()).foregroundColor(.plagitOnline).lineLimit(1)
                        }
                        Spacer()
                        if selectedRadius < 20 {
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) { selectedRadius = min(selectedRadius + 5, 20) }
                            } label: {
                                Text(L10n.t("expand")).font(PlagitFont.captionMedium()).foregroundColor(.white)
                                    .padding(.horizontal, PlagitSpacing.md).padding(.vertical, 5)
                                    .background(Capsule().fill(Color.plagitTeal))
                            }
                        }
                    }
                    .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm + 2)
                    .background(Capsule().fill(.ultraThinMaterial).shadow(color: .black.opacity(0.06), radius: 4, y: 2))
                    .padding(.horizontal, PlagitSpacing.xl).padding(.bottom, PlagitSpacing.lg)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: PlagitRadius.xl))
        .padding(.horizontal, PlagitSpacing.xl)
        .padding(.top, PlagitSpacing.sm)
        .onAppear { recenterMap() }
        .onChange(of: selectedRadius) { _, _ in recenterMap() }
    }

    // MARK: - Pin Card (floating overlay)

    private func pinCard(_ job: NearbyJobDTO) -> some View {
        let hue = job.businessAvatarHue ?? job.avatarHue
        return Button { selectedJobId = job.id; showJobDetail = true } label: {
            HStack(spacing: PlagitSpacing.md) {
                ProfileAvatarView(photoUrl: job.businessPhotoUrl, initials: job.businessInitials ?? "?", hue: hue, size: 40, verified: job.businessVerified == true)

                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    Text(job.title).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                    HStack(spacing: PlagitSpacing.sm) {
                        Text(job.businessName ?? "").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                        let pcflag = CountryFlag.emoji(for: job.businessCountryCode)
                        if !pcflag.isEmpty { Text(pcflag).font(.system(size: 11)) }
                        if let sal = job.salary, !sal.isEmpty { Text("·").foregroundColor(.plagitTertiary); Text(sal).font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal) }
                    }
                }

                Spacer()

                VStack(spacing: 2) {
                    Text(String(format: "%.1f", job.distanceKm)).font(.system(size: 15, weight: .bold, design: .rounded)).foregroundColor(.plagitTeal)
                    Text("km").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                }

                Image(systemName: "chevron.right").font(.system(size: 11, weight: .medium)).foregroundColor(.plagitTertiary)
            }
            .padding(PlagitSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: PlagitRadius.xl)
                    .fill(Color.plagitCardBackground)
                    .shadow(color: PlagitShadow.elevatedShadowColor, radius: PlagitShadow.elevatedShadowRadius, y: PlagitShadow.elevatedShadowY)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Job Card (list mode)

    private func jobCard(_ job: NearbyJobDTO) -> some View {
        let hue = job.businessAvatarHue ?? job.avatarHue
        return Button { selectedJobId = job.id; showJobDetail = true } label: {
            VStack(alignment: .leading, spacing: PlagitSpacing.md) {
                HStack(spacing: PlagitSpacing.md) {
                    ProfileAvatarView(photoUrl: job.businessPhotoUrl, initials: job.businessInitials ?? "?", hue: hue, size: 44, verified: job.businessVerified == true)

                    VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                        Text(job.title).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                        HStack(spacing: 4) {
                            Text(job.businessName ?? "Unknown").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                            let jflag = CountryFlag.emoji(for: job.businessCountryCode)
                            if !jflag.isEmpty { Text(jflag).font(.system(size: 11)) }
                        }
                        if let loc = job.location, !loc.isEmpty {
                            HStack(spacing: PlagitSpacing.xs) {
                                Image(systemName: "mappin").font(.system(size: 9, weight: .medium)).foregroundColor(.plagitTertiary)
                                Text(loc).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                            }
                        }
                    }
                    Spacer()
                    VStack(spacing: 2) {
                        Text(String(format: "%.1f", job.distanceKm)).font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(.plagitTeal)
                        Text("km").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                    }
                }

                // Tags row
                HStack(spacing: PlagitSpacing.sm) {
                    if let sal = job.salary, !sal.isEmpty {
                        tagPill(sal, .plagitCharcoal)
                    }
                    if let type = job.employmentType {
                        tagPill(L10n.employmentType(type), .plagitTeal)
                    }
                    if job.isFeatured {
                        tagPill(L10n.featured, .plagitAmber)
                    }
                }

                // Quick action
                HStack(spacing: PlagitSpacing.sm) {
                    Text(L10n.viewDetails).font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                    Image(systemName: "chevron.right").font(.system(size: 10, weight: .semibold)).foregroundColor(.plagitTeal)
                }
            }
            .padding(PlagitSpacing.xl)
            .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
        }
        .buttonStyle(.plain)
    }

    private func tagPill(_ text: String, _ color: Color) -> some View {
        Text(text).font(PlagitFont.micro()).foregroundColor(color)
            .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 2)
            .background(Capsule().fill(color.opacity(0.08)))
    }

    // MARK: - Location Prompt

    private var locationPrompt: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack { Circle().fill(Color.plagitTealLight).frame(width: 56, height: 56); Image(systemName: "location.fill").font(.system(size: 24, weight: .medium)).foregroundColor(.plagitTeal) }
            Text(L10n.t("enable_location")).font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
            Text(L10n.t("allow_location_desc")).font(PlagitFont.caption()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center)
            Button { location.requestPermission() } label: {
                Text(L10n.t("allow_location")).font(PlagitFont.captionMedium()).foregroundColor(.white)
                    .padding(.horizontal, PlagitSpacing.xxl).padding(.vertical, PlagitSpacing.md)
                    .background(Capsule().fill(Color.plagitTeal))
            }
        }.padding(.horizontal, PlagitSpacing.xxl)
    }

    // MARK: - Location Denied

    private var locationDenied: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack { Circle().fill(Color.plagitUrgent.opacity(0.08)).frame(width: 56, height: 56); Image(systemName: "location.slash").font(.system(size: 24, weight: .medium)).foregroundColor(.plagitUrgent) }
            Text(L10n.t("location_access_needed")).font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
            Text(L10n.t("location_denied_desc")).font(PlagitFont.caption()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center)
            Button { if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) } } label: {
                Text(L10n.t("open_settings")).font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                    .padding(.horizontal, PlagitSpacing.xxl).padding(.vertical, PlagitSpacing.md)
                    .background(Capsule().fill(Color.plagitTealLight))
            }
        }.padding(.horizontal, PlagitSpacing.xxl)
    }

    // MARK: - Smart Empty State

    private var widerRadiusSuggestion: (Double, Int)? {
        for r in radii where r > selectedRadius {
            let key = "\(Int(r))-\(selectedCategory)"
            if let cached = cache[key], !cached.isEmpty { return (r, cached.count) }
        }
        return nil
    }

    private var allRolesSuggestion: Int? {
        guard selectedCategory != "All" else { return nil }
        let key = "\(Int(selectedRadius))-All"
        if let cached = cache[key], !cached.isEmpty { return cached.count }
        return nil
    }

    private var emptyTitle: String {
        selectedCategory != "All" ? "\(L10n.roleCategory(selectedCategory)) — \(L10n.t("no_jobs_found"))" : L10n.t("no_jobs_found")
    }
    private var emptySubtitle: String {
        "\(L10n.t("within_km")) \(Int(selectedRadius)) km"
    }
    private var emptyHelper: String? {
        if widerRadiusSuggestion != nil { return nil } // hint card handles it
        if allRolesSuggestion != nil { return nil }
        if selectedCategory != "All" { return L10n.t("try_all_roles") }
        return L10n.t("closest_openings")
    }

    private var emptyState: some View {
        VStack(spacing: PlagitSpacing.md) {
            // Header
            VStack(spacing: 4) {
                Text(emptyTitle).font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
                Text(emptySubtitle).font(PlagitFont.caption()).foregroundColor(.plagitTertiary)
                if let helper = emptyHelper {
                    Text(helper).font(PlagitFont.micro()).foregroundColor(.plagitSecondary)
                        .padding(.top, 2)
                }
            }.multilineTextAlignment(.center)
            .padding(.top, PlagitSpacing.lg)

            // Smart hints
            if widerRadiusSuggestion != nil || allRolesSuggestion != nil {
                VStack(spacing: PlagitSpacing.xs) {
                    if let (radius, count) = widerRadiusSuggestion {
                        smartHint(icon: "sparkles", color: .plagitOnline,
                            text: "\(count) job\(count == 1 ? "" : "s") at \(Int(radius)) km", action: "Show"
                        ) { withAnimation(.easeInOut(duration: 0.2)) { selectedRadius = radius } }
                    }
                    if let count = allRolesSuggestion {
                        smartHint(icon: "rectangle.stack", color: .plagitIndigo,
                            text: "\(count) across all roles", action: "View"
                        ) { withAnimation(.easeInOut(duration: 0.2)) { selectedCategory = "All" } }
                    }
                }
            }

            // CTA row — primary + secondary
            HStack(spacing: PlagitSpacing.sm) {
                if selectedRadius < 20 {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { selectedRadius = min(selectedRadius + 5, 20) }
                    } label: {
                        Text("Expand to \(Int(min(selectedRadius + 5, 20))) km")
                            .font(PlagitFont.captionMedium()).foregroundColor(.white)
                            .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm + 2)
                            .background(Capsule().fill(Color.plagitTeal))
                    }
                }
                if selectedCategory != "All" {
                    emptyBtn("All roles") { withAnimation(.easeInOut(duration: 0.2)) { selectedCategory = "All" } }
                }
                emptyBtn(viewMode == .list ? "Map" : "List") {
                    withAnimation(.easeInOut(duration: 0.2)) { viewMode = viewMode == .list ? .map : .list }
                }
            }
            .padding(.bottom, PlagitSpacing.md)
        }
        .padding(.horizontal, PlagitSpacing.lg)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground)
            .shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func smartHint(icon: String, color: Color, text: String, action: String, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            HStack(spacing: PlagitSpacing.sm) {
                Image(systemName: icon).font(.system(size: 12, weight: .medium)).foregroundColor(color)
                Text(text).font(PlagitFont.caption()).foregroundColor(.plagitCharcoal)
                Spacer()
                Text(action).font(PlagitFont.captionMedium()).foregroundColor(color)
            }
            .padding(.horizontal, PlagitSpacing.md).padding(.vertical, PlagitSpacing.sm)
            .background(RoundedRectangle(cornerRadius: PlagitRadius.sm).fill(color.opacity(0.04)))
        }
    }

    private func emptyBtn(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label).font(PlagitFont.captionMedium()).foregroundColor(.plagitTertiary)
                .padding(.horizontal, PlagitSpacing.md).padding(.vertical, PlagitSpacing.sm)
                .background(Capsule().fill(Color.plagitSurface))
        }
    }
}
