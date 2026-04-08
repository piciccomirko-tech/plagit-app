//
//  AdminNotificationService.swift
//  Plagit
//

import Foundation

struct AdminNotification: Identifiable {
    let id: UUID
    let recipientName: String
    let recipientType: String
    let notificationType: String
    let title: String
    let linkedEntity: String
    let destinationRoute: String
    var deliveryState: String
    var isRead: Bool
    let createdDate: String
    let sentDate: String
    let retryCount: Int
    let avatarHue: Double

    init(id: UUID = UUID(), recipientName: String, recipientType: String, notificationType: String, title: String, linkedEntity: String, destinationRoute: String, deliveryState: String, isRead: Bool, createdDate: String, sentDate: String, retryCount: Int, avatarHue: Double) {
        self.id = id; self.recipientName = recipientName; self.recipientType = recipientType; self.notificationType = notificationType; self.title = title; self.linkedEntity = linkedEntity; self.destinationRoute = destinationRoute; self.deliveryState = deliveryState; self.isRead = isRead; self.createdDate = createdDate; self.sentDate = sentDate; self.retryCount = retryCount; self.avatarHue = avatarHue
    }

    static let sampleData: [AdminNotification] = [
        .init(recipientName: "Elena Rossi", recipientType: "Candidate", notificationType: "Push", title: "Interview Confirmed — Nobu Restaurant", linkedEntity: "Interview #1042", destinationRoute: "interview-detail", deliveryState: "Delivered", isRead: true, createdDate: "Mar 24", sentDate: "Mar 24, 3:02 PM", retryCount: 0, avatarHue: 0.52),
        .init(recipientName: "Nobu Restaurant", recipientType: "Business", notificationType: "Email", title: "New Application — Senior Chef", linkedEntity: "Application #2081", destinationRoute: "application-detail", deliveryState: "Delivered", isRead: true, createdDate: "Mar 22", sentDate: "Mar 22, 9:15 AM", retryCount: 0, avatarHue: 0.55),
        .init(recipientName: "James Park", recipientType: "Candidate", notificationType: "In-App", title: "Profile Verification Complete", linkedEntity: "Profile", destinationRoute: "profile", deliveryState: "Delivered", isRead: false, createdDate: "Mar 25", sentDate: "Mar 25, 11:00 AM", retryCount: 0, avatarHue: 0.38),
        .init(recipientName: "The Ritz London", recipientType: "Business", notificationType: "Push", title: "Job Expiring Soon — Bar Manager", linkedEntity: "Job #305", destinationRoute: "job-detail", deliveryState: "Failed", isRead: false, createdDate: "Mar 26", sentDate: "—", retryCount: 2, avatarHue: 0.68),
        .init(recipientName: "Sofia Blanc", recipientType: "Candidate", notificationType: "Email", title: "Welcome to Plagit", linkedEntity: "Onboarding", destinationRoute: "onboarding", deliveryState: "Delivered", isRead: true, createdDate: "Jan 15", sentDate: "Jan 15, 8:00 AM", retryCount: 0, avatarHue: 0.62),
        .init(recipientName: "Anna Weber", recipientType: "Candidate", notificationType: "SMS", title: "Interview Reminder — Tomorrow 11 AM", linkedEntity: "Interview #1043", destinationRoute: "interview-detail", deliveryState: "Pending", isRead: false, createdDate: "Mar 25", sentDate: "—", retryCount: 0, avatarHue: 0.58),
        .init(recipientName: "Dishoom Soho", recipientType: "Business", notificationType: "Email", title: "Subscription Renewal Reminder", linkedEntity: "Subscription #88", destinationRoute: "subscription", deliveryState: "Failed", isRead: false, createdDate: "Mar 20", sentDate: "—", retryCount: 3, avatarHue: 0.48),
        .init(recipientName: "Admin Mirko", recipientType: "System", notificationType: "In-App", title: "Report Resolved — Spam Listing", linkedEntity: "Report #401", destinationRoute: "report-detail", deliveryState: "Delivered", isRead: true, createdDate: "Mar 23", sentDate: "Mar 23, 2:30 PM", retryCount: 0, avatarHue: 0.50),
        .init(recipientName: "Tom Chen", recipientType: "Candidate", notificationType: "Push", title: "New Job Match — Line Cook", linkedEntity: "Job #310", destinationRoute: "job-detail", deliveryState: "Delivered", isRead: false, createdDate: "Mar 26", sentDate: "Mar 26, 7:00 AM", retryCount: 0, avatarHue: 0.35),
        .init(recipientName: "Fabric London", recipientType: "Business", notificationType: "Email", title: "Payment Failed — Please Update Card", linkedEntity: "Invoice #INV-2026-088", destinationRoute: "billing", deliveryState: "Failed", isRead: false, createdDate: "Mar 25", sentDate: "—", retryCount: 1, avatarHue: 0.35),
    ]
}

protocol AdminNotificationServiceProtocol: Sendable {
    func fetchNotifications() async throws -> [AdminNotification]
    func updateDeliveryState(id: UUID, state: String) async throws
    func markRead(id: UUID, read: Bool) async throws
}

final class MockAdminNotificationService: AdminNotificationServiceProtocol, @unchecked Sendable {
    private var notifs: [AdminNotification] = AdminNotification.sampleData
    func fetchNotifications() async throws -> [AdminNotification] { try await Task.sleep(for: .milliseconds(300)); return notifs }
    func updateDeliveryState(id: UUID, state: String) async throws {
        try await Task.sleep(for: .milliseconds(200))
        guard let i = notifs.firstIndex(where: { $0.id == id }) else { throw AdminNotificationServiceError.notFound }
        notifs[i].deliveryState = state
    }
    func markRead(id: UUID, read: Bool) async throws {
        try await Task.sleep(for: .milliseconds(200))
        guard let i = notifs.firstIndex(where: { $0.id == id }) else { throw AdminNotificationServiceError.notFound }
        notifs[i].isRead = read
    }
}

enum AdminNotificationServiceError: LocalizedError {
    case notFound; case networkError(String)
    var errorDescription: String? { switch self { case .notFound: return "Notification not found."; case .networkError(let m): return m } }
}
