//
//  BusinessShortlistView.swift
//  Plagit
//
//  Shortlisted candidates view for business.
//

import SwiftUI

struct BusinessShortlistView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var candidates: [BizCandidateProfileDTO] = []
    @State private var isLoading = true
    @State private var showCandidateProfile = false
    @State private var selectedCandidateId: String?

    private var shortlistedIds: [String] {
        UserDefaults.standard.stringArray(forKey: "biz_shortlist") ?? []
    }

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar
                if isLoading {
                    Spacer(); ProgressView().tint(.plagitTeal); Spacer()
                } else if candidates.isEmpty {
                    Spacer(); emptyState; Spacer()
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: PlagitSpacing.md) {
                            ForEach(candidates, id: \.id) { c in candidateCard(c) }
                        }
                        .padding(.horizontal, PlagitSpacing.xl)
                        .padding(.top, PlagitSpacing.lg)
                        .padding(.bottom, PlagitSpacing.xxxl)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showCandidateProfile) {
            BusinessRealCandidateProfileView(candidateId: selectedCandidateId ?? "").navigationBarHidden(true)
        }
        .task { await load() }
    }

    private func load() async {
        isLoading = true
        var loaded: [BizCandidateProfileDTO] = []
        for id in shortlistedIds {
            if let profile = try? await BusinessAPIService.shared.fetchCandidateProfile(candidateId: id) {
                loaded.append(profile)
            }
        }
        candidates = loaded
        isLoading = false
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36)
            }
            Spacer()
            Text("Shortlist").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
            Spacer()
            Text("\(candidates.count)").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 2)
                .background(Capsule().fill(Color.plagitTealLight))
        }
        .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.lg)
    }

    private func candidateCard(_ c: BizCandidateProfileDTO) -> some View {
        Button {
            selectedCandidateId = c.id
            DispatchQueue.main.async { showCandidateProfile = true }
        } label: {
            HStack(spacing: PlagitSpacing.md) {
                ProfileAvatarView(photoUrl: c.photoUrl, initials: c.initials ?? "—", hue: c.avatarHue, size: 48, verified: c.isVerified)
                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    HStack(spacing: 4) {
                        Text(c.name).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                        let flag = CountryFlag.emoji(for: c.nationalityCode)
                        if !flag.isEmpty { Text(flag).font(.system(size: 12)) }
                    }
                    if let role = c.role { Text(role).font(PlagitFont.caption()).foregroundColor(.plagitSecondary) }
                    HStack(spacing: PlagitSpacing.sm) {
                        if let exp = c.experience { Text(exp).font(PlagitFont.micro()).foregroundColor(.plagitTertiary) }
                        if let loc = c.location {
                            let locFlag = CountryFlag.emoji(for: c.countryCode)
                            Text("·").foregroundColor(.plagitTertiary)
                            Text("\(locFlag) \(loc)".trimmingCharacters(in: .whitespaces)).font(PlagitFont.micro()).foregroundColor(.plagitTertiary).lineLimit(1)
                        }
                    }
                }
                Spacer()
                Image(systemName: "star.fill").font(.system(size: 14)).foregroundColor(.plagitAmber)
            }
            .padding(PlagitSpacing.xl)
            .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground)
                .shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
        }.buttonStyle(.plain)
    }

    private var emptyState: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack {
                Circle().fill(Color.plagitAmber.opacity(0.08)).frame(width: 56, height: 56)
                Image(systemName: "star").font(.system(size: 24, weight: .medium)).foregroundColor(.plagitAmber)
            }
            Text("No shortlisted candidates").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
            Text("Shortlist candidates from Nearby, Applicants, or search results.").font(PlagitFont.caption()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center)
        }.padding(.horizontal, PlagitSpacing.xxl)
    }
}
