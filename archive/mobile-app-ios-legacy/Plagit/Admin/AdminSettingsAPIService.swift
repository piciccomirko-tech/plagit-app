//
//  AdminSettingsAPIService.swift
//  Plagit
//

import Foundation

private struct APIWrapper<T: Decodable>: Decodable { let success: Bool; let data: T }

final class AdminSettingsAPIService: AdminSettingsServiceProtocol, @unchecked Sendable {
    private let client: APIClient
    init(client: APIClient = .shared) { self.client = client }

    func fetchSettings() async throws -> AdminSettings {
        let w: APIWrapper<[String: String]> = try await client.request(.GET, path: "/admin/settings")
        let d = w.data
        var s = AdminSettings()
        if let v = d["maintenanceMode"] { s.maintenanceMode = v == "true" }
        if let v = d["onboardingEnabled"] { s.onboardingEnabled = v == "true" }
        if let v = d["pushEnabled"] { s.pushEnabled = v == "true" }
        if let v = d["emailEnabled"] { s.emailEnabled = v == "true" }
        if let v = d["smsEnabled"] { s.smsEnabled = v == "true" }
        if let v = d["inAppEnabled"] { s.inAppEnabled = v == "true" }
        if let v = d["mapEnabled"] { s.mapEnabled = v == "true" }
        if let v = d["autoFlagEnabled"] { s.autoFlagEnabled = v == "true" }
        if let v = d["abuseFilterEnabled"] { s.abuseFilterEnabled = v == "true" }
        if let v = d["communityEnabled"] { s.communityEnabled = v == "true" }
        if let v = d["homePreviewEnabled"] { s.homePreviewEnabled = v == "true" }
        if let v = d["nearMeEnabled"] { s.nearMeEnabled = v == "true" }
        if let v = d["offerFlowEnabled"] { s.offerFlowEnabled = v == "true" }
        if let v = d["mapModeEnabled"] { s.mapModeEnabled = v == "true" }
        if let v = d["experimentalOnboarding"] { s.experimentalOnboarding = v == "true" }
        return s
    }

    func saveSettings(_ settings: AdminSettings) async throws {
        let body: [String: String] = [
            "maintenanceMode": String(settings.maintenanceMode),
            "onboardingEnabled": String(settings.onboardingEnabled),
            "pushEnabled": String(settings.pushEnabled),
            "emailEnabled": String(settings.emailEnabled),
            "smsEnabled": String(settings.smsEnabled),
            "inAppEnabled": String(settings.inAppEnabled),
            "mapEnabled": String(settings.mapEnabled),
            "autoFlagEnabled": String(settings.autoFlagEnabled),
            "abuseFilterEnabled": String(settings.abuseFilterEnabled),
            "communityEnabled": String(settings.communityEnabled),
            "homePreviewEnabled": String(settings.homePreviewEnabled),
            "nearMeEnabled": String(settings.nearMeEnabled),
            "offerFlowEnabled": String(settings.offerFlowEnabled),
            "mapModeEnabled": String(settings.mapModeEnabled),
            "experimentalOnboarding": String(settings.experimentalOnboarding),
        ]
        try await client.requestVoid(.PUT, path: "/admin/settings", body: body)
    }
}
