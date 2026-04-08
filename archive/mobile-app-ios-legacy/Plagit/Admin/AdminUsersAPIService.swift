//
//  AdminUsersAPIService.swift
//  Plagit
//
//  Real REST API implementation of AdminUserServiceProtocol.
//

import Foundation

// MARK: - API Endpoints

private enum Endpoints {
    static let users = "/admin/users"
    static func user(_ id: UUID) -> String { "/admin/users/\(id.uuidString)" }
    static func status(_ id: UUID) -> String { "/admin/users/\(id.uuidString)/status" }
    static func verify(_ id: UUID) -> String { "/admin/users/\(id.uuidString)/verify" }
    static func message(_ id: UUID) -> String { "/admin/users/\(id.uuidString)/message" }
}

// MARK: - Response DTOs (matches real backend JSON)

private struct APIWrapper<T: Decodable>: Decodable {
    let success: Bool
    let data: T
    let meta: PaginationMeta?
}

private struct PaginationMeta: Decodable {
    let page: Int
    let limit: Int
    let total: Int
    let pages: Int
}

private struct UserDTO: Decodable {
    let id: String
    let name: String
    let initials: String?
    let email: String
    let phone: String?
    let userType: String
    let adminRole: String?
    let location: String?
    let role: String?
    let status: String
    let isVerified: Bool
    let profileStrength: Int?
    let flagCount: Int?
    let avatarHue: Double?
    let plan: String?
    let createdAt: String?
    let updatedAt: String?

    func toModel() -> AdminUser {
        AdminUser(
            id: UUID(uuidString: id) ?? UUID(),
            name: name,
            initials: initials ?? String(name.prefix(2)).uppercased(),
            email: email,
            phone: phone ?? "",
            userType: userType.capitalized,
            location: location ?? "",
            role: role ?? "",
            status: status.capitalized,
            isVerified: isVerified,
            joinedDate: formatDate(createdAt),
            lastActive: formatDate(updatedAt),
            profileStrength: profileStrength ?? 0,
            flagCount: flagCount ?? 0,
            avatarHue: avatarHue ?? 0.5,
            plan: plan ?? ""
        )
    }

    private func formatDate(_ iso: String?) -> String {
        guard let iso else { return "—" }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: iso) else { return iso }
        let display = DateFormatter()
        display.dateFormat = "MMM yyyy"
        return display.string(from: date)
    }
}

// MARK: - Request DTOs

private struct UserUpdateRequest: Encodable {
    let name: String
    let email: String
    let role: String
    let location: String
    let status: String
    let isVerified: Bool
}

private struct StatusRequest: Encodable { let status: String }
private struct VerifyRequest: Encodable { let verified: Bool }
private struct MessageRequest: Encodable { let subject: String; let body: String }

// MARK: - API Service

final class AdminUsersAPIService: AdminUserServiceProtocol, @unchecked Sendable {
    private let client: APIClient

    init(client: APIClient = .shared) { self.client = client }

    func fetchUsers() async throws -> [AdminUser] {
        let wrapper: APIWrapper<[UserDTO]> = try await client.request(.GET, path: Endpoints.users)
        return wrapper.data.map { $0.toModel() }
    }

    func updateUser(_ user: AdminUser) async throws -> AdminUser {
        let body = UserUpdateRequest(
            name: user.name, email: user.email, role: user.role,
            location: user.location, status: user.status.lowercased(),
            isVerified: user.isVerified
        )
        let wrapper: APIWrapper<UserDTO> = try await client.request(.PUT, path: Endpoints.user(user.id), body: body)
        return wrapper.data.toModel()
    }

    func updateUserStatus(id: UUID, status: String) async throws {
        try await client.requestVoid(.PATCH, path: Endpoints.status(id), body: StatusRequest(status: status.lowercased()))
    }

    func setVerified(id: UUID, verified: Bool) async throws {
        try await client.requestVoid(.PATCH, path: Endpoints.verify(id), body: VerifyRequest(verified: verified))
    }

    func deleteUser(id: UUID) async throws {
        try await client.requestVoid(.DELETE, path: Endpoints.user(id))
    }

    func sendMessage(to userId: UUID, subject: String, body: String) async throws {
        try await client.requestVoid(.POST, path: Endpoints.message(userId), body: MessageRequest(subject: subject, body: body))
    }
}
