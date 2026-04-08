//
//  AdminDashboardAPIService.swift
//  Plagit
//

import Foundation

private struct APIWrapper<T: Decodable>: Decodable { let success: Bool; let data: T }

private struct StatsDTO: Decodable {
    let totalUsers: Int; let totalCandidates: Int; let totalBusinesses: Int
    let verifiedUsers: Int; let suspendedUsers: Int; let newBusinesses: Int; let newCandidates: Int
    let activeJobs: Int; let pausedJobs: Int; let expiringJobs: Int
    let noApplicantJobs: Int; let jobsNeedReview: Int
    let applicationsToday: Int; let appliedCount: Int; let reviewCount: Int
    let interviewCount: Int; let offerCount: Int; let hiredCount: Int
    let interviewsToday: Int; let interviewsTomorrow: Int
    let interviewsThisWeek: Int; let pendingInterviews: Int
    let openReports: Int; let urgentReports: Int
    let activePlans: Int; let trialPlans: Int; let renewingPlans: Int; let failedPayments: Int
    let publishedPosts: Int; let draftPosts: Int; let featuredPosts: Int; let totalViews: Int
    let unreadMessages: Int; let pendingNotifications: Int; let flaggedContent: Int
    let pendingBusinessVerification: Int?

    func toModel() -> AdminDashboardStats {
        AdminDashboardStats(
            totalUsers: totalUsers, totalCandidates: totalCandidates, totalBusinesses: totalBusinesses,
            verifiedUsers: verifiedUsers, suspendedUsers: suspendedUsers,
            newBusinesses: newBusinesses, newCandidates: newCandidates,
            activeJobs: activeJobs, pausedJobs: pausedJobs, expiringJobs: expiringJobs,
            noApplicantJobs: noApplicantJobs, jobsNeedReview: jobsNeedReview,
            applicationsToday: applicationsToday, appliedCount: appliedCount, reviewCount: reviewCount,
            interviewCount: interviewCount, offerCount: offerCount, hiredCount: hiredCount,
            interviewsToday: interviewsToday, interviewsTomorrow: interviewsTomorrow,
            interviewsThisWeek: interviewsThisWeek, pendingInterviews: pendingInterviews,
            openReports: openReports, urgentReports: urgentReports,
            activePlans: activePlans, trialPlans: trialPlans,
            renewingPlans: renewingPlans, failedPayments: failedPayments,
            publishedPosts: publishedPosts, draftPosts: draftPosts,
            featuredPosts: featuredPosts, totalViews: totalViews,
            unreadMessages: unreadMessages, pendingNotifications: pendingNotifications,
            flaggedContent: flaggedContent,
            pendingBusinessVerification: pendingBusinessVerification ?? 0
        )
    }
}

private struct ActivityDTO: Decodable {
    let id: String; let action: String; let target: String?; let category: String?
    let adminUser: String?; let result: String?; let createdAt: String?

    func toModel() -> AdminActivityItem {
        AdminActivityItem(
            id: UUID(uuidString: id) ?? UUID(), action: action,
            target: target ?? "", category: category ?? "",
            adminUser: adminUser ?? "System", timestamp: fmtRelative(createdAt),
            color: colorFor(category)
        )
    }
    private func fmtRelative(_ s: String?) -> String {
        guard let s else { return "—" }
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let d = f.date(from: s) else { return s }
        let secs = Date().timeIntervalSince(d)
        if secs < 60 { return "Just now" }; if secs < 3600 { return "\(Int(secs/60))m ago" }
        if secs < 86400 { return "\(Int(secs/3600))h ago" }; return "\(Int(secs/86400))d ago"
    }
    private func colorFor(_ cat: String?) -> String {
        switch cat {
        case "Users": return "teal"; case "Businesses": return "online"; case "Jobs": return "indigo"
        case "Reports", "Moderation": return "urgent"; case "Billing": return "amber"
        default: return "teal"
        }
    }
}

private struct AttentionDTO: Decodable {
    let icon: String; let color: String; let text: String; let badge: String; let route: String
    func toModel() -> AdminAttentionItem {
        AdminAttentionItem(icon: icon, color: color, text: text, badge: badge, route: route)
    }
}

final class AdminDashboardAPIService: AdminDashboardServiceProtocol, @unchecked Sendable {
    private let client: APIClient
    init(client: APIClient = .shared) { self.client = client }

    func fetchStats() async throws -> AdminDashboardStats {
        let dto: StatsDTO = try await client.request(.GET, path: "/admin/dashboard/stats")
        return dto.toModel()
    }

    func fetchActivity() async throws -> [AdminActivityItem] {
        let w: APIWrapper<[ActivityDTO]> = try await client.request(.GET, path: "/admin/dashboard/activity")
        return w.data.map { $0.toModel() }
    }

    func fetchAttention() async throws -> [AdminAttentionItem] {
        let w: APIWrapper<[AttentionDTO]> = try await client.request(.GET, path: "/admin/dashboard/attention")
        return w.data.map { $0.toModel() }
    }
}
