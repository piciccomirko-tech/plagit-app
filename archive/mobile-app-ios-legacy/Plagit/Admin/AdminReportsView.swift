//
//  AdminReportsView.swift
//  Plagit
//
//  Admin — Reports & Flags (Moderation & Trust Control)
//

import SwiftUI

// MARK: - View

struct AdminReportsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AdminReportsViewModel()
    @State private var showSearch = false
    @State private var showSuspendAlert = false
    @State private var showBanAlert = false

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()

            switch viewModel.loadingState {
            case .idle, .loading:
                ProgressView("Loading reports...").frame(maxWidth: .infinity, maxHeight: .infinity)
            case .error(let message):
                errorView(message)
            case .loaded:
                loadedContent
            }
        }
        .navigationBarHidden(true)
        .animation(.easeInOut(duration: 0.2), value: showSearch)
        .alert("Suspend Account", isPresented: $showSuspendAlert) {
            Button("Suspend", role: .destructive) { }
            Button("Cancel", role: .cancel) {}
        } message: { Text("This will suspend the reported account.") }
        .alert("Ban Account", isPresented: $showBanAlert) {
            Button("Ban", role: .destructive) { }
            Button("Cancel", role: .cancel) {}
        } message: { Text("This will permanently ban the account.") }
        .task { await viewModel.loadReports() }
    }

    // MARK: - Loaded Content
    private var loadedContent: some View {
        VStack(spacing: 0) {
            topBar.background(Color.plagitBackground).zIndex(1)
            if showSearch { searchBar.transition(.move(edge: .top).combined(with: .opacity)) }
            summaryCards.padding(.top, PlagitSpacing.xs)
            filterChips.padding(.top, PlagitSpacing.sm)
            sortRow.padding(.top, PlagitSpacing.sm)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Needs Immediate Attention
                    if viewModel.selectedFilter == "All" && viewModel.searchText.isEmpty && !viewModel.urgentReports.isEmpty {
                        urgentSection.padding(.top, PlagitSpacing.md)
                    }

                    if viewModel.filtered.isEmpty {
                        emptyState.padding(.top, PlagitSpacing.xxxl * 2)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(Array(viewModel.filtered.enumerated()), id: \.element.id) { idx, report in
                                reportRow(report)
                                if idx < viewModel.filtered.count - 1 { Rectangle().fill(Color.plagitDivider).frame(height: 1).padding(.leading, PlagitSpacing.xl + 36 + PlagitSpacing.md) }
                            }
                        }
                        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
                        .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.md).padding(.bottom, PlagitSpacing.xxxl)
                    }
                }
            }
        }
    }

    // MARK: - Error View
    private func errorView(_ message: String) -> some View {
        VStack(spacing: PlagitSpacing.lg) {
            topBar.background(Color.plagitBackground)
            Spacer()
            ZStack { Circle().fill(Color.plagitUrgent.opacity(0.08)).frame(width: 48, height: 48); Image(systemName: "exclamationmark.triangle").font(.system(size: 20, weight: .medium)).foregroundColor(.plagitUrgent) }
            Text(message).font(PlagitFont.body()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center).padding(.horizontal, PlagitSpacing.xxl)
            Button { Task { await viewModel.loadReports() } } label: { Text("Retry").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal).padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm).background(Capsule().fill(Color.plagitTealLight)) }
            Spacer()
        }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button { dismiss() } label: { Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36) }
            Spacer()
            Text("Reports & Flags").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
            Spacer()
            Button { withAnimation { showSearch.toggle(); if !showSearch { viewModel.searchText = "" } } } label: {
                Image(systemName: showSearch ? "xmark" : "magnifyingglass").font(.system(size: 18, weight: .regular)).foregroundColor(.plagitCharcoal)
            }
        }.padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.xxl).padding(.bottom, PlagitSpacing.lg)
    }

    private var searchBar: some View {
        HStack(spacing: PlagitSpacing.md) {
            Image(systemName: "magnifyingglass").font(.system(size: 14, weight: .medium)).foregroundColor(.plagitTertiary)
            TextField("Search reports, users, reasons...", text: $viewModel.searchText).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
            if !viewModel.searchText.isEmpty { Button { viewModel.searchText = "" } label: { Image(systemName: "xmark.circle.fill").font(.system(size: 14)).foregroundColor(.plagitTertiary) } }
        }.padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.md).background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface)).padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Summary Cards
    private var summaryCards: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PlagitSpacing.sm) {
                sumChip("All", "\(viewModel.reports.count)", .plagitCharcoal, "All")
                sumChip("Open", "\(viewModel.countFor("Open"))", .plagitUrgent, "Open")
                sumChip("Urgent", "\(viewModel.countFor("Urgent"))", .plagitUrgent, "Urgent")
                sumChip("Review", "\(viewModel.countFor("Under Review"))", .plagitAmber, "Under Review")
                sumChip("Resolved", "\(viewModel.countFor("Resolved"))", .plagitOnline, "Resolved")
                sumChip("Users", "\(viewModel.countFor("Users"))", .plagitTeal, "Users")
                sumChip("Jobs", "\(viewModel.countFor("Jobs"))", .plagitIndigo, "Jobs")
                sumChip("Messages", "\(viewModel.countFor("Messages"))", .plagitAmber, "Messages")
                sumChip("Repeat", "\(viewModel.countFor("Repeat Offender"))", .plagitUrgent, "Repeat Offender")
            }.padding(.horizontal, PlagitSpacing.xl)
        }
    }

    private func sumChip(_ label: String, _ count: String, _ color: Color, _ filter: String) -> some View {
        Button { withAnimation { viewModel.selectedFilter = filter } } label: {
            VStack(spacing: 2) {
                Text(count).font(PlagitFont.headline()).foregroundColor(color)
                Text(label).font(PlagitFont.micro()).foregroundColor(.plagitSecondary)
            }.frame(width: 62).padding(.vertical, PlagitSpacing.sm).background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
        }
    }

    // MARK: - Filters
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PlagitSpacing.sm) {
                ForEach(viewModel.filters, id: \.self) { f in
                    let isActive = viewModel.selectedFilter == f; let c = viewModel.countFor(f)
                    Button { withAnimation { viewModel.selectedFilter = f } } label: {
                        HStack(spacing: PlagitSpacing.xs) {
                            Text(f).font(PlagitFont.captionMedium())
                            if f != "All" && c > 0 { Text("\(c)").font(PlagitFont.micro()).foregroundColor(isActive ? .white.opacity(0.7) : .plagitTertiary) }
                        }.foregroundColor(isActive ? .white : .plagitSecondary).padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm)
                        .background(Capsule().fill(isActive ? Color.plagitTeal : Color.plagitSurface))
                        .overlay(Capsule().stroke(isActive ? Color.clear : Color.plagitBorder, lineWidth: 0.5))
                    }
                }
            }.padding(.horizontal, PlagitSpacing.xl)
        }
    }

    private var sortRow: some View {
        HStack {
            Text("\(viewModel.filtered.count) reports").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
            Spacer()
            Menu {
                ForEach(viewModel.sortOptions, id: \.self) { o in Button(o) { viewModel.selectedSort = o } }
            } label: {
                HStack(spacing: PlagitSpacing.xs) {
                    Text("Sort: \(viewModel.selectedSort)").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                    Image(systemName: "chevron.down").font(.system(size: 9, weight: .semibold)).foregroundColor(.plagitTeal)
                }
            }
        }.padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Urgent Section

    private var urgentSection: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.md) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 12, weight: .medium)).foregroundColor(.plagitUrgent)
                Text("Needs Immediate Attention").font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
                Text("\(viewModel.urgentReports.count)").font(PlagitFont.micro()).foregroundColor(.white).frame(width: 20, height: 20).background(Circle().fill(Color.plagitUrgent))
                Spacer()
            }

            ForEach(viewModel.urgentReports) { report in
                Menu {
                    urgentReportMenuItems(report)
                } label: {
                    HStack(spacing: PlagitSpacing.md) {
                        ZStack {
                            RoundedRectangle(cornerRadius: PlagitRadius.sm).fill(Color.plagitUrgent.opacity(0.08)).frame(width: 32, height: 32)
                            Image(systemName: typeIcon(report.type)).font(.system(size: 12, weight: .medium)).foregroundColor(.plagitUrgent)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(report.title).font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal).lineLimit(1)
                            Text(report.reportedEntity).font(PlagitFont.micro()).foregroundColor(.plagitSecondary)
                        }
                        Spacer()
                        severityBadge(report.severity)
                        Image(systemName: "chevron.right").font(.system(size: 9, weight: .medium)).foregroundColor(.plagitTertiary)
                    }.padding(.vertical, PlagitSpacing.xs)
                }.buttonStyle(.plain)
            }
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
        .overlay(RoundedRectangle(cornerRadius: PlagitRadius.xl).stroke(Color.plagitUrgent.opacity(0.15), lineWidth: 1))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    @ViewBuilder
    private func urgentReportMenuItems(_ r: AdminReport) -> some View {
        if r.status == "Open" { Button { viewModel.updateStatus(id: r.id, status: "Under Review"); viewModel.assignToMe(id: r.id) } label: { Label("Mark Under Review", systemImage: "eye") } }
        if r.status == "Open" || r.status == "Under Review" {
            Button { viewModel.updateStatus(id: r.id, status: "Resolved") } label: { Label("Resolve", systemImage: "checkmark.circle") }
            Button { viewModel.updateStatus(id: r.id, status: "Dismissed") } label: { Label("Dismiss", systemImage: "xmark.circle") }
        }
        if r.assignedAdmin.isEmpty { Button { viewModel.assignToMe(id: r.id) } label: { Label("Assign to Me", systemImage: "person.badge.plus") } }
        Button { } label: { Label("View Reported Entity", systemImage: "doc.text.magnifyingglass") }
        Button(role: .destructive) { showSuspendAlert = true } label: { Label("Suspend", systemImage: "pause.circle") }
        Button(role: .destructive) { showBanAlert = true } label: { Label("Ban", systemImage: "nosign") }
    }

    // MARK: - Report Row
    private func reportRow(_ report: AdminReport) -> some View {
        Menu {
            if report.status == "Open" { Button { viewModel.updateStatus(id: report.id, status: "Under Review"); viewModel.assignToMe(id: report.id) } label: { Label("Mark Under Review", systemImage: "eye") } }
            if report.status == "Open" || report.status == "Under Review" {
                Button { viewModel.updateStatus(id: report.id, status: "Resolved") } label: { Label("Resolve", systemImage: "checkmark.circle") }
                Button { viewModel.updateStatus(id: report.id, status: "Dismissed") } label: { Label("Dismiss", systemImage: "xmark.circle") }
            }
            if report.assignedAdmin.isEmpty { Button { viewModel.assignToMe(id: report.id) } label: { Label("Assign to Me", systemImage: "person.badge.plus") } }
            Button { } label: { Label("View Reported Entity", systemImage: "doc.text.magnifyingglass") }
            Button { } label: { Label("View Reporter", systemImage: "person") }
            Button { } label: { Label("Warn User", systemImage: "exclamationmark.bubble") }
            Button(role: .destructive) { showSuspendAlert = true } label: { Label("Suspend", systemImage: "pause.circle") }
            Button(role: .destructive) { showBanAlert = true } label: { Label("Ban", systemImage: "nosign") }
            if report.type == "Job" || report.type == "Community" { Button(role: .destructive) { } label: { Label("Remove Content", systemImage: "trash") } }
            Button { } label: { Label("Add Note", systemImage: "note.text") }
        } label: {
            HStack(alignment: .top, spacing: PlagitSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: PlagitRadius.sm).fill(typeColor(report.type).opacity(0.08)).frame(width: 36, height: 36)
                    Image(systemName: typeIcon(report.type)).font(.system(size: 13, weight: .medium)).foregroundColor(typeColor(report.type))
                }

                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    // Title + severity + status
                    HStack(spacing: PlagitSpacing.sm) {
                        Text(report.title).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal).lineLimit(1)
                        severityBadge(report.severity)
                        statusBadge(report.status)
                    }

                    // Entity + type + reason
                    HStack(spacing: PlagitSpacing.sm) {
                        Text(report.reportedEntity).font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal)
                        pill(report.type, typeColor(report.type))
                        pill(report.reason, reasonColor(report.reason))
                    }

                    // Reporter + date
                    HStack(spacing: PlagitSpacing.sm) {
                        Text("By: \(report.reporter)").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                        Text("\u{00B7}").foregroundColor(.plagitTertiary)
                        Text(report.reportDate).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                    }

                    // Indicators
                    HStack(spacing: PlagitSpacing.sm) {
                        if report.previousReports >= 2 {
                            HStack(spacing: 2) {
                                Image(systemName: "exclamationmark.triangle").font(.system(size: 8, weight: .bold)).foregroundColor(.plagitUrgent)
                                Text("Repeat \u{00D7}\(report.previousReports)").font(PlagitFont.micro()).foregroundColor(.plagitUrgent)
                            }.padding(.horizontal, PlagitSpacing.sm - 2).padding(.vertical, 1).background(Capsule().fill(Color.plagitUrgent.opacity(0.08)))
                        }
                        if report.flagCount > 1 {
                            HStack(spacing: 2) { Image(systemName: "flag.fill").font(.system(size: 8, weight: .medium)).foregroundColor(.plagitAmber); Text("\(report.flagCount) flags").font(PlagitFont.micro()).foregroundColor(.plagitAmber) }
                        }
                        if !report.assignedAdmin.isEmpty {
                            Text(report.assignedAdmin).font(PlagitFont.micro()).foregroundColor(.plagitIndigo)
                                .padding(.horizontal, PlagitSpacing.sm - 2).padding(.vertical, 1).background(Capsule().fill(Color.plagitIndigo.opacity(0.06)))
                        } else if report.status == "Open" {
                            Text("Unassigned").font(PlagitFont.micro()).foregroundColor(.plagitAmber)
                                .padding(.horizontal, PlagitSpacing.sm - 2).padding(.vertical, 1).background(Capsule().stroke(Color.plagitAmber.opacity(0.3), lineWidth: 0.5))
                        }
                    }
                }

                Spacer(minLength: 0)
                Image(systemName: "ellipsis").font(.system(size: 14, weight: .medium)).foregroundColor(.plagitTertiary)
            }.padding(.horizontal, PlagitSpacing.xl).padding(.vertical, PlagitSpacing.lg)
        }.buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func typeIcon(_ type: String) -> String {
        switch type { case "User": return "person"; case "Business": return "building.2"; case "Job": return "briefcase"; case "Message": return "bubble.left"; case "Community": return "text.bubble"; default: return "flag" }
    }

    private func typeColor(_ type: String) -> Color {
        switch type { case "User": return .plagitTeal; case "Business": return .plagitIndigo; case "Job": return .plagitAmber; case "Message": return .plagitUrgent; case "Community": return .plagitOnline; default: return .plagitTertiary }
    }

    private func reasonColor(_ reason: String) -> Color {
        switch reason { case "Scam", "Harassment": return .plagitUrgent; case "Spam", "Fake": return .plagitAmber; case "Misleading": return .plagitIndigo; case "Abuse": return .plagitUrgent; default: return .plagitTertiary }
    }

    private func pill(_ text: String, _ color: Color) -> some View {
        Text(text).font(PlagitFont.micro()).foregroundColor(color)
            .padding(.horizontal, PlagitSpacing.sm - 2).padding(.vertical, 1).background(Capsule().fill(color.opacity(0.08))).lineLimit(1).fixedSize()
    }

    private func severityBadge(_ sev: String) -> some View {
        let color: Color = sev == "Urgent" ? .plagitUrgent : (sev == "High" ? .plagitUrgent : (sev == "Medium" ? .plagitAmber : .plagitTertiary))
        return Text(sev).font(PlagitFont.micro()).foregroundColor(.white)
            .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 1)
            .background(Capsule().fill(color)).lineLimit(1).fixedSize()
    }

    private func statusBadge(_ status: String) -> some View {
        let color: Color = status == "Open" ? .plagitAmber : (status == "Under Review" ? .plagitIndigo : (status == "Resolved" ? .plagitOnline : .plagitTertiary))
        return Text(status).font(PlagitFont.micro()).foregroundColor(color)
            .padding(.horizontal, PlagitSpacing.sm - 2).padding(.vertical, 1).background(Capsule().fill(color.opacity(0.08))).lineLimit(1).fixedSize()
    }

    private var emptyState: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack { Circle().fill(Color.plagitTealLight).frame(width: 48, height: 48); Image(systemName: "flag").font(.system(size: 20, weight: .medium)).foregroundColor(.plagitTeal) }
            VStack(spacing: PlagitSpacing.xs) {
                Text(viewModel.searchText.isEmpty ? "No reports match this filter" : "No results for \"\(viewModel.searchText)\"").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                Text("Try adjusting your filters or search.").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
            }
            if viewModel.selectedFilter != "All" { Button { withAnimation { viewModel.selectedFilter = "All"; viewModel.searchText = "" } } label: { Text("Show All").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal).padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm).background(Capsule().fill(Color.plagitTealLight)) } }
        }.frame(maxWidth: .infinity).padding(.horizontal, PlagitSpacing.xxl)
    }
}

#Preview { NavigationStack { AdminReportsView() }.preferredColorScheme(.light) }
