//
//  AdminCommunityService.swift
//  Plagit
//

import Foundation

struct AdminContent: Identifiable {
    let id: UUID
    let title: String
    let category: String
    let author: String
    let authorInitials: String
    var status: String
    var isPinned: Bool
    var isFeaturedOnHome: Bool
    let linkedEmployer: String
    let linkedJob: String
    let createdDate: String
    let publishedDate: String
    let views: Int
    let saves: Int
    let readTime: String
    let summary: String
    let avatarHue: Double

    init(id: UUID = UUID(), title: String, category: String, author: String, authorInitials: String, status: String, isPinned: Bool, isFeaturedOnHome: Bool, linkedEmployer: String, linkedJob: String, createdDate: String, publishedDate: String, views: Int, saves: Int, readTime: String, summary: String, avatarHue: Double) {
        self.id = id; self.title = title; self.category = category; self.author = author; self.authorInitials = authorInitials; self.status = status; self.isPinned = isPinned; self.isFeaturedOnHome = isFeaturedOnHome; self.linkedEmployer = linkedEmployer; self.linkedJob = linkedJob; self.createdDate = createdDate; self.publishedDate = publishedDate; self.views = views; self.saves = saves; self.readTime = readTime; self.summary = summary; self.avatarHue = avatarHue
    }

    static let sampleData: [AdminContent] = [
        .init(title: "5 Things Recruiters Notice First on Your CV", category: "Career Tips", author: "Admin Mirko", authorInitials: "AM", status: "Published", isPinned: true, isFeaturedOnHome: true, linkedEmployer: "", linkedJob: "", createdDate: "Mar 20", publishedDate: "Mar 20", views: 4231, saves: 678, readTime: "4 min", summary: "Key tips for hospitality professionals looking to stand out.", avatarHue: 0.50),
        .init(title: "Nobu Restaurant — Now Hiring in Dubai", category: "Featured Employers", author: "Admin Mirko", authorInitials: "AM", status: "Published", isPinned: true, isFeaturedOnHome: true, linkedEmployer: "Nobu Restaurant", linkedJob: "", createdDate: "Mar 18", publishedDate: "Mar 18", views: 1854, saves: 212, readTime: "2 min", summary: "Explore career opportunities at one of the world's most iconic restaurants.", avatarHue: 0.55),
        .init(title: "From Line Cook to Executive Chef in 3 Years", category: "Success Stories", author: "Elena Rossi", authorInitials: "ER", status: "Published", isPinned: false, isFeaturedOnHome: false, linkedEmployer: "", linkedJob: "", createdDate: "Mar 15", publishedDate: "Mar 16", views: 2105, saves: 342, readTime: "6 min", summary: "Elena shares her rapid career progression in fine dining.", avatarHue: 0.52),
        .init(title: "Free Food Safety Certification — Level 2", category: "Training", author: "Admin Mirko", authorInitials: "AM", status: "Published", isPinned: false, isFeaturedOnHome: false, linkedEmployer: "", linkedJob: "", createdDate: "Mar 12", publishedDate: "Mar 12", views: 980, saves: 156, readTime: "3 min", summary: "Free government-accredited food safety certification for UK hospitality workers.", avatarHue: 0.50),
        .init(title: "How to Negotiate Your Salary in Hospitality", category: "Career Tips", author: "Admin Mirko", authorInitials: "AM", status: "Published", isPinned: false, isFeaturedOnHome: false, linkedEmployer: "", linkedJob: "", createdDate: "Mar 10", publishedDate: "Mar 11", views: 1450, saves: 234, readTime: "5 min", summary: "Practical negotiation strategies tailored for hospitality roles.", avatarHue: 0.50),
        .init(title: "The Ritz London — Premium Hiring Event", category: "Featured Employers", author: "Admin Mirko", authorInitials: "AM", status: "Published", isPinned: false, isFeaturedOnHome: false, linkedEmployer: "The Ritz London", linkedJob: "", createdDate: "Mar 8", publishedDate: "Mar 8", views: 1120, saves: 89, readTime: "2 min", summary: "Exclusive hiring event for top hospitality talent.", avatarHue: 0.68),
        .init(title: "Senior Chef — Nobu Dubai (Immediate Start)", category: "Job Highlights", author: "System", authorInitials: "SY", status: "Published", isPinned: false, isFeaturedOnHome: false, linkedEmployer: "Nobu Restaurant", linkedJob: "Senior Chef", createdDate: "Mar 22", publishedDate: "Mar 22", views: 876, saves: 45, readTime: "1 min", summary: "Featured job: Senior Chef position at Nobu Dubai.", avatarHue: 0.55),
        .init(title: "WSET Level 1 — Wine Fundamentals", category: "Training", author: "Admin Mirko", authorInitials: "AM", status: "Published", isPinned: false, isFeaturedOnHome: false, linkedEmployer: "", linkedJob: "", createdDate: "Mar 5", publishedDate: "Mar 6", views: 654, saves: 98, readTime: "3 min", summary: "Wine certification for aspiring sommeliers and bartenders.", avatarHue: 0.50),
        .init(title: "Top 10 Interview Questions for Hospitality", category: "Career Tips", author: "Admin Mirko", authorInitials: "AM", status: "Draft", isPinned: false, isFeaturedOnHome: false, linkedEmployer: "", linkedJob: "", createdDate: "Mar 24", publishedDate: "—", views: 0, saves: 0, readTime: "4 min", summary: "Prepare for your next hospitality interview with these common questions.", avatarHue: 0.50),
        .init(title: "Bartender Certification Guide", category: "Training", author: "Admin Mirko", authorInitials: "AM", status: "Draft", isPinned: false, isFeaturedOnHome: false, linkedEmployer: "", linkedJob: "", createdDate: "Mar 25", publishedDate: "—", views: 0, saves: 0, readTime: "5 min", summary: "Complete guide to bartender certifications worldwide.", avatarHue: 0.50),
        .init(title: "How I Landed My Dream Job at The Dorchester", category: "Success Stories", author: "Sofia Blanc", authorInitials: "SB", status: "Scheduled", isPinned: false, isFeaturedOnHome: false, linkedEmployer: "The Dorchester", linkedJob: "", createdDate: "Mar 26", publishedDate: "Apr 1", views: 0, saves: 0, readTime: "5 min", summary: "Sofia's story of landing a sommelier role at a 5-star London hotel.", avatarHue: 0.62),
        .init(title: "Four Seasons — Global Hospitality Careers", category: "Featured Employers", author: "Admin Mirko", authorInitials: "AM", status: "Archived", isPinned: false, isFeaturedOnHome: false, linkedEmployer: "Four Seasons", linkedJob: "", createdDate: "Feb 15", publishedDate: "Feb 15", views: 2340, saves: 178, readTime: "3 min", summary: "Explore global opportunities with Four Seasons Hotels.", avatarHue: 0.52),
    ]
}

protocol AdminCommunityServiceProtocol: Sendable {
    func fetchPosts() async throws -> [AdminContent]
    func updateStatus(id: UUID, status: String) async throws
    func setPinned(id: UUID, pinned: Bool) async throws
    func setFeaturedOnHome(id: UUID, featured: Bool) async throws
    func deletePost(id: UUID) async throws
}

final class MockAdminCommunityService: AdminCommunityServiceProtocol, @unchecked Sendable {
    private var posts: [AdminContent] = AdminContent.sampleData
    func fetchPosts() async throws -> [AdminContent] { try await Task.sleep(for: .milliseconds(300)); return posts }
    func updateStatus(id: UUID, status: String) async throws {
        try await Task.sleep(for: .milliseconds(200))
        guard let i = posts.firstIndex(where: { $0.id == id }) else { throw AdminCommunityServiceError.notFound }
        posts[i].status = status
    }
    func setPinned(id: UUID, pinned: Bool) async throws {
        try await Task.sleep(for: .milliseconds(200))
        guard let i = posts.firstIndex(where: { $0.id == id }) else { throw AdminCommunityServiceError.notFound }
        posts[i].isPinned = pinned
    }
    func setFeaturedOnHome(id: UUID, featured: Bool) async throws {
        try await Task.sleep(for: .milliseconds(200))
        guard let i = posts.firstIndex(where: { $0.id == id }) else { throw AdminCommunityServiceError.notFound }
        posts[i].isFeaturedOnHome = featured
    }
    func deletePost(id: UUID) async throws {
        try await Task.sleep(for: .milliseconds(200))
        guard let i = posts.firstIndex(where: { $0.id == id }) else { throw AdminCommunityServiceError.notFound }
        posts.remove(at: i)
    }
}

enum AdminCommunityServiceError: LocalizedError {
    case notFound; case networkError(String)
    var errorDescription: String? { switch self { case .notFound: return "Post not found."; case .networkError(let m): return m } }
}
