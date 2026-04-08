//
//  PostActionMenu.swift
//  Plagit
//
//  Role-aware contextual action menu for social feed posts.
//  Shows different actions for own posts vs others' posts,
//  and for candidate/business vs admin users.
//

import SwiftUI

// MARK: - User Role Detection

enum FeedUserRole {
    case candidate
    case business
    case admin

    static var current: FeedUserRole {
        if AdminAuthService.shared.isAuthenticated { return .admin }
        if BusinessAuthService.shared.isAuthenticated { return .business }
        return .candidate
    }
}

// MARK: - Post Action Menu

struct PostActionMenu: View {
    let post: FeedPostDTO
    let userRole: FeedUserRole
    let isSaved: Bool

    // Callbacks
    var onSave: () -> Void = {}
    var onShare: () -> Void = {}
    var onCopyLink: () -> Void = {}
    var onNotInterested: () -> Void = {}
    var onMuteUser: () -> Void = {}
    var onBlockUser: () -> Void = {}
    var onReport: () -> Void = {}
    var onEdit: () -> Void = {}
    var onDelete: () -> Void = {}
    var onToggleNotifications: () -> Void = {}
    // Admin
    var onAdminRemove: () -> Void = {}
    var onAdminMarkSpam: () -> Void = {}
    var onAdminSuspend: () -> Void = {}
    var onAdminViewReports: () -> Void = {}

    private var isOwnPost: Bool { post.isOwn == true }

    var body: some View {
        VStack(spacing: 0) {
            // Drag indicator
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.plagitTertiary.opacity(0.3))
                .frame(width: 36, height: 4)
                .padding(.top, PlagitSpacing.md)
                .padding(.bottom, PlagitSpacing.lg)

            if userRole == .admin {
                adminActions
            } else if isOwnPost {
                ownPostActions
            } else {
                otherPostActions
            }

            Spacer().frame(height: PlagitSpacing.xxxl)
        }
        .background(Color.plagitCardBackground)
    }

    // MARK: - Other's Post Actions

    private var otherPostActions: some View {
        VStack(spacing: 0) {
            actionRow(icon: "link", label: L10n.t("copy_link"), color: .plagitCharcoal, action: onCopyLink)

            divider

            actionRow(icon: "hand.thumbsdown", label: L10n.t("not_interested"), color: .plagitCharcoal, action: onNotInterested)
            actionRow(icon: "speaker.slash", label: L10n.t("mute_user"), color: .plagitCharcoal, action: onMuteUser)
            actionRow(icon: "nosign", label: L10n.t("block_user"), color: .plagitUrgent, action: onBlockUser)

            divider

            actionRow(icon: "flag", label: L10n.t("report_post"), color: .plagitUrgent, action: onReport)
        }
    }

    // MARK: - Own Post Actions

    private var ownPostActions: some View {
        VStack(spacing: 0) {
            actionRow(icon: "pencil", label: L10n.t("edit_post"), color: .plagitCharcoal, action: onEdit)
            actionRow(icon: "trash", label: L10n.t("delete_post"), color: .plagitUrgent, action: onDelete)
            actionRow(icon: "link", label: L10n.t("copy_link"), color: .plagitCharcoal, action: onCopyLink)
            actionRow(icon: "bell.slash", label: L10n.t("turn_off_notifications"), color: .plagitSecondary, action: onToggleNotifications)
        }
    }

    // MARK: - Admin Actions

    private var adminActions: some View {
        VStack(spacing: 0) {
            actionRow(icon: "exclamationmark.bubble", label: L10n.t("view_reports"), color: .plagitCharcoal, action: onAdminViewReports)
            actionRow(icon: "trash", label: L10n.t("remove_post"), color: .plagitUrgent, action: onAdminRemove)
            actionRow(icon: "xmark.bin", label: L10n.t("mark_as_spam"), color: .plagitAmber, action: onAdminMarkSpam)
            actionRow(icon: "person.crop.circle.badge.xmark", label: L10n.t("suspend_user"), color: .plagitUrgent, action: onAdminSuspend)

            divider

            actionRow(icon: "link", label: L10n.t("copy_link"), color: .plagitCharcoal, action: onCopyLink)
        }
    }

    // MARK: - Row Builder

    private func actionRow(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: PlagitSpacing.lg) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color)
                    .frame(width: 24)
                Text(label)
                    .font(PlagitFont.body())
                    .foregroundColor(color)
                Spacer()
            }
            .padding(.horizontal, PlagitSpacing.xxl)
            .padding(.vertical, PlagitSpacing.lg)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var divider: some View {
        Rectangle().fill(Color.plagitDivider).frame(height: 1)
            .padding(.horizontal, PlagitSpacing.xxl)
            .padding(.vertical, PlagitSpacing.xs)
    }
}

// MARK: - Report Post Sheet

struct ReportPostSheet: View {
    let post: FeedPostDTO
    var onReport: (String, String?) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var selectedReason: String?
    @State private var otherDetails = ""
    @State private var isSubmitting = false
    @State private var submitted = false

    private let reasons: [(String, String, String)] = [
        ("spam", "Spam", "flag"),
        ("harassment", "Harassment", "exclamationmark.bubble"),
        ("inappropriate", "Inappropriate Content", "eye.slash"),
        ("misleading", "Fake or Misleading", "doc.questionmark"),
        ("other", "Other", "ellipsis.circle"),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.plagitBackground.ignoresSafeArea()

                if submitted {
                    submittedView
                } else {
                    reasonsList
                }
            }
            .navigationTitle(L10n.t("report_post"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L10n.cancel) { dismiss() }
                        .font(PlagitFont.captionMedium())
                        .foregroundColor(.plagitSecondary)
                }
            }
        }
    }

    private var reasonsList: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: PlagitSpacing.sm) {
                Image(systemName: "flag.fill")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(.plagitUrgent)
                Text("Why are you reporting this post?")
                    .font(PlagitFont.bodyMedium())
                    .foregroundColor(.plagitCharcoal)
                Text("Your report is anonymous. We'll review it and take action if it violates our guidelines.")
                    .font(PlagitFont.caption())
                    .foregroundColor(.plagitSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, PlagitSpacing.xxl)
            .padding(.top, PlagitSpacing.xxl)
            .padding(.bottom, PlagitSpacing.xl)

            // Reasons
            VStack(spacing: 0) {
                ForEach(reasons, id: \.0) { id, label, icon in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) { selectedReason = id }
                    } label: {
                        HStack(spacing: PlagitSpacing.lg) {
                            Image(systemName: icon)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(selectedReason == id ? .plagitTeal : .plagitSecondary)
                                .frame(width: 24)
                            Text(label)
                                .font(PlagitFont.body())
                                .foregroundColor(.plagitCharcoal)
                            Spacer()
                            if selectedReason == id {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.plagitTeal)
                            }
                        }
                        .padding(.horizontal, PlagitSpacing.xxl)
                        .padding(.vertical, PlagitSpacing.lg)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if id != reasons.last?.0 {
                        Rectangle().fill(Color.plagitDivider).frame(height: 1)
                            .padding(.leading, PlagitSpacing.xxl + 24 + PlagitSpacing.lg)
                    }
                }
            }
            .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground))
            .padding(.horizontal, PlagitSpacing.xl)

            // Other details
            if selectedReason == "other" {
                VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
                    Text("Please describe the issue")
                        .font(PlagitFont.captionMedium())
                        .foregroundColor(.plagitSecondary)
                    TextEditor(text: $otherDetails)
                        .font(PlagitFont.body())
                        .foregroundColor(.plagitCharcoal)
                        .frame(height: 80)
                        .scrollContentBackground(.hidden)
                        .padding(PlagitSpacing.md)
                        .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitCardBackground))
                }
                .padding(.horizontal, PlagitSpacing.xl)
                .padding(.top, PlagitSpacing.lg)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            Spacer()

            // Submit button
            Button {
                guard let reason = selectedReason else { return }
                isSubmitting = true
                onReport(reason, selectedReason == "other" ? otherDetails : nil)
                withAnimation { submitted = true }
                isSubmitting = false
            } label: {
                HStack(spacing: PlagitSpacing.sm) {
                    if isSubmitting {
                        ProgressView().tint(.white)
                    } else {
                        Text("Submit Report")
                            .font(PlagitFont.bodyMedium())
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, PlagitSpacing.lg)
                .background(Capsule().fill(selectedReason != nil ? Color.plagitUrgent : Color.plagitTertiary.opacity(0.4)))
            }
            .disabled(selectedReason == nil || isSubmitting)
            .padding(.horizontal, PlagitSpacing.xxl)
            .padding(.bottom, PlagitSpacing.xxl)
        }
    }

    private var submittedView: some View {
        VStack(spacing: PlagitSpacing.xl) {
            Spacer()
            ZStack {
                Circle().fill(Color.plagitOnline.opacity(0.1)).frame(width: 72, height: 72)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.plagitOnline)
            }
            Text("Report Submitted")
                .font(PlagitFont.headline())
                .foregroundColor(.plagitCharcoal)
            Text("Thank you. We'll review this post and take action if needed.")
                .font(PlagitFont.body())
                .foregroundColor(.plagitSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, PlagitSpacing.xxl)
            Spacer()
            Button {
                dismiss()
            } label: {
                Text(L10n.done)
                    .font(PlagitFont.bodyMedium())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, PlagitSpacing.lg)
                    .background(Capsule().fill(Color.plagitTeal))
            }
            .padding(.horizontal, PlagitSpacing.xxl)
            .padding(.bottom, PlagitSpacing.xxl)
        }
    }
}

// MARK: - Edit Post Sheet

struct EditPostSheet: View {
    let post: FeedPostDTO
    var onSave: (String) async -> Bool
    @Environment(\.dismiss) private var dismiss

    @State private var editedBody: String = ""
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.plagitBackground.ignoresSafeArea()
                VStack(spacing: 0) {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
                            HStack(spacing: PlagitSpacing.md) {
                                ProfileAvatarView(
                                    photoUrl: post.authorPhotoUrl,
                                    initials: post.authorInitials ?? "—",
                                    hue: post.authorAvatarHue ?? 0.5,
                                    size: 40, verified: post.authorVerified == true
                                )
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(post.authorName ?? "You")
                                        .font(PlagitFont.bodyMedium())
                                        .foregroundColor(.plagitCharcoal)
                                    Text("Editing post")
                                        .font(PlagitFont.micro())
                                        .foregroundColor(.plagitSecondary)
                                }
                                Spacer()
                            }

                            TextEditor(text: $editedBody)
                                .font(PlagitFont.body())
                                .foregroundColor(.plagitCharcoal)
                                .frame(minHeight: 150)
                                .scrollContentBackground(.hidden)
                        }
                        .padding(.horizontal, PlagitSpacing.xl)
                        .padding(.top, PlagitSpacing.lg)
                    }
                }
            }
            .navigationTitle(L10n.t("edit_post"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(L10n.cancel) { dismiss() }
                        .font(PlagitFont.captionMedium())
                        .foregroundColor(.plagitSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            isSaving = true
                            let success = await onSave(editedBody.trimmingCharacters(in: .whitespaces))
                            isSaving = false
                            if success { dismiss() }
                        }
                    } label: {
                        if isSaving { ProgressView().tint(.white).frame(width: 50, height: 28) }
                        else { Text(L10n.t("save")).font(PlagitFont.captionMedium()).fontWeight(.semibold) }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, PlagitSpacing.xl)
                    .padding(.vertical, PlagitSpacing.sm)
                    .background(Capsule().fill(!editedBody.trimmingCharacters(in: .whitespaces).isEmpty ? Color.plagitTeal : Color.plagitTertiary.opacity(0.4)))
                    .disabled(editedBody.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
                }
            }
            .onAppear { editedBody = post.body }
        }
    }
}
