//
//  SuperAdminHomeViewModel.swift
//  Plagit
//

import SwiftUI

@Observable
final class SuperAdminHomeViewModel {
    private let service: any AdminDashboardServiceProtocol
    var stats = AdminDashboardStats()
    var attention: [AdminAttentionItem] = []
    var loadingState: LoadingState = .idle

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning,"
        case 12..<18: return "Good afternoon,"
        default: return "Good evening,"
        }
    }

    init(service: any AdminDashboardServiceProtocol = AdminDashboardAPIService()) { self.service = service }

    @MainActor func loadStats() async {
        guard loadingState != .loading else { return }; loadingState = .loading
        do {
            async let s = service.fetchStats()
            async let att = service.fetchAttention()
            stats = try await s
            attention = try await att
            loadingState = .loaded
        } catch { loadingState = .error(error.localizedDescription) }
    }
}
