//
//  AdminLogService.swift
//  Plagit
//

import Foundation

struct AdminLog: Identifiable {
    let id: UUID
    let action: String
    let target: String
    let category: String
    let adminUser: String
    let timestamp: String
    let oldValue: String?
    let newValue: String?
    let result: String

    init(id: UUID = UUID(), action: String, target: String, category: String, adminUser: String, timestamp: String, oldValue: String? = nil, newValue: String? = nil, result: String) {
        self.id = id; self.action = action; self.target = target; self.category = category; self.adminUser = adminUser; self.timestamp = timestamp; self.oldValue = oldValue; self.newValue = newValue; self.result = result
    }

    static let sampleData: [AdminLog] = [
        .init(action: "Verified business", target: "The Ritz London", category: "Businesses", adminUser: "Admin Mirko", timestamp: "10 min ago", result: "Success"),
        .init(action: "Verified candidate", target: "Elena Rossi", category: "Users", adminUser: "Admin Mirko", timestamp: "25 min ago", result: "Success"),
        .init(action: "Resolved report", target: "Spam listing removed", category: "Reports", adminUser: "Admin Mirko", timestamp: "1h ago", result: "Success"),
        .init(action: "Approved job", target: "Senior Chef — Nobu", category: "Jobs", adminUser: "Admin Mirko", timestamp: "2h ago", result: "Success"),
        .init(action: "Suspended account", target: "Unknown User", category: "Moderation", adminUser: "Admin Mirko", timestamp: "3h ago", result: "Success"),
        .init(action: "Updated match threshold", target: "Search Settings", category: "Settings", adminUser: "Admin Mirko", timestamp: "4h ago", oldValue: "70%", newValue: "75%", result: "Success"),
        .init(action: "Published community post", target: "5 CV Tips", category: "Community", adminUser: "Admin Mirko", timestamp: "5h ago", result: "Success"),
        .init(action: "Cancelled subscription", target: "Sky Lounge", category: "Billing", adminUser: "Admin Mirko", timestamp: "6h ago", result: "Success"),
        .init(action: "Extended trial", target: "Dishoom Soho", category: "Billing", adminUser: "Admin Mirko", timestamp: "8h ago", oldValue: "7 days", newValue: "14 days", result: "Success"),
        .init(action: "Dismissed report", target: "Duplicate listing", category: "Reports", adminUser: "Admin Mirko", timestamp: "1d ago", result: "Success"),
        .init(action: "Featured employer", target: "Nobu Restaurant", category: "Businesses", adminUser: "Admin Mirko", timestamp: "1d ago", result: "Success"),
        .init(action: "Banned account", target: "Sky Lounge", category: "Moderation", adminUser: "Admin Mirko", timestamp: "2d ago", result: "Success"),
        .init(action: "Sent notification", target: "All Candidates", category: "Community", adminUser: "Admin Mirko", timestamp: "2d ago", result: "Success"),
        .init(action: "Reset password", target: "James Park", category: "Users", adminUser: "Admin Mirko", timestamp: "3d ago", result: "Success"),
        .init(action: "Updated billing plan", target: "Four Seasons", category: "Billing", adminUser: "Admin Mirko", timestamp: "3d ago", oldValue: "Premium", newValue: "Enterprise", result: "Success"),
    ]
}

protocol AdminLogServiceProtocol: Sendable {
    func fetchLogs() async throws -> [AdminLog]
}

final class MockAdminLogService: AdminLogServiceProtocol, @unchecked Sendable {
    func fetchLogs() async throws -> [AdminLog] { try await Task.sleep(for: .milliseconds(300)); return AdminLog.sampleData }
}

enum AdminLogServiceError: LocalizedError {
    case networkError(String)
    var errorDescription: String? { switch self { case .networkError(let m): return m } }
}
