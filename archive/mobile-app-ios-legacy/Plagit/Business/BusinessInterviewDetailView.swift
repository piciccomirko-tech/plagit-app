//
//  BusinessInterviewDetailView.swift
//  Plagit
//
//  Business interview detail with status management.
//

import SwiftUI

struct BusinessInterviewDetailView: View {
    let interviewId: String
    @Environment(\.dismiss) private var dismiss
    @State private var interviews: [BusinessInterviewDTO] = []
    @State private var isLoading = true
    @State private var loadError: String?
    @State private var isUpdating = false

    private var interview: BusinessInterviewDTO? { interviews.first { $0.id == interviewId } }

    private func statusColor(_ s: String) -> Color {
        switch s { case "pending": return .plagitAmber; case "confirmed": return .plagitTeal; case "completed": return .plagitOnline; case "cancelled": return .plagitUrgent; case "declined": return .plagitUrgent; default: return .plagitSecondary }
    }
    private func statusIcon(_ s: String) -> String {
        switch s { case "pending": return "clock"; case "confirmed": return "checkmark.circle.fill"; case "completed": return "checkmark.seal.fill"; case "cancelled": return "xmark.circle.fill"; case "declined": return "hand.thumbsdown.fill"; default: return "questionmark.circle" }
    }
    private func typeLabel(_ t: String) -> String {
        switch t { case "video_call": return "Video Call"; case "phone": return "Phone"; case "in_person": return "In Person"; default: return t.capitalized }
    }
    private func typeIcon(_ t: String) -> String {
        switch t { case "video_call": return "video.fill"; case "phone": return "phone.fill"; case "in_person": return "mappin.and.ellipse"; default: return "calendar" }
    }
    private func formatDate(_ iso: String?) -> String {
        guard let iso else { return "TBD" }
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = f.date(from: iso) ?? ISO8601DateFormatter().date(from: iso) else { return iso }
        let df = DateFormatter(); df.dateFormat = "EEEE, MMM d, yyyy"; return df.string(from: date)
    }
    private func formatTime(_ iso: String?) -> String {
        guard let iso else { return "" }
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = f.date(from: iso) ?? ISO8601DateFormatter().date(from: iso) else { return "" }
        let df = DateFormatter(); df.dateFormat = "h:mm a"; return df.string(from: date)
    }

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()
            if isLoading {
                ProgressView().tint(.plagitTeal)
            } else if let iv = interview {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        topBar
                        statusBanner(iv).padding(.top, PlagitSpacing.lg)
                        candidateCard(iv).padding(.top, PlagitSpacing.sectionGap)
                        detailsCard(iv).padding(.top, PlagitSpacing.sectionGap)
                        if iv.status == "pending" || iv.status == "confirmed" {
                            actionsCard(iv).padding(.top, PlagitSpacing.sectionGap)
                        }
                        if let err = updateError {
                            Text(err).font(PlagitFont.caption()).foregroundColor(.plagitUrgent)
                                .padding(.top, PlagitSpacing.md).padding(.horizontal, PlagitSpacing.xl)
                        }
                        Spacer().frame(height: PlagitSpacing.xxxl)
                    }
                }
            } else {
                VStack(spacing: PlagitSpacing.md) {
                    Text("Interview not found").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                    Button { dismiss() } label: { Text("Go Back").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal) }
                }
            }
        }
        .navigationBarHidden(true)
        .task { await load() }
    }

    private func load() async {
        isLoading = true
        do { interviews = try await BusinessAPIService.shared.fetchInterviews() } catch { loadError = error.localizedDescription }
        isLoading = false
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: { Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36) }
            Spacer(); Text("Interview Details").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal); Spacer()
            Color.clear.frame(width: 36, height: 36)
        }.padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.lg)
    }

    // MARK: - Status Banner

    private func statusBanner(_ iv: BusinessInterviewDTO) -> some View {
        let sc = statusColor(iv.status)
        return HStack(spacing: PlagitSpacing.md) {
            Image(systemName: statusIcon(iv.status)).font(.system(size: 20, weight: .medium)).foregroundColor(sc)
            VStack(alignment: .leading, spacing: 2) {
                Text(iv.status.capitalized).font(PlagitFont.bodyMedium()).foregroundColor(sc)
                Text(iv.status == "pending" ? "Waiting for candidate response" : iv.status == "confirmed" ? "Interview confirmed" : iv.status == "completed" ? "Interview completed" : "").font(PlagitFont.micro()).foregroundColor(.plagitSecondary)
            }
            Spacer()
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(sc.opacity(0.06)).overlay(RoundedRectangle(cornerRadius: PlagitRadius.xl).stroke(sc.opacity(0.15), lineWidth: 1)))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Candidate Card

    private func candidateCard(_ iv: BusinessInterviewDTO) -> some View {
        HStack(spacing: PlagitSpacing.md) {
            ProfileAvatarView(photoUrl: iv.candidatePhotoUrl, initials: iv.candidateInitials ?? "—", hue: iv.candidateAvatarHue ?? 0.5, size: 48)
            VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                Text(iv.candidateName ?? "Candidate").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                if let role = iv.candidateRole { Text(role).font(PlagitFont.caption()).foregroundColor(.plagitSecondary) }
                if let jt = iv.jobTitle { Text("for \(jt)").font(PlagitFont.micro()).foregroundColor(.plagitTeal) }
            }
            Spacer()
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Details Card

    private func detailsCard(_ iv: BusinessInterviewDTO) -> some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            detailRow("calendar", "Date", formatDate(iv.scheduledAt))
            detailRow("clock", "Time", formatTime(iv.scheduledAt) + (iv.timezone != nil ? " \(iv.timezone!)" : ""))
            detailRow(typeIcon(iv.interviewType), "Type", typeLabel(iv.interviewType))

            // Meeting link CTA
            if iv.interviewType == "video_call", let link = iv.meetingLink, !link.isEmpty {
                Button {
                    if let url = URL(string: link) { UIApplication.shared.open(url) }
                } label: {
                    HStack(spacing: PlagitSpacing.sm) {
                        Image(systemName: "video.fill").font(.system(size: 14, weight: .medium))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Join Video Call").font(PlagitFont.captionMedium())
                            Text(link).font(PlagitFont.micro()).foregroundColor(.plagitTertiary).lineLimit(1)
                        }
                        Spacer()
                        Image(systemName: "arrow.up.right").font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(.plagitTeal)
                    .padding(PlagitSpacing.md)
                    .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitTealLight))
                }
            }

            // Location CTA
            if iv.interviewType == "in_person", let loc = iv.location, !loc.isEmpty {
                Button {
                    let q = loc.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? loc
                    if let url = URL(string: "maps://?q=\(q)") { UIApplication.shared.open(url) }
                } label: {
                    HStack(spacing: PlagitSpacing.sm) {
                        Image(systemName: "map.fill").font(.system(size: 14, weight: .medium))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Open in Maps").font(PlagitFont.captionMedium())
                            Text(loc).font(PlagitFont.micro()).foregroundColor(.plagitTertiary).lineLimit(1)
                        }
                        Spacer()
                        Image(systemName: "arrow.up.right").font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(.plagitTeal)
                    .padding(PlagitSpacing.md)
                    .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitTealLight))
                }
            }
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func detailRow(_ icon: String, _ label: String, _ value: String) -> some View {
        HStack(spacing: PlagitSpacing.md) {
            Image(systemName: icon).font(.system(size: 13, weight: .medium)).foregroundColor(.plagitTeal).frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                Text(value).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
            }
            Spacer()
        }
    }

    // MARK: - Actions

    private func actionsCard(_ iv: BusinessInterviewDTO) -> some View {
        VStack(spacing: PlagitSpacing.sm) {
            if iv.status == "pending" {
                actionBtn("Confirm Interview", icon: "checkmark.circle.fill", color: .plagitOnline, primary: true) { await updateStatus("confirmed") }
                actionBtn("Cancel Interview", icon: "xmark.circle", color: .plagitUrgent, primary: false) { await updateStatus("cancelled") }
            } else if iv.status == "confirmed" {
                actionBtn("Mark as Completed", icon: "checkmark.seal.fill", color: .plagitTeal, primary: true) { await updateStatus("completed") }
                actionBtn("Cancel Interview", icon: "xmark.circle", color: .plagitUrgent, primary: false) { await updateStatus("cancelled") }
            }
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func actionBtn(_ label: String, icon: String, color: Color, primary: Bool, action: @escaping () async -> Void) -> some View {
        Button { Task { await action() } } label: {
            HStack(spacing: PlagitSpacing.sm) {
                Image(systemName: icon).font(.system(size: 15, weight: .medium))
                Text(label).font(PlagitFont.captionMedium())
                Spacer()
                if isUpdating { ProgressView().tint(primary ? .white : color) }
            }
            .foregroundColor(primary ? .white : color)
            .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.md)
            .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(primary ? color : color.opacity(0.04)))
        }.disabled(isUpdating)
    }

    @State private var updateError: String?

    private func updateStatus(_ status: String) async {
        isUpdating = true; updateError = nil
        do {
            try await BusinessAPIService.shared.updateInterviewStatus(id: interviewId, status: status)
            interviews = try await BusinessAPIService.shared.fetchInterviews()
        } catch {
            updateError = "Could not update interview. Please try again."
        }
        isUpdating = false
    }
}
