//
//  AdminInterviewsView.swift
//  Plagit
//
//  Admin — Interviews Scheduling & Operations (Full Control)
//

import SwiftUI

// MARK: - View

struct AdminInterviewsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AdminInterviewsViewModel()
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

                HStack {
                    sortRow
                    Spacer()
                    viewToggle
                }.padding(.top, PlagitSpacing.sm).padding(.horizontal, PlagitSpacing.xl)

                if viewModel.viewMode == "list" { listView } else { calendarView }
            }
        }
        .navigationBarHidden(true)
        .animation(.easeInOut(duration: 0.2), value: showSearch)
        .animation(.easeInOut(duration: 0.2), value: viewModel.viewMode)
        .task { await viewModel.loadInterviews() }
        .navigationDestination(isPresented: $showCandidateDetail) { AdminCandidateDetailView().navigationBarHidden(true) }
        .navigationDestination(isPresented: $showBusinessDetail) { AdminBusinessDetailView().navigationBarHidden(true) }
        .confirmationDialog("Sort By", isPresented: $showSortMenu) {
            ForEach(viewModel.sortOptions, id: \.self) { o in Button(o) { viewModel.selectedSort = o } }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button { dismiss() } label: { Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36) }
            Spacer()
            Text("Interviews").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
            Spacer()
            Button { withAnimation { showSearch.toggle(); if !showSearch { viewModel.searchText = "" } } } label: {
                Image(systemName: showSearch ? "xmark" : "magnifyingglass").font(.system(size: 18, weight: .regular)).foregroundColor(.plagitCharcoal)
            }
        }.padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.xxl).padding(.bottom, PlagitSpacing.lg)
    }

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
                sumChip("All", "\(viewModel.interviews.count)", .plagitCharcoal, "All")
                sumChip("Today", "\(viewModel.countFor("Today"))", .plagitTeal, "Today")
                sumChip("Pending", "\(viewModel.countFor("Pending"))", .plagitAmber, "Pending")
                sumChip("Confirmed", "\(viewModel.countFor("Confirmed"))", .plagitOnline, "Confirmed")
                sumChip("Rescheduled", "\(viewModel.countFor("Rescheduled"))", .plagitIndigo, "Rescheduled")
                sumChip("Cancelled", "\(viewModel.countFor("Cancelled"))", .plagitTertiary, "Cancelled")
                sumChip("Flagged", "\(viewModel.countFor("Flagged"))", .plagitUrgent, "Flagged")
                sumChip("Missing", "\(viewModel.countFor("Missing Info"))", .plagitAmber, "Missing Info")
            }.padding(.horizontal, PlagitSpacing.xl)
        }
    }

    private func sumChip(_ label: String, _ count: String, _ color: Color, _ filter: String) -> some View {
        Button { withAnimation { viewModel.selectedFilter = filter } } label: {
            VStack(spacing: 2) {
                Text(count).font(PlagitFont.headline()).foregroundColor(color)
                Text(label).font(PlagitFont.micro()).foregroundColor(.plagitSecondary)
            }.frame(width: 68).padding(.vertical, PlagitSpacing.sm).background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
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

    // MARK: - Sort + View Toggle
    private var sortRow: some View {
        HStack {
            Text("\(viewModel.filtered.count) interviews").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
            Button { showSortMenu = true } label: {
                HStack(spacing: PlagitSpacing.xs) {
                    Text(viewModel.selectedSort).font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                    Image(systemName: "chevron.down").font(.system(size: 9, weight: .semibold)).foregroundColor(.plagitTeal)
                }
            }
        }
    }

    private var viewToggle: some View {
        HStack(spacing: 0) {
            Button { withAnimation { viewModel.viewMode = "list" } } label: {
                Image(systemName: "list.bullet").font(.system(size: 12, weight: .medium))
                    .foregroundColor(viewModel.viewMode == "list" ? .white : .plagitSecondary)
                    .frame(width: 32, height: 28)
                    .background(RoundedRectangle(cornerRadius: PlagitRadius.sm).fill(viewModel.viewMode == "list" ? Color.plagitTeal : Color.clear))
            }
            Button { withAnimation { viewModel.viewMode = "calendar" } } label: {
                Image(systemName: "calendar").font(.system(size: 12, weight: .medium))
                    .foregroundColor(viewModel.viewMode == "calendar" ? .white : .plagitSecondary)
                    .frame(width: 32, height: 28)
                    .background(RoundedRectangle(cornerRadius: PlagitRadius.sm).fill(viewModel.viewMode == "calendar" ? Color.plagitTeal : Color.clear))
            }
        }
        .padding(2)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.sm + 2).fill(Color.plagitSurface))
    }

    // MARK: - List View
    private var listView: some View {
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
                        ForEach(Array(viewModel.filtered.enumerated()), id: \.element.id) { idx, iv in
                            ivRow(iv)
                            if idx < viewModel.filtered.count - 1 { Rectangle().fill(Color.plagitDivider).frame(height: 1).padding(.leading, PlagitSpacing.xl + 44 + PlagitSpacing.md) }
                        }
                    }
                    .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
                    .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.md).padding(.bottom, PlagitSpacing.xxxl)
                }
            }
        }
    }

    // MARK: - Calendar View (grouped by date)
    private var calendarView: some View {
        let grouped = Dictionary(grouping: viewModel.filtered, by: { $0.date })
        let sortedDates = grouped.keys.sorted()

        return ScrollView(.vertical, showsIndicators: false) {
            switch viewModel.loadingState {
            case .idle, .loading:
                loadingView.padding(.top, PlagitSpacing.xxxl * 2)
            case .error(let message):
                errorView(message).padding(.top, PlagitSpacing.xxxl * 2)
            case .loaded:
                if viewModel.filtered.isEmpty {
                    emptyState.padding(.top, PlagitSpacing.xxxl * 2)
                } else {
                    VStack(spacing: PlagitSpacing.lg) {
                        ForEach(sortedDates, id: \.self) { date in
                            VStack(alignment: .leading, spacing: PlagitSpacing.md) {
                                HStack(spacing: PlagitSpacing.sm) {
                                    Image(systemName: "calendar").font(.system(size: 12, weight: .medium)).foregroundColor(.plagitTeal)
                                    Text(date).font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
                                    Text("\(grouped[date]?.count ?? 0)").font(PlagitFont.micro()).foregroundColor(.plagitTeal)
                                        .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 2).background(Capsule().fill(Color.plagitTeal.opacity(0.08)))
                                }.padding(.horizontal, PlagitSpacing.xl)

                                VStack(spacing: 0) {
                                    ForEach(Array((grouped[date] ?? []).enumerated()), id: \.element.id) { idx, iv in
                                        calendarRow(iv)
                                        if idx < (grouped[date]?.count ?? 0) - 1 { Rectangle().fill(Color.plagitDivider).frame(height: 1).padding(.leading, PlagitSpacing.xl + PlagitSpacing.lg) }
                                    }
                                }
                                .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
                                .padding(.horizontal, PlagitSpacing.xl)
                            }
                        }
                    }.padding(.top, PlagitSpacing.md).padding(.bottom, PlagitSpacing.xxxl)
                }
            }
        }
    }

    private func calendarRow(_ iv: AdminInterview) -> some View {
        HStack(spacing: PlagitSpacing.md) {
            VStack(spacing: 2) {
                Text(iv.time).font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal)
                Text(iv.timezone).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
            }.frame(width: 55)

            VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                HStack(spacing: PlagitSpacing.sm) {
                    Text(iv.candidateName).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal).lineLimit(1)
                    statusBadge(iv.status)
                }
                Text("\(iv.jobTitle) · \(iv.business)").font(PlagitFont.caption()).foregroundColor(.plagitSecondary).lineLimit(1)
                typeBadge(iv.interviewType)
            }
            Spacer()
            ivActionMenu(iv)
        }
        .padding(.horizontal, PlagitSpacing.xl).padding(.vertical, PlagitSpacing.md + 2)
        .contentShape(Rectangle())
        .onTapGesture { showCandidateDetail = true }
    }

    // MARK: - Interview Row (List)
    private func ivRow(_ iv: AdminInterview) -> some View {
        HStack(alignment: .top, spacing: PlagitSpacing.md) {
            Circle().fill(LinearGradient(colors: [Color(hue: iv.avatarHue, saturation: 0.45, brightness: 0.90), Color(hue: iv.avatarHue, saturation: 0.55, brightness: 0.75)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 44, height: 44)
                .overlay(Text(iv.candidateInitials).font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(.white))

            VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                HStack(spacing: PlagitSpacing.sm) {
                    Text(iv.candidateName).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal).lineLimit(1)
                    statusBadge(iv.status)
                }

                HStack(spacing: PlagitSpacing.sm) {
                    Text(iv.jobTitle).font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal)
                    Text("·").foregroundColor(.plagitTertiary)
                    Text(iv.business).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                    if iv.isVerifiedBusiness { Image(systemName: "checkmark.seal.fill").font(.system(size: 8)).foregroundColor(.plagitVerified) }
                }

                HStack(spacing: PlagitSpacing.md) {
                    HStack(spacing: 2) { Image(systemName: "calendar").font(.system(size: 9, weight: .medium)).foregroundColor(.plagitTeal); Text("\(iv.date) · \(iv.time) \(iv.timezone)").font(PlagitFont.micro()).foregroundColor(.plagitSecondary) }
                    typeBadge(iv.interviewType)
                }

                // Health indicators
                HStack(spacing: PlagitSpacing.sm) {
                    if iv.daysPending >= 3 && iv.status == "Pending" { healthBadge("Pending \(iv.daysPending)d", .plagitAmber) }
                    if iv.interviewType == "Video Call" && iv.meetingLink.isEmpty { healthBadge("No Link", .plagitUrgent) }
                    if iv.interviewType == "In Person" && iv.location.isEmpty { healthBadge("No Location", .plagitUrgent) }
                    if iv.rescheduleCount >= 2 { healthBadge("Rescheduled ×\(iv.rescheduleCount)", .plagitAmber) }
                    if iv.flagCount > 0 {
                        HStack(spacing: 2) { Image(systemName: "flag.fill").font(.system(size: 8, weight: .medium)).foregroundColor(.plagitUrgent); Text("\(iv.flagCount)").font(PlagitFont.micro()).foregroundColor(.plagitUrgent) }
                    }
                }

                Text(iv.lastUpdate).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
            }

            Spacer(minLength: 0)
            ivActionMenu(iv)
        }
        .padding(.horizontal, PlagitSpacing.xl).padding(.vertical, PlagitSpacing.lg)
        .contentShape(Rectangle())
        .onTapGesture { showCandidateDetail = true }
    }

    // MARK: - Interview Action Menu
    private func ivActionMenu(_ iv: AdminInterview) -> some View {
        Menu {
            Button { showCandidateDetail = true } label: { Label("View Candidate", systemImage: "person") }
            Button { showBusinessDetail = true } label: { Label("View Business", systemImage: "building.2") }
            Button { } label: { Label("View Application", systemImage: "doc.text") }

            Divider()

            if iv.status == "Pending" {
                Button { withAnimation { viewModel.updateStatus(id: iv.id, status: "Confirmed") } } label: { Label("Confirm", systemImage: "checkmark.circle") }
            }
            if iv.status == "Confirmed" || iv.status == "Pending" {
                Button { withAnimation { viewModel.updateStatus(id: iv.id, status: "Rescheduled") } } label: { Label("Reschedule", systemImage: "calendar.badge.clock") }
            }
            if iv.status == "Confirmed" {
                Button { withAnimation { viewModel.updateStatus(id: iv.id, status: "Completed") } } label: { Label("Mark Completed", systemImage: "checkmark.seal") }
            }
            if iv.status != "Cancelled" && iv.status != "Completed" {
                Button(role: .destructive) { withAnimation { viewModel.updateStatus(id: iv.id, status: "Cancelled") } } label: { Label("Cancel", systemImage: "xmark.circle") }
            }

            Divider()

            Button { } label: { Label("Add Note", systemImage: "note.text.badge.plus") }
            if iv.flagCount > 0 {
                Button { } label: { Label("Investigate", systemImage: "flag") }
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.plagitTertiary)
                .frame(width: 36, height: 36)
                .contentShape(Rectangle())
        }
    }

    // MARK: - Loading & Error

    private var loadingView: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ProgressView().tint(.plagitTeal)
            Text("Loading interviews…").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
        }.frame(maxWidth: .infinity)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack {
                Circle().fill(Color.plagitUrgent.opacity(0.10)).frame(width: 48, height: 48)
                Image(systemName: "exclamationmark.triangle").font(.system(size: 20, weight: .medium)).foregroundColor(.plagitUrgent)
            }
            VStack(spacing: PlagitSpacing.xs) {
                Text("Failed to load interviews").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                Text(message).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
            }
            Button { Task { await viewModel.loadInterviews() } } label: {
                Text("Retry").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                    .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm)
                    .background(Capsule().fill(Color.plagitTealLight))
            }
        }.frame(maxWidth: .infinity).padding(.horizontal, PlagitSpacing.xxl)
    }

    // MARK: - Helpers

    private func statusBadge(_ status: String) -> some View {
        let color: Color = {
            switch status {
            case "Pending": return .plagitAmber
            case "Confirmed": return .plagitOnline
            case "Rescheduled": return .plagitIndigo
            case "Cancelled": return .plagitTertiary
            case "Completed": return .plagitTeal
            case "Flagged": return .plagitUrgent
            default: return .plagitTertiary
            }
        }()
        return Text(status).font(PlagitFont.micro()).foregroundColor(color)
            .padding(.horizontal, PlagitSpacing.sm - 2).padding(.vertical, 1).background(Capsule().fill(color.opacity(0.08)))
            .lineLimit(1).fixedSize()
    }

    private func typeBadge(_ type: String) -> some View {
        let icon: String = type == "Video Call" ? "video" : (type == "Phone" ? "phone" : "mappin")
        let color: Color = type == "Video Call" ? .plagitIndigo : (type == "Phone" ? .plagitTeal : .plagitAmber)
        return HStack(spacing: 2) {
            Image(systemName: icon).font(.system(size: 8, weight: .medium)).foregroundColor(color)
            Text(type).font(PlagitFont.micro()).foregroundColor(color)
        }.padding(.horizontal, PlagitSpacing.sm - 2).padding(.vertical, 1).background(Capsule().fill(color.opacity(0.06)))
    }

    private func healthBadge(_ text: String, _ color: Color) -> some View {
        Text(text).font(PlagitFont.micro()).foregroundColor(color)
            .padding(.horizontal, PlagitSpacing.sm - 2).padding(.vertical, 1)
            .background(Capsule().stroke(color.opacity(0.3), lineWidth: 0.5))
    }

    private var emptyState: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack { Circle().fill(Color.plagitTealLight).frame(width: 48, height: 48); Image(systemName: "calendar").font(.system(size: 20, weight: .medium)).foregroundColor(.plagitTeal) }
            VStack(spacing: PlagitSpacing.xs) {
                Text(viewModel.searchText.isEmpty ? "No interviews match this filter" : "No results for \"\(viewModel.searchText)\"").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                Text("Try adjusting your filters or search.").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
            }
            if viewModel.selectedFilter != "All" { Button { withAnimation { viewModel.selectedFilter = "All"; viewModel.searchText = "" } } label: { Text("Show All").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal).padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm).background(Capsule().fill(Color.plagitTealLight)) } }
        }.frame(maxWidth: .infinity).padding(.horizontal, PlagitSpacing.xxl)
    }
}

#Preview { NavigationStack { AdminInterviewsView() }.preferredColorScheme(.light) }
