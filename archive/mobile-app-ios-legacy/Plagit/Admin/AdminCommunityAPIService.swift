//
//  AdminCommunityAPIService.swift
//  Plagit
//

import Foundation

private struct APIWrapper<T: Decodable>: Decodable { let success: Bool; let data: T }

private struct PostDTO: Decodable {
    let id: String; let title: String; let category: String?; let author: String?
    let authorInitials: String?; let status: String; let isPinned: Bool
    let isFeaturedOnHome: Bool; let linkedEmployer: String?; let linkedJob: String?
    let publishedDate: String?; let views: Int?; let saves: Int?
    let readTime: String?; let summary: String?; let avatarHue: Double?; let createdAt: String?

    func toModel() -> AdminContent {
        AdminContent(
            id: UUID(uuidString: id) ?? UUID(), title: title,
            category: category ?? "", author: author ?? "",
            authorInitials: authorInitials ?? "??", status: status.capitalized,
            isPinned: isPinned, isFeaturedOnHome: isFeaturedOnHome,
            linkedEmployer: linkedEmployer ?? "", linkedJob: linkedJob ?? "",
            createdDate: fmtShort(createdAt), publishedDate: fmtShort(publishedDate),
            views: views ?? 0, saves: saves ?? 0,
            readTime: readTime ?? "", summary: summary ?? "",
            avatarHue: avatarHue ?? 0.5
        )
    }
    private func fmtShort(_ s: String?) -> String {
        guard let s, s != "null" else { return "—" }
        for fmt in ["yyyy-MM-dd'T'HH:mm:ss.SSSZ", "yyyy-MM-dd"] {
            let f = DateFormatter(); f.dateFormat = fmt; f.locale = Locale(identifier: "en_US_POSIX")
            if let d = f.date(from: s) { let o = DateFormatter(); o.dateFormat = "MMM d"; return o.string(from: d) }
        }
        return s
    }
}

private struct StatusReq: Encodable { let status: String }
private struct PinReq: Encodable { let pinned: Bool }
private struct FeatureReq: Encodable { let featured: Bool }

final class AdminCommunityAPIService: AdminCommunityServiceProtocol, @unchecked Sendable {
    private let client: APIClient
    init(client: APIClient = .shared) { self.client = client }

    func fetchPosts() async throws -> [AdminContent] {
        let w: APIWrapper<[PostDTO]> = try await client.request(.GET, path: "/admin/community")
        return w.data.map { $0.toModel() }
    }
    func updateStatus(id: UUID, status: String) async throws {
        try await client.requestVoid(.PATCH, path: "/admin/community/\(id.uuidString)/status", body: StatusReq(status: status.lowercased()))
    }
    func setPinned(id: UUID, pinned: Bool) async throws {
        try await client.requestVoid(.PATCH, path: "/admin/community/\(id.uuidString)/pin", body: PinReq(pinned: pinned))
    }
    func setFeaturedOnHome(id: UUID, featured: Bool) async throws {
        try await client.requestVoid(.PATCH, path: "/admin/community/\(id.uuidString)/feature", body: FeatureReq(featured: featured))
    }
    func deletePost(id: UUID) async throws {
        try await client.requestVoid(.DELETE, path: "/admin/community/\(id.uuidString)")
    }
}
