//
//  BusinessRealJobsView.swift
//  Plagit
//
//  Real business jobs list backed by GET /business/jobs + POST /business/jobs.
//

import SwiftUI

struct BusinessRealJobsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var jobs: [BusinessJobDTO] = []
    @State private var isLoading = true
    @State private var loadError: String?
    @State private var selectedFilter = "All"
    @State private var showPostJob = false
    @State private var showJobDetail = false
    @State private var selectedJobId: String?
    @State private var showSubscription = false

    private var activeJobCount: Int { jobs.filter { $0.status == "active" }.count }
    private var atJobLimit: Bool { activeJobCount >= FeatureGate.jobPostLimit }

    private let filters = ["All", "active", "paused", "closed", "draft"]
    private var filterLabels: [String: String] {
        ["All": L10n.all, "active": L10n.jobStatus("active"), "paused": L10n.jobStatus("paused"), "closed": L10n.jobStatus("closed"), "draft": L10n.jobStatus("draft")]
    }

    private var filteredJobs: [BusinessJobDTO] {
        if selectedFilter == "All" { return jobs }
        return jobs.filter { $0.status == selectedFilter }
    }

    private func statusColor(_ s: String) -> Color {
        switch s {
        case "active": return .plagitOnline
        case "paused": return .plagitAmber
        case "closed": return .plagitTertiary
        case "draft": return .plagitIndigo
        default: return .plagitSecondary
        }
    }

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar
                filterChips.padding(.top, PlagitSpacing.xs)

                if isLoading {
                    Spacer(); ProgressView().tint(.plagitTeal); Spacer()
                } else if let error = loadError {
                    Spacer()
                    VStack(spacing: PlagitSpacing.md) {
                        Image(systemName: "wifi.exclamationmark").font(.system(size: 32)).foregroundColor(.plagitTertiary)
                        Text(error).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                        Button { Task { await load() } } label: { Text("Retry").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal) }
                    }.padding(PlagitSpacing.xxl)
                    Spacer()
                } else if filteredJobs.isEmpty {
                    Spacer(); emptyState; Spacer()
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: PlagitSpacing.md) {
                            if atJobLimit && FeatureGate.jobPostLimit < .max {
                                BusinessLimitCard(current: activeJobCount, limit: FeatureGate.jobPostLimit, feature: .unlimitedJobs, showSubscription: $showSubscription)
                                    .padding(.horizontal, PlagitSpacing.xl)
                            }
                            ForEach(filteredJobs) { job in jobCard(job) }
                        }.padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.xxxl)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showPostJob) { BusinessRealPostJobView(onJobCreated: { Task { await load() } }).navigationBarHidden(true) }
        .navigationDestination(isPresented: $showJobDetail) {
            BusinessRealJobDetailView(jobId: selectedJobId ?? "").navigationBarHidden(true)
        }
        .navigationDestination(isPresented: $showSubscription) {
            BusinessSubscriptionView().navigationBarHidden(true)
        }
        .task { await load() }
    }

    private func load() async {
        isLoading = true; loadError = nil
        do { jobs = try await BusinessAPIService.shared.fetchJobs() } catch { loadError = error.localizedDescription }
        isLoading = false
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: { Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36) }
            Spacer()
            Text("Jobs").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
            Spacer()
            Button {
                if atJobLimit { showSubscription = true }
                else { showPostJob = true }
            } label: {
                Image(systemName: atJobLimit ? "lock.fill" : "plus").font(.system(size: 18, weight: .medium)).foregroundColor(atJobLimit ? .plagitAmber : .plagitTeal)
            }
        }.padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.lg)
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PlagitSpacing.sm) {
                ForEach(filters, id: \.self) { f in
                    let active = selectedFilter == f
                    let count = f == "All" ? jobs.count : jobs.filter { $0.status == f }.count
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

    private func jobCard(_ job: BusinessJobDTO) -> some View {
        let sc = statusColor(job.status)
        return Button { selectedJobId = job.id; DispatchQueue.main.async { showJobDetail = true } } label: {
            VStack(alignment: .leading, spacing: PlagitSpacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                        HStack(spacing: PlagitSpacing.sm) {
                            Text(job.title).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                            Text(L10n.jobStatus(job.status)).font(PlagitFont.micro()).foregroundColor(sc).padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 3).background(Capsule().fill(sc.opacity(0.08)))
                        }
                        if let loc = job.location { Text(loc).font(PlagitFont.caption()).foregroundColor(.plagitSecondary) }
                        HStack(spacing: PlagitSpacing.sm) {
                            if let sal = job.salary { Text(sal).font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal) }
                            if let type = job.employmentType { Text(L10n.employmentType(type)).font(PlagitFont.micro()).foregroundColor(.plagitTeal) }
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: PlagitSpacing.sm) {
                        HStack(spacing: PlagitSpacing.lg) {
                            if let views = job.views, views > 0 {
                                VStack(spacing: 2) {
                                    Image(systemName: "eye").font(.system(size: 12, weight: .medium)).foregroundColor(.plagitTertiary)
                                    Text("\(views)").font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal)
                                }
                            }
                            if let saves = job.saveCount, saves > 0 {
                                VStack(spacing: 2) {
                                    Image(systemName: "bookmark").font(.system(size: 12, weight: .medium)).foregroundColor(.plagitTertiary)
                                    Text("\(saves)").font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal)
                                }
                            }
                            VStack(spacing: 2) {
                                Image(systemName: "person.2").font(.system(size: 12, weight: .medium)).foregroundColor(.plagitTeal)
                                Text("\(job.applicantCount ?? 0)").font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal)
                            }
                        }
                    }
                }
            }.padding(PlagitSpacing.xl)
            .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
        }.buttonStyle(.plain)
    }

    private var emptyState: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack { Circle().fill(Color.plagitTealLight).frame(width: 48, height: 48); Image(systemName: "briefcase").font(.system(size: 20, weight: .medium)).foregroundColor(.plagitTeal) }
            Text("No jobs yet").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
            Text("Post your first job to start receiving applicants.").font(PlagitFont.caption()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center)
            Button { showPostJob = true } label: {
                Text("Post a Job").font(PlagitFont.captionMedium()).foregroundColor(.white).padding(.horizontal, PlagitSpacing.xxl).padding(.vertical, PlagitSpacing.md).background(Capsule().fill(Color.plagitTeal))
            }
        }.padding(.horizontal, PlagitSpacing.xxl)
    }
}
