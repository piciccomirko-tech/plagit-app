//
//  AdminContentFeaturedView.swift
//  Plagit
//
//  Admin — Content / Featured Placement Control
//

import SwiftUI

struct AdminContentFeaturedView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AdminFeaturedContentViewModel()
    @State private var showSearch = false
    @State private var showDeleteAlert = false
    @State private var deleteItemId: UUID?

    var body: some View {
        ZStack {
            Color.plagitBackground.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar.background(Color.plagitBackground).zIndex(1)
                if showSearch { searchBar.transition(.move(edge: .top).combined(with: .opacity)) }

                switch viewModel.loadingState {
                case .idle, .loading:
                    Spacer()
                    ProgressView().tint(.plagitTeal)
                    Spacer()
                case .error(let message):
                    Spacer()
                    VStack(spacing: PlagitSpacing.lg) {
                        Image(systemName: "exclamationmark.triangle").font(.system(size: 32, weight: .medium)).foregroundColor(.plagitAmber)
                        Text(message).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal).multilineTextAlignment(.center)
                        Button { Task { await viewModel.loadItems() } } label: {
                            Text("Retry").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal).padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm).background(Capsule().fill(Color.plagitTealLight))
                        }
                    }.padding(.horizontal, PlagitSpacing.xxl)
                    Spacer()
                case .loaded:
                    summaryCards.padding(.top, PlagitSpacing.xs)
                    filterChips.padding(.top, PlagitSpacing.sm)
                    sortRow.padding(.top, PlagitSpacing.sm)

                    ScrollView(.vertical, showsIndicators: false) {
                        if viewModel.filtered.isEmpty { emptyState.padding(.top, PlagitSpacing.xxxl * 2) }
                        else {
                            VStack(spacing: 0) {
                                ForEach(Array(viewModel.filtered.enumerated()), id: \.element.id) { idx, item in
                                    itemRow(item)
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
        .navigationBarHidden(true)
        .animation(.easeInOut(duration: 0.2), value: showSearch)
        .alert("Delete Content", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let id = deleteItemId {
                    Task { viewModel.deleteItem(id: id) }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: { Text("This cannot be undone.") }
        .task { await viewModel.loadItems() }
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: { Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36) }
            Spacer()
            Text("Content / Featured").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
            Spacer()
            HStack(spacing: PlagitSpacing.lg) {
                Button { withAnimation { showSearch.toggle(); if !showSearch { viewModel.searchText = "" } } } label: { Image(systemName: showSearch ? "xmark" : "magnifyingglass").font(.system(size: 18, weight: .regular)).foregroundColor(.plagitCharcoal) }
                Button { } label: { Image(systemName: "plus.circle.fill").font(.system(size: 20)).foregroundColor(.plagitTeal) }
            }
        }.padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.xxl).padding(.bottom, PlagitSpacing.lg)
    }

    private var searchBar: some View {
        HStack(spacing: PlagitSpacing.md) {
            Image(systemName: "magnifyingglass").font(.system(size: 14, weight: .medium)).foregroundColor(.plagitTertiary)
            TextField("Search title, employer, placement…", text: $viewModel.searchText).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
            if !viewModel.searchText.isEmpty { Button { viewModel.searchText = "" } label: { Image(systemName: "xmark.circle.fill").font(.system(size: 14)).foregroundColor(.plagitTertiary) } }
        }.padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.md).background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface)).padding(.horizontal, PlagitSpacing.xl)
    }

    private var summaryCards: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PlagitSpacing.sm) {
                sumChip("All", "\(viewModel.items.count)", .plagitCharcoal, "All")
                sumChip("Employers", "\(viewModel.countFor("Featured Employer"))", .plagitTeal, "Featured Employer")
                sumChip("Jobs", "\(viewModel.countFor("Featured Job"))", .plagitIndigo, "Featured Job")
                sumChip("Banners", "\(viewModel.countFor("Home Banner"))", .plagitAmber, "Home Banner")
                sumChip("Active", "\(viewModel.countFor("Active"))", .plagitOnline, "Active")
                sumChip("Scheduled", "\(viewModel.countFor("Scheduled"))", .plagitIndigo, "Scheduled")
                sumChip("Pinned", "\(viewModel.countFor("Pinned"))", .plagitAmber, "Pinned")
                sumChip("Expired", "\(viewModel.countFor("Expired"))", .plagitTertiary, "Expired")
            }.padding(.horizontal, PlagitSpacing.xl)
        }
    }

    private func sumChip(_ label: String, _ count: String, _ color: Color, _ filter: String) -> some View {
        Button { withAnimation { viewModel.selectedFilter = filter } } label: {
            VStack(spacing: 2) { Text(count).font(PlagitFont.headline()).foregroundColor(color); Text(label).font(PlagitFont.micro()).foregroundColor(.plagitSecondary) }
                .frame(width: 66).padding(.vertical, PlagitSpacing.sm).background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PlagitSpacing.sm) {
                ForEach(viewModel.filters, id: \.self) { f in
                    let isActive = viewModel.selectedFilter == f; let c = viewModel.countFor(f)
                    Button { withAnimation { viewModel.selectedFilter = f } } label: {
                        HStack(spacing: PlagitSpacing.xs) { Text(f).font(PlagitFont.captionMedium()); if f != "All" && c > 0 { Text("\(c)").font(PlagitFont.micro()).foregroundColor(isActive ? .white.opacity(0.7) : .plagitTertiary) } }
                            .foregroundColor(isActive ? .white : .plagitSecondary).padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm)
                            .background(Capsule().fill(isActive ? Color.plagitTeal : Color.plagitSurface)).overlay(Capsule().stroke(isActive ? Color.clear : Color.plagitBorder, lineWidth: 0.5))
                    }
                }
            }.padding(.horizontal, PlagitSpacing.xl)
        }
    }

    private var sortRow: some View {
        HStack { Text("\(viewModel.filtered.count) items").font(PlagitFont.caption()).foregroundColor(.plagitSecondary); Spacer()
            Menu {
                ForEach(viewModel.sortOptions, id: \.self) { o in Button(o) { viewModel.selectedSort = o } }
            } label: {
                HStack(spacing: PlagitSpacing.xs) { Text("Sort: \(viewModel.selectedSort)").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal); Image(systemName: "chevron.down").font(.system(size: 9, weight: .semibold)).foregroundColor(.plagitTeal) }
            }
        }.padding(.horizontal, PlagitSpacing.xl)
    }

    private func itemRow(_ item: AdminFeaturedItem) -> some View {
        Menu {
            if item.status == "Draft" || item.status == "Scheduled" { Button { viewModel.updateStatus(id: item.id, status: "Active") } label: { Label("Activate", systemImage: "checkmark.circle") } }
            if item.status == "Active" { Button { viewModel.updateStatus(id: item.id, status: "Draft") } label: { Label("Deactivate", systemImage: "xmark.circle") } }
            if item.isPinned { Button { viewModel.setPinned(id: item.id, pinned: false) } label: { Label("Unpin", systemImage: "pin.slash") } }
            else { Button { viewModel.setPinned(id: item.id, pinned: true) } label: { Label("Pin", systemImage: "pin") } }
            Button { } label: { Label("Duplicate", systemImage: "doc.on.doc") }
            Button { } label: { Label("Add Note", systemImage: "note.text") }
            Divider()
            Button(role: .destructive) { deleteItemId = item.id; showDeleteAlert = true } label: { Label("Delete", systemImage: "trash") }
        } label: {
            HStack(alignment: .top, spacing: PlagitSpacing.md) {
                ZStack { RoundedRectangle(cornerRadius: PlagitRadius.sm).fill(typeColor(item.type).opacity(0.08)).frame(width: 36, height: 36); Image(systemName: typeIcon(item.type)).font(.system(size: 13, weight: .medium)).foregroundColor(typeColor(item.type)) }
                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    HStack(spacing: PlagitSpacing.sm) { Text(item.title).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal).lineLimit(1); statusBadge(item.status); if item.isPinned { pill("Pinned", .plagitAmber) } }
                    HStack(spacing: PlagitSpacing.sm) { pill(item.type, typeColor(item.type)); Text(item.placement).font(PlagitFont.micro()).foregroundColor(.plagitTertiary) }
                    if !item.linkedEntity.isEmpty { HStack(spacing: 2) { Image(systemName: "link").font(.system(size: 8, weight: .medium)).foregroundColor(.plagitTertiary); Text(item.linkedEntity).font(PlagitFont.micro()).foregroundColor(.plagitSecondary) } }
                    HStack(spacing: PlagitSpacing.md) {
                        if item.views > 0 { HStack(spacing: 2) { Image(systemName: "eye").font(.system(size: 8, weight: .medium)).foregroundColor(.plagitTertiary); Text("\(item.views)").font(PlagitFont.micro()).foregroundColor(.plagitSecondary) } }
                        if item.clicks > 0 { HStack(spacing: 2) { Image(systemName: "hand.tap").font(.system(size: 8, weight: .medium)).foregroundColor(.plagitTertiary); Text("\(item.clicks)").font(PlagitFont.micro()).foregroundColor(.plagitSecondary) } }
                        Text("#\(item.priority)").font(PlagitFont.micro()).foregroundColor(.plagitTeal)
                        Text(item.lastUpdated).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                    }
                }
                Spacer(minLength: 0); Image(systemName: "ellipsis").font(.system(size: 14, weight: .medium)).foregroundColor(.plagitTertiary)
            }.padding(.horizontal, PlagitSpacing.xl).padding(.vertical, PlagitSpacing.lg)
        }.buttonStyle(.plain)
    }

    private func typeIcon(_ t: String) -> String { switch t { case "Featured Employer": return "building.2.fill"; case "Featured Job": return "briefcase.fill"; case "Home Banner": return "rectangle.fill"; case "Recommended": return "star.fill"; case "Onboarding Card": return "hand.wave.fill"; default: return "doc" } }
    private func typeColor(_ t: String) -> Color { switch t { case "Featured Employer": return .plagitTeal; case "Featured Job": return .plagitIndigo; case "Home Banner": return .plagitAmber; case "Recommended": return .plagitOnline; case "Onboarding Card": return .plagitVerified; default: return .plagitSecondary } }
    private func statusBadge(_ s: String) -> some View { let c: Color = s == "Active" ? .plagitOnline : (s == "Scheduled" ? .plagitIndigo : (s == "Expired" ? .plagitTertiary : .plagitSecondary)); return Text(s).font(PlagitFont.micro()).foregroundColor(c).padding(.horizontal, PlagitSpacing.sm - 2).padding(.vertical, 1).background(Capsule().fill(c.opacity(0.08))).lineLimit(1).fixedSize() }
    private func pill(_ t: String, _ c: Color) -> some View { Text(t).font(PlagitFont.micro()).foregroundColor(c).padding(.horizontal, PlagitSpacing.sm - 2).padding(.vertical, 1).background(Capsule().fill(c.opacity(0.08))) }

    private var emptyState: some View {
        VStack(spacing: PlagitSpacing.lg) { ZStack { Circle().fill(Color.plagitTealLight).frame(width: 48, height: 48); Image(systemName: "star").font(.system(size: 20, weight: .medium)).foregroundColor(.plagitTeal) }; VStack(spacing: PlagitSpacing.xs) { Text(viewModel.searchText.isEmpty ? "No content matches" : "No results for \"\(viewModel.searchText)\"").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal); Text("Try adjusting filters.").font(PlagitFont.caption()).foregroundColor(.plagitSecondary) }
            if viewModel.selectedFilter != "All" { Button { withAnimation { viewModel.selectedFilter = "All"; viewModel.searchText = "" } } label: { Text("Show All").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal).padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm).background(Capsule().fill(Color.plagitTealLight)) } }
        }.frame(maxWidth: .infinity).padding(.horizontal, PlagitSpacing.xxl)
    }
}

#Preview { NavigationStack { AdminContentFeaturedView() }.preferredColorScheme(.light) }
