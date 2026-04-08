//
//  AdminFeaturedContentAPIService.swift
//  Plagit
//

import Foundation

private struct APIWrapper<T: Decodable>: Decodable { let success: Bool; let data: T }

private struct FeaturedDTO: Decodable {
    let id: String; let title: String; let type: String?; let linkedEntity: String?
    let placement: String?; let status: String; let isPinned: Bool; let priority: Int?
    let startDate: String?; let endDate: String?; let clicks: Int?; let views: Int?
    let avatarHue: Double?; let updatedAt: String?

    func toModel() -> AdminFeaturedItem {
        AdminFeaturedItem(
            id: UUID(uuidString: id) ?? UUID(), title: title,
            type: type ?? "", linkedEntity: linkedEntity ?? "",
            placement: placement ?? "", status: status.capitalized,
            isPinned: isPinned, priority: priority ?? 0,
            startDate: fmtShort(startDate), endDate: fmtShort(endDate),
            clicks: clicks ?? 0, views: views ?? 0,
            lastUpdated: fmtRelative(updatedAt), avatarHue: avatarHue ?? 0.5
        )
    }
    private func fmtShort(_ s: String?) -> String {
        guard let s, s != "null" else { return "—" }
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        guard let d = f.date(from: s) else { return s }
        let o = DateFormatter(); o.dateFormat = "MMM d"; return o.string(from: d)
    }
    private func fmtRelative(_ s: String?) -> String {
        guard let s else { return "—" }
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let d = f.date(from: s) else { return s }
        let secs = Date().timeIntervalSince(d)
        if secs < 3600 { return "\(Int(secs/60))m ago" }
        if secs < 86400 { return "\(Int(secs/3600))h ago" }; return "\(Int(secs/86400))d ago"
    }
}

private struct StatusReq: Encodable { let status: String }
private struct PinReq: Encodable { let pinned: Bool }

final class AdminFeaturedContentAPIService: AdminFeaturedContentServiceProtocol, @unchecked Sendable {
    private let client: APIClient
    init(client: APIClient = .shared) { self.client = client }

    func fetchItems() async throws -> [AdminFeaturedItem] {
        let w: APIWrapper<[FeaturedDTO]> = try await client.request(.GET, path: "/admin/featured")
        return w.data.map { $0.toModel() }
    }
    func updateStatus(id: UUID, status: String) async throws {
        try await client.requestVoid(.PATCH, path: "/admin/featured/\(id.uuidString)/status", body: StatusReq(status: status.lowercased()))
    }
    func setPinned(id: UUID, pinned: Bool) async throws {
        try await client.requestVoid(.PATCH, path: "/admin/featured/\(id.uuidString)/pin", body: PinReq(pinned: pinned))
    }
    func deleteItem(id: UUID) async throws {
        try await client.requestVoid(.DELETE, path: "/admin/featured/\(id.uuidString)")
    }
}
