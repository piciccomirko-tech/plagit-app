//
//  AdminDashboardService.swift
//  Plagit
//
//  Aggregator service that composes stats from existing admin services.
//

import Foundation

struct AdminDashboardStats {
    // Users
    var totalUsers: Int = 0
    var totalCandidates: Int = 0
    var totalBusinesses: Int = 0
    var verifiedUsers: Int = 0
    var suspendedUsers: Int = 0
    var newBusinesses: Int = 0
    var newCandidates: Int = 0

    // Jobs
    var activeJobs: Int = 0
    var pausedJobs: Int = 0
    var expiringJobs: Int = 0
    var noApplicantJobs: Int = 0
    var jobsNeedReview: Int = 0

    // Applications
    var applicationsToday: Int = 0
    var appliedCount: Int = 0
    var reviewCount: Int = 0
    var interviewCount: Int = 0
    var offerCount: Int = 0
    var hiredCount: Int = 0

    // Interviews
    var interviewsToday: Int = 0
    var interviewsTomorrow: Int = 0
    var interviewsThisWeek: Int = 0
    var pendingInterviews: Int = 0

    // Reports
    var openReports: Int = 0
    var urgentReports: Int = 0

    // Subscriptions
    var activePlans: Int = 0
    var trialPlans: Int = 0
    var renewingPlans: Int = 0
    var failedPayments: Int = 0

    // Community
    var publishedPosts: Int = 0
    var draftPosts: Int = 0
    var featuredPosts: Int = 0
    var totalViews: Int = 0

    // Messages
    var unreadMessages: Int = 0
    var pendingNotifications: Int = 0
    var flaggedContent: Int = 0

    // Needs attention
    var pendingBusinessVerification: Int = 0
}

struct AdminActivityItem: Identifiable {
    let id: UUID
    let action: String
    let target: String
    let category: String
    let adminUser: String
    let timestamp: String
    let color: String

    init(id: UUID = UUID(), action: String, target: String, category: String, adminUser: String, timestamp: String, color: String = "teal") {
        self.id = id; self.action = action; self.target = target; self.category = category; self.adminUser = adminUser; self.timestamp = timestamp; self.color = color
    }
}

struct AdminAttentionItem: Identifiable {
    let id = UUID()
    let icon: String
    let color: String
    let text: String
    let badge: String
    let route: String
}

protocol AdminDashboardServiceProtocol: Sendable {
    func fetchStats() async throws -> AdminDashboardStats
    func fetchActivity() async throws -> [AdminActivityItem]
    func fetchAttention() async throws -> [AdminAttentionItem]
}

final class MockAdminDashboardService: AdminDashboardServiceProtocol, @unchecked Sendable {
    func fetchStats() async throws -> AdminDashboardStats { AdminDashboardStats() }
    func fetchActivity() async throws -> [AdminActivityItem] { [] }
    func fetchAttention() async throws -> [AdminAttentionItem] { [] }
}
