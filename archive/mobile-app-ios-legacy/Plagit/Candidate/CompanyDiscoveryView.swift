//
//  CompanyDiscoveryView.swift
//  Plagit
//
//  Map-based hospitality company discovery.
//  Same UX pattern as CandidateNearbyRealView but for service companies.
//

import SwiftUI
import MapKit
import CoreLocation

struct CompanyDiscoveryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var location = LocationManager.shared

    @State private var searchText = ""
    @State private var selectedCategoryId: String?
    @State private var selectedRadius: Double = 10
    @State private var viewMode: ViewMode = .list
    @State private var verifiedOnly = false
    @State private var showFilters = false
    @State private var showCompanyProfile = false
    @State private var selectedCompany: ServiceCompany?
    @State private var selectedMapCompany: ServiceCompany?
    @State private var mapPosition: MapCameraPosition = .automatic

    private var effectiveLat: Double? { location.hasLocation ? location.latitude : nil }
    private var effectiveLng: Double? { location.hasLocation ? location.longitude : nil }
    private var hasCoordinates: Bool { effectiveLat != nil && effectiveLng != nil }

    private let radii: [Double] = [3, 5, 10, 15, 20]

    enum ViewMode { case list, map }

    private var filteredCompanies: [ServiceCompany] {
        var results = ServiceCatalog.searchCompanies(
            query: searchText,
            categoryId: selectedCategoryId,
            verifiedOnly: verifiedOnly
        )
        // Distance filter when we have coordinates
        if let lat = effectiveLat, let lng = effectiveLng {
            let userLoc = CLLocation(latitude: lat, longitude: lng)
            results = results.filter { co in
                guard let cLat = co.latitude, let cLng = co.longitude else { return true }
                let dist = userLoc.distance(from: CLLocation(latitude: cLat, longitude: cLng)) / 1000
                return dist <= selectedRadius
            }
        }
        return results
    }

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar
                searchBar
                radiusAndToggle.padding(.top, PlagitSpacing.xs)
                categoryChips.padding(.top, PlagitSpacing.xs)
                summaryRow.padding(.top, PlagitSpacing.sm)

                if !hasCoordinates && location.authorizationStatus == .notDetermined {
                    Spacer(); locationPrompt; Spacer()
                } else if filteredCompanies.isEmpty {
                    emptyState
                } else {
                    switch viewMode {
                    case .list: listContent
                    case .map:  mapContent
                    }
                }
            }

            // Floating pin card on map
            if let co = selectedMapCompany, viewMode == .map {
                VStack {
                    Spacer()
                    pinCard(co)
                        .padding(.horizontal, PlagitSpacing.xl)
                        .padding(.bottom, PlagitSpacing.xl)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.easeInOut(duration: 0.25), value: selectedMapCompany?.id)
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showCompanyProfile) {
            if let company = selectedCompany {
                ServiceCompanyProfileView(company: company).navigationBarHidden(true)
            }
        }
        .sheet(isPresented: $showFilters) { filterSheet }
        .onAppear { location.requestLocation() }
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
            Text(L10n.findCompanies)
                .font(PlagitFont.subheadline())
                .foregroundColor(.plagitCharcoal)
            Spacer()
            Button { showFilters = true } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.plagitCharcoal)
                        .frame(width: 36, height: 36)
                    if verifiedOnly {
                        Circle().fill(Color.plagitAmber).frame(width: 8, height: 8).offset(x: 3, y: -1)
                    }
                }
            }
        }
        .padding(.horizontal, PlagitSpacing.xl)
        .padding(.top, PlagitSpacing.lg)
        .padding(.bottom, PlagitSpacing.sm)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: PlagitSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.plagitTertiary)
            TextField("Search companies, services, locations...", text: $searchText)
                .font(PlagitFont.body())
                .foregroundColor(.plagitCharcoal)
            if !searchText.isEmpty {
                Button { searchText = "" } label: {
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
    }

    // MARK: - Radius + Toggle

    private var radiusAndToggle: some View {
        HStack(spacing: PlagitSpacing.md) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: PlagitSpacing.sm) {
                    ForEach(radii, id: \.self) { r in
                        let active = selectedRadius == r
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { selectedRadius = r }
                        } label: {
                            Text("\(Int(r)) km")
                                .font(PlagitFont.captionMedium())
                                .foregroundColor(active ? .white : .plagitSecondary)
                                .padding(.horizontal, PlagitSpacing.md + 2)
                                .padding(.vertical, PlagitSpacing.sm)
                                .background(Capsule().fill(active ? Color.plagitAmber : Color.plagitSurface))
                                .overlay(Capsule().stroke(active ? Color.clear : Color.plagitBorder, lineWidth: 0.5))
                        }
                    }
                }
            }

            HStack(spacing: 0) {
                toggleButton("list.bullet", .list)
                toggleButton("map", .map)
            }
            .background(RoundedRectangle(cornerRadius: PlagitRadius.sm + 2).fill(Color.plagitSurface))
        }
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func toggleButton(_ icon: String, _ mode: ViewMode) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { selectedMapCompany = nil; viewMode = mode }
        } label: {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(viewMode == mode ? .white : .plagitTertiary)
                .frame(width: 34, height: 30)
                .background(RoundedRectangle(cornerRadius: PlagitRadius.sm).fill(viewMode == mode ? Color.plagitAmber : Color.clear))
        }
    }

    // MARK: - Category Chips

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PlagitSpacing.sm) {
                chipButton(label: "All", icon: nil, isActive: selectedCategoryId == nil) {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedCategoryId = nil }
                }
                ForEach(ServiceCatalog.all) { cat in
                    chipButton(label: cat.name, icon: cat.icon, isActive: selectedCategoryId == cat.id) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategoryId = selectedCategoryId == cat.id ? nil : cat.id
                        }
                    }
                }
            }
            .padding(.horizontal, PlagitSpacing.xl)
        }
    }

    private func chipButton(label: String, icon: String?, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: PlagitSpacing.xs) {
                if let icon { Image(systemName: icon).font(.system(size: 11, weight: .medium)) }
                Text(label).font(PlagitFont.captionMedium())
            }
            .foregroundColor(isActive ? .white : .plagitSecondary)
            .padding(.horizontal, PlagitSpacing.lg)
            .padding(.vertical, PlagitSpacing.sm)
            .background(Capsule().fill(isActive ? Color.plagitAmber : Color.plagitSurface))
            .overlay(Capsule().stroke(isActive ? Color.clear : Color.plagitBorder, lineWidth: 0.5))
        }
    }

    // MARK: - Summary Row

    private var summaryRow: some View {
        HStack(spacing: PlagitSpacing.sm) {
            HStack(spacing: PlagitSpacing.xs) {
                Circle().fill(filteredCompanies.isEmpty ? Color.plagitTertiary : Color.plagitOnline).frame(width: 6, height: 6)
                Text(filteredCompanies.isEmpty ? "No results" : "\(filteredCompanies.count) companies")
                    .font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal)
            }
            Text("·").foregroundColor(.plagitTertiary)
            Text("\(Int(selectedRadius)) km").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
            if let catId = selectedCategoryId, let cat = ServiceCatalog.category(id: catId) {
                Text("·").foregroundColor(.plagitTertiary)
                Text(cat.name).font(PlagitFont.micro()).foregroundColor(.plagitAmber)
            }
            Spacer()
        }
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - List Content

    private var listContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: PlagitSpacing.md) {
                ForEach(filteredCompanies) { co in companyCard(co) }
            }
            .padding(.horizontal, PlagitSpacing.xl)
            .padding(.top, PlagitSpacing.lg)
            .padding(.bottom, PlagitSpacing.xxxl)
        }
    }

    private func companyCard(_ co: ServiceCompany) -> some View {
        Button {
            selectedCompany = co; showCompanyProfile = true
        } label: {
            VStack(alignment: .leading, spacing: PlagitSpacing.md) {
                HStack(spacing: PlagitSpacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: PlagitRadius.md)
                            .fill(Color(hue: co.avatarHue, saturation: 0.15, brightness: 0.95))
                            .frame(width: 48, height: 48)
                        Text(co.initials)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hue: co.avatarHue, saturation: 0.6, brightness: 0.5))
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: PlagitSpacing.sm) {
                            Text(co.name).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal).lineLimit(1)
                            if co.isVerified {
                                Image(systemName: "checkmark.seal.fill").font(.system(size: 12)).foregroundColor(.plagitVerified)
                            }
                            if co.isPremium {
                                Text("PRO").font(.system(size: 8, weight: .bold)).foregroundColor(.white)
                                    .padding(.horizontal, 5).padding(.vertical, 2)
                                    .background(Capsule().fill(Color.plagitAmber))
                            }
                        }
                        Text(co.subcategoryName).font(PlagitFont.caption()).foregroundColor(.plagitTeal).lineLimit(1)
                    }
                    Spacer()
                    if let rating = co.rating {
                        VStack(spacing: 2) {
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill").font(.system(size: 10)).foregroundColor(.plagitAmber)
                                Text(String(format: "%.1f", rating)).font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal)
                            }
                            Text("\(co.reviewCount)").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                        }
                    }
                }
                Text(co.description).font(PlagitFont.caption()).foregroundColor(.plagitSecondary).lineLimit(2)
                HStack(spacing: PlagitSpacing.sm) {
                    Image(systemName: "mappin").font(.system(size: 10, weight: .medium)).foregroundColor(.plagitTeal)
                    Text(co.location).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                    if let lat = effectiveLat, let lng = effectiveLng, let cLat = co.latitude, let cLng = co.longitude {
                        let dist = CLLocation(latitude: lat, longitude: lng).distance(from: CLLocation(latitude: cLat, longitude: cLng)) / 1000
                        Text(String(format: "%.1f km", dist)).font(PlagitFont.micro()).foregroundColor(.plagitAmber)
                    }
                    Spacer()
                    if co.isAvailable {
                        HStack(spacing: 3) {
                            Circle().fill(Color.plagitOnline).frame(width: 6, height: 6)
                            Text("Available").font(PlagitFont.micro()).foregroundColor(.plagitOnline)
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
        }
        .buttonStyle(.plain)
    }

    // MARK: - Map Content

    private var mapContent: some View {
        let userCoord = CLLocationCoordinate2D(latitude: effectiveLat ?? 0, longitude: effectiveLng ?? 0)

        return ZStack(alignment: .topTrailing) {
            Map(position: $mapPosition) {
                // User pin
                Annotation("You", coordinate: userCoord) {
                    ZStack {
                        Circle().fill(Color.plagitAmber.opacity(0.15)).frame(width: 32, height: 32)
                        Circle().fill(Color.plagitAmber).frame(width: 12, height: 12)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }
                }
                // Company pins
                ForEach(filteredCompanies.filter { $0.latitude != nil && $0.longitude != nil }) { co in
                    Annotation(co.name, coordinate: CLLocationCoordinate2D(latitude: co.latitude!, longitude: co.longitude!)) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedMapCompany = selectedMapCompany?.id == co.id ? nil : co
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(selectedMapCompany?.id == co.id ? Color.plagitAmber : Color.plagitCardBackground)
                                    .frame(width: 36, height: 36)
                                    .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
                                Image(systemName: ServiceCatalog.category(id: co.categoryId)?.icon ?? "building.2")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(selectedMapCompany?.id == co.id ? .white : .plagitAmber)
                            }
                        }
                    }
                }
            }
            .mapStyle(.standard(pointsOfInterest: .excludingAll))
            .mapControls { MapCompass() }
            .onTapGesture { withAnimation { selectedMapCompany = nil } }

            // Recenter button
            Button { recenterMap() } label: {
                Image(systemName: "location.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.plagitAmber)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.plagitCardBackground).shadow(color: .black.opacity(0.10), radius: 4, y: 2))
            }
            .padding(PlagitSpacing.md)
        }
        .onAppear { recenterMap() }
        .onChange(of: selectedRadius) { _, _ in recenterMap() }
    }

    private func recenterMap() {
        guard let lat = effectiveLat, let lng = effectiveLng else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            mapPosition = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: lat, longitude: lng),
                latitudinalMeters: selectedRadius * 1000 * 2.2,
                longitudinalMeters: selectedRadius * 1000 * 2.2))
        }
    }

    // MARK: - Pin Card (floating on map)

    private func pinCard(_ co: ServiceCompany) -> some View {
        Button {
            selectedCompany = co; showCompanyProfile = true
        } label: {
            HStack(spacing: PlagitSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: PlagitRadius.sm)
                        .fill(Color(hue: co.avatarHue, saturation: 0.15, brightness: 0.95))
                        .frame(width: 44, height: 44)
                    Text(co.initials)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hue: co.avatarHue, saturation: 0.6, brightness: 0.5))
                }
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: PlagitSpacing.sm) {
                        Text(co.name).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal).lineLimit(1)
                        if co.isVerified {
                            Image(systemName: "checkmark.seal.fill").font(.system(size: 11)).foregroundColor(.plagitVerified)
                        }
                    }
                    Text(co.subcategoryName).font(PlagitFont.caption()).foregroundColor(.plagitTeal).lineLimit(1)
                    HStack(spacing: PlagitSpacing.xs) {
                        Image(systemName: "mappin").font(.system(size: 9, weight: .medium)).foregroundColor(.plagitAmber)
                        Text(co.location).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.plagitTertiary)
            }
            .padding(PlagitSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: PlagitRadius.xl)
                    .fill(Color.plagitCardBackground)
                    .shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Filter Sheet

    private var filterSheet: some View {
        NavigationStack {
            ZStack {
                Color.plagitBackground.ignoresSafeArea()
                VStack(spacing: PlagitSpacing.lg) {
                    Toggle(isOn: $verifiedOnly) {
                        HStack(spacing: PlagitSpacing.sm) {
                            Image(systemName: "checkmark.seal.fill").font(.system(size: 14)).foregroundColor(.plagitVerified)
                            Text("Verified Only").font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
                        }
                    }.tint(.plagitAmber)

                    Spacer()

                    Button { verifiedOnly = false } label: {
                        Text("Reset Filters")
                            .font(PlagitFont.captionMedium())
                            .foregroundColor(.plagitUrgent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, PlagitSpacing.md)
                            .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitUrgent.opacity(0.06)))
                    }
                }
                .padding(PlagitSpacing.xxl)
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showFilters = false }
                        .font(PlagitFont.captionMedium()).foregroundColor(.plagitAmber)
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Location Prompt

    private var locationPrompt: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack {
                Circle().fill(Color.plagitAmber.opacity(0.1)).frame(width: 56, height: 56)
                Image(systemName: "location.fill").font(.system(size: 24, weight: .medium)).foregroundColor(.plagitAmber)
            }
            Text("Enable Location").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
            Text("Allow location access to find companies near you.")
                .font(PlagitFont.caption()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center)
            Button { location.requestLocation() } label: {
                Text("Enable")
                    .font(PlagitFont.captionMedium()).foregroundColor(.white)
                    .padding(.horizontal, PlagitSpacing.xxl).padding(.vertical, PlagitSpacing.md)
                    .background(Capsule().fill(Color.plagitAmber))
            }
        }
        .padding(.horizontal, PlagitSpacing.xxl)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: PlagitSpacing.lg) {
            Spacer()
            ZStack {
                Circle().fill(Color.plagitAmber.opacity(0.1)).frame(width: 56, height: 56)
                Image(systemName: "building.2").font(.system(size: 24, weight: .medium)).foregroundColor(.plagitAmber)
            }
            Text("No companies found").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
            Text("Try a wider radius or different category.")
                .font(PlagitFont.caption()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.horizontal, PlagitSpacing.xxl)
    }
}
