//
//  FeedActivityView.swift
//  Plagit
//
//  Notifications / Activity screen for community feed interactions.
//  Shows likes, comments, and follows from other users.
//

import SwiftUI

struct FeedActivityView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var notifications: [FeedNotificationDTO] = []
    @State private var isLoading = true

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar
                if isLoading {
                    Spacer(); ProgressView().tint(.plagitTeal); Spacer()
                } else if notifications.isEmpty {
                    Spacer(); emptyState; Spacer()
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(notifications) { notif in
                                notificationRow(notif)
                                Rectangle().fill(Color.plagitDivider).frame(height: 0.5)
                                    .padding(.leading, PlagitSpacing.xl + 44 + PlagitSpacing.md)
                            }
                        }
                        .padding(.bottom, PlagitSpacing.xxxl)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .task { await load() }
    }

    private func load() async {
        isLoading = true
        notifications = await FeedService.shared.fetchNotifications()
        isLoading = false
        // Mark all as read after viewing
        await FeedService.shared.markAllNotificationsRead()
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium))
                    .foregroundColor(.plagitCharcoal).frame(width: 36, height: 36)
            }
            Spacer()
            Text(L10n.activity).font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, PlagitSpacing.xl)
        .padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.lg)
    }

    private func notificationRow(_ notif: FeedNotificationDTO) -> some View {
        let hue = notif.actorAvatarHue ?? 0.5
        return HStack(alignment: .top, spacing: PlagitSpacing.md) {
            ProfileAvatarView(
                photoUrl: notif.actorPhotoUrl,
                initials: notif.actorInitials ?? "?",
                hue: hue, size: 44,
                verified: notif.actorVerified == true
            )

            VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                HStack(spacing: 0) {
                    Text(notif.actorName ?? "Someone").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                    Text(" \(actionText(notif.actionType))").font(PlagitFont.body()).foregroundColor(.plagitSecondary)
                }

                if let preview = notif.preview, !preview.isEmpty {
                    Text(preview).font(PlagitFont.caption()).foregroundColor(.plagitTertiary).lineLimit(2)
                }

                Text(timeAgo(notif.createdAt)).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
            }

            Spacer()

            actionIcon(notif.actionType)

            if !notif.isRead {
                Circle().fill(Color.plagitTeal).frame(width: 8, height: 8)
            }
        }
        .padding(.horizontal, PlagitSpacing.xl).padding(.vertical, PlagitSpacing.lg)
        .background(notif.isRead ? Color.clear : Color.plagitTealLight.opacity(0.3))
    }

    private func actionText(_ type: String) -> String {
        switch type {
        case "like": return L10n.t("liked_your_post")
        case "comment": return L10n.t("commented_on_post")
        case "follow": return L10n.t("started_following")
        default: return L10n.t("interacted_content")
        }
    }

    private func actionIcon(_ type: String) -> some View {
        let (icon, color): (String, Color) = {
            switch type {
            case "like": return ("heart.fill", .plagitUrgent)
            case "comment": return ("bubble.left.fill", .plagitTeal)
            case "follow": return ("person.badge.plus", .plagitIndigo)
            default: return ("bell.fill", .plagitAmber)
            }
        }()
        return Image(systemName: icon).font(.system(size: 14, weight: .medium)).foregroundColor(color)
    }

    private var emptyState: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack {
                Circle().fill(Color.plagitTealLight).frame(width: 56, height: 56)
                Image(systemName: "bell").font(.system(size: 24, weight: .medium)).foregroundColor(.plagitTeal)
            }
            Text(L10n.t("no_activity_yet")).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
            Text(L10n.t("activity_empty_desc"))
                .font(PlagitFont.caption()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center)
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
