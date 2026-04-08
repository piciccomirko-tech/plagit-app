//
//  AdminBusinessesAPIService.swift
//  Plagit
//
//  Real REST API implementation of AdminBusinessServiceProtocol.
//

import Foundation

// MARK: - Endpoints

private enum Endpoints {
    static let businesses = "/admin/businesses"
    static func biz(_ id: UUID) -> String { "/admin/businesses/\(id.uuidString)" }
    static func status(_ id: UUID) -> String { "/admin/businesses/\(id.uuidString)/status" }
    static func verify(_ id: UUID) -> String { "/admin/businesses/\(id.uuidString)/verify" }
    static func featured(_ id: UUID) -> String { "/admin/businesses/\(id.uuidString)/featured" }
}

// MARK: - Response DTOs

private struct APIWrapper<T: Decodable>: Decodable {
    let success: Bool
    let data: T
}

private struct BizDTO: Decodable {
    let id: String
    let name: String
    let initials: String?
    let venueType: String?
    let location: String?
    let contact: String?
    let email: String?
    let status: String
    let isVerified: Bool
    let isFeatured: Bool
    let plan: String?
    let planStatus: String?
    let renewalDate: String?
    let responseRate: Int?
    let flagCount: Int?
    let avatarHue: Double?
    let createdAt: String?
    let updatedAt: String?

    func toModel() -> AdminBiz {
        AdminBiz(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            initials: initials ?? String(name.prefix(2)).uppercased(),
            venueType: venueType ?? "",
            location: location ?? "",
            contact: contact ?? "",
            email: email ?? "",
            status: status.capitalized,
            isVerified: isVerified,
            isFeatured: isFeatured,
            plan: plan ?? "Basic",
            planStatus: (planStatus ?? "active").capitalized,
            renewalDate: formatDate(renewalDate),
            activeJobs: 0, // TODO: join from jobs table
            applicantsReceived: 0,
            responseRate: responseRate ?? 0,
            lastActive: formatRelative(updatedAt),
            joinedDate: formatMonth(createdAt),
            flagCount: flagCount ?? 0,
            avatarHue: avatarHue ?? 0.5
        )
    }

    private func formatDate(_ str: String?) -> String {
        guard let str, str != "null" else { return "—" }
        if let date = ISO8601DateFormatter().date(from: str) {
            let f = DateFormatter(); f.dateFormat = "MMM d, yyyy"; return f.string(from: date)
        }
        // Try date-only format
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        if let date = f.date(from: str) {
            let out = DateFormatter(); out.dateFormat = "MMM d, yyyy"; return out.string(from: date)
        }
        return str
    }

    private func formatMonth(_ iso: String?) -> String {
        guard let iso else { return "—" }
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = f.date(from: iso) else { return iso }
        let d = DateFormatter(); d.dateFormat = "MMM yyyy"; return d.string(from: date)
    }

    private func formatRelative(_ iso: String?) -> String {
        guard let iso else { return "—" }
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = f.date(from: iso) else { return iso }
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "Just now" }
        if interval < 3600 { return "\(Int(interval / 60))m ago" }
        if interval < 86400 { return "\(Int(interval / 3600))h ago" }
        return "\(Int(interval / 86400))d ago"
    }
}

// MARK: - Request DTOs

private struct StatusRequest: Encodable { let status: String }
private struct VerifyRequest: Encodable { let verified: Bool }
private struct FeaturedRequest: Encodable { let featured: Bool }

// MARK: - API Service

final class AdminBusinessesAPIService: AdminBusinessServiceProtocol, @unchecked Sendable {
    private let client: APIClient

    init(client: APIClient = .shared) { self.client = client }

    func fetchBusinesses() async throws -> [AdminBiz] {
        let wrapper: APIWrapper<[BizDTO]> = try await client.request(.GET, path: Endpoints.businesses)
        return wrapper.data.map { $0.toModel() }
    }

    func updateStatus(id: UUID, status: String) async throws {
        try await client.requestVoid(.PATCH, path: Endpoints.status(id), body: StatusRequest(status: status.lowercased()))
    }

    func setVerified(id: UUID, verified: Bool) async throws {
        try await client.requestVoid(.PATCH, path: Endpoints.verify(id), body: VerifyRequest(verified: verified))
    }

    func setFeatured(id: UUID, featured: Bool) async throws {
        try await client.requestVoid(.PATCH, path: Endpoints.featured(id), body: FeaturedRequest(featured: featured))
    }

    func deleteBusiness(id: UUID) async throws {
        try await client.requestVoid(.DELETE, path: Endpoints.biz(id))
    }
}
