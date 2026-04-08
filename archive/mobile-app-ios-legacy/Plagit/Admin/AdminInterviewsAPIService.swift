//
//  AdminInterviewsAPIService.swift
//  Plagit
//

import Foundation

private struct APIWrapper<T: Decodable>: Decodable { let success: Bool; let data: T }

private struct IVDTO: Decodable {
    let id: String; let candidateName: String?; let candidateInitials: String?
    let businessName: String?; let isVerifiedBusiness: Bool?; let jobTitle: String?
    let scheduledAt: String?; let timezone: String?; let interviewType: String?
    let status: String; let location: String?; let meetingLink: String?
    let rescheduleCount: Int?; let flagCount: Int?; let createdAt: String?; let updatedAt: String?

    func toModel() -> AdminInterview {
        let (dateStr, timeStr) = parseDateTime(scheduledAt)
        return AdminInterview(
            id: UUID(uuidString: id) ?? UUID(),
            candidateName: candidateName ?? "—", candidateInitials: candidateInitials ?? "??",
            business: businessName ?? "—", businessInitials: String((businessName ?? "??").prefix(2)).uppercased(),
            isVerifiedBusiness: isVerifiedBusiness ?? false, jobTitle: jobTitle ?? "—",
            date: dateStr, time: timeStr, timezone: timezone ?? "GMT",
            interviewType: (interviewType ?? "video_call").replacingOccurrences(of: "_", with: " ").capitalized,
            status: status.capitalized, location: location ?? "—", meetingLink: meetingLink ?? "—",
            createdDate: fmtShort(createdAt), lastUpdate: fmtShort(updatedAt),
            rescheduleCount: rescheduleCount ?? 0, daysPending: 0,
            flagCount: flagCount ?? 0, avatarHue: 0.5
        )
    }
    private func parseDateTime(_ iso: String?) -> (String, String) {
        guard let iso else { return ("—", "—") }
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let d = f.date(from: iso) else { return (iso, "—") }
        let df = DateFormatter(); df.dateFormat = "EEE, MMM d"
        let tf = DateFormatter(); tf.dateFormat = "h:mm a"
        return (df.string(from: d), tf.string(from: d))
    }
    private func fmtShort(_ s: String?) -> String {
        guard let s else { return "—" }
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let d = f.date(from: s) else { return s }
        let o = DateFormatter(); o.dateFormat = "MMM d"; return o.string(from: d)
    }
}

private struct StatusReq: Encodable { let status: String }

final class AdminInterviewsAPIService: AdminInterviewServiceProtocol, @unchecked Sendable {
    private let client: APIClient
    init(client: APIClient = .shared) { self.client = client }

    func fetchInterviews() async throws -> [AdminInterview] {
        let w: APIWrapper<[IVDTO]> = try await client.request(.GET, path: "/admin/interviews")
        return w.data.map { $0.toModel() }
    }
    func updateStatus(id: UUID, status: String) async throws {
        try await client.requestVoid(.PATCH, path: "/admin/interviews/\(id.uuidString)/status", body: StatusReq(status: status.lowercased()))
    }
}
