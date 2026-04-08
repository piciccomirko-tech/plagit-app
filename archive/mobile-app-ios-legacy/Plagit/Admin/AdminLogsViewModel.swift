//
//  AdminLogsViewModel.swift
//  Plagit
//

import SwiftUI

@Observable
final class AdminLogsViewModel {
    private let service: any AdminLogServiceProtocol
    var logs: [AdminLog] = []
    var loadingState: LoadingState = .idle
    var selectedFilter = "All"
    var selectedSort = "Newest"
    var searchText = ""

    let filters = ["All", "Users", "Jobs", "Businesses", "Reports", "Moderation", "Billing", "Community", "Settings", "Today"]
    let sortOptions = ["Newest", "Oldest", "Critical First", "Admin A–Z", "Entity A–Z"]

    init(service: any AdminLogServiceProtocol = AdminLogsAPIService()) { self.service = service }

    var filtered: [AdminLog] {
        var result = logs
        switch selectedFilter {
        case "Today": result = result.filter { $0.timestamp.contains("min") || $0.timestamp.contains("h ago") }
        case "All": break
        default: result = result.filter { $0.category == selectedFilter }
        }
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            result = result.filter { $0.action.lowercased().contains(q) || $0.target.lowercased().contains(q) || $0.adminUser.lowercased().contains(q) || $0.category.lowercased().contains(q) }
        }
        switch selectedSort {
        case "Oldest": result.reverse()
        case "Admin A–Z": result.sort { $0.adminUser.localizedCaseInsensitiveCompare($1.adminUser) == .orderedAscending }
        case "Entity A–Z": result.sort { $0.target.localizedCaseInsensitiveCompare($1.target) == .orderedAscending }
        default: break
        }
        return result
    }

    func countFor(_ f: String) -> Int {
        switch f {
        case "All": return logs.count
        case "Today": return logs.filter { $0.timestamp.contains("min") || $0.timestamp.contains("h ago") }.count
        default: return logs.filter { $0.category == f }.count
        }
    }

    @MainActor func loadLogs() async {
        guard loadingState != .loading else { return }; loadingState = .loading
        do { logs = try await service.fetchLogs(); loadingState = .loaded } catch { loadingState = .error(error.localizedDescription) }
    }
}
