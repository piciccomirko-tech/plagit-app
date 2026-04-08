//
//  AdminInterviewsViewModel.swift
//  Plagit
//

import SwiftUI

@Observable
final class AdminInterviewsViewModel {
    private let service: any AdminInterviewServiceProtocol
    var interviews: [AdminInterview] = []
    var loadingState: LoadingState = .idle
    var selectedFilter = "All"
    var selectedSort = "Soonest"
    var searchText = ""
    var viewMode = "list"

    let filters = ["All", "Pending", "Confirmed", "Rescheduled", "Cancelled", "Completed", "Flagged", "Today", "This Week", "Missing Info"]
    let sortOptions = ["Soonest", "Latest Created", "Last Updated", "Pending First", "Cancelled First", "Flagged First", "Candidate A–Z", "Business A–Z"]

    init(service: any AdminInterviewServiceProtocol = AdminInterviewsAPIService()) { self.service = service }

    var filtered: [AdminInterview] {
        var result = interviews
        switch selectedFilter {
        case "Pending": result = result.filter { $0.status == "Pending" }
        case "Confirmed": result = result.filter { $0.status == "Confirmed" }
        case "Rescheduled": result = result.filter { $0.status == "Rescheduled" }
        case "Cancelled": result = result.filter { $0.status == "Cancelled" }
        case "Completed": result = result.filter { $0.status == "Completed" }
        case "Flagged": result = result.filter { $0.status == "Flagged" || $0.flagCount > 0 }
        case "Today": result = result.filter { $0.date.contains("Mar 26") || $0.date.contains("Mar 27") }
        case "This Week": result = result.filter { $0.date.contains("Mar 2") }
        case "Missing Info": result = result.filter { ($0.interviewType == "Video Call" && $0.meetingLink == "—") || ($0.interviewType == "In Person" && $0.location == "—") }
        default: break
        }
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            result = result.filter { $0.candidateName.lowercased().contains(q) || $0.business.lowercased().contains(q) || $0.jobTitle.lowercased().contains(q) || $0.location.lowercased().contains(q) }
        }
        switch selectedSort {
        case "Soonest": result.sort { $0.date < $1.date }
        case "Latest Created": result.sort { $0.createdDate > $1.createdDate }
        case "Pending First": result.sort { ($0.status == "Pending" ? 0 : 1) < ($1.status == "Pending" ? 0 : 1) }
        case "Cancelled First": result.sort { ($0.status == "Cancelled" ? 0 : 1) < ($1.status == "Cancelled" ? 0 : 1) }
        case "Flagged First": result.sort { $0.flagCount > $1.flagCount }
        case "Candidate A–Z": result.sort { $0.candidateName.localizedCaseInsensitiveCompare($1.candidateName) == .orderedAscending }
        case "Business A–Z": result.sort { $0.business.localizedCaseInsensitiveCompare($1.business) == .orderedAscending }
        default: break
        }
        return result
    }

    func countFor(_ f: String) -> Int {
        switch f {
        case "All": return interviews.count
        case "Today": return interviews.filter { $0.date.contains("Mar 26") || $0.date.contains("Mar 27") }.count
        case "This Week": return interviews.filter { $0.date.contains("Mar 2") }.count
        case "Missing Info": return interviews.filter { ($0.interviewType == "Video Call" && $0.meetingLink == "—") || ($0.interviewType == "In Person" && $0.location == "—") }.count
        case "Flagged": return interviews.filter { $0.status == "Flagged" || $0.flagCount > 0 }.count
        default: return interviews.filter { $0.status == f }.count
        }
    }

    @MainActor func loadInterviews() async {
        guard loadingState != .loading else { return }; loadingState = .loading
        do { interviews = try await service.fetchInterviews(); loadingState = .loaded } catch { loadingState = .error(error.localizedDescription) }
    }

    @MainActor func updateStatus(id: UUID, status: String) {
        Task { do { try await service.updateStatus(id: id, status: status); if let i = interviews.firstIndex(where: { $0.id == id }) { interviews[i].status = status } } catch { } }
    }
}
