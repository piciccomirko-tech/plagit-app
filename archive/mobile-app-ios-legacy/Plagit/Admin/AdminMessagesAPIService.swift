//
//  AdminMessagesAPIService.swift
//  Plagit
//

import Foundation

private struct APIWrapper<T: Decodable>: Decodable { let success: Bool; let data: T }

private struct ConvoDTO: Decodable {
    let id: String; let candidateName: String?; let candidateInitials: String?
    let businessName: String?; let businessInitials: String?; let jobTitle: String?
    let lastMessage: String?; let status: String; let flagCount: Int?
    let supportState: String?; let isInterviewRelated: Bool; let noReplyDays: Int?
    let avatarHue: Double?; let updatedAt: String?

    func toModel() -> AdminConvo {
        AdminConvo(
            id: UUID(uuidString: id) ?? UUID(),
            candidateName: candidateName ?? "—", candidateInitials: candidateInitials ?? "??",
            businessName: businessName ?? "—", businessInitials: businessInitials ?? "??",
            jobTitle: jobTitle ?? "—", lastMessage: lastMessage ?? "",
            lastActivity: fmtRelative(updatedAt),
            status: status.replacingOccurrences(of: "_", with: " ").capitalized,
            flagCount: flagCount ?? 0,
            supportState: (supportState ?? "none").capitalized,
            isInterviewRelated: isInterviewRelated, noReplyDays: noReplyDays ?? 0,
            avatarHue: avatarHue ?? 0.5
        )
    }
    private func fmtRelative(_ s: String?) -> String {
        guard let s else { return "—" }
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let d = f.date(from: s) else { return s }
        let secs = Date().timeIntervalSince(d)
        if secs < 60 { return "Just now" }; if secs < 3600 { return "\(Int(secs/60))m ago" }
        if secs < 86400 { return "\(Int(secs/3600))h ago" }; return "\(Int(secs/86400))d ago"
    }
}

private struct StatusReq: Encodable { let status: String }

final class AdminMessagesAPIService: AdminMessageServiceProtocol, @unchecked Sendable {
    private let client: APIClient
    init(client: APIClient = .shared) { self.client = client }

    func fetchConversations() async throws -> [AdminConvo] {
        let w: APIWrapper<[ConvoDTO]> = try await client.request(.GET, path: "/admin/messages")
        return w.data.map { $0.toModel() }
    }
    func updateStatus(id: UUID, status: String) async throws {
        try await client.requestVoid(.PATCH, path: "/admin/messages/\(id.uuidString)/status", body: StatusReq(status: status.lowercased().replacingOccurrences(of: " ", with: "_")))
    }
    func deleteConversation(id: UUID) async throws {
        try await client.requestVoid(.DELETE, path: "/admin/messages/\(id.uuidString)")
    }
}
