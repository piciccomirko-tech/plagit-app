//
//  AdminMatchesAPIService.swift
//  Plagit
//
//  API calls for admin match management.
//

import Foundation

private struct APIWrapper<T: Decodable>: Decodable { let success: Bool; let data: T }
private struct PaginatedWrapper<T: Decodable>: Decodable { let success: Bool; let data: [T]; let meta: PgMeta? }
private struct PgMeta: Decodable { let page: Int; let limit: Int; let total: Int }

struct AdminMatchDTO: Decodable, Identifiable {
    var id: String { matchId ?? "\(candidateId)-\(jobId)" }
    let matchId: String?
    let matchStatus: String?
    let matchCreatedAt: String?
    let candidateId: String
    let candidateName: String
    let candidateInitials: String?
    let candidateRole: String?
    let candidateJobType: String?
    let candidateLocation: String?
    let candidateAvatarHue: Double?
    let candidateVerified: Bool?
    let candidatePhotoUrl: String?
    let candidateLat: Double?
    let candidateLng: Double?
    let jobId: String
    let jobTitle: String
    let jobRole: String?
    let jobType: String?
    let jobLocation: String?
    let jobSalary: String?
    let jobLat: Double?
    let jobLng: Double?
    let jobCreatedAt: String?
    let businessId: String?
    let businessName: String?
    let businessInitials: String?
    let businessVerified: Bool?
}

struct AdminMatchStatsDTO: Decodable {
    let totalMatches: Int
    let pendingMatches: Int
    let acceptedMatches: Int
    let deniedMatches: Int
    let matchNotificationsSent: Int
    let totalFeedback: Int
    let positiveFeedback: Int
    let profiledCandidates: Int
    let profiledJobs: Int
    let interviewsRequested: Int
    let interviewsAccepted: Int
    let interviewsDeclined: Int
    let interviewsCompleted: Int
}

struct AdminMatchNotifDTO: Decodable, Identifiable {
    let id: String
    let title: String
    let deliveryState: String
    let isRead: Bool
    let sentAt: String?
    let createdAt: String?
    let linkedEntity: String?
    let recipientName: String?
    let recipientType: String?
}

struct AdminFeedbackDTO: Decodable, Identifiable {
    let id: String
    let userId: String
    let matchId: String
    let userType: String
    let wasRelevant: Bool?
    let roleAccurate: Bool?
    let jobTypeAccurate: Bool?
    let createdAt: String?
    let userName: String?
    let userEmail: String?
    let accountType: String?
}

final class AdminMatchesAPIService {
    static let shared = AdminMatchesAPIService()
    private let client = APIClient.shared

    func fetchMatches(page: Int = 1, limit: Int = 50, role: String? = nil, jobType: String? = nil, search: String? = nil) async throws -> [AdminMatchDTO] {
        var q: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)"),
        ]
        if let role, !role.isEmpty { q.append(URLQueryItem(name: "role", value: role)) }
        if let jobType, !jobType.isEmpty { q.append(URLQueryItem(name: "job_type", value: jobType)) }
        if let search, !search.isEmpty { q.append(URLQueryItem(name: "search", value: search)) }
        let w: PaginatedWrapper<AdminMatchDTO> = try await client.request(.GET, path: "/admin/matches", queryItems: q)
        return w.data
    }

    func fetchStats() async throws -> AdminMatchStatsDTO {
        let w: APIWrapper<AdminMatchStatsDTO> = try await client.request(.GET, path: "/admin/matches/stats")
        return w.data
    }

    func fetchFeedback(page: Int = 1, limit: Int = 50, userType: String? = nil) async throws -> [AdminFeedbackDTO] {
        var q: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)"),
        ]
        if let userType, !userType.isEmpty { q.append(URLQueryItem(name: "user_type", value: userType)) }
        let w: PaginatedWrapper<AdminFeedbackDTO> = try await client.request(.GET, path: "/admin/matches/feedback", queryItems: q)
        return w.data
    }

    func fetchMatchNotifications(page: Int = 1, limit: Int = 50) async throws -> [AdminMatchNotifDTO] {
        let w: PaginatedWrapper<AdminMatchNotifDTO> = try await client.request(
            .GET, path: "/admin/matches/notifications",
            queryItems: [URLQueryItem(name: "page", value: "\(page)"), URLQueryItem(name: "limit", value: "\(limit)")]
        )
        return w.data
    }
}
