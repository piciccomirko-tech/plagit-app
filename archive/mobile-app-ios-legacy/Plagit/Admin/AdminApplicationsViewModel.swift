//
//  AdminApplicationsViewModel.swift
//  Plagit
//
//  ViewModel for AdminApplicationsView. Delegates to AdminApplicationServiceProtocol.
//

import SwiftUI

@Observable
final class AdminApplicationsViewModel {
    private let service: any AdminApplicationServiceProtocol

    var applications: [AdminApplication] = []
    var loadingState: LoadingState = .idle
    var selectedFilter = "All"
    var selectedSort = "Newest"
    var searchText = ""

    let filters = ["All", "Applied", "Under Review", "Shortlisted", "Interview", "Offer", "Rejected", "Withdrawn", "Flagged", "Stale"]
    let sortOptions = ["Newest", "Oldest", "Last Updated", "Interview First", "Offer First", "Flagged First", "Stale First", "Candidate A–Z", "Business A–Z"]

    init(service: any AdminApplicationServiceProtocol = AdminApplicationsAPIService()) {
        self.service = service
    }

    // MARK: - Computed

    var filtered: [AdminApplication] {
        var result = applications
        switch selectedFilter {
        case "Stale": result = result.filter { $0.daysSinceUpdate >= 7 }
        case "All": break
        default: result = result.filter { $0.status == selectedFilter }
        }
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            result = result.filter {
                $0.candidateName.lowercased().contains(q) ||
                $0.business.lowercased().contains(q) ||
                $0.jobTitle.lowercased().contains(q) ||
                $0.candidateRole.lowercased().contains(q) ||
                $0.location.lowercased().contains(q)
            }
        }
        switch selectedSort {
        case "Oldest": result.sort { $0.appliedDate < $1.appliedDate }
        case "Last Updated": result.sort { $0.daysSinceUpdate < $1.daysSinceUpdate }
        case "Interview First": result.sort { ($0.hasInterview ? 0 : 1) < ($1.hasInterview ? 0 : 1) }
        case "Offer First": result.sort { ($0.hasOffer ? 0 : 1) < ($1.hasOffer ? 0 : 1) }
        case "Flagged First": result.sort { $0.flagCount > $1.flagCount }
        case "Stale First": result.sort { $0.daysSinceUpdate > $1.daysSinceUpdate }
        case "Candidate A–Z": result.sort { $0.candidateName.localizedCaseInsensitiveCompare($1.candidateName) == .orderedAscending }
        case "Business A–Z": result.sort { $0.business.localizedCaseInsensitiveCompare($1.business) == .orderedAscending }
        default: result.sort { $0.appliedDate > $1.appliedDate }
        }
        return result
    }

    func countFor(_ f: String) -> Int {
        switch f {
        case "All": return applications.count
        case "Stale": return applications.filter { $0.daysSinceUpdate >= 7 }.count
        default: return applications.filter { $0.status == f }.count
        }
    }

    // MARK: - Data Loading

    @MainActor
    func loadApplications() async {
        guard loadingState != .loading else { return }
        loadingState = .loading
        do {
            applications = try await service.fetchApplications()
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
                if let i = applications.firstIndex(where: { $0.id == id }) { applications[i].status = status }
            } catch { }
        }
    }
}
