//
//  AdminCommunityView.swift
//  Plagit
//
//  Admin — Community Editorial & Content Control Center
//

import SwiftUI

// MARK: - View

struct AdminCommunityView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AdminCommunityViewModel()
    @State private var showSearch = false
    @State private var showDeleteAlert = false
    @State private var deletePostId: UUID?

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
                        Button { Task { await viewModel.loadPosts() } } label: {
                            Text("Retry").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal).padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm).background(Capsule().fill(Color.plagitTealLight))
                        }
                    }.padding(.horizontal, PlagitSpacing.xxl)
                    Spacer()
                case .loaded:
                    summaryCards.padding(.top, PlagitSpacing.xs)
                    filterChips.padding(.top, PlagitSpacing.sm)
                    sortRow.padding(.top, PlagitSpacing.sm)

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            // Home Placement Control
                            if viewModel.selectedFilter == "All" && viewModel.searchText.isEmpty {
                                homePlacement.padding(.top, PlagitSpacing.md)
                            }

                            if viewModel.filtered.isEmpty {
                                emptyState.padding(.top, PlagitSpacing.xxxl * 2)
                            } else {
                                VStack(spacing: 0) {
                                    ForEach(Array(viewModel.filtered.enumerated()), id: \.element.id) { idx, post in
                                        contentRow(post)
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
        }
        .navigationBarHidden(true)
        .animation(.easeInOut(duration: 0.2), value: showSearch)
        .alert("Delete Content", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let id = deletePostId {
                    Task { viewModel.deletePost(id: id) }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: { Text("This cannot be undone.") }
        .task { await viewModel.loadPosts() }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button { dismiss() } label: { Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36) }
            Spacer()
            Text("Community").font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
            Spacer()
            HStack(spacing: PlagitSpacing.lg) {
                Button { withAnimation { showSearch.toggle(); if !showSearch { viewModel.searchText = "" } } } label: {
                    Image(systemName: showSearch ? "xmark" : "magnifyingglass").font(.system(size: 18, weight: .regular)).foregroundColor(.plagitCharcoal)
                }
                Button { } label: {
                    Image(systemName: "plus.circle.fill").font(.system(size: 20, weight: .regular)).foregroundColor(.plagitTeal)
                }
            }
        }.padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.xxl).padding(.bottom, PlagitSpacing.lg)
    }

    private var searchBar: some View {
        HStack(spacing: PlagitSpacing.md) {
            Image(systemName: "magnifyingglass").font(.system(size: 14, weight: .medium)).foregroundColor(.plagitTertiary)
            TextField("Search title, author, employer…", text: $viewModel.searchText).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
            if !viewModel.searchText.isEmpty { Button { viewModel.searchText = "" } label: { Image(systemName: "xmark.circle.fill").font(.system(size: 14)).foregroundColor(.plagitTertiary) } }
        }.padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.md).background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface)).padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Summary Cards
    private var summaryCards: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PlagitSpacing.sm) {
                sumChip("All", "\(viewModel.posts.count)", .plagitCharcoal, "All")
                sumChip("Published", "\(viewModel.countFor("Published"))", .plagitOnline, "Published")
                sumChip("Drafts", "\(viewModel.countFor("Draft"))", .plagitSecondary, "Draft")
                sumChip("Scheduled", "\(viewModel.countFor("Scheduled"))", .plagitIndigo, "Scheduled")
                sumChip("Pinned", "\(viewModel.countFor("Pinned"))", .plagitAmber, "Pinned")
                sumChip("On Home", "\(viewModel.countFor("Featured on Home"))", .plagitTeal, "Featured on Home")
                sumChip("Tips", "\(viewModel.countFor("Career Tips"))", .plagitAmber, "Career Tips")
                sumChip("Training", "\(viewModel.countFor("Training"))", .plagitIndigo, "Training")
                sumChip("Employers", "\(viewModel.countFor("Featured Employers"))", .plagitTeal, "Featured Employers")
            }.padding(.horizontal, PlagitSpacing.xl)
        }
    }

    private func sumChip(_ label: String, _ count: String, _ color: Color, _ filter: String) -> some View {
        Button { withAnimation { viewModel.selectedFilter = filter } } label: {
            VStack(spacing: 2) {
                Text(count).font(PlagitFont.headline()).foregroundColor(color)
                Text(label).font(PlagitFont.micro()).foregroundColor(.plagitSecondary)
            }.frame(width: 66).padding(.vertical, PlagitSpacing.sm).background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
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
            Text("\(viewModel.filtered.count) items").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
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

    // MARK: - Home Placement Control

    private var homePlacement: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.md) {
            HStack {
                Image(systemName: "house").font(.system(size: 12, weight: .medium)).foregroundColor(.plagitTeal)
                Text("Home Preview Cards").font(PlagitFont.headline()).foregroundColor(.plagitCharcoal)
                Text("\(viewModel.homePreviewPosts.count)").font(PlagitFont.micro()).foregroundColor(.plagitTeal)
                    .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 2).background(Capsule().fill(Color.plagitTeal.opacity(0.08)))
                Spacer()
            }

            if viewModel.homePreviewPosts.isEmpty {
                Text("No content featured on Candidate Home").font(PlagitFont.caption()).foregroundColor(.plagitTertiary)
            } else {
                ForEach(Array(viewModel.homePreviewPosts.enumerated()), id: \.element.id) { idx, post in
                    HStack(spacing: PlagitSpacing.md) {
                        Text("\(idx + 1)").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal).frame(width: 20)
                        catIcon(post.category)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(post.title).font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal).lineLimit(1)
                            Text(post.category).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                        }
                        Spacer()
                        Button {
                            Task { viewModel.setFeaturedOnHome(id: post.id, featured: false) }
                        } label: {
                            Image(systemName: "xmark").font(.system(size: 9, weight: .bold)).foregroundColor(.plagitTertiary)
                        }
                    }.padding(.vertical, PlagitSpacing.xs)
                }
            }
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground).shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        .overlay(RoundedRectangle(cornerRadius: PlagitRadius.xl).stroke(Color.plagitTeal.opacity(0.12), lineWidth: 1))
        .padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Content Row
    private func contentRow(_ post: AdminContent) -> some View {
        Menu {
            Button { } label: { Label("Preview", systemImage: "eye") }
            if post.status == "Draft" || post.status == "Scheduled" { Button { viewModel.updateStatus(id: post.id, status: "Published") } label: { Label("Publish", systemImage: "checkmark.circle") } }
            if post.status == "Published" { Button { viewModel.updateStatus(id: post.id, status: "Draft") } label: { Label("Unpublish", systemImage: "xmark.circle") } }
            if post.isPinned { Button { viewModel.setPinned(id: post.id, pinned: false) } label: { Label("Unpin", systemImage: "pin.slash") } }
            else { Button { viewModel.setPinned(id: post.id, pinned: true) } label: { Label("Pin", systemImage: "pin") } }
            if post.isFeaturedOnHome { Button { viewModel.setFeaturedOnHome(id: post.id, featured: false) } label: { Label("Remove from Home", systemImage: "house.slash") } }
            else if post.status == "Published" { Button { viewModel.setFeaturedOnHome(id: post.id, featured: true) } label: { Label("Feature on Home", systemImage: "house") } }
            if post.status != "Archived" { Button { viewModel.updateStatus(id: post.id, status: "Archived") } label: { Label("Archive", systemImage: "archivebox") } }
            Button { } label: { Label("Duplicate", systemImage: "doc.on.doc") }
            if !post.linkedEmployer.isEmpty { Button { } label: { Label("View Employer", systemImage: "building.2") } }
            if !post.linkedJob.isEmpty { Button { } label: { Label("View Job", systemImage: "briefcase") } }
            Divider()
            Button(role: .destructive) { deletePostId = post.id; showDeleteAlert = true } label: { Label("Delete", systemImage: "trash") }
        } label: {
            HStack(alignment: .top, spacing: PlagitSpacing.md) {
                catIcon(post.category)

                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                    // Title + badges
                    HStack(spacing: PlagitSpacing.sm) {
                        Text(post.title).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal).lineLimit(1)
                        statusBadge(post.status)
                    }

                    // Category + author
                    HStack(spacing: PlagitSpacing.sm) {
                        catPill(post.category)
                        Text(post.author).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                        if post.isPinned { pill("Pinned", .plagitAmber) }
                        if post.isFeaturedOnHome { pill("Home", .plagitTeal) }
                    }

                    // Links
                    if !post.linkedEmployer.isEmpty || !post.linkedJob.isEmpty {
                        HStack(spacing: PlagitSpacing.sm) {
                            if !post.linkedEmployer.isEmpty {
                                HStack(spacing: 2) { Image(systemName: "building.2").font(.system(size: 8, weight: .medium)).foregroundColor(.plagitIndigo); Text(post.linkedEmployer).font(PlagitFont.micro()).foregroundColor(.plagitIndigo) }
                            }
                            if !post.linkedJob.isEmpty {
                                HStack(spacing: 2) { Image(systemName: "briefcase").font(.system(size: 8, weight: .medium)).foregroundColor(.plagitTeal); Text(post.linkedJob).font(PlagitFont.micro()).foregroundColor(.plagitTeal) }
                            }
                        }
                    }

                    // Metrics + dates
                    HStack(spacing: PlagitSpacing.md) {
                        if post.views > 0 { metricItem("eye", "\(post.views)") }
                        if post.saves > 0 { metricItem("bookmark", "\(post.saves)") }
                        Text(post.readTime).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                        Text("·").foregroundColor(.plagitTertiary)
                        Text(post.status == "Published" ? "Published \(post.publishedDate)" : "Created \(post.createdDate)").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                    }
                }

                Spacer(minLength: 0)
                Image(systemName: "ellipsis").font(.system(size: 14, weight: .medium)).foregroundColor(.plagitTertiary)
            }.padding(.horizontal, PlagitSpacing.xl).padding(.vertical, PlagitSpacing.lg)
        }.buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func catIcon(_ cat: String) -> some View {
        let icon: String = { switch cat { case "Career Tips": return "lightbulb.fill"; case "Training": return "book.fill"; case "Featured Employers": return "building.2.fill"; case "Success Stories": return "star.fill"; case "Job Highlights": return "briefcase.fill"; default: return "text.bubble" } }()
        let color: Color = { switch cat { case "Career Tips": return .plagitAmber; case "Training": return .plagitIndigo; case "Featured Employers": return .plagitTeal; case "Success Stories": return .plagitOnline; case "Job Highlights": return .plagitVerified; default: return .plagitSecondary } }()
        return ZStack {
            RoundedRectangle(cornerRadius: PlagitRadius.sm).fill(color.opacity(0.08)).frame(width: 36, height: 36)
            Image(systemName: icon).font(.system(size: 13, weight: .medium)).foregroundColor(color)
        }
    }

    private func catPill(_ cat: String) -> some View {
        let color: Color = { switch cat { case "Career Tips": return .plagitAmber; case "Training": return .plagitIndigo; case "Featured Employers": return .plagitTeal; case "Success Stories": return .plagitOnline; case "Job Highlights": return .plagitVerified; default: return .plagitSecondary } }()
        return Text(cat).font(PlagitFont.micro()).foregroundColor(color).padding(.horizontal, PlagitSpacing.sm - 2).padding(.vertical, 1).background(Capsule().fill(color.opacity(0.08)))
    }

    private func pill(_ text: String, _ color: Color) -> some View {
        Text(text).font(PlagitFont.micro()).foregroundColor(color).padding(.horizontal, PlagitSpacing.sm - 2).padding(.vertical, 1).background(Capsule().fill(color.opacity(0.08)))
    }

    private func statusBadge(_ status: String) -> some View {
        let color: Color = status == "Published" ? .plagitOnline : (status == "Draft" ? .plagitSecondary : (status == "Scheduled" ? .plagitIndigo : .plagitTertiary))
        return Text(status).font(PlagitFont.micro()).foregroundColor(color).padding(.horizontal, PlagitSpacing.sm - 2).padding(.vertical, 1).background(Capsule().fill(color.opacity(0.08))).lineLimit(1).fixedSize()
    }

    private func metricItem(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 2) {
            Image(systemName: icon).font(.system(size: 8, weight: .medium)).foregroundColor(.plagitTertiary)
            Text(text).font(PlagitFont.micro()).foregroundColor(.plagitSecondary)
        }
    }

    private var emptyState: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack { Circle().fill(Color.plagitTealLight).frame(width: 48, height: 48); Image(systemName: "text.bubble").font(.system(size: 20, weight: .medium)).foregroundColor(.plagitTeal) }
            VStack(spacing: PlagitSpacing.xs) {
                Text(viewModel.searchText.isEmpty ? "No content matches this filter" : "No results for \"\(viewModel.searchText)\"").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                Text("Try adjusting your filters or search.").font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
            }
            if viewModel.selectedFilter != "All" { Button { withAnimation { viewModel.selectedFilter = "All"; viewModel.searchText = "" } } label: { Text("Show All").font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal).padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm).background(Capsule().fill(Color.plagitTealLight)) } }
        }.frame(maxWidth: .infinity).padding(.horizontal, PlagitSpacing.xxl)
    }
}

#Preview { NavigationStack { AdminCommunityView() }.preferredColorScheme(.light) }
