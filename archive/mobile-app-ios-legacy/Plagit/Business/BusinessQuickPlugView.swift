//
//  BusinessQuickPlugView.swift
//  Plagit
//
//  Quick Plug — Tinder-style premium candidate discovery for businesses.
//  Swipe right = interested/shortlist, swipe left = pass.
//  Uses filtered candidates from Refine panel.
//

import SwiftUI

struct BusinessQuickPlugView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var location = LocationManager.shared

    // Candidates
    @State private var candidates: [NearbyCandidateDTO] = []
    @State private var isLoading = true
    @State private var currentIndex = 0
    @State private var dragOffset = CGSize.zero
    @State private var swipeDirection: SwipeDirection?

    // Refine filters
    @State private var showRefine = false
    @State private var filterRadius: Double = 15
    @State private var filterRoles: Set<String> = []
    @State private var filterNationalityCodes: Set<String> = []
    @State private var filterLocations: Set<String> = []
    @State private var filterJobType = "All"

    // Navigation
    @State private var showCandidateProfile = false
    @State private var selectedCandidate: NearbyCandidateDTO?
    @State private var showSubscription = false

    private let jobTypes = ["All", "Full-time", "Part-time", "Flexible"]

    enum SwipeDirection { case left, right }

    private var effectiveLat: Double? { location.hasLocation ? location.latitude : nil }
    private var effectiveLng: Double? { location.hasLocation ? location.longitude : nil }

    private var remainingCandidates: [NearbyCandidateDTO] {
        guard currentIndex < candidates.count else { return [] }
        return Array(candidates[currentIndex...].prefix(3))
    }

    /// Active filter count for badge
    private var activeFilterCount: Int {
        var n = 0
        if filterRadius != 15 { n += 1 }
        if !filterRoles.isEmpty { n += 1 }
        if !filterNationalityCodes.isEmpty { n += 1 }
        if !filterLocations.isEmpty { n += 1 }
        if filterJobType != "All" { n += 1 }
        return n
    }

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar

                if isLoading {
                    Spacer(); ProgressView().tint(.plagitPurple); Spacer()
                } else if candidates.isEmpty {
                    emptyState
                } else if currentIndex >= candidates.count {
                    doneState
                } else {
                    cardDeck
                    actionButtons.padding(.bottom, PlagitSpacing.xxl)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(item: $selectedCandidate) { candidate in
            QuickPlugCandidateProfileSheet(candidate: candidate)
        }
        .navigationDestination(isPresented: $showSubscription) {
            BusinessSubscriptionView().navigationBarHidden(true)
        }
        .sheet(isPresented: $showRefine) {
            QuickPlugRefineSheet(
                filterRadius: $filterRadius,
                filterRoles: $filterRoles,
                filterNationalityCodes: $filterNationalityCodes,
                filterLocations: $filterLocations,
                filterJobType: $filterJobType,
                jobTypes: jobTypes,
                onApply: {
                    showRefine = false
                    isLoading = true
                    Task { await loadCandidates() }
                }
            )
        }
        .onAppear { location.requestLocation() }
        .task { await loadCandidates() }
    }

    // MARK: - Load

    private func loadCandidates() async {
        isLoading = true
        guard let lat = effectiveLat, let lng = effectiveLng else {
            try? await Task.sleep(nanoseconds: 800_000_000)
            guard let lat = effectiveLat, let lng = effectiveLng else {
                isLoading = false; return
            }
            await fetchCandidates(lat: lat, lng: lng)
            return
        }
        await fetchCandidates(lat: lat, lng: lng)
    }

    private func fetchCandidates(lat: Double, lng: Double) async {
        let role = filterRoles.first // API takes single role — client-side filter handles multi
        do {
            var results = try await BusinessAPIService.shared.fetchNearbyCandidates(lat: lat, lng: lng, radius: filterRadius, limit: 50, role: role)
            // Client-side multi-role filter
            if filterRoles.count > 1 {
                let roles = filterRoles
                results = results.filter { c in
                    guard let r = c.role else { return false }
                    return roles.contains(r)
                }
            }
            // Job type filter
            if filterJobType != "All" {
                results = results.filter { $0.jobType == filterJobType }
            }
            // Nationality filter
            if !filterNationalityCodes.isEmpty {
                let codes = filterNationalityCodes
                results = results.filter { c in
                    guard let nc = c.nationalityCode else { return false }
                    return codes.contains(nc)
                }
            }
            // Location filter
            if !filterLocations.isEmpty {
                let locs = filterLocations.map { $0.lowercased() }
                results = results.filter { c in
                    guard let loc = c.location?.lowercased() else { return false }
                    return locs.contains { loc.contains($0) }
                }
            }
            candidates = results
        } catch {
            candidates = []
        }
        currentIndex = 0
        isLoading = false
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
            HStack(spacing: PlagitSpacing.sm) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.plagitPurple)
                Text("Quick Plug")
                    .font(PlagitFont.subheadline())
                    .foregroundColor(.plagitCharcoal)
            }
            Spacer()
            Button { showRefine = true } label: {
                HStack(spacing: 4) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 16, weight: .medium))
                    Text("Refine")
                        .font(PlagitFont.captionMedium())
                    if activeFilterCount > 0 {
                        Text("\(activeFilterCount)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 18, height: 18)
                            .background(Circle().fill(Color.plagitPurple))
                    }
                }
                .foregroundColor(.plagitPurple)
            }
        }
        .padding(.horizontal, PlagitSpacing.xl)
        .padding(.top, PlagitSpacing.lg)
        .padding(.bottom, PlagitSpacing.md)
    }

    // MARK: - Card Deck

    private var cardDeck: some View {
        ZStack {
            ForEach(Array(remainingCandidates.dropFirst().reversed().enumerated()), id: \.element.id) { index, candidate in
                candidateCard(candidate)
                    .scaleEffect(1.0 - Double(index + 1) * 0.04)
                    .offset(y: CGFloat(index + 1) * 8)
                    .allowsHitTesting(false)
            }

            if let frontCandidate = remainingCandidates.first {
                candidateCard(frontCandidate)
                    .offset(x: dragOffset.width, y: dragOffset.height * 0.3)
                    .rotationEffect(.degrees(Double(dragOffset.width) / 20))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation
                                if value.translation.width > 40 { swipeDirection = .right }
                                else if value.translation.width < -40 { swipeDirection = .left }
                                else { swipeDirection = nil }
                            }
                            .onEnded { value in
                                if abs(value.translation.width) > 120 {
                                    completeSwipe(direction: value.translation.width > 0 ? .right : .left)
                                } else {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        dragOffset = .zero; swipeDirection = nil
                                    }
                                }
                            }
                    )
                    .onTapGesture {
                        selectedCandidate = frontCandidate
                    }
                    .overlay(alignment: .topLeading) {
                        if swipeDirection == .left {
                            Text("PASS")
                                .font(.system(size: 32, weight: .black))
                                .foregroundColor(.plagitUrgent)
                                .padding(PlagitSpacing.xl)
                                .opacity(min(abs(Double(dragOffset.width)) / 120, 1.0))
                        }
                    }
                    .overlay(alignment: .topTrailing) {
                        if swipeDirection == .right {
                            Text("INTERESTED")
                                .font(.system(size: 28, weight: .black))
                                .foregroundColor(.plagitOnline)
                                .padding(PlagitSpacing.xl)
                                .opacity(min(abs(Double(dragOffset.width)) / 120, 1.0))
                        }
                    }
            }
        }
        .padding(.horizontal, PlagitSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func completeSwipe(direction: SwipeDirection) {
        let offscreen: CGFloat = direction == .right ? 500 : -500
        withAnimation(.easeOut(duration: 0.3)) {
            dragOffset = CGSize(width: offscreen, height: 0)
        }

        if direction == .right, currentIndex < candidates.count {
            _ = candidates[currentIndex]
        } else if currentIndex < candidates.count {
            _ = candidates[currentIndex]
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            currentIndex += 1
            dragOffset = .zero
            swipeDirection = nil
        }
    }

    // MARK: - Candidate Card (Immersive)

    private func candidateCard(_ c: NearbyCandidateDTO) -> some View {
        ZStack(alignment: .bottom) {
            // Full-bleed photo/avatar — tall, immersive
            if let photoUrl = c.photoUrl, let url = URL(string: photoUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        avatarPlaceholder(c)
                    }
                }
            } else {
                avatarPlaceholder(c)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: UIScreen.main.bounds.height * 0.62)
        .clipped()
        .overlay(alignment: .bottom) {
            // Gradient overlay with candidate info at bottom
            LinearGradient(colors: [.clear, .clear, .black.opacity(0.25), .black.opacity(0.75)], startPoint: .top, endPoint: .bottom)
                .overlay(alignment: .bottomLeading) {
                    VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
                        // Name + verified + flag
                        HStack(spacing: PlagitSpacing.sm) {
                            Text(c.name)
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.white)
                            if c.isVerified {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.plagitVerified)
                            }
                            if let code = c.nationalityCode, let country = CountryFlag.country(for: code) {
                                Text(country.flag)
                                    .font(.title3)
                            }
                        }

                        // Role
                        if let role = c.role {
                            Text(role)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white.opacity(0.92))
                        }

                        // Location + distance row
                        HStack(spacing: PlagitSpacing.lg) {
                            if let loc = c.location {
                                HStack(spacing: PlagitSpacing.xs) {
                                    Image(systemName: "mappin").font(.system(size: 12, weight: .medium)).foregroundColor(.white.opacity(0.7))
                                    Text(loc).font(PlagitFont.caption()).foregroundColor(.white.opacity(0.8))
                                }
                            }
                            if let dist = c.distanceKm {
                                HStack(spacing: PlagitSpacing.xs) {
                                    Image(systemName: "location.fill").font(.system(size: 11, weight: .medium)).foregroundColor(.plagitTeal)
                                    Text(String(format: "%.1f km", dist)).font(PlagitFont.captionMedium()).foregroundColor(.white.opacity(0.9))
                                }
                            }
                        }

                        // Badges
                        HStack(spacing: PlagitSpacing.sm) {
                            if let jt = c.jobType, !jt.isEmpty {
                                cardBadge(jt)
                            }
                            if let exp = c.experience, !exp.isEmpty {
                                cardBadge(exp)
                            }
                            if c.availableToRelocate == true {
                                cardBadge("Open to Relocate")
                            }
                        }
                    }
                    .padding(PlagitSpacing.xl)
                    .padding(.bottom, PlagitSpacing.sm)
                }
        }
        .overlay(alignment: .topTrailing) {
            // Tap hint
            Text("Tap for profile")
                .font(PlagitFont.micro())
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal, PlagitSpacing.sm)
                .padding(.vertical, PlagitSpacing.xs)
                .background(Capsule().fill(Color.black.opacity(0.3)))
                .padding(PlagitSpacing.lg)
        }
        .clipShape(RoundedRectangle(cornerRadius: PlagitRadius.xl + 4))
        .shadow(color: .black.opacity(0.15), radius: 16, y: 8)
    }

    private func avatarPlaceholder(_ c: NearbyCandidateDTO) -> some View {
        ZStack {
            Rectangle().fill(
                LinearGradient(
                    colors: [
                        Color(hue: c.avatarHue, saturation: 0.20, brightness: 0.92),
                        Color(hue: c.avatarHue, saturation: 0.15, brightness: 0.85)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            Text(c.initials ?? String(c.name.prefix(2)).uppercased())
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundColor(Color(hue: c.avatarHue, saturation: 0.35, brightness: 0.55))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func cardBadge(_ text: String) -> some View {
        Text(text)
            .font(PlagitFont.micro())
            .foregroundColor(.white)
            .padding(.horizontal, PlagitSpacing.sm)
            .padding(.vertical, 3)
            .background(Capsule().fill(Color.white.opacity(0.2)))
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: PlagitSpacing.xxl) {
            // Pass
            Button {
                completeSwipe(direction: .left)
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.plagitUrgent.opacity(0.1))
                        .frame(width: 60, height: 60)
                    Image(systemName: "xmark")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.plagitUrgent)
                }
            }

            // Interested / Shortlist — green = accept
            Button {
                completeSwipe(direction: .right)
            } label: {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [Color.plagitOnline, Color.plagitOnline.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 70, height: 70)
                        .shadow(color: Color.plagitOnline.opacity(0.3), radius: 8, y: 4)
                    Image(systemName: "checkmark")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }
            }

            // View Profile — teal (Plagit brand)
            Button {
                if let c = remainingCandidates.first {
                    selectedCandidate = c
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.plagitTeal.opacity(0.1))
                        .frame(width: 60, height: 60)
                    Image(systemName: "person.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.plagitTeal)
                }
            }
        }
        .padding(.top, PlagitSpacing.lg)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: PlagitSpacing.lg) {
            Spacer()
            ZStack {
                Circle().fill(Color.plagitPurple.opacity(0.1)).frame(width: 64, height: 64)
                Image(systemName: "bolt.fill").font(.system(size: 28, weight: .medium)).foregroundColor(.plagitPurple)
            }
            Text("No candidates found").font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
            Text("Try adjusting your Refine filters or expanding the search radius.")
                .font(PlagitFont.body()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center)
            Button { showRefine = true } label: {
                Text("Open Refine")
                    .font(PlagitFont.captionMedium()).foregroundColor(.white)
                    .padding(.horizontal, PlagitSpacing.xxl).padding(.vertical, PlagitSpacing.md)
                    .background(Capsule().fill(Color.plagitPurple))
            }
            Spacer()
        }
        .padding(.horizontal, PlagitSpacing.xxl)
    }

    // MARK: - Done State

    private var doneState: some View {
        VStack(spacing: PlagitSpacing.lg) {
            Spacer()
            ZStack {
                Circle().fill(Color.plagitOnline.opacity(0.1)).frame(width: 64, height: 64)
                Image(systemName: "checkmark.circle.fill").font(.system(size: 28, weight: .medium)).foregroundColor(.plagitOnline)
            }
            Text("All caught up!").font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
            Text("You've reviewed all \(candidates.count) candidates. Adjust filters to discover more.")
                .font(PlagitFont.body()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center)
            HStack(spacing: PlagitSpacing.md) {
                Button { showRefine = true } label: {
                    Text("Refine").font(PlagitFont.captionMedium()).foregroundColor(.plagitPurple)
                        .padding(.horizontal, PlagitSpacing.xxl).padding(.vertical, PlagitSpacing.md)
                        .background(Capsule().fill(Color.plagitPurple.opacity(0.1)))
                }
                Button {
                    currentIndex = 0
                } label: {
                    Text("Start Over").font(PlagitFont.captionMedium()).foregroundColor(.white)
                        .padding(.horizontal, PlagitSpacing.xxl).padding(.vertical, PlagitSpacing.md)
                        .background(Capsule().fill(Color.plagitPurple))
                }
            }
            Spacer()
        }
        .padding(.horizontal, PlagitSpacing.xxl)
    }

}

// MARK: - Refine Sheet (Premium Searchable Filters)

private struct QuickPlugRefineSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var filterRadius: Double
    @Binding var filterRoles: Set<String>
    @Binding var filterNationalityCodes: Set<String>
    @Binding var filterLocations: Set<String>
    @Binding var filterJobType: String
    let jobTypes: [String]
    var onApply: () -> Void

    // Sub-sheet navigation
    @State private var showRolePicker = false
    @State private var showNationalityPicker = false
    @State private var showLocationPicker = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.plagitBackground.ignoresSafeArea()
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: PlagitSpacing.sectionGap) {
                        // Distance
                        filterSection("Distance") {
                            VStack(spacing: PlagitSpacing.sm) {
                                HStack {
                                    Text("\(Int(filterRadius)) km")
                                        .font(PlagitFont.bodyMedium())
                                        .foregroundColor(.plagitTeal)
                                        .frame(width: 60)
                                    Slider(value: $filterRadius, in: 1...50, step: 1)
                                        .tint(.plagitTeal)
                                }
                                HStack {
                                    Text("1 km").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                                    Spacer()
                                    Text("50 km").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                                }
                            }
                        }

                        // Role — searchable picker
                        filterSection("Role") {
                            Button { showRolePicker = true } label: {
                                filterPickerButton(
                                    icon: "briefcase",
                                    placeholder: "Any role",
                                    values: Array(filterRoles).sorted(),
                                    emptyLabel: "All Roles"
                                )
                            }
                            .buttonStyle(.plain)
                        }

                        // Nationality — searchable picker
                        filterSection("Nationality") {
                            Button { showNationalityPicker = true } label: {
                                filterPickerButton(
                                    icon: "flag",
                                    placeholder: "Any nationality",
                                    values: filterNationalityCodes.sorted().map { code in
                                        let country = CountryFlag.country(for: code)
                                        return "\(country?.flag ?? "") \(country?.name ?? code)"
                                    },
                                    emptyLabel: "All Nationalities"
                                )
                            }
                            .buttonStyle(.plain)
                        }

                        // Location — searchable picker
                        filterSection("Location") {
                            Button { showLocationPicker = true } label: {
                                filterPickerButton(
                                    icon: "mappin.and.ellipse",
                                    placeholder: "Any location",
                                    values: Array(filterLocations).sorted(),
                                    emptyLabel: "All Locations"
                                )
                            }
                            .buttonStyle(.plain)
                        }

                        // Job Type — chip selection
                        filterSection("Job Type") {
                            HStack(spacing: PlagitSpacing.sm) {
                                ForEach(jobTypes, id: \.self) { jt in
                                    let active = filterJobType == jt
                                    Button { filterJobType = jt } label: {
                                        Text(jt)
                                            .font(PlagitFont.captionMedium())
                                            .foregroundColor(active ? .white : .plagitSecondary)
                                            .padding(.horizontal, PlagitSpacing.lg)
                                            .padding(.vertical, PlagitSpacing.sm + 2)
                                            .background(
                                                Capsule().fill(active ? Color.plagitTeal : Color.plagitSurface)
                                            )
                                            .overlay(
                                                Capsule().stroke(active ? Color.clear : Color.plagitBorder, lineWidth: 0.5)
                                            )
                                    }
                                }
                            }
                        }

                        // Selected filters summary
                        if hasActiveFilters {
                            activeFiltersSummary
                        }
                    }
                    .padding(PlagitSpacing.xxl)
                    .padding(.bottom, PlagitSpacing.xxxl)
                }
            }
            .navigationTitle("Refine Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Reset") {
                        filterRadius = 15
                        filterRoles.removeAll()
                        filterNationalityCodes.removeAll()
                        filterLocations.removeAll()
                        filterJobType = "All"
                    }
                    .font(PlagitFont.captionMedium()).foregroundColor(.plagitUrgent)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") { onApply() }
                        .font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal).bold()
                }
            }
            .sheet(isPresented: $showRolePicker) {
                QuickPlugRolePicker(selectedRoles: $filterRoles)
            }
            .sheet(isPresented: $showNationalityPicker) {
                QuickPlugNationalityPicker(selectedCodes: $filterNationalityCodes)
            }
            .sheet(isPresented: $showLocationPicker) {
                QuickPlugLocationPicker(selectedLocations: $filterLocations)
            }
        }
        .presentationDetents([.large])
    }

    private var hasActiveFilters: Bool {
        filterRadius != 15 || !filterRoles.isEmpty || !filterNationalityCodes.isEmpty || !filterLocations.isEmpty || filterJobType != "All"
    }

    // MARK: - Components

    private func filterSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.md) {
            Text(title)
                .font(PlagitFont.captionMedium())
                .foregroundColor(.plagitSecondary)
                .textCase(.uppercase)
                .tracking(0.5)
            content()
        }
    }

    private func filterPickerButton(icon: String, placeholder: String, values: [String], emptyLabel: String) -> some View {
        HStack(spacing: PlagitSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: PlagitRadius.sm)
                    .fill(values.isEmpty ? Color.plagitSurface : Color.plagitTeal.opacity(0.1))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(values.isEmpty ? .plagitTertiary : .plagitTeal)
            }

            if values.isEmpty {
                Text(emptyLabel)
                    .font(PlagitFont.body())
                    .foregroundColor(.plagitTertiary)
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(values.count) selected")
                        .font(PlagitFont.micro())
                        .foregroundColor(.plagitTeal)
                    Text(values.prefix(3).joined(separator: ", ") + (values.count > 3 ? " +\(values.count - 3)" : ""))
                        .font(PlagitFont.caption())
                        .foregroundColor(.plagitCharcoal)
                        .lineLimit(1)
                }
            }

            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.plagitTertiary)
        }
        .padding(PlagitSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: PlagitRadius.md)
                .fill(Color.plagitCardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: PlagitRadius.md)
                .stroke(values.isEmpty ? Color.plagitBorder.opacity(0.3) : Color.plagitTeal.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Active Filters Summary

    private var activeFiltersSummary: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.md) {
            Text("Active Filters")
                .font(PlagitFont.captionMedium())
                .foregroundColor(.plagitSecondary)
                .textCase(.uppercase)
                .tracking(0.5)

            FlowLayout(spacing: PlagitSpacing.sm) {
                if filterRadius != 15 {
                    filterChip("Within \(Int(filterRadius)) km") { filterRadius = 15 }
                }
                ForEach(Array(filterRoles).sorted(), id: \.self) { role in
                    filterChip(role) { filterRoles.remove(role) }
                }
                ForEach(Array(filterNationalityCodes).sorted(), id: \.self) { code in
                    let country = CountryFlag.country(for: code)
                    filterChip("\(country?.flag ?? "") \(country?.name ?? code)") { filterNationalityCodes.remove(code) }
                }
                ForEach(Array(filterLocations).sorted(), id: \.self) { loc in
                    filterChip(loc) { filterLocations.remove(loc) }
                }
                if filterJobType != "All" {
                    filterChip(filterJobType) { filterJobType = "All" }
                }
            }
        }
    }

    private func filterChip(_ label: String, onRemove: @escaping () -> Void) -> some View {
        HStack(spacing: PlagitSpacing.xs) {
            Text(label)
                .font(PlagitFont.caption())
                .foregroundColor(.plagitTeal)
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.plagitTeal.opacity(0.6))
            }
        }
        .padding(.horizontal, PlagitSpacing.md)
        .padding(.vertical, PlagitSpacing.sm)
        .background(Capsule().fill(Color.plagitTeal.opacity(0.08)))
        .overlay(Capsule().stroke(Color.plagitTeal.opacity(0.2), lineWidth: 0.5))
    }
}

// MARK: - Role Picker (Smart Searchable)

private struct QuickPlugRolePicker: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedRoles: Set<String>
    @State private var draft: Set<String> = []
    @State private var search = ""

    private var allRoles: [String] {
        var roles: [String] = []
        for cat in HospitalityCatalog.all {
            for sub in cat.subcategories {
                for role in sub.roles {
                    if !roles.contains(role.name) {
                        roles.append(role.name)
                    }
                }
            }
        }
        return roles.sorted()
    }

    private var filtered: [String] {
        if search.isEmpty { return allRoles }
        let q = search.lowercased()
        return allRoles.filter { $0.lowercased().contains(q) }
            .sorted { a, b in
                let aPrefix = a.lowercased().hasPrefix(q)
                let bPrefix = b.lowercased().hasPrefix(q)
                if aPrefix != bPrefix { return aPrefix }
                return a < b
            }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar
                selectedCount

                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(filtered, id: \.self) { role in
                            roleRow(role)
                        }
                    }
                    .padding(.bottom, PlagitSpacing.xxxl)
                }
            }
            .background(Color.plagitBackground)
            .navigationTitle("Select Roles")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .font(PlagitFont.captionMedium()).foregroundColor(.plagitSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { selectedRoles = draft; dismiss() }
                        .font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal).bold()
                }
            }
        }
        .onAppear { draft = selectedRoles }
    }

    private var searchBar: some View {
        HStack(spacing: PlagitSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.plagitTertiary)
            TextField("Search roles...", text: $search)
                .font(PlagitFont.body())
                .foregroundColor(.plagitCharcoal)
            if !search.isEmpty {
                Button { search = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.plagitTertiary)
                }
            }
        }
        .padding(.horizontal, PlagitSpacing.md)
        .padding(.vertical, PlagitSpacing.sm + 2)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
        .padding(.horizontal, PlagitSpacing.xl)
        .padding(.top, PlagitSpacing.md)
        .padding(.bottom, PlagitSpacing.sm)
    }

    private var selectedCount: some View {
        Group {
            if !draft.isEmpty {
                HStack {
                    Text("\(draft.count) selected")
                        .font(PlagitFont.micro())
                        .foregroundColor(.plagitTeal)
                    Spacer()
                    Button("Clear all") { draft.removeAll() }
                        .font(PlagitFont.micro())
                        .foregroundColor(.plagitUrgent)
                }
                .padding(.horizontal, PlagitSpacing.xl)
                .padding(.bottom, PlagitSpacing.sm)
            }
        }
    }

    private func roleRow(_ role: String) -> some View {
        let selected = draft.contains(role)
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                if selected { draft.remove(role) } else { draft.insert(role) }
            }
        } label: {
            HStack(spacing: PlagitSpacing.md) {
                Text(role)
                    .font(PlagitFont.body())
                    .foregroundColor(.plagitCharcoal)
                Spacer()
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20, weight: selected ? .medium : .light))
                    .foregroundColor(selected ? .plagitTeal : .plagitBorder)
            }
            .padding(.horizontal, PlagitSpacing.xl)
            .padding(.vertical, PlagitSpacing.md)
            .background(selected ? Color.plagitTeal.opacity(0.04) : Color.clear)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Nationality Picker (Searchable Country List)

private struct QuickPlugNationalityPicker: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCodes: Set<String>
    @State private var draft: Set<String> = []
    @State private var search = ""

    private var filtered: [Country] {
        let all = CountryFlag.allCountries
        if search.isEmpty { return all }
        let q = search.lowercased()
        return all.filter { $0.name.lowercased().contains(q) || $0.code.lowercased().contains(q) }
            .sorted { a, b in
                let aPrefix = a.name.lowercased().hasPrefix(q)
                let bPrefix = b.name.lowercased().hasPrefix(q)
                if aPrefix != bPrefix { return aPrefix }
                return a.name < b.name
            }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar
                selectedCount

                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(filtered) { country in
                            countryRow(country)
                        }
                    }
                    .padding(.bottom, PlagitSpacing.xxxl)
                }
            }
            .background(Color.plagitBackground)
            .navigationTitle("Select Nationality")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .font(PlagitFont.captionMedium()).foregroundColor(.plagitSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { selectedCodes = draft; dismiss() }
                        .font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal).bold()
                }
            }
        }
        .onAppear { draft = selectedCodes }
    }

    private var searchBar: some View {
        HStack(spacing: PlagitSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.plagitTertiary)
            TextField("Search countries...", text: $search)
                .font(PlagitFont.body())
                .foregroundColor(.plagitCharcoal)
            if !search.isEmpty {
                Button { search = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.plagitTertiary)
                }
            }
        }
        .padding(.horizontal, PlagitSpacing.md)
        .padding(.vertical, PlagitSpacing.sm + 2)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
        .padding(.horizontal, PlagitSpacing.xl)
        .padding(.top, PlagitSpacing.md)
        .padding(.bottom, PlagitSpacing.sm)
    }

    private var selectedCount: some View {
        Group {
            if !draft.isEmpty {
                HStack {
                    Text("\(draft.count) selected")
                        .font(PlagitFont.micro())
                        .foregroundColor(.plagitTeal)
                    Spacer()
                    Button("Clear all") { draft.removeAll() }
                        .font(PlagitFont.micro())
                        .foregroundColor(.plagitUrgent)
                }
                .padding(.horizontal, PlagitSpacing.xl)
                .padding(.bottom, PlagitSpacing.sm)
            }
        }
    }

    private func countryRow(_ c: Country) -> some View {
        let selected = draft.contains(c.code)
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                if selected { draft.remove(c.code) } else { draft.insert(c.code) }
            }
        } label: {
            HStack(spacing: PlagitSpacing.md) {
                Text(c.flag)
                    .font(.system(size: 28))
                    .frame(width: 36, height: 36)
                Text(c.name)
                    .font(PlagitFont.body())
                    .foregroundColor(.plagitCharcoal)
                Spacer()
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20, weight: selected ? .medium : .light))
                    .foregroundColor(selected ? .plagitTeal : .plagitBorder)
            }
            .padding(.horizontal, PlagitSpacing.xl)
            .padding(.vertical, PlagitSpacing.md)
            .background(selected ? Color.plagitTeal.opacity(0.04) : Color.clear)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Location Picker (Searchable City List)

private struct QuickPlugLocationPicker: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedLocations: Set<String>
    @State private var draft: Set<String> = []
    @State private var search = ""

    private var filtered: [String] {
        if search.isEmpty { return Self.hospitalityLocations }
        let q = search.lowercased()
        return Self.hospitalityLocations
            .filter { $0.lowercased().contains(q) }
            .sorted { a, b in
                let aPrefix = a.lowercased().hasPrefix(q)
                let bPrefix = b.lowercased().hasPrefix(q)
                if aPrefix != bPrefix { return aPrefix }
                return a < b
            }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar
                selectedCount

                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(filtered, id: \.self) { loc in
                            locationRow(loc)
                        }
                    }
                    .padding(.bottom, PlagitSpacing.xxxl)
                }
            }
            .background(Color.plagitBackground)
            .navigationTitle("Select Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .font(PlagitFont.captionMedium()).foregroundColor(.plagitSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { selectedLocations = draft; dismiss() }
                        .font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal).bold()
                }
            }
        }
        .onAppear { draft = selectedLocations }
    }

    private var searchBar: some View {
        HStack(spacing: PlagitSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.plagitTertiary)
            TextField("Search cities or regions...", text: $search)
                .font(PlagitFont.body())
                .foregroundColor(.plagitCharcoal)
            if !search.isEmpty {
                Button { search = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.plagitTertiary)
                }
            }
        }
        .padding(.horizontal, PlagitSpacing.md)
        .padding(.vertical, PlagitSpacing.sm + 2)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
        .padding(.horizontal, PlagitSpacing.xl)
        .padding(.top, PlagitSpacing.md)
        .padding(.bottom, PlagitSpacing.sm)
    }

    private var selectedCount: some View {
        Group {
            if !draft.isEmpty {
                HStack {
                    Text("\(draft.count) selected")
                        .font(PlagitFont.micro())
                        .foregroundColor(.plagitTeal)
                    Spacer()
                    Button("Clear all") { draft.removeAll() }
                        .font(PlagitFont.micro())
                        .foregroundColor(.plagitUrgent)
                }
                .padding(.horizontal, PlagitSpacing.xl)
                .padding(.bottom, PlagitSpacing.sm)
            }
        }
    }

    private func locationRow(_ loc: String) -> some View {
        let selected = draft.contains(loc)
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                if selected { draft.remove(loc) } else { draft.insert(loc) }
            }
        } label: {
            HStack(spacing: PlagitSpacing.md) {
                Image(systemName: "mappin.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(selected ? .plagitTeal : .plagitTertiary)
                    .frame(width: 32)
                Text(loc)
                    .font(PlagitFont.body())
                    .foregroundColor(.plagitCharcoal)
                Spacer()
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20, weight: selected ? .medium : .light))
                    .foregroundColor(selected ? .plagitTeal : .plagitBorder)
            }
            .padding(.horizontal, PlagitSpacing.xl)
            .padding(.vertical, PlagitSpacing.md)
            .background(selected ? Color.plagitTeal.opacity(0.04) : Color.clear)
        }
        .buttonStyle(.plain)
    }

    // Global hospitality locations — alphabetical
    static let hospitalityLocations: [String] = [
        "Abu Dhabi, UAE", "Accra, Ghana", "Adelaide, Australia", "Agadir, Morocco",
        "Amman, Jordan", "Amsterdam, Netherlands", "Antalya, Turkey", "Antigua",
        "Aprilia, Italy", "Athens, Greece", "Atlanta, USA", "Auckland, New Zealand",
        "Bahrain", "Baku, Azerbaijan", "Bali, Indonesia", "Bangkok, Thailand",
        "Barcelona, Spain", "Beijing, China", "Beirut, Lebanon", "Belgrade, Serbia",
        "Berlin, Germany", "Bermuda", "Birmingham, UK", "Bogota, Colombia",
        "Bologna, Italy", "Bordeaux, France", "Boston, USA", "Bratislava, Slovakia",
        "Brisbane, Australia", "Brussels, Belgium", "Bucharest, Romania",
        "Budapest, Hungary", "Buenos Aires, Argentina",
        "Cairo, Egypt", "Calgary, Canada", "Cancun, Mexico", "Cape Town, South Africa",
        "Cartagena, Colombia", "Casablanca, Morocco", "Chennai, India",
        "Chicago, USA", "Colombo, Sri Lanka", "Copenhagen, Denmark",
        "Dakar, Senegal", "Dallas, USA", "Dar es Salaam, Tanzania", "Delhi, India",
        "Doha, Qatar", "Dubai, UAE", "Dublin, Ireland", "Dubrovnik, Croatia",
        "Dusseldorf, Germany",
        "Edinburgh, UK",
        "Fiji", "Florence, Italy", "Frankfurt, Germany",
        "Geneva, Switzerland", "Glasgow, UK", "Goa, India",
        "Hanoi, Vietnam", "Havana, Cuba", "Helsinki, Finland",
        "Ho Chi Minh City, Vietnam", "Hong Kong, China", "Honolulu, USA",
        "Istanbul, Turkey",
        "Jakarta, Indonesia", "Jeddah, Saudi Arabia", "Johannesburg, South Africa",
        "Kigali, Rwanda", "Kuala Lumpur, Malaysia", "Kuwait City, Kuwait",
        "Kyoto, Japan",
        "Lagos, Nigeria", "Las Vegas, USA", "Latina, Italy", "Lima, Peru", "Lisbon, Portugal",
        "Liverpool, UK", "Ljubljana, Slovenia", "London, UK", "Los Angeles, USA",
        "Luanda, Angola", "Lugano, Switzerland", "Lyon, France",
        "Macau, China", "Madrid, Spain", "Malaga, Spain", "Maldives",
        "Manchester, UK", "Manila, Philippines", "Marrakech, Morocco",
        "Mauritius", "Medellin, Colombia", "Melbourne, Australia", "Mexico City, Mexico",
        "Miami, USA", "Milan, Italy", "Monaco", "Monterrey, Mexico",
        "Montreal, Canada", "Moscow, Russia", "Mumbai, India", "Munich, Germany",
        "Muscat, Oman", "Mykonos, Greece",
        "Nairobi, Kenya", "Naples, Italy", "Nassau, Bahamas", "New Orleans, USA",
        "New York, USA", "Nice, France", "Nicosia, Cyprus",
        "Orlando, USA", "Osaka, Japan", "Oslo, Norway",
        "Palma de Mallorca, Spain", "Panama City, Panama", "Paris, France",
        "Perth, Australia", "Phnom Penh, Cambodia", "Phuket, Thailand",
        "Pomezia, Italy", "Porto, Portugal", "Prague, Czech Republic", "Punta Cana, Dominican Republic",
        "Reykjavik, Iceland", "Riga, Latvia", "Rio de Janeiro, Brazil",
        "Riyadh, Saudi Arabia", "Rome, Italy",
        "San Diego, USA", "San Francisco, USA", "San Juan, Puerto Rico",
        "San Sebastian, Spain", "Santiago, Chile", "Santorini, Greece",
        "Sao Paulo, Brazil", "Sardinia, Italy", "Seattle, USA",
        "Seoul, South Korea", "Seville, Spain", "Shanghai, China",
        "Sharm El Sheikh, Egypt", "Singapore", "Sofia, Bulgaria",
        "St. Barts", "St. Moritz, Switzerland", "Stockholm, Sweden",
        "Sydney, Australia",
        "Taipei, Taiwan", "Tallinn, Estonia", "Tbilisi, Georgia",
        "Tel Aviv, Israel", "Tenerife, Spain", "Tokyo, Japan",
        "Toronto, Canada", "Tulum, Mexico", "Tunis, Tunisia",
        "Vancouver, Canada", "Venice, Italy", "Vienna, Austria",
        "Vilnius, Lithuania", "Viseu, Portugal",
        "Warsaw, Poland", "Washington DC, USA",
        "Yangon, Myanmar",
        "Zagreb, Croatia", "Zanzibar, Tanzania", "Zurich, Switzerland",
    ]
}

// MARK: - Quick Plug Candidate Profile Sheet

private struct QuickPlugCandidateProfileSheet: View {
    let candidate: NearbyCandidateDTO
    @Environment(\.dismiss) private var dismiss
    @State private var fullProfile: BizCandidateProfileDTO?
    @State private var isLoadingFull = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.plagitBackground.ignoresSafeArea()
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: PlagitSpacing.sectionGap) {
                        heroSection
                        detailsSection
                        if let full = fullProfile {
                            fullDetailSection(full)
                        }
                        Spacer().frame(height: PlagitSpacing.xxxl)
                    }
                    .padding(.top, PlagitSpacing.md)
                }
            }
            .navigationTitle("Candidate Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                }
            }
        }
        .task { await loadFullProfile() }
    }

    private func loadFullProfile() async {
        isLoadingFull = true
        do {
            fullProfile = try await BusinessAPIService.shared.fetchCandidateProfile(candidateId: candidate.id)
        } catch {
            // No full profile available — show Quick Plug data only
        }
        isLoadingFull = false
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: PlagitSpacing.xl) {
            HStack(spacing: PlagitSpacing.lg) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color(hue: candidate.avatarHue, saturation: 0.15, brightness: 0.92))
                        .frame(width: 72, height: 72)
                    if let photoUrl = candidate.photoUrl, let url = URL(string: photoUrl) {
                        AsyncImage(url: url) { phase in
                            if case .success(let img) = phase {
                                img.resizable().scaledToFill()
                                    .frame(width: 72, height: 72)
                                    .clipShape(Circle())
                            }
                        }
                    } else {
                        Text(candidate.initials ?? String(candidate.name.prefix(2)).uppercased())
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hue: candidate.avatarHue, saturation: 0.35, brightness: 0.55))
                    }
                    if candidate.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.plagitVerified)
                            .offset(x: 26, y: 26)
                    }
                }

                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    HStack(spacing: PlagitSpacing.sm) {
                        Text(candidate.name)
                            .font(PlagitFont.headline())
                            .foregroundColor(.plagitCharcoal)
                        if let code = candidate.nationalityCode, let country = CountryFlag.country(for: code) {
                            Text(country.flag)
                                .font(.title3)
                        }
                    }
                    if let role = candidate.role {
                        Text(role)
                            .font(PlagitFont.body())
                            .foregroundColor(.plagitSecondary)
                    }
                    if let loc = candidate.location {
                        HStack(spacing: PlagitSpacing.xs) {
                            Image(systemName: "mappin")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.plagitTeal)
                            Text(loc)
                                .font(PlagitFont.caption())
                                .foregroundColor(.plagitTeal)
                        }
                    }
                }
                Spacer()
            }
        }
        .padding(PlagitSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: PlagitRadius.xl)
                .fill(Color.plagitCardBackground)
                .shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY)
        )
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Details from Quick Plug data

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            if let dist = candidate.distanceKm {
                detailRow("location", "Distance", String(format: "%.1f km away", dist))
            }
            if let jt = candidate.jobType, !jt.isEmpty {
                detailRow("briefcase", "Job Type", jt)
            }
            if let exp = candidate.experience, !exp.isEmpty {
                detailRow("clock", "Experience", exp)
            }
            if let langs = candidate.languages, !langs.isEmpty {
                detailRow("globe", "Languages", Language.profileLabel(from: langs).isEmpty ? langs : Language.profileLabel(from: langs))
            }
            if let nc = candidate.nationalityCode, !nc.isEmpty {
                let country = CountryFlag.country(for: nc)
                detailRow("flag", "Nationality", "\(country?.flag ?? "") \(country?.name ?? nc)")
            }
            if candidate.availableToRelocate == true {
                detailRow("airplane", "Relocation", "Open to relocate")
            }
            detailRow("checkmark.shield", "Verification", candidate.isVerified ? "Verified" : "Pending")

            if isLoadingFull {
                HStack {
                    Spacer()
                    ProgressView().tint(.plagitTeal)
                    Text("Loading full profile...").font(PlagitFont.caption()).foregroundColor(.plagitTertiary)
                    Spacer()
                }
                .padding(.top, PlagitSpacing.sm)
            }
        }
        .padding(PlagitSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: PlagitRadius.xl)
                .fill(Color.plagitCardBackground)
                .shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY)
        )
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Full Profile (if API succeeds)

    private func fullDetailSection(_ p: BizCandidateProfileDTO) -> some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            Text("Full Profile")
                .font(PlagitFont.captionMedium())
                .foregroundColor(.plagitSecondary)
                .textCase(.uppercase)
                .tracking(0.5)

            if let email = p.email, !email.isEmpty {
                detailRow("envelope", "Email", email)
            }
            if let phone = p.phone, !phone.isEmpty {
                detailRow("phone", "Phone", phone)
            }
            if let nat = p.nationality, !nat.isEmpty {
                detailRow("flag", "Nationality", CountryFlag.label(country: nat, code: p.nationalityCode))
            }
        }
        .padding(PlagitSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: PlagitRadius.xl)
                .fill(Color.plagitCardBackground)
                .shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY)
        )
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func detailRow(_ icon: String, _ label: String, _ value: String) -> some View {
        HStack(spacing: PlagitSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.plagitTeal)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(PlagitFont.micro())
                    .foregroundColor(.plagitTertiary)
                Text(value)
                    .font(PlagitFont.body())
                    .foregroundColor(.plagitCharcoal)
            }
            Spacer()
        }
    }
}
