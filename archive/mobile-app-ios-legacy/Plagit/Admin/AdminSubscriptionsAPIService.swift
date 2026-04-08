//
//  AdminSubscriptionsAPIService.swift
//  Plagit
//

import Foundation

private struct APIWrapper<T: Decodable>: Decodable { let success: Bool; let data: T }

private struct SubDTO: Decodable {
    let id: String; let userType: String?; let userName: String?; let userEmail: String?
    let userInitials: String?; let plan: String; let status: String; let billingCycle: String?
    let renewalDate: String?; let amount: Double?; let trialEnd: String?
    let autoRenew: Bool?; let paymentState: String?
    let avatarHue: Double?; let graceEnd: String?; let productId: String?; let createdAt: String?

    func toModel() -> AdminSubscription {
        AdminSubscription(
            id: UUID(uuidString: id) ?? UUID(),
            userType: userType ?? "business",
            businessName: userName ?? "—", initials: userInitials ?? "??",
            plan: plan.replacingOccurrences(of: "_", with: " ").capitalized,
            status: status.capitalized,
            billingCycle: (billingCycle ?? "monthly").capitalized,
            renewalDate: fmtDate(renewalDate), lastPayment: fmtShort(createdAt),
            amount: amount != nil ? "$\(Int(amount!))" : "—",
            trialEnd: fmtDate(trialEnd),
            trialDaysLeft: trialDays(trialEnd),
            autoRenew: autoRenew ?? true, invoiceCount: 0,
            paymentState: (paymentState ?? "paid").capitalized,
            avatarHue: avatarHue ?? 0.5
        )
    }
    private func fmtDate(_ s: String?) -> String {
        guard let s, s != "null" else { return "—" }
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        guard let d = f.date(from: s) else { return s }
        let o = DateFormatter(); o.dateFormat = "MMM d, yyyy"; return o.string(from: d)
    }
    private func fmtShort(_ s: String?) -> String {
        guard let s else { return "—" }
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let d = f.date(from: s) else { return s }
        let o = DateFormatter(); o.dateFormat = "MMM d"; return o.string(from: d)
    }
    private func trialDays(_ s: String?) -> Int {
        guard let s, s != "null" else { return 0 }
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        guard let d = f.date(from: s) else { return 0 }
        return max(0, Int(d.timeIntervalSince(Date()) / 86400))
    }
}

private struct StatusReq: Encodable { let status: String }

final class AdminSubscriptionsAPIService: AdminSubscriptionServiceProtocol, @unchecked Sendable {
    private let client: APIClient
    init(client: APIClient = .shared) { self.client = client }

    func fetchSubscriptions() async throws -> [AdminSubscription] {
        let w: APIWrapper<[SubDTO]> = try await client.request(.GET, path: "/admin/subscriptions")
        return w.data.map { $0.toModel() }
    }
    func updateStatus(id: UUID, status: String) async throws {
        try await client.requestVoid(.PATCH, path: "/admin/subscriptions/\(id.uuidString)/status", body: StatusReq(status: status.lowercased()))
    }
    func updatePlan(id: UUID, plan: String) async throws {
        struct PlanReq: Encodable { let plan: String }
        try await client.requestVoid(.PATCH, path: "/admin/subscriptions/\(id.uuidString)/plan", body: PlanReq(plan: plan.lowercased()))
    }
    func cancelSubscription(id: UUID) async throws {
        try await client.requestVoid(.POST, path: "/admin/subscriptions/\(id.uuidString)/cancel")
    }
}
