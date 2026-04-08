//
//  AdminMessageService.swift
//  Plagit
//

import Foundation

struct AdminConvo: Identifiable {
    let id: UUID
    let candidateName: String
    let candidateInitials: String
    let businessName: String
    let businessInitials: String
    let jobTitle: String
    let lastMessage: String
    let lastActivity: String
    var status: String
    let flagCount: Int
    let supportState: String
    let isInterviewRelated: Bool
    let noReplyDays: Int
    let avatarHue: Double

    init(id: UUID = UUID(), candidateName: String, candidateInitials: String, businessName: String, businessInitials: String, jobTitle: String, lastMessage: String, lastActivity: String, status: String, flagCount: Int, supportState: String, isInterviewRelated: Bool, noReplyDays: Int, avatarHue: Double) {
        self.id = id; self.candidateName = candidateName; self.candidateInitials = candidateInitials; self.businessName = businessName; self.businessInitials = businessInitials; self.jobTitle = jobTitle; self.lastMessage = lastMessage; self.lastActivity = lastActivity; self.status = status; self.flagCount = flagCount; self.supportState = supportState; self.isInterviewRelated = isInterviewRelated; self.noReplyDays = noReplyDays; self.avatarHue = avatarHue
    }

    static let sampleData: [AdminConvo] = [
        .init(candidateName: "Elena Rossi", candidateInitials: "ER", businessName: "Nobu Restaurant", businessInitials: "NR", jobTitle: "Senior Chef", lastMessage: "Thank you for considering me. I'm available for an interview anytime this week.", lastActivity: "5m ago", status: "Normal", flagCount: 0, supportState: "None", isInterviewRelated: true, noReplyDays: 0, avatarHue: 0.52),
        .init(candidateName: "Unknown User", candidateInitials: "UU", businessName: "Sky Lounge", businessInitials: "SL", jobTitle: "Host / Hostess", lastMessage: "Send me money first for uniform deposit before starting...", lastActivity: "4h ago", status: "Flagged", flagCount: 3, supportState: "Escalated", isInterviewRelated: false, noReplyDays: 0, avatarHue: 0.30),
        .init(candidateName: "Sara Kim", candidateInitials: "SK", businessName: "Fabric London", businessInitials: "FB", jobTitle: "Waitstaff", lastMessage: "This is completely inappropriate. I'm reporting this.", lastActivity: "1d ago", status: "Flagged", flagCount: 2, supportState: "Open", isInterviewRelated: false, noReplyDays: 0, avatarHue: 0.40),
        .init(candidateName: "James Park", candidateInitials: "JP", businessName: "The Ritz London", businessInitials: "TR", jobTitle: "Bar Manager", lastMessage: "Looking forward to the interview on Thursday.", lastActivity: "2h ago", status: "Normal", flagCount: 0, supportState: "None", isInterviewRelated: true, noReplyDays: 0, avatarHue: 0.38),
        .init(candidateName: "Tom Chen", candidateInitials: "TC", businessName: "Dishoom Soho", businessInitials: "DS", jobTitle: "Line Cook", lastMessage: "Hi, I applied last week. Any update?", lastActivity: "3d ago", status: "Normal", flagCount: 0, supportState: "None", isInterviewRelated: false, noReplyDays: 5, avatarHue: 0.35),
        .init(candidateName: "Sofia Blanc", candidateInitials: "SB", businessName: "Four Seasons", businessInitials: "FS", jobTitle: "Sommelier", lastMessage: "Thank you for the wonderful interview experience.", lastActivity: "1d ago", status: "Normal", flagCount: 0, supportState: "None", isInterviewRelated: true, noReplyDays: 0, avatarHue: 0.62),
        .init(candidateName: "Marco Bianchi", candidateInitials: "MB", businessName: "Chiltern Firehouse", businessInitials: "CF", jobTitle: "Sous Chef", lastMessage: "I haven't received the interview details yet.", lastActivity: "4d ago", status: "Under Review", flagCount: 1, supportState: "Open", isInterviewRelated: true, noReplyDays: 4, avatarHue: 0.45),
        .init(candidateName: "Priya Sharma", candidateInitials: "PS", businessName: "Sky Lounge", businessInitials: "SL", jobTitle: "Waitstaff", lastMessage: "Account restricted — conversation archived.", lastActivity: "1w ago", status: "Restricted", flagCount: 4, supportState: "Resolved", isInterviewRelated: false, noReplyDays: 0, avatarHue: 0.42),
    ]
}

protocol AdminMessageServiceProtocol: Sendable {
    func fetchConversations() async throws -> [AdminConvo]
    func updateStatus(id: UUID, status: String) async throws
    func deleteConversation(id: UUID) async throws
}

final class MockAdminMessageService: AdminMessageServiceProtocol, @unchecked Sendable {
    private var convos: [AdminConvo] = AdminConvo.sampleData
    func fetchConversations() async throws -> [AdminConvo] { try await Task.sleep(for: .milliseconds(300)); return convos }
    func updateStatus(id: UUID, status: String) async throws {
        try await Task.sleep(for: .milliseconds(200))
        guard let i = convos.firstIndex(where: { $0.id == id }) else { throw AdminMessageServiceError.notFound }
        convos[i].status = status
    }
    func deleteConversation(id: UUID) async throws {
        try await Task.sleep(for: .milliseconds(200))
        guard let i = convos.firstIndex(where: { $0.id == id }) else { throw AdminMessageServiceError.notFound }
        convos.remove(at: i)
    }
}

enum AdminMessageServiceError: LocalizedError {
    case notFound; case networkError(String)
    var errorDescription: String? { switch self { case .notFound: return "Conversation not found."; case .networkError(let m): return m } }
}
