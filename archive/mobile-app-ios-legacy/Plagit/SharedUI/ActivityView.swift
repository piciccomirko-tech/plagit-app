//
//  ActivityView.swift
//  Plagit
//
//  Unified activity / notifications screen for both Candidate and Business.
//

import SwiftUI

struct ActivityNotification: Decodable, Identifiable {
    let id: String
    let notificationType: String
    let title: String
    let linkedEntity: String?
    let destinationRoute: String?
    let deliveryState: String
    let isRead: Bool
    let sentAt: String?
    let createdAt: String?
}

struct ActivityView: View {
    let isBusiness: Bool
    @Environment(\.dismiss) private var dismiss
    private var sub: SubscriptionManager { .shared }
    @State private var items: [ActivityNotification] = []
    @State private var isLoading = true
    @State private var selectedFilter = "All"
    // Navigation
    @State private var showInterviews = false
    @State private var showMessages = false
    @State private var showJobs = false
    @State private var showChat = false
    @State private var chatConvId: String?
    @State private var showClearAllConfirm = false
    @State private var showMatches = false
    @State private var showProfile = false

    private var isPremiumCandidate: Bool { !isBusiness && sub.isCandidatePremium }

    // Priority routes — interview invites and match confirmations are high-value
    private static let priorityRoutes: Set<String> = ["interview", "match"]
    // Urgent routes — applications and shortlists are medium priority
    private static let urgentRoutes: Set<String> = ["application", "applicant", "shortlist"]

    private var filtered: [ActivityNotification] {
        var result = items
        if selectedFilter == "Unread" { result = result.filter { !$0.isRead } }
        if selectedFilter == "Priority" { result = result.filter { isPriority($0) } }

        // Premium candidates: pin priority notifications to the top
        if isPremiumCandidate {
            result.sort { a, b in
                let aPri = priorityWeight(a)
                let bPri = priorityWeight(b)
                if aPri != bPri { return aPri > bPri }
                // Within same tier, newest first
                return (a.createdAt ?? "") > (b.createdAt ?? "")
            }
        }
        return result
    }

    private var unreadCount: Int { items.filter { !$0.isRead }.count }
    private var priorityCount: Int { items.filter { isPriority($0) }.count }

    /// Is this notification considered priority for premium sorting?
    private func isPriority(_ n: ActivityNotification) -> Bool {
        guard let route = n.destinationRoute else { return false }
        return Self.priorityRoutes.contains(route) || Self.urgentRoutes.contains(route)
    }

    /// Sorting weight: higher = shown first. Only used for premium candidates.
    private func priorityWeight(_ n: ActivityNotification) -> Int {
        guard let route = n.destinationRoute else { return 0 }
        if !n.isRead && Self.priorityRoutes.contains(route) { return 3 }  // Unread interview/match
        if Self.priorityRoutes.contains(route) { return 2 }               // Read interview/match
        if !n.isRead && Self.urgentRoutes.contains(route) { return 1 }    // Unread application/shortlist
        return 0
    }

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar
                filterRow.padding(.top, PlagitSpacing.xs)

                if isLoading {
                    Spacer(); ProgressView().tint(.plagitTeal); Spacer()
                } else if filtered.isEmpty {
                    Spacer(); emptyState; Spacer()
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(filtered) { item in
                                notifRow(item)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            items.removeAll { $0.id == item.id }
                                            Task { await markRead(item) }
                                        } label: { Label(L10n.t("remove_notif"), systemImage: "trash") }
                                    }
                                Rectangle().fill(Color.plagitDivider).frame(height: 0.5)
                                    .padding(.leading, PlagitSpacing.xl + 40 + PlagitSpacing.md)
                            }
                        }.padding(.bottom, PlagitSpacing.xxxl)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showInterviews) {
            if isBusiness { BusinessRealInterviewsView().navigationBarHidden(true) }
            else { CandidateInterviewsListView().navigationBarHidden(true) }
        }
        .navigationDestination(isPresented: $showMessages) {
            if isBusiness { BusinessRealMessagesView().navigationBarHidden(true) }
            else { CandidateMessagesView().navigationBarHidden(true) }
        }
        .navigationDestination(isPresented: $showJobs) {
            if isBusiness { BusinessRealJobsView().navigationBarHidden(true) }
            else { MyApplicationsView().navigationBarHidden(true) }
        }
        .navigationDestination(isPresented: $showChat) {
            if isBusiness {
                BusinessRealChatView(conversationId: chatConvId ?? "").navigationBarHidden(true)
            } else {
                CandidateChatView(conversationId: chatConvId ?? "").navigationBarHidden(true)
            }
        }
        .navigationDestination(isPresented: $showMatches) {
            if isBusiness { BusinessRealJobsView().navigationBarHidden(true) }
            else { CandidateMatchesView().navigationBarHidden(true) }
        }
        .navigationDestination(isPresented: $showProfile) {
            if isBusiness { BusinessRealProfileView().navigationBarHidden(true) }
            else { CandidateRealProfileView().navigationBarHidden(true) }
        }
        .task { await load() }
        .alert(L10n.t("clear_all_notifs"), isPresented: $showClearAllConfirm) {
            Button(L10n.t("clear_all"), role: .destructive) { items.removeAll() }
            Button(L10n.cancel, role: .cancel) {}
        } message: { Text(L10n.t("clear_all_confirm")) }
    }

    private func load() async {
        isLoading = true
        do {
            if isBusiness {
                let notifs = try await BusinessAPIService.shared.fetchNotifications()
                items = notifs.map { n in
                    ActivityNotification(id: n.id, notificationType: n.notificationType, title: n.title,
                        linkedEntity: n.linkedEntity, destinationRoute: n.destinationRoute,
                        deliveryState: n.deliveryState, isRead: n.isRead, sentAt: n.sentAt, createdAt: n.createdAt)
                }
            } else {
                let w: [ActivityNotification] = try await fetchCandidateNotifs()
                items = w
            }
        } catch {
            // Error state handled by empty items list — UI shows empty state
        }
        isLoading = false
    }

    private func fetchCandidateNotifs() async throws -> [ActivityNotification] {
        struct Wrapper: Decodable { let success: Bool; let data: [ActivityNotification] }
        let w: Wrapper = try await APIClient.shared.request(.GET, path: "/candidate/notifications")
        return w.data
    }


    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36)
            }
            Spacer()
            HStack(spacing: PlagitSpacing.sm) {
                Text(L10n.activity).font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
                if isPremiumCandidate {
                    Image(systemName: "crown.fill").font(.system(size: 10, weight: .bold)).foregroundColor(.plagitAmber)
                }
            }
            Spacer()
            if !items.isEmpty {
                Menu {
                    if unreadCount > 0 {
                        Button { Task { await markAllRead() } } label: { Label(L10n.t("mark_all_read"), systemImage: "checkmark.circle") }
                    }
                    Button(role: .destructive) { showClearAllConfirm = true } label: { Label(L10n.t("clear_all"), systemImage: "trash") }
                } label: {
                    Image(systemName: "ellipsis.circle").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitTeal)
                }
            } else {
                Color.clear.frame(width: 36, height: 36)
            }
        }.padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.lg)
    }

    // MARK: - Filter Row

    private var filterRow: some View {
        let filterOptions: [(key: String, label: String)] = {
            var opts: [(String, String)] = [
                ("All", L10n.all),
                ("Unread", L10n.t("unread_filter")),
            ]
            // Premium candidates get a Priority filter tab
            if isPremiumCandidate {
                opts.append(("Priority", L10n.t("priority_filter")))
            }
            return opts
        }()

        return HStack(spacing: PlagitSpacing.sm) {
            ForEach(filterOptions, id: \.key) { option in
                let active = selectedFilter == option.key
                let badgeCount: Int = {
                    switch option.key {
                    case "Unread": return unreadCount
                    case "Priority": return priorityCount
                    default: return 0
                    }
                }()
                Button { withAnimation(.easeInOut(duration: 0.2)) { selectedFilter = option.key } } label: {
                    HStack(spacing: PlagitSpacing.xs) {
                        if option.key == "Priority" {
                            Image(systemName: "bolt.fill").font(.system(size: 9, weight: .bold))
                        }
                        Text(option.label).font(PlagitFont.captionMedium()).foregroundColor(active ? .white : .plagitSecondary)
                        if badgeCount > 0 {
                            Text("\(badgeCount)").font(PlagitFont.micro()).foregroundColor(active ? .white.opacity(0.8) : .plagitTertiary)
                        }
                    }
                    .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm)
                    .background(Capsule().fill(active ? (option.key == "Priority" ? Color.plagitAmber : Color.plagitTeal) : Color.plagitSurface))
                    .overlay(Capsule().stroke(active ? Color.clear : Color.plagitBorder, lineWidth: 0.5))
                }
            }
            Spacer()
        }.padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Row

    private func notifIcon(_ route: String?) -> (String, Color) {
        switch route {
        case "interview": return ("calendar.badge.clock", .plagitIndigo)
        case "application", "applicant": return ("person.badge.plus", .plagitTeal)
        case "message": return ("bubble.left.fill", .plagitAmber)
        case "shortlist": return ("star.fill", .plagitAmber)
        case "match": return ("checkmark.seal.fill", .plagitOnline)
        default: return ("bell.fill", .plagitTeal)
        }
    }

    private func notifRow(_ n: ActivityNotification) -> some View {
        let (icon, color) = notifIcon(n.destinationRoute)
        let showPriorityLabel = isPremiumCandidate && isPriority(n)
        return Button {
            Task { await markRead(n) }
            navigate(n)
        } label: {
            HStack(spacing: PlagitSpacing.md) {
                ZStack {
                    Circle().fill(n.isRead ? Color.plagitSurface : color.opacity(0.1)).frame(width: 40, height: 40)
                    Image(systemName: icon).font(.system(size: 15, weight: .medium)).foregroundColor(n.isRead ? .plagitTertiary : color)
                }
                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    HStack(spacing: PlagitSpacing.sm) {
                        Text(n.title).font(n.isRead ? PlagitFont.body() : PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal).lineLimit(2)
                        if showPriorityLabel {
                            Text("Priority")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.plagitAmber)
                                .padding(.horizontal, 5).padding(.vertical, 2)
                                .background(Capsule().fill(Color.plagitAmber.opacity(0.1)))
                        }
                    }
                    HStack(spacing: PlagitSpacing.sm) {
                        Text(timeAgo(n.createdAt)).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                        if showPriorityLabel && !n.isRead {
                            Text("·").foregroundColor(.plagitTertiary)
                            Image(systemName: "bolt.fill").font(.system(size: 8, weight: .bold)).foregroundColor(.plagitAmber)
                        }
                    }
                }
                Spacer()
                if !n.isRead { Circle().fill(Color.plagitTeal).frame(width: 8, height: 8) }
            }
            .padding(.horizontal, PlagitSpacing.xl).padding(.vertical, PlagitSpacing.lg)
            .background(
                n.isRead
                    ? Color.clear
                    : (showPriorityLabel ? Color.plagitAmber.opacity(0.04) : Color.plagitTealLight.opacity(0.15))
            )
        }.buttonStyle(.plain)
    }

    private func navigate(_ n: ActivityNotification) {
        let route = n.destinationRoute ?? ""

        switch route {
        case "interview":
            DispatchQueue.main.async { showInterviews = true }
        case "message":
            if let entity = n.linkedEntity, !entity.isEmpty {
                chatConvId = entity
                DispatchQueue.main.async { showChat = true }
            } else {
                DispatchQueue.main.async { showMessages = true }
            }
        case "application", "applicant":
            DispatchQueue.main.async { showJobs = true }
        case "shortlist":
            // Shortlist notifications → open Applications (where the user can see shortlisted status)
            DispatchQueue.main.async { showJobs = true }
        case "match":
            DispatchQueue.main.async { showMatches = true }
        default:
            // Profile-related or generic notifications → open Profile
            if n.title.lowercased().contains("profile") {
                DispatchQueue.main.async { showProfile = true }
            } else {
                DispatchQueue.main.async { showProfile = true }
            }
        }
    }

    // MARK: - Actions

    private func markRead(_ n: ActivityNotification) async {
        guard !n.isRead else { return }
        if isBusiness {
            try? await BusinessAPIService.shared.markNotificationRead(id: n.id)
        } else {
            try? await APIClient.shared.requestVoid(.PATCH, path: "/candidate/notifications/\(n.id)/read")
        }
        await load()
    }

    private func markAllRead() async {
        if isBusiness {
            try? await APIClient.shared.requestVoid(.PATCH, path: "/business/notifications/read-all")
        } else {
            try? await APIClient.shared.requestVoid(.PATCH, path: "/candidate/notifications/read-all")
        }
        await load()
    }

    // MARK: - Empty

    private var emptyState: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack {
                Circle().fill(Color.plagitTealLight).frame(width: 56, height: 56)
                Image(systemName: "bell").font(.system(size: 24, weight: .medium)).foregroundColor(.plagitTeal)
            }
            Text(L10n.t("no_activity_yet")).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
            Text(isBusiness
                ? L10n.t("activity_empty_business")
                : L10n.t("activity_empty_candidate")
            ).font(PlagitFont.caption()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center)
        }.padding(.horizontal, PlagitSpacing.xxl)
    }

    private func timeAgo(_ iso: String?) -> String {
        guard let iso else { return "" }
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = f.date(from: iso) ?? ISO8601DateFormatter().date(from: iso) else { return "" }
        let s = Int(Date().timeIntervalSince(date))
        if s < 60 { return L10n.t("just_now") }
        if s < 3600 { return "\(s / 60)m" }
        if s < 86400 { return "\(s / 3600)h" }
        return "\(s / 86400)d"
    }
}
