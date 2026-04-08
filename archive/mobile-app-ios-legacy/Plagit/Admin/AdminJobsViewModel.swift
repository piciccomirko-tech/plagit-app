//
//  AdminJobsViewModel.swift
//  Plagit
//
//  ViewModel for AdminJobsView. Delegates to AdminJobServiceProtocol.
//

import SwiftUI

@Observable
final class AdminJobsViewModel {
    private let service: any AdminJobServiceProtocol

    var jobs: [AdminJob] = []
    var loadingState: LoadingState = .idle
    var selectedFilter = "All"
    var selectedSort = "Newest"
    var searchText = ""

    let filters = ["All", "Active", "Paused", "Closed", "Draft", "Featured", "Flagged", "Expiring Soon", "No Applicants", "Pending Review"]
    let sortOptions = ["Newest", "Oldest", "Most Views", "Most Applicants", "Expiring Soon", "No Applicants First", "Flagged First", "A–Z"]

    init(service: any AdminJobServiceProtocol = AdminJobsAPIService()) {
        self.service = service
    }

    // MARK: - Computed

    var filtered: [AdminJob] {
        var result = jobs
        switch selectedFilter {
        case "Active": result = result.filter { $0.status == "Active" }
        case "Paused": result = result.filter { $0.status == "Paused" }
        case "Closed": result = result.filter { $0.status == "Closed" }
        case "Draft": result = result.filter { $0.status == "Draft" }
        case "Featured": result = result.filter(\.isFeatured)
        case "Flagged": result = result.filter { $0.flagCount > 0 }
        case "Expiring Soon": result = result.filter { $0.expiryDate.contains("Mar") }
        case "No Applicants": result = result.filter { $0.applicants == 0 }
        case "Pending Review": result = result.filter { $0.status == "Pending Review" }
        default: break
        }
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            result = result.filter {
                $0.title.lowercased().contains(q) ||
                $0.business.lowercased().contains(q) ||
                $0.location.lowercased().contains(q) ||
                $0.category.lowercased().contains(q)
            }
        }
        switch selectedSort {
        case "Oldest": result.sort { $0.postedDate < $1.postedDate }
        case "Most Views": result.sort { $0.views > $1.views }
        case "Most Applicants": result.sort { $0.applicants > $1.applicants }
        case "Expiring Soon": result.sort { $0.expiryDate < $1.expiryDate }
        case "No Applicants First": result.sort { $0.applicants < $1.applicants }
        case "Flagged First": result.sort { $0.flagCount > $1.flagCount }
        case "A–Z": result.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        default: result.sort { $0.postedDate > $1.postedDate }
        }
        return result
    }

    func countFor(_ f: String) -> Int {
        switch f {
        case "All": return jobs.count
        case "Active": return jobs.filter { $0.status == "Active" }.count
        case "Paused": return jobs.filter { $0.status == "Paused" }.count
        case "Closed": return jobs.filter { $0.status == "Closed" }.count
        case "Draft": return jobs.filter { $0.status == "Draft" }.count
        case "Featured": return jobs.filter(\.isFeatured).count
        case "Flagged": return jobs.filter { $0.flagCount > 0 }.count
        case "Expiring Soon": return jobs.filter { $0.expiryDate.contains("Mar") }.count
        case "No Applicants": return jobs.filter { $0.applicants == 0 }.count
        case "Pending Review": return jobs.filter { $0.status == "Pending Review" }.count
        default: return 0
        }
    }

    func alertTitle(action: String, for id: UUID?) -> String {
        if let id, let job = jobs.first(where: { $0.id == id }) {
            return "\(action) \"\(job.title)\"?"
        }
        return "\(action) Job?"
    }

    // MARK: - Data Loading

    @MainActor
    func loadJobs() async {
        guard loadingState != .loading else { return }
        loadingState = .loading
        do {
            jobs = try await service.fetchJobs()
            loadingState = .loaded
        } catch {
            loadingState = .error(error.localizedDescription)
        }
    }

    // MARK: - Actions

    @MainActor
    func updateStatus(id: UUID, status: String) {
        Task {
            do {
                try await service.updateStatus(id: id, status: status)
                if let i = jobs.firstIndex(where: { $0.id == id }) { jobs[i].status = status }
            } catch { }
        }
    }

    @MainActor
    func setFeatured(id: UUID, featured: Bool) {
        Task {
            do {
                try await service.setFeatured(id: id, featured: featured)
                if let i = jobs.firstIndex(where: { $0.id == id }) { jobs[i].isFeatured = featured }
            } catch { }
        }
    }

    @MainActor
    func deleteJob(id: UUID) {
        Task {
            do {
                try await service.deleteJob(id: id)
                jobs.removeAll { $0.id == id }
            } catch { }
        }
    }
}
