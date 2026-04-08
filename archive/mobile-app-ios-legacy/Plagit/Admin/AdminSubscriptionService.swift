//
//  AdminSubscriptionService.swift
//  Plagit
//

import Foundation

struct AdminSubscription: Identifiable {
    let id: UUID
    let userType: String  // "candidate" or "business"
    let businessName: String
    let initials: String
    var plan: String
    var status: String
    let billingCycle: String
    var renewalDate: String
    let lastPayment: String
    let amount: String
    let trialEnd: String
    let trialDaysLeft: Int
    var autoRenew: Bool
    let invoiceCount: Int
    var paymentState: String
    let avatarHue: Double

    init(id: UUID = UUID(), userType: String = "business", businessName: String, initials: String, plan: String, status: String, billingCycle: String, renewalDate: String, lastPayment: String, amount: String, trialEnd: String, trialDaysLeft: Int, autoRenew: Bool, invoiceCount: Int, paymentState: String, avatarHue: Double) {
        self.id = id; self.userType = userType; self.businessName = businessName; self.initials = initials; self.plan = plan; self.status = status; self.billingCycle = billingCycle; self.renewalDate = renewalDate; self.lastPayment = lastPayment; self.amount = amount; self.trialEnd = trialEnd; self.trialDaysLeft = trialDaysLeft; self.autoRenew = autoRenew; self.invoiceCount = invoiceCount; self.paymentState = paymentState; self.avatarHue = avatarHue
    }

    static let sampleData: [AdminSubscription] = [
        .init(businessName: "Nobu Restaurant", initials: "NR", plan: "Premium", status: "Active", billingCycle: "Monthly", renewalDate: "Apr 15, 2026", lastPayment: "Mar 15", amount: "$299/mo", trialEnd: "—", trialDaysLeft: 0, autoRenew: true, invoiceCount: 14, paymentState: "Paid", avatarHue: 0.55),
        .init(businessName: "The Ritz London", initials: "TR", plan: "Enterprise", status: "Active", billingCycle: "Annual", renewalDate: "May 1, 2026", lastPayment: "May 1, 2025", amount: "$4,999/yr", trialEnd: "—", trialDaysLeft: 0, autoRenew: true, invoiceCount: 2, paymentState: "Paid", avatarHue: 0.68),
        .init(businessName: "Dishoom Soho", initials: "DS", plan: "Basic", status: "Trial", billingCycle: "Monthly", renewalDate: "Apr 10, 2026", lastPayment: "—", amount: "$99/mo", trialEnd: "Apr 10, 2026", trialDaysLeft: 14, autoRenew: true, invoiceCount: 0, paymentState: "Pending", avatarHue: 0.48),
        .init(businessName: "Four Seasons", initials: "FS", plan: "Enterprise", status: "Active", billingCycle: "Annual", renewalDate: "Jun 1, 2026", lastPayment: "Jun 1, 2025", amount: "$4,999/yr", trialEnd: "—", trialDaysLeft: 0, autoRenew: true, invoiceCount: 2, paymentState: "Paid", avatarHue: 0.52),
        .init(businessName: "Chiltern Firehouse", initials: "CF", plan: "Premium", status: "Expiring", billingCycle: "Monthly", renewalDate: "Mar 28, 2026", lastPayment: "Feb 28", amount: "$299/mo", trialEnd: "—", trialDaysLeft: 0, autoRenew: false, invoiceCount: 6, paymentState: "Paid", avatarHue: 0.15),
        .init(businessName: "Fabric London", initials: "FB", plan: "Basic", status: "Failed", billingCycle: "Monthly", renewalDate: "Mar 20, 2026", lastPayment: "Feb 20", amount: "$99/mo", trialEnd: "—", trialDaysLeft: 0, autoRenew: true, invoiceCount: 3, paymentState: "Failed", avatarHue: 0.35),
        .init(businessName: "Sky Lounge", initials: "SL", plan: "Premium", status: "Cancelled", billingCycle: "Monthly", renewalDate: "—", lastPayment: "Feb 15", amount: "$299/mo", trialEnd: "—", trialDaysLeft: 0, autoRenew: false, invoiceCount: 8, paymentState: "Refunded", avatarHue: 0.42),
        .init(businessName: "Sketch London", initials: "SK", plan: "Premium", status: "Grace", billingCycle: "Monthly", renewalDate: "Mar 25, 2026", lastPayment: "Feb 25", amount: "$299/mo", trialEnd: "—", trialDaysLeft: 0, autoRenew: true, invoiceCount: 5, paymentState: "Failed", avatarHue: 0.58),
        .init(businessName: "Hakkasan Mayfair", initials: "HM", plan: "Premium", status: "Active", billingCycle: "Monthly", renewalDate: "Apr 5, 2026", lastPayment: "Mar 5", amount: "$299/mo", trialEnd: "—", trialDaysLeft: 0, autoRenew: true, invoiceCount: 10, paymentState: "Paid", avatarHue: 0.22),
        .init(businessName: "The Ned", initials: "TN", plan: "Basic", status: "Comp", billingCycle: "—", renewalDate: "—", lastPayment: "—", amount: "Free", trialEnd: "—", trialDaysLeft: 0, autoRenew: false, invoiceCount: 0, paymentState: "Complimentary", avatarHue: 0.65),
    ]
}

protocol AdminSubscriptionServiceProtocol: Sendable {
    func fetchSubscriptions() async throws -> [AdminSubscription]
    func updateStatus(id: UUID, status: String) async throws
    func updatePlan(id: UUID, plan: String) async throws
    func cancelSubscription(id: UUID) async throws
}

final class MockAdminSubscriptionService: AdminSubscriptionServiceProtocol, @unchecked Sendable {
    private var subs: [AdminSubscription] = AdminSubscription.sampleData
    func fetchSubscriptions() async throws -> [AdminSubscription] { try await Task.sleep(for: .milliseconds(300)); return subs }
    func updateStatus(id: UUID, status: String) async throws {
        try await Task.sleep(for: .milliseconds(200))
        guard let i = subs.firstIndex(where: { $0.id == id }) else { throw AdminSubscriptionServiceError.notFound }
        subs[i].status = status
    }
    func updatePlan(id: UUID, plan: String) async throws {
        try await Task.sleep(for: .milliseconds(200))
        guard let i = subs.firstIndex(where: { $0.id == id }) else { throw AdminSubscriptionServiceError.notFound }
        subs[i].plan = plan
    }
    func cancelSubscription(id: UUID) async throws {
        try await Task.sleep(for: .milliseconds(200))
        guard let i = subs.firstIndex(where: { $0.id == id }) else { throw AdminSubscriptionServiceError.notFound }
        subs[i].status = "Cancelled"; subs[i].autoRenew = false
    }
}

enum AdminSubscriptionServiceError: LocalizedError {
    case notFound; case networkError(String)
    var errorDescription: String? { switch self { case .notFound: return "Subscription not found."; case .networkError(let m): return m } }
}
