//
//  BusinessRealJobDetailView.swift
//  Plagit
//
//  Real job detail + applicants for business, backed by GET /business/jobs/:id + /business/jobs/:id/applicants.
//

import SwiftUI

struct BusinessRealJobDetailView: View {
    let jobId: String
    @Environment(\.dismiss) private var dismiss
    @State private var job: BusinessJobDTO?
    @State private var applicants: [BusinessApplicantDTO] = []
    @State private var isLoading = true
    @State private var loadError: String?
    @State private var selectedTab = 0
    @State private var showScheduleInterview = false
    @State private var showCandidateProfile = false
    @State private var selectedCandidateId: String?
    @State private var selectedAppForInterview: BusinessApplicantDTO?
    @State private var isUpdatingStatus = false
    @State private var toastMessage: String?
    @State private var toastIsError = false
    @State private var showSubscription = false

    private func statusColor(_ s: String) -> Color {
        switch s { case "applied": return .plagitTeal; case "under_review","shortlisted": return .plagitAmber; case "interview": return .plagitIndigo; case "offer": return .plagitOnline; case "rejected","withdrawn": return .plagitTertiary; default: return .plagitSecondary }
    }
    private func statusLabel(_ s: String) -> String {
        L10n.appStatus(s)
    }

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar
                if isLoading { Spacer(); ProgressView().tint(.plagitTeal); Spacer()
                } else if let error = loadError {
                    Spacer()
                    VStack(spacing: PlagitSpacing.md) { Text(error).font(PlagitFont.caption()).foregroundColor(.plagitSecondary); Button { Task { await load() } } label: { Text("Retry").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal) } }.padding(PlagitSpacing.xxl)
                    Spacer()
                } else if let job {
                    tabSelector
                    if selectedTab == 0 { jobDetailContent(job) } else { applicantsContent }
                }
            }
        }
        .overlay(alignment: .bottom) {
            if let msg = toastMessage {
                HStack(spacing: PlagitSpacing.sm) {
                    Image(systemName: toastIsError ? "exclamationmark.triangle" : "checkmark.circle.fill")
                        .font(.system(size: 13, weight: .medium))
                    Text(msg).font(PlagitFont.captionMedium()).lineLimit(2)
                }
                .foregroundColor(.white)
                .padding(.horizontal, PlagitSpacing.xl).padding(.vertical, PlagitSpacing.md)
                .background(Capsule().fill(toastIsError ? Color.plagitUrgent : Color.plagitOnline))
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                .padding(.bottom, PlagitSpacing.xxl)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: toastMessage)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showSubscription) {
            BusinessSubscriptionView().navigationBarHidden(true)
        }
        .navigationDestination(isPresented: $showScheduleInterview) {
            if let app = selectedAppForInterview {
                BusinessRealScheduleInterviewView(applicationId: app.id, candidateName: app.candidateName ?? "Candidate", jobTitle: job?.title ?? "Job").navigationBarHidden(true)
            }
        }
        .navigationDestination(isPresented: $showCandidateProfile) {
            if let id = selectedCandidateId {
                BusinessRealCandidateProfileView(candidateId: id).navigationBarHidden(true)
            }
        }
        .task { await load() }
    }

    private func load() async {
        isLoading = true; loadError = nil
        do {
            async let j = BusinessAPIService.shared.fetchJob(id: jobId)
            async let a = BusinessAPIService.shared.fetchApplicants(jobId: jobId)
            (job, applicants) = try await (j, a)
        } catch { loadError = error.localizedDescription }
        isLoading = false
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: { Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36) }
            Spacer(); Text(job?.title ?? "Job").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal); Spacer()
            Color.clear.frame(width: 36, height: 36)
        }.padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.lg)
    }

    private var tabSelector: some View {
        HStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { selectedTab = 0 }
            } label: {
                Text(L10n.t("job_details")).font(PlagitFont.captionMedium())
                    .foregroundColor(selectedTab == 0 ? .plagitTeal : .plagitSecondary)
                    .frame(maxWidth: .infinity).padding(.vertical, PlagitSpacing.md)
                    .overlay(alignment: .bottom) { if selectedTab == 0 { Rectangle().fill(Color.plagitTeal).frame(height: 2) } }
            }

            Button {
                withAnimation(.easeInOut(duration: 0.2)) { selectedTab = 1 }
            } label: {
                Text("\(L10n.t("applicants")) (\(applicants.count))").font(PlagitFont.captionMedium())
                    .foregroundColor(selectedTab == 1 ? .plagitTeal : .plagitSecondary)
                    .frame(maxWidth: .infinity).padding(.vertical, PlagitSpacing.md)
                    .overlay(alignment: .bottom) { if selectedTab == 1 { Rectangle().fill(Color.plagitTeal).frame(height: 2) } }
            }
        }.padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Job Detail Tab

    private func jobDetailContent(_ job: BusinessJobDTO) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: PlagitSpacing.sectionGap) {
                infoCard(job)
                statsCard(job)
                if let desc = job.description, !desc.isEmpty { textSection(L10n.t("about_role"), desc) }
                if let reqs = job.requirements, !reqs.isEmpty { textSection(L10n.t("requirements"), reqs) }
                jobActionsCard(job)
                Spacer().frame(height: PlagitSpacing.xxxl)
            }.padding(.top, PlagitSpacing.lg)
        }
    }

    private func textSection(_ title: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
            Text(title).font(PlagitFont.captionMedium()).foregroundColor(.plagitTertiary)
            Text(text).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
        }
        .padding(PlagitSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    @State private var isUpdatingJob = false

    private func jobActionsCard(_ job: BusinessJobDTO) -> some View {
        VStack(spacing: PlagitSpacing.sm) {
            if job.status == "active" {
                jobActionBtn(L10n.t("pause_job"), icon: "pause.circle", color: .plagitAmber) {
                    await updateJobStatus("paused")
                }
                jobActionBtn(L10n.t("close_job"), icon: "xmark.circle", color: .plagitUrgent) {
                    await updateJobStatus("closed")
                }
            }
            if job.status == "paused" {
                jobActionBtn(L10n.t("resume_job"), icon: "play.circle", color: .plagitOnline) {
                    await updateJobStatus("active")
                }
                jobActionBtn(L10n.t("close_job"), icon: "xmark.circle", color: .plagitUrgent) {
                    await updateJobStatus("closed")
                }
            }
            if job.status == "closed" {
                jobActionBtn(L10n.t("reopen_job"), icon: "arrow.clockwise.circle", color: .plagitTeal) {
                    await updateJobStatus("active")
                }
            }
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func jobActionBtn(_ label: String, icon: String, color: Color, action: @escaping () async -> Void) -> some View {
        Button { Task { await action() } } label: {
            HStack(spacing: PlagitSpacing.sm) {
                Image(systemName: icon).font(.system(size: 16, weight: .medium)).foregroundColor(color)
                Text(label).font(PlagitFont.captionMedium()).foregroundColor(color)
                Spacer()
                if isUpdatingJob { ProgressView().tint(color) }
                else { Image(systemName: "chevron.right").font(.system(size: 10, weight: .medium)).foregroundColor(.plagitTertiary) }
            }
            .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.md)
            .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(color.opacity(0.04)))
        }.disabled(isUpdatingJob)
    }

    private func showToast(_ message: String, isError: Bool = false) {
        toastMessage = message
        toastIsError = isError
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { toastMessage = nil }
    }

    private func updateJobStatus(_ status: String) async {
        isUpdatingJob = true
        do {
            job = try await BusinessAPIService.shared.updateJob(id: jobId, fields: ["status": status])
            showToast("Job \(L10n.jobStatus(status).lowercased())")
        } catch {
            showToast("Could not update job status", isError: true)
        }
        isUpdatingJob = false
    }

    private func infoCard(_ job: BusinessJobDTO) -> some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
                if let loc = job.location { infoPill("mappin", loc) }
                HStack(spacing: PlagitSpacing.sm) {
                    if let type = job.employmentType { infoPill("briefcase", L10n.employmentType(type)) }
                    if let sal = job.salary { infoPill("banknote", sal) }
                }
            }
            if let cat = job.category { HStack(spacing: PlagitSpacing.sm) { Text("\(L10n.t("category")):").font(PlagitFont.caption()).foregroundColor(.plagitTertiary); Text(cat).font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal) } }
            HStack(spacing: PlagitSpacing.sm) {
                Text("\(L10n.t("status")):").font(PlagitFont.caption()).foregroundColor(.plagitTertiary)
                let sc = statusColor(job.status)
                Text(L10n.jobStatus(job.status)).font(PlagitFont.captionMedium()).foregroundColor(sc).padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 3).background(Capsule().fill(sc.opacity(0.08)))
            }
        }.padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func infoPill(_ icon: String, _ text: String) -> some View {
        HStack(spacing: PlagitSpacing.xs) {
            Image(systemName: icon).font(.system(size: 10, weight: .medium)).foregroundColor(.plagitTeal)
            Text(text).font(PlagitFont.caption()).foregroundColor(.plagitCharcoal).lineLimit(1)
        }
        .padding(.horizontal, PlagitSpacing.md).padding(.vertical, PlagitSpacing.sm)
        .background(Capsule().fill(Color.plagitTealLight))
    }

    private func statsCard(_ job: BusinessJobDTO) -> some View {
        HStack(spacing: PlagitSpacing.lg) {
            statItem("\(job.applicantCount ?? 0)", L10n.t("applicants"))
            statItem("\(job.views ?? 0)", L10n.t("views"))
            statItem("\(job.saveCount ?? 0)", L10n.t("saves"))
            statItem(job.isFeatured ? L10n.t("yes") : L10n.t("no"), L10n.featured)
        }.padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func statItem(_ n: String, _ label: String) -> some View {
        VStack(spacing: PlagitSpacing.xs) { Text(n).font(PlagitFont.headline()).foregroundColor(.plagitCharcoal); Text(label).font(PlagitFont.micro()).foregroundColor(.plagitSecondary) }.frame(maxWidth: .infinity)
    }

    // MARK: - Applicants Tab

    private var applicantsContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            if applicants.isEmpty {
                VStack(spacing: PlagitSpacing.lg) {
                    Image(systemName: "person.2").font(.system(size: 32)).foregroundColor(.plagitTertiary)
                    Text(L10n.t("no_applicants")).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                    Text(L10n.t("no_applicants_desc")).font(PlagitFont.caption()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center)
                }.padding(.top, PlagitSpacing.xxxl * 2).padding(.horizontal, PlagitSpacing.xxl)
            } else {
                VStack(spacing: PlagitSpacing.md) {
                    ForEach(applicants) { app in applicantCard(app) }
                }.padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.xxxl)
            }
        }
    }

    private func applicantCard(_ app: BusinessApplicantDTO) -> some View {
        let hue = app.candidateAvatarHue ?? 0.5
        let sc = statusColor(app.status)
        return VStack(alignment: .leading, spacing: PlagitSpacing.md) {
            Button {
                if let cid = app.candidateId { selectedCandidateId = cid; showCandidateProfile = true }
            } label: {
                HStack(spacing: PlagitSpacing.md) {
                    ProfileAvatarView(photoUrl: app.candidatePhotoUrl, initials: app.candidateInitials ?? "—", hue: hue, size: 44, verified: app.candidateVerified == true)
                    VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                        HStack(spacing: PlagitSpacing.sm) {
                            Text(app.candidateName ?? "Unknown").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                            let aflag = CountryFlag.emoji(for: app.candidateNationalityCode)
                            if !aflag.isEmpty { Text(aflag).font(.system(size: 12)) }
                            if app.candidateVerified == true { Image(systemName: "checkmark.seal.fill").font(.system(size: 10)).foregroundColor(.plagitVerified) }
                            Text(statusLabel(app.status)).font(PlagitFont.micro()).foregroundColor(sc).padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 3).background(Capsule().fill(sc.opacity(0.08)))
                        }
                        if let role = app.candidateRole { Text(role).font(PlagitFont.caption()).foregroundColor(.plagitSecondary) }
                        if let exp = app.candidateExperience { Text(exp).font(PlagitFont.micro()).foregroundColor(.plagitTertiary) }
                    }
                    Spacer()
                    Image(systemName: "chevron.right").font(.system(size: 11, weight: .medium)).foregroundColor(.plagitTertiary)
                }
            }.buttonStyle(.plain)

            // Action buttons
            HStack(spacing: PlagitSpacing.sm) {
                if app.status == "applied" || app.status == "under_review" {
                    actionBtn(L10n.t("shortlist"), .plagitTeal) { await updateStatus(app.id, "shortlisted") }
                    actionBtn(L10n.t("reject"), .plagitUrgent) { await updateStatus(app.id, "rejected") }
                }
                if app.status == "shortlisted" {
                    if FeatureGate.hasInterviewScheduling {
                        actionBtn(L10n.t("invite_interview"), .plagitIndigo) { selectedAppForInterview = app; showScheduleInterview = true }
                    } else {
                        Button { showSubscription = true } label: {
                            HStack(spacing: PlagitSpacing.xs) {
                                Image(systemName: "lock.fill").font(.system(size: 10, weight: .medium))
                                Text(L10n.t("invite_interview")).font(PlagitFont.captionMedium())
                            }
                            .foregroundColor(.plagitIndigo)
                            .padding(.horizontal, PlagitSpacing.md).padding(.vertical, PlagitSpacing.sm)
                            .background(Capsule().fill(Color.plagitIndigo.opacity(0.08)))
                        }
                    }
                    actionBtn(L10n.t("reject"), .plagitUrgent) { await updateStatus(app.id, "rejected") }
                }
            }
        }.padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
    }

    private func actionBtn(_ label: String, _ color: Color, action: @escaping () async -> Void) -> some View {
        Button { Task { await action() } } label: {
            Text(label).font(PlagitFont.captionMedium()).foregroundColor(color).padding(.horizontal, PlagitSpacing.md).padding(.vertical, PlagitSpacing.sm).background(Capsule().fill(color.opacity(0.08)))
        }.disabled(isUpdatingStatus)
    }

    private func updateStatus(_ appId: String, _ status: String) async {
        isUpdatingStatus = true
        do {
            try await BusinessAPIService.shared.updateApplicantStatus(applicationId: appId, status: status)
            applicants = try await BusinessAPIService.shared.fetchApplicants(jobId: jobId)
            showToast("Applicant \(L10n.appStatus(status).lowercased())")
        } catch {
            showToast("Could not update applicant", isError: true)
        }
        isUpdatingStatus = false
    }
}
