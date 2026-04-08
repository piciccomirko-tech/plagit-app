//
//  AdminCandidatesAPIService.swift
//  Plagit
//

import Foundation

private struct APIWrapper<T: Decodable>: Decodable { let success: Bool; let data: T }

private struct CandidateDTO: Decodable {
    let id: String; let name: String; let initials: String?; let role: String?
    let location: String?; let experience: String?; let languages: String?
    let jobType: String?; let bio: String?
    let verificationStatus: String?; let avatarHue: Double?; let createdAt: String?

    func toModel() -> AdminCandidate {
        AdminCandidate(
            id: UUID(uuidString: id) ?? UUID(), name: name,
            initials: initials ?? String(name.prefix(2)).uppercased(),
            role: role ?? "", jobType: jobType ?? "", location: location ?? "",
            experience: experience ?? "", languages: languages ?? "",
            verificationStatus: (verificationStatus ?? "new").replacingOccurrences(of: "_", with: " ").capitalized,
            activeSince: formatDate(createdAt), avatarHue: avatarHue ?? 0.5
        )
    }
    private func formatDate(_ iso: String?) -> String {
        guard let iso else { return "—" }
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let d = f.date(from: iso) else { return iso }
        let out = DateFormatter(); out.dateFormat = "MMM yyyy"; return "Active since \(out.string(from: d))"
    }
}

private struct StatusReq: Encodable { let status: String }

final class AdminCandidatesAPIService: AdminCandidateServiceProtocol, @unchecked Sendable {
    private let client: APIClient
    init(client: APIClient = .shared) { self.client = client }

    func fetchCandidates() async throws -> [AdminCandidate] {
        let w: APIWrapper<[CandidateDTO]> = try await client.request(.GET, path: "/admin/candidates")
        return w.data.map { $0.toModel() }
    }
    func updateVerificationStatus(id: UUID, status: String) async throws {
        try await client.requestVoid(.PATCH, path: "/admin/candidates/\(id.uuidString)/verification", body: StatusReq(status: status.lowercased().replacingOccurrences(of: " ", with: "_")))
    }
}
