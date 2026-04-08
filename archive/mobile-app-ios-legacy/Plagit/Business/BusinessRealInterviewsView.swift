//
//  BusinessRealInterviewsView.swift
//  Plagit
//
//  Real business interviews list backed by GET /business/interviews.
//

import SwiftUI

struct BusinessRealInterviewsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var interviews: [BusinessInterviewDTO] = []
    @State private var isLoading = true
    @State private var loadError: String?
    @State private var selectedFilter = "All"
    @State private var isUpdating = false
    @State private var showDetail = false
    @State private var selectedInterviewId: String?

    private let filters = ["All", "pending", "confirmed", "completed", "cancelled"]
    private var filterLabels: [String: String] {
        ["All": L10n.all, "pending": L10n.interviewStatus("pending"), "confirmed": L10n.interviewStatus("confirmed"), "completed": L10n.interviewStatus("completed"), "cancelled": L10n.interviewStatus("cancelled")]
    }

    private var filteredInterviews: [BusinessInterviewDTO] {
        if selectedFilter == "All" { return interviews }
        return interviews.filter { $0.status == selectedFilter }
    }

    private func statusColor(_ s: String) -> Color {
        switch s { case "pending": return .plagitAmber; case "confirmed": return .plagitTeal; case "completed": return .plagitOnline; case "cancelled": return .plagitUrgent; default: return .plagitSecondary }
    }
    private func typeLabel(_ t: String) -> String {
        L10n.interviewType(t)
    }
    private func formatDate(_ iso: String?) -> String {
        guard let iso else { return "TBD" }
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = f.date(from: iso) ?? ISO8601DateFormatter().date(from: iso) else { return iso }
        let df = DateFormatter(); df.dateFormat = "MMM d, yyyy 'at' h:mm a"; return df.string(from: date)
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
                } else if filteredInterviews.isEmpty { Spacer(); emptyState; Spacer()
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: PlagitSpacing.md) {
                            ForEach(filteredInterviews) { iv in
                                Button {
                                    selectedInterviewId = iv.id
                                    DispatchQueue.main.async { showDetail = true }
                                } label: {
                                    interviewCard(iv)
                                }.buttonStyle(.plain)
                            }
                        }
                            .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.xxxl)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showDetail) {
            BusinessInterviewDetailView(interviewId: selectedInterviewId ?? "").navigationBarHidden(true)
        }
        .task { await load() }
    }

    private func load() async {
        isLoading = true; loadError = nil
        do { interviews = try await BusinessAPIService.shared.fetchInterviews() } catch { loadError = error.localizedDescription }
        isLoading = false
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: { Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36) }
            Spacer(); Text("Interviews").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal); Spacer(); Color.clear.frame(width: 36, height: 36)
        }.padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.lg)
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PlagitSpacing.sm) {
                ForEach(filters, id: \.self) { f in
                    let active = selectedFilter == f; let count = f == "All" ? interviews.count : interviews.filter { $0.status == f }.count
                    Button { withAnimation(.easeInOut(duration: 0.2)) { selectedFilter = f } } label: {
                        HStack(spacing: PlagitSpacing.xs) {
                            Text(filterLabels[f] ?? f).font(PlagitFont.captionMedium()).foregroundColor(active ? .white : .plagitSecondary)
                            if count > 0 && f != "All" { Text("\(count)").font(PlagitFont.micro()).foregroundColor(active ? .white.opacity(0.8) : .plagitTertiary) }
                        }.padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm)
                        .background(Capsule().fill(active ? Color.plagitTeal : Color.plagitSurface))
                        .overlay(Capsule().stroke(active ? Color.clear : Color.plagitBorder, lineWidth: 0.5))
                    }
                }
            }.padding(.horizontal, PlagitSpacing.xl)
        }
    }

    private func interviewCard(_ iv: BusinessInterviewDTO) -> some View {
        let sc = statusColor(iv.status); let hue = iv.candidateAvatarHue ?? 0.5
        return HStack(spacing: PlagitSpacing.md) {
            ProfileAvatarView(photoUrl: iv.candidatePhotoUrl, initials: iv.candidateInitials ?? "—", hue: hue, size: 44)
            VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                Text(iv.candidateName ?? "Unknown").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                if let jt = iv.jobTitle { Text(jt).font(PlagitFont.caption()).foregroundColor(.plagitSecondary) }
                Text("\(formatDate(iv.scheduledAt)) · \(typeLabel(iv.interviewType))").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(L10n.interviewStatus(iv.status)).font(PlagitFont.micro()).foregroundColor(sc)
                    .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 3)
                    .background(Capsule().fill(sc.opacity(0.08)))
                Image(systemName: "chevron.right").font(.system(size: 10, weight: .medium)).foregroundColor(.plagitTertiary)
            }
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
    }

    private var emptyState: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack { Circle().fill(Color.plagitTealLight).frame(width: 48, height: 48); Image(systemName: "calendar").font(.system(size: 20, weight: .medium)).foregroundColor(.plagitTeal) }
            Text("No interviews scheduled").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
            Text("Schedule interviews from the applicants view.").font(PlagitFont.caption()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center)
        }.padding(.horizontal, PlagitSpacing.xxl)
    }
}
