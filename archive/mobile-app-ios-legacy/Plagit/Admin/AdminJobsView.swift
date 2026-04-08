//
//  AdminJobsView.swift
//  Plagit
//
//  Admin — Jobs Management (Full Operational Control)
//

import SwiftUI

// MARK: - View

struct AdminJobsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AdminJobsViewModel()
    @State private var showSearch = false
    @State private var showSortMenu = false
    @State private var showJobDetail = false
    @State private var showDeleteAlert = false
    @State private var actionJobId: UUID?

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar.background(Color.plagitBackground).zIndex(1)
                if showSearch { searchBar.transition(.move(edge: .top).combined(with: .opacity)) }
                summaryCards.padding(.top, PlagitSpacing.xs)
                filterChips.padding(.top, PlagitSpacing.sm)
                sortRow.padding(.top, PlagitSpacing.sm)

                ScrollView(.vertical, showsIndicators: false) {
                    switch viewModel.loadingState {
                    case .idle, .loading:
                        loadingView.padding(.top, PlagitSpacing.xxxl * 2)
                    case .error(let message):
                        errorView(message).padding(.top, PlagitSpacing.xxxl * 2)
                    case .loaded:
                        if viewModel.filtered.isEmpty {
                            emptyState.padding(.top, PlagitSpacing.xxxl * 2)
                        } else {
                            VStack(spacing: 0) {
                                ForEach(Array(viewModel.filtered.enumerated()), id: \.element.id) { idx, job in
                                    jobRow(job)
                                    if idx < viewModel.filtered.count - 1 { Rectangle().fill(Color.plagitDivider).frame(height: 1).padding(.leading, PlagitSpacing.xl + 44 + PlagitSpacing.md) }
                                }
                            }
                            .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
                            .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.md).padding(.bottom, PlagitSpacing.xxxl)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .animation(.easeInOut(duration: 0.2), value: showSearch)
        .task { await viewModel.loadJobs() }
        .navigationDestination(isPresented: $showJobDetail) { AdminJobDetailView().navigationBarHidden(true) }
        .alert(viewModel.alertTitle(action: "Delete", for: actionJobId), isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) { if let id = actionJobId { withAnimation { viewModel.deleteJob(id: id) } } }
            Button("Cancel", role: .cancel) {}
        } message: { Text("This action cannot be undone. The job listing will be permanently removed.") }
        .confirmationDialog("Sort By", isPresented: $showSortMenu) {
            ForEach(viewModel.sortOptions, id: \.self) { o in Button(o) { viewModel.selectedSort = o } }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Loading / Error States

    private var loadingView: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ProgressView().tint(.plagitTeal)
            Text("Loading jobs…").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
        }.frame(maxWidth: .infinity)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack {
                Circle().fill(Color.plagitUrgent.opacity(0.10)).frame(width: 48, height: 48)
                Image(systemName: "exclamationmark.triangle").font(.system(size: 20, weight: .medium)).foregroundColor(.plagitUrgent)
            }
            VStack(spacing: PlagitSpacing.xs) {
                Text("Failed to load jobs").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                Text(message).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
            }
            Button { Task { await viewModel.loadJobs() } } label: {
                Text("Retry").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                    .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm)
                    .background(Capsule().fill(Color.plagitTealLight))
            }
        }.frame(maxWidth: .infinity).padding(.horizontal, PlagitSpacing.xxl)
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button { dismiss() } label: { Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36) }
            Spacer()
            Text("Jobs").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
            Spacer()
            Button { withAnimation { showSearch.toggle(); if !showSearch { viewModel.searchText = "" } } } label: {
                Image(systemName: showSearch ? "xmark" : "magnifyingglass").font(.system(size: 18, weight: .regular)).foregroundColor(.plagitCharcoal)
            }
        }.padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.xxl).padding(.bottom, PlagitSpacing.lg)
    }

    // MARK: - Search
    private var searchBar: some View {
        HStack(spacing: PlagitSpacing.md) {
            Image(systemName: "magnifyingglass").font(.system(size: 14, weight: .medium)).foregroundColor(.plagitTertiary)
            TextField("Search title, business, location…", text: $viewModel.searchText).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
            if !viewModel.searchText.isEmpty { Button { viewModel.searchText = "" } label: { Image(systemName: "xmark.circle.fill").font(.system(size: 14)).foregroundColor(.plagitTertiary) } }
        }.padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.md).background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface)).padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Summary Cards
    private var summaryCards: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PlagitSpacing.sm) {
                sumChip("All", "\(viewModel.jobs.count)", .plagitCharcoal)
                sumChip("Active", "\(viewModel.countFor("Active"))", .plagitOnline)
                sumChip("Paused", "\(viewModel.countFor("Paused"))", .plagitAmber)
                sumChip("Closed", "\(viewModel.countFor("Closed"))", .plagitTertiary)
                sumChip("Draft", "\(viewModel.countFor("Draft"))", .plagitSecondary)
                sumChip("Flagged", "\(viewModel.countFor("Flagged"))", .plagitUrgent)
                sumChip("Featured", "\(viewModel.countFor("Featured"))", .plagitTeal)
                sumChip("No Apps", "\(viewModel.countFor("No Applicants"))", .plagitUrgent)
            }.padding(.horizontal, PlagitSpacing.xl)
        }
    }

    private func sumChip(_ label: String, _ count: String, _ color: Color) -> some View {
        Button {
            let mapped: String = { switch label { case "No Apps": return "No Applicants"; default: return label } }()
            withAnimation { viewModel.selectedFilter = mapped }
        } label: {
            VStack(spacing: 2) {
                Text(count).font(PlagitFont.headline()).foregroundColor(color)
                Text(label).font(PlagitFont.micro()).foregroundColor(.plagitSecondary)
            }.frame(width: 64).padding(.vertical, PlagitSpacing.sm).background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
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

    // MARK: - Sort
    private var sortRow: some View {
        HStack {
            Text("\(viewModel.filtered.count) jobs").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
            Spacer()
            Button { showSortMenu = true } label: {
                HStack(spacing: PlagitSpacing.xs) {
                    Text("Sort: \(viewModel.selectedSort)").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                    Image(systemName: "chevron.down").font(.system(size: 9, weight: .semibold)).foregroundColor(.plagitTeal)
                }
            }
        }.padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Job Row
    private func jobRow(_ job: AdminJob) -> some View {
        HStack(alignment: .top, spacing: PlagitSpacing.md) {
            Circle().fill(LinearGradient(colors: [Color(hue: job.avatarHue, saturation: 0.45, brightness: 0.90), Color(hue: job.avatarHue, saturation: 0.55, brightness: 0.75)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 44, height: 44)
                .overlay(Text(job.businessInitials).font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(.white))

            VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                HStack(spacing: PlagitSpacing.xs) {
                    Text(job.title).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                        .lineLimit(1).layoutPriority(-1)
                    statusBadge(job.status)
                    if job.isFeatured { pill("Featured", .plagitAmber) }
                }

                HStack(spacing: PlagitSpacing.sm) {
                    Text(job.business).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                    if job.isVerified { Image(systemName: "checkmark.seal.fill").font(.system(size: 9)).foregroundColor(.plagitVerified) }
                    Text("·").foregroundColor(.plagitTertiary)
                    Text(job.location).font(PlagitFont.caption()).foregroundColor(.plagitTertiary)
                }

                HStack(spacing: PlagitSpacing.sm) {
                    Text(job.employmentType).font(PlagitFont.micro()).foregroundColor(.plagitSecondary)
                    Text("·").foregroundColor(.plagitTertiary)
                    Text(job.salary).font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal)
                    pill(job.category, .plagitTeal)
                }

                HStack(spacing: PlagitSpacing.md) {
                    metricItem("eye", "\(job.views)")
                    if job.saves > 0 { metricItem("bookmark", "\(job.saves)") }
                    metricItem("person.2", "\(job.applicants)")
                    metricItem("checkmark.circle", "\(job.shortlisted)")
                    metricItem("calendar", "\(job.interviews)")
                    if job.flagCount > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "flag.fill").font(.system(size: 8, weight: .medium)).foregroundColor(.plagitUrgent)
                            Text("\(job.flagCount)").font(PlagitFont.micro()).foregroundColor(.plagitUrgent)
                        }
                    }
                }

                HStack(spacing: PlagitSpacing.sm) {
                    if job.applicants == 0 && job.status == "Active" { healthBadge("No Applicants", .plagitUrgent) }
                    if job.views < 30 && job.status == "Active" { healthBadge("Low Views", .plagitAmber) }
                    if job.applicants > 0 && job.views > 0 && Double(job.applicants) / Double(job.views) > 0.05 { healthBadge("High Conversion", .plagitOnline) }
                    if job.salary == "Not specified" { healthBadge("No Salary", .plagitAmber) }
                    Text("Posted \(job.postedDate)").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                    if job.expiryDate != "—" {
                        Text("· Expires \(job.expiryDate)").font(PlagitFont.micro()).foregroundColor(job.expiryDate.contains("Mar") ? .plagitUrgent : .plagitTertiary)
                    }
                }
            }

            Spacer(minLength: 0)
            jobActionMenu(job)
        }
        .padding(.horizontal, PlagitSpacing.xl).padding(.vertical, PlagitSpacing.lg)
        .contentShape(Rectangle())
        .onTapGesture { showJobDetail = true }
    }

    // MARK: - Job Action Menu
    private func jobActionMenu(_ job: AdminJob) -> some View {
        Menu {
            Button { showJobDetail = true } label: { Label("View Job", systemImage: "briefcase") }

            Divider()

            if job.status == "Active" {
                Button { withAnimation { viewModel.updateStatus(id: job.id, status: "Paused") } } label: { Label("Pause", systemImage: "pause.circle") }
            }
            if job.status == "Paused" {
                Button { withAnimation { viewModel.updateStatus(id: job.id, status: "Active") } } label: { Label("Activate", systemImage: "play.circle") }
            }
            if job.status == "Pending Review" {
                Button { withAnimation { viewModel.updateStatus(id: job.id, status: "Active") } } label: { Label("Approve", systemImage: "checkmark.circle") }
            }
            if job.status != "Closed" {
                Button { withAnimation { viewModel.updateStatus(id: job.id, status: "Closed") } } label: { Label("Close", systemImage: "xmark.circle") }
            }
            if job.status == "Closed" {
                Button { withAnimation { viewModel.updateStatus(id: job.id, status: "Active") } } label: { Label("Reopen", systemImage: "arrow.uturn.left.circle") }
            }

            Divider()

            if job.isFeatured {
                Button { withAnimation { viewModel.setFeatured(id: job.id, featured: false) } } label: { Label("Remove Featured", systemImage: "star.slash") }
            } else {
                Button { withAnimation { viewModel.setFeatured(id: job.id, featured: true) } } label: { Label("Feature", systemImage: "star") }
            }

            Divider()

            Button(role: .destructive) { actionJobId = job.id; showDeleteAlert = true } label: { Label("Delete", systemImage: "trash") }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.plagitTertiary)
                .frame(width: 36, height: 36)
                .contentShape(Rectangle())
        }
    }

    // MARK: - Helpers

    private func pill(_ text: String, _ color: Color) -> some View {
        Text(text).font(PlagitFont.micro()).foregroundColor(color)
            .lineLimit(1).fixedSize()
            .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 1)
            .background(Capsule().fill(color.opacity(0.08)))
    }

    private func statusBadge(_ status: String) -> some View {
        let color: Color = {
            switch status {
            case "Active": return .plagitOnline
            case "Paused": return .plagitAmber
            case "Closed": return .plagitTertiary
            case "Draft": return .plagitSecondary
            case "Pending Review": return .plagitAmber
            case "Flagged": return .plagitUrgent
            case "Suspended": return .plagitUrgent
            default: return .plagitTertiary
            }
        }()
        return Text(status).font(PlagitFont.micro()).foregroundColor(color)
            .lineLimit(1).fixedSize()
            .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 1)
            .background(Capsule().fill(color.opacity(0.08)))
    }

    private func healthBadge(_ text: String, _ color: Color) -> some View {
        Text(text).font(PlagitFont.micro()).foregroundColor(color)
            .lineLimit(1).fixedSize()
            .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 1)
            .background(Capsule().stroke(color.opacity(0.3), lineWidth: 0.5))
    }

    private func metricItem(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 2) {
            Image(systemName: icon).font(.system(size: 8, weight: .medium)).foregroundColor(.plagitTertiary)
            Text(text).font(PlagitFont.micro()).foregroundColor(.plagitSecondary)
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack { Circle().fill(Color.plagitTealLight).frame(width: 48, height: 48); Image(systemName: "briefcase").font(.system(size: 20, weight: .medium)).foregroundColor(.plagitTeal) }
            VStack(spacing: PlagitSpacing.xs) {
                Text(viewModel.searchText.isEmpty ? "No jobs match this filter" : "No results for \"\(viewModel.searchText)\"").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                Text("Try adjusting your filters or search.").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
            }
            if viewModel.selectedFilter != "All" { Button { withAnimation { viewModel.selectedFilter = "All"; viewModel.searchText = "" } } label: { Text("Show All").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal).padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm).background(Capsule().fill(Color.plagitTealLight)) } }
        }.frame(maxWidth: .infinity).padding(.horizontal, PlagitSpacing.xxl)
    }
}

#Preview { NavigationStack { AdminJobsView() }.preferredColorScheme(.light) }
