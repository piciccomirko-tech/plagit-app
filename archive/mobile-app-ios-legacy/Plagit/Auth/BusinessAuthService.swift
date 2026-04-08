//
//  BusinessAuthService.swift
//  Plagit
//
//  Handles business login, registration, token storage, and session management.
//

import Foundation
import Security

private struct APIWrapper<T: Decodable>: Decodable { let success: Bool; let data: T }
private struct LoginResponse: Decodable { let accessToken: String; let refreshToken: String; let user: LoginUser }
private struct LoginUser: Decodable { let id: String; let name: String; let email: String; let role: String; let isVerified: Bool }
private struct RefreshResponse: Decodable { let accessToken: String; let refreshToken: String }

private enum BizKeychainHelper {
    static func save(key: String, value: String) {
        let data = Data(value.utf8)
        let q: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrAccount as String: key]
        SecItemDelete(q as CFDictionary)
        let add: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrAccount as String: key,
                                   kSecValueData as String: data, kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly]
        SecItemAdd(add as CFDictionary, nil)
    }
    static func load(key: String) -> String? {
        let q: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrAccount as String: key,
                                 kSecReturnData as String: true, kSecMatchLimit as String: kSecMatchLimitOne]
        var result: AnyObject?
        guard SecItemCopyMatching(q as CFDictionary, &result) == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
    static func delete(key: String) {
        let q: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrAccount as String: key]
        SecItemDelete(q as CFDictionary)
    }
}

@Observable
final class BusinessAuthService {
    static let shared = BusinessAuthService()

    var isAuthenticated = false
    var isRestoring = false
    var sessionExpired = false
    var currentUserName: String?
    var currentUserEmail: String?

    private var refreshToken: String?
    private let client = APIClient.shared

    private static let kcAccess  = "com.plagit.business.accessToken"
    private static let kcRefresh = "com.plagit.business.refreshToken"
    private static let kcName    = "com.plagit.business.userName"
    private static let kcEmail   = "com.plagit.business.userEmail"

    private init() {}

    // MARK: - Restore

    @MainActor
    func restoreSession() async {
        guard let storedRefresh = BizKeychainHelper.load(key: Self.kcRefresh) else { return }
        isRestoring = true
        defer { isRestoring = false }
        do {
            struct Body: Encodable { let refreshToken: String }
            let w: APIWrapper<RefreshResponse> = try await client.request(.POST, path: "/auth/refresh", body: Body(refreshToken: storedRefresh))
            APIConfig.authToken = w.data.accessToken
            refreshToken = w.data.refreshToken
            BizKeychainHelper.save(key: Self.kcAccess, value: w.data.accessToken)
            BizKeychainHelper.save(key: Self.kcRefresh, value: w.data.refreshToken)
            currentUserName = BizKeychainHelper.load(key: Self.kcName)
            currentUserEmail = BizKeychainHelper.load(key: Self.kcEmail)
            isAuthenticated = true
            await SubscriptionManager.shared.refreshFromStoreKit()
        } catch {
            clearTokens()
            if UserDefaults.standard.bool(forKey: "businessRememberMe") { sessionExpired = true }
        }
    }

    // MARK: - Login

    @MainActor
    func login(email: String, password: String, rememberMe: Bool = false) async throws {
        struct Body: Encodable { let email: String; let password: String }
        let w: APIWrapper<LoginResponse> = try await client.request(.POST, path: "/auth/login", body: Body(email: email, password: password))
        guard w.data.user.role == "business" else { throw APIError.badRequest("This account is not a business account.") }
        apply(w.data, rememberMe: rememberMe, email: email)
    }

    // MARK: - Register

    @MainActor
    func register(companyName: String, contactPerson: String?, email: String, password: String, venueType: String?, location: String?, requiredRole: String? = nil, jobType: String? = nil, openToInternational: Bool = false) async throws {
        struct Body: Encodable {
            let companyName: String; let contactPerson: String?; let email: String; let password: String
            let venueType: String?; let location: String?
            let requiredRole: String?; let jobType: String?; let openToInternational: Bool
            enum CodingKeys: String, CodingKey {
                case companyName = "company_name"; case contactPerson = "contact_person"
                case email, password
                case venueType = "venue_type"; case location
                case requiredRole = "required_role"; case jobType = "job_type"
                case openToInternational = "open_to_international"
            }
        }
        let w: APIWrapper<LoginResponse> = try await client.request(.POST, path: "/auth/register/business",
            body: Body(companyName: companyName, contactPerson: contactPerson, email: email, password: password,
                       venueType: venueType, location: location, requiredRole: requiredRole, jobType: jobType,
                       openToInternational: openToInternational))
        apply(w.data, rememberMe: true, email: email)
    }

    // MARK: - Logout

    @MainActor
    func logout() {
        APIConfig.authToken = nil; refreshToken = nil
        isAuthenticated = false; currentUserName = nil; currentUserEmail = nil
        SubscriptionManager.shared.reset()
        clearTokens()
    }

    // MARK: - Private

    private func apply(_ data: LoginResponse, rememberMe: Bool, email: String) {
        APIConfig.authToken = data.accessToken
        refreshToken = data.refreshToken
        currentUserName = data.user.name
        currentUserEmail = data.user.email
        sessionExpired = false
        isAuthenticated = true
        Task { await SubscriptionManager.shared.refreshStatus() }
        if rememberMe {
            BizKeychainHelper.save(key: Self.kcAccess, value: data.accessToken)
            BizKeychainHelper.save(key: Self.kcRefresh, value: data.refreshToken)
            BizKeychainHelper.save(key: Self.kcName, value: data.user.name)
            BizKeychainHelper.save(key: Self.kcEmail, value: data.user.email)
            UserDefaults.standard.set(true, forKey: "businessRememberMe")
            UserDefaults.standard.set(email, forKey: "businessRememberedEmail")
        } else {
            clearTokens()
            UserDefaults.standard.removeObject(forKey: "businessRememberMe")
            UserDefaults.standard.removeObject(forKey: "businessRememberedEmail")
        }
    }

    private func clearTokens() {
        BizKeychainHelper.delete(key: Self.kcAccess)
        BizKeychainHelper.delete(key: Self.kcRefresh)
        BizKeychainHelper.delete(key: Self.kcName)
        BizKeychainHelper.delete(key: Self.kcEmail)
    }
}
