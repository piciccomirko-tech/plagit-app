//
//  AdminReportsAPIService.swift
//  Plagit
//

import Foundation

private struct APIWrapper<T: Decodable>: Decodable { let success: Bool; let data: T }

private struct ReportDTO: Decodable {
    let id: String; let title: String; let reportedEntity: String?; let reportedInitials: String?
    let type: String; let reason: String?; let severity: String; let status: String
    let reporter: String?; let assignedAdmin: String?; let previousReports: Int?
    let flagCount: Int?; let summary: String?; let avatarHue: Double?; let createdAt: String?

    func toModel() -> AdminReport {
        AdminReport(
            id: UUID(uuidString: id) ?? UUID(), title: title,
            reportedEntity: reportedEntity ?? "—", reportedInitials: reportedInitials ?? "??",
            type: type.capitalized, reason: (reason ?? "").capitalized,
            severity: severity.capitalized, status: status.replacingOccurrences(of: "_", with: " ").capitalized,
            reporter: reporter ?? "—", reportDate: fmtShort(createdAt),
            daysSinceSubmit: daysSince(createdAt), assignedAdmin: assignedAdmin ?? "",
            previousReports: previousReports ?? 0, flagCount: flagCount ?? 0,
            summary: summary ?? "", avatarHue: avatarHue ?? 0.5
        )
    }
    private func fmtShort(_ s: String?) -> String {
        guard let s else { return "—" }
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let d = f.date(from: s) else { return s }
        let o = DateFormatter(); o.dateFormat = "MMM d"; return o.string(from: d)
    }
    private func daysSince(_ s: String?) -> Int {
        guard let s else { return 0 }
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let d = f.date(from: s) else { return 0 }
        return max(0, Int(Date().timeIntervalSince(d) / 86400))
    }
}

private struct StatusReq: Encodable { let status: String }
private struct AssignReq: Encodable { let admin: String }

final class AdminReportsAPIService: AdminReportServiceProtocol, @unchecked Sendable {
    private let client: APIClient
    init(client: APIClient = .shared) { self.client = client }

    func fetchReports() async throws -> [AdminReport] {
        let w: APIWrapper<[ReportDTO]> = try await client.request(.GET, path: "/admin/reports")
        return w.data.map { $0.toModel() }
    }
    func updateStatus(id: UUID, status: String) async throws {
        try await client.requestVoid(.PATCH, path: "/admin/reports/\(id.uuidString)/status", body: StatusReq(status: status.lowercased().replacingOccurrences(of: " ", with: "_")))
    }
    func assignAdmin(id: UUID, admin: String) async throws {
        try await client.requestVoid(.PATCH, path: "/admin/reports/\(id.uuidString)/assign", body: AssignReq(admin: admin))
    }
}
