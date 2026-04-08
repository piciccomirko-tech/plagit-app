//
//  BusinessAPIService.swift
//  Plagit
//
//  Fetches real business data from /v1/business/* endpoints.
//

import Foundation

private struct APIWrapper<T: Decodable>: Decodable { let success: Bool; let data: T }

struct BusinessProfileDTO: Decodable {
    let id: String
    let name: String
    let email: String
    let phone: String?
    let location: String?
    let status: String
    let isVerified: Bool
    let avatarHue: Double
    let photoUrl: String?
    let profileStrength: Int
    let companyName: String
    let companyInitials: String
    let venueType: String?
    let businessLocation: String?
    let isFeatured: Bool
    let plan: String?
    let planStatus: String?
    let responseRate: Int
    let languages: String?
    let country: String?
    let countryCode: String?
    let profileViews: Int?
    let createdAt: String?
}

struct BusinessHomeDTO: Decodable {
    let business: BusinessSummaryDTO
    let stats: BusinessStatsDTO
    let nextInterview: BusinessNextInterviewDTO?
    let unreadMessages: Int
}

struct BusinessSummaryDTO: Decodable {
    let companyName: String
    let companyInitials: String
    let venueType: String?
    let location: String?
    let avatarHue: Double
    let isVerified: Bool
    let photoUrl: String?
    let profileLat: Double?
    let profileLng: Double?
    let country: String?
    let countryCode: String?
    let appLanguageCode: String?
    let spokenLanguages: String?
}

struct BusinessStatsDTO: Decodable {
    let activeJobs: Int
    let totalApplicants: Int
    let newApplicants: Int
    let interviews: Int
}

struct BusinessNextInterviewDTO: Decodable {
    let id: String
    let scheduledAt: String?
    let timezone: String?
    let interviewType: String
    let status: String
    let jobTitle: String?
    let candidateName: String?
    let candidateInitials: String?
}

private struct PaginatedWrapper<T: Decodable>: Decodable { let success: Bool; let data: [T]; let meta: PgMeta? }
private struct PgMeta: Decodable { let page: Int; let limit: Int; let total: Int }

struct BusinessJobDTO: Decodable, Identifiable {
    let id: String; let title: String; let location: String?; let employmentType: String?
    let salary: String?; let category: String?; let status: String; let isFeatured: Bool
    let avatarHue: Double; let views: Int?; let saveCount: Int?; let applicantCount: Int?; let createdAt: String?
    let description: String?; let requirements: String?
    let isUrgent: Bool?; let numHires: Int?
    let startDate: String?; let endDate: String?; let shiftHours: String?
}

struct BusinessApplicantDTO: Decodable, Identifiable {
    let id: String; let status: String; let appliedAt: String?
    let hasInterview: Bool; let hasOffer: Bool
    let candidateId: String?; let candidateName: String?; let candidateInitials: String?
    let candidateRole: String?; let candidateLocation: String?
    let candidateExperience: String?; let candidateAvatarHue: Double?
    let candidateVerified: Bool?; let candidatePhotoUrl: String?
    let candidateNationalityCode: String?
}

struct BusinessInterviewDTO: Decodable, Identifiable {
    let id: String; let scheduledAt: String?; let timezone: String?
    let interviewType: String; let status: String; let location: String?
    let meetingLink: String?; let createdAt: String?
    let candidateName: String?; let candidateInitials: String?
    let candidateRole: String?; let candidateAvatarHue: Double?
    let candidatePhotoUrl: String?
    let jobTitle: String?
}

struct BizConversationDTO: Decodable, Identifiable {
    let id: String; let lastMessage: String?; let status: String
    let isInterviewRelated: Bool; let updatedAt: String?
    let candidateName: String?; let candidateInitials: String?
    let candidateAvatarHue: Double?; let candidatePhotoUrl: String?
    let candidateNationalityCode: String?
    let jobTitle: String?; let unreadCount: Int?
}

struct BizCandidateProfileDTO: Decodable {
    let id: String; let userId: String?; let name: String; let initials: String?
    let role: String?; let location: String?; let experience: String?
    let languages: String?; let verificationStatus: String?
    let avatarHue: Double; let isVerified: Bool
    let photoUrl: String?
    let email: String?; let phone: String?
    let nationality: String?; let nationalityCode: String?; let countryCode: String?
}

struct BizNotificationDTO: Decodable, Identifiable {
    let id: String; let notificationType: String; let title: String
    let linkedEntity: String?; let destinationRoute: String?
    let deliveryState: String; let isRead: Bool
    let sentAt: String?; let createdAt: String?
}

struct NearbyCandidateDTO: Decodable, Identifiable, Hashable {
    let id: String; let name: String; let initials: String?
    let role: String?; let location: String?; let experience: String?
    let languages: String?; let jobType: String?; let verificationStatus: String?
    let avatarHue: Double; let isVerified: Bool; let photoUrl: String?
    let nationalityCode: String?
    let latitude: Double?; let longitude: Double?; let distanceKm: Double?
    let matchId: String?; let matchStatus: String?
    let availableToRelocate: Bool?
}

struct BusinessRecentApplicantDTO: Decodable, Identifiable {
    let id: String; let status: String; let appliedAt: String?
    let candidateId: String?; let candidateName: String?; let candidateInitials: String?
    let candidateRole: String?; let candidateLocation: String?
    let candidateExperience: String?; let candidateAvatarHue: Double?
    let candidateVerified: Bool?; let candidatePhotoUrl: String?
    let jobTitle: String?; let jobId: String?
}

final class BusinessAPIService {
    static let shared = BusinessAPIService()
    private let client = APIClient.shared
    private init() {}

    func fetchProfile() async throws -> BusinessProfileDTO {
        let w: APIWrapper<BusinessProfileDTO> = try await client.request(.GET, path: "/business/profile")
        return w.data
    }

    func fetchHome() async throws -> BusinessHomeDTO {
        let w: APIWrapper<BusinessHomeDTO> = try await client.request(.GET, path: "/business/home")
        return w.data
    }

    // MARK: - Jobs

    func fetchJobs(status: String? = nil) async throws -> [BusinessJobDTO] {
        var q: [URLQueryItem] = []
        if let status { q.append(URLQueryItem(name: "status", value: status)) }
        let w: PaginatedWrapper<BusinessJobDTO> = try await client.request(.GET, path: "/business/jobs", queryItems: q.isEmpty ? nil : q)
        return w.data
    }

    func createJob(title: String, location: String?, employmentType: String?, salary: String?, category: String?,
                   description: String? = nil, requirements: String? = nil, isUrgent: Bool = false, numHires: Int = 1,
                   openToInternational: Bool = false,
                   startDate: String? = nil, endDate: String? = nil, shiftHours: String? = nil,
                   latitude: Double? = nil, longitude: Double? = nil) async throws -> BusinessJobDTO {
        var d: [String: Any] = ["title": title]
        if let location, !location.isEmpty { d["location"] = location }
        if let employmentType, !employmentType.isEmpty { d["employment_type"] = employmentType }
        if let salary, !salary.isEmpty { d["salary"] = salary }
        if let category, !category.isEmpty { d["category"] = category }
        if let description, !description.isEmpty { d["description"] = description }
        if let requirements, !requirements.isEmpty { d["requirements"] = requirements }
        if isUrgent { d["is_urgent"] = true }
        if numHires > 1 { d["num_hires"] = numHires }
        if openToInternational { d["open_to_international"] = true }
        if let startDate { d["start_date"] = startDate }
        if let endDate { d["end_date"] = endDate }
        if let shiftHours, !shiftHours.isEmpty { d["shift_hours"] = shiftHours }
        if let latitude { d["latitude"] = latitude }
        if let longitude { d["longitude"] = longitude }
        let w: APIWrapper<BusinessJobDTO> = try await client.request(.POST, path: "/business/jobs", body: JSONBody(d))
        return w.data
    }

    func fetchJob(id: String) async throws -> BusinessJobDTO {
        let w: APIWrapper<BusinessJobDTO> = try await client.request(.GET, path: "/business/jobs/\(id)")
        return w.data
    }

    func updateJob(id: String, fields: [String: Any]) async throws -> BusinessJobDTO {
        let w: APIWrapper<BusinessJobDTO> = try await client.request(.PATCH, path: "/business/jobs/\(id)", body: JSONBody(fields))
        return w.data
    }

    // MARK: - Applicants

    func fetchApplicants(jobId: String, status: String? = nil) async throws -> [BusinessApplicantDTO] {
        var q: [URLQueryItem] = []
        if let status { q.append(URLQueryItem(name: "status", value: status)) }
        let w: PaginatedWrapper<BusinessApplicantDTO> = try await client.request(.GET, path: "/business/jobs/\(jobId)/applicants", queryItems: q.isEmpty ? nil : q)
        return w.data
    }

    func updateApplicantStatus(applicationId: String, status: String) async throws {
        struct Body: Encodable { let status: String }
        try await client.requestVoid(.PATCH, path: "/business/applicants/\(applicationId)/status", body: Body(status: status))
    }

    // MARK: - Interviews

    func fetchInterviews(status: String? = nil) async throws -> [BusinessInterviewDTO] {
        var q: [URLQueryItem] = []
        if let status { q.append(URLQueryItem(name: "status", value: status)) }
        let w: PaginatedWrapper<BusinessInterviewDTO> = try await client.request(.GET, path: "/business/interviews", queryItems: q.isEmpty ? nil : q)
        return w.data
    }

    func scheduleInterview(applicationId: String? = nil, candidateId: String? = nil, scheduledAt: String, timezone: String, interviewType: String, location: String?, meetingLink: String?) async throws -> BusinessInterviewDTO {
        var d: [String: Any] = ["scheduled_at": scheduledAt, "timezone": timezone, "interview_type": interviewType]
        if let applicationId, !applicationId.isEmpty { d["application_id"] = applicationId }
        if let candidateId, !candidateId.isEmpty { d["candidate_id"] = candidateId }
        if let location, !location.isEmpty { d["location"] = location }
        if let meetingLink, !meetingLink.isEmpty { d["meeting_link"] = meetingLink }
        let w: APIWrapper<BusinessInterviewDTO> = try await client.request(.POST, path: "/business/interviews", body: JSONBody(d))
        return w.data
    }

    func updateInterviewStatus(id: String, status: String) async throws {
        struct Body: Encodable { let status: String }
        try await client.requestVoid(.PATCH, path: "/business/interviews/\(id)/status", body: Body(status: status))
    }

    // MARK: - Profile Update
    @discardableResult
    func updateProfile(companyName: String? = nil, venueType: String? = nil, location: String? = nil, phone: String? = nil, languages: String? = nil, latitude: Double? = nil, longitude: Double? = nil) async throws -> BusinessProfileDTO {
        var d: [String: Any] = [:]
        if let companyName { d["company_name"] = companyName }
        if let venueType { d["venue_type"] = venueType }
        if let location { d["location"] = location }
        if let phone { d["phone"] = phone }
        if let languages { d["languages"] = languages }
        if let latitude { d["latitude"] = latitude }
        if let longitude { d["longitude"] = longitude }
        let w: APIWrapper<BusinessProfileDTO> = try await client.request(.PUT, path: "/business/profile", body: JSONBody(d))
        return w.data
    }

    // MARK: - Conversations
    func fetchConversations() async throws -> [BizConversationDTO] {
        let w: PaginatedWrapper<BizConversationDTO> = try await client.request(.GET, path: "/business/conversations")
        return w.data
    }
    func startConversation(candidateId: String) async throws -> String {
        struct Body: Encodable { let candidateId: String }
        struct Resp: Decodable { let conversationId: String; let created: Bool }
        let w: APIWrapper<Resp> = try await client.request(.POST, path: "/business/conversations/start", body: Body(candidateId: candidateId))
        return w.data.conversationId
    }
    func fetchMessages(conversationId: String) async throws -> [MessageDTO] {
        let w: PaginatedWrapper<MessageDTO> = try await client.request(.GET, path: "/business/conversations/\(conversationId)/messages")
        return w.data
    }
    func sendMessage(conversationId: String, body: String) async throws -> MessageDTO {
        struct B: Encodable { let body: String }
        let w: APIWrapper<MessageDTO> = try await client.request(.POST, path: "/business/conversations/\(conversationId)/messages", body: B(body: body))
        return w.data
    }

    // MARK: - Candidate Profile
    func fetchCandidateProfile(candidateId: String) async throws -> BizCandidateProfileDTO {
        let w: APIWrapper<BizCandidateProfileDTO> = try await client.request(.GET, path: "/business/candidates/\(candidateId)")
        return w.data
    }

    // MARK: - Notifications
    func fetchNotifications(isRead: Bool? = nil) async throws -> [BizNotificationDTO] {
        var q: [URLQueryItem] = []
        if let isRead { q.append(URLQueryItem(name: "is_read", value: isRead ? "true" : "false")) }
        let w: PaginatedWrapper<BizNotificationDTO> = try await client.request(.GET, path: "/business/notifications", queryItems: q.isEmpty ? nil : q)
        return w.data
    }
    func markNotificationRead(id: String) async throws {
        try await client.requestVoid(.PATCH, path: "/business/notifications/\(id)/read")
    }

    // MARK: - Recent Applicants (dashboard)
    // MARK: - Photo
    func uploadPhoto(base64Data: String) async throws -> String? {
        struct Body: Encodable { let photo: String }
        struct Resp: Decodable { let photoUrl: String? }
        let w: APIWrapper<Resp> = try await client.request(.POST, path: "/business/photo", body: Body(photo: base64Data))
        return w.data.photoUrl
    }

    func fetchRecentApplicants(limit: Int = 10) async throws -> [BusinessRecentApplicantDTO] {
        let w: APIWrapper<[BusinessRecentApplicantDTO]> = try await client.request(.GET, path: "/business/recent-applicants", queryItems: [URLQueryItem(name: "limit", value: "\(limit)")])
        return w.data
    }

    // MARK: - Nearby Candidates
    func fetchNearbyCandidates(lat: Double, lng: Double, radius: Double = 10, limit: Int = 30, role: String? = nil) async throws -> [NearbyCandidateDTO] {
        var q: [URLQueryItem] = [
            URLQueryItem(name: "lat", value: "\(lat)"), URLQueryItem(name: "lng", value: "\(lng)"),
            URLQueryItem(name: "radius", value: "\(radius)"), URLQueryItem(name: "limit", value: "\(limit)")
        ]
        if let role, !role.isEmpty { q.append(URLQueryItem(name: "role", value: role)) }
        let w: PaginatedWrapper<NearbyCandidateDTO> = try await client.request(.GET, path: "/business/candidates/nearby", queryItems: q)
        return w.data
    }

    // MARK: - Matches
    func updateMatchStatus(matchId: String, status: String) async throws {
        struct Body: Encodable { let status: String }
        try await client.requestVoid(.PATCH, path: "/business/matches/\(matchId)/status", body: Body(status: status))
    }

    func fetchJobMatches(jobId: String, page: Int = 1, limit: Int = 20) async throws -> [NearbyCandidateDTO] {
        let w: PaginatedWrapper<NearbyCandidateDTO> = try await client.request(
            .GET, path: "/business/matches/\(jobId)",
            queryItems: [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "limit", value: "\(limit)"),
            ]
        )
        return w.data
    }

    // MARK: - Analytics / Tracking

    func recordJobView(jobId: String) async {
        try? await client.requestVoid(.POST, path: "/business/jobs/\(jobId)/view")
    }

    func recordProfileView(profileId: String, profileType: String) async {
        try? await client.requestVoid(.POST, path: "/analytics/profile-view", body: JSONBody(["profileId": profileId, "profileType": profileType]))
    }
}
