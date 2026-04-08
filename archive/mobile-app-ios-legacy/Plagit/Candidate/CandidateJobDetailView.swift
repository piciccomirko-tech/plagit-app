//
//  CandidateJobDetailView.swift
//  Plagit
//
//  Job detail screen backed by real API data.
//  Loads from GET /candidate/jobs/:id and supports POST /candidate/jobs/:id/apply.
//

import SwiftUI

struct CandidateJobDetailView: View {
    let jobId: String
    @Environment(\.dismiss) private var dismiss

    @State private var job: JobDetailDTO?
    @State private var isLoading = true
    @State private var loadError: String?
    @State private var isApplying = false
    @State private var applied = false
    @State private var applyError: String?

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
                        Text(L10n.retry).font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                    }
                }.padding(PlagitSpacing.xxl)
            } else if let job {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        topBar
                        heroCard(job).padding(.top, PlagitSpacing.lg)
                        detailSections(job).padding(.top, PlagitSpacing.sectionGap)
                        Spacer().frame(height: 120)
                    }
                }

                // Sticky apply button
                VStack(spacing: 0) {
                    Spacer()
                    applyBar(job)
                }
            }
        }
        .navigationBarHidden(true)
        .task { await load() }
    }

    // MARK: - Load

    private func load() async {
        isLoading = true; loadError = nil
        do {
            let detail = try await CandidateAPIService.shared.fetchJobDetail(id: jobId)
            job = detail
            if detail.hasApplied == true { applied = true }
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
            Text(L10n.t("job_details")).font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.xxl).padding(.bottom, PlagitSpacing.lg)
    }

    // MARK: - Hero

    private func heroCard(_ job: JobDetailDTO) -> some View {
        let hue = job.businessAvatarHue ?? job.avatarHue
        return VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
            HStack(spacing: PlagitSpacing.md) {
                ProfileAvatarView(photoUrl: job.businessPhotoUrl, initials: job.businessInitials ?? "?", hue: hue, size: 56, verified: job.businessVerified == true)
                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    Text(job.title).font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
                    Text(job.businessName ?? "Unknown").font(PlagitFont.body()).foregroundColor(.plagitSecondary)
                }
            }

            HStack(spacing: PlagitSpacing.md) {
                if let loc = job.location, !loc.isEmpty {
                    infoPill("mappin", loc)
                }
                if let type = job.employmentType, !type.isEmpty {
                    infoPill("briefcase", L10n.employmentType(type))
                }
                if let salary = job.salary, !salary.isEmpty {
                    infoPill("banknote", salary)
                }
            }

            if job.isFeatured {
                Text(L10n.featured).font(PlagitFont.micro()).foregroundColor(.plagitAmber)
                    .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 3)
                    .background(Capsule().fill(Color.plagitAmber.opacity(0.10)))
            }
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func infoPill(_ icon: String, _ text: String) -> some View {
        HStack(spacing: PlagitSpacing.xs) {
            Image(systemName: icon).font(.system(size: 10, weight: .medium)).foregroundColor(.plagitTeal)
            Text(text).font(PlagitFont.caption()).foregroundColor(.plagitCharcoal)
        }
        .padding(.horizontal, PlagitSpacing.md).padding(.vertical, PlagitSpacing.sm)
        .background(Capsule().fill(Color.plagitTealLight))
    }

    // MARK: - Details

    private func detailSections(_ job: JobDetailDTO) -> some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.sectionGap) {
            // Badges row
            let hasBadges = job.isUrgent == true || (job.numHires ?? 1) > 1
            if hasBadges {
                HStack(spacing: PlagitSpacing.sm) {
                    if job.isUrgent == true {
                        HStack(spacing: PlagitSpacing.xs) {
                            Image(systemName: "bolt.fill").font(.system(size: 10)).foregroundColor(.plagitAmber)
                            Text(L10n.t("urgent_hiring")).font(PlagitFont.micro()).foregroundColor(.plagitAmber)
                        }.padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 3)
                        .background(Capsule().fill(Color.plagitAmber.opacity(0.08)))
                    }
                    if let hires = job.numHires, hires > 1 {
                        Text("\(hires) \(L10n.t("positions"))").font(PlagitFont.micro()).foregroundColor(.plagitTeal)
                            .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 3)
                            .background(Capsule().fill(Color.plagitTealLight))
                    }
                }.padding(.horizontal, PlagitSpacing.xl)
            }

            // Description
            if let desc = job.description, !desc.isEmpty {
                sectionCard(L10n.t("about_role")) { Text(desc).font(PlagitFont.body()).foregroundColor(.plagitCharcoal).lineSpacing(3) }
            }

            // Requirements
            if let reqs = job.requirements, !reqs.isEmpty {
                sectionCard(L10n.t("requirements")) { Text(reqs).font(PlagitFont.body()).foregroundColor(.plagitCharcoal).lineSpacing(3) }
            }

            // Schedule & dates
            let hasSchedule = job.startDate != nil || job.shiftHours != nil
            if hasSchedule {
                sectionCard(L10n.t("schedule")) {
                    VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
                        if let start = job.startDate {
                            infoRow("calendar", L10n.t("start_date"), start)
                        }
                        if let end = job.endDate {
                            infoRow("calendar.badge.clock", L10n.t("end_date"), end)
                        }
                        if let hours = job.shiftHours, !hours.isEmpty {
                            infoRow("clock", L10n.t("shift_hours"), hours)
                        }
                    }
                }
            }

            // Job details card — always shown, collects remaining info
            sectionCard(L10n.t("job_details")) {
                VStack(alignment: .leading, spacing: PlagitSpacing.md) {
                    if let cat = job.category, !cat.isEmpty { infoRow("tag", L10n.t("category"), cat) }
                    if let venue = job.businessVenueType, !venue.isEmpty { infoRow("building.2", L10n.venueType, venue) }
                    if let type = job.employmentType, !type.isEmpty { infoRow("briefcase", L10n.t("employment"), L10n.employmentType(type)) }
                    if let sal = job.salary, !sal.isEmpty { infoRow("banknote", L10n.t("salary"), sal) }
                    if let loc = job.businessLocation, !loc.isEmpty { infoRow("mappin", L10n.t("business_location"), loc) }
                    if let views = job.views, views > 0 { infoRow("eye", L10n.t("job_views"), "\(views)") }
                }
            }

            // About the business
            if job.businessName != nil {
                sectionCard(L10n.t("about_business")) {
                    VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
                        if let venue = job.businessVenueType, !venue.isEmpty {
                            Text(venue).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
                        }
                        if let loc = job.businessLocation, !loc.isEmpty {
                            HStack(spacing: PlagitSpacing.xs) {
                                Image(systemName: "mappin").font(.system(size: 10, weight: .medium)).foregroundColor(.plagitTertiary)
                                Text(loc).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                            }
                        }
                    }
                }
            }
        }
    }

    private func infoRow(_ icon: String, _ label: String, _ value: String) -> some View {
        HStack(spacing: PlagitSpacing.md) {
            Image(systemName: icon).font(.system(size: 12, weight: .medium)).foregroundColor(.plagitTeal).frame(width: 18)
            VStack(alignment: .leading, spacing: 1) {
                Text(label).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                Text(value).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
            }
        }
    }

    private func sectionCard<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.md) {
            Text(title).font(PlagitFont.captionMedium()).foregroundColor(.plagitSecondary)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Apply Bar

    private func applyBar(_ job: JobDetailDTO) -> some View {
        VStack(spacing: 0) {
            Rectangle().fill(Color.plagitDivider.opacity(0.5)).frame(height: 0.5)

            VStack(spacing: PlagitSpacing.sm) {
                if let msg = applyError {
                    Text(msg).font(PlagitFont.caption()).foregroundColor(.plagitUrgent)
                }

                if applied {
                    // Already applied — show status
                    HStack(spacing: PlagitSpacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                        Text(L10n.t("applied"))
                    }
                    .font(PlagitFont.subheadline())
                    .foregroundColor(.plagitOnline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, PlagitSpacing.lg)
                    .background(Capsule().fill(Color.plagitOnline.opacity(0.10)))
                } else {
                    // Not yet applied
                    Button { Task { await applyToJob() } } label: {
                        Group {
                            if isApplying { ProgressView().tint(.white) }
                            else { Text(L10n.t("apply_now")) }
                        }
                        .font(PlagitFont.subheadline())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, PlagitSpacing.lg)
                        .background(Capsule().fill(LinearGradient(colors: [Color.plagitTeal, Color.plagitTealDark], startPoint: .topLeading, endPoint: .bottomTrailing)))
                    }
                    .disabled(isApplying)
                }
            }
            .padding(.horizontal, PlagitSpacing.xl)
            .padding(.top, PlagitSpacing.md)
            .padding(.bottom, PlagitSpacing.xxl)
            .background(Rectangle().fill(.ultraThinMaterial).ignoresSafeArea(edges: .bottom))
        }
    }

    private func applyToJob() async {
        isApplying = true; applyError = nil
        do {
            _ = try await CandidateAPIService.shared.applyToJob(id: jobId)
            applied = true
        } catch {
            applyError = error.localizedDescription
        }
        isApplying = false
    }
}
