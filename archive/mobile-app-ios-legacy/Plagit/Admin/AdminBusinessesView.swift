//
//  AdminBusinessesView.swift
//  Plagit
//
//  Admin — Businesses Management (Full Operational Control)
//

import SwiftUI

// MARK: - View

struct AdminBusinessesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AdminBusinessesViewModel()
    @State private var showSearch = false
    @State private var showSortMenu = false
    @State private var showBusinessDetail = false
    @State private var showBanAlert = false
    @State private var showDeleteAlert = false
    @State private var actionBizId: UUID?

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
                                ForEach(Array(viewModel.filtered.enumerated()), id: \.element.id) { idx, biz in
                                    bizRow(biz)
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
        .task { await viewModel.loadBusinesses() }
        .navigationDestination(isPresented: $showBusinessDetail) { AdminBusinessDetailView().navigationBarHidden(true) }
        .alert(viewModel.alertTitle(action: "Ban", for: actionBizId), isPresented: $showBanAlert) {
            Button("Ban", role: .destructive) { if let id = actionBizId { withAnimation { viewModel.banBusiness(id: id) } } }
            Button("Cancel", role: .cancel) {}
        } message: { Text("This business will permanently lose platform access.") }
        .alert(viewModel.alertTitle(action: "Delete", for: actionBizId), isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) { if let id = actionBizId { withAnimation { viewModel.deleteBusiness(id: id) } } }
            Button("Cancel", role: .cancel) {}
        } message: { Text("This action cannot be undone. All business data will be permanently removed.") }
        .confirmationDialog("Sort By", isPresented: $showSortMenu) {
            ForEach(viewModel.sortOptions, id: \.self) { o in Button(o) { viewModel.selectedSort = o } }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Loading / Error States

    private var loadingView: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ProgressView().tint(.plagitTeal)
            Text("Loading businesses…").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
        }.frame(maxWidth: .infinity)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack {
                Circle().fill(Color.plagitUrgent.opacity(0.10)).frame(width: 48, height: 48)
                Image(systemName: "exclamationmark.triangle").font(.system(size: 20, weight: .medium)).foregroundColor(.plagitUrgent)
            }
            VStack(spacing: PlagitSpacing.xs) {
                Text("Failed to load businesses").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                Text(message).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
            }
            Button { Task { await viewModel.loadBusinesses() } } label: {
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
            Text("Businesses").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
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
            TextField("Search name, email, contact, type…", text: $viewModel.searchText).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
            if !viewModel.searchText.isEmpty { Button { viewModel.searchText = "" } label: { Image(systemName: "xmark.circle.fill").font(.system(size: 14)).foregroundColor(.plagitTertiary) } }
        }.padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.md).background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface)).padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Summary Cards
    private var summaryCards: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PlagitSpacing.sm) {
                sumChip("All", "\(viewModel.businesses.count)", .plagitCharcoal)
                sumChip("Verified", "\(viewModel.countFor("Verified"))", .plagitOnline)
                sumChip("Unverified", "\(viewModel.countFor("Unverified"))", .plagitAmber)
                sumChip("Active", "\(viewModel.countFor("Active Plan"))", .plagitTeal)
                sumChip("Trial", "\(viewModel.countFor("Trial"))", .plagitIndigo)
                sumChip("Suspended", "\(viewModel.countFor("Suspended"))", .plagitUrgent)
                sumChip("Flagged", "\(viewModel.countFor("Flagged"))", .plagitUrgent)
            }.padding(.horizontal, PlagitSpacing.xl)
        }
    }

    private func sumChip(_ label: String, _ count: String, _ color: Color) -> some View {
        Button { withAnimation { viewModel.selectedFilter = label == "Active" ? "Active Plan" : label } } label: {
            VStack(spacing: 2) {
                Text(count).font(PlagitFont.headline()).foregroundColor(color)
                Text(label).font(PlagitFont.micro()).foregroundColor(.plagitSecondary)
            }.frame(width: 70).padding(.vertical, PlagitSpacing.sm).background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
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
            Text("\(viewModel.filtered.count) businesses").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
            Spacer()
            Button { showSortMenu = true } label: {
                HStack(spacing: PlagitSpacing.xs) {
                    Text("Sort: \(viewModel.selectedSort)").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                    Image(systemName: "chevron.down").font(.system(size: 9, weight: .semibold)).foregroundColor(.plagitTeal)
                }
            }
        }.padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Business Row
    private func bizRow(_ biz: AdminBiz) -> some View {
        HStack(alignment: .top, spacing: PlagitSpacing.md) {
            ZStack(alignment: .bottomTrailing) {
                Circle().fill(LinearGradient(colors: [Color(hue: biz.avatarHue, saturation: 0.45, brightness: 0.90), Color(hue: biz.avatarHue, saturation: 0.55, brightness: 0.75)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 44, height: 44)
                    .overlay(Text(biz.initials).font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(.white))
                if biz.isVerified {
                    Image(systemName: "checkmark.seal.fill").font(.system(size: 12)).foregroundColor(.plagitVerified)
                        .background(Circle().fill(.white).frame(width: 10, height: 10)).offset(x: 2, y: 2)
                }
            }

            VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                HStack(spacing: PlagitSpacing.xs) {
                    Text(biz.name).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                        .lineLimit(1).layoutPriority(-1)
                    if biz.isFeatured { pill("Featured", .plagitAmber) }
                    statusPill(biz.status)
                }
                HStack(spacing: PlagitSpacing.xs) {
                    pill(biz.venueType, .plagitIndigo)
                    Text("·").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                    Text(biz.location).font(PlagitFont.caption()).foregroundColor(.plagitSecondary).lineLimit(1)
                }
                planPill(biz.plan, biz.planStatus)
                HStack(spacing: PlagitSpacing.md) {
                    metricItem("briefcase", "\(biz.activeJobs) jobs")
                    metricItem("person.2", "\(biz.applicantsReceived) apps")
                    HStack(spacing: 2) {
                        Image(systemName: "bolt.fill").font(.system(size: 8, weight: .medium)).foregroundColor(rateColor(biz.responseRate))
                        Text("\(biz.responseRate)%").font(PlagitFont.micro()).foregroundColor(rateColor(biz.responseRate))
                    }
                    if biz.flagCount > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "flag.fill").font(.system(size: 8, weight: .medium)).foregroundColor(.plagitUrgent)
                            Text("\(biz.flagCount)").font(PlagitFont.micro()).foregroundColor(.plagitUrgent)
                        }
                    }
                }
                HStack(spacing: PlagitSpacing.sm) {
                    Text("Joined \(biz.joinedDate)").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                    Text("·").foregroundColor(.plagitTertiary)
                    Text("Active \(biz.lastActive)").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                }
            }

            Spacer(minLength: 0)
            bizActionMenu(biz)
        }
        .padding(.horizontal, PlagitSpacing.xl).padding(.vertical, PlagitSpacing.lg)
        .contentShape(Rectangle())
        .onTapGesture { showBusinessDetail = true }
    }

    // MARK: - Business Action Menu
    private func bizActionMenu(_ biz: AdminBiz) -> some View {
        Menu {
            Button { showBusinessDetail = true } label: { Label("View Profile", systemImage: "building.2") }

            if !biz.isVerified {
                Button { withAnimation { viewModel.verifyBusiness(id: biz.id) } } label: { Label("Verify", systemImage: "checkmark.seal") }
            }

            if biz.isFeatured {
                Button { withAnimation { viewModel.setFeatured(id: biz.id, featured: false) } } label: { Label("Remove Featured", systemImage: "star.slash") }
            } else {
                Button { withAnimation { viewModel.setFeatured(id: biz.id, featured: true) } } label: { Label("Feature", systemImage: "star") }
            }

            Divider()

            if biz.status == "Active" {
                Button(role: .destructive) { withAnimation { viewModel.suspendBusiness(id: biz.id) } } label: { Label("Suspend", systemImage: "pause.circle") }
            }

            if biz.status == "Suspended" {
                Button { withAnimation { viewModel.activateBusiness(id: biz.id) } } label: { Label("Activate", systemImage: "play.circle") }
                Button(role: .destructive) { actionBizId = biz.id; showBanAlert = true } label: { Label("Ban", systemImage: "nosign") }
            }

            if biz.status == "Banned" {
                Button { withAnimation { viewModel.unbanBusiness(id: biz.id) } } label: { Label("Unban", systemImage: "arrow.uturn.left.circle") }
            }

            Divider()

            Button(role: .destructive) { actionBizId = biz.id; showDeleteAlert = true } label: { Label("Delete", systemImage: "trash") }
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

    private func statusPill(_ status: String) -> some View {
        let color: Color = status == "Active" ? .plagitOnline : (status == "Suspended" ? .plagitUrgent : (status == "Banned" ? .plagitTertiary : .plagitSecondary))
        return Group {
            if status != "Active" {
                Text(status).font(PlagitFont.micro()).foregroundColor(color)
                    .lineLimit(1).fixedSize()
                    .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 1)
                    .background(Capsule().fill(color.opacity(0.08)))
            }
        }
    }

    private func planPill(_ plan: String, _ planStatus: String) -> some View {
        let color: Color = planStatus == "Active" ? .plagitOnline : (planStatus == "Trial" ? .plagitAmber : (planStatus == "Expired" ? .plagitUrgent : .plagitTertiary))
        return Text("\(plan) · \(planStatus)").font(PlagitFont.micro()).foregroundColor(color)
            .lineLimit(1).fixedSize()
            .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 1)
            .background(Capsule().fill(color.opacity(0.08)))
    }

    private func metricItem(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 2) {
            Image(systemName: icon).font(.system(size: 8, weight: .medium)).foregroundColor(.plagitTertiary)
            Text(text).font(PlagitFont.micro()).foregroundColor(.plagitSecondary)
        }
    }

    private func rateColor(_ rate: Int) -> Color {
        rate >= 80 ? .plagitOnline : (rate >= 50 ? .plagitAmber : .plagitUrgent)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack { Circle().fill(Color.plagitTealLight).frame(width: 48, height: 48); Image(systemName: "building.2").font(.system(size: 20, weight: .medium)).foregroundColor(.plagitTeal) }
            VStack(spacing: PlagitSpacing.xs) {
                Text(viewModel.searchText.isEmpty ? "No businesses match this filter" : "No results for \"\(viewModel.searchText)\"").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                Text("Try adjusting your filters or search.").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
            }
            if viewModel.selectedFilter != "All" { Button { withAnimation { viewModel.selectedFilter = "All"; viewModel.searchText = "" } } label: { Text("Show All").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal).padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm).background(Capsule().fill(Color.plagitTealLight)) } }
        }.frame(maxWidth: .infinity).padding(.horizontal, PlagitSpacing.xxl)
    }
}

#Preview { NavigationStack { AdminBusinessesView() }.preferredColorScheme(.light) }
