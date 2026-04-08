//
//  FeedService.swift
//  Plagit
//
//  Shared social feed API service for /v1/feed endpoints.
//  Feed API service — all feed operations.
//

import Foundation

// MARK: - DTOs

struct PostMediaDTO: Decodable, Identifiable {
    let id: String
    let mediaType: String   // "photo" or "video"
    let url: String
    let sortOrder: Int?
}

struct FeedPostDTO: Decodable, Identifiable, Hashable {
    static func == (lhs: FeedPostDTO, rhs: FeedPostDTO) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    let id: String
    let body: String
    let imageUrl: String?
    let videoUrl: String?
    let location: String?
    let tag: String?
    let roleCategory: String?
    var likeCount: Int
    var commentCount: Int
    var viewCount: Int?
    var saveCount: Int?
    let latitude: Double?
    let longitude: Double?
    let createdAt: String?
    let userId: String?
    let authorName: String?
    let authorType: String?
    let authorPhotoUrl: String?
    let authorAvatarHue: Double?
    let authorVerified: Bool?
    let authorSubtitle: String?
    let authorLocation: String?
    let authorNationality: String?
    let authorNationalityCode: String?
    let authorCountryCode: String?
    let authorInitials: String?
    var isLiked: Bool?
    var isFollowing: Bool?
    var isOwn: Bool?
    var isSaved: Bool?
    var media: [PostMediaDTO]?

    // Convenience
    var photos: [PostMediaDTO] { (media ?? []).filter { $0.mediaType == "photo" } }
    var videos: [PostMediaDTO] { (media ?? []).filter { $0.mediaType == "video" } }
    var hasMultipleMedia: Bool { (media ?? []).count > 1 }
}

struct FeedCommentDTO: Decodable, Identifiable {
    let id: String
    let body: String
    let createdAt: String?
    let userId: String?
    let authorName: String?
    let authorType: String?
    let authorPhotoUrl: String?
    let authorAvatarHue: Double?
    let authorVerified: Bool?
    let authorInitials: String?
    let authorNationalityCode: String?
}

struct LikeResponseDTO: Decodable {
    let liked: Bool
}

struct FeedNotificationDTO: Decodable, Identifiable {
    let id: String
    let actionType: String
    let postId: String?
    let preview: String?
    let isRead: Bool
    let createdAt: String?
    let actorName: String?
    let actorType: String?
    let actorPhotoUrl: String?
    let actorAvatarHue: Double?
    let actorVerified: Bool?
    let actorInitials: String?
}

// MARK: - Service

private struct FeedAPIWrapper<T: Decodable>: Decodable { let success: Bool; let data: T }
private struct FeedPaginatedWrapper<T: Decodable>: Decodable { let success: Bool; let data: [T]; let meta: FeedPgMeta? }
private struct FeedPgMeta: Decodable { let page: Int; let limit: Int; let total: Int }

final class FeedService {
    static let shared = FeedService()
    private let client = APIClient.shared
    private init() {}

    /// Fetch posts from the API.
    func fetchPosts(page: Int = 1, limit: Int = 20, tab: String? = nil, tag: String? = nil, role: String? = nil) async -> [FeedPostDTO] {
        do {
            var q: [URLQueryItem] = [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "limit", value: "\(limit)"),
            ]
            if let tab { q.append(URLQueryItem(name: "tab", value: tab)) }
            if let tag { q.append(URLQueryItem(name: "tag", value: tag)) }
            if let role { q.append(URLQueryItem(name: "role", value: role)) }
            let w: FeedPaginatedWrapper<FeedPostDTO> = try await client.request(.GET, path: "/feed", queryItems: q)
            return w.data
        } catch {
            return []
        }
    }

    struct MediaItem { let mediaType: String; let url: String }

    func createPost(body: String, mediaItems: [MediaItem] = [], location: String? = nil, tag: String? = nil, roleCategory: String? = nil, latitude: Double? = nil, longitude: Double? = nil) async throws -> FeedPostDTO {
        do {
            var d: [String: Any] = ["body": body]
            if let location { d["location"] = location }
            if let tag { d["tag"] = tag }
            if let roleCategory { d["role_category"] = roleCategory }
            if let latitude { d["latitude"] = latitude }
            if let longitude { d["longitude"] = longitude }

            // Multi-media
            if !mediaItems.isEmpty {
                d["media"] = mediaItems.map { ["media_type": $0.mediaType, "url": $0.url] }
                // Also set legacy fields for backward compat
                if let first = mediaItems.first {
                    if first.mediaType == "photo" { d["image_url"] = first.url }
                    else if first.mediaType == "video" { d["video_url"] = first.url }
                }
            }

            let w: FeedAPIWrapper<FeedPostDTO> = try await client.request(.POST, path: "/feed", body: JSONBody(d))
            return w.data
        } catch {
            let isBiz = BusinessAuthService.shared.isAuthenticated
            let name = CandidateAuthService.shared.currentUserName ?? BusinessAuthService.shared.currentUserName ?? "You"
            let initials: String = {
                let p = name.split(separator: " ")
                return p.count >= 2 ? "\(p[0].prefix(1))\(p[1].prefix(1))".uppercased() : String(name.prefix(2)).uppercased()
            }()
            let firstPhoto = mediaItems.first(where: { $0.mediaType == "photo" })?.url
            let firstVideo = mediaItems.first(where: { $0.mediaType == "video" })?.url
            let mediaDTOs = mediaItems.enumerated().map { i, m in PostMediaDTO(id: UUID().uuidString, mediaType: m.mediaType, url: m.url, sortOrder: i) }
            return FeedPostDTO(
                id: UUID().uuidString, body: body, imageUrl: firstPhoto, videoUrl: firstVideo, location: location,
                tag: tag, roleCategory: roleCategory, likeCount: 0, commentCount: 0, viewCount: 0, saveCount: 0,
                latitude: latitude, longitude: longitude,
                createdAt: ISO8601DateFormatter().string(from: Date()),
                userId: nil, authorName: name, authorType: isBiz ? "business" : "candidate",
                authorPhotoUrl: nil, authorAvatarHue: CandidateAuthService.shared.currentUserAvatarHue,
                authorVerified: false, authorSubtitle: nil, authorLocation: location,
                authorNationality: nil, authorNationalityCode: nil, authorCountryCode: nil,
                authorInitials: initials, isLiked: false, isFollowing: nil, isOwn: true, isSaved: false,
                media: mediaDTOs
            )
        }
    }

    func toggleLike(postId: String) async -> Bool? {
        do {
            let w: FeedAPIWrapper<LikeResponseDTO> = try await client.request(.POST, path: "/feed/\(postId)/like")
            return w.data.liked
        } catch { return nil }
    }

    func fetchComments(postId: String) async -> [FeedCommentDTO] {
        do {
            let w: FeedPaginatedWrapper<FeedCommentDTO> = try await client.request(.GET, path: "/feed/\(postId)/comments")
            return w.data
        } catch {
            return []
        }
    }

    func addComment(postId: String, body: String) async -> FeedCommentDTO {
        do {
            struct B: Encodable { let body: String }
            let w: FeedAPIWrapper<FeedCommentDTO> = try await client.request(.POST, path: "/feed/\(postId)/comments", body: B(body: body))
            return w.data
        } catch {
            return FeedCommentDTO(
                id: UUID().uuidString, body: body,
                createdAt: ISO8601DateFormatter().string(from: Date()),
                userId: nil, authorName: "You", authorType: "candidate",
                authorPhotoUrl: nil, authorAvatarHue: 0.55, authorVerified: false, authorInitials: "ME",
                authorNationalityCode: nil
            )
        }
    }

    func followUser(userId: String) async -> Bool {
        do {
            struct R: Decodable { let following: Bool }
            let w: FeedAPIWrapper<R> = try await client.request(.POST, path: "/feed/follow/\(userId)")
            return w.data.following
        } catch { return true } // Optimistic
    }

    func unfollowUser(userId: String) async -> Bool {
        do {
            struct R: Decodable { let following: Bool }
            let w: FeedAPIWrapper<R> = try await client.request(.DELETE, path: "/feed/follow/\(userId)")
            return w.data.following
        } catch { return false }
    }

    // MARK: - Notifications

    func fetchNotifications(limit: Int = 30) async -> [FeedNotificationDTO] {
        do {
            let w: FeedPaginatedWrapper<FeedNotificationDTO> = try await client.request(.GET, path: "/feed/notifications", queryItems: [URLQueryItem(name: "limit", value: "\(limit)")])
            return w.data
        } catch { return [] }
    }

    func unreadCount() async -> Int {
        do {
            struct R: Decodable { let count: Int }
            let w: FeedAPIWrapper<R> = try await client.request(.GET, path: "/feed/notifications/count")
            return w.data.count
        } catch { return 0 }
    }

    func markNotificationRead(id: String) async {
        try? await client.requestVoid(.PATCH, path: "/feed/notifications/\(id)/read")
    }

    func markAllNotificationsRead() async {
        try? await client.requestVoid(.PATCH, path: "/feed/notifications/read-all")
    }

    func deletePost(postId: String) async {
        try? await client.requestVoid(.DELETE, path: "/feed/\(postId)")
    }

    // MARK: - View Tracking

    func recordView(postId: String) async {
        try? await client.requestVoid(.POST, path: "/feed/\(postId)/view")
    }

    // MARK: - Post Actions (Menu)

    func savePost(postId: String) async -> Bool {
        do {
            struct R: Decodable { let saved: Bool }
            let w: FeedAPIWrapper<R> = try await client.request(.POST, path: "/feed/\(postId)/save")
            return w.data.saved
        } catch { return true } // Optimistic
    }

    func unsavePost(postId: String) async -> Bool {
        do {
            struct R: Decodable { let saved: Bool }
            let w: FeedAPIWrapper<R> = try await client.request(.DELETE, path: "/feed/\(postId)/save")
            return !w.data.saved
        } catch { return true }
    }

    func reportPost(postId: String, reason: String, details: String? = nil) async -> Bool {
        do {
            struct B: Encodable { let reason: String; let details: String? }
            let _: FeedAPIWrapper<EmptyResponse> = try await client.request(.POST, path: "/feed/\(postId)/report", body: B(reason: reason, details: details))
            return true
        } catch { return true } // Optimistic
    }

    func muteUser(userId: String) async -> Bool {
        do {
            let _: FeedAPIWrapper<EmptyResponse> = try await client.request(.POST, path: "/feed/mute/\(userId)")
            return true
        } catch { return true }
    }

    func blockUser(userId: String) async -> Bool {
        do {
            let _: FeedAPIWrapper<EmptyResponse> = try await client.request(.POST, path: "/feed/block/\(userId)")
            return true
        } catch { return true }
    }

    func notInterestedInPost(postId: String) async -> Bool {
        do {
            let _: FeedAPIWrapper<EmptyResponse> = try await client.request(.POST, path: "/feed/\(postId)/not-interested")
            return true
        } catch { return true }
    }

    func updatePost(postId: String, body: String) async -> Bool {
        do {
            struct B: Encodable { let body: String }
            let _: FeedAPIWrapper<EmptyResponse> = try await client.request(.PATCH, path: "/feed/\(postId)", body: B(body: body))
            return true
        } catch { return false }
    }

    func togglePostNotifications(postId: String, enabled: Bool) async -> Bool {
        do {
            struct B: Encodable { let enabled: Bool }
            let _: FeedAPIWrapper<EmptyResponse> = try await client.request(.PATCH, path: "/feed/\(postId)/notifications", body: B(enabled: enabled))
            return true
        } catch { return true }
    }

    // MARK: - Admin Moderation

    func adminRemovePost(postId: String) async -> Bool {
        do {
            let _: FeedAPIWrapper<EmptyResponse> = try await client.request(.DELETE, path: "/feed/admin/\(postId)")
            return true
        } catch { return false }
    }

    func adminMarkSpam(postId: String) async -> Bool {
        do {
            let _: FeedAPIWrapper<EmptyResponse> = try await client.request(.POST, path: "/feed/admin/\(postId)/spam")
            return true
        } catch { return false }
    }

    func adminSuspendUser(userId: String) async -> Bool {
        do {
            let _: FeedAPIWrapper<EmptyResponse> = try await client.request(.POST, path: "/feed/admin/suspend/\(userId)")
            return true
        } catch { return false }
    }
}

private struct EmptyResponse: Decodable {}

