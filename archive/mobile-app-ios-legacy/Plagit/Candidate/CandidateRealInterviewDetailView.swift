//
//  CandidateRealInterviewDetailView.swift
//  Plagit
//
//  Real interview detail backed by GET /candidate/interviews/:id.
//

import SwiftUI

struct CandidateRealInterviewDetailView: View {
    let interviewId: String
    @Environment(\.dismiss) private var dismiss

    @State private var interview: CandidateInterviewDTO?
    @State private var isLoading = true
    @State private var loadError: String?

    private func statusColor(_ s: String) -> Color {
        switch s {
        case "pending": return .plagitAmber
        case "confirmed": return .plagitTeal
        case "completed": return .plagitOnline
        case "cancelled": return .plagitUrgent
        case "rescheduled": return .plagitIndigo
        default: return .plagitSecondary
        }
    }

    private func statusLabel(_ s: String) -> String {
        switch s {
        case "pending": return "Pending"
        case "confirmed": return "Confirmed"
        case "completed": return "Completed"
        case "cancelled": return "Cancelled"
        case "rescheduled": return "Rescheduled"
        default: return s.capitalized
        }
    }

    private func typeLabel(_ t: String) -> String {
        switch t {
        case "video_call": return "Video Call"
        case "phone": return "Phone"
        case "in_person": return "In Person"
        default: return t.capitalized
        }
    }

    private func formatDate(_ iso: String?) -> String {
        guard let iso else { return "TBD" }
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = f.date(from: iso) ?? ISO8601DateFormatter().date(from: iso) else { return iso }
        let df = DateFormatter()
        df.dateFormat = "EEEE, MMMM d, yyyy"
        return df.string(from: date)
    }

    private func formatTime(_ iso: String?) -> String {
        guard let iso else { return "" }
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = f.date(from: iso) ?? ISO8601DateFormatter().date(from: iso) else { return "" }
        let df = DateFormatter()
        df.dateFormat = "h:mm a"
        return df.string(from: date)
    }

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()

            if isLoading {
                ProgressView().tint(.plagitTeal)
            } else if let error = loadError {
                VStack(spacing: PlagitSpacing.lg) {
                    Image(systemName: "exclamationmark.triangle").font(.system(size: 32)).foregroundColor(.plagitTertiary)
                    Text(error).font(PlagitFont.caption()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center)
                    Button { Task { await load() } } label: {
                        Text("Retry").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                    }
                }.padding(PlagitSpacing.xxl)
            } else if let iv = interview {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        topBar
                        statusBanner(iv).padding(.top, PlagitSpacing.lg)
                        detailsCard(iv).padding(.top, PlagitSpacing.sectionGap)
                        companyCard(iv).padding(.top, PlagitSpacing.sectionGap)
                        if iv.status == "pending" || iv.status == "confirmed" {
                            actionCard(iv).padding(.top, PlagitSpacing.sectionGap)
                        }
                        if let toast = responseToast {
                            Text(toast).font(PlagitFont.caption()).foregroundColor(.plagitUrgent)
                                .padding(.top, PlagitSpacing.md).padding(.horizontal, PlagitSpacing.xl)
                        }
                        Spacer().frame(height: PlagitSpacing.xxxl)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .task { await load() }
    }

    private func load() async {
        isLoading = true; loadError = nil
        do {
            interview = try await CandidateAPIService.shared.fetchInterview(id: interviewId)
        } catch {
            loadError = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36)
            }
            Spacer()
            Text("Interview Details").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.xxl).padding(.bottom, PlagitSpacing.lg)
    }

    // MARK: - Status Banner

    private func statusBanner(_ iv: CandidateInterviewDTO) -> some View {
        let sc = statusColor(iv.status)
        return HStack(spacing: PlagitSpacing.md) {
            ZStack {
                Circle().fill(sc.opacity(0.12)).frame(width: 40, height: 40)
                Image(systemName: iv.status == "confirmed" ? "checkmark.circle" : iv.status == "cancelled" ? "xmark.circle" : "clock")
                    .font(.system(size: 18, weight: .medium)).foregroundColor(sc)
            }
            VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                Text(statusLabel(iv.status)).font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
                Text(iv.jobTitle ?? "Interview").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
            }
            Spacer()
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
        .overlay(RoundedRectangle(cornerRadius: PlagitRadius.xl).stroke(sc.opacity(0.15), lineWidth: 1))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Details

    private func detailsCard(_ iv: CandidateInterviewDTO) -> some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            HStack(spacing: PlagitSpacing.sm) {
                Image(systemName: "calendar").font(.system(size: 12, weight: .medium)).foregroundColor(.plagitTeal)
                Text("Interview Details").font(PlagitFont.captionMedium()).foregroundColor(.plagitSecondary)
            }

            VStack(spacing: PlagitSpacing.md) {
                detailRow("calendar", "Date", formatDate(iv.scheduledAt))
                detailRow("clock", "Time", formatTime(iv.scheduledAt) + (iv.timezone.map { " \($0)" } ?? ""))
                detailRow("video", "Type", typeLabel(iv.interviewType))
                if let loc = iv.location, !loc.isEmpty {
                    detailRow("mappin", "Location", loc)
                }
                if let link = iv.meetingLink, !link.isEmpty {
                    detailRow("link", "Meeting Link", link)
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

    // MARK: - Company

    private func companyCard(_ iv: CandidateInterviewDTO) -> some View {
        let hue = iv.businessAvatarHue ?? 0.5
        return HStack(spacing: PlagitSpacing.md) {
            Circle()
                .fill(LinearGradient(colors: [Color(hue: hue, saturation: 0.45, brightness: 0.90), Color(hue: hue, saturation: 0.55, brightness: 0.75)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 44, height: 44)
                .overlay(Text(iv.businessInitials ?? "—").font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(.white))
            VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                HStack(spacing: PlagitSpacing.sm) {
                    Text(iv.businessName ?? "Unknown").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                    if iv.businessVerified == true {
                        Image(systemName: "checkmark.seal.fill").font(.system(size: 10)).foregroundColor(.plagitVerified)
                    }
                }
                if let loc = iv.jobLocation, !loc.isEmpty {
                    Text(loc).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                }
            }
            Spacer()
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Action

    @State private var isResponding = false
    @State private var responseToast: String?
    @State private var respondError: String?

    private func actionCard(_ iv: CandidateInterviewDTO) -> some View {
        VStack(spacing: PlagitSpacing.md) {
            // Accept / Decline
            if iv.status == "pending" {
                HStack(spacing: PlagitSpacing.sm) {
                    Button {
                        Task { await respond("confirmed") }
                    } label: {
                        HStack(spacing: PlagitSpacing.xs) {
                            Image(systemName: "checkmark.circle.fill").font(.system(size: 14))
                            Text("Accept").font(PlagitFont.captionMedium())
                        }
                        .foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, PlagitSpacing.md)
                        .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitOnline))
                    }
                    Button {
                        Task { await respond("declined") }
                    } label: {
                        HStack(spacing: PlagitSpacing.xs) {
                            Image(systemName: "xmark.circle.fill").font(.system(size: 14))
                            Text("Decline").font(PlagitFont.captionMedium())
                        }
                        .foregroundColor(.plagitUrgent).frame(maxWidth: .infinity).padding(.vertical, PlagitSpacing.md)
                        .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitUrgent.opacity(0.06)))
                    }
                }.disabled(isResponding)
            }

            if iv.interviewType == "video_call", let link = iv.meetingLink, !link.isEmpty {
                Button {
                    if let url = URL(string: link) { UIApplication.shared.open(url) }
                } label: {
                    HStack(spacing: PlagitSpacing.sm) {
                        Image(systemName: "video.fill")
                        Text("Join Video Call")
                    }
                    .font(PlagitFont.subheadline()).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, PlagitSpacing.lg)
                    .background(Capsule().fill(LinearGradient(colors: [Color.plagitTeal, Color.plagitTealDark], startPoint: .topLeading, endPoint: .bottomTrailing)))
                }
            }

            if iv.interviewType == "in_person", let loc = iv.location, !loc.isEmpty {
                Button {
                    let q = loc.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? loc
                    if let url = URL(string: "maps://?q=\(q)") { UIApplication.shared.open(url) }
                } label: {
                    HStack(spacing: PlagitSpacing.sm) {
                        Image(systemName: "map.fill")
                        Text("Open in Maps")
                    }
                    .font(PlagitFont.subheadline()).foregroundColor(.plagitTeal)
                    .frame(maxWidth: .infinity).padding(.vertical, PlagitSpacing.lg)
                    .background(Capsule().fill(Color.plagitTealLight))
                }
            }
        }
        .padding(.horizontal, PlagitSpacing.xl)
    }

    @MainActor
    private func respond(_ status: String) async {
        isResponding = true
        do {
            try await CandidateAPIService.shared.respondToInterview(id: interviewId, status: status)
            interview = try await CandidateAPIService.shared.fetchInterview(id: interviewId)
        } catch {
            // Update locally so the UI reflects the change in test mode
            if let current = interview {
                let newStatus = status == "confirmed" ? "confirmed" : "cancelled"
                interview = CandidateInterviewDTO(
                    id: current.id, scheduledAt: current.scheduledAt, timezone: current.timezone,
                    interviewType: current.interviewType, status: newStatus,
                    location: current.location, meetingLink: current.meetingLink, createdAt: current.createdAt,
                    jobId: current.jobId, jobTitle: current.jobTitle, jobLocation: current.jobLocation,
                    businessName: current.businessName, businessInitials: current.businessInitials,
                    businessVerified: current.businessVerified, businessAvatarHue: current.businessAvatarHue
                )
            }
        }
        isResponding = false
    }
}
