//
//  CandidateAuthService.swift
//  Plagit
//
//  Handles candidate login, token storage, and session management.
//  Mirrors AdminAuthService but uses separate Keychain keys to keep
//  candidate and admin sessions independent.
//

import Foundation
import Security

// MARK: - Response DTOs (private to this file)

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
    let isVerified: Bool
}

private struct RefreshResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}

// MARK: - Keychain Helper (candidate namespace)

private enum CandidateKeychainHelper {
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

// MARK: - Candidate Auth Service

@Observable
final class CandidateAuthService {
    static let shared = CandidateAuthService()

    var isAuthenticated = false
    var isRestoring = false
    var sessionExpired = false
    var currentUserName: String?
    var currentUserEmail: String?
    var currentUserInitials: String?
    var currentUserLocation: String?
    var currentUserAvatarHue: Double = 0.5

    private var refreshToken: String?
    private let client = APIClient.shared

    // Separate keychain namespace from admin
    private static let kcAccessToken  = "com.plagit.candidate.accessToken"
    private static let kcRefreshToken = "com.plagit.candidate.refreshToken"
    private static let kcUserName     = "com.plagit.candidate.userName"
    private static let kcUserEmail    = "com.plagit.candidate.userEmail"

    private init() {}

    // MARK: - Session Restore

    @MainActor
    func restoreSession() async {
        guard let storedRefresh = CandidateKeychainHelper.load(key: Self.kcRefreshToken) else { return }

        isRestoring = true
        defer { isRestoring = false }

        do {
            struct RefreshBody: Encodable { let refreshToken: String }
            let wrapper: APIWrapper<RefreshResponse> = try await client.request(
                .POST, path: "/auth/refresh",
                body: RefreshBody(refreshToken: storedRefresh)
            )
            let data = wrapper.data
            APIConfig.authToken = data.accessToken
            refreshToken = data.refreshToken

            CandidateKeychainHelper.save(key: Self.kcAccessToken, value: data.accessToken)
            CandidateKeychainHelper.save(key: Self.kcRefreshToken, value: data.refreshToken)

            currentUserName  = CandidateKeychainHelper.load(key: Self.kcUserName)
            currentUserEmail = CandidateKeychainHelper.load(key: Self.kcUserEmail)
            isAuthenticated  = true

            // Sync subscription status after session restore
            await SubscriptionManager.shared.refreshFromStoreKit()
        } catch {
            clearPersistedTokens()
            if UserDefaults.standard.bool(forKey: "candidateRememberMe") {
                sessionExpired = true
            }
        }
    }

    // MARK: - Login

    @MainActor
    func login(email: String, password: String, rememberMe: Bool = false) async throws {
        struct LoginBody: Encodable { let email: String; let password: String }

        let wrapper: APIWrapper<LoginResponse> = try await client.request(
            .POST, path: "/auth/login",
            body: LoginBody(email: email, password: password)
        )

        let data = wrapper.data

        // Reject non-candidate logins
        guard data.user.role == "candidate" else {
            throw APIError.badRequest("This account is not a candidate account.")
        }

        APIConfig.authToken = data.accessToken
        refreshToken    = data.refreshToken
        currentUserName  = data.user.name
        currentUserEmail = data.user.email
        currentUserInitials = data.user.name
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first.map(String.init) }
            .joined()
            .uppercased()
        sessionExpired  = false
        isAuthenticated = true
        Task { await SubscriptionManager.shared.refreshStatus() }

        if rememberMe {
            CandidateKeychainHelper.save(key: Self.kcAccessToken, value: data.accessToken)
            CandidateKeychainHelper.save(key: Self.kcRefreshToken, value: data.refreshToken)
            CandidateKeychainHelper.save(key: Self.kcUserName, value: data.user.name)
            CandidateKeychainHelper.save(key: Self.kcUserEmail, value: data.user.email)
            UserDefaults.standard.set(true, forKey: "candidateRememberMe")
            UserDefaults.standard.set(email, forKey: "candidateRememberedEmail")
        } else {
            clearPersistedTokens()
            UserDefaults.standard.removeObject(forKey: "candidateRememberMe")
            UserDefaults.standard.removeObject(forKey: "candidateRememberedEmail")
        }
    }

    // MARK: - Register

    @MainActor
    func register(name: String, email: String, password: String, role: String?, location: String?, experience: String?, languages: String?, jobType: String? = nil) async throws {
        struct RegisterBody: Encodable {
            let name: String; let email: String; let password: String
            let role: String?; let location: String?
            let experience: String?; let languages: String?
            let jobType: String?
            enum CodingKeys: String, CodingKey {
                case name, email, password, role, location, experience, languages
                case jobType = "job_type"
            }
        }

        let wrapper: APIWrapper<LoginResponse> = try await client.request(
            .POST, path: "/auth/register/candidate",
            body: RegisterBody(name: name, email: email, password: password,
                               role: role, location: location,
                               experience: experience, languages: languages,
                               jobType: jobType)
        )

        let data = wrapper.data
        APIConfig.authToken = data.accessToken
        refreshToken    = data.refreshToken
        currentUserName  = data.user.name
        currentUserEmail = data.user.email
        currentUserInitials = data.user.name
            .split(separator: " ").prefix(2)
            .compactMap { $0.first.map(String.init) }
            .joined().uppercased()
        sessionExpired  = false
        isAuthenticated = true

        // Always remember after registration
        CandidateKeychainHelper.save(key: Self.kcAccessToken, value: data.accessToken)
        CandidateKeychainHelper.save(key: Self.kcRefreshToken, value: data.refreshToken)
        CandidateKeychainHelper.save(key: Self.kcUserName, value: data.user.name)
        CandidateKeychainHelper.save(key: Self.kcUserEmail, value: data.user.email)
        UserDefaults.standard.set(true, forKey: "candidateRememberMe")
        UserDefaults.standard.set(email, forKey: "candidateRememberedEmail")
    }

    // MARK: - Logout

    @MainActor
    func logout() {
        APIConfig.authToken = nil
        refreshToken     = nil
        isAuthenticated  = false
        sessionExpired   = false
        currentUserName  = nil
        currentUserEmail = nil
        currentUserInitials = nil
        currentUserLocation = nil
        clearPersistedTokens()
        SubscriptionManager.shared.reset()
        UserDefaults.standard.removeObject(forKey: "candidateRememberMe")
        UserDefaults.standard.removeObject(forKey: "candidateRememberedEmail")
        UserDefaults.standard.removeObject(forKey: "plagit_welcome_email_sent")
        AppLocaleManager.shared.resetToDeviceLanguage()
    }

    // MARK: - Private

    private func clearPersistedTokens() {
        CandidateKeychainHelper.delete(key: Self.kcAccessToken)
        CandidateKeychainHelper.delete(key: Self.kcRefreshToken)
        CandidateKeychainHelper.delete(key: Self.kcUserName)
        CandidateKeychainHelper.delete(key: Self.kcUserEmail)
    }
}
