//
//  AdminCandidateService.swift
//  Plagit
//
//  Protocol-based service for admin candidate operations.
//  Swap MockAdminCandidateService for a real API implementation later.
//

import Foundation

// MARK: - Model

struct AdminCandidate: Identifiable {
    let id: UUID
    let name: String
    let initials: String
    let role: String
    let jobType: String
    let location: String
    let experience: String
    let languages: String
    var verificationStatus: String  // "Verified", "Pending Review", "Suspended", "New"
    let activeSince: String
    let profileViews: Int
    let avatarHue: Double

    init(id: UUID = UUID(), name: String, initials: String, role: String, jobType: String = "", location: String, experience: String, languages: String, verificationStatus: String, activeSince: String, profileViews: Int = 0, avatarHue: Double) {
        self.id = id; self.name = name; self.initials = initials; self.role = role; self.jobType = jobType; self.location = location; self.experience = experience; self.languages = languages; self.verificationStatus = verificationStatus; self.activeSince = activeSince; self.profileViews = profileViews; self.avatarHue = avatarHue
    }

    static let sampleData: [AdminCandidate] = [
        .init(name: "Elena Rossi", initials: "ER", role: "Chef", jobType: "Full-time", location: "Milan, IT", experience: "15 years", languages: "Italian, English", verificationStatus: "Verified", activeSince: "Active since Mar 2025", profileViews: 142, avatarHue: 0.52),
        .init(name: "James Park", initials: "JP", role: "Bartender", jobType: "Part-time", location: "London, UK", experience: "8 years", languages: "English, Korean", verificationStatus: "Pending Review", activeSince: "Joined Mar 2026", profileViews: 67, avatarHue: 0.38),
        .init(name: "Sofia Blanc", initials: "SB", role: "Sommelier", jobType: "Full-time", location: "Paris, FR", experience: "6 years", languages: "French, English, Spanish", verificationStatus: "Verified", activeSince: "Active since Jan 2026", profileViews: 93, avatarHue: 0.62),
        .init(name: "Marco Bianchi", initials: "MB", role: "Sous Chef", jobType: "Flexible", location: "Dubai, UAE", experience: "10 years", languages: "Italian, English", verificationStatus: "New", activeSince: "Joined today", profileViews: 5, avatarHue: 0.45),
        .init(name: "Anna Weber", initials: "AW", role: "Manager", jobType: "Full-time", location: "Berlin, DE", experience: "12 years", languages: "German, English", verificationStatus: "Suspended", activeSince: "Suspended Mar 2026", profileViews: 31, avatarHue: 0.58),
        .init(name: "Tom Chen", initials: "TC", role: "Kitchen Porter", jobType: "Part-time", location: "Sydney, AU", experience: "3 years", languages: "English, Mandarin", verificationStatus: "Pending Review", activeSince: "Joined 2 days ago", profileViews: 12, avatarHue: 0.35),
    ]
}

// MARK: - Protocol

protocol AdminCandidateServiceProtocol: Sendable {
    func fetchCandidates() async throws -> [AdminCandidate]
    func updateVerificationStatus(id: UUID, status: String) async throws
}

// MARK: - Mock Implementation

final class MockAdminCandidateService: AdminCandidateServiceProtocol, @unchecked Sendable {
    private var candidates: [AdminCandidate] = AdminCandidate.sampleData

    func fetchCandidates() async throws -> [AdminCandidate] {
        try await Task.sleep(for: .milliseconds(300))
        return candidates
    }

    func updateVerificationStatus(id: UUID, status: String) async throws {
        try await Task.sleep(for: .milliseconds(200))
        guard let i = candidates.firstIndex(where: { $0.id == id }) else {
            throw AdminCandidateServiceError.notFound
        }
        candidates[i].verificationStatus = status
    }
}

// MARK: - Errors

enum AdminCandidateServiceError: LocalizedError {
    case notFound
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .notFound: return "Candidate not found."
        case .networkError(let msg): return msg
        }
    }
}
