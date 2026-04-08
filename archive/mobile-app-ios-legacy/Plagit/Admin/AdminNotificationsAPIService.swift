//
//  AdminNotificationsAPIService.swift
//  Plagit
//

import Foundation

private struct APIWrapper<T: Decodable>: Decodable { let success: Bool; let data: T }

private struct NotifDTO: Decodable {
    let id: String; let recipientName: String?; let recipientType: String?
    let notificationType: String; let title: String; let linkedEntity: String?
    let destinationRoute: String?; let deliveryState: String; let isRead: Bool
    let sentAt: String?; let retryCount: Int?; let avatarHue: Double?; let createdAt: String?

    func toModel() -> AdminNotification {
        AdminNotification(
            id: UUID(uuidString: id) ?? UUID(),
            recipientName: recipientName ?? "—",
            recipientType: (recipientType ?? "candidate").capitalized,
            notificationType: notificationType.replacingOccurrences(of: "_", with: "-").capitalized.replacingOccurrences(of: "-", with: "-"),
            title: title, linkedEntity: linkedEntity ?? "",
            destinationRoute: destinationRoute ?? "",
            deliveryState: deliveryState.capitalized,
            isRead: isRead, createdDate: fmtShort(createdAt),
            sentDate: sentAt != nil ? fmtFull(sentAt) : "—",
            retryCount: retryCount ?? 0, avatarHue: avatarHue ?? 0.5
        )
    }
    private func fmtShort(_ s: String?) -> String {
        guard let s else { return "—" }
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let d = f.date(from: s) else { return s }
        let o = DateFormatter(); o.dateFormat = "MMM d"; return o.string(from: d)
    }
    private func fmtFull(_ s: String?) -> String {
        guard let s else { return "—" }
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let d = f.date(from: s) else { return s }
        let o = DateFormatter(); o.dateFormat = "MMM d, h:mm a"; return o.string(from: d)
    }
}

private struct DeliveryReq: Encodable { let state: String }

final class AdminNotificationsAPIService: AdminNotificationServiceProtocol, @unchecked Sendable {
    private let client: APIClient
    init(client: APIClient = .shared) { self.client = client }

    func fetchNotifications() async throws -> [AdminNotification] {
        let w: APIWrapper<[NotifDTO]> = try await client.request(.GET, path: "/admin/notifications")
        return w.data.map { $0.toModel() }
    }
    func updateDeliveryState(id: UUID, state: String) async throws {
        try await client.requestVoid(.PATCH, path: "/admin/notifications/\(id.uuidString)/delivery", body: DeliveryReq(state: state.lowercased()))
    }
    func markRead(id: UUID, read: Bool) async throws {
        struct ReadReq: Encodable { let read: Bool }
        try await client.requestVoid(.PATCH, path: "/admin/notifications/\(id.uuidString)/read", body: ReadReq(read: read))
    }
}
