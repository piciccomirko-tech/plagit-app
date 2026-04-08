//
//  AdminFeaturedContentService.swift
//  Plagit
//

import Foundation

struct AdminFeaturedItem: Identifiable {
    let id: UUID
    let title: String
    let type: String
    let linkedEntity: String
    let placement: String
    var status: String
    var isPinned: Bool
    let priority: Int
    let startDate: String
    let endDate: String
    let clicks: Int
    let views: Int
    let lastUpdated: String
    let avatarHue: Double

    init(id: UUID = UUID(), title: String, type: String, linkedEntity: String, placement: String, status: String, isPinned: Bool, priority: Int, startDate: String, endDate: String, clicks: Int, views: Int, lastUpdated: String, avatarHue: Double) {
        self.id = id; self.title = title; self.type = type; self.linkedEntity = linkedEntity; self.placement = placement; self.status = status; self.isPinned = isPinned; self.priority = priority; self.startDate = startDate; self.endDate = endDate; self.clicks = clicks; self.views = views; self.lastUpdated = lastUpdated; self.avatarHue = avatarHue
    }

    static let sampleData: [AdminFeaturedItem] = [
        .init(title: "Nobu Restaurant — Now Hiring", type: "Featured Employer", linkedEntity: "Nobu Restaurant", placement: "Candidate Home", status: "Active", isPinned: true, priority: 1, startDate: "Mar 18", endDate: "Apr 18", clicks: 342, views: 1854, lastUpdated: "2h ago", avatarHue: 0.55),
        .init(title: "The Ritz London Hiring Event", type: "Featured Employer", linkedEntity: "The Ritz London", placement: "Candidate Home", status: "Active", isPinned: true, priority: 2, startDate: "Mar 20", endDate: "Apr 20", clicks: 218, views: 1120, lastUpdated: "6h ago", avatarHue: 0.68),
        .init(title: "Senior Chef — Immediate Start", type: "Featured Job", linkedEntity: "Senior Chef — Nobu", placement: "Jobs Page", status: "Active", isPinned: false, priority: 3, startDate: "Mar 22", endDate: "Apr 22", clicks: 156, views: 876, lastUpdated: "1d ago", avatarHue: 0.55),
        .init(title: "Get Hired Faster This Week", type: "Home Banner", linkedEntity: "", placement: "Candidate Home", status: "Active", isPinned: true, priority: 1, startDate: "Mar 15", endDate: "Apr 15", clicks: 890, views: 3200, lastUpdated: "3h ago", avatarHue: 0.50),
        .init(title: "Top 5 CV Tips for Hospitality", type: "Recommended", linkedEntity: "5 Things Recruiters Notice", placement: "Community", status: "Active", isPinned: false, priority: 4, startDate: "Mar 20", endDate: "Apr 20", clicks: 234, views: 980, lastUpdated: "1d ago", avatarHue: 0.50),
        .init(title: "Welcome to Plagit", type: "Onboarding Card", linkedEntity: "", placement: "Onboarding", status: "Active", isPinned: false, priority: 5, startDate: "Jan 1", endDate: "—", clicks: 1200, views: 3159, lastUpdated: "Always active", avatarHue: 0.50),
        .init(title: "Four Seasons — Premium Employer", type: "Featured Employer", linkedEntity: "Four Seasons", placement: "Candidate Home", status: "Scheduled", isPinned: false, priority: 3, startDate: "Apr 1", endDate: "May 1", clicks: 0, views: 0, lastUpdated: "2d ago", avatarHue: 0.52),
        .init(title: "Bartender — Ritz London", type: "Featured Job", linkedEntity: "Bartender — The Ritz", placement: "Jobs Page", status: "Expired", isPinned: false, priority: 0, startDate: "Mar 1", endDate: "Mar 15", clicks: 98, views: 456, lastUpdated: "2w ago", avatarHue: 0.68),
        .init(title: "Post Your First Job — Business", type: "Onboarding Card", linkedEntity: "", placement: "Onboarding", status: "Draft", isPinned: false, priority: 0, startDate: "—", endDate: "—", clicks: 0, views: 0, lastUpdated: "1w ago", avatarHue: 0.50),
        .init(title: "Find Staff Near You", type: "Home Banner", linkedEntity: "", placement: "Business Home", status: "Active", isPinned: false, priority: 2, startDate: "Mar 10", endDate: "Apr 10", clicks: 145, views: 890, lastUpdated: "4h ago", avatarHue: 0.50),
    ]
}

protocol AdminFeaturedContentServiceProtocol: Sendable {
    func fetchItems() async throws -> [AdminFeaturedItem]
    func updateStatus(id: UUID, status: String) async throws
    func setPinned(id: UUID, pinned: Bool) async throws
    func deleteItem(id: UUID) async throws
}

final class MockAdminFeaturedContentService: AdminFeaturedContentServiceProtocol, @unchecked Sendable {
    private var items: [AdminFeaturedItem] = AdminFeaturedItem.sampleData
    func fetchItems() async throws -> [AdminFeaturedItem] { try await Task.sleep(for: .milliseconds(300)); return items }
    func updateStatus(id: UUID, status: String) async throws {
        try await Task.sleep(for: .milliseconds(200))
        guard let i = items.firstIndex(where: { $0.id == id }) else { throw AdminFeaturedContentServiceError.notFound }
        items[i].status = status
    }
    func setPinned(id: UUID, pinned: Bool) async throws {
        try await Task.sleep(for: .milliseconds(200))
        guard let i = items.firstIndex(where: { $0.id == id }) else { throw AdminFeaturedContentServiceError.notFound }
        items[i].isPinned = pinned
    }
    func deleteItem(id: UUID) async throws {
        try await Task.sleep(for: .milliseconds(200))
        guard let i = items.firstIndex(where: { $0.id == id }) else { throw AdminFeaturedContentServiceError.notFound }
        items.remove(at: i)
    }
}

enum AdminFeaturedContentServiceError: LocalizedError {
    case notFound; case networkError(String)
    var errorDescription: String? { switch self { case .notFound: return "Item not found."; case .networkError(let m): return m } }
}
