//
//  AdminLogsAPIService.swift
//  Plagit
//

import Foundation

private struct APIWrapper<T: Decodable>: Decodable { let success: Bool; let data: T }

private struct LogDTO: Decodable {
    let id: String; let action: String; let target: String?; let category: String?
    let adminUser: String?; let oldValue: String?; let newValue: String?
    let result: String?; let createdAt: String?

    func toModel() -> AdminLog {
        AdminLog(
            id: UUID(uuidString: id) ?? UUID(), action: action,
            target: target ?? "", category: category ?? "",
            adminUser: adminUser ?? "System", timestamp: fmtRelative(createdAt),
            oldValue: oldValue, newValue: newValue, result: result ?? "Success"
        )
    }
    private func fmtRelative(_ s: String?) -> String {
        guard let s else { return "—" }
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let d = f.date(from: s) else { return s }
        let secs = Date().timeIntervalSince(d)
        if secs < 60 { return "\(Int(secs))s ago" }; if secs < 3600 { return "\(Int(secs/60)) min ago" }
        if secs < 86400 { return "\(Int(secs/3600))h ago" }; return "\(Int(secs/86400))d ago"
    }
}

final class AdminLogsAPIService: AdminLogServiceProtocol, @unchecked Sendable {
    private let client: APIClient
    init(client: APIClient = .shared) { self.client = client }

    func fetchLogs() async throws -> [AdminLog] {
        let w: APIWrapper<[LogDTO]> = try await client.request(.GET, path: "/admin/logs")
        return w.data.map { $0.toModel() }
    }
}
