//
//  SavedPostsView.swift
//  Plagit
//
//  Saved posts section with category filters and search.
//

import SwiftUI

struct SavedPostsView: View {
    let allPosts: [FeedPostDTO]
    let savedPostIds: Set<String>
    var onUnsave: (FeedPostDTO) -> Void
    var onPostTap: (FeedPostDTO) -> Void
    var onToast: ((String) -> Void)? = nil

    @State private var searchText = ""
    @State private var selectedCategory: SavedPostCategory? = nil
    @State private var changeCategoryPost: FeedPostDTO?
    @State private var showChangeCategory = false
    @State private var refreshTick = 0  // forces re-render after store mutation

    private var store: SavedPostStore { .shared }

    private var savedPosts: [FeedPostDTO] {
        _ = refreshTick  // read to create dependency
        return allPosts.filter { savedPostIds.contains($0.id) }
    }

    private var filteredPosts: [FeedPostDTO] {
        _ = refreshTick
        var result = savedPosts

        // Category filter
        if let cat = selectedCategory {
            let idsInCategory = Set(store.map.filter { $0.value == cat }.map(\.key))
            result = result.filter { idsInCategory.contains($0.id) }
        }

        // Search
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            result = result.filter { post in
                let catLabel = store.category(for: post.id)?.label.lowercased() ?? ""
                return post.body.lowercased().contains(q)
                    || (post.authorName?.lowercased().contains(q) ?? false)
                    || (post.tag?.lowercased().contains(q) ?? false)
                    || catLabel.contains(q)
            }
        }

        return result
    }

    private func countFor(_ cat: SavedPostCategory) -> Int {
        _ = refreshTick
        return savedPosts.filter { store.category(for: $0.id) == cat }.count
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack(spacing: PlagitSpacing.md) {
                Image(systemName: "magnifyingglass").font(.system(size: 14, weight: .medium)).foregroundColor(.plagitTertiary)
                TextField(L10n.t("search_saved"), text: $searchText)
                    .font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
                if !searchText.isEmpty {
                    Button { searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill").font(.system(size: 14)).foregroundColor(.plagitTertiary)
                    }
                }
            }
            .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.md)
            .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitSurface))
            .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.sm)

            // Category chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: PlagitSpacing.sm) {
                    chipButton(label: L10n.all, icon: nil, count: savedPosts.count, isActive: selectedCategory == nil) {
                        withAnimation(.easeInOut(duration: 0.2)) { selectedCategory = nil }
                    }
                    ForEach(SavedPostCategory.allCases, id: \.self) { cat in
                        chipButton(label: cat.label, icon: cat.icon, count: countFor(cat), isActive: selectedCategory == cat) {
                            withAnimation(.easeInOut(duration: 0.2)) { selectedCategory = cat }
                        }
                    }
                }
                .padding(.horizontal, PlagitSpacing.xl)
            }
            .padding(.top, PlagitSpacing.sm)

            // Content
            if savedPosts.isEmpty {
                Spacer()
                emptyState
                Spacer()
            } else if filteredPosts.isEmpty {
                Spacer()
                noResultsState
                Spacer()
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: PlagitSpacing.md) {
                        ForEach(filteredPosts) { post in
                            savedPostCard(post)
                        }
                    }
                    .padding(.horizontal, PlagitSpacing.xl)
                    .padding(.top, PlagitSpacing.lg)
                    .padding(.bottom, PlagitSpacing.xxxl)
                }
            }
        }
        .sheet(isPresented: $showChangeCategory) {
            if let post = changeCategoryPost {
                SaveCategoryPickerSheet(
                    postPreview: post.body,
                    currentCategory: store.category(for: post.id)
                ) { newCat in
                    store.updateCategory(postId: post.id, to: newCat)
                    refreshTick += 1
                    onToast?("Moved to \(newCat.label)")
                }
            }
        }
    }

    // MARK: - Card

    private func savedPostCard(_ post: FeedPostDTO) -> some View {
        let cat = store.category(for: post.id) ?? .other
        let hue = post.authorAvatarHue ?? 0.5

        return Button { onPostTap(post) } label: {
            VStack(alignment: .leading, spacing: PlagitSpacing.md) {
                HStack(spacing: PlagitSpacing.md) {
                    ProfileAvatarView(photoUrl: post.authorPhotoUrl, initials: post.authorInitials ?? "—", hue: hue, size: 36, verified: post.authorVerified == true)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(post.authorName ?? "Unknown").font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal)
                        if let loc = post.authorLocation, !loc.isEmpty {
                            Text(loc).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                        }
                    }
                    Spacer()
                    // Category pill — tap to change
                    Button {
                        changeCategoryPost = post
                        showChangeCategory = true
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: cat.icon).font(.system(size: 9, weight: .medium))
                            Text(cat.label).font(PlagitFont.micro())
                        }
                        .foregroundColor(.plagitTeal)
                        .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 3)
                        .background(Capsule().fill(Color.plagitTealLight))
                    }
                }

                Text(post.body).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
                    .lineLimit(3).multilineTextAlignment(.leading)

                // Image thumbnail
                if let photos = post.media?.filter({ $0.mediaType == "photo" }), let first = photos.first {
                    AsyncImage(url: URL(string: first.url)) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFill()
                                .frame(maxWidth: .infinity, maxHeight: 120)
                                .clipShape(RoundedRectangle(cornerRadius: PlagitRadius.md))
                        }
                    }
                }

                // Footer
                HStack(spacing: PlagitSpacing.lg) {
                    Button {
                        withAnimation(.easeOut(duration: 0.25)) { onUnsave(post) }
                    } label: {
                        HStack(spacing: PlagitSpacing.xs) {
                            Image(systemName: "bookmark.slash").font(.system(size: 12, weight: .medium))
                            Text(L10n.t("unsave")).font(PlagitFont.micro())
                        }.foregroundColor(.plagitSecondary)
                    }

                    Spacer()

                    HStack(spacing: PlagitSpacing.md) {
                        if post.likeCount > 0 {
                            Label("\(post.likeCount)", systemImage: "heart").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                        }
                        if post.commentCount > 0 {
                            Label("\(post.commentCount)", systemImage: "bubble.left").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                        }
                    }
                }
            }
            .padding(PlagitSpacing.xl)
            .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground)
                .shadow(color: PlagitShadow.subtleShadowColor, radius: PlagitShadow.subtleShadowRadius, y: PlagitShadow.subtleShadowY))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Chips

    private func chipButton(label: String, icon: String?, count: Int, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: PlagitSpacing.xs) {
                if let icon {
                    Image(systemName: icon).font(.system(size: 10, weight: .medium))
                }
                Text(label).font(PlagitFont.captionMedium())
                if count > 0 {
                    Text("\(count)").font(PlagitFont.micro())
                        .foregroundColor(isActive ? .white.opacity(0.7) : .plagitTertiary)
                }
            }
            .foregroundColor(isActive ? .white : .plagitSecondary)
            .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm)
            .background(Capsule().fill(isActive ? Color.plagitTeal : Color.plagitSurface))
            .overlay(Capsule().stroke(isActive ? Color.clear : Color.plagitBorder, lineWidth: 0.5))
        }
    }

    // MARK: - Empty States

    private var emptyState: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack {
                Circle().fill(Color.plagitTealLight).frame(width: 56, height: 56)
                Image(systemName: "bookmark").font(.system(size: 24, weight: .medium)).foregroundColor(.plagitTeal)
            }
            Text(L10n.t("no_saved_posts")).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
            Text(L10n.t("no_saved_posts_hint")).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
                .multilineTextAlignment(.center)
        }.padding(.horizontal, PlagitSpacing.xxl)
    }

    private var noResultsState: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack {
                Circle().fill(Color.plagitSurface).frame(width: 48, height: 48)
                Image(systemName: "magnifyingglass").font(.system(size: 20, weight: .medium)).foregroundColor(.plagitTertiary)
            }
            Text(L10n.t("no_saved_results")).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
            if selectedCategory != nil || !searchText.isEmpty {
                Button {
                    selectedCategory = nil
                    searchText = ""
                } label: {
                    Text(L10n.t("clear_filters")).font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                        .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.sm)
                        .background(Capsule().fill(Color.plagitTealLight))
                }
            }
        }.padding(.horizontal, PlagitSpacing.xxl)
    }
}
