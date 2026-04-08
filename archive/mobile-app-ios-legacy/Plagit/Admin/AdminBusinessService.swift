//
//  AdminBusinessService.swift
//  Plagit
//
//  Protocol-based service for admin business operations.
//  Swap MockAdminBusinessService for a real API implementation later.
//

import Foundation

// MARK: - Model

struct AdminBiz: Identifiable {
    let id: UUID
    var name: String
    let initials: String
    let venueType: String
    let location: String
    let contact: String
    let email: String
    var status: String          // Active, Suspended, Banned
    var isVerified: Bool
    var isFeatured: Bool
    var plan: String            // Premium, Enterprise, Starter, Free
    var planStatus: String      // Active, Trial, Expired, Cancelled
    let renewalDate: String
    let activeJobs: Int
    let applicantsReceived: Int
    let responseRate: Int       // 0-100
    let lastActive: String
    let joinedDate: String
    let flagCount: Int
    let avatarHue: Double

    init(id: UUID = UUID(), name: String, initials: String, venueType: String, location: String, contact: String, email: String, status: String, isVerified: Bool, isFeatured: Bool, plan: String, planStatus: String, renewalDate: String, activeJobs: Int, applicantsReceived: Int, responseRate: Int, lastActive: String, joinedDate: String, flagCount: Int, avatarHue: Double) {
        self.id = id; self.name = name; self.initials = initials; self.venueType = venueType; self.location = location; self.contact = contact; self.email = email; self.status = status; self.isVerified = isVerified; self.isFeatured = isFeatured; self.plan = plan; self.planStatus = planStatus; self.renewalDate = renewalDate; self.activeJobs = activeJobs; self.applicantsReceived = applicantsReceived; self.responseRate = responseRate; self.lastActive = lastActive; self.joinedDate = joinedDate; self.flagCount = flagCount; self.avatarHue = avatarHue
    }

    static let sampleData: [AdminBiz] = [
        .init(name: "Nobu Restaurant", initials: "NR", venueType: "Fine Dining", location: "Dubai, UAE", contact: "Ahmed Al-Rashid", email: "hr@nobu.com", status: "Active", isVerified: true, isFeatured: true, plan: "Premium", planStatus: "Active", renewalDate: "Apr 15, 2026", activeJobs: 4, applicantsReceived: 87, responseRate: 94, lastActive: "1h ago", joinedDate: "Jan 2025", flagCount: 0, avatarHue: 0.55),
        .init(name: "The Ritz London", initials: "TR", venueType: "Luxury Hotel", location: "London, UK", contact: "Sarah Mitchell", email: "careers@theritz.com", status: "Active", isVerified: true, isFeatured: true, plan: "Enterprise", planStatus: "Active", renewalDate: "May 1, 2026", activeJobs: 7, applicantsReceived: 142, responseRate: 98, lastActive: "30m ago", joinedDate: "Feb 2025", flagCount: 0, avatarHue: 0.68),
        .init(name: "Dishoom Soho", initials: "DS", venueType: "Casual Dining", location: "London, UK", contact: "Priya Sharma", email: "jobs@dishoom.com", status: "Active", isVerified: false, isFeatured: false, plan: "Starter", planStatus: "Trial", renewalDate: "Apr 10, 2026", activeJobs: 2, applicantsReceived: 18, responseRate: 72, lastActive: "2d ago", joinedDate: "Mar 2026", flagCount: 0, avatarHue: 0.48),
        .init(name: "Fabric London", initials: "FB", venueType: "Nightclub", location: "London, UK", contact: "Mike Torres", email: "events@fabric.com", status: "Active", isVerified: false, isFeatured: false, plan: "Starter", planStatus: "Expired", renewalDate: "Mar 20, 2026", activeJobs: 1, applicantsReceived: 5, responseRate: 45, lastActive: "1w ago", joinedDate: "Mar 2026", flagCount: 1, avatarHue: 0.35),
        .init(name: "Sky Lounge", initials: "SL", venueType: "Rooftop Bar", location: "Dubai, UAE", contact: "Unknown", email: "info@skylounge.com", status: "Banned", isVerified: false, isFeatured: false, plan: "Premium", planStatus: "Cancelled", renewalDate: "—", activeJobs: 0, applicantsReceived: 3, responseRate: 12, lastActive: "1mo ago", joinedDate: "Nov 2025", flagCount: 5, avatarHue: 0.42),
        .init(name: "Four Seasons", initials: "FS", venueType: "Luxury Hotel", location: "Paris, FR", contact: "Marie Laurent", email: "hr@fourseasons.com", status: "Active", isVerified: true, isFeatured: false, plan: "Enterprise", planStatus: "Active", renewalDate: "Jun 1, 2026", activeJobs: 5, applicantsReceived: 96, responseRate: 91, lastActive: "3h ago", joinedDate: "Mar 2025", flagCount: 0, avatarHue: 0.52),
        .init(name: "Chiltern Firehouse", initials: "CF", venueType: "Restaurant", location: "London, UK", contact: "James Lowe", email: "team@chilternfirehouse.com", status: "Active", isVerified: true, isFeatured: false, plan: "Premium", planStatus: "Active", renewalDate: "Apr 20, 2026", activeJobs: 3, applicantsReceived: 54, responseRate: 82, lastActive: "6h ago", joinedDate: "Oct 2025", flagCount: 0, avatarHue: 0.15),
        .init(name: "Sketch London", initials: "SK", venueType: "Restaurant", location: "London, UK", contact: "Lina Moreau", email: "hr@sketch.london", status: "Suspended", isVerified: true, isFeatured: false, plan: "Premium", planStatus: "Active", renewalDate: "May 5, 2026", activeJobs: 0, applicantsReceived: 31, responseRate: 38, lastActive: "2w ago", joinedDate: "Aug 2025", flagCount: 3, avatarHue: 0.58),
    ]
}

// MARK: - Protocol

protocol AdminBusinessServiceProtocol: Sendable {
    func fetchBusinesses() async throws -> [AdminBiz]
    func updateStatus(id: UUID, status: String) async throws
    func setVerified(id: UUID, verified: Bool) async throws
    func setFeatured(id: UUID, featured: Bool) async throws
    func deleteBusiness(id: UUID) async throws
}

// MARK: - Mock Implementation

final class MockAdminBusinessService: AdminBusinessServiceProtocol, @unchecked Sendable {
    private var businesses: [AdminBiz] = AdminBiz.sampleData

    func fetchBusinesses() async throws -> [AdminBiz] {
        try await Task.sleep(for: .milliseconds(300))
        return businesses
    }

    func updateStatus(id: UUID, status: String) async throws {
        try await Task.sleep(for: .milliseconds(200))
        guard let i = businesses.firstIndex(where: { $0.id == id }) else {
            throw AdminBusinessServiceError.notFound
        }
        businesses[i].status = status
    }

    func setVerified(id: UUID, verified: Bool) async throws {
        try await Task.sleep(for: .milliseconds(200))
        guard let i = businesses.firstIndex(where: { $0.id == id }) else {
            throw AdminBusinessServiceError.notFound
        }
        businesses[i].isVerified = verified
    }

    func setFeatured(id: UUID, featured: Bool) async throws {
        try await Task.sleep(for: .milliseconds(200))
        guard let i = businesses.firstIndex(where: { $0.id == id }) else {
            throw AdminBusinessServiceError.notFound
        }
        businesses[i].isFeatured = featured
    }

    func deleteBusiness(id: UUID) async throws {
        try await Task.sleep(for: .milliseconds(200))
        guard let i = businesses.firstIndex(where: { $0.id == id }) else {
            throw AdminBusinessServiceError.notFound
        }
        businesses.remove(at: i)
    }
}

// MARK: - Errors

enum AdminBusinessServiceError: LocalizedError {
    case notFound
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .notFound: return "Business not found."
        case .networkError(let msg): return msg
        }
    }
}
