//
//  AdminInterviewService.swift
//  Plagit
//

import Foundation

struct AdminInterview: Identifiable {
    let id: UUID
    let candidateName: String
    let candidateInitials: String
    let business: String
    let businessInitials: String
    let isVerifiedBusiness: Bool
    let jobTitle: String
    let date: String
    let time: String
    let timezone: String
    let interviewType: String
    var status: String
    let location: String
    let meetingLink: String
    let createdDate: String
    let lastUpdate: String
    let rescheduleCount: Int
    let daysPending: Int
    let flagCount: Int
    let avatarHue: Double

    init(id: UUID = UUID(), candidateName: String, candidateInitials: String, business: String, businessInitials: String, isVerifiedBusiness: Bool, jobTitle: String, date: String, time: String, timezone: String, interviewType: String, status: String, location: String, meetingLink: String, createdDate: String, lastUpdate: String, rescheduleCount: Int, daysPending: Int, flagCount: Int, avatarHue: Double) {
        self.id = id; self.candidateName = candidateName; self.candidateInitials = candidateInitials; self.business = business; self.businessInitials = businessInitials; self.isVerifiedBusiness = isVerifiedBusiness; self.jobTitle = jobTitle; self.date = date; self.time = time; self.timezone = timezone; self.interviewType = interviewType; self.status = status; self.location = location; self.meetingLink = meetingLink; self.createdDate = createdDate; self.lastUpdate = lastUpdate; self.rescheduleCount = rescheduleCount; self.daysPending = daysPending; self.flagCount = flagCount; self.avatarHue = avatarHue
    }

    static let sampleData: [AdminInterview] = [
        .init(candidateName: "Elena Rossi", candidateInitials: "ER", business: "Nobu Restaurant", businessInitials: "NR", isVerifiedBusiness: true, jobTitle: "Senior Chef", date: "Wed, Mar 26", time: "3:00 PM", timezone: "GST", interviewType: "Video Call", status: "Confirmed", location: "—", meetingLink: "https://zoom.us/j/98234567", createdDate: "Mar 22", lastUpdate: "Confirmed Mar 24", rescheduleCount: 0, daysPending: 0, flagCount: 0, avatarHue: 0.52),
        .init(candidateName: "James Park", candidateInitials: "JP", business: "The Ritz London", businessInitials: "TR", isVerifiedBusiness: true, jobTitle: "Bar Manager", date: "Thu, Mar 27", time: "10:00 AM", timezone: "GMT", interviewType: "In Person", status: "Pending", location: "The Ritz, 150 Piccadilly, London", meetingLink: "—", createdDate: "Mar 21", lastUpdate: "Awaiting confirmation", rescheduleCount: 0, daysPending: 6, flagCount: 0, avatarHue: 0.38),
        .init(candidateName: "Anna Weber", candidateInitials: "AW", business: "Nobu Restaurant", businessInitials: "NR", isVerifiedBusiness: true, jobTitle: "Sous Chef", date: "Wed, Mar 26", time: "11:00 AM", timezone: "GST", interviewType: "Video Call", status: "Confirmed", location: "—", meetingLink: "https://zoom.us/j/123456789", createdDate: "Mar 23", lastUpdate: "Confirmed Mar 25", rescheduleCount: 0, daysPending: 0, flagCount: 0, avatarHue: 0.58),
        .init(candidateName: "Sofia Blanc", candidateInitials: "SB", business: "Four Seasons", businessInitials: "FS", isVerifiedBusiness: true, jobTitle: "Sommelier", date: "Fri, Mar 28", time: "2:00 PM", timezone: "CET", interviewType: "In Person", status: "Pending", location: "Four Seasons Hotel George V, Paris", meetingLink: "—", createdDate: "Mar 24", lastUpdate: "Pending since Mar 24", rescheduleCount: 0, daysPending: 3, flagCount: 0, avatarHue: 0.62),
        .init(candidateName: "Marco Bianchi", candidateInitials: "MB", business: "Chiltern Firehouse", businessInitials: "CF", isVerifiedBusiness: true, jobTitle: "Sous Chef", date: "Sat, Mar 29", time: "4:00 PM", timezone: "GMT", interviewType: "Phone", status: "Rescheduled", location: "—", meetingLink: "—", createdDate: "Mar 20", lastUpdate: "Rescheduled Mar 25", rescheduleCount: 2, daysPending: 0, flagCount: 0, avatarHue: 0.45),
        .init(candidateName: "Tom Chen", candidateInitials: "TC", business: "Dishoom Soho", businessInitials: "DS", isVerifiedBusiness: false, jobTitle: "Line Cook", date: "Mon, Mar 24", time: "9:00 AM", timezone: "GMT", interviewType: "Video Call", status: "Completed", location: "—", meetingLink: "https://meet.google.com/abc-defg", createdDate: "Mar 18", lastUpdate: "Completed Mar 24", rescheduleCount: 0, daysPending: 0, flagCount: 0, avatarHue: 0.35),
        .init(candidateName: "Priya Sharma", candidateInitials: "PS", business: "Fabric London", businessInitials: "FB", isVerifiedBusiness: false, jobTitle: "Waitstaff", date: "Tue, Mar 25", time: "1:00 PM", timezone: "GMT", interviewType: "In Person", status: "Cancelled", location: "Fabric London, 77a Charterhouse St", meetingLink: "—", createdDate: "Mar 19", lastUpdate: "Cancelled by business", rescheduleCount: 0, daysPending: 0, flagCount: 0, avatarHue: 0.42),
        .init(candidateName: "Sara Kim", candidateInitials: "SK", business: "Sky Lounge", businessInitials: "SL", isVerifiedBusiness: false, jobTitle: "Host / Hostess", date: "Wed, Mar 26", time: "5:00 PM", timezone: "GST", interviewType: "Video Call", status: "Flagged", location: "—", meetingLink: "—", createdDate: "Mar 22", lastUpdate: "Missing meeting link", rescheduleCount: 0, daysPending: 4, flagCount: 1, avatarHue: 0.40),
    ]
}

protocol AdminInterviewServiceProtocol: Sendable {
    func fetchInterviews() async throws -> [AdminInterview]
    func updateStatus(id: UUID, status: String) async throws
}

final class MockAdminInterviewService: AdminInterviewServiceProtocol, @unchecked Sendable {
    private var interviews: [AdminInterview] = AdminInterview.sampleData
    func fetchInterviews() async throws -> [AdminInterview] { try await Task.sleep(for: .milliseconds(300)); return interviews }
    func updateStatus(id: UUID, status: String) async throws {
        try await Task.sleep(for: .milliseconds(200))
        guard let i = interviews.firstIndex(where: { $0.id == id }) else { throw AdminInterviewServiceError.notFound }
        interviews[i].status = status
    }
}

enum AdminInterviewServiceError: LocalizedError {
    case notFound; case networkError(String)
    var errorDescription: String? { switch self { case .notFound: return "Interview not found."; case .networkError(let m): return m } }
}
