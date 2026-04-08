//
//  AdminDashboardViewModel.swift
//  Plagit
//

import SwiftUI

@Observable
final class AdminDashboardViewModel {
    private let service: any AdminDashboardServiceProtocol
    var stats = AdminDashboardStats()
    var activity: [AdminActivityItem] = []
    var attention: [AdminAttentionItem] = []
    var loadingState: LoadingState = .idle
    var selectedRange = "7 Days"
    var showSearch = false
    var searchText = ""
    var livePulse = false

    let dateRanges = ["Today", "7 Days", "30 Days"]

    init(service: any AdminDashboardServiceProtocol = AdminDashboardAPIService()) { self.service = service }

    @MainActor func loadStats() async {
        guard loadingState != .loading else { return }; loadingState = .loading
        do {
            async let s = service.fetchStats()
            async let a = service.fetchActivity()
            async let att = service.fetchAttention()
            stats = try await s
            activity = try await a
            attention = try await att
            loadingState = .loaded; livePulse = true
        } catch { loadingState = .error(error.localizedDescription) }
    }
}
