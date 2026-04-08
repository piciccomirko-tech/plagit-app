//
//  CandidateMatchesView.swift
//  Plagit
//
//  Shows jobs matching the candidate's role + job type.
//  Accept opens the job detail; Deny dismisses the match.
//

import SwiftUI

struct CandidateMatchesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var matches: [FeaturedJobDTO] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var dismissed: Set<String> = []
    @State private var accepted: Set<String> = []
    @State private var showFeedback = false
    @State private var feedbackJobId: String?

    private var visible: [FeaturedJobDTO] {
        matches.filter { !dismissed.contains($0.id) }
    }

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                if isLoading {
                    Spacer(); ProgressView().tint(.plagitTeal); Spacer()
                } else if let error = errorMessage {
                    Spacer()
                    VStack(spacing: PlagitSpacing.md) {
                        Image(systemName: "exclamationmark.triangle").font(.system(size: 28)).foregroundColor(.plagitTertiary)
                        Text(error).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                        Button { Task { await load() } } label: { Text(L10n.retry).font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal) }
                    }
                    Spacer()
                } else if visible.isEmpty {
                    Spacer()
                    VStack(spacing: PlagitSpacing.lg) {
                        Image(systemName: "person.2.slash").font(.system(size: 36)).foregroundColor(.plagitTertiary)
                        Text(L10n.t("no_matches_yet")).font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
                        Text(L10n.t("no_matches_hint"))
                            .font(PlagitFont.body()).foregroundColor(.plagitSecondary)
                            .multilineTextAlignment(.center).padding(.horizontal, PlagitSpacing.xxl)
                    }
                    Spacer()
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: PlagitSpacing.md) {
                            Text("\(visible.count) \(L10n.t("matching_jobs"))")
                                .font(PlagitFont.captionMedium())
                                .foregroundColor(.plagitSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, PlagitSpacing.xl)
                                .padding(.top, PlagitSpacing.md)

                            ForEach(visible) { job in
                                matchCard(job)
                                    .transition(.asymmetric(insertion: .identity, removal: .move(edge: .leading).combined(with: .opacity)))
                            }

                            Spacer().frame(height: PlagitSpacing.xxxl)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            loadDismissed()
            await load()
        }
        .sheet(isPresented: $showFeedback) {
            if let jid = feedbackJobId {
                MatchFeedbackView(matchId: jid, isBusiness: false)
            }
        }
    }

    private func load() async {
        isLoading = true; errorMessage = nil
        do {
            matches = try await CandidateAPIService.shared.fetchMatches()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func loadDismissed() {
        // Denied matches are already filtered out by the backend (status != 'denied')
    }

    private func acceptMatchAction(_ job: FeaturedJobDTO) {
        withAnimation(.easeInOut(duration: 0.3)) {
            accepted.insert(job.id)
        }
        guard let matchId = job.matchId else {
            return
        }
        Task {
            do {
                try await CandidateAPIService.shared.updateMatchStatus(matchId: matchId, status: "accepted")
            } catch {
            }
        }
    }

    private func denyMatch(_ job: FeaturedJobDTO) {
        guard let matchId = job.matchId else { return }
        _ = withAnimation(.easeOut(duration: 0.3)) {
            dismissed.insert(job.id)
        }
        Task { try? await CandidateAPIService.shared.updateMatchStatus(matchId: matchId, status: "denied") }
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36)
            }
            Spacer()
            Text(L10n.t("your_matches")).font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, PlagitSpacing.xl)
        .padding(.top, PlagitSpacing.lg)
        .padding(.bottom, PlagitSpacing.lg)
    }

    private func matchCard(_ job: FeaturedJobDTO) -> some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.md) {
            // Header: avatar + name + match badge
            HStack(spacing: PlagitSpacing.md) {
                ProfileAvatarView(
                    photoUrl: nil,
                    initials: job.businessInitials ?? "—",
                    hue: job.businessAvatarHue ?? 0.5,
                    size: 48,
                    verified: job.businessVerified ?? false
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(job.title).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal).lineLimit(1)
                    if let biz = job.businessName {
                        Text(biz).font(PlagitFont.caption()).foregroundColor(.plagitSecondary).lineLimit(1)
                    }
                }
                Spacer()

                HStack(spacing: PlagitSpacing.xs) {
                    Image(systemName: "checkmark.seal.fill").font(.system(size: 12))
                    Text(L10n.t("match")).font(PlagitFont.micro())
                }
                .foregroundColor(.plagitOnline)
                .padding(.horizontal, PlagitSpacing.sm)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color.plagitOnline.opacity(0.1)))
            }

            // Tags: role + job type + location + international
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: PlagitSpacing.sm) {
                    if let cat = job.category {
                        tagPill(cat, icon: "briefcase.fill", color: .plagitIndigo)
                    }
                    if let type = job.employmentType {
                        tagPill(type, icon: "clock.fill", color: .plagitTeal)
                    }
                    if let loc = job.location, !loc.isEmpty {
                        tagPill(loc, icon: "mappin", color: .plagitSecondary)
                    }
                    if job.openToInternational == true {
                        tagPill("International", icon: "globe.americas.fill", color: .plagitIndigo)
                    }
                }
            }

            // Salary
            if let salary = job.salary, !salary.isEmpty {
                Text(salary).font(PlagitFont.bodyMedium()).foregroundColor(.plagitTeal)
            }

            // Accept / Deny buttons
            if accepted.contains(job.id) {
                // Accepted state
                HStack(spacing: PlagitSpacing.sm) {
                    Image(systemName: "checkmark.circle.fill").font(.system(size: 16, weight: .medium)).foregroundColor(.plagitOnline)
                    Text("Accepted").font(PlagitFont.bodyMedium()).foregroundColor(.plagitOnline)
                    Spacer()
                    if job.isFeatured {
                        HStack(spacing: PlagitSpacing.xs) {
                            Image(systemName: "star.fill").font(.system(size: 10)).foregroundColor(.plagitAmber)
                            Text("Featured").font(PlagitFont.micro()).foregroundColor(.plagitAmber)
                        }
                    }
                }
            } else {
                HStack(spacing: PlagitSpacing.md) {
                    Button { acceptMatchAction(job) } label: {
                        HStack(spacing: PlagitSpacing.xs) {
                            Image(systemName: "checkmark").font(.system(size: 12, weight: .bold))
                            Text("Accept").font(PlagitFont.captionMedium()).fixedSize()
                        }
                        .foregroundColor(.white)
                        .frame(minWidth: 90)
                        .padding(.vertical, PlagitSpacing.sm + 2)
                        .background(Capsule().fill(Color.plagitTeal))
                    }

                    Button { denyMatch(job) } label: {
                        HStack(spacing: PlagitSpacing.xs) {
                            Image(systemName: "xmark").font(.system(size: 12, weight: .bold))
                            Text("Deny").font(PlagitFont.captionMedium()).fixedSize()
                        }
                        .foregroundColor(.plagitUrgent)
                        .frame(minWidth: 80)
                        .padding(.vertical, PlagitSpacing.sm + 2)
                        .background(Capsule().fill(Color.plagitUrgent.opacity(0.08)))
                    }

                    Spacer()

                    if job.isFeatured {
                        HStack(spacing: PlagitSpacing.xs) {
                            Image(systemName: "star.fill").font(.system(size: 10)).foregroundColor(.plagitAmber)
                            Text("Featured").font(PlagitFont.micro()).foregroundColor(.plagitAmber)
                        }
                    }
                }
            }
        }
        .padding(PlagitSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: PlagitRadius.xl)
                .fill(Color.plagitCardBackground)
                .shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY)
        )
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func tagPill(_ text: String, icon: String, color: Color) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon).font(.system(size: 9, weight: .medium))
            Text(text).font(PlagitFont.micro()).lineLimit(1)
        }
        .foregroundColor(color)
        .padding(.horizontal, PlagitSpacing.sm)
        .padding(.vertical, 3)
        .background(Capsule().fill(color.opacity(0.08)))
    }
}
