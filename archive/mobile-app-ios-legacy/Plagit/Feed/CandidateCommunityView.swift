//
//  CandidateCommunityView.swift
//  Plagit
//
//  Social feed for the hospitality community.
//  Shared by candidate and business accounts via /v1/feed.
//

import SwiftUI
import PhotosUI
import AVFoundation

struct CandidateCommunityView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var posts: [FeedPostDTO] = []
    @State private var isLoading = true
    @State private var loadError: String?

    // Tabs
    @State private var selectedTab = "For You"
    private let tabs = ["For You", "Following", "Nearby", "Saved"]
    @State private var pendingSavePost: FeedPostDTO?

    // Role filter
    @State private var selectedRole = "All"
    private let roles = ["All", "Chef", "Waiter", "Bartender", "Manager", "Reception", "Kitchen Porter"]

    // Create post
    @State private var showCreatePost = false

    // Comments — use item-based sheet to guarantee data is available
    @State private var commentsPost: FeedPostDTO?

    // Media viewer — item-based presentation guarantees data is ready
    @State private var photoViewerItem: PhotoViewerItem?
    @State private var showVideoViewer = false
    @State private var viewerVideoUrl: String = ""

    // Activity
    @State private var showActivity = false
    @State private var unreadCount = 0
    @State private var toastMessage: String?

    // Liked posts tracking (local state for instant UI)
    @State private var likedPosts: Set<String> = []
    @State private var likeCounts: [String: Int] = [:]
    @State private var followedUsers: Set<String> = []

    // View tracking
    @State private var viewedPosts: Set<String> = []
    @State private var viewCounts: [String: Int] = [:]

    // Post action menu state
    @State private var actionMenuPost: FeedPostDTO?
    @State private var reportPost: FeedPostDTO?
    @State private var editPost: FeedPostDTO?
    @State private var showDeleteConfirm = false
    @State private var deleteTargetPost: FeedPostDTO?
    @State private var showBlockConfirm = false
    @State private var blockTargetUserId: String?
    @State private var blockTargetName: String?
    @State private var insightsPost: FeedPostDTO?
    @State private var savedPosts: Set<String> = []
    @State private var mutedUsers: Set<String> = []
    @State private var hiddenPosts: Set<String> = []

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.plagitBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                tabRow.padding(.top, PlagitSpacing.xs)
                if selectedTab != "Saved" {
                    roleChips.padding(.top, PlagitSpacing.xs)
                }

                if selectedTab == "Saved" {
                    SavedPostsView(
                        allPosts: posts,
                        savedPostIds: savedPosts,
                        onUnsave: { post in handleSave(post) },
                        onPostTap: { post in commentsPost = post },
                        onToast: { msg in showToast(msg) }
                    )
                } else if isLoading {
                    Spacer(); ProgressView().tint(.plagitTeal); Spacer()
                } else if let error = loadError {
                    Spacer()
                    VStack(spacing: PlagitSpacing.md) {
                        Image(systemName: "wifi.exclamationmark").font(.system(size: 32)).foregroundColor(.plagitTertiary)
                        Text(error).font(PlagitFont.caption()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center)
                        Button { Task { await load() } } label: { Text(L10n.retry).font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal) }
                    }.padding(PlagitSpacing.xxl)
                    Spacer()
                } else if posts.isEmpty {
                    Spacer(); emptyState; Spacer()
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: PlagitSpacing.lg) {
                            ForEach(posts.filter { !hiddenPosts.contains($0.id) && !mutedUsers.contains($0.userId ?? "") }) { post in
                                postCard(post)
                            }
                        }
                        .padding(.horizontal, PlagitSpacing.xl)
                        .padding(.top, PlagitSpacing.lg)
                        .padding(.bottom, PlagitSpacing.xxxl)
                    }
                    .refreshable { await load() }
                }
            }

            // Toast overlay
            if let msg = toastMessage {
                HStack(spacing: PlagitSpacing.sm) {
                    Image(systemName: "checkmark.circle.fill").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitOnline)
                    Text(msg).font(PlagitFont.bodyMedium()).foregroundColor(.white)
                }
                .padding(.horizontal, PlagitSpacing.xxl).padding(.vertical, PlagitSpacing.lg)
                .background(RoundedRectangle(cornerRadius: PlagitRadius.lg).fill(Color.plagitCharcoal.opacity(0.92)))
                .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                .padding(.bottom, PlagitSpacing.xxxl + 10)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showCreatePost) {
            CreatePostSheet { newPost in
                if let newPost { posts.insert(newPost, at: 0) }
                else { await load() }
            }
        }
        .sheet(item: $insightsPost) { post in
            PostInsightsSheet(post: post, viewCountOverride: viewCounts[post.id] ?? post.viewCount ?? 0, isPremium: SubscriptionManager.shared.isCandidatePremium)
        }
        .sheet(item: $commentsPost) { post in
            CommentsSheet(post: post)
        }
        .fullScreenCover(item: $photoViewerItem) { item in
            PhotoViewerWrapper(images: item.images, startIndex: item.startIndex)
        }
        .fullScreenCover(isPresented: $showVideoViewer) {
            FeedVideoPlayerView(videoUrl: viewerVideoUrl)
        }
        .sheet(item: $pendingSavePost) { post in
            SaveCategoryPickerSheet(postPreview: post.body) { category in
                completeSave(post, category: category)
            }
        }
        .sheet(item: $actionMenuPost) { post in
            PostActionMenu(
                post: post,
                userRole: FeedUserRole.current,
                isSaved: savedPosts.contains(post.id),
                onSave: { handleSave(post) },
                onShare: { sharePost(post); actionMenuPost = nil },
                onCopyLink: { handleCopyLink(post) },
                onNotInterested: { handleNotInterested(post) },
                onMuteUser: { handleMuteUser(post) },
                onBlockUser: {
                    actionMenuPost = nil
                    blockTargetUserId = post.userId
                    blockTargetName = post.authorName
                    showBlockConfirm = true
                },
                onReport: { actionMenuPost = nil; reportPost = post },
                onEdit: { actionMenuPost = nil; editPost = post },
                onDelete: {
                    actionMenuPost = nil
                    deleteTargetPost = post
                    showDeleteConfirm = true
                },
                onToggleNotifications: { handleToggleNotifications(post) },
                onAdminRemove: { handleAdminRemove(post) },
                onAdminMarkSpam: { handleAdminMarkSpam(post) },
                onAdminSuspend: { handleAdminSuspend(post) },
                onAdminViewReports: { actionMenuPost = nil; showToast("Reports viewer coming soon") }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.hidden)
        }
        .sheet(item: $reportPost) { post in
            ReportPostSheet(post: post) { reason, details in
                Task { await FeedService.shared.reportPost(postId: post.id, reason: reason, details: details) }
            }
        }
        .sheet(item: $editPost) { post in
            EditPostSheet(post: post) { newBody in
                let success = await FeedService.shared.updatePost(postId: post.id, body: newBody)
                if success {
                    if let idx = posts.firstIndex(where: { $0.id == post.id }) {
                        var updated = posts[idx]
                        updated = FeedPostDTO(
                            id: updated.id, body: newBody, imageUrl: updated.imageUrl, videoUrl: updated.videoUrl,
                            location: updated.location, tag: updated.tag, roleCategory: updated.roleCategory,
                            likeCount: updated.likeCount, commentCount: updated.commentCount, viewCount: updated.viewCount, saveCount: updated.saveCount,
                            latitude: updated.latitude, longitude: updated.longitude, createdAt: updated.createdAt,
                            userId: updated.userId, authorName: updated.authorName, authorType: updated.authorType,
                            authorPhotoUrl: updated.authorPhotoUrl, authorAvatarHue: updated.authorAvatarHue,
                            authorVerified: updated.authorVerified, authorSubtitle: updated.authorSubtitle,
                            authorLocation: updated.authorLocation, authorNationality: updated.authorNationality,
                            authorNationalityCode: updated.authorNationalityCode, authorCountryCode: updated.authorCountryCode,
                            authorInitials: updated.authorInitials, isLiked: updated.isLiked, isFollowing: updated.isFollowing,
                            isOwn: updated.isOwn, isSaved: updated.isSaved, media: updated.media
                        )
                        posts[idx] = updated
                    }
                    showToast(L10n.t("post_updated"))
                }
                return success
            }
        }
        .alert(L10n.t("delete_post"), isPresented: $showDeleteConfirm) {
            Button(L10n.t("delete"), role: .destructive) {
                guard let post = deleteTargetPost else { return }
                Task {
                    await FeedService.shared.deletePost(postId: post.id)
                    posts.removeAll { $0.id == post.id }
                    showToast(L10n.t("post_deleted"))
                }
            }
            Button(L10n.cancel, role: .cancel) { deleteTargetPost = nil }
        } message: {
            Text("This action cannot be undone.")
        }
        .alert(L10n.t("block_user"), isPresented: $showBlockConfirm) {
            Button(L10n.t("block"), role: .destructive) {
                guard let uid = blockTargetUserId else { return }
                Task {
                    await FeedService.shared.blockUser(userId: uid)
                    posts.removeAll { $0.userId == uid }
                    showToast("\(blockTargetName ?? "User") blocked")
                }
            }
            Button(L10n.cancel, role: .cancel) { blockTargetUserId = nil; blockTargetName = nil }
        } message: {
            Text("You won't see posts from \(blockTargetName ?? "this user") and they won't be able to interact with you.")
        }
        .navigationDestination(isPresented: $showActivity) {
            FeedActivityView().navigationBarHidden(true)
        }
        .task { await load(); unreadCount = await FeedService.shared.unreadCount() }
        .onAppear { Task { unreadCount = await FeedService.shared.unreadCount() } }
    }

    private func load() async {
        isLoading = posts.isEmpty
        loadError = nil
        let tabParam: String? = selectedTab == "Nearby" ? "nearby" : selectedTab == "Following" ? "following" : nil
        let roleParam: String? = selectedRole == "All" ? nil : selectedRole.lowercased().replacingOccurrences(of: " ", with: "_")
        let fetched = await FeedService.shared.fetchPosts(limit: 50, tab: tabParam, role: roleParam)
        // Preserve locally created posts (not yet on server) at top
        let localPosts = posts.filter { $0.userId == nil }
        let fetchedIds = Set(fetched.map(\.id))
        posts = localPosts.filter { !fetchedIds.contains($0.id) } + fetched
        for p in posts {
            if p.isLiked == true { likedPosts.insert(p.id) }
            likeCounts[p.id] = p.likeCount
            if p.isFollowing == true, let uid = p.userId { followedUsers.insert(uid) }
            viewCounts[p.id] = p.viewCount ?? 0
            if p.isSaved == true { savedPosts.insert(p.id) }
        }
        isLoading = false
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(spacing: PlagitSpacing.md) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left").font(.system(size: 18, weight: .medium)).foregroundColor(.plagitCharcoal).frame(width: 36, height: 36)
            }
            Spacer()
            Text(L10n.community).font(PlagitFont.subheadline()).foregroundColor(.plagitCharcoal)
            Spacer()
            Button { showActivity = true } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: unreadCount > 0 ? "bell.badge.fill" : "bell.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(unreadCount > 0 ? .plagitTeal : .plagitCharcoal)
                        .frame(width: 36, height: 36)
                    if unreadCount > 0 {
                        Text("\(min(unreadCount, 99))")
                            .font(.system(size: 10, weight: .bold)).foregroundColor(.white)
                            .frame(minWidth: 18, minHeight: 18)
                            .background(Circle().fill(Color.plagitUrgent))
                            .offset(x: 8, y: -4)
                    }
                }
            }
            Button { showCreatePost = true } label: {
                Image(systemName: "plus.circle.fill").font(.system(size: 22, weight: .medium)).foregroundColor(.plagitTeal)
            }
        }
        .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.sm)
    }

    // MARK: - Tabs

    private var tabRow: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tab }
                    Task { await load() }
                } label: {
                    VStack(spacing: PlagitSpacing.sm) {
                        HStack(spacing: 3) {
                            if tab == "Saved" {
                                Image(systemName: "bookmark.fill").font(.system(size: 10, weight: .medium))
                            }
                            Text(tab == "For You" ? L10n.forYou : tab == "Following" ? L10n.following : tab == "Saved" ? L10n.t("saved_tab") : L10n.nearby).font(PlagitFont.captionMedium())
                        }
                        .foregroundColor(selectedTab == tab ? .plagitCharcoal : .plagitTertiary)
                        Rectangle()
                            .fill(selectedTab == tab ? Color.plagitTeal : Color.clear)
                            .frame(height: 2)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }.padding(.horizontal, PlagitSpacing.xl)
    }

    // MARK: - Role Chips

    private var roleChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: PlagitSpacing.sm) {
                ForEach(roles, id: \.self) { role in
                    let active = selectedRole == role
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { selectedRole = role }
                        Task { await load() }
                    } label: {
                        Text(role == "All" ? L10n.all : L10n.roleCategory(role)).font(PlagitFont.captionMedium())
                            .foregroundColor(active ? .white : .plagitSecondary)
                            .padding(.horizontal, PlagitSpacing.md).padding(.vertical, PlagitSpacing.sm)
                            .background(Capsule().fill(active ? Color.plagitTeal : Color.plagitSurface))
                            .overlay(Capsule().stroke(active ? Color.clear : Color.plagitBorder, lineWidth: 0.5))
                    }
                }
            }.padding(.horizontal, PlagitSpacing.xl)
        }
    }

    // MARK: - Post Card

    private func tagColor(_ tag: String?) -> Color {
        switch tag {
        // Candidate tags
        case "open_to_work", "available_immediately", "looking_for_opportunities": return .plagitOnline
        case "available_for_shifts", "open_to_relocation": return .plagitIndigo
        case "available_full_time": return .plagitTeal
        case "available_part_time": return .plagitAmber
        // Business tags
        case "hiring", "open_positions", "international_opportunity": return .plagitTeal
        case "looking_for_staff": return .plagitAmber
        case "urgent_hiring": return .plagitUrgent
        case "interviewing_now": return .plagitIndigo
        default: return .plagitSecondary
        }
    }

    private func tagLabel(_ tag: String?) -> String {
        L10n.feedTag(tag)
    }

    private func roleIcon(_ role: String?) -> String {
        switch role?.lowercased() {
        case "chef": return "flame.fill"
        case "waiter": return "person.fill"
        case "bartender": return "wineglass.fill"
        case "manager": return "star.fill"
        case "reception": return "bell.fill"
        case "kitchen_porter", "kitchen porter": return "frying.pan.fill"
        default: return "person.fill"
        }
    }

    private func timeAgo(_ iso: String?) -> String {
        guard let iso else { return "" }
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = f.date(from: iso) ?? ISO8601DateFormatter().date(from: iso) else { return "" }
        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 60 { return "now" }
        if seconds < 3600 { return "\(seconds / 60)m" }
        if seconds < 86400 { return "\(seconds / 3600)h" }
        if seconds < 604800 { return "\(seconds / 86400)d" }
        return "\(seconds / 604800)w"
    }

    private func postCard(_ post: FeedPostDTO) -> some View {
        let hue = post.authorAvatarHue ?? 0.5
        let liked = likedPosts.contains(post.id)
        let likes = likeCounts[post.id] ?? post.likeCount

        return VStack(alignment: .leading, spacing: PlagitSpacing.md) {

            // Author header — tap avatar/name to open post comments
            HStack(spacing: PlagitSpacing.md) {
                Button { commentsPost = post; trackProfileClick(post) } label: {
                    ProfileAvatarView(
                        photoUrl: post.authorPhotoUrl,
                        initials: post.authorInitials ?? "—",
                        hue: hue, size: 44,
                        verified: post.authorVerified == true
                    )
                }

                VStack(alignment: .leading, spacing: 2) {
                    Button { commentsPost = post; trackProfileClick(post) } label: {
                        HStack(spacing: PlagitSpacing.xs) {
                            Text(post.authorName ?? "Unknown").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                            if post.authorType == "business" {
                                Image(systemName: "building.2.fill").font(.system(size: 9)).foregroundColor(.plagitTeal)
                            }
                        }
                    }.buttonStyle(.plain)
                    HStack(spacing: PlagitSpacing.xs) {
                        if let subtitle = post.authorSubtitle, !subtitle.isEmpty {
                            Text(subtitle).font(PlagitFont.micro()).foregroundColor(.plagitSecondary)
                        }
                        let flag = CountryFlag.emoji(for: post.authorNationalityCode ?? post.authorCountryCode)
                        if !flag.isEmpty || (post.authorLocation != nil && !(post.authorLocation ?? "").isEmpty) {
                            Text("·").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                            Text("\(flag) \(post.authorLocation ?? "")".trimmingCharacters(in: .whitespaces))
                                .font(PlagitFont.micro()).foregroundColor(.plagitTertiary).lineLimit(1)
                        }
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: PlagitSpacing.sm) {
                        Text(timeAgo(post.createdAt)).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                        Button { actionMenuPost = post } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.plagitTertiary)
                                .frame(width: 28, height: 28)
                                .contentShape(Rectangle())
                        }
                    }
                    if let uid = post.userId, post.isOwn != true {
                        let following = followedUsers.contains(uid)
                        Button {
                            Task { await toggleFollow(userId: uid) }
                        } label: {
                            Text(following ? L10n.following : L10n.follow)
                                .font(PlagitFont.micro()).fontWeight(.medium)
                                .foregroundColor(following ? .plagitSecondary : .plagitTeal)
                                .padding(.horizontal, PlagitSpacing.sm).padding(.vertical, 2)
                                .background(Capsule().fill(following ? Color.plagitSurface : Color.plagitTealLight))
                        }
                    }
                }
            }

            // Tag badge — only show if tag has visible text
            if let tag = post.tag, !tag.isEmpty {
                let label = tagLabel(tag)
                if !label.isEmpty {
                    let color = tagColor(tag)
                    Text(label).font(PlagitFont.micro()).foregroundColor(color)
                        .padding(.horizontal, PlagitSpacing.sm + 2).padding(.vertical, PlagitSpacing.xs)
                        .background(Capsule().fill(color.opacity(0.08)))
                }
            }

            // Body text
            Text(post.body).font(PlagitFont.body()).foregroundColor(.plagitCharcoal).lineLimit(8)

            // Post media (multi-media aware)
            postMediaSection(post)

            // Role + location pills
            HStack(spacing: PlagitSpacing.sm) {
                if let role = post.roleCategory, !role.isEmpty {
                    HStack(spacing: PlagitSpacing.xs) {
                        Image(systemName: roleIcon(role)).font(.system(size: 10, weight: .medium)).foregroundColor(.plagitTeal)
                        Text(L10n.roleCategory(role)).font(PlagitFont.micro()).foregroundColor(.plagitTeal)
                    }
                    .padding(.horizontal, PlagitSpacing.sm + 2).padding(.vertical, PlagitSpacing.xs)
                    .background(Capsule().fill(Color.plagitTealLight))
                }
                if let loc = post.location, !loc.isEmpty {
                    HStack(spacing: PlagitSpacing.xs) {
                        Image(systemName: "mappin").font(.system(size: 10, weight: .medium)).foregroundColor(.plagitSecondary)
                        Text(loc).font(PlagitFont.micro()).foregroundColor(.plagitSecondary).lineLimit(1)
                    }
                }
            }

            // Action bar
            HStack(spacing: PlagitSpacing.xl) {
                Button {
                    Task { await toggleLike(post) }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: liked ? "heart.fill" : "heart")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(liked ? .plagitUrgent : .plagitTertiary)
                        Text(likes > 0 ? "\(likes)" : L10n.like)
                            .font(PlagitFont.micro()).lineLimit(1).fixedSize()
                            .foregroundColor(liked ? .plagitUrgent : .plagitTertiary)
                    }.padding(.vertical, 4)
                }

                Button {
                    commentsPost = post
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.plagitTertiary)
                        Text(post.commentCount > 0 ? "\(post.commentCount)" : L10n.comment)
                            .font(PlagitFont.micro()).lineLimit(1).fixedSize()
                            .foregroundColor(.plagitTertiary)
                    }.padding(.vertical, 4)
                }

                Button {
                    sharePost(post)
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.plagitTertiary)
                        Text(L10n.share)
                            .font(PlagitFont.micro()).lineLimit(1).fixedSize()
                            .foregroundColor(.plagitTertiary)
                    }.padding(.vertical, 4)
                }

                // Save button
                let isSaved = savedPosts.contains(post.id)
                Button {
                    handleSave(post)
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(isSaved ? .plagitTeal : .plagitTertiary)
                        let saves = post.saveCount ?? 0
                        Text(saves > 0 ? "\(saves)" : L10n.t("save_action"))
                            .font(PlagitFont.micro()).lineLimit(1).fixedSize()
                            .foregroundColor(isSaved ? .plagitTeal : .plagitTertiary)
                    }.padding(.vertical, 4)
                }

                Spacer()

                // View count — tap to open insights
                let views = viewCounts[post.id] ?? post.viewCount ?? 0
                if views > 0 {
                    Button { insightsPost = post } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "eye")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.plagitTertiary)
                            Text(formatCount(views))
                                .font(PlagitFont.micro()).lineLimit(1).fixedSize()
                                .foregroundColor(.plagitTertiary)
                        }.padding(.vertical, 4)
                    }
                }
            }

            // View comments link
            if post.commentCount > 0 {
                Button { commentsPost = post } label: {
                    HStack(spacing: PlagitSpacing.xs) {
                        Image(systemName: "bubble.left.fill").font(.system(size: 11, weight: .medium)).foregroundColor(.plagitTeal)
                        Text(L10n.viewCommentsText(post.commentCount))
                            .font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                    }
                }
            }
        }
        .padding(PlagitSpacing.xl)
        .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitCardBackground)
            .shadow(color: PlagitShadow.cardShadowColor, radius: PlagitShadow.cardShadowRadius, y: PlagitShadow.cardShadowY))
        .onAppear { trackView(for: post) }
    }

    // MARK: - Actions

    private func toggleLike(_ post: FeedPostDTO) async {
        // Optimistic update
        let wasLiked = likedPosts.contains(post.id)
        if wasLiked { likedPosts.remove(post.id); likeCounts[post.id] = (likeCounts[post.id] ?? post.likeCount) - 1 }
        else { likedPosts.insert(post.id); likeCounts[post.id] = (likeCounts[post.id] ?? post.likeCount) + 1 }

        if let serverLiked = await FeedService.shared.toggleLike(postId: post.id) {
            if serverLiked { likedPosts.insert(post.id) } else { likedPosts.remove(post.id) }
        }
        // If API failed, keep optimistic state — feels responsive
    }

    private func toggleFollow(userId: String) async {
        let wasFollowing = followedUsers.contains(userId)
        if wasFollowing { followedUsers.remove(userId) } else { followedUsers.insert(userId) }
        if wasFollowing {
            let result = await FeedService.shared.unfollowUser(userId: userId)
            if result { followedUsers.remove(userId) } else { followedUsers.insert(userId) }
            showToast(L10n.unfollowed)
        } else {
            let result = await FeedService.shared.followUser(userId: userId)
            if result { followedUsers.insert(userId) } else { followedUsers.remove(userId) }
            showToast(L10n.following)
        }
    }

    private func sharePost(_ post: FeedPostDTO) {
        let text = "\(post.authorName ?? "Someone") on Plagit:\n\n\(post.body)"
        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        av.completionWithItemsHandler = { _, completed, _, _ in
            if completed { showToast(L10n.postShared) }
        }
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(av, animated: true)
        }
    }

    private func showToast(_ message: String) {
        withAnimation(.easeInOut(duration: 0.2)) { toastMessage = message }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeInOut(duration: 0.3)) { toastMessage = nil }
        }
    }

    // MARK: - View Tracking

    private func trackView(for post: FeedPostDTO) {
        guard !viewedPosts.contains(post.id) else { return }
        // 1.5 second visibility threshold
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard !viewedPosts.contains(post.id) else { return }
            viewedPosts.insert(post.id)
            viewCounts[post.id] = (viewCounts[post.id] ?? post.viewCount ?? 0) + 1
            Task { await FeedService.shared.recordView(postId: post.id) }
        }
    }

    private func trackProfileClick(_ post: FeedPostDTO) {
        guard let uid = post.userId, post.isOwn != true else { return }
        let profileType = post.authorType ?? "candidate"
        Task { await CandidateAPIService.shared.recordProfileView(profileId: uid, profileType: profileType) }
    }

    private func formatCount(_ count: Int) -> String {
        if count >= 1_000_000 { return String(format: "%.1fM", Double(count) / 1_000_000) }
        if count >= 1_000 { return String(format: "%.1fK", Double(count) / 1_000) }
        return "\(count)"
    }

    // MARK: - Post Menu Actions

    private func handleSave(_ post: FeedPostDTO) {
        let wasSaved = savedPosts.contains(post.id)
        actionMenuPost = nil
        if wasSaved {
            savedPosts.remove(post.id)
            SavedPostStore.shared.remove(postId: post.id)
            Task { await FeedService.shared.unsavePost(postId: post.id) }
            showToast(L10n.t("post_unsaved"))
        } else {
            pendingSavePost = post
        }
    }

    private func completeSave(_ post: FeedPostDTO, category: SavedPostCategory) {
        savedPosts.insert(post.id)
        SavedPostStore.shared.save(postId: post.id, category: category)
        Task { await FeedService.shared.savePost(postId: post.id) }
        showToast("\(L10n.t("post_saved")) → \(category.label)")
    }

    private func handleCopyLink(_ post: FeedPostDTO) {
        UIPasteboard.general.string = "https://plagit.com/post/\(post.id)"
        actionMenuPost = nil
        showToast(L10n.t("link_copied"))
    }

    private func handleNotInterested(_ post: FeedPostDTO) {
        hiddenPosts.insert(post.id)
        actionMenuPost = nil
        Task { await FeedService.shared.notInterestedInPost(postId: post.id) }
        showToast(L10n.t("not_interested_done"))
    }

    private func handleMuteUser(_ post: FeedPostDTO) {
        guard let uid = post.userId else { return }
        mutedUsers.insert(uid)
        actionMenuPost = nil
        Task { await FeedService.shared.muteUser(userId: uid) }
        showToast("\(post.authorName ?? "User") muted")
    }

    private func handleToggleNotifications(_ post: FeedPostDTO) {
        actionMenuPost = nil
        Task { await FeedService.shared.togglePostNotifications(postId: post.id, enabled: false) }
        showToast(L10n.t("notifications_off"))
    }

    private func handleAdminRemove(_ post: FeedPostDTO) {
        actionMenuPost = nil
        Task {
            let success = await FeedService.shared.adminRemovePost(postId: post.id)
            if success { posts.removeAll { $0.id == post.id } }
            showToast(success ? "Post removed" : "Failed to remove post")
        }
    }

    private func handleAdminMarkSpam(_ post: FeedPostDTO) {
        actionMenuPost = nil
        Task {
            await FeedService.shared.adminMarkSpam(postId: post.id)
            posts.removeAll { $0.id == post.id }
            showToast("Marked as spam")
        }
    }

    private func handleAdminSuspend(_ post: FeedPostDTO) {
        guard let uid = post.userId else { return }
        actionMenuPost = nil
        Task {
            await FeedService.shared.adminSuspendUser(userId: uid)
            showToast("\(post.authorName ?? "User") suspended")
        }
    }

    // MARK: - Helpers

    // MARK: - Post Media Section

    @ViewBuilder
    private func postMediaSection(_ post: FeedPostDTO) -> some View {
        let allMedia = post.media ?? []
        let photos = allMedia.filter { $0.mediaType == "photo" }
        let videos = allMedia.filter { $0.mediaType == "video" }

        if photos.count > 1 {
            // Multi-photo gallery
            let decoded = photos.compactMap { decodeImage($0.url) }
            if !decoded.isEmpty {
                Button {
                    photoViewerItem = PhotoViewerItem(images: decoded, startIndex: 0)
                } label: {
                    ZStack(alignment: .bottomTrailing) {
                        Image(uiImage: decoded[0]).resizable().scaledToFill()
                            .frame(maxWidth: .infinity).frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: PlagitRadius.lg))
                        if decoded.count > 1 {
                            Text("+\(decoded.count - 1)")
                                .font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .background(Capsule().fill(.black.opacity(0.55)))
                                .padding(PlagitSpacing.sm)
                        }
                    }
                }.buttonStyle(.plain)
            }
        } else if photos.count == 1, let img = decodeImage(photos[0].url) {
            // Single photo
            Button { photoViewerItem = PhotoViewerItem(images: [img], startIndex: 0) } label: {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: img).resizable().scaledToFill()
                        .frame(maxWidth: .infinity).frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: PlagitRadius.lg))
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 12, weight: .bold)).foregroundColor(.white)
                        .padding(6).background(Circle().fill(.black.opacity(0.35)))
                        .padding(PlagitSpacing.sm)
                }
            }.buttonStyle(.plain)
        } else if !videos.isEmpty {
            // Video(s)
            Button { viewerVideoUrl = post.videoUrl ?? ""; showVideoViewer = true } label: {
                ZStack {
                    if let thumbUrl = videos.first?.url, thumbUrl.hasPrefix("data:image"), let img = decodeImage(thumbUrl) {
                        Image(uiImage: img).resizable().scaledToFill()
                            .frame(maxWidth: .infinity).frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: PlagitRadius.lg))
                            .overlay(RoundedRectangle(cornerRadius: PlagitRadius.lg).fill(.black.opacity(0.2)))
                    } else {
                        RoundedRectangle(cornerRadius: PlagitRadius.lg).fill(Color.plagitSurface)
                            .frame(maxWidth: .infinity).frame(height: 180)
                    }
                    VStack(spacing: PlagitSpacing.sm) {
                        Image(systemName: "play.circle.fill").font(.system(size: 48, weight: .medium)).foregroundColor(.white)
                        if videos.count > 1 { Text("\(videos.count) \(L10n.videos)").font(PlagitFont.micro()).foregroundColor(.white) }
                    }
                }
            }.buttonStyle(.plain)
        } else if let imgUrl = post.imageUrl, !imgUrl.isEmpty, let img = decodeImage(imgUrl) {
            // Legacy single image
            let isVideo = post.videoUrl != nil
            Button { if isVideo { viewerVideoUrl = post.videoUrl ?? ""; showVideoViewer = true } else { photoViewerItem = PhotoViewerItem(images: [img], startIndex: 0) } } label: {
                ZStack {
                    Image(uiImage: img).resizable().scaledToFill()
                        .frame(maxWidth: .infinity).frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: PlagitRadius.lg))
                    if isVideo {
                        RoundedRectangle(cornerRadius: PlagitRadius.lg).fill(.black.opacity(0.2))
                            .frame(maxWidth: .infinity).frame(height: 200)
                        Image(systemName: "play.circle.fill").font(.system(size: 48, weight: .medium)).foregroundColor(.white)
                    }
                }
            }.buttonStyle(.plain)
        } else if post.videoUrl != nil {
            // Legacy video without thumbnail
            Button { viewerVideoUrl = post.videoUrl ?? ""; showVideoViewer = true } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: PlagitRadius.lg).fill(Color.plagitSurface)
                        .frame(maxWidth: .infinity).frame(height: 180)
                    Image(systemName: "play.circle.fill").font(.system(size: 44, weight: .medium)).foregroundColor(.plagitTeal)
                }
            }.buttonStyle(.plain)
        }
    }

    private func decodeImage(_ urlString: String) -> UIImage? {
        let base64: String
        if let range = urlString.range(of: ";base64,") { base64 = String(urlString[range.upperBound...]) } else { base64 = urlString }
        guard let data = Data(base64Encoded: base64, options: .ignoreUnknownCharacters) else { return nil }
        return UIImage(data: data)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: PlagitSpacing.lg) {
            ZStack {
                Circle().fill(Color.plagitTealLight).frame(width: 56, height: 56)
                Image(systemName: "bubble.left.and.bubble.right.fill").font(.system(size: 24, weight: .medium)).foregroundColor(.plagitTeal)
            }
            VStack(spacing: PlagitSpacing.xs) {
                Text(selectedTab == "Nearby" ? L10n.noPostsNearby : selectedTab == "Following" ? L10n.noPostsFollowing : L10n.noPostsYet)
                    .font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                Text(selectedTab == "Following" ? L10n.followToSee : L10n.beFirstCommunity)
                    .font(PlagitFont.caption()).foregroundColor(.plagitSecondary).multilineTextAlignment(.center)
            }
            Button { showCreatePost = true } label: {
                HStack(spacing: PlagitSpacing.sm) {
                    Image(systemName: "plus").font(.system(size: 13, weight: .medium))
                    Text(L10n.createPost)
                }
                .font(PlagitFont.captionMedium()).foregroundColor(.white)
                .padding(.horizontal, PlagitSpacing.xxl).padding(.vertical, PlagitSpacing.md)
                .background(Capsule().fill(Color.plagitTeal))
            }
        }.padding(.horizontal, PlagitSpacing.xxl)
    }
}

// MARK: - Create Post Sheet

struct CreatePostSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onPosted: (FeedPostDTO?) async -> Void

    @State private var postText = ""
    @State private var selectedTag: String?

    // Multi-media
    enum MediaMode { case none, photos, videos }
    @State private var mediaMode: MediaMode = .none
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var photoImages: [UIImage] = []       // previews
    @State private var photoDataList: [String] = []      // base64

    @State private var selectedVideos: [PhotosPickerItem] = []
    @State private var videoThumbnails: [UIImage] = []
    @State private var videoDataList: [String] = []

    // Location
    @State private var locationText: String?
    @State private var showLocationInput = false

    @State private var isPosting = false
    @State private var postError: String?

    private let maxPhotos = 5
    private let maxVideos = 3

    private var hasMedia: Bool { !photoDataList.isEmpty || !videoDataList.isEmpty }
    private var canPost: Bool { !postText.trimmingCharacters(in: .whitespaces).isEmpty || hasMedia }

    private var userName: String { CandidateAuthService.shared.currentUserName ?? BusinessAuthService.shared.currentUserName ?? "You" }
    private var userInitials: String { let p = userName.split(separator: " "); return p.count >= 2 ? "\(p[0].prefix(1))\(p[1].prefix(1))".uppercased() : String(userName.prefix(2)).uppercased() }
    private var userHue: Double { CandidateAuthService.shared.currentUserAvatarHue }
    private var isBusiness: Bool { BusinessAuthService.shared.isAuthenticated }

    private var tags: [(String, String, Color)] {
        if isBusiness {
            return [
                ("hiring", L10n.t("tag_hiring"), .plagitTeal),
                ("looking_for_staff", L10n.t("tag_looking_for_staff"), .plagitAmber),
                ("urgent_hiring", L10n.t("tag_urgent_hiring"), .plagitUrgent),
                ("open_positions", L10n.t("tag_open_positions"), .plagitOnline),
                ("interviewing_now", L10n.t("tag_interviewing_now"), .plagitIndigo),
                ("international_opportunity", L10n.t("tag_international"), .plagitTeal),
            ]
        } else {
            return [
                ("open_to_work", L10n.t("tag_open_to_work"), .plagitOnline),
                ("available_for_shifts", L10n.t("tag_available_shifts"), .plagitIndigo),
                ("available_full_time", L10n.t("tag_full_time"), .plagitTeal),
                ("available_part_time", L10n.t("tag_part_time"), .plagitAmber),
                ("available_immediately", L10n.t("tag_immediately"), .plagitOnline),
                ("open_to_relocation", L10n.t("tag_relocation"), .plagitIndigo),
                ("looking_for_opportunities", L10n.t("tag_looking_opps"), .plagitTeal),
            ]
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.plagitBackground.ignoresSafeArea()
                VStack(spacing: 0) {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: PlagitSpacing.lg) {
                            // Author
                            HStack(alignment: .top, spacing: PlagitSpacing.md) {
                                ProfileAvatarView(photoUrl: nil, initials: userInitials, hue: userHue, size: 40)
                                VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                                    HStack(spacing: PlagitSpacing.xs) {
                                        Text(userName).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                                        if isBusiness { Image(systemName: "building.2.fill").font(.system(size: 9)).foregroundColor(.plagitTeal) }
                                    }
                                    Text(isBusiness ? L10n.business : L10n.candidate).font(PlagitFont.micro()).foregroundColor(.plagitSecondary)
                                }; Spacer()
                            }

                            // Text
                            ZStack(alignment: .topLeading) {
                                if postText.isEmpty {
                                    Text(L10n.shareUpdatePlaceholder).font(PlagitFont.body()).foregroundColor(.plagitTertiary).padding(.horizontal, 5).padding(.vertical, 8)
                                }
                                TextEditor(text: $postText).font(PlagitFont.body()).foregroundColor(.plagitCharcoal).frame(minHeight: 100).scrollContentBackground(.hidden)
                            }

                            // Media grid preview
                            mediaGrid

                            // Location
                            if let loc = locationText {
                                HStack(spacing: PlagitSpacing.xs) {
                                    Image(systemName: "mappin.circle.fill").font(.system(size: 14)).foregroundColor(.plagitTeal)
                                    Text(loc).font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal).lineLimit(1); Spacer()
                                    Button { locationText = nil } label: { Image(systemName: "xmark.circle.fill").font(.system(size: 14)).foregroundColor(.plagitTertiary) }
                                }.padding(.horizontal, PlagitSpacing.md).padding(.vertical, PlagitSpacing.sm)
                                .background(RoundedRectangle(cornerRadius: PlagitRadius.md).fill(Color.plagitTealLight))
                            }

                            // Tags
                            VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
                                Text(L10n.addTag).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                                tagChips
                            }

                            if let err = postError { Text(err).font(PlagitFont.caption()).foregroundColor(.plagitUrgent) }
                        }
                        .padding(.horizontal, PlagitSpacing.xl).padding(.top, PlagitSpacing.lg).padding(.bottom, PlagitSpacing.xxxl)
                    }
                    actionBar
                }
            }
            .navigationTitle(L10n.newPost).navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button(L10n.cancel) { dismiss() }.font(PlagitFont.captionMedium()).foregroundColor(.plagitSecondary) }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { Task { await post() } } label: {
                        if isPosting { ProgressView().tint(.white).frame(width: 50, height: 28) }
                        else { Text(L10n.postVerb).font(PlagitFont.captionMedium()).fontWeight(.semibold) }
                    }.foregroundColor(.white).padding(.horizontal, PlagitSpacing.xl).padding(.vertical, PlagitSpacing.sm)
                    .background(Capsule().fill(canPost ? Color.plagitTeal : Color.plagitTertiary.opacity(0.4))).disabled(!canPost || isPosting)
                }
            }
            .alert(L10n.addLocation, isPresented: $showLocationInput) {
                TextField(L10n.cityOrArea, text: Binding(get: { locationText ?? "" }, set: { locationText = $0.isEmpty ? nil : $0 }))
                Button(L10n.add) {}; Button(L10n.cancel, role: .cancel) {}
            } message: { Text(L10n.enterCityOrArea) }
        }
    }

    // MARK: - Media Grid

    private var gridColumns: [GridItem] { [GridItem(.flexible(), spacing: PlagitSpacing.sm), GridItem(.flexible(), spacing: PlagitSpacing.sm)] }

    @ViewBuilder
    private var mediaGrid: some View {
        if !photoImages.isEmpty {
            VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
                Text("\(photoImages.count)/\(maxPhotos) \(L10n.photos)").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                LazyVGrid(columns: gridColumns, spacing: PlagitSpacing.sm) {
                    ForEach(Array(photoImages.enumerated()), id: \.offset) { idx, img in
                        mediaThumbnail(image: img, isVideo: false) {
                            removePhoto(at: idx)
                        }
                    }
                }
            }
        }
        if !videoThumbnails.isEmpty {
            VStack(alignment: .leading, spacing: PlagitSpacing.sm) {
                Text("\(videoThumbnails.count)/\(maxVideos) \(L10n.videos)").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                LazyVGrid(columns: gridColumns, spacing: PlagitSpacing.sm) {
                    ForEach(Array(videoThumbnails.enumerated()), id: \.offset) { idx, thumb in
                        mediaThumbnail(image: thumb, isVideo: true) {
                            removeVideo(at: idx)
                        }
                    }
                }
            }
        }
    }

    private func mediaThumbnail(image: UIImage, isVideo: Bool, onRemove: @escaping () -> Void) -> some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, minHeight: 120, maxHeight: 120)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: PlagitRadius.md))

            if isVideo {
                RoundedRectangle(cornerRadius: PlagitRadius.md).fill(.black.opacity(0.2))
                    .frame(maxWidth: .infinity, minHeight: 120, maxHeight: 120)
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 28, weight: .medium)).foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22, weight: .medium))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .black.opacity(0.5))
            }
            .padding(6)
        }
        .frame(maxWidth: .infinity, minHeight: 120, maxHeight: 120)
    }

    // MARK: - Tag Chips

    private var tagChips: some View {
        FlowLayout(spacing: PlagitSpacing.sm) {
            ForEach(tags, id: \.0) { id, label, color in
                let active = selectedTag == id
                Button { withAnimation(.easeInOut(duration: 0.15)) { selectedTag = active ? nil : id } } label: {
                    HStack(spacing: 5) { Circle().fill(color).frame(width: 6, height: 6); Text(L10n.feedTag(id)).font(PlagitFont.captionMedium()).foregroundColor(active ? .white : color) }
                    .padding(.horizontal, PlagitSpacing.md).padding(.vertical, PlagitSpacing.sm)
                    .background(Capsule().fill(active ? color : color.opacity(0.08)))
                    .overlay(active ? nil : Capsule().stroke(color.opacity(0.2), lineWidth: 0.5))
                }
            }
        }
    }

    // MARK: - Action Bar

    private var actionBar: some View {
        VStack(spacing: 0) {
            Rectangle().fill(Color.plagitDivider).frame(height: 0.5)
            HStack(spacing: PlagitSpacing.lg) {
                PhotosPicker(selection: $selectedPhotos, maxSelectionCount: maxPhotos - photoImages.count, matching: .images) {
                    actionLabel("photo", photoImages.isEmpty ? L10n.photo : "\(L10n.photo) (\(photoImages.count))", active: !photoImages.isEmpty)
                }
                .onChange(of: selectedPhotos) { _, items in Task { await handlePhotos(items) } }
                .disabled(mediaMode == .videos).opacity(mediaMode == .videos ? 0.4 : 1)

                PhotosPicker(selection: $selectedVideos, maxSelectionCount: maxVideos - videoThumbnails.count, matching: .videos) {
                    actionLabel("video", videoThumbnails.isEmpty ? L10n.video : "\(L10n.video) (\(videoThumbnails.count))", active: !videoThumbnails.isEmpty)
                }
                .onChange(of: selectedVideos) { _, items in Task { await handleVideos(items) } }
                .disabled(mediaMode == .photos).opacity(mediaMode == .photos ? 0.4 : 1)

                Button { showLocationInput = true } label: { actionLabel("mappin", L10n.location, active: locationText != nil) }
                Spacer()
            }.padding(.horizontal, PlagitSpacing.xl).padding(.vertical, PlagitSpacing.md).background(Color.plagitCardBackground)
        }
    }

    private func actionLabel(_ icon: String, _ text: String, active: Bool) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon).font(.system(size: 14, weight: .medium))
            Text(text).font(PlagitFont.captionMedium()).lineLimit(1).fixedSize()
        }.foregroundColor(active ? .plagitTeal : .plagitTertiary)
    }

    // MARK: - Media Handling

    @MainActor
    private func handlePhotos(_ items: [PhotosPickerItem]) async {
        postError = nil
        for item in items {
            guard photoImages.count < maxPhotos else { break }
            if let data = try? await item.loadTransferable(type: Data.self), let img = UIImage(data: data) {
                photoImages.append(img)
                var quality: CGFloat = 0.5; var jpeg = img.jpegData(compressionQuality: quality)
                while let j = jpeg, j.count > 750_000, quality > 0.1 { quality -= 0.1; jpeg = img.jpegData(compressionQuality: quality) }
                if let j = jpeg { photoDataList.append("data:image/jpeg;base64," + j.base64EncodedString()) }
            }
        }
        if !photoImages.isEmpty { mediaMode = .photos }
        selectedPhotos = []
    }

    @MainActor
    private func handleVideos(_ items: [PhotosPickerItem]) async {
        postError = nil
        for item in items {
            guard videoThumbnails.count < maxVideos else { break }
            guard let data = try? await item.loadTransferable(type: Data.self) else { continue }
            let tempUrl = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".mov")
            try? data.write(to: tempUrl)
            let gen = AVAssetImageGenerator(asset: AVURLAsset(url: tempUrl))
            gen.appliesPreferredTrackTransform = true; gen.maximumSize = CGSize(width: 600, height: 600)
            if let cg = try? await gen.image(at: .zero).image { videoThumbnails.append(UIImage(cgImage: cg)) }
            else { videoThumbnails.append(UIImage(systemName: "video.fill")!) }
            videoDataList.append(data.count <= 8_000_000 ? "data:video/mp4;base64," + data.base64EncodedString() : "demo_video")
            try? FileManager.default.removeItem(at: tempUrl)
        }
        if !videoThumbnails.isEmpty { mediaMode = .videos }
        selectedVideos = []
    }

    private func removePhoto(at idx: Int) {
        photoImages.remove(at: idx)
        if idx < photoDataList.count { photoDataList.remove(at: idx) }
        if photoImages.isEmpty { mediaMode = .none }
    }

    private func removeVideo(at idx: Int) {
        videoThumbnails.remove(at: idx)
        if idx < videoDataList.count { videoDataList.remove(at: idx) }
        if videoThumbnails.isEmpty { mediaMode = .none }
    }

    // MARK: - Post

    private func post() async {
        isPosting = true; postError = nil
        var items: [FeedService.MediaItem] = []
        for url in photoDataList { items.append(.init(mediaType: "photo", url: url)) }
        for url in videoDataList { items.append(.init(mediaType: "video", url: url)) }
        let result = try? await FeedService.shared.createPost(
            body: postText.trimmingCharacters(in: .whitespaces),
            mediaItems: items, location: locationText, tag: selectedTag
        )
        dismiss()
        await onPosted(result)
        isPosting = false
    }
}

// MARK: - Flow Layout (wrapping tag chips)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY), proposal: ProposedViewSize(frame.size))
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        let maxWidth = proposal.width ?? .infinity
        var frames: [CGRect] = []
        var x: CGFloat = 0; var y: CGFloat = 0; var rowHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 { x = 0; y += rowHeight + spacing; rowHeight = 0 }
            frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        return (CGSize(width: maxWidth, height: y + rowHeight), frames)
    }
}

// MARK: - Comments Sheet

struct CommentsSheet: View {
    let post: FeedPostDTO
    @Environment(\.dismiss) private var dismiss
    @State private var comments: [FeedCommentDTO] = []
    @State private var isLoading = true
    @State private var newComment = ""
    @State private var isSending = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.plagitBackground.ignoresSafeArea()
                VStack(spacing: 0) {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            // Original post at top
                            originalPostHeader
                                .padding(.horizontal, PlagitSpacing.xl)
                                .padding(.top, PlagitSpacing.lg)
                                .padding(.bottom, PlagitSpacing.md)

                            Rectangle().fill(Color.plagitDivider).frame(height: 1)
                                .padding(.horizontal, PlagitSpacing.xl)

                            // Comments section
                            if isLoading {
                                ProgressView().tint(.plagitTeal)
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, PlagitSpacing.xxxl)
                            } else if comments.isEmpty {
                                emptyComments
                                    .padding(.top, PlagitSpacing.xxxl)
                            } else {
                                LazyVStack(spacing: 0) {
                                    ForEach(comments) { c in
                                        commentRow(c)
                                            .padding(.horizontal, PlagitSpacing.xl)
                                            .padding(.vertical, PlagitSpacing.md)
                                    }
                                }
                                .padding(.top, PlagitSpacing.sm)
                            }

                            Spacer().frame(height: PlagitSpacing.xxxl)
                        }
                    }

                    commentInput
                }
            }
            .navigationTitle(L10n.comments)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L10n.done) { dismiss() }.font(PlagitFont.captionMedium()).foregroundColor(.plagitTeal)
                }
            }
            .task { await load() }
        }
    }

    // MARK: - Original Post Header

    private var originalPostHeader: some View {
        VStack(alignment: .leading, spacing: PlagitSpacing.md) {
            HStack(spacing: PlagitSpacing.md) {
                ProfileAvatarView(
                    photoUrl: post.authorPhotoUrl,
                    initials: post.authorInitials ?? "—",
                    hue: post.authorAvatarHue ?? 0.5,
                    size: 40, verified: post.authorVerified == true
                )
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: PlagitSpacing.xs) {
                        Text(post.authorName ?? "Unknown").font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
                        if post.authorType == "business" {
                            Image(systemName: "building.2.fill").font(.system(size: 9)).foregroundColor(.plagitTeal)
                        }
                    }
                    HStack(spacing: PlagitSpacing.xs) {
                        if let sub = post.authorSubtitle, !sub.isEmpty {
                            Text(sub).font(PlagitFont.micro()).foregroundColor(.plagitSecondary)
                        }
                        let cflag = CountryFlag.emoji(for: post.authorNationalityCode ?? post.authorCountryCode)
                        if !cflag.isEmpty || (post.authorLocation != nil && !(post.authorLocation ?? "").isEmpty) {
                            Text("·").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                            Text("\(cflag) \(post.authorLocation ?? "")".trimmingCharacters(in: .whitespaces)).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                        }
                    }
                }
                Spacer()
                Text(timeAgo(post.createdAt)).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
            }

            Text(post.body).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)

            HStack(spacing: PlagitSpacing.lg) {
                HStack(spacing: PlagitSpacing.xs) {
                    Image(systemName: "heart.fill").font(.system(size: 12)).foregroundColor(.plagitUrgent)
                    Text("\(post.likeCount)").font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                }
                HStack(spacing: PlagitSpacing.xs) {
                    Image(systemName: "bubble.left.fill").font(.system(size: 12)).foregroundColor(.plagitTeal)
                    Text(L10n.commentCount(comments.count)).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyComments: some View {
        VStack(spacing: PlagitSpacing.md) {
            Image(systemName: "bubble.left").font(.system(size: 28)).foregroundColor(.plagitTertiary)
            Text(L10n.noCommentsYet).font(PlagitFont.bodyMedium()).foregroundColor(.plagitCharcoal)
            Text(L10n.startConversation).font(PlagitFont.caption()).foregroundColor(.plagitSecondary)
        }.frame(maxWidth: .infinity)
    }

    // MARK: - Data

    private func load() async {
        isLoading = true
        comments = await FeedService.shared.fetchComments(postId: post.id)
        isLoading = false
    }

    // MARK: - Comment Row

    private func commentRow(_ c: FeedCommentDTO) -> some View {
        HStack(alignment: .top, spacing: PlagitSpacing.md) {
            ProfileAvatarView(
                photoUrl: c.authorPhotoUrl,
                initials: c.authorInitials ?? "—",
                hue: c.authorAvatarHue ?? 0.5,
                size: 32, verified: c.authorVerified == true
            )
            VStack(alignment: .leading, spacing: PlagitSpacing.xs) {
                HStack(spacing: PlagitSpacing.sm) {
                    Text(c.authorName ?? "Unknown").font(PlagitFont.captionMedium()).foregroundColor(.plagitCharcoal)
                    Text(timeAgo(c.createdAt)).font(PlagitFont.micro()).foregroundColor(.plagitTertiary)
                }
                Text(c.body).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
            }
            Spacer()
        }
    }

    // MARK: - Input

    private var commentInput: some View {
        VStack(spacing: 0) {
            Rectangle().fill(Color.plagitDivider).frame(height: 0.5)
            HStack(spacing: PlagitSpacing.md) {
                TextField(L10n.addComment, text: $newComment).font(PlagitFont.body()).foregroundColor(.plagitCharcoal)
                    .padding(.horizontal, PlagitSpacing.lg).padding(.vertical, PlagitSpacing.md)
                    .background(RoundedRectangle(cornerRadius: PlagitRadius.xl).fill(Color.plagitSurface))
                Button { Task { await send() } } label: {
                    if isSending { ProgressView().tint(.white).frame(width: 32, height: 32) }
                    else { Image(systemName: "arrow.up.circle.fill").font(.system(size: 32, weight: .medium)).foregroundColor(newComment.trimmingCharacters(in: .whitespaces).isEmpty ? .plagitTertiary : .plagitTeal) }
                }.disabled(newComment.trimmingCharacters(in: .whitespaces).isEmpty || isSending)
            }.padding(.horizontal, PlagitSpacing.xl).padding(.vertical, PlagitSpacing.md).background(Color.plagitBackground)
        }
    }

    private func send() async {
        let text = newComment.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        isSending = true
        let c = await FeedService.shared.addComment(postId: post.id, body: text)
        comments.append(c); newComment = ""
        isSending = false
    }

    private func timeAgo(_ iso: String?) -> String {
        guard let iso else { return "" }
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = f.date(from: iso) ?? ISO8601DateFormatter().date(from: iso) else { return "" }
        let s = Int(Date().timeIntervalSince(date))
        if s < 60 { return "now" }
        if s < 3600 { return "\(s / 60)m" }
        if s < 86400 { return "\(s / 3600)h" }
        return "\(s / 86400)d"
    }
}
