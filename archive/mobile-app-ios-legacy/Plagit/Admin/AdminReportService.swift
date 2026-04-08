//
//  AdminReportService.swift
//  Plagit
//

import Foundation

struct AdminReport: Identifiable {
    let id: UUID
    let title: String
    let reportedEntity: String
    let reportedInitials: String
    let type: String
    let reason: String
    let severity: String
    var status: String
    let reporter: String
    let reportDate: String
    let daysSinceSubmit: Int
    var assignedAdmin: String
    let previousReports: Int
    let flagCount: Int
    let summary: String
    let avatarHue: Double

    init(id: UUID = UUID(), title: String, reportedEntity: String, reportedInitials: String, type: String, reason: String, severity: String, status: String, reporter: String, reportDate: String, daysSinceSubmit: Int, assignedAdmin: String, previousReports: Int, flagCount: Int, summary: String, avatarHue: Double) {
        self.id = id; self.title = title; self.reportedEntity = reportedEntity; self.reportedInitials = reportedInitials; self.type = type; self.reason = reason; self.severity = severity; self.status = status; self.reporter = reporter; self.reportDate = reportDate; self.daysSinceSubmit = daysSinceSubmit; self.assignedAdmin = assignedAdmin; self.previousReports = previousReports; self.flagCount = flagCount; self.summary = summary; self.avatarHue = avatarHue
    }

    static let sampleData: [AdminReport] = [
        .init(title: "Fake Job Listing — Scam Salary", reportedEntity: "Sky Lounge", reportedInitials: "SL", type: "Job", reason: "Scam", severity: "Urgent", status: "Open", reporter: "Elena Rossi", reportDate: "Mar 24", daysSinceSubmit: 3, assignedAdmin: "Mirko", previousReports: 4, flagCount: 3, summary: "Candidate reported a job listing with a salary that seems too good to be true. Business has 4 prior reports.", avatarHue: 0.42),
        .init(title: "Harassment in Messages", reportedEntity: "Unknown User", reportedInitials: "UU", type: "Message", reason: "Harassment", severity: "Urgent", status: "Open", reporter: "Sara Kim", reportDate: "Mar 25", daysSinceSubmit: 2, assignedAdmin: "", previousReports: 2, flagCount: 2, summary: "Candidate reported receiving inappropriate messages from another user.", avatarHue: 0.30),
        .init(title: "Spam Job Batch — 12 Posts", reportedEntity: "Unknown Venue", reportedInitials: "UV", type: "Job", reason: "Spam", severity: "High", status: "Open", reporter: "System", reportDate: "Mar 23", daysSinceSubmit: 4, assignedAdmin: "", previousReports: 0, flagCount: 1, summary: "Auto-flagged: 12 near-identical job postings created in under 5 minutes.", avatarHue: 0.30),
        .init(title: "Suspicious Account Activity", reportedEntity: "Tom Chen", reportedInitials: "TC", type: "User", reason: "Fake", severity: "High", status: "Under Review", reporter: "System", reportDate: "Mar 22", daysSinceSubmit: 5, assignedAdmin: "Mirko", previousReports: 0, flagCount: 1, summary: "Multiple logins from different countries. Profile completeness dropped suddenly.", avatarHue: 0.35),
        .init(title: "Duplicate Business Profile", reportedEntity: "Dishoom Soho", reportedInitials: "DS", type: "Business", reason: "Misleading", severity: "Medium", status: "Under Review", reporter: "Priya Sharma", reportDate: "Mar 21", daysSinceSubmit: 6, assignedAdmin: "Mirko", previousReports: 0, flagCount: 1, summary: "Business appears twice with slightly different names. Could be test accounts.", avatarHue: 0.48),
        .init(title: "Misleading Business Description", reportedEntity: "Fabric London", reportedInitials: "FB", type: "Business", reason: "Misleading", severity: "Medium", status: "Open", reporter: "James Park", reportDate: "Mar 20", daysSinceSubmit: 7, assignedAdmin: "", previousReports: 1, flagCount: 1, summary: "Business describes itself as a 'Michelin-star restaurant' but is a nightclub.", avatarHue: 0.35),
        .init(title: "Interview No-Show Dispute", reportedEntity: "James Park", reportedInitials: "JP", type: "User", reason: "Abuse", severity: "Low", status: "Under Review", reporter: "The Ritz London", reportDate: "Mar 25", daysSinceSubmit: 2, assignedAdmin: "", previousReports: 0, flagCount: 0, summary: "Business claims candidate did not show up for confirmed interview.", avatarHue: 0.38),
        .init(title: "Abusive Community Comment", reportedEntity: "Sara Kim", reportedInitials: "SK", type: "Community", reason: "Abuse", severity: "Medium", status: "Open", reporter: "Sofia Blanc", reportDate: "Mar 24", daysSinceSubmit: 3, assignedAdmin: "", previousReports: 0, flagCount: 1, summary: "Offensive language in community post comment section.", avatarHue: 0.40),
        .init(title: "Profile Verification Dispute", reportedEntity: "Anna Weber", reportedInitials: "AW", type: "User", reason: "Fake", severity: "Low", status: "Resolved", reporter: "Self-report", reportDate: "Mar 18", daysSinceSubmit: 9, assignedAdmin: "Mirko", previousReports: 0, flagCount: 0, summary: "Candidate claims verification was incorrectly denied. Documents re-submitted.", avatarHue: 0.58),
        .init(title: "Payment Scam Attempt", reportedEntity: "Sky Lounge", reportedInitials: "SL", type: "Business", reason: "Scam", severity: "Urgent", status: "Resolved", reporter: "Multiple", reportDate: "Mar 15", daysSinceSubmit: 12, assignedAdmin: "Mirko", previousReports: 5, flagCount: 5, summary: "Business requesting upfront payments from candidates. Account banned.", avatarHue: 0.42),
    ]
}

protocol AdminReportServiceProtocol: Sendable {
    func fetchReports() async throws -> [AdminReport]
    func updateStatus(id: UUID, status: String) async throws
    func assignAdmin(id: UUID, admin: String) async throws
}

final class MockAdminReportService: AdminReportServiceProtocol, @unchecked Sendable {
    private var reports: [AdminReport] = AdminReport.sampleData
    func fetchReports() async throws -> [AdminReport] { try await Task.sleep(for: .milliseconds(300)); return reports }
    func updateStatus(id: UUID, status: String) async throws {
        try await Task.sleep(for: .milliseconds(200))
        guard let i = reports.firstIndex(where: { $0.id == id }) else { throw AdminReportServiceError.notFound }
        reports[i].status = status
    }
    func assignAdmin(id: UUID, admin: String) async throws {
        try await Task.sleep(for: .milliseconds(200))
        guard let i = reports.firstIndex(where: { $0.id == id }) else { throw AdminReportServiceError.notFound }
        reports[i].assignedAdmin = admin
    }
}

enum AdminReportServiceError: LocalizedError {
    case notFound; case networkError(String)
    var errorDescription: String? { switch self { case .notFound: return "Report not found."; case .networkError(let m): return m } }
}
