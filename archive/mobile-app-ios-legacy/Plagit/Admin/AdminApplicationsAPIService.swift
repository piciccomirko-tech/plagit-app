//
//  AdminApplicationsAPIService.swift
//  Plagit
//

import Foundation

private struct APIWrapper<T: Decodable>: Decodable { let success: Bool; let data: T }

private struct AppDTO: Decodable {
    let id: String; let candidateName: String?; let candidateInitials: String?
    let jobTitle: String?; let businessName: String?
    let status: String; let hasInterview: Bool; let hasOffer: Bool
    let flagCount: Int?; let daysSinceUpdate: Int?
    let createdAt: String?; let candidateId: String?; let jobId: String?

    func toModel() -> AdminApplication {
        AdminApplication(
            id: UUID(uuidString: id) ?? UUID(),
            candidateName: candidateName ?? "—", candidateInitials: candidateInitials ?? "??",
            candidateRole: "", jobTitle: jobTitle ?? "—",
            business: businessName ?? "—", businessInitials: String((businessName ?? "??").prefix(2)).uppercased(),
            location: "", status: status.replacingOccurrences(of: "_", with: " ").capitalized,
            appliedDate: fmtShort(createdAt), lastUpdate: "—",
            hasInterview: hasInterview, hasOffer: hasOffer,
            isVerifiedCandidate: false, isVerifiedBusiness: false,
            flagCount: flagCount ?? 0, daysSinceUpdate: daysSinceUpdate ?? 0, avatarHue: 0.5
        )
    }
    private func fmtShort(_ s: String?) -> String {
        guard let s else { return "—" }
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let d = f.date(from: s) else { return s }
        let o = DateFormatter(); o.dateFormat = "MMM d"; return o.string(from: d)
    }
}

private struct StatusReq: Encodable { let status: String }

final class AdminApplicationsAPIService: AdminApplicationServiceProtocol, @unchecked Sendable {
    private let client: APIClient
    init(client: APIClient = .shared) { self.client = client }

    func fetchApplications() async throws -> [AdminApplication] {
        let w: APIWrapper<[AppDTO]> = try await client.request(.GET, path: "/admin/applications")
        return w.data.map { $0.toModel() }
    }
    func updateStatus(id: UUID, status: String) async throws {
        try await client.requestVoid(.PATCH, path: "/admin/applications/\(id.uuidString)/status", body: StatusReq(status: status.lowercased().replacingOccurrences(of: " ", with: "_")))
    }
}
