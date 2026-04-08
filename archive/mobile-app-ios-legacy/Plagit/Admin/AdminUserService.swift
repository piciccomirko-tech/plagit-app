//
//  AdminUserService.swift
//  Plagit
//
//  Protocol-based service for admin user operations.
//  Swap MockAdminUserService for a real API implementation later.
//

import Foundation

// MARK: - Protocol

protocol AdminUserServiceProtocol: Sendable {
    func fetchUsers() async throws -> [AdminUser]
    func updateUser(_ user: AdminUser) async throws -> AdminUser
    func updateUserStatus(id: UUID, status: String) async throws
    func setVerified(id: UUID, verified: Bool) async throws
    func deleteUser(id: UUID) async throws
    func sendMessage(to userId: UUID, subject: String, body: String) async throws
}

// MARK: - Mock Implementation

final class MockAdminUserService: AdminUserServiceProtocol, @unchecked Sendable {
    private var users: [AdminUser] = AdminUser.sampleData

    func fetchUsers() async throws -> [AdminUser] {
        try await Task.sleep(for: .milliseconds(300))
        return users
    }

    func updateUser(_ user: AdminUser) async throws -> AdminUser {
        try await Task.sleep(for: .milliseconds(200))
        guard let i = users.firstIndex(where: { $0.id == user.id }) else {
            throw AdminUserServiceError.userNotFound
        }
        users[i] = user
        return users[i]
    }

    func updateUserStatus(id: UUID, status: String) async throws {
        try await Task.sleep(for: .milliseconds(200))
        guard let i = users.firstIndex(where: { $0.id == id }) else {
            throw AdminUserServiceError.userNotFound
        }
        users[i].status = status
    }

    func setVerified(id: UUID, verified: Bool) async throws {
        try await Task.sleep(for: .milliseconds(200))
        guard let i = users.firstIndex(where: { $0.id == id }) else {
            throw AdminUserServiceError.userNotFound
        }
        users[i].isVerified = verified
        if verified && users[i].status != "Banned" {
            users[i].status = "Active"
        }
    }

    func deleteUser(id: UUID) async throws {
        try await Task.sleep(for: .milliseconds(200))
        guard let i = users.firstIndex(where: { $0.id == id }) else {
            throw AdminUserServiceError.userNotFound
        }
        users.remove(at: i)
    }

    func sendMessage(to userId: UUID, subject: String, body: String) async throws {
        try await Task.sleep(for: .milliseconds(300))
        guard users.contains(where: { $0.id == userId }) else {
            throw AdminUserServiceError.userNotFound
        }
        // Mock: message "sent" successfully
    }
}

// MARK: - Errors

enum AdminUserServiceError: LocalizedError {
    case userNotFound
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .userNotFound: return "User not found."
        case .networkError(let msg): return msg
        }
    }
}
