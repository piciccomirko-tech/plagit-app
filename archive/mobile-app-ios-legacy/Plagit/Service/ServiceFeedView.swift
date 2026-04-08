//
//  ServiceFeedView.swift
//  Plagit
//
//  Social feed + discovery for hospitality service businesses.
//  Tabs: Feed (posts), Nearby (map), Browse (categories).
//

import SwiftUI
import MapKit
import CoreLocation

struct ServiceFeedView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var location = LocationManager.shared

    // Tabs
    @State private var selectedTab = 0   // 0=Feed, 1=Nearby, 2=Browse

    // Feed state
    @State private var posts: [ServiceFeedPost] = []
    @State private var selectedCategoryId: String?
    @State private var searchText = ""
    @State private var verifiedOnly = false
    @State private var showFilters = false

    // Company profile nav
    @State private var showCompanyProfile = false
    @State private var selectedCompany: ServiceCompany?

    // Nearby state
    @State private var selectedRadius: Double = 10
    @State private var viewMode: NearbyMode = .list
    @State private var selectedMapCompany: ServiceCompany?
    @State private var mapPosition: MapCameraPosition = .automatic
    private let radii: [Double] = [3, 5, 10, 15, 20]

    enum NearbyMode { case list, map }

    private var effectiveLat: Double? { location.hasLocation ? location.latitude : nil }
    private var effectiveLng: Double? { location.hasLocation ? location.longitude : nil }

    // Filtered feed posts
    private var filteredPosts: [ServiceFeedPost] {
        var result = posts
        if let catId = selectedCategoryId {
            result = result.filter { $0.company.categoryId == catId }
        }
        if verifiedOnly { result = result.filter { $0.company.isVerified } }
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            result = result.filter {
                $0.company.name.lowercased().contains(q)
                || $0.body.lowercased().contains(q)
                || $0.company.subcategoryName.lowercased().contains(q)
                || $0.company.categoryName.lowercased().contains(q)
                || $0.company.location.lowercased().contains(q)
            }
        }
        return result
    }

    // Filtered companies for nearby/browse
    private var filteredCompanies: [ServiceCompany] {
        var results = ServiceCatalog.searchCompanies(
            query: searchText, categoryId: selectedCategoryId, verifiedOnly: verifiedOnly
        )
        if selectedTab == 1, let lat = effectiveLat, let lng = effectiveLng {
            let userLoc = CLLocation(latitude: lat, longitude: lng)
            results = results.filter { co in
                guard let cLat = co.latitude, let cLng = co.longitude else { return true }
                return userLoc.distance(from: CLLocation(latitude: cLat, longitude: cLng)) / 1000 <= selectedRadius
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
                tabBar.padding(.top, PlagitSpacing.xs)
                categoryChips.padding(.top, PlagitSpacing.xs)

                if selectedTab == 1 {
                    radiusRow.padding(.top, PlagitSpacing.xs)
                }

                // Content
                switch selectedTab {
                case 0: feedContent
                case 1: nearbyContent
                default: browseContent
                }
            }

            // Floating map pin card
            if let co = selectedMapCompany, selectedTab == 1, viewMode == .map {
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
        .onAppear {
            location.requestLocation()
        }
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
            Text("Services")
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
            Image(systemName: "magnifyingglass").font(.system(size: 14, weight: .medium)).foregroundColor(.plagitTertiary)
            TextField("Search services, companies, locations...", text: $searchText)
                .font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill").font(.system(size: 14)).foregroundColor(.plagitTertiary)
                }
            }
        }
        .padding(.horizontal, PlagitSpacing.md)
        .padding(.vertical, PlagitSpacing.sm + 2)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabButton("Feed", icon: "rectangle.stack", index: 0)
            tabButton("Nearby", icon: "map", index: 1)
            tabButton("Browse", icon: "square.grid.2x2", index: 2)
        }
        .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func tabButton(_ label: String, icon: String, index: Int) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { selectedTab = index }
        } label: {
            HStack(spacing: PlagitSpacing.xs) {
                Image(systemName: icon).font(.system(size: 12, weight: .medium))
                Text(label).font(PlagitFont.captionMedium())
            }
            .foregroundColor(selectedTab == index ? .white : .plagitSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, PlagitSpacing.sm + 2)
            .background(
                RoundedRectangle(cornerRadius: PlagitRadius.sm + 2)
                    .fill(selectedTab == index ? Color.plagitAmber : Color.clear)
            )
        }
    }

    // MARK: - Category Chips

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PlagitSpacing.sm) {
                chip("All", isActive: selectedCategoryId == nil) {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedCategoryId = nil }
                }
                ForEach(ServiceCatalog.all) { cat in
                    chip(cat.name, icon: cat.icon, isActive: selectedCategoryId == cat.id) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategoryId = selectedCategoryId == cat.id ? nil : cat.id
                        }
                    }
                }
            }
            .padding(.horizontal, PlagitSpacing.xl)
        }
    }

    private func chip(_ label: String, icon: String? = nil, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: PlagitSpacing.xs) {
                if let icon { Image(systemName: icon).font(.system(size: 11, weight: .medium)) }
                Text(label).font(PlagitFont.captionMedium())
            }
            .foregroundColor(isActive ? .white : .plagitSecondary)
            .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm)
            .background(Capsule().fill(isActive ? Color.plagitAmber : Color.plagitSurface))
            .overlay(Capsule().stroke(isActive ? Color.clear : Color.plagitBorder, lineWidth: 0.5))
        }
    }

    // MARK: - Radius Row (Nearby tab only)

    private var radiusRow: some View {
        HStack(spacing: PlagitSpacing.md) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: PlagitSpacing.sm) {
                    ForEach(radii, id: \.self) { r in
                        let active = selectedRadius == r
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { selectedRadius = r }
                        } label: {
                            Text("\(Int(r)) km").font(PlagitFont.captionMedium())
                                .foregroundColor(active ? .white : .plagitSecondary)
                                .padding(.horizontal, PlagitSpacing.md + 2).padding(.vertical, PlagitSpacing.sm)
                                .background(Capsule().fill(active ? Color.plagitTeal : Color.plagitSurface))
                                .overlay(Capsule().stroke(active ? Color.clear : Color.plagitBorder, lineWidth: 0.5))
                        }
                    }
                }
            }
            HStack(spacing: 0) {
                modeButton("list.bullet", .list)
                modeButton("map", .map)
            }
            .background(RoundedRectangle(cornerRadius: PlagitRadius.sm + 2).fill(Color.plagitSurface))
        }
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func modeButton(_ icon: String, _ mode: NearbyMode) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { selectedMapCompany = nil; viewMode = mode }
        } label: {
            Image(systemName: icon).font(.system(size: 13, weight: .medium))
                .foregroundColor(viewMode == mode ? .white : .plagitTertiary)
                .frame(width: 34, height: 30)
                .background(RoundedRectangle(cornerRadius: PlagitRadius.sm).fill(viewMode == mode ? Color.plagitAmber : Color.clear))
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Tab 0: Feed
    // ═══════════════════════════════════════════════════════════════

    private var feedContent: some View {
        Group {
            if filteredPosts.isEmpty {
                emptyState("No posts found", "Try a different search or category.")
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: PlagitSpacing.lg) {
                        ForEach(filteredPosts) { post in
                            feedPostCard(post)
                        }
                    }
                    .padding(.horizontal, PlagitSpacing.xl)
                    .padding(.top, PlagitSpacing.lg)
                    .padding(.bottom, PlagitSpacing.xxxl)
                }
            }
        }
    }

    private func feedPostCard(_ post: ServiceFeedPost) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Button {
                selectedCompany = post.company; showCompanyProfile = true
            } label: {
                HStack(spacing: PlagitSpacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: PlagitRadius.sm)
                            .fill(Color(hue: post.company.avatarHue, saturation: 0.15, brightness: 0.95))
                            .frame(width: 40, height: 40)
                        Text(post.company.initials)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hue: post.company.avatarHue, saturation: 0.6, brightness: 0.5))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: PlagitSpacing.sm) {
                            Text(post.company.name).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal).lineLimit(1)
                            if post.company.isVerified {
                                Image(systemName: "checkmark.seal.fill").font(.system(size: 11)).foregroundColor(.plagitVerified)
                            }
                        }
                        Text(post.company.subcategoryName).font(PlagitFont.micro()).foregroundColor(.plagitTeal)
                    }
                    Spacer()
                    Text(post.timeAgo).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                }
                .padding(.horizontal, PlagitSpacing.lg).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.md)
            }
            .buttonStyle(.plain)

            // Body text
            if !post.body.isEmpty {
                Text(post.body)
                    .font(PlagitFont.body())
                    .foregroundColor(.plagitCharcoal)
                    .lineSpacing(2)
                    .padding(.horizontal, PlagitSpacing.lg)
                    .padding(.bottom, PlagitSpacing.md)
            }

            // Image
            if let imageUrl = post.imageUrl {
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                            .frame(maxWidth: .infinity).frame(height: 200)
                            .clipped()
                    default:
                        Rectangle()
                            .fill(Color(hue: post.company.avatarHue, saturation: 0.08, brightness: 0.95))
                            .frame(height: 200)
                            .overlay(
                                Image(systemName: ServiceCatalog.category(id: post.company.categoryId)?.icon ?? "photo")
                                    .font(.system(size: 32, weight: .light))
                                    .foregroundColor(Color(hue: post.company.avatarHue, saturation: 0.3, brightness: 0.7))
                            )
                    }
                }
            }

            // Action bar
            HStack(spacing: PlagitSpacing.xxl) {
                actionButton("heart", "\(post.likeCount)")
                actionButton("bubble.right", "\(post.commentCount)")
                actionButton("bookmark", "")
                Spacer()
                Button {
                    selectedCompany = post.company; showCompanyProfile = true
                } label: {
                    Text("View Profile")
                        .font(PlagitFont.micro())
                        .foregroundColor(.plagitAmber)
                        .padding(.horizontal, PlagitSpacing.md).padding(.vertical, PlagitSpacing.xs)
                        .background(Capsule().fill(Color.plagitAmber.opacity(0.1)))
                }
            }
            .padding(.horizontal, PlagitSpacing.lg)
            .padding(.vertical, PlagitSpacing.md)

            // Location
            HStack(spacing: PlagitSpacing.xs) {
                Image(systemName: "mappin").font(.system(size: 9, weight: .medium)).foregroundColor(.plagitTeal)
                Text(post.company.location).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                Spacer()
                Text(post.company.categoryName).font(PlagitFont.micro()).foregroundColor(.plagitAmber)
            }
            .padding(.horizontal, PlagitSpacing.lg)
            .padding(.bottom, PlagitSpacing.lg)
        }
        .background(
            RoundedRectangle(cornerRadius: PlagitRadius.xl)
                .fill(Color.plagitCardBackground)
                .shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY)
        )
    }

    private func actionButton(_ icon: String, _ count: String) -> some View {
        Button {} label: {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 14, weight: .medium))
                if !count.isEmpty && count != "0" {
                    Text(count).font(PlagitFont.micro())
                }
            }
            .foregroundColor(.plagitSecondary)
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Tab 1: Nearby (Map/List)
    // ═══════════════════════════════════════════════════════════════

    private var nearbyContent: some View {
        Group {
            if filteredCompanies.isEmpty {
                emptyState("No companies nearby", "Try a wider radius or different category.")
            } else {
                switch viewMode {
                case .list:
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: PlagitSpacing.md) {
                            ForEach(filteredCompanies) { co in companyRow(co) }
                        }
                        .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.xxxl)
                    }
                case .map:
                    mapView
                }
            }
        }
    }

    private var mapView: some View {
        let userCoord = CLLocationCoordinate2D(latitude: effectiveLat ?? 0, longitude: effectiveLng ?? 0)
        return ZStack(alignment: .topTrailing) {
            Map(position: $mapPosition) {
                Annotation("You", coordinate: userCoord) {
                    ZStack {
                        Circle().fill(Color.plagitAmber.opacity(0.15)).frame(width: 32, height: 32)
                        Circle().fill(Color.plagitAmber).frame(width: 12, height: 12).overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }
                }
                ForEach(filteredCompanies.filter { $0.latitude != nil && $0.longitude != nil }) { co in
                    Annotation(co.name, coordinate: CLLocationCoordinate2D(latitude: co.latitude!, longitude: co.longitude!)) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { selectedMapCompany = selectedMapCompany?.id == co.id ? nil : co }
                        } label: {
                            ZStack {
                                Circle().fill(selectedMapCompany?.id == co.id ? Color.plagitAmber : Color.plagitCardBackground)
                                    .frame(width: 36, height: 36).shadow(color: .black.opacity(0.12), radius: 4, y: 2)
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

            Button { recenterMap() } label: {
                Image(systemName: "location.fill").font(.system(size: 14, weight: .medium)).foregroundColor(.plagitAmber)
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

    // ═══════════════════════════════════════════════════════════════
    // MARK: - Tab 2: Browse (Grid)
    // ═══════════════════════════════════════════════════════════════

    private var browseContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: PlagitSpacing.md) {
                ForEach(filteredCompanies) { co in companyRow(co) }
            }
            .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.xxxl)
        }
    }

    // MARK: - Shared Company Row

    private func companyRow(_ co: ServiceCompany) -> some View {
        Button {
            selectedCompany = co; showCompanyProfile = true
        } label: {
            HStack(spacing: PlagitSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: PlagitRadius.md)
                        .fill(Color(hue: co.avatarHue, saturation: 0.15, brightness: 0.95))
                        .frame(width: 48, height: 48)
                    Text(co.initials).font(.system(size: 16, weight: .bold, design: .rounded))
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
            .padding(PlagitSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground)
                    .shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Pin Card (floating on map)

    private func pinCard(_ co: ServiceCompany) -> some View {
        Button { selectedCompany = co; showCompanyProfile = true } label: {
            HStack(spacing: PlagitSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: PlagitRadius.sm)
                        .fill(Color(hue: co.avatarHue, saturation: 0.15, brightness: 0.95))
                        .frame(width: 44, height: 44)
                    Text(co.initials).font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hue: co.avatarHue, saturation: 0.6, brightness: 0.5))
                }
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: PlagitSpacing.sm) {
                        Text(co.name).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal).lineLimit(1)
                        if co.isVerified {
                            Image(systemName: "checkmark.seal.fill").font(.system(size: 11)).foregroundColor(.plagitVerified)
                        }
                    }
                    Text(co.subcategoryName).font(PlagitFont.caption()).foregroundColor(.plagitTeal)
                    HStack(spacing: PlagitSpacing.xs) {
                        Image(systemName: "mappin").font(.system(size: 9, weight: .medium)).foregroundColor(.plagitAmber)
                        Text(co.location).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 12, weight: .medium)).foregroundColor(.plagitTertiary)
            }
            .padding(PlagitSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground)
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
                        Text("Reset Filters").font(PlagitFont.captionMedium()).foregroundColor(.plagitUrgent)
                            .frame(maxWidth: .infinity).padding(.vertical, PlagitSpacing.md)
                            .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitUrgent.opacity(0.06)))
                    }
                }.padding(PlagitSpacing.xxl)
            }
            .navigationTitle("Filters").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showFilters = false }.font(PlagitFont.captionMedium()).foregroundColor(.plagitAmber)
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Empty State

    private func emptyState(_ title: String, _ subtitle: String) -> some View {
        VStack(spacing: PlagitSpacing.lg) {
            Spacer()
            ZStack {
                Circle().fill(Color.plagitAmber.opacity(0.1)).frame(width: 56, height: 56)
                Image(systemName: "building.2").font(.system(size: 24, weight: .medium)).foregroundColor(.plagitAmber)
            }
            Text(title).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
            Text(subtitle).font(PlagitFont.caption()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center)
            Spacer()
        }.padding(.horizontal, PlagitSpacing.xxl)
    }
}

// MARK: - Service Feed Post Model

struct ServiceFeedPost: Identifiable {
    let id: String
    let company: ServiceCompany
    let body: String
    let imageUrl: String?
    let likeCount: Int
    let commentCount: Int
    let postedMinutesAgo: Int

    var timeAgo: String {
        if postedMinutesAgo < 60 { return "\(postedMinutesAgo)m" }
        let h = postedMinutesAgo / 60
        if h < 24 { return "\(h)h" }
        return "\(h / 24)d"
    }

}
