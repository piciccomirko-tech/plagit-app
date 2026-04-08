//
//  AdminJobService.swift
//  Plagit
//
//  Protocol-based service for admin job operations.
//  Swap MockAdminJobService for a real API implementation later.
//

import Foundation

// MARK: - Model

struct AdminJob: Identifiable {
    let id: UUID
    let title: String
    let business: String
    let businessInitials: String
    let location: String
    let employmentType: String
    let salary: String
    let category: String
    var status: String         // Active, Paused, Closed, Draft, Pending Review, Flagged, Suspended
    var isFeatured: Bool
    let isVerified: Bool       // employer verified
    let postedDate: String
    let expiryDate: String
    let views: Int
    let saves: Int
    let applicants: Int
    let shortlisted: Int
    let interviews: Int
    let flagCount: Int
    let avatarHue: Double

    init(id: UUID = UUID(), title: String, business: String, businessInitials: String, location: String, employmentType: String, salary: String, category: String, status: String, isFeatured: Bool, isVerified: Bool, postedDate: String, expiryDate: String, views: Int, saves: Int = 0, applicants: Int, shortlisted: Int, interviews: Int, flagCount: Int, avatarHue: Double) {
        self.id = id; self.title = title; self.business = business; self.businessInitials = businessInitials; self.location = location; self.employmentType = employmentType; self.salary = salary; self.category = category; self.status = status; self.isFeatured = isFeatured; self.isVerified = isVerified; self.postedDate = postedDate; self.expiryDate = expiryDate; self.views = views; self.saves = saves; self.applicants = applicants; self.shortlisted = shortlisted; self.interviews = interviews; self.flagCount = flagCount; self.avatarHue = avatarHue
    }

    static let sampleData: [AdminJob] = [
        .init(title: "Senior Chef", business: "Nobu Restaurant", businessInitials: "NR", location: "Dubai, UAE", employmentType: "Full-time", salary: "$5,500/mo", category: "Fine Dining", status: "Active", isFeatured: true, isVerified: true, postedDate: "Mar 18", expiryDate: "Apr 18", views: 342, applicants: 12, shortlisted: 4, interviews: 2, flagCount: 0, avatarHue: 0.55),
        .init(title: "Bar Manager", business: "The Ritz London", businessInitials: "TR", location: "London, UK", employmentType: "Full-time", salary: "£45–55k", category: "Luxury Hotel", status: "Active", isFeatured: true, isVerified: true, postedDate: "Mar 20", expiryDate: "Apr 20", views: 218, applicants: 6, shortlisted: 3, interviews: 1, flagCount: 0, avatarHue: 0.68),
        .init(title: "Waitstaff", business: "Dishoom Soho", businessInitials: "DS", location: "London, UK", employmentType: "Part-time", salary: "£14/hr", category: "Casual Dining", status: "Pending Review", isFeatured: false, isVerified: false, postedDate: "Mar 22", expiryDate: "Apr 22", views: 45, applicants: 3, shortlisted: 0, interviews: 0, flagCount: 0, avatarHue: 0.48),
        .init(title: "Bartender", business: "Fabric London", businessInitials: "FB", location: "London, UK", employmentType: "Part-time", salary: "£15/hr + tips", category: "Nightclub", status: "Active", isFeatured: false, isVerified: false, postedDate: "Mar 24", expiryDate: "Mar 31", views: 28, applicants: 0, shortlisted: 0, interviews: 0, flagCount: 0, avatarHue: 0.35),
        .init(title: "Host / Hostess", business: "Sky Lounge", businessInitials: "SL", location: "Dubai, UAE", employmentType: "Full-time", salary: "$3,000/mo", category: "Rooftop Bar", status: "Flagged", isFeatured: false, isVerified: false, postedDate: "Mar 10", expiryDate: "Apr 10", views: 156, applicants: 8, shortlisted: 1, interviews: 0, flagCount: 3, avatarHue: 0.42),
        .init(title: "Line Cook", business: "Unknown Venue", businessInitials: "UV", location: "London, UK", employmentType: "Full-time", salary: "Not specified", category: "Uncategorized", status: "Flagged", isFeatured: false, isVerified: false, postedDate: "Mar 23", expiryDate: "Apr 23", views: 12, applicants: 1, shortlisted: 0, interviews: 0, flagCount: 2, avatarHue: 0.30),
        .init(title: "Sommelier", business: "Four Seasons", businessInitials: "FS", location: "Paris, FR", employmentType: "Full-time", salary: "€3,800/mo", category: "Luxury Hotel", status: "Paused", isFeatured: false, isVerified: true, postedDate: "Mar 15", expiryDate: "Apr 15", views: 189, applicants: 4, shortlisted: 2, interviews: 1, flagCount: 0, avatarHue: 0.52),
        .init(title: "Sous Chef", business: "Le Cinq", businessInitials: "LC", location: "Paris, FR", employmentType: "Full-time", salary: "€40k", category: "Fine Dining", status: "Closed", isFeatured: false, isVerified: true, postedDate: "Feb 28", expiryDate: "Mar 28", views: 412, applicants: 9, shortlisted: 3, interviews: 2, flagCount: 0, avatarHue: 0.65),
        .init(title: "Restaurant Manager", business: "Chiltern Firehouse", businessInitials: "CF", location: "London, UK", employmentType: "Full-time", salary: "£4,800/mo", category: "Restaurant", status: "Active", isFeatured: false, isVerified: true, postedDate: "Mar 25", expiryDate: "Apr 25", views: 94, applicants: 7, shortlisted: 2, interviews: 1, flagCount: 0, avatarHue: 0.15),
        .init(title: "Night Reception", business: "The Ned", businessInitials: "TN", location: "London, UK", employmentType: "Part-time", salary: "£13/hr", category: "Hotel", status: "Draft", isFeatured: false, isVerified: true, postedDate: "Mar 26", expiryDate: "—", views: 0, applicants: 0, shortlisted: 0, interviews: 0, flagCount: 0, avatarHue: 0.65),
    ]
}

// MARK: - Protocol

protocol AdminJobServiceProtocol: Sendable {
    func fetchJobs() async throws -> [AdminJob]
    func updateStatus(id: UUID, status: String) async throws
    func setFeatured(id: UUID, featured: Bool) async throws
    func deleteJob(id: UUID) async throws
}

// MARK: - Mock Implementation

final class MockAdminJobService: AdminJobServiceProtocol, @unchecked Sendable {
    private var jobs: [AdminJob] = AdminJob.sampleData

    func fetchJobs() async throws -> [AdminJob] {
        try await Task.sleep(for: .milliseconds(300))
        return jobs
    }

    func updateStatus(id: UUID, status: String) async throws {
        try await Task.sleep(for: .milliseconds(200))
        guard let i = jobs.firstIndex(where: { $0.id == id }) else {
            throw AdminJobServiceError.notFound
        }
        jobs[i].status = status
    }

    func setFeatured(id: UUID, featured: Bool) async throws {
        try await Task.sleep(for: .milliseconds(200))
        guard let i = jobs.firstIndex(where: { $0.id == id }) else {
            throw AdminJobServiceError.notFound
        }
        jobs[i].isFeatured = featured
    }

    func deleteJob(id: UUID) async throws {
        try await Task.sleep(for: .milliseconds(200))
        guard let i = jobs.firstIndex(where: { $0.id == id }) else {
            throw AdminJobServiceError.notFound
        }
        jobs.remove(at: i)
    }
}

// MARK: - Errors

enum AdminJobServiceError: LocalizedError {
    case notFound
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .notFound: return "Job not found."
        case .networkError(let msg): return msg
        }
    }
}
