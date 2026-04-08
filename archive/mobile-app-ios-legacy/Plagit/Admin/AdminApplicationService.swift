//
//  AdminApplicationService.swift
//  Plagit
//
//  Protocol-based service for admin application operations.
//  Swap MockAdminApplicationService for a real API implementation later.
//

import Foundation

// MARK: - Model

struct AdminApplication: Identifiable {
    let id: UUID
    let candidateName: String
    let candidateInitials: String
    let candidateRole: String
    let jobTitle: String
    let business: String
    let businessInitials: String
    let location: String
    var status: String         // Applied, Under Review, Shortlisted, Interview, Offer, Rejected, Withdrawn, Flagged
    let appliedDate: String
    let lastUpdate: String
    let hasInterview: Bool
    let hasOffer: Bool
    let isVerifiedCandidate: Bool
    let isVerifiedBusiness: Bool
    let flagCount: Int
    let daysSinceUpdate: Int
    let avatarHue: Double

    init(id: UUID = UUID(), candidateName: String, candidateInitials: String, candidateRole: String, jobTitle: String, business: String, businessInitials: String, location: String, status: String, appliedDate: String, lastUpdate: String, hasInterview: Bool, hasOffer: Bool, isVerifiedCandidate: Bool, isVerifiedBusiness: Bool, flagCount: Int, daysSinceUpdate: Int, avatarHue: Double) {
        self.id = id; self.candidateName = candidateName; self.candidateInitials = candidateInitials; self.candidateRole = candidateRole; self.jobTitle = jobTitle; self.business = business; self.businessInitials = businessInitials; self.location = location; self.status = status; self.appliedDate = appliedDate; self.lastUpdate = lastUpdate; self.hasInterview = hasInterview; self.hasOffer = hasOffer; self.isVerifiedCandidate = isVerifiedCandidate; self.isVerifiedBusiness = isVerifiedBusiness; self.flagCount = flagCount; self.daysSinceUpdate = daysSinceUpdate; self.avatarHue = avatarHue
    }

    static let sampleData: [AdminApplication] = [
        .init(candidateName: "Elena Rossi", candidateInitials: "ER", candidateRole: "Executive Chef", jobTitle: "Senior Chef", business: "Nobu Restaurant", businessInitials: "NR", location: "Dubai, UAE", status: "Interview", appliedDate: "Mar 22", lastUpdate: "Interview Mar 26", hasInterview: true, hasOffer: false, isVerifiedCandidate: true, isVerifiedBusiness: true, flagCount: 0, daysSinceUpdate: 1, avatarHue: 0.52),
        .init(candidateName: "James Park", candidateInitials: "JP", candidateRole: "Bar Manager", jobTitle: "Bar Manager", business: "The Ritz London", businessInitials: "TR", location: "London, UK", status: "Under Review", appliedDate: "Mar 21", lastUpdate: "Profile viewed 2h ago", hasInterview: false, hasOffer: false, isVerifiedCandidate: false, isVerifiedBusiness: true, flagCount: 0, daysSinceUpdate: 0, avatarHue: 0.38),
        .init(candidateName: "Sofia Blanc", candidateInitials: "SB", candidateRole: "Sommelier", jobTitle: "Sommelier", business: "Four Seasons", businessInitials: "FS", location: "Paris, FR", status: "Applied", appliedDate: "Mar 24", lastUpdate: "Awaiting response", hasInterview: false, hasOffer: false, isVerifiedCandidate: true, isVerifiedBusiness: true, flagCount: 0, daysSinceUpdate: 3, avatarHue: 0.62),
        .init(candidateName: "Marco Bianchi", candidateInitials: "MB", candidateRole: "Sous Chef", jobTitle: "Senior Chef", business: "Nobu Restaurant", businessInitials: "NR", location: "Dubai, UAE", status: "Shortlisted", appliedDate: "Mar 20", lastUpdate: "Shortlisted Mar 25", hasInterview: false, hasOffer: false, isVerifiedCandidate: true, isVerifiedBusiness: true, flagCount: 0, daysSinceUpdate: 2, avatarHue: 0.45),
        .init(candidateName: "Anna Weber", candidateInitials: "AW", candidateRole: "Restaurant Manager", jobTitle: "Restaurant Manager", business: "Chiltern Firehouse", businessInitials: "CF", location: "London, UK", status: "Offer", appliedDate: "Mar 18", lastUpdate: "Offer sent Mar 23", hasInterview: true, hasOffer: true, isVerifiedCandidate: true, isVerifiedBusiness: true, flagCount: 0, daysSinceUpdate: 4, avatarHue: 0.58),
        .init(candidateName: "Tom Chen", candidateInitials: "TC", candidateRole: "Line Cook", jobTitle: "Line Cook", business: "Dishoom Soho", businessInitials: "DS", location: "London, UK", status: "Rejected", appliedDate: "Mar 15", lastUpdate: "Rejected Mar 20", hasInterview: false, hasOffer: false, isVerifiedCandidate: false, isVerifiedBusiness: false, flagCount: 0, daysSinceUpdate: 7, avatarHue: 0.35),
        .init(candidateName: "Priya Sharma", candidateInitials: "PS", candidateRole: "Waitstaff", jobTitle: "Waitstaff", business: "Dishoom Soho", businessInitials: "DS", location: "London, UK", status: "Withdrawn", appliedDate: "Mar 19", lastUpdate: "Candidate withdrew Mar 24", hasInterview: false, hasOffer: false, isVerifiedCandidate: false, isVerifiedBusiness: false, flagCount: 0, daysSinceUpdate: 3, avatarHue: 0.42),
        .init(candidateName: "Unknown User", candidateInitials: "UU", candidateRole: "Unknown", jobTitle: "Host / Hostess", business: "Sky Lounge", businessInitials: "SL", location: "Dubai, UAE", status: "Flagged", appliedDate: "Mar 23", lastUpdate: "Duplicate detected", hasInterview: false, hasOffer: false, isVerifiedCandidate: false, isVerifiedBusiness: false, flagCount: 2, daysSinceUpdate: 4, avatarHue: 0.30),
        .init(candidateName: "Sara Kim", candidateInitials: "SK", candidateRole: "Waitstaff", jobTitle: "Waitstaff", business: "Fabric London", businessInitials: "FB", location: "London, UK", status: "Flagged", appliedDate: "Mar 22", lastUpdate: "12 apps in 1 hour", hasInterview: false, hasOffer: false, isVerifiedCandidate: false, isVerifiedBusiness: false, flagCount: 3, daysSinceUpdate: 5, avatarHue: 0.40),
        .init(candidateName: "David Okafor", candidateInitials: "DO", candidateRole: "Bartender", jobTitle: "Bartender", business: "Fabric London", businessInitials: "FB", location: "London, UK", status: "Applied", appliedDate: "Mar 10", lastUpdate: "No response from business", hasInterview: false, hasOffer: false, isVerifiedCandidate: false, isVerifiedBusiness: false, flagCount: 0, daysSinceUpdate: 17, avatarHue: 0.68),
    ]
}

// MARK: - Protocol

protocol AdminApplicationServiceProtocol: Sendable {
    func fetchApplications() async throws -> [AdminApplication]
    func updateStatus(id: UUID, status: String) async throws
}

// MARK: - Mock Implementation

final class MockAdminApplicationService: AdminApplicationServiceProtocol, @unchecked Sendable {
    private var applications: [AdminApplication] = AdminApplication.sampleData

    func fetchApplications() async throws -> [AdminApplication] {
        try await Task.sleep(for: .milliseconds(300))
        return applications
    }

    func updateStatus(id: UUID, status: String) async throws {
        try await Task.sleep(for: .milliseconds(200))
        guard let i = applications.firstIndex(where: { $0.id == id }) else {
            throw AdminApplicationServiceError.notFound
        }
        applications[i].status = status
    }
}

// MARK: - Errors

enum AdminApplicationServiceError: LocalizedError {
    case notFound
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .notFound: return "Application not found."
        case .networkError(let msg): return msg
        }
    }
}
