//
//  BusinessMatchesView.swift
//  Plagit
//
//  Shows candidates matching a specific job's role + employment type.
//  Accept opens the candidate profile; Deny dismisses the match.
//

import SwiftUI

struct BusinessMatchesView: View {
    @Environment(\.dismiss) private var dismiss
    let jobId: String
    let jobTitle: String
    @State private var matches: [NearbyCandidateDTO] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var dismissed: Set<String> = []
    @State private var showFeedback = false
    @State private var feedbackCandId: String?

    private var visible: [NearbyCandidateDTO] {
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
                        Text(L10n.t("no_matches_biz_hint"))
                            .font(PlagitFont.body()).foregroundColor(.plagitSecondary)
                            .multilineTextAlignment(.center).padding(.horizontal, PlagitSpacing.xxl)
                    }
                    Spacer()
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: PlagitSpacing.md) {
                            Text("\(visible.count) \(L10n.t("matching_candidates")) — \(jobTitle)")
                                .font(PlagitFont.captionMedium())
                                .foregroundColor(.plagitSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, PlagitSpacing.xl)
                                .padding(.top, PlagitSpacing.md)

                            ForEach(visible) { cand in
                                candidateMatchCard(cand)
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
            if let cid = feedbackCandId {
                MatchFeedbackView(matchId: cid, isBusiness: true)
            }
        }
    }

    private func load() async {
        isLoading = true; errorMessage = nil
        do {
            matches = try await BusinessAPIService.shared.fetchJobMatches(jobId: jobId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func loadDismissed() {
        // Denied matches filtered by backend
    }

    private func acceptMatch(_ cand: NearbyCandidateDTO) {
        guard let matchId = cand.matchId else { return }
        Task { try? await BusinessAPIService.shared.updateMatchStatus(matchId: matchId, status: "accepted") }
    }

    private func denyMatch(_ cand: NearbyCandidateDTO) {
        guard let matchId = cand.matchId else { return }
        _ = withAnimation(.easeOut(duration: 0.3)) {
            dismissed.insert(cand.id)
        }
        Task { try? await BusinessAPIService.shared.updateMatchStatus(matchId: matchId, status: "denied") }
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

    private func candidateMatchCard(_ cand: NearbyCandidateDTO) -> some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.md) {
            // Header
            HStack(spacing: PlagitSpacing.md) {
                ProfileAvatarView(
                    photoUrl: cand.photoUrl,
                    initials: cand.initials ?? "—",
                    hue: cand.avatarHue,
                    size: 48,
                    verified: cand.isVerified
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(cand.name).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal).lineLimit(1)
                    if let role = cand.role, !role.isEmpty {
                        Text(role).font(PlagitFont.caption()).foregroundColor(.plagitSecondary).lineLimit(1)
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

            // Tags
            HStack(spacing: PlagitSpacing.sm) {
                if let role = cand.role {
                    tagPill(role, icon: "briefcase.fill", color: .plagitIndigo)
                }
                if let jt = cand.jobType {
                    tagPill(jt, icon: "clock.fill", color: .plagitTeal)
                }
                if let loc = cand.location, !loc.isEmpty {
                    tagPill(loc, icon: "mappin", color: .plagitSecondary)
                }
                if let dist = cand.distanceKm {
                    tagPill(String(format: "%.1f km", dist), icon: "location", color: .plagitAmber)
                }
                if cand.availableToRelocate == true {
                    tagPill("Relocate", icon: "globe.americas.fill", color: .plagitIndigo)
                }
            }

            if let exp = cand.experience, !exp.isEmpty {
                Text(exp).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
            }

            // Accept / Deny + action buttons
            HStack(spacing: PlagitSpacing.md) {
                NavigationLink {
                    BusinessRealCandidateProfileView(candidateId: cand.id)
                        .navigationBarHidden(true)
                        .onDisappear {
                            feedbackCandId = cand.id
                            showFeedback = true
                        }
                } label: {
                    HStack(spacing: PlagitSpacing.xs) {
                        Image(systemName: "checkmark").font(.system(size: 12, weight: .bold))
                        Text("Accept").font(PlagitFont.captionMedium())
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, PlagitSpacing.xl)
                    .padding(.vertical, PlagitSpacing.sm + 2)
                    .background(Capsule().fill(Color.plagitTeal))
                }

                Button { denyMatch(cand) } label: {
                    HStack(spacing: PlagitSpacing.xs) {
                        Image(systemName: "xmark").font(.system(size: 12, weight: .bold))
                        Text("Deny").font(PlagitFont.captionMedium())
                    }
                    .foregroundColor(.plagitUrgent)
                    .padding(.horizontal, PlagitSpacing.xl)
                    .padding(.vertical, PlagitSpacing.sm + 2)
                    .background(Capsule().fill(Color.plagitUrgent.opacity(0.08)))
                }

                Spacer()

                Button { startChat(cand) } label: {
                    Image(systemName: "bubble.left").font(.system(size: 14, weight: .medium)).foregroundColor(.plagitIndigo)
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

    private func startChat(_ cand: NearbyCandidateDTO) {
        Task {
            _ = try? await BusinessAPIService.shared.startConversation(candidateId: cand.id)
        }
    }
}
