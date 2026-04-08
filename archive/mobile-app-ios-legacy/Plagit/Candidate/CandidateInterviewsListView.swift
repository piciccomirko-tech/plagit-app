//
//  CandidateInterviewsListView.swift
//  Plagit
//
//  Real candidate interviews list backed by GET /candidate/interviews.
//

import SwiftUI

struct CandidateInterviewsListView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var interviews: [CandidateInterviewDTO] = []
    @State private var isLoading = true
    @State private var loadError: String?
    @State private var selectedFilter = "All"
    @State private var showDetail = false
    @State private var selectedInterviewId: String?

    private let filters = ["All", "pending", "confirmed", "completed", "cancelled"]
    private var filterLabels: [String: String] {
        ["All": L10n.all, "pending": L10n.interviewStatus("pending"), "confirmed": L10n.interviewStatus("confirmed"), "completed": L10n.interviewStatus("completed"), "cancelled": L10n.interviewStatus("cancelled")]
    }

    private var filteredInterviews: [CandidateInterviewDTO] {
        if selectedFilter == "All" { return interviews }
        return interviews.filter { $0.status == selectedFilter }
    }

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
        L10n.interviewStatus(s)
    }

    private func typeLabel(_ t: String) -> String {
        L10n.interviewType(t)
    }

    private func formatDate(_ iso: String?) -> String {
        guard let iso else { return "TBD" }
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = f.date(from: iso) ?? ISO8601DateFormatter().date(from: iso) else { return iso }
        let df = DateFormatter()
        df.dateFormat = "MMM d, yyyy 'at' h:mm a"
        return df.string(from: date)
    }

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                filterChips.padding(.top, PlagitSpacing.xs)

                if isLoading {
                    Spacer()
                    ProgressView().tint(.plagitTeal)
                    Spacer()
                } else if let error = loadError {
                    Spacer()
                    VStack(spacing: PlagitSpacing.md) {
                        Image(systemName: "wifi.exclamationmark").font(.system(size: 32)).foregroundColor(.plagitTertiary)
                        Text(error).font(PlagitFont.caption()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center)
                        Button { Task { await load() } } label: {
                            Text("Retry").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                        }
                    }.padding(PlagitSpacing.xxl)
                    Spacer()
                } else if filteredInterviews.isEmpty {
                    Spacer()
                    emptyState
                    Spacer()
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: PlagitSpacing.md) {
                            ForEach(filteredInterviews) { iv in
                                interviewCard(iv)
                            }
                        }
                        .padding(.horizontal, PlagitSpacing.xl)
                        .padding(.top, PlagitSpacing.lg)
                        .padding(.bottom, PlagitSpacing.xxxl)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showDetail) {
            CandidateRealInterviewDetailView(interviewId: selectedInterviewId ?? "").navigationBarHidden(true)
        }
        .task { await load() }
    }

    private func load() async {
        isLoading = true; loadError = nil
        do {
            interviews = try await CandidateAPIService.shared.fetchInterviews()
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
            Text("Interviews").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.lg)
    }

    // MARK: - Filters

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PlagitSpacing.sm) {
                ForEach(filters, id: \.self) { f in
                    let active = selectedFilter == f
                    let count = f == "All" ? interviews.count : interviews.filter { $0.status == f }.count
                    Button { withAnimation(.easeInOut(duration: 0.2)) { selectedFilter = f } } label: {
                        HStack(spacing: PlagitSpacing.xs) {
                            Text(filterLabels[f] ?? f).font(PlagitFont.captionMedium()).foregroundColor(active ? .white : .plagitSecondary)
                            if count > 0 { Text("\(count)").font(PlagitFont.micro()).foregroundColor(active ? .white.opacity(0.8) : .plagitTertiary) }
                        }
                        .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm)
                        .background(Capsule().fill(active ? Color.plagitTeal : Color.plagitSurface))
                        .overlay(Capsule().stroke(active ? Color.clear : Color.plagitBorder, lineWidth: 0.5))
                    }
                }
            }.padding(.horizontal, PlagitSpacing.xl)
        }
    }

    // MARK: - Card

    private func interviewCard(_ iv: CandidateInterviewDTO) -> some View {
        let sc = statusColor(iv.status)
        let hue = iv.businessAvatarHue ?? 0.5

        return VStack(alignment: .leading, spacing: PlagitSpacing.md) {
            HStack(alignment: .top, spacing: PlagitSpacing.md) {
                Circle()
                    .fill(LinearGradient(colors: [Color(hue: hue, saturation: 0.45, brightness: 0.90), Color(hue: hue, saturation: 0.55, brightness: 0.75)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 44, height: 44)
                    .overlay(Text(iv.businessInitials ?? "—").font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(.white))

                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    HStack(spacing: PlagitSpacing.sm) {
                        Text(iv.jobTitle ?? "Interview").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                        Text(statusLabel(iv.status)).font(PlagitFont.micro()).foregroundColor(sc)
                            .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 3)
                            .background(Capsule().fill(sc.opacity(0.08)))
                    }
                    Text(iv.businessName ?? "Unknown").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                    Text(formatDate(iv.scheduledAt)).font(PlagitFont.caption()).foregroundColor(.plagitCharcoal)

                    HStack(spacing: PlagitSpacing.sm) {
                        Text(typeLabel(iv.interviewType)).font(PlagitFont.micro()).foregroundColor(.plagitIndigo)
                            .padding(.horizontal, PlagitSpacing.sm - 2).padding(.vertical, 2)
                            .background(Capsule().fill(Color.plagitIndigo.opacity(0.08)))
                        if let loc = iv.location, !loc.isEmpty {
                            Text(loc).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                        }
                    }
                }
                Spacer()
            }

            Button { selectedInterviewId = iv.id; DispatchQueue.main.async { showDetail = true } } label: {
                Text("View Details").font(PlagitFont.captionMedium()).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 10)
                    .background(Capsule().fill(Color.plagitTeal))
            }
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
    }

    // MARK: - Empty

    private var emptyState: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack {
                Circle().fill(Color.plagitTealLight).frame(width: 48, height: 48)
                Image(systemName: "calendar").font(.system(size: 20, weight: .medium)).foregroundColor(.plagitTeal)
            }
            VStack(spacing: PlagitSpacing.xs) {
                Text("No interviews yet").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                Text("When employers schedule interviews, they'll appear here.").font(PlagitFont.caption()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center)
            }
        }.padding(.horizontal, PlagitSpacing.xxl)
    }
}
