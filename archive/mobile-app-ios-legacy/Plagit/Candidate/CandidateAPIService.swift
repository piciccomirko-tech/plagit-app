//
//  CandidateAPIService.swift
//  Plagit
//
//  Fetches real candidate data from /v1/candidate/* endpoints.
//

import Foundation

// MARK: - Response Wrappers

private struct APIWrapper<T: Decodable>: Decodable {
    let success: Bool
    let data: T
}

private struct PaginatedWrapper<T: Decodable>: Decodable {
    let success: Bool
    let data: [T]
    let meta: PaginationMeta?
}

private struct PaginationMeta: Decodable {
    let page: Int
    let limit: Int
    let total: Int
    let pages: Int
}

// MARK: - Response DTOs

struct CandidateProfileDTO: Decodable {
    let id: String
    let name: String
    let initials: String
    let email: String
    let phone: String?
    let location: String?
    let role: String?
    let status: String
    let isVerified: Bool
    let profileStrength: Int
    let profileViews: Int?
    let avatarHue: Double
    let photoUrl: String?
    let experience: String?
    let languages: String?
    let verificationStatus: String
    let createdAt: String?
}

struct CandidateHomeDTO: Decodable {
    let user: HomeUserDTO
    let applicationsSummary: ApplicationsSummaryDTO
    let nextInterview: NextInterviewDTO?
    let unreadMessages: Int
    let unreadNotifications: Int
}

struct HomeUserDTO: Decodable {
    let name: String
    let initials: String
    let location: String?
    let avatarHue: Double
    let profileStrength: Int
    let hasPhoto: Bool?
    let hasLocation: Bool?
    let hasRole: Bool?
    let hasExperience: Bool?
    let hasLanguages: Bool?
    let appLanguageCode: String?
    let spokenLanguages: String?
    let nationality: String?
    let nationalityCode: String?
    let countryCode: String?
    let hasPhone: Bool?
    let isVerified: Bool
    let photoUrl: String?
    let profileLat: Double?
    let profileLng: Double?
}

struct ApplicationsSummaryDTO: Decodable {
    let total: Int
    let underReview: Int
    let interview: Int
    let offer: Int
}

struct NextInterviewDTO: Decodable {
    let id: String
    let scheduledAt: String?
    let timezone: String?
    let interviewType: String
    let status: String
    let location: String?
    let meetingLink: String?
    let jobTitle: String?
    let jobLocation: String?
}

struct NearbyJobDTO: Decodable, Identifiable {
    let id: String
    let title: String
    let location: String?
    let employmentType: String?
    let salary: String?
    let category: String?
    let isFeatured: Bool
    let avatarHue: Double
    let latitude: Double?
    let longitude: Double?
    let distanceKm: Double
    let createdAt: String?
    let businessName: String?
    let businessInitials: String?
    let businessVerified: Bool?
    let businessAvatarHue: Double?
    let businessPhotoUrl: String?
    let businessCountryCode: String?
}

// Also used as the full job list item (same shape)
struct FeaturedJobDTO: Decodable, Identifiable {
    let id: String
    let title: String
    let location: String?
    let employmentType: String?
    let salary: String?
    let category: String?
    let isFeatured: Bool
    let avatarHue: Double
    let createdAt: String?
    let businessId: String?
    let businessName: String?
    let businessInitials: String?
    let businessVerified: Bool?
    let businessAvatarHue: Double?
    let matchId: String?
    let matchStatus: String?
    let openToInternational: Bool?
    let isUrgent: Bool?
    let shiftHours: String?
}

struct JobDetailDTO: Decodable {
    let id: String
    let title: String
    let location: String?
    let employmentType: String?
    let salary: String?
    let category: String?
    let isFeatured: Bool
    let avatarHue: Double
    let views: Int?
    let createdAt: String?
    let businessName: String?
    let businessInitials: String?
    let businessVerified: Bool?
    let businessAvatarHue: Double?
    let businessVenueType: String?
    let businessLocation: String?
    let businessPhotoUrl: String?
    let description: String?
    let requirements: String?
    let isUrgent: Bool?
    let numHires: Int?
    let startDate: String?
    let endDate: String?
    let shiftHours: String?
    let hasApplied: Bool?
    let applicationStatus: String?
}

struct CandidateApplicationDTO: Decodable, Identifiable {
    let id: String
    let status: String
    let appliedAt: String?
    let hasInterview: Bool
    let hasOffer: Bool
    let jobId: String?
    let jobTitle: String?
    let jobLocation: String?
    let salary: String?
    let employmentType: String?
    let jobAvatarHue: Double?
    let businessName: String?
    let businessInitials: String?
    let businessVerified: Bool?
    let businessAvatarHue: Double?
}

struct CandidateInterviewDTO: Decodable, Identifiable {
    let id: String
    let scheduledAt: String?
    let timezone: String?
    let interviewType: String
    let status: String
    let location: String?
    let meetingLink: String?
    let createdAt: String?
    let jobId: String?
    let jobTitle: String?
    let jobLocation: String?
    let businessName: String?
    let businessInitials: String?
    let businessVerified: Bool?
    let businessAvatarHue: Double?
}

struct CommunityPostDTO: Decodable, Identifiable {
    let id: String
    let title: String
    let category: String?
    let author: String?
    let authorInitials: String?
    let status: String?
    let isPinned: Bool?
    let isFeaturedOnHome: Bool?
    let linkedEmployer: String?
    let linkedJob: String?
    let publishedDate: String?
    let views: Int?
    let saves: Int?
    let readTime: String?
    let summary: String?
    let avatarHue: Double?
}

struct ConversationDTO: Decodable, Identifiable {
    let id: String
    let lastMessage: String?
    let status: String
    let isInterviewRelated: Bool
    let updatedAt: String?
    let businessName: String?
    let businessInitials: String?
    let businessVerified: Bool?
    let businessAvatarHue: Double?
    let businessCountryCode: String?
    let jobTitle: String?
    let unreadCount: Int?
}

struct MessageDTO: Decodable, Identifiable {
    let id: String
    let body: String
    let isRead: Bool
    let senderId: String
    let createdAt: String?
    let senderName: String?
    let senderType: String?
}

struct ApplyResponseDTO: Decodable {
    let id: String
    let jobId: String
    let status: String
    let createdAt: String?
}

// MARK: - Service

final class CandidateAPIService {
    static let shared = CandidateAPIService()
    private let client = APIClient.shared
    private init() {}

    func fetchProfile() async throws -> CandidateProfileDTO {
        let wrapper: APIWrapper<CandidateProfileDTO> = try await client.request(
            .GET, path: "/candidate/profile"
        )
        return wrapper.data
    }

    func fetchHome() async throws -> CandidateHomeDTO {
        let wrapper: APIWrapper<CandidateHomeDTO> = try await client.request(
            .GET, path: "/candidate/home"
        )
        return wrapper.data
    }

    func fetchFeaturedJobs(page: Int = 1, limit: Int = 20, search: String? = nil) async throws -> [FeaturedJobDTO] {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        if let search, !search.isEmpty {
            queryItems.append(URLQueryItem(name: "search", value: search))
        }

        let wrapper: PaginatedWrapper<FeaturedJobDTO> = try await client.request(
            .GET, path: "/candidate/jobs/featured",
            queryItems: queryItems
        )
        return wrapper.data
    }

    // MARK: - Jobs

    func fetchJobs(
        page: Int = 1, limit: Int = 20,
        search: String? = nil, employmentType: String? = nil, category: String? = nil,
        isUrgent: Bool = false, shiftHours: String? = nil, verifiedOnly: Bool = false
    ) async throws -> [FeaturedJobDTO] {
        var q: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        if let search, !search.isEmpty { q.append(URLQueryItem(name: "search", value: search)) }
        if let employmentType, !employmentType.isEmpty { q.append(URLQueryItem(name: "employment_type", value: employmentType)) }
        if let category, !category.isEmpty { q.append(URLQueryItem(name: "category", value: category)) }
        if isUrgent { q.append(URLQueryItem(name: "is_urgent", value: "true")) }
        if let shiftHours, !shiftHours.isEmpty { q.append(URLQueryItem(name: "shift_hours", value: shiftHours)) }
        if verifiedOnly { q.append(URLQueryItem(name: "verified_only", value: "true")) }

        let wrapper: PaginatedWrapper<FeaturedJobDTO> = try await client.request(
            .GET, path: "/candidate/jobs", queryItems: q
        )
        return wrapper.data
    }

    func fetchJobDetail(id: String) async throws -> JobDetailDTO {
        let wrapper: APIWrapper<JobDetailDTO> = try await client.request(
            .GET, path: "/candidate/jobs/\(id)"
        )
        return wrapper.data
    }

    func applyToJob(id: String) async throws -> ApplyResponseDTO {
        let wrapper: APIWrapper<ApplyResponseDTO> = try await client.request(
            .POST, path: "/candidate/jobs/\(id)/apply"
        )
        return wrapper.data
    }

    // MARK: - Applications

    func fetchApplications(page: Int = 1, limit: Int = 50, status: String? = nil, search: String? = nil) async throws -> [CandidateApplicationDTO] {
        var q: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        if let status, !status.isEmpty { q.append(URLQueryItem(name: "status", value: status)) }
        if let search, !search.isEmpty { q.append(URLQueryItem(name: "search", value: search)) }

        let wrapper: PaginatedWrapper<CandidateApplicationDTO> = try await client.request(
            .GET, path: "/candidate/applications", queryItems: q
        )
        return wrapper.data
    }

    func fetchApplication(id: String) async throws -> CandidateApplicationDTO {
        let wrapper: APIWrapper<CandidateApplicationDTO> = try await client.request(
            .GET, path: "/candidate/applications/\(id)"
        )
        return wrapper.data
    }

    func withdrawApplication(id: String) async throws {
        try await client.requestVoid(
            .PATCH, path: "/candidate/applications/\(id)/withdraw"
        )
    }

    // MARK: - Interviews

    func fetchInterviews(status: String? = nil) async throws -> [CandidateInterviewDTO] {
        var q: [URLQueryItem] = []
        if let status, !status.isEmpty { q.append(URLQueryItem(name: "status", value: status)) }
        let wrapper: PaginatedWrapper<CandidateInterviewDTO> = try await client.request(
            .GET, path: "/candidate/interviews", queryItems: q.isEmpty ? nil : q
        )
        return wrapper.data
    }

    func fetchInterview(id: String) async throws -> CandidateInterviewDTO {
        let wrapper: APIWrapper<CandidateInterviewDTO> = try await client.request(
            .GET, path: "/candidate/interviews/\(id)"
        )
        return wrapper.data
    }

    func respondToInterview(id: String, status: String) async throws {
        struct Body: Encodable { let status: String }
        try await client.requestVoid(.PATCH, path: "/candidate/interviews/\(id)/respond", body: Body(status: status))
    }

    // MARK: - Conversations & Messages

    func fetchConversations() async throws -> [ConversationDTO] {
        let wrapper: PaginatedWrapper<ConversationDTO> = try await client.request(
            .GET, path: "/candidate/conversations"
        )
        return wrapper.data
    }

    func fetchMessages(conversationId: String) async throws -> [MessageDTO] {
        let wrapper: PaginatedWrapper<MessageDTO> = try await client.request(
            .GET, path: "/candidate/conversations/\(conversationId)/messages"
        )
        return wrapper.data
    }

    func sendMessage(conversationId: String, body: String) async throws -> MessageDTO {
        struct Body: Encodable { let body: String }
        let wrapper: APIWrapper<MessageDTO> = try await client.request(
            .POST, path: "/candidate/conversations/\(conversationId)/messages",
            body: Body(body: body)
        )
        return wrapper.data
    }

    // MARK: - Profile Update

    @discardableResult
    func updateProfile(name: String? = nil, phone: String? = nil, location: String? = nil, role: String? = nil, experience: String? = nil, languages: String? = nil, latitude: Double? = nil, longitude: Double? = nil, startDate: String? = nil, jobType: String? = nil, bio: String? = nil, availableToRelocate: Bool? = nil) async throws -> CandidateProfileDTO {
        var dict: [String: Any] = [:]
        if let name { dict["name"] = name }
        if let phone { dict["phone"] = phone }
        if let location { dict["location"] = location }
        if let role { dict["role"] = role }
        if let experience { dict["experience"] = experience }
        if let languages { dict["languages"] = languages }
        if let latitude { dict["latitude"] = latitude }
        if let longitude { dict["longitude"] = longitude }
        if let startDate { dict["start_date"] = startDate }
        if let jobType { dict["job_type"] = jobType }
        if let bio { dict["bio"] = bio }
        if let availableToRelocate { dict["available_to_relocate"] = availableToRelocate }

        let wrapper: APIWrapper<CandidateProfileDTO> = try await client.request(
            .PUT, path: "/candidate/profile",
            body: JSONBody(dict)
        )
        return wrapper.data
    }

    // MARK: - Matches

    func updateMatchStatus(matchId: String, status: String) async throws {
        struct Body: Encodable { let status: String }
        try await client.requestVoid(.PATCH, path: "/candidate/matches/\(matchId)/status", body: Body(status: status))
    }

    func fetchMatches(page: Int = 1, limit: Int = 20) async throws -> [FeaturedJobDTO] {
        let wrapper: APIWrapper<[FeaturedJobDTO]> = try await client.request(
            .GET, path: "/candidate/matches",
            queryItems: [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "limit", value: "\(limit)"),
            ]
        )
        return wrapper.data
    }

    // MARK: - Photo Upload

    func uploadPhoto(base64Data: String) async throws -> String {
        struct Body: Encodable { let photo: String }
        struct Resp: Decodable { let photoUrl: String }
        let wrapper: APIWrapper<Resp> = try await client.request(.POST, path: "/candidate/photo", body: Body(photo: base64Data))
        return wrapper.data.photoUrl
    }

    // MARK: - CV Upload

    func uploadCV(base64Data: String, fileName: String) async throws -> String {
        struct Body: Encodable { let cv: String; let fileName: String
            enum CodingKeys: String, CodingKey { case cv; case fileName = "file_name" }
        }
        struct Resp: Decodable { let cvUrl: String }
        let wrapper: APIWrapper<Resp> = try await client.request(
            .POST, path: "/candidate/cv",
            body: Body(cv: base64Data, fileName: fileName)
        )
        return wrapper.data.cvUrl
    }

    // MARK: - CV Parse (AI extraction)

    struct CVExtractedData: Decodable, Identifiable {
        var id: String { "\(firstName ?? "")\(lastName ?? "")\(role ?? "")" }
        let firstName: String?
        let lastName: String?
        let email: String?
        let phone: String?
        let location: String?
        let role: String?
        let roleCategory: String?
        let experience: String?
        let languages: String?
        let skills: String?
        let certifications: String?
        let bio: String?
    }

    struct CVParseResponse: Decodable {
        let extracted: CVExtractedData?
        let rawText: String?
        let parseError: String?
    }

    func parseCV(base64Data: String, fileName: String) async throws -> CVParseResponse {
        struct Body: Encodable { let cv: String; let fileName: String
            enum CodingKeys: String, CodingKey { case cv; case fileName = "file_name" }
        }
        let wrapper: APIWrapper<CVParseResponse> = try await client.request(
            .POST, path: "/candidate/cv/parse",
            body: Body(cv: base64Data, fileName: fileName)
        )
        return wrapper.data
    }

    // MARK: - Welcome Email

    func sendWelcomeEmail() async throws {
        struct Empty: Decodable {}
        let _: APIWrapper<Empty> = try await client.request(
            .POST, path: "/candidate/welcome-email"
        )
    }

    // MARK: - Nearby Jobs

    func fetchNearbyJobs(lat: Double, lng: Double, radius: Double = 10, limit: Int = 30, category: String? = nil) async throws -> [NearbyJobDTO] {
        var q: [URLQueryItem] = [
            URLQueryItem(name: "lat", value: "\(lat)"),
            URLQueryItem(name: "lng", value: "\(lng)"),
            URLQueryItem(name: "radius", value: "\(radius)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        if let category, !category.isEmpty { q.append(URLQueryItem(name: "category", value: category)) }
        let wrapper: PaginatedWrapper<NearbyJobDTO> = try await client.request(
            .GET, path: "/candidate/jobs/nearby", queryItems: q
        )
        return wrapper.data
    }

    func fetchCommunityPosts(page: Int = 1, limit: Int = 20, category: String? = nil) async throws -> [CommunityPostDTO] {
        var q: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        if let category, !category.isEmpty { q.append(URLQueryItem(name: "category", value: category)) }
        let wrapper: PaginatedWrapper<CommunityPostDTO> = try await client.request(
            .GET, path: "/candidate/community", queryItems: q
        )
        return wrapper.data
    }

    // MARK: - Analytics / Tracking

    func recordProfileView(profileId: String, profileType: String) async {
        try? await client.requestVoid(.POST, path: "/analytics/profile-view", body: JSONBody(["profileId": profileId, "profileType": profileType]))
    }

    func recordJobView(jobId: String) async {
        try? await client.requestVoid(.POST, path: "/candidate/jobs/\(jobId)/view")
    }
}
