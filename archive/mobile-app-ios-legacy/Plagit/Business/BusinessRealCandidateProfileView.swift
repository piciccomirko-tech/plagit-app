//
//  BusinessRealCandidateProfileView.swift
//  Plagit
//
//  Real candidate profile view from business side, backed by GET /business/candidates/:id.
//

import SwiftUI

struct BusinessRealCandidateProfileView: View {
    let candidateId: String
    @Environment(\.dismiss) private var dismiss
    @State private var profile: BizCandidateProfileDTO?
    @State private var isLoading = true
    @State private var loadError: String?

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar
                if isLoading { Spacer(); ProgressView().tint(.plagitTeal); Spacer()
                } else if let error = loadError {
                    Spacer(); VStack(spacing: PlagitSpacing.md) { Text(error).font(PlagitFont.caption()).foregroundColor(.plagitSecondary); Button { Task { await load() } } label: { Text("Retry").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal) } }.padding(PlagitSpacing.xxl); Spacer()
                } else if let p = profile {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: PlagitSpacing.sectionGap) {
                            heroCard(p)
                            actionsCard(p)
                            detailCard(p)
                            Spacer().frame(height: PlagitSpacing.xxxl)
                        }.padding(.top, PlagitSpacing.xs)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showChat) {
            BusinessRealChatView(conversationId: chatConvId ?? "").navigationBarHidden(true)
        }
        .navigationDestination(isPresented: $showScheduleInterview) {
            BusinessRealScheduleInterviewView(
                candidateId: candidateId,
                candidateName: profile?.name ?? "Candidate",
                jobTitle: ""
            ).navigationBarHidden(true)
        }
        .task { await load() }
    }

    private func load() async {
        isLoading = true; loadError = nil
        do { profile = try await BusinessAPIService.shared.fetchCandidateProfile(candidateId: candidateId) } catch { loadError = error.localizedDescription }
        isLoading = false
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: { Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36) }
            Spacer(); Text(L10n.t("candidate_profile")).font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal); Spacer(); Color.clear.frame(width: 36, height: 36)
        }.padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.lg)
    }

    private func heroCard(_ p: BizCandidateProfileDTO) -> some View {
        VStack(spacing: PlagitSpacing.xl) {
            HStack(spacing: PlagitSpacing.lg) {
                ProfileAvatarView(photoUrl: p.photoUrl, initials: p.initials ?? "—", hue: p.avatarHue, size: 64, verified: p.isVerified)
                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    Text(p.name).font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
                    if let role = p.role { Text(role).font(PlagitFont.body()).foregroundColor(.plagitSecondary) }
                    if let loc = p.location { HStack(spacing: PlagitSpacing.xs) { Image(systemName: "mappin").font(.system(size: 10, weight: .medium)).foregroundColor(.plagitTeal); Text(loc).font(PlagitFont.caption()).foregroundColor(.plagitTeal) } }
                }; Spacer()
            }
        }.padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    @State private var isShortlisted: Bool = false
    @State private var showChat = false
    @State private var chatConvId: String?
    @State private var showScheduleInterview = false
    @State private var actionToast: String?

    private func actionsCard(_ p: BizCandidateProfileDTO) -> some View {
        VStack(spacing: PlagitSpacing.sm) {
            HStack(spacing: PlagitSpacing.sm) {
                Button {
                    isShortlisted.toggle()
                    var saved = Set(UserDefaults.standard.stringArray(forKey: "biz_shortlist") ?? [])
                    if isShortlisted { saved.insert(p.id) } else { saved.remove(p.id) }
                    UserDefaults.standard.set(Array(saved), forKey: "biz_shortlist")
                    actionToast = isShortlisted ? L10n.t("shortlisted") : L10n.t("removed_shortlist")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { actionToast = nil }
                } label: {
                    HStack(spacing: PlagitSpacing.xs) {
                        Image(systemName: isShortlisted ? "star.fill" : "star").font(.system(size: 14, weight: .medium))
                        Text(isShortlisted ? L10n.t("shortlisted") : L10n.t("shortlist")).font(PlagitFont.captionMedium())
                    }
                    .foregroundColor(isShortlisted ? .plagitAmber : .plagitCharcoal)
                    .frame(maxWidth: .infinity).padding(.vertical, PlagitSpacing.md)
                    .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(isShortlisted ? Color.plagitAmber.opacity(0.08) : Color.plagitSurface))
                }

                Button {
                    Task {
                        if let convId = try? await BusinessAPIService.shared.startConversation(candidateId: candidateId) {
                            chatConvId = convId; DispatchQueue.main.async { showChat = true }
                        }
                    }
                } label: {
                    HStack(spacing: PlagitSpacing.xs) {
                        Image(systemName: "bubble.left").font(.system(size: 14, weight: .medium))
                        Text(L10n.t("message")).font(PlagitFont.captionMedium())
                    }
                    .foregroundColor(.plagitIndigo)
                    .frame(maxWidth: .infinity).padding(.vertical, PlagitSpacing.md)
                    .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitIndigo.opacity(0.06)))
                }
            }

            // Invite to Interview — full width
            Button { showScheduleInterview = true } label: {
                HStack(spacing: PlagitSpacing.sm) {
                    Image(systemName: "calendar.badge.plus").font(.system(size: 14, weight: .medium))
                    Text(L10n.t("invite_interview")).font(PlagitFont.captionMedium())
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity).padding(.vertical, PlagitSpacing.md)
                .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitTeal))
            }
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
        .onAppear {
            let saved = Set(UserDefaults.standard.stringArray(forKey: "biz_shortlist") ?? [])
            isShortlisted = saved.contains(candidateId)
        }
    }

    private func detailCard(_ p: BizCandidateProfileDTO) -> some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            if let nat = p.nationality, !nat.isEmpty {
                row("flag", L10n.t("nationality"), CountryFlag.label(country: nat, code: p.nationalityCode))
            }
            if let loc = p.location, !loc.isEmpty {
                row("mappin", L10n.t("based_in"), CountryFlag.label(country: loc, code: p.countryCode))
            }
            row("clock", L10n.t("experience"), p.experience ?? L10n.t("not_specified"))
            row("globe", L10n.t("languages"), Language.profileLabel(from: p.languages).isEmpty ? (p.languages ?? L10n.t("not_specified")) : Language.profileLabel(from: p.languages))
            row("checkmark.shield", L10n.t("verification"), p.verificationStatus?.capitalized ?? L10n.t("new"))
            if let email = p.email { row("envelope", L10n.t("email"), email) }
            if let phone = p.phone { row("phone", L10n.t("phone"), phone) }
        }.padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func row(_ icon: String, _ label: String, _ value: String) -> some View {
        HStack(spacing: PlagitSpacing.md) {
            Image(systemName: icon).font(.system(size: 13, weight: .medium)).foregroundColor(.plagitTeal).frame(width: 20)
            VStack(alignment: .leading, spacing: 2) { Text(label).font(PlagitFont.micro()).foregroundColor(.plagitTertiary); Text(value).font(PlagitFont.body()).foregroundColor(.plagitCharcoal) }; Spacer()
        }
    }
}
