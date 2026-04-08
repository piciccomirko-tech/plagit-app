//
//  AdminAuthService.swift
//  Plagit
//
//  Handles admin login, token storage, and session management.
//

import Foundation
import Security

// MARK: - Response DTOs

private struct APIWrapper<T: Decodable>: Decodable {
    let success: Bool
    let data: T
}

private struct LoginResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let user: LoginUser
}

private struct LoginUser: Decodable {
    let id: String
    let name: String
    let email: String
    let role: String
    let adminRole: String?
    let isVerified: Bool
}

// MARK: - Keychain Helper

private enum KeychainHelper {
    static func save(key: String, value: String) {
        let data = Data(value.utf8)
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                     kSecAttrAccount as String: key]
        SecItemDelete(query as CFDictionary)
        let add: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                   kSecAttrAccount as String: key,
                                   kSecValueData as String: data,
                                   kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly]
        SecItemAdd(add as CFDictionary, nil)
    }

    static func load(key: String) -> String? {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                     kSecAttrAccount as String: key,
                                     kSecReturnData as String: true,
                                     kSecMatchLimit as String: kSecMatchLimitOne]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func delete(key: String) {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                     kSecAttrAccount as String: key]
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - Auth Service

@Observable
final class AdminAuthService {
    static let shared = AdminAuthService()

    var isAuthenticated = false
    var isRestoring = false
    var sessionExpired = false
    var currentUserName: String?
    var currentUserEmail: String?

    private var refreshToken: String?
    private let client = APIClient.shared

    private static let keychainAccessToken = "com.plagit.admin.accessToken"
    private static let keychainRefreshToken = "com.plagit.admin.refreshToken"
    private static let keychainUserName = "com.plagit.admin.userName"
    private static let keychainUserEmail = "com.plagit.admin.userEmail"

    private init() {}

    /// Attempt to restore a previous session from Keychain, refreshing the access token if possible.
    @MainActor
    func restoreSession() async {
        guard let storedRefresh = KeychainHelper.load(key: Self.keychainRefreshToken) else { return }

        isRestoring = true
        defer { isRestoring = false }

        // Try to get a fresh access token using the stored refresh token
        do {
            struct RefreshBody: Encodable { let refreshToken: String }
            let wrapper: APIWrapper<RefreshResponse> = try await client.request(
                .POST, path: "/auth/refresh",
                body: RefreshBody(refreshToken: storedRefresh)
            )
            let data = wrapper.data
            APIConfig.authToken = data.accessToken
            refreshToken = data.refreshToken

            // Persist the rotated tokens
            KeychainHelper.save(key: Self.keychainAccessToken, value: data.accessToken)
            KeychainHelper.save(key: Self.keychainRefreshToken, value: data.refreshToken)

            currentUserName = KeychainHelper.load(key: Self.keychainUserName)
            currentUserEmail = KeychainHelper.load(key: Self.keychainUserEmail)
            isAuthenticated = true
        } catch {
            // Refresh token expired or revoked — clear stale Keychain data
            clearPersistedTokens()
            // Only flag as expired if there was a remembered session (user will see the message)
            if UserDefaults.standard.bool(forKey: "rememberMe") {
                sessionExpired = true
            }
        }
    }

    @MainActor
    func login(email: String, password: String, rememberMe: Bool = false) async throws {
        struct LoginBody: Encodable {
            let email: String
            let password: String
        }

        let wrapper: APIWrapper<LoginResponse> = try await client.request(
            .POST, path: "/auth/login",
            body: LoginBody(email: email, password: password)
        )

        let data = wrapper.data
        APIConfig.authToken = data.accessToken
        refreshToken = data.refreshToken
        currentUserName = data.user.name
        currentUserEmail = data.user.email
        sessionExpired = false
        isAuthenticated = true

        if rememberMe {
            KeychainHelper.save(key: Self.keychainAccessToken, value: data.accessToken)
            KeychainHelper.save(key: Self.keychainRefreshToken, value: data.refreshToken)
            KeychainHelper.save(key: Self.keychainUserName, value: data.user.name)
            KeychainHelper.save(key: Self.keychainUserEmail, value: data.user.email)
            UserDefaults.standard.set(true, forKey: "rememberMe")
            UserDefaults.standard.set(email, forKey: "rememberedEmail")
        } else {
            clearPersistedTokens()
            UserDefaults.standard.removeObject(forKey: "rememberMe")
            UserDefaults.standard.removeObject(forKey: "rememberedEmail")
        }
    }

    @MainActor
    func changePassword(newPassword: String) async throws {
        struct ChangePasswordBody: Encodable {
            let newPassword: String
        }

        let _: APIWrapper<ChangePasswordMessage> = try await client.request(
            .POST, path: "/auth/change-password",
            body: ChangePasswordBody(newPassword: newPassword)
        )

        // Server revokes all refresh tokens, so force logout
        logout()
    }

    func logout() {
        APIConfig.authToken = nil
        refreshToken = nil
        isAuthenticated = false
        currentUserName = nil
        currentUserEmail = nil
        clearPersistedTokens()
        // Keep rememberMe flag and rememberedEmail in UserDefaults so
        // the email field is pre-filled on the next login screen.
    }

    /// Clears tokens and user info from Keychain but preserves the
    /// remembered-email preference in UserDefaults.
    private func clearPersistedTokens() {
        KeychainHelper.delete(key: Self.keychainAccessToken)
        KeychainHelper.delete(key: Self.keychainRefreshToken)
        KeychainHelper.delete(key: Self.keychainUserName)
        KeychainHelper.delete(key: Self.keychainUserEmail)
    }
}

private struct RefreshResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}

private struct ChangePasswordMessage: Decodable {
    let message: String
}
