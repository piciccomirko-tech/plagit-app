//
//  AdminReportsViewModel.swift
//  Plagit
//

import SwiftUI

@Observable
final class AdminReportsViewModel {
    private let service: any AdminReportServiceProtocol
    var reports: [AdminReport] = []
    var loadingState: LoadingState = .idle
    var selectedFilter = "All"
    var selectedSort = "Newest"
    var searchText = ""

    let filters = ["All", "Open", "Urgent", "Under Review", "Resolved", "Dismissed", "Users", "Jobs", "Messages", "Repeat Offender"]
    let sortOptions = ["Newest", "Oldest", "Severity High", "Unresolved Longest", "Repeat Offender", "Assigned", "Unassigned", "A–Z"]

    init(service: any AdminReportServiceProtocol = AdminReportsAPIService()) { self.service = service }

    func sevOrder(_ s: String) -> Int { switch s { case "Urgent": return 0; case "High": return 1; case "Medium": return 2; default: return 3 } }

    var filtered: [AdminReport] {
        var result = reports
        switch selectedFilter {
        case "Open": result = result.filter { $0.status == "Open" }
        case "Urgent": result = result.filter { $0.severity == "Urgent" || $0.severity == "High" }
        case "Under Review": result = result.filter { $0.status == "Under Review" }
        case "Resolved": result = result.filter { $0.status == "Resolved" }
        case "Dismissed": result = result.filter { $0.status == "Dismissed" }
        case "Users": result = result.filter { $0.type == "User" }
        case "Jobs": result = result.filter { $0.type == "Job" }
        case "Messages": result = result.filter { $0.type == "Message" }
        case "Repeat Offender": result = result.filter { $0.previousReports >= 2 }
        default: break
        }
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            result = result.filter { $0.title.lowercased().contains(q) || $0.reportedEntity.lowercased().contains(q) || $0.reporter.lowercased().contains(q) || $0.reason.lowercased().contains(q) || $0.summary.lowercased().contains(q) }
        }
        switch selectedSort {
        case "Oldest": result.sort { $0.daysSinceSubmit > $1.daysSinceSubmit }
        case "Severity High": result.sort { sevOrder($0.severity) < sevOrder($1.severity) }
        case "Unresolved Longest": result.sort { $0.daysSinceSubmit > $1.daysSinceSubmit }
        case "Repeat Offender": result.sort { $0.previousReports > $1.previousReports }
        case "Assigned": result.sort { (!$0.assignedAdmin.isEmpty ? 0 : 1) < (!$1.assignedAdmin.isEmpty ? 0 : 1) }
        case "Unassigned": result.sort { ($0.assignedAdmin.isEmpty ? 0 : 1) < ($1.assignedAdmin.isEmpty ? 0 : 1) }
        case "A–Z": result.sort { $0.reportedEntity.localizedCaseInsensitiveCompare($1.reportedEntity) == .orderedAscending }
        default: result.sort { $0.daysSinceSubmit < $1.daysSinceSubmit }
        }
        return result
    }

    var urgentReports: [AdminReport] {
        reports.filter { ($0.severity == "Urgent" || $0.severity == "High") && $0.status == "Open" }
    }

    func countFor(_ f: String) -> Int {
        switch f {
        case "All": return reports.count
        case "Open": return reports.filter { $0.status == "Open" }.count
        case "Urgent": return reports.filter { $0.severity == "Urgent" || $0.severity == "High" }.count
        case "Under Review": return reports.filter { $0.status == "Under Review" }.count
        case "Resolved": return reports.filter { $0.status == "Resolved" }.count
        case "Dismissed": return reports.filter { $0.status == "Dismissed" }.count
        case "Users": return reports.filter { $0.type == "User" }.count
        case "Jobs": return reports.filter { $0.type == "Job" }.count
        case "Messages": return reports.filter { $0.type == "Message" }.count
        case "Repeat Offender": return reports.filter { $0.previousReports >= 2 }.count
        default: return 0
        }
    }

    @MainActor func loadReports() async {
        guard loadingState != .loading else { return }; loadingState = .loading
        do { reports = try await service.fetchReports(); loadingState = .loaded } catch { loadingState = .error(error.localizedDescription) }
    }

    @MainActor func updateStatus(id: UUID, status: String) {
        Task { do { try await service.updateStatus(id: id, status: status); if let i = reports.firstIndex(where: { $0.id == id }) { reports[i].status = status } } catch { } }
    }

    @MainActor func assignToMe(id: UUID) {
        let name = AdminAuthService.shared.currentUserName ?? "Admin"
        Task { do { try await service.assignAdmin(id: id, admin: name); if let i = reports.firstIndex(where: { $0.id == id }) { reports[i].assignedAdmin = name } } catch { } }
    }
}
