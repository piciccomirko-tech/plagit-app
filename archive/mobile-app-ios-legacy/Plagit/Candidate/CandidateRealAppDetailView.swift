//
//  CandidateRealAppDetailView.swift
//  Plagit
//
//  Real application detail backed by CandidateApplicationDTO from the API.
//

import SwiftUI

struct CandidateRealAppDetailView: View {
    let app: CandidateApplicationDTO
    @Environment(\.dismiss) private var dismiss
    @State private var showJobDetail = false
    @State private var showWithdrawAlert = false
    @State private var isWithdrawing = false
    @State private var withdrawError: String?
    @State private var currentStatus: String

    init(app: CandidateApplicationDTO) {
        self.app = app
        _currentStatus = State(initialValue: app.status)
    }

    private func statusColor(_ s: String) -> Color {
        switch s {
        case "applied": return .plagitTeal
        case "under_review", "shortlisted": return .plagitAmber
        case "interview": return .plagitIndigo
        case "offer": return .plagitOnline
        case "rejected", "withdrawn": return .plagitTertiary
        default: return .plagitSecondary
        }
    }

    private func statusLabel(_ s: String) -> String {
        L10n.appStatus(s)
    }

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: PlagitSpacing.sectionGap) {
                        heroCard
                        progressTracker
                        statusContextCard
                        actionsCard
                        Spacer().frame(height: PlagitSpacing.xxxl)
                    }
                    .padding(.top, PlagitSpacing.xs)
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showJobDetail) {
            if let jobId = app.jobId {
                CandidateJobDetailView(jobId: jobId).navigationBarHidden(true)
            }
        }
        .alert("\(L10n.t("withdraw_application"))?", isPresented: $showWithdrawAlert) {
            Button(L10n.cancel, role: .cancel) {}
            Button(L10n.appStatus("withdrawn"), role: .destructive) { Task { await withdraw() } }
        } message: {
            Text(L10n.t("withdraw_confirm"))
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: { Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36) }
            Spacer()
            Text(L10n.t("application")).font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.xxl).padding(.bottom, PlagitSpacing.lg)
    }

    // MARK: - Hero

    private var heroCard: some View {
        let hue = app.businessAvatarHue ?? app.jobAvatarHue ?? 0.5
        let sc = statusColor(currentStatus)

        return VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            HStack(spacing: PlagitSpacing.md) {
                Circle()
                    .fill(LinearGradient(colors: [Color(hue: hue, saturation: 0.45, brightness: 0.90), Color(hue: hue, saturation: 0.55, brightness: 0.75)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 52, height: 52)
                    .overlay(Text(app.businessInitials ?? "?").font(.system(size: 17, weight: .bold, design: .rounded)).foregroundColor(.white))

                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    Text(app.jobTitle ?? "Unknown").font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
                    HStack(spacing: PlagitSpacing.sm) {
                        Text(app.businessName ?? "Unknown").font(PlagitFont.body()).foregroundColor(.plagitSecondary)
                        if app.businessVerified == true { Image(systemName: "checkmark.seal.fill").font(.system(size: 10)).foregroundColor(.plagitVerified) }
                    }
                }
                Spacer()
            }

            HStack(spacing: PlagitSpacing.md) {
                Text(statusLabel(currentStatus)).font(PlagitFont.captionMedium()).foregroundColor(sc)
                    .padding(.horizontal, PlagitSpacing.md).padding(.vertical, PlagitSpacing.xs)
                    .background(Capsule().fill(sc.opacity(0.10)))
                if let loc = app.jobLocation, !loc.isEmpty {
                    HStack(spacing: PlagitSpacing.xs) {
                        Image(systemName: "mappin").font(.system(size: 10, weight: .medium)).foregroundColor(.plagitTeal)
                        Text(loc).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                    }
                }
                if let sal = app.salary, !sal.isEmpty {
                    Text(sal).font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal)
                }
            }
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Progress Tracker

    private var progressTracker: some View {
        let steps = ["applied", "under_review", "interview", "offer"]
        let currentIdx = steps.firstIndex(of: currentStatus) ?? 0
        let sc = statusColor(currentStatus)

        let shortLabels = [L10n.t("step_applied"), L10n.t("step_review"), L10n.t("step_interview"), L10n.t("step_offer")]

        return VStack(alignment: .leading, spacing: PlagitSpacing.md) {
            Text(L10n.t("app_progress")).font(PlagitFont.captionMedium()).foregroundColor(.plagitSecondary)
            HStack(spacing: 0) {
                ForEach(Array(steps.enumerated()), id: \.offset) { idx, step in
                    let isActive = idx == currentIdx
                    let isPast = idx == 0 || idx < currentIdx
                    let dotColor = isActive ? sc : (isPast ? sc.opacity(0.4) : Color.plagitBorder)
                    let textColor: Color = isActive ? sc : (isPast ? .plagitSecondary : .plagitTertiary)
                    let lineColor = idx < currentIdx ? sc.opacity(0.4) : Color.plagitBorder

                    VStack(spacing: PlagitSpacing.xs) {
                        ZStack {
                            Circle().fill(dotColor).frame(width: isActive ? 12 : 8, height: isActive ? 12 : 8)
                            if isActive {
                                Circle().stroke(sc.opacity(0.25), lineWidth: 3).frame(width: 20, height: 20)
                            }
                        }.frame(width: 20, height: 20)
                        Text(shortLabels[idx]).font(PlagitFont.micro()).foregroundColor(textColor).lineLimit(1).fixedSize()
                    }
                    if idx < steps.count - 1 { Rectangle().fill(lineColor).frame(height: 2).frame(maxWidth: .infinity) }
                }
            }
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Status Context

    private var statusContextCard: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.md) {
            if currentStatus == "interview" {
                contextRow("calendar", L10n.t("interview_scheduled_detail"), L10n.t("interview_check_detail"), .plagitIndigo)
            } else if currentStatus == "under_review" || currentStatus == "shortlisted" {
                contextRow("eye", L10n.appStatus("under_review"), L10n.t("employer_reviewing"), .plagitAmber)
            } else if currentStatus == "offer" {
                contextRow("gift", L10n.t("offer_received"), L10n.t("offer_congrats"), .plagitOnline)
            } else if currentStatus == "applied" {
                contextRow("clock", L10n.t("app_submitted"), L10n.t("employer_will_review"), .plagitTeal)
            } else if currentStatus == "withdrawn" {
                contextRow("xmark.circle", L10n.appStatus("withdrawn"), L10n.t("withdraw_confirm"), .plagitTertiary)
            } else if currentStatus == "rejected" {
                contextRow("xmark.circle", L10n.appStatus("rejected"), L10n.t("withdraw_confirm"), .plagitTertiary)
            }

            if let err = withdrawError {
                Text(err).font(PlagitFont.caption()).foregroundColor(.plagitUrgent)
            }
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func contextRow(_ icon: String, _ title: String, _ subtitle: String, _ color: Color) -> some View {
        HStack(spacing: PlagitSpacing.md) {
            ZStack {
                Circle().fill(color.opacity(0.10)).frame(width: 36, height: 36)
                Image(systemName: icon).font(.system(size: 14, weight: .medium)).foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                Text(subtitle).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
            }
        }
    }

    // MARK: - Actions

    private var actionsCard: some View {
        VStack(spacing: PlagitSpacing.md) {
            if app.jobId != nil {
                Button { showJobDetail = true } label: {
                    actionRow("briefcase", L10n.t("view_job_listing"), .plagitTeal)
                }
            }

            if currentStatus != "withdrawn" && currentStatus != "rejected" {
                Button { showWithdrawAlert = true } label: {
                    actionRow("xmark.circle", L10n.t("withdraw_application"), .plagitUrgent)
                }
            }
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func actionRow(_ icon: String, _ label: String, _ color: Color) -> some View {
        HStack(spacing: PlagitSpacing.md) {
            Image(systemName: icon).font(.system(size: 14, weight: .medium)).foregroundColor(color)
            Text(label).font(PlagitFont.body()).foregroundColor(color)
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 11, weight: .medium)).foregroundColor(.plagitTertiary)
        }
    }

    // MARK: - Withdraw

    private func withdraw() async {
        isWithdrawing = true; withdrawError = nil
        do {
            try await CandidateAPIService.shared.withdrawApplication(id: app.id)
            currentStatus = "withdrawn"
        } catch { withdrawError = error.localizedDescription }
        isWithdrawing = false
    }
}
