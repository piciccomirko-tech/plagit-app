//
//  BusinessNearbyTalentView.swift
//  Plagit
//
//  Business nearby candidates with list/map toggle, smart empty states.
//  Backed by GET /business/candidates/nearby.
//

import SwiftUI
import MapKit
import CoreLocation

struct BusinessNearbyTalentView: View {
    var profileLat: Double?
    var profileLng: Double?

    @Environment(\.dismiss) private var dismiss
    @State private var location = LocationManager.shared

    private var effectiveLat: Double? { location.hasLocation ? location.latitude : profileLat }
    private var effectiveLng: Double? { location.hasLocation ? location.longitude : profileLng }
    private var hasCoordinates: Bool { effectiveLat != nil && effectiveLng != nil }

    @State private var candidates: [NearbyCandidateDTO] = []
    @State private var hasLoadedOnce = false
    @State private var loadError: String?
    @State private var selectedRadius: Double = 10
    @State private var selectedRole = "All"
    @State private var viewMode: ViewMode = .list
    @State private var showCandidateProfile = false
    @State private var selectedCandidateId: String?
    @State private var selectedMapCandidate: NearbyCandidateDTO?
    @State private var mapPosition: MapCameraPosition = .automatic
    @State private var cache: [String: [NearbyCandidateDTO]] = [:]
    @State private var loadTask: Task<Void, Never>?
    @State private var shortlisted: Set<String> = {
        Set(UserDefaults.standard.stringArray(forKey: "biz_shortlist") ?? [])
    }()
    @State private var toastMessage: String?
    @State private var showMessages = false
    @State private var showChat = false
    @State private var chatConversationId: String?

    private let radii: [Double] = [3, 5, 10, 15, 20]
    private let roles = ["All", "Chef", "Waiter", "Bartender", "Manager", "Reception", "Kitchen Porter", "Relocate"]
    private var cacheKey: String { "\(Int(selectedRadius))-\(selectedRole)" }
    private var displayCandidates: [NearbyCandidateDTO] {
        if selectedRole == "Relocate" { return candidates.filter { $0.availableToRelocate == true } }
        return candidates
    }
    enum ViewMode { case list, map }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.plagitBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                radiusAndToggle.padding(.top, PlagitSpacing.xs)
                roleChips.padding(.top, PlagitSpacing.xs)
                summaryRow.padding(.top, PlagitSpacing.sm)

                if !hasCoordinates && location.authorizationStatus == .notDetermined {
                    Spacer(); locationPrompt; Spacer()
                } else if !hasCoordinates {
                    Spacer(); locationDenied; Spacer()
                } else if !hasLoadedOnce {
                    Spacer(); ProgressView().tint(.plagitTeal); Spacer()
                } else if let error = loadError, candidates.isEmpty {
                    Spacer()
                    VStack(spacing: PlagitSpacing.md) {
                        Image(systemName: "wifi.exclamationmark").font(.system(size: 32)).foregroundColor(.plagitTertiary)
                        Text(error).font(PlagitFont.caption()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center)
                        Button { Task { await loadFresh() } } label: { Text("Retry").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal) }
                    }.padding(PlagitSpacing.xxl)
                    Spacer()
                } else {
                    ZStack(alignment: .top) {
                        switch viewMode {
                        case .list:
                            if candidates.isEmpty { ScrollView { emptyState.padding(.top, PlagitSpacing.xl) } }
                            else { listContent }
                        case .map:
                            mapContent
                        }
                    }
                }
            }

            // Floating pin card
            if let c = selectedMapCandidate, viewMode == .map {
                VStack { Spacer()
                    pinCard(c).padding(.horizontal, PlagitSpacing.xl).padding(.bottom, PlagitSpacing.xl)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }.animation(.easeInOut(duration: 0.25), value: selectedMapCandidate?.id)
            }

            // Toast
            if let msg = toastMessage {
                HStack(spacing: PlagitSpacing.sm) {
                    Image(systemName: "checkmark.circle.fill").font(.system(size: 16)).foregroundColor(.plagitOnline)
                    Text(msg).font(PlagitFont.captionMedium()).foregroundColor(.white)
                }
                .padding(.horizontal, PlagitSpacing.xl).padding(.vertical, PlagitSpacing.md)
                .background(Capsule().fill(Color.plagitCharcoal.opacity(0.9)))
                .padding(.bottom, PlagitSpacing.xxl)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showCandidateProfile) {
            BusinessRealCandidateProfileView(candidateId: selectedCandidateId ?? "").navigationBarHidden(true)
        }
        .navigationDestination(isPresented: $showMessages) {
            BusinessRealMessagesView().navigationBarHidden(true)
        }
        .navigationDestination(isPresented: $showChat) {
            if let convId = chatConversationId {
                BusinessRealChatView(conversationId: convId).navigationBarHidden(true)
            }
        }
        .onAppear { location.requestLocation() }
        .onChange(of: location.latitude) { _, _ in if hasLoadedOnce { debouncedLoad() } }
        .onChange(of: selectedRadius) { _, _ in if hasLoadedOnce { debouncedLoad() } }
        .onChange(of: selectedRole) { _, _ in if hasLoadedOnce { debouncedLoad() } }
        .task {
            if !hasCoordinates { try? await Task.sleep(nanoseconds: 500_000_000) }
            if hasCoordinates { await loadFresh() }
        }
    }

    // MARK: - Data

    private func debouncedLoad() {
        loadTask?.cancel()
        loadTask = Task {
            try? await Task.sleep(nanoseconds: 150_000_000)
            guard !Task.isCancelled else { return }
            await loadWithCache()
        }
    }

    private func loadFresh() async {
        guard let lat = effectiveLat, let lng = effectiveLng else { return }
        loadError = nil
        let r = (selectedRole == "All" || selectedRole == "Relocate") ? nil : selectedRole
        do {
            let result = try await BusinessAPIService.shared.fetchNearbyCandidates(lat: lat, lng: lng, radius: selectedRadius, role: r)
            candidates = result; cache[cacheKey] = result
        } catch { loadError = error.localizedDescription }
        hasLoadedOnce = true
        prewarmCache(lat: lat, lng: lng)
    }

    private func loadWithCache() async {
        guard let lat = effectiveLat, let lng = effectiveLng else { return }
        if let cached = cache[cacheKey] {
            withAnimation(.easeInOut(duration: 0.15)) { candidates = cached }
            hasLoadedOnce = true
            Task {
                let r = (selectedRole == "All" || selectedRole == "Relocate") ? nil : selectedRole
                if let fresh = try? await BusinessAPIService.shared.fetchNearbyCandidates(lat: lat, lng: lng, radius: selectedRadius, role: r) {
                    cache[cacheKey] = fresh
                    if cacheKey == "\(Int(selectedRadius))-\(selectedRole)" {
                        withAnimation(.easeInOut(duration: 0.15)) { candidates = fresh }
                    }
                }
            }
            return
        }
        loadError = nil
        let r = (selectedRole == "All" || selectedRole == "Relocate") ? nil : selectedRole
        do {
            let result = try await BusinessAPIService.shared.fetchNearbyCandidates(lat: lat, lng: lng, radius: selectedRadius, role: r)
            cache[cacheKey] = result
            withAnimation(.easeInOut(duration: 0.15)) { candidates = result }
        } catch { loadError = error.localizedDescription }
        hasLoadedOnce = true
    }

    private func prewarmCache(lat: Double, lng: Double) {
        let currentRole = selectedRole; let currentR = selectedRadius
        Task {
            let r = currentRole == "All" ? nil : currentRole
            for radius in [10.0, 15.0, 20.0] where radius > currentR {
                let key = "\(Int(radius))-\(currentRole)"
                guard cache[key] == nil else { continue }
                if let data = try? await BusinessAPIService.shared.fetchNearbyCandidates(lat: lat, lng: lng, radius: radius, role: r) {
                    cache[key] = data
                }
            }
            if currentRole != "All" {
                let allKey = "\(Int(currentR))-All"
                if cache[allKey] == nil {
                    if let data = try? await BusinessAPIService.shared.fetchNearbyCandidates(lat: lat, lng: lng, radius: currentR, role: nil) {
                        cache[allKey] = data
                    }
                }
            }
        }
    }

    @MainActor
    private func openChat(candidateId: String, name: String) async {
        do {
            let convId = try await BusinessAPIService.shared.startConversation(candidateId: candidateId)
            chatConversationId = convId
            DispatchQueue.main.async { showChat = true }
        } catch {
            // Fallback: open messages list
            showToast("Message \(name)")
            showMessages = true
        }
    }

    private func showToast(_ msg: String) {
        withAnimation(.easeInOut(duration: 0.2)) { toastMessage = msg }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { withAnimation { toastMessage = nil } }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: { Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36) }
            Spacer(); Text("Nearby Talent").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal); Spacer()
            Color.clear.frame(width: 36, height: 36)
        }.padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.lg)
    }

    // MARK: - Radius + Toggle

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
            HStack(spacing: 0) { toggleBtn("list.bullet", .list); toggleBtn("map", .map) }
                .background(RoundedRectangle(cornerRadius: PlagitRadius.sm + 2).fill(Color.plagitSurface))
        }.padding(.horizontal, PlagitSpacing.xl)
    }

    private func toggleBtn(_ icon: String, _ mode: ViewMode) -> some View {
        Button { withAnimation(.easeInOut(duration: 0.2)) { selectedMapCandidate = nil; viewMode = mode } } label: {
            Image(systemName: icon).font(.system(size: 13, weight: .medium))
                .foregroundColor(viewMode == mode ? .white : .plagitTertiary)
                .frame(width: 34, height: 30)
                .background(RoundedRectangle(cornerRadius: PlagitRadius.sm).fill(viewMode == mode ? Color.plagitTeal : Color.clear))
        }
    }

    // MARK: - Role Chips

    private var roleChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PlagitSpacing.sm) {
                ForEach(roles, id: \.self) { r in
                    let active = selectedRole == r
                    Button { withAnimation(.easeInOut(duration: 0.2)) { selectedRole = r } } label: {
                        Text(r).font(PlagitFont.captionMedium())
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
                Circle().fill(candidates.isEmpty ? Color.plagitTertiary : Color.plagitOnline).frame(width: 6, height: 6)
                Text(candidates.isEmpty ? "No results" : "\(candidates.count) candidate\(candidates.count == 1 ? "" : "s") found")
                    .font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal)
            }
            Text("·").foregroundColor(.plagitTertiary)
            Text("\(Int(selectedRadius)) km").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
            if selectedRole != "All" {
                Text("·").foregroundColor(.plagitTertiary)
                Text(selectedRole).font(PlagitFont.micro()).foregroundColor(.plagitTeal)
            }
            Spacer()
        }.padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - List

    private var listContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: PlagitSpacing.md) { ForEach(displayCandidates) { c in candidateCard(c) } }
                .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.xxxl)
        }
    }

    private func candidateCard(_ c: NearbyCandidateDTO) -> some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.md) {
            // Header
            Button { selectedCandidateId = c.id; DispatchQueue.main.async { showCandidateProfile = true } } label: {
                HStack(spacing: PlagitSpacing.md) {
                    ProfileAvatarView(photoUrl: c.photoUrl, initials: c.initials ?? "—", hue: c.avatarHue, size: 48, verified: c.isVerified)
                    VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                        HStack(spacing: 4) {
                            Text(c.name).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                            let nflag = CountryFlag.emoji(for: c.nationalityCode)
                            if !nflag.isEmpty { Text(nflag).font(.system(size: 12)) }
                        }
                        if let role = c.role {
                            Text(role).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                        }
                        HStack(spacing: PlagitSpacing.sm) {
                            if let exp = c.experience { Text(exp).font(PlagitFont.micro()).foregroundColor(.plagitTertiary) }
                            if let loc = c.location {
                                HStack(spacing: 3) {
                                    Image(systemName: "mappin").font(.system(size: 8, weight: .medium)).foregroundColor(.plagitTertiary)
                                    Text(loc).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                                }
                            }
                        }
                    }
                    Spacer()
                    VStack(spacing: 2) {
                        Text(String(format: "%.1f", c.distanceKm ?? 0)).font(.system(size: 18, weight: .bold, design: .rounded)).foregroundColor(.plagitTeal)
                        Text("km").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                    }
                }
            }.buttonStyle(.plain)

            // Actions
            HStack(spacing: PlagitSpacing.sm) {
                actionButton("View", icon: "person.crop.circle", color: .plagitTeal) {
                    selectedCandidateId = c.id; DispatchQueue.main.async { showCandidateProfile = true }
                }
                actionButton(shortlisted.contains(c.id) ? "Shortlisted" : "Shortlist",
                    icon: shortlisted.contains(c.id) ? "star.fill" : "star",
                    color: shortlisted.contains(c.id) ? .plagitAmber : .plagitSecondary
                ) {
                    if shortlisted.contains(c.id) {
                        shortlisted.remove(c.id); showToast("Removed from shortlist")
                    } else {
                        shortlisted.insert(c.id); showToast("Added to shortlist")
                    }
                    UserDefaults.standard.set(Array(shortlisted), forKey: "biz_shortlist")
                }
                actionButton("Message", icon: "bubble.left", color: .plagitIndigo) {
                    Task { await openChat(candidateId: c.id, name: c.name) }
                }
            }
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground)
            .shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
    }

    private func actionButton(_ label: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 11, weight: .medium))
                Text(label).font(PlagitFont.micro()).lineLimit(1)
            }
            .foregroundColor(color)
            .padding(.horizontal, PlagitSpacing.md).padding(.vertical, PlagitSpacing.sm)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(color.opacity(0.06)))
        }
    }

    // MARK: - Map

    private func recenterMap() {
        guard let lat = effectiveLat, let lng = effectiveLng else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            mapPosition = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: lat, longitude: lng),
                latitudinalMeters: selectedRadius * 1000 * 2.2, longitudinalMeters: selectedRadius * 1000 * 2.2))
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
                ForEach(candidates.filter { $0.latitude != nil && $0.longitude != nil }) { c in
                    Annotation(c.name, coordinate: CLLocationCoordinate2D(latitude: c.latitude!, longitude: c.longitude!)) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { selectedMapCandidate = selectedMapCandidate?.id == c.id ? nil : c }
                        } label: {
                            ZStack {
                                Circle().fill(selectedMapCandidate?.id == c.id ? Color.plagitTeal : Color.plagitCardBackground)
                                    .frame(width: 36, height: 36).shadow(color: .black.opacity(0.12), radius: 4, y: 2)
                                Image(systemName: "person.fill").font(.system(size: 14, weight: .medium))
                                    .foregroundColor(selectedMapCandidate?.id == c.id ? .white : .plagitTeal)
                            }
                        }
                    }
                }
            }
            .mapStyle(.standard(pointsOfInterest: .excludingAll))
            .mapControls { MapCompass() }
            .onTapGesture { withAnimation { selectedMapCandidate = nil } }

            Button { recenterMap() } label: {
                Image(systemName: "location.fill").font(.system(size: 14, weight: .medium)).foregroundColor(.plagitTeal)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.plagitCardBackground).shadow(color: .black.opacity(0.10), radius: 4, y: 2))
            }.padding(PlagitSpacing.md)

            // Slim floating empty pill
            if candidates.isEmpty {
                VStack {
                    Spacer()
                    HStack(spacing: PlagitSpacing.sm) {
                        Image(systemName: "person.slash").font(.system(size: 13, weight: .medium)).foregroundColor(.plagitTeal)
                        Text(emptyTitle).font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal).lineLimit(1)
                        if let (r, c) = widerRadiusSuggestion {
                            Text("· \(c) at \(Int(r)) km").font(PlagitFont.micro()).foregroundColor(.plagitOnline).lineLimit(1)
                        }
                        Spacer()
                        if selectedRadius < 20 {
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) { selectedRadius = min(selectedRadius + 5, 20) }
                            } label: {
                                Text("Expand").font(PlagitFont.captionMedium()).foregroundColor(.white)
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
        .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.sm)
        .onAppear { recenterMap() }
        .onChange(of: selectedRadius) { _, _ in recenterMap() }
    }

    // MARK: - Pin Card

    private func pinCard(_ c: NearbyCandidateDTO) -> some View {
        Button { selectedCandidateId = c.id; DispatchQueue.main.async { showCandidateProfile = true } } label: {
            HStack(spacing: PlagitSpacing.md) {
                ProfileAvatarView(photoUrl: c.photoUrl, initials: c.initials ?? "—", hue: c.avatarHue, size: 40, verified: c.isVerified)
                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    HStack(spacing: 4) {
                        Text(c.name).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                        let pflag = CountryFlag.emoji(for: c.nationalityCode)
                        if !pflag.isEmpty { Text(pflag).font(.system(size: 12)) }
                    }
                    HStack(spacing: PlagitSpacing.sm) {
                        if let role = c.role { Text(role).font(PlagitFont.caption()).foregroundColor(.plagitSecondary) }
                        if let exp = c.experience { Text("·").foregroundColor(.plagitTertiary); Text(exp).font(PlagitFont.micro()).foregroundColor(.plagitTertiary) }
                    }
                }
                Spacer()
                VStack(spacing: 2) {
                    Text(String(format: "%.1f", c.distanceKm ?? 0)).font(.system(size: 15, weight: .bold, design: .rounded)).foregroundColor(.plagitTeal)
                    Text("km").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                }
                Image(systemName: "chevron.right").font(.system(size: 11, weight: .medium)).foregroundColor(.plagitTertiary)
            }
            .padding(PlagitSpacing.lg)
            .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground)
                .shadow(color: PlagitShadow.elevatedShadowColor, radius: PlagitShadow.elevatedShadowRadius, y: PlagitShadow.elevatedShadowY))
        }.buttonStyle(.plain)
    }

    // MARK: - Smart Empty State

    private var widerRadiusSuggestion: (Double, Int)? {
        for r in radii where r > selectedRadius {
            let key = "\(Int(r))-\(selectedRole)"
            if let cached = cache[key], !cached.isEmpty { return (r, cached.count) }
        }
        return nil
    }
    private var allRolesSuggestion: Int? {
        guard selectedRole != "All" else { return nil }
        let key = "\(Int(selectedRadius))-All"
        if let cached = cache[key], !cached.isEmpty { return cached.count }
        return nil
    }
    private var emptyTitle: String {
        selectedRole != "All" ? "No \(selectedRole.lowercased())s nearby" : "No candidates found"
    }

    private var emptyState: some View {
        VStack(spacing: PlagitSpacing.md) {
            VStack(spacing: 4) {
                Text(emptyTitle).font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
                Text("within \(Int(selectedRadius)) km").font(PlagitFont.caption()).foregroundColor(.plagitTertiary)
                if widerRadiusSuggestion == nil && allRolesSuggestion == nil {
                    Text(selectedRole != "All" ? "Try all roles for more results" : "Closest candidates may be farther away")
                        .font(PlagitFont.micro()).foregroundColor(.plagitSecondary).padding(.top, 2)
                }
            }.multilineTextAlignment(.center).padding(.top, PlagitSpacing.lg)

            if widerRadiusSuggestion != nil || allRolesSuggestion != nil {
                VStack(spacing: PlagitSpacing.xs) {
                    if let (radius, count) = widerRadiusSuggestion {
                        smartHint(icon: "sparkles", color: .plagitOnline, text: "\(count) candidate\(count == 1 ? "" : "s") at \(Int(radius)) km", action: "Show") {
                            withAnimation(.easeInOut(duration: 0.2)) { selectedRadius = radius }
                        }
                    }
                    if let count = allRolesSuggestion {
                        smartHint(icon: "rectangle.stack", color: .plagitIndigo, text: "\(count) across all roles", action: "View") {
                            withAnimation(.easeInOut(duration: 0.2)) { selectedRole = "All" }
                        }
                    }
                }
            }

            HStack(spacing: PlagitSpacing.sm) {
                if selectedRadius < 20 {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { selectedRadius = min(selectedRadius + 5, 20) }
                    } label: {
                        Text("Expand to \(Int(min(selectedRadius + 5, 20))) km").font(PlagitFont.captionMedium()).foregroundColor(.white)
                            .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm + 2)
                            .background(Capsule().fill(Color.plagitTeal))
                    }
                }
                if selectedRole != "All" {
                    Button { withAnimation(.easeInOut(duration: 0.2)) { selectedRole = "All" } } label: {
                        Text("All roles").font(PlagitFont.captionMedium()).foregroundColor(.plagitTertiary)
                            .padding(.horizontal, PlagitSpacing.md).padding(.vertical, PlagitSpacing.sm)
                            .background(Capsule().fill(Color.plagitSurface))
                    }
                }
                Button { withAnimation(.easeInOut(duration: 0.2)) { viewMode = viewMode == .list ? .map : .list } } label: {
                    Text(viewMode == .list ? "Map" : "List").font(PlagitFont.captionMedium()).foregroundColor(.plagitTertiary)
                        .padding(.horizontal, PlagitSpacing.md).padding(.vertical, PlagitSpacing.sm)
                        .background(Capsule().fill(Color.plagitSurface))
                }
            }.padding(.bottom, PlagitSpacing.md)
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

    // MARK: - Location States

    private var locationPrompt: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack { Circle().fill(Color.plagitTealLight).frame(width: 56, height: 56); Image(systemName: "location.fill").font(.system(size: 24, weight: .medium)).foregroundColor(.plagitTeal) }
            Text("Enable Location").font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
            Text("Allow Plagit to use your location to find\nnearby candidates.").font(PlagitFont.caption()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center)
            Button { location.requestPermission() } label: {
                Text("Allow Location").font(PlagitFont.captionMedium()).foregroundColor(.white)
                    .padding(.horizontal, PlagitSpacing.xxl).padding(.vertical, PlagitSpacing.md)
                    .background(Capsule().fill(Color.plagitTeal))
            }
        }.padding(.horizontal, PlagitSpacing.xxl)
    }

    private var locationDenied: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack { Circle().fill(Color.plagitUrgent.opacity(0.08)).frame(width: 56, height: 56); Image(systemName: "location.slash").font(.system(size: 24, weight: .medium)).foregroundColor(.plagitUrgent) }
            Text("Location Access Needed").font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
            Text("Enable location in Settings to find\nnearby candidates.").font(PlagitFont.caption()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center)
            Button { if let url = URL(string: UIApplication.openSettingsURLString) { UIApplication.shared.open(url) } } label: {
                Text("Open Settings").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                    .padding(.horizontal, PlagitSpacing.xxl).padding(.vertical, PlagitSpacing.md)
                    .background(Capsule().fill(Color.plagitTealLight))
            }
        }.padding(.horizontal, PlagitSpacing.xxl)
    }
}
