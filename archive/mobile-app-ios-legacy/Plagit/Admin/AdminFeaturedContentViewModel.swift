//
//  AdminFeaturedContentViewModel.swift
//  Plagit
//

import SwiftUI

@Observable
final class AdminFeaturedContentViewModel {
    private let service: any AdminFeaturedContentServiceProtocol
    var items: [AdminFeaturedItem] = []
    var loadingState: LoadingState = .idle
    var selectedFilter = "All"
    var selectedSort = "Priority"
    var searchText = ""

    let filters = ["All", "Active", "Scheduled", "Expired", "Draft", "Pinned", "Featured Employer", "Featured Job", "Home Banner", "Recommended", "Onboarding Card"]
    let sortOptions = ["Priority", "Newest", "Oldest", "Most Clicks", "Most Views", "Active First", "A–Z"]

    init(service: any AdminFeaturedContentServiceProtocol = AdminFeaturedContentAPIService()) { self.service = service }

    var filtered: [AdminFeaturedItem] {
        var result = items
        switch selectedFilter {
        case "Active", "Scheduled", "Expired", "Draft": result = result.filter { $0.status == selectedFilter }
        case "Pinned": result = result.filter(\.isPinned)
        case "All": break
        default: result = result.filter { $0.type.lowercased() == selectedFilter.lowercased() }
        }
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            result = result.filter { $0.title.lowercased().contains(q) || $0.linkedEntity.lowercased().contains(q) || $0.placement.lowercased().contains(q) || $0.type.lowercased().contains(q) }
        }
        switch selectedSort {
        case "Newest": result.sort { $0.startDate > $1.startDate }
        case "Oldest": result.sort { $0.startDate < $1.startDate }
        case "Most Clicks": result.sort { $0.clicks > $1.clicks }
        case "Most Views": result.sort { $0.views > $1.views }
        case "Active First": result.sort { ($0.status == "Active" ? 0 : 1) < ($1.status == "Active" ? 0 : 1) }
        case "A–Z": result.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        default: result.sort { $0.priority < $1.priority }
        }
        return result
    }

    func countFor(_ f: String) -> Int {
        switch f {
        case "All": return items.count
        case "Active", "Scheduled", "Expired", "Draft": return items.filter { $0.status == f }.count
        case "Pinned": return items.filter(\.isPinned).count
        default: return items.filter { $0.type.lowercased() == f.lowercased() }.count
        }
    }

    @MainActor func loadItems() async {
        guard loadingState != .loading else { return }; loadingState = .loading
        do { items = try await service.fetchItems(); loadingState = .loaded } catch { loadingState = .error(error.localizedDescription) }
    }

    @MainActor func updateStatus(id: UUID, status: String) { Task { do { try await service.updateStatus(id: id, status: status); if let i = items.firstIndex(where: { $0.id == id }) { items[i].status = status } } catch { } } }
    @MainActor func setPinned(id: UUID, pinned: Bool) { Task { do { try await service.setPinned(id: id, pinned: pinned); if let i = items.firstIndex(where: { $0.id == id }) { items[i].isPinned = pinned } } catch { } } }
    @MainActor func deleteItem(id: UUID) { Task { do { try await service.deleteItem(id: id); items.removeAll { $0.id == id } } catch { } } }
}
