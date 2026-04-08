//
//  AdminCommunityViewModel.swift
//  Plagit
//

import SwiftUI

@Observable
final class AdminCommunityViewModel {
    private let service: any AdminCommunityServiceProtocol
    var posts: [AdminContent] = []
    var loadingState: LoadingState = .idle
    var selectedFilter = "All"
    var selectedSort = "Newest"
    var searchText = ""

    let filters = ["All", "Published", "Draft", "Scheduled", "Archived", "Pinned", "Featured on Home", "Career Tips", "Training", "Featured Employers", "Success Stories", "Job Highlights"]
    let sortOptions = ["Newest", "Oldest", "Most Views", "Most Saves", "Featured First", "Pinned First", "A–Z"]

    init(service: any AdminCommunityServiceProtocol = AdminCommunityAPIService()) { self.service = service }

    var homePreviewPosts: [AdminContent] { posts.filter(\.isFeaturedOnHome) }

    var filtered: [AdminContent] {
        var result = posts
        switch selectedFilter {
        case "Published", "Draft", "Scheduled", "Archived": result = result.filter { $0.status == selectedFilter }
        case "Pinned": result = result.filter(\.isPinned)
        case "Featured on Home": result = result.filter(\.isFeaturedOnHome)
        case "All": break
        default: result = result.filter { $0.category.lowercased() == selectedFilter.lowercased() }
        }
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            result = result.filter { $0.title.lowercased().contains(q) || $0.author.lowercased().contains(q) || $0.category.lowercased().contains(q) || $0.linkedEmployer.lowercased().contains(q) || $0.summary.lowercased().contains(q) }
        }
        switch selectedSort {
        case "Oldest": result.sort { $0.createdDate < $1.createdDate }
        case "Most Views": result.sort { $0.views > $1.views }
        case "Most Saves": result.sort { $0.saves > $1.saves }
        case "Featured First": result.sort { ($0.isFeaturedOnHome ? 0 : 1) < ($1.isFeaturedOnHome ? 0 : 1) }
        case "Pinned First": result.sort { ($0.isPinned ? 0 : 1) < ($1.isPinned ? 0 : 1) }
        case "A–Z": result.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        default: result.sort { $0.createdDate > $1.createdDate }
        }
        return result
    }

    func countFor(_ f: String) -> Int {
        switch f {
        case "All": return posts.count
        case "Published", "Draft", "Scheduled", "Archived": return posts.filter { $0.status == f }.count
        case "Pinned": return posts.filter(\.isPinned).count
        case "Featured on Home": return posts.filter(\.isFeaturedOnHome).count
        default: return posts.filter { $0.category.lowercased() == f.lowercased() }.count
        }
    }

    @MainActor func loadPosts() async {
        guard loadingState != .loading else { return }; loadingState = .loading
        do { posts = try await service.fetchPosts(); loadingState = .loaded } catch { loadingState = .error(error.localizedDescription) }
    }

    @MainActor func updateStatus(id: UUID, status: String) { Task { do { try await service.updateStatus(id: id, status: status); if let i = posts.firstIndex(where: { $0.id == id }) { posts[i].status = status } } catch { } } }
    @MainActor func setPinned(id: UUID, pinned: Bool) { Task { do { try await service.setPinned(id: id, pinned: pinned); if let i = posts.firstIndex(where: { $0.id == id }) { posts[i].isPinned = pinned } } catch { } } }
    @MainActor func setFeaturedOnHome(id: UUID, featured: Bool) { Task { do { try await service.setFeaturedOnHome(id: id, featured: featured); if let i = posts.firstIndex(where: { $0.id == id }) { posts[i].isFeaturedOnHome = featured } } catch { } } }
    @MainActor func deletePost(id: UUID) { Task { do { try await service.deletePost(id: id); posts.removeAll { $0.id == id } } catch { } } }
}
