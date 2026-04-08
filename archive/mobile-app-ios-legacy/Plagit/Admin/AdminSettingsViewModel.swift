//
//  AdminSettingsViewModel.swift
//  Plagit
//

import SwiftUI

@Observable
final class AdminSettingsViewModel {
    private let service: any AdminSettingsServiceProtocol
    var settings = AdminSettings()
    var loadingState: LoadingState = .idle

    init(service: any AdminSettingsServiceProtocol = AdminSettingsAPIService()) { self.service = service }

    @MainActor func loadSettings() async {
        guard loadingState != .loading else { return }; loadingState = .loading
        do { settings = try await service.fetchSettings(); loadingState = .loaded } catch { loadingState = .error(error.localizedDescription) }
    }

    @MainActor func saveSettings() {
        Task { do { try await service.saveSettings(settings) } catch { } }
    }
}
