//
//  AdminMessagesViewModel.swift
//  Plagit
//

import SwiftUI

@Observable
final class AdminMessagesViewModel {
    private let service: any AdminMessageServiceProtocol
    var convos: [AdminConvo] = []
    var loadingState: LoadingState = .idle
    var selectedFilter = "All"
    var selectedSort = "Last Updated"
    var searchText = ""

    let filters = ["All", "Flagged", "Under Review", "Interview Related", "Support Issues", "Archived", "Restricted", "No Reply"]
    let sortOptions = ["Last Updated", "Newest Flagged", "Unresolved First", "Oldest Unresolved", "Candidate A–Z", "Business A–Z"]

    init(service: any AdminMessageServiceProtocol = AdminMessagesAPIService()) { self.service = service }

    var filtered: [AdminConvo] {
        var result = convos
        switch selectedFilter {
        case "Flagged": result = result.filter { $0.status == "Flagged" }
        case "Under Review": result = result.filter { $0.status == "Under Review" }
        case "Interview Related": result = result.filter(\.isInterviewRelated)
        case "Support Issues": result = result.filter { $0.supportState != "None" && $0.supportState != "Resolved" }
        case "Archived": result = result.filter { $0.status == "Archived" }
        case "Restricted": result = result.filter { $0.status == "Restricted" }
        case "No Reply": result = result.filter { $0.noReplyDays >= 3 }
        default: break
        }
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            result = result.filter { $0.candidateName.lowercased().contains(q) || $0.businessName.lowercased().contains(q) || $0.jobTitle.lowercased().contains(q) || $0.lastMessage.lowercased().contains(q) }
        }
        switch selectedSort {
        case "Newest Flagged": result.sort { $0.flagCount > $1.flagCount }
        case "Unresolved First": result.sort { ($0.supportState == "Open" || $0.supportState == "Escalated" ? 0 : 1) < ($1.supportState == "Open" || $1.supportState == "Escalated" ? 0 : 1) }
        case "Oldest Unresolved": result.sort { $0.noReplyDays > $1.noReplyDays }
        case "Candidate A–Z": result.sort { $0.candidateName.localizedCaseInsensitiveCompare($1.candidateName) == .orderedAscending }
        case "Business A–Z": result.sort { $0.businessName.localizedCaseInsensitiveCompare($1.businessName) == .orderedAscending }
        default: break
        }
        return result
    }

    func countFor(_ f: String) -> Int {
        switch f {
        case "All": return convos.count
        case "Flagged": return convos.filter { $0.status == "Flagged" }.count
        case "Under Review": return convos.filter { $0.status == "Under Review" }.count
        case "Interview Related": return convos.filter(\.isInterviewRelated).count
        case "Support Issues": return convos.filter { $0.supportState != "None" && $0.supportState != "Resolved" }.count
        case "Archived": return convos.filter { $0.status == "Archived" }.count
        case "Restricted": return convos.filter { $0.status == "Restricted" }.count
        case "No Reply": return convos.filter { $0.noReplyDays >= 3 }.count
        default: return 0
        }
    }

    @MainActor func loadConversations() async {
        guard loadingState != .loading else { return }; loadingState = .loading
        do { convos = try await service.fetchConversations(); loadingState = .loaded } catch { loadingState = .error(error.localizedDescription) }
    }

    @MainActor func updateStatus(id: UUID, status: String) {
        Task { do { try await service.updateStatus(id: id, status: status); if let i = convos.firstIndex(where: { $0.id == id }) { convos[i].status = status } } catch { } }
    }

    @MainActor func deleteConversation(id: UUID) {
        Task { do { try await service.deleteConversation(id: id); convos.removeAll { $0.id == id } } catch { } }
    }
}
