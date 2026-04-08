//
//  AdminSettingsService.swift
//  Plagit
//

import Foundation

struct AdminSettings {
    var maintenanceMode: Bool = false
    var onboardingEnabled: Bool = true
    var pushEnabled: Bool = true
    var emailEnabled: Bool = true
    var smsEnabled: Bool = false
    var inAppEnabled: Bool = true
    var mapEnabled: Bool = true
    var autoFlagEnabled: Bool = true
    var abuseFilterEnabled: Bool = true
    var communityEnabled: Bool = true
    var homePreviewEnabled: Bool = true
    var nearMeEnabled: Bool = true
    var offerFlowEnabled: Bool = true
    var mapModeEnabled: Bool = false
    var experimentalOnboarding: Bool = false
}

protocol AdminSettingsServiceProtocol: Sendable {
    func fetchSettings() async throws -> AdminSettings
    func saveSettings(_ settings: AdminSettings) async throws
}

final class MockAdminSettingsService: AdminSettingsServiceProtocol, @unchecked Sendable {
    private var settings = AdminSettings()
    func fetchSettings() async throws -> AdminSettings { try await Task.sleep(for: .milliseconds(300)); return settings }
    func saveSettings(_ settings: AdminSettings) async throws { try await Task.sleep(for: .milliseconds(200)); self.settings = settings }
}

enum AdminSettingsServiceError: LocalizedError {
    case saveFailed; case networkError(String)
    var errorDescription: String? { switch self { case .saveFailed: return "Failed to save settings."; case .networkError(let m): return m } }
}
