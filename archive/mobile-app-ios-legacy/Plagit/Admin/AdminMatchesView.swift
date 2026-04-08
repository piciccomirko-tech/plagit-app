//
//  AdminMatchesView.swift
//  Plagit
//
//  Admin panel: view all matches, feedback, and match stats.
//

import SwiftUI

struct AdminMatchesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var vm = AdminMatchesViewModel()

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                tabRow
                filterRow

                if vm.isLoading {
                    Spacer(); ProgressView().tint(.plagitTeal); Spacer()
                } else if let error = vm.errorMessage {
                    Spacer()
                    VStack(spacing: PlagitSpacing.md) {
                        Text(error).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                        Button { Task { await vm.loadAll() } } label: { Text("Retry").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal) }
                    }
                    Spacer()
                } else {
                    switch vm.selectedTab {
                    case "Matches": matchesList
                    case "Notifications": notifHistoryList
                    case "Feedback": feedbackList
                    case "Stats": statsView
                    default: matchesList
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .task { await vm.loadAll() }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36)
            }
            Spacer()
            Text("Match Management").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.sm)
    }

    // MARK: - Tab Row

    private var tabRow: some View {
        HStack(spacing: PlagitSpacing.sm) {
            ForEach(vm.tabs, id: \.self) { tab in
                let active = vm.selectedTab == tab
                Button { withAnimation { vm.selectedTab = tab } } label: {
                    Text(tab).font(PlagitFont.captionMedium())
                        .foregroundColor(active ? .white : .plagitSecondary)
                        .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm)
                        .background(Capsule().fill(active ? Color.plagitTeal : Color.plagitSurface))
                }
            }
            Spacer()
        }
        .padding(.horizontal, PlagitSpacing.xl).padding(.vertical, PlagitSpacing.sm)
    }

    // MARK: - Filters

    private var filterRow: some View {
        VStack(spacing: PlagitSpacing.sm) {
            if vm.selectedTab == "Matches" {
                HStack(spacing: PlagitSpacing.sm) {
                    Menu {
                        ForEach(vm.roleFilters, id: \.self) { r in
                            Button(r) { vm.roleFilter = r == "All" ? "" : r }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(vm.roleFilter.isEmpty ? "Role" : vm.roleFilter).font(PlagitFont.caption())
                            Image(systemName: "chevron.down").font(.system(size: 9))
                        }
                        .foregroundColor(.plagitSecondary)
                        .padding(.horizontal, PlagitSpacing.md).padding(.vertical, PlagitSpacing.xs + 2)
                        .background(Capsule().fill(Color.plagitSurface))
                    }

                    Menu {
                        ForEach(vm.jobTypeFilters, id: \.self) { t in
                            Button(t) { vm.jobTypeFilter = t == "All" ? "" : t }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(vm.jobTypeFilter.isEmpty ? "Job Type" : vm.jobTypeFilter).font(PlagitFont.caption())
                            Image(systemName: "chevron.down").font(.system(size: 9))
                        }
                        .foregroundColor(.plagitSecondary)
                        .padding(.horizontal, PlagitSpacing.md).padding(.vertical, PlagitSpacing.xs + 2)
                        .background(Capsule().fill(Color.plagitSurface))
                    }

                    Menu {
                        ForEach(vm.statusFilters, id: \.self) { s in
                            Button(s.capitalized) { vm.statusFilter = s == "All" ? "" : s }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(vm.statusFilter.isEmpty ? "Status" : vm.statusFilter.capitalized).font(PlagitFont.caption())
                            Image(systemName: "chevron.down").font(.system(size: 9))
                        }
                        .foregroundColor(.plagitSecondary)
                        .padding(.horizontal, PlagitSpacing.md).padding(.vertical, PlagitSpacing.xs + 2)
                        .background(Capsule().fill(Color.plagitSurface))
                    }

                    Spacer()

                    Text("\(vm.filteredMatches.count) matches")
                        .font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                }
                .padding(.horizontal, PlagitSpacing.xl)
            }
        }
    }

    // MARK: - Matches List

    private var matchesList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: PlagitSpacing.md) {
                ForEach(vm.filteredMatches) { match in
                    matchRow(match)
                }

                if vm.filteredMatches.isEmpty {
                    VStack(spacing: PlagitSpacing.md) {
                        Image(systemName: "checkmark.seal").font(.system(size: 28)).foregroundColor(.plagitTertiary)
                        Text("No matches found").font(PlagitFont.body()).foregroundColor(.plagitSecondary)
                    }.padding(.top, PlagitSpacing.xxxl)
                }
            }
            .padding(.top, PlagitSpacing.md)
            .padding(.bottom, PlagitSpacing.xxxl)
        }
    }

    private func matchRow(_ m: AdminMatchDTO) -> some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.md) {
            // Candidate → Job header
            HStack(spacing: PlagitSpacing.sm) {
                ProfileAvatarView(photoUrl: m.candidatePhotoUrl, initials: m.candidateInitials ?? "??", hue: m.candidateAvatarHue ?? 0.5, size: 36, verified: m.candidateVerified ?? false)

                VStack(alignment: .leading, spacing: 1) {
                    Text(m.candidateName).font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal).lineLimit(1)
                    if let loc = m.candidateLocation { Text(loc).font(PlagitFont.micro()).foregroundColor(.plagitTertiary).lineLimit(1) }
                }

                Image(systemName: "arrow.right").font(.system(size: 11, weight: .medium)).foregroundColor(.plagitTeal)

                VStack(alignment: .leading, spacing: 1) {
                    Text(m.jobTitle).font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal).lineLimit(1)
                    if let biz = m.businessName { Text(biz).font(PlagitFont.micro()).foregroundColor(.plagitTertiary).lineLimit(1) }
                }

                Spacer()

                // Status pill
                let status = m.matchStatus ?? "pending"
                Text(status.capitalized)
                    .font(PlagitFont.micro())
                    .foregroundColor(statusColor(status))
                    .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 2)
                    .background(Capsule().fill(statusColor(status).opacity(0.1)))
            }

            // Match reason tags
            HStack(spacing: PlagitSpacing.sm) {
                if let role = m.candidateRole {
                    tagPill(role, icon: "briefcase.fill", color: .plagitIndigo)
                }
                if let jt = m.candidateJobType {
                    tagPill(jt, icon: "clock.fill", color: .plagitTeal)
                }
                if let salary = m.jobSalary, !salary.isEmpty {
                    tagPill(salary, icon: "dollarsign", color: .plagitAmber)
                }

                // Distance if both have coordinates
                if let cLat = m.candidateLat, let cLng = m.candidateLng, let jLat = m.jobLat, let jLng = m.jobLng {
                    let dist = haversineDistance(lat1: cLat, lng1: cLng, lat2: jLat, lng2: jLng)
                    tagPill(String(format: "%.1f km", dist), icon: "location", color: .plagitAmber)
                }
            }
        }
        .padding(PlagitSpacing.lg)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.lg).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Feedback List

    private var feedbackList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: PlagitSpacing.sm) {
                ForEach(vm.feedback) { fb in
                    feedbackRow(fb)
                }
                if vm.feedback.isEmpty {
                    VStack(spacing: PlagitSpacing.md) {
                        Image(systemName: "star.bubble").font(.system(size: 28)).foregroundColor(.plagitTertiary)
                        Text("No feedback collected yet").font(PlagitFont.body()).foregroundColor(.plagitSecondary)
                    }.padding(.top, PlagitSpacing.xxxl)
                }
            }
            .padding(.top, PlagitSpacing.md)
            .padding(.bottom, PlagitSpacing.xxxl)
        }
    }

    private func feedbackRow(_ fb: AdminFeedbackDTO) -> some View {
        HStack(spacing: PlagitSpacing.md) {
            VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                HStack(spacing: PlagitSpacing.sm) {
                    Text(fb.userName ?? "Unknown").font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal)
                    Text(fb.userType).font(PlagitFont.micro()).foregroundColor(.white)
                        .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 2)
                        .background(Capsule().fill(fb.userType == "candidate" ? Color.plagitTeal : Color.plagitIndigo))
                }
                HStack(spacing: PlagitSpacing.lg) {
                    fbIndicator("Relevant", fb.wasRelevant)
                    fbIndicator("Role OK", fb.roleAccurate)
                    fbIndicator("Type OK", fb.jobTypeAccurate)
                }
            }
            Spacer()
            if let date = fb.createdAt {
                Text(String(date.prefix(10))).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
            }
        }
        .padding(PlagitSpacing.lg)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitCardBackground))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    private func fbIndicator(_ label: String, _ value: Bool?) -> some View {
        HStack(spacing: 3) {
            Image(systemName: value == true ? "checkmark.circle.fill" : value == false ? "xmark.circle.fill" : "minus.circle")
                .font(.system(size: 11)).foregroundColor(value == true ? .plagitOnline : value == false ? .plagitUrgent : .plagitTertiary)
            Text(label).font(PlagitFont.micro()).foregroundColor(.plagitSecondary)
        }
    }

    // MARK: - Stats View

    private var statsView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: PlagitSpacing.lg) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: PlagitSpacing.md) {
                    statCard("Total Matches", "\(vm.stats.totalMatches)", icon: "checkmark.seal.fill", color: .plagitOnline)
                    statCard("Pending", "\(vm.stats.pendingMatches)", icon: "clock.fill", color: .plagitAmber)
                    statCard("Accepted", "\(vm.stats.acceptedMatches)", icon: "checkmark.circle.fill", color: .plagitOnline)
                    statCard("Denied", "\(vm.stats.deniedMatches)", icon: "xmark.circle.fill", color: .plagitUrgent)
                    statCard("Notifications Sent", "\(vm.stats.matchNotificationsSent)", icon: "bell.fill", color: .plagitAmber)
                    statCard("Feedback Collected", "\(vm.stats.totalFeedback)", icon: "star.bubble", color: .plagitIndigo)
                    statCard("Profiled Candidates", "\(vm.stats.profiledCandidates)", icon: "person.fill.checkmark", color: .plagitTeal)
                    statCard("Matchable Jobs", "\(vm.stats.profiledJobs)", icon: "briefcase.fill", color: .plagitIndigo)
                }

                // Interview status section
                VStack(alignment: .leading, spacing: PlagitSpacing.md) {
                    Text("Interview Status").font(PlagitFont.captionMedium()).foregroundColor(.plagitSecondary)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: PlagitSpacing.sm) {
                        statCard("Requested", "\(vm.stats.interviewsRequested)", icon: "calendar.badge.plus", color: .plagitAmber)
                        statCard("Accepted", "\(vm.stats.interviewsAccepted)", icon: "calendar.badge.checkmark", color: .plagitOnline)
                        statCard("Declined", "\(vm.stats.interviewsDeclined)", icon: "calendar.badge.minus", color: .plagitUrgent)
                        statCard("Completed", "\(vm.stats.interviewsCompleted)", icon: "checkmark.square", color: .plagitTeal)
                    }
                }
                .padding(.horizontal, PlagitSpacing.xl)

                if vm.stats.totalFeedback > 0 {
                    let pct = vm.stats.totalFeedback > 0 ? Double(vm.stats.positiveFeedback) / Double(vm.stats.totalFeedback) * 100 : 0
                    VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
                        Text("Match Quality Score").font(PlagitFont.captionMedium()).foregroundColor(.plagitSecondary)
                        HStack {
                            Text(String(format: "%.0f%%", pct)).font(PlagitFont.displayMedium()).foregroundColor(.plagitTeal)
                            Text("positive").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                        }
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4).fill(Color.plagitSurface).frame(height: 8)
                                RoundedRectangle(cornerRadius: 4).fill(Color.plagitTeal).frame(width: geo.size.width * pct / 100, height: 8)
                            }
                        }.frame(height: 8)
                    }
                    .padding(PlagitSpacing.xl)
                    .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
                    .padding(.horizontal, PlagitSpacing.xl)
                }
            }
            .padding(.top, PlagitSpacing.lg)
            .padding(.bottom, PlagitSpacing.xxxl)
        }
    }

    private func statCard(_ title: String, _ value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
            HStack(spacing: PlagitSpacing.xs) {
                Image(systemName: icon).font(.system(size: 13, weight: .medium)).foregroundColor(color)
                Text(title).font(PlagitFont.micro()).foregroundColor(.plagitSecondary)
            }
            Text(value).font(PlagitFont.statNumber()).foregroundColor(.plagitCharcoal)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(PlagitSpacing.lg)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.lg).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
    }

    // MARK: - Helpers

    private func tagPill(_ text: String, icon: String, color: Color) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon).font(.system(size: 9, weight: .medium))
            Text(text).font(PlagitFont.micro()).lineLimit(1)
        }
        .foregroundColor(color)
        .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 3)
        .background(Capsule().fill(color.opacity(0.08)))
    }

    // MARK: - Notification History

    private var notifHistoryList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: PlagitSpacing.sm) {
                ForEach(vm.notifications) { n in
                    HStack(spacing: PlagitSpacing.md) {
                        ZStack {
                            Circle().fill(Color.plagitOnline.opacity(0.1)).frame(width: 36, height: 36)
                            Image(systemName: "checkmark.seal.fill").font(.system(size: 14)).foregroundColor(.plagitOnline)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(n.title).font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal).lineLimit(2)
                            HStack(spacing: PlagitSpacing.sm) {
                                Text(n.recipientName ?? "Unknown").font(PlagitFont.micro()).foregroundColor(.plagitSecondary)
                                Text(n.recipientType ?? "").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                                Text(n.deliveryState).font(PlagitFont.micro())
                                    .foregroundColor(n.deliveryState == "delivered" ? .plagitOnline : .plagitAmber)
                            }
                        }
                        Spacer()
                        if let date = n.createdAt {
                            Text(String(date.prefix(10))).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                        }
                    }
                    .padding(PlagitSpacing.lg)
                    .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitCardBackground))
                    .padding(.horizontal, PlagitSpacing.xl)
                }
                if vm.notifications.isEmpty {
                    VStack(spacing: PlagitSpacing.md) {
                        Image(systemName: "bell.slash").font(.system(size: 28)).foregroundColor(.plagitTertiary)
                        Text("No match notifications sent yet").font(PlagitFont.body()).foregroundColor(.plagitSecondary)
                    }.padding(.top, PlagitSpacing.xxxl)
                }
            }
            .padding(.top, PlagitSpacing.md)
            .padding(.bottom, PlagitSpacing.xxxl)
        }
    }

    // MARK: - Helpers

    private func statusColor(_ status: String) -> Color {
        switch status {
        case "accepted": return .plagitOnline
        case "denied": return .plagitUrgent
        default: return .plagitAmber
        }
    }

    private func haversineDistance(lat1: Double, lng1: Double, lat2: Double, lng2: Double) -> Double {
        let R = 6371.0
        let dLat = (lat2 - lat1) * .pi / 180
        let dLng = (lng2 - lng1) * .pi / 180
        let a = sin(dLat / 2) * sin(dLat / 2) + cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) * sin(dLng / 2) * sin(dLng / 2)
        return R * 2 * atan2(sqrt(a), sqrt(1 - a))
    }
}
