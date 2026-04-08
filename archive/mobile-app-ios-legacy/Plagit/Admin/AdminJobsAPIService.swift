//
//  AdminJobsAPIService.swift
//  Plagit
//

import Foundation

private struct APIWrapper<T: Decodable>: Decodable { let success: Bool; let data: T }

private struct JobDTO: Decodable {
    let id: String; let title: String; let businessName: String?; let businessInitials: String?
    let location: String?; let employmentType: String?; let salary: String?; let category: String?
    let status: String; let isFeatured: Bool; let isVerifiedBusiness: Bool?
    let expiryDate: String?; let views: Int?; let flagCount: Int?; let avatarHue: Double?
    let createdAt: String?

    func toModel() -> AdminJob {
        AdminJob(
            id: UUID(uuidString: id) ?? UUID(), title: title,
            business: businessName ?? "—", businessInitials: businessInitials ?? "??",
            location: location ?? "", employmentType: employmentType ?? "",
            salary: salary ?? "—", category: category ?? "",
            status: status.replacingOccurrences(of: "_", with: " ").capitalized,
            isFeatured: isFeatured, isVerified: isVerifiedBusiness ?? false,
            postedDate: fmtShort(createdAt), expiryDate: fmtShort(expiryDate),
            views: views ?? 0, applicants: 0, shortlisted: 0, interviews: 0,
            flagCount: flagCount ?? 0, avatarHue: avatarHue ?? 0.5
        )
    }
    private func fmtShort(_ s: String?) -> String {
        guard let s else { return "—" }
        for fmt in ["yyyy-MM-dd'T'HH:mm:ss.SSSZ", "yyyy-MM-dd"] {
            let f = DateFormatter(); f.dateFormat = fmt; f.locale = Locale(identifier: "en_US_POSIX")
            if let d = f.date(from: s) { let o = DateFormatter(); o.dateFormat = "MMM d"; return o.string(from: d) }
        }
        return s
    }
}

private struct StatusReq: Encodable { let status: String }
private struct FeaturedReq: Encodable { let featured: Bool }

final class AdminJobsAPIService: AdminJobServiceProtocol, @unchecked Sendable {
    private let client: APIClient
    init(client: APIClient = .shared) { self.client = client }

    func fetchJobs() async throws -> [AdminJob] {
        let w: APIWrapper<[JobDTO]> = try await client.request(.GET, path: "/admin/jobs")
        return w.data.map { $0.toModel() }
    }
    func updateStatus(id: UUID, status: String) async throws {
        try await client.requestVoid(.PATCH, path: "/admin/jobs/\(id.uuidString)/status", body: StatusReq(status: status.lowercased().replacingOccurrences(of: " ", with: "_")))
    }
    func setFeatured(id: UUID, featured: Bool) async throws {
        try await client.requestVoid(.PATCH, path: "/admin/jobs/\(id.uuidString)/featured", body: FeaturedReq(featured: featured))
    }
    func deleteJob(id: UUID) async throws {
        try await client.requestVoid(.DELETE, path: "/admin/jobs/\(id.uuidString)")
    }
}
