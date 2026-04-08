//
//  AdminApplicationsView.swift
//  Plagit
//
//  Admin — Applications Funnel Management (Full Operational Control)
//

import SwiftUI

// MARK: - View

struct AdminApplicationsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AdminApplicationsViewModel()
    @State private var showSearch = false
    @State private var showSortMenu = false
    @State private var showCandidateDetail = false
    @State private var showBusinessDetail = false

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
                                ForEach(Array(viewModel.filtered.enumerated()), id: \.element.id) { idx, app in
                                    appRow(app)
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
        .task { await viewModel.loadApplications() }
        .navigationDestination(isPresented: $showCandidateDetail) { AdminCandidateDetailView().navigationBarHidden(true) }
        .navigationDestination(isPresented: $showBusinessDetail) { AdminBusinessDetailView().navigationBarHidden(true) }
        .confirmationDialog("Sort By", isPresented: $showSortMenu) {
            ForEach(viewModel.sortOptions, id: \.self) { o in Button(o) { viewModel.selectedSort = o } }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Loading / Error States

    private var loadingView: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ProgressView().tint(.plagitTeal)
            Text("Loading applications…").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
        }.frame(maxWidth: .infinity)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack {
                Circle().fill(Color.plagitUrgent.opacity(0.10)).frame(width: 48, height: 48)
                Image(systemName: "exclamationmark.triangle").font(.system(size: 20, weight: .medium)).foregroundColor(.plagitUrgent)
            }
            VStack(spacing: PlagitSpacing.xs) {
                Text("Failed to load applications").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                Text(message).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
            }
            Button { Task { await viewModel.loadApplications() } } label: {
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
            Text("Applications").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
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
            TextField("Search candidate, business, job…", text: $viewModel.searchText).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
            if !viewModel.searchText.isEmpty { Button { viewModel.searchText = "" } label: { Image(systemName: "xmark.circle.fill").font(.system(size: 14)).foregroundColor(.plagitTertiary) } }
        }.padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.md).background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface)).padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Summary Cards
    private var summaryCards: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PlagitSpacing.sm) {
                sumChip("All", "\(viewModel.applications.count)", .plagitCharcoal)
                sumChip("Applied", "\(viewModel.countFor("Applied"))", .plagitTeal)
                sumChip("Review", "\(viewModel.countFor("Under Review"))", .plagitAmber)
                sumChip("Shortlist", "\(viewModel.countFor("Shortlisted"))", .plagitIndigo)
                sumChip("Interview", "\(viewModel.countFor("Interview"))", .plagitOnline)
                sumChip("Offer", "\(viewModel.countFor("Offer"))", .plagitTeal)
                sumChip("Rejected", "\(viewModel.countFor("Rejected"))", .plagitTertiary)
                sumChip("Flagged", "\(viewModel.countFor("Flagged"))", .plagitUrgent)
                sumChip("Stale", "\(viewModel.countFor("Stale"))", .plagitAmber)
            }.padding(.horizontal, PlagitSpacing.xl)
        }
    }

    private func sumChip(_ label: String, _ count: String, _ color: Color) -> some View {
        let mapped: String = { switch label { case "Review": return "Under Review"; case "Shortlist": return "Shortlisted"; default: return label } }()
        return Button { withAnimation { viewModel.selectedFilter = mapped } } label: {
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

    // MARK: - Sort
    private var sortRow: some View {
        HStack {
            Text("\(viewModel.filtered.count) applications").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
            Spacer()
            Button { showSortMenu = true } label: {
                HStack(spacing: PlagitSpacing.xs) {
                    Text("Sort: \(viewModel.selectedSort)").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                    Image(systemName: "chevron.down").font(.system(size: 9, weight: .semibold)).foregroundColor(.plagitTeal)
                }
            }
        }.padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - App Row
    private func appRow(_ app: AdminApplication) -> some View {
        HStack(alignment: .top, spacing: PlagitSpacing.md) {
            ZStack(alignment: .bottomTrailing) {
                Circle().fill(LinearGradient(colors: [Color(hue: app.avatarHue, saturation: 0.45, brightness: 0.90), Color(hue: app.avatarHue, saturation: 0.55, brightness: 0.75)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 44, height: 44)
                    .overlay(Text(app.candidateInitials).font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(.white))
                if app.isVerifiedCandidate {
                    Image(systemName: "checkmark.seal.fill").font(.system(size: 12)).foregroundColor(.plagitVerified)
                        .background(Circle().fill(.white).frame(width: 10, height: 10)).offset(x: 2, y: 2)
                }
            }

            VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                HStack(spacing: PlagitSpacing.xs) {
                    Text(app.candidateName).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                        .lineLimit(1).layoutPriority(-1)
                    statusBadge(app.status)
                }

                HStack(spacing: PlagitSpacing.sm) {
                    Text(app.candidateRole).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                    Image(systemName: "arrow.right").font(.system(size: 8, weight: .bold)).foregroundColor(.plagitTertiary)
                    Text(app.jobTitle).font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal)
                }

                HStack(spacing: PlagitSpacing.sm) {
                    Text(app.business).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                    if app.isVerifiedBusiness { Image(systemName: "checkmark.seal.fill").font(.system(size: 8)).foregroundColor(.plagitVerified) }
                    Text("·").foregroundColor(.plagitTertiary)
                    Text(app.location).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                }

                HStack(spacing: PlagitSpacing.sm) {
                    if app.hasInterview { indicator("calendar", "Interview", .plagitOnline) }
                    if app.hasOffer { indicator("gift", "Offer", .plagitTeal) }
                    if app.daysSinceUpdate >= 7 { indicator("clock.badge.exclamationmark", "Stale \(app.daysSinceUpdate)d", .plagitAmber) }
                    if app.flagCount > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "flag.fill").font(.system(size: 8, weight: .medium)).foregroundColor(.plagitUrgent)
                            Text("\(app.flagCount)").font(PlagitFont.micro()).foregroundColor(.plagitUrgent)
                        }
                    }
                }

                HStack(spacing: PlagitSpacing.sm) {
                    Text("Applied \(app.appliedDate)").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                    Text("·").foregroundColor(.plagitTertiary)
                    Text(app.lastUpdate).font(PlagitFont.micro()).foregroundColor(.plagitTertiary).lineLimit(1)
                }
            }

            Spacer(minLength: 0)
            appActionMenu(app)
        }
        .padding(.horizontal, PlagitSpacing.xl).padding(.vertical, PlagitSpacing.lg)
        .contentShape(Rectangle())
        .onTapGesture { showCandidateDetail = true }
    }

    // MARK: - Application Action Menu
    private func appActionMenu(_ app: AdminApplication) -> some View {
        Menu {
            Button { showCandidateDetail = true } label: { Label("View Candidate", systemImage: "person") }
            Button { showBusinessDetail = true } label: { Label("View Business", systemImage: "building.2") }

            Divider()

            if app.status == "Applied" {
                Button { withAnimation { viewModel.updateStatus(id: app.id, status: "Under Review") } } label: { Label("Move to Review", systemImage: "eye") }
            }
            if app.status == "Under Review" {
                Button { withAnimation { viewModel.updateStatus(id: app.id, status: "Shortlisted") } } label: { Label("Shortlist", systemImage: "star") }
            }
            if app.status == "Shortlisted" {
                Button { withAnimation { viewModel.updateStatus(id: app.id, status: "Interview") } } label: { Label("Schedule Interview", systemImage: "calendar") }
            }

            if app.hasInterview {
                Button { } label: { Label("View Interview", systemImage: "calendar.badge.clock") }
            }
            if app.hasOffer {
                Button { } label: { Label("View Offer", systemImage: "gift") }
            }

            Divider()

            if app.status != "Flagged" {
                Button(role: .destructive) { withAnimation { viewModel.updateStatus(id: app.id, status: "Flagged") } } label: { Label("Flag", systemImage: "flag") }
            }
            if app.flagCount > 0 {
                Button { } label: { Label("Investigate", systemImage: "magnifyingglass") }
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.plagitTertiary)
                .frame(width: 36, height: 36)
                .contentShape(Rectangle())
        }
    }

    // MARK: - Helpers

    private func statusBadge(_ status: String) -> some View {
        let color: Color = {
            switch status {
            case "Applied": return .plagitTeal
            case "Under Review": return .plagitAmber
            case "Shortlisted": return .plagitIndigo
            case "Interview": return .plagitOnline
            case "Offer": return .plagitTeal
            case "Rejected": return .plagitTertiary
            case "Withdrawn": return .plagitSecondary
            case "Flagged": return .plagitUrgent
            default: return .plagitTertiary
            }
        }()
        return Text(status).font(PlagitFont.micro()).foregroundColor(color)
            .lineLimit(1).fixedSize()
            .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 1)
            .background(Capsule().fill(color.opacity(0.08)))
    }

    private func indicator(_ icon: String, _ text: String, _ color: Color) -> some View {
        HStack(spacing: 2) {
            Image(systemName: icon).font(.system(size: 8, weight: .medium)).foregroundColor(color)
            Text(text).font(PlagitFont.micro()).foregroundColor(color)
        }
        .lineLimit(1).fixedSize()
        .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 1)
        .background(Capsule().stroke(color.opacity(0.3), lineWidth: 0.5))
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack { Circle().fill(Color.plagitTealLight).frame(width: 48, height: 48); Image(systemName: "doc.text").font(.system(size: 20, weight: .medium)).foregroundColor(.plagitTeal) }
            VStack(spacing: PlagitSpacing.xs) {
                Text(viewModel.searchText.isEmpty ? "No applications match this filter" : "No results for \"\(viewModel.searchText)\"").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                Text("Try adjusting your filters or search.").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
            }
            if viewModel.selectedFilter != "All" { Button { withAnimation { viewModel.selectedFilter = "All"; viewModel.searchText = "" } } label: { Text("Show All").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal).padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm).background(Capsule().fill(Color.plagitTealLight)) } }
        }.frame(maxWidth: .infinity).padding(.horizontal, PlagitSpacing.xxl)
    }
}

#Preview { NavigationStack { AdminApplicationsView() }.preferredColorScheme(.light) }
