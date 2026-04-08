//
//  AdminBusinessesViewModel.swift
//  Plagit
//
//  ViewModel for AdminBusinessesView. Delegates to AdminBusinessServiceProtocol.
//

import SwiftUI

@Observable
final class AdminBusinessesViewModel {
    private let service: any AdminBusinessServiceProtocol

    var businesses: [AdminBiz] = []
    var loadingState: LoadingState = .idle
    var selectedFilter = "All"
    var selectedSort = "Newest"
    var searchText = ""

    let filters = ["All", "Verified", "Unverified", "Active Plan", "Trial", "Expired", "Suspended", "Flagged", "New", "No Applicants"]
    let sortOptions = ["Newest", "Oldest", "Last Active", "Most Jobs", "Most Applicants", "Flagged First", "Expiring Plans", "A–Z"]

    init(service: any AdminBusinessServiceProtocol = AdminBusinessesAPIService()) {
        self.service = service
    }

    // MARK: - Computed

    var filtered: [AdminBiz] {
        var result = businesses
        switch selectedFilter {
        case "Verified": result = result.filter(\.isVerified)
        case "Unverified": result = result.filter { !$0.isVerified }
        case "Active Plan": result = result.filter { $0.planStatus == "Active" }
        case "Trial": result = result.filter { $0.planStatus == "Trial" }
        case "Expired": result = result.filter { $0.planStatus == "Expired" || $0.planStatus == "Cancelled" }
        case "Suspended": result = result.filter { $0.status == "Suspended" || $0.status == "Banned" }
        case "Flagged": result = result.filter { $0.flagCount > 0 }
        case "New": result = result.filter { $0.joinedDate.contains("Mar 2026") }
        case "No Applicants": result = result.filter { $0.applicantsReceived < 5 }
        default: break
        }
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            result = result.filter {
                $0.name.lowercased().contains(q) ||
                $0.email.lowercased().contains(q) ||
                $0.contact.lowercased().contains(q) ||
                $0.venueType.lowercased().contains(q) ||
                $0.location.lowercased().contains(q)
            }
        }
        switch selectedSort {
        case "Oldest": result.sort { $0.joinedDate < $1.joinedDate }
        case "Most Jobs": result.sort { $0.activeJobs > $1.activeJobs }
        case "Most Applicants": result.sort { $0.applicantsReceived > $1.applicantsReceived }
        case "Flagged First": result.sort { $0.flagCount > $1.flagCount }
        case "A–Z": result.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        default: result.sort { $0.joinedDate > $1.joinedDate }
        }
        return result
    }

    func countFor(_ f: String) -> Int {
        switch f {
        case "All": return businesses.count
        case "Verified": return businesses.filter(\.isVerified).count
        case "Unverified": return businesses.filter { !$0.isVerified }.count
        case "Active Plan": return businesses.filter { $0.planStatus == "Active" }.count
        case "Trial": return businesses.filter { $0.planStatus == "Trial" }.count
        case "Expired": return businesses.filter { $0.planStatus == "Expired" || $0.planStatus == "Cancelled" }.count
        case "Suspended": return businesses.filter { $0.status == "Suspended" || $0.status == "Banned" }.count
        case "Flagged": return businesses.filter { $0.flagCount > 0 }.count
        case "New": return businesses.filter { $0.joinedDate.contains("Mar 2026") }.count
        case "No Applicants": return businesses.filter { $0.applicantsReceived < 5 }.count
        default: return 0
        }
    }

    func alertTitle(action: String, for id: UUID?) -> String {
        if let id, let biz = businesses.first(where: { $0.id == id }) {
            return "\(action) \(biz.name)?"
        }
        return "\(action) Business?"
    }

    // MARK: - Data Loading

    @MainActor
    func loadBusinesses() async {
        guard loadingState != .loading else { return }
        loadingState = .loading
        do {
            businesses = try await service.fetchBusinesses()
            loadingState = .loaded
        } catch {
            loadingState = .error(error.localizedDescription)
        }
    }

    // MARK: - Actions

    @MainActor
    func verifyBusiness(id: UUID) {
        Task {
            do {
                try await service.setVerified(id: id, verified: true)
                if let i = businesses.firstIndex(where: { $0.id == id }) { businesses[i].isVerified = true }
            } catch { }
        }
    }

    @MainActor
    func setFeatured(id: UUID, featured: Bool) {
        Task {
            do {
                try await service.setFeatured(id: id, featured: featured)
                if let i = businesses.firstIndex(where: { $0.id == id }) { businesses[i].isFeatured = featured }
            } catch { }
        }
    }

    @MainActor
    func suspendBusiness(id: UUID) {
        Task {
            do {
                try await service.updateStatus(id: id, status: "Suspended")
                if let i = businesses.firstIndex(where: { $0.id == id }) { businesses[i].status = "Suspended" }
            } catch { }
        }
    }

    @MainActor
    func activateBusiness(id: UUID) {
        Task {
            do {
                try await service.updateStatus(id: id, status: "Active")
                if let i = businesses.firstIndex(where: { $0.id == id }) { businesses[i].status = "Active" }
            } catch { }
        }
    }

    @MainActor
    func banBusiness(id: UUID) {
        Task {
            do {
                try await service.updateStatus(id: id, status: "Banned")
                if let i = businesses.firstIndex(where: { $0.id == id }) { businesses[i].status = "Banned" }
            } catch { }
        }
    }

    @MainActor
    func unbanBusiness(id: UUID) {
        Task {
            do {
                try await service.updateStatus(id: id, status: "Active")
                if let i = businesses.firstIndex(where: { $0.id == id }) { businesses[i].status = "Active" }
            } catch { }
        }
    }

    @MainActor
    func deleteBusiness(id: UUID) {
        Task {
            do {
                try await service.deleteBusiness(id: id)
                businesses.removeAll { $0.id == id }
            } catch { }
        }
    }
}
