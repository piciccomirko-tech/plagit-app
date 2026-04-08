//
//  AdminCandidatesViewModel.swift
//  Plagit
//
//  ViewModel for AdminCandidatesView. Delegates to AdminCandidateServiceProtocol.
//

import SwiftUI

@Observable
final class AdminCandidatesViewModel {
    private let service: any AdminCandidateServiceProtocol

    var candidates: [AdminCandidate] = []
    var loadingState: LoadingState = .idle
    var selectedFilter = "All"
    var searchText = ""

    let filters = ["All", "Verified", "Pending Review", "Suspended", "New"]

    init(service: any AdminCandidateServiceProtocol = AdminCandidatesAPIService()) {
        self.service = service
    }

    // MARK: - Computed

    var filteredCandidates: [AdminCandidate] {
        var result = candidates
        if selectedFilter != "All" {
            result = result.filter { $0.verificationStatus == selectedFilter }
        }
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.name.lowercased().contains(query) ||
                $0.role.lowercased().contains(query) ||
                $0.location.lowercased().contains(query)
            }
        }
        return result.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func countFor(_ filter: String) -> Int {
        if filter == "All" { return candidates.count }
        return candidates.filter { $0.verificationStatus == filter }.count
    }

    func alertTitle(action: String, for id: UUID?) -> String {
        if let id, let c = candidates.first(where: { $0.id == id }) {
            return "\(action) \(c.name)?"
        }
        return "\(action) Candidate?"
    }

    // MARK: - Data Loading

    @MainActor
    func loadCandidates() async {
        guard loadingState != .loading else { return }
        loadingState = .loading
        do {
            candidates = try await service.fetchCandidates()
            loadingState = .loaded
        } catch {
            loadingState = .error(error.localizedDescription)
        }
    }

    // MARK: - Actions

    @MainActor
    func verifyCandidate(id: UUID) {
        Task {
            do {
                try await service.updateVerificationStatus(id: id, status: "Verified")
                if let i = candidates.firstIndex(where: { $0.id == id }) {
                    candidates[i].verificationStatus = "Verified"
                }
            } catch { }
        }
    }

    @MainActor
    func suspendCandidate(id: UUID) {
        Task {
            do {
                try await service.updateVerificationStatus(id: id, status: "Suspended")
                if let i = candidates.firstIndex(where: { $0.id == id }) {
                    candidates[i].verificationStatus = "Suspended"
                }
            } catch { }
        }
    }
}
