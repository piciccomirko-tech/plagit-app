//
//  BusinessRealNotificationsView.swift
//  Plagit
//
//  Real business notifications backed by GET /business/notifications.
//

import SwiftUI

struct BusinessRealNotificationsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var notifications: [BizNotificationDTO] = []
    @State private var isLoading = true
    @State private var loadError: String?
    @State private var selectedFilter = "All"

    private let filters = ["All", "Unread"]

    private var filtered: [BizNotificationDTO] {
        if selectedFilter == "Unread" { return notifications.filter { !$0.isRead } }
        return notifications
    }
    private var unreadCount: Int { notifications.filter { !$0.isRead }.count }

    private func typeIcon(_ t: String) -> String {
        switch t { case "push": return "bell.fill"; case "email": return "envelope.fill"; case "in_app": return "app.badge"; case "sms": return "message.fill"; default: return "bell" }
    }

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar
                filterChips.padding(.top, PlagitSpacing.xs)
                if isLoading { Spacer(); ProgressView().tint(.plagitTeal); Spacer()
                } else if let error = loadError {
                    Spacer(); VStack(spacing: PlagitSpacing.md) { Text(error).font(PlagitFont.caption()).foregroundColor(.plagitSecondary); Button { Task { await load() } } label: { Text("Retry").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal) } }.padding(PlagitSpacing.xxl); Spacer()
                } else if filtered.isEmpty { Spacer(); emptyState; Spacer()
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: PlagitSpacing.sm) {
                            ForEach(filtered) { n in notificationRow(n) }
                        }.padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.xxxl)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .task { await load() }
    }

    private func load() async {
        isLoading = true; loadError = nil
        do { notifications = try await BusinessAPIService.shared.fetchNotifications() } catch { loadError = error.localizedDescription }
        isLoading = false
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: { Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36) }
            Spacer(); Text("Notifications").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
            if unreadCount > 0 { Text("\(unreadCount)").font(PlagitFont.micro()).foregroundColor(.white).padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 2).background(Capsule().fill(Color.plagitTeal)) }
            Spacer(); Color.clear.frame(width: 36, height: 36)
        }.padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.lg)
    }

    private var filterChips: some View {
        HStack(spacing: PlagitSpacing.sm) {
            ForEach(filters, id: \.self) { f in
                let active = selectedFilter == f
                Button { withAnimation(.easeInOut(duration: 0.2)) { selectedFilter = f } } label: {
                    Text(f).font(PlagitFont.captionMedium()).foregroundColor(active ? .white : .plagitSecondary)
                        .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm)
                        .background(Capsule().fill(active ? Color.plagitTeal : Color.plagitSurface))
                        .overlay(Capsule().stroke(active ? Color.clear : Color.plagitBorder, lineWidth: 0.5))
                }
            }; Spacer()
        }.padding(.horizontal, PlagitSpacing.xl)
    }

    private func notificationRow(_ n: BizNotificationDTO) -> some View {
        Button {
            if !n.isRead { Task { try? await BusinessAPIService.shared.markNotificationRead(id: n.id); await load() } }
        } label: {
            HStack(spacing: PlagitSpacing.md) {
                ZStack {
                    Circle().fill(n.isRead ? Color.plagitSurface : Color.plagitTealLight).frame(width: 36, height: 36)
                    Image(systemName: typeIcon(n.notificationType)).font(.system(size: 14, weight: .medium)).foregroundColor(n.isRead ? .plagitTertiary : .plagitTeal)
                }
                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    Text(n.title).font(n.isRead ? PlagitFont.body() : PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal).lineLimit(2)
                    Text(n.deliveryState.capitalized).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                }; Spacer()
                if !n.isRead { Circle().fill(Color.plagitTeal).frame(width: 8, height: 8) }
            }.padding(PlagitSpacing.lg)
            .background(RoundedRectangle(cornerRadius: PlagitRadius.lg).fill(n.isRead ? Color.plagitBackground : Color.plagitCardBackground))
        }.buttonStyle(.plain)
    }

    private var emptyState: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack { Circle().fill(Color.plagitTealLight).frame(width: 48, height: 48); Image(systemName: "bell").font(.system(size: 20, weight: .medium)).foregroundColor(.plagitTeal) }
            Text("No notifications").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
            Text("You'll be notified about new applicants, interviews, and messages.").font(PlagitFont.caption()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center)
        }.padding(.horizontal, PlagitSpacing.xxl)
    }
}
