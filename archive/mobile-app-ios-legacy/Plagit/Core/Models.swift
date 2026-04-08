//
//  Models.swift
//  Plagit
//
//  Data Models
//

import Foundation
import Combine

struct RecommendedJob: Identifiable {
    let id = UUID()
    let jobTitle: String
    let company: String
    let location: String
    let initials: String
    let isVerified: Bool
    let employmentType: String
    let salary: String
    let tag: String
    let avatarHue: Double

    func toJobDetail() -> JobDetail {
        JobDetail(
            jobTitle: jobTitle,
            company: company,
            companyInitials: initials,
            companyAbout: "\(company) is a leading hospitality venue offering exceptional experiences.",
            location: location,
            postedTime: "Recently",
            employmentType: employmentType,
            salary: salary,
            badges: isVerified ? ["Verified Employer"] : [],
            isVerified: isVerified,
            avatarHue: avatarHue,
            description: "Join \(company) as a \(jobTitle). We're looking for talented individuals to deliver world-class hospitality.",
            requirements: ["Relevant experience in hospitality", "Strong communication skills", "Available for flexible shifts"],
            benefits: ["Competitive salary", "Career growth opportunities", "Team meals included"],
            openPositions: 1
        )
    }
}

struct FeedPost: Identifiable {
    let id = UUID()
    let authorName: String
    let authorRole: String
    let authorCountry: String
    let authorInitials: String
    let timeAgo: String
    let title: String
    let body: String
    let likes: Int
    let comments: Int
    let views: Int
    let isVerified: Bool
    let isOnline: Bool
    let avatarHue: Double
    let salary: String
    let badges: [String]
    let primaryCTA: String
    let secondaryCTA: String
    let tertiaryCTA: String
}

enum CommunityCategory: String, CaseIterable {
    case careerTips = "Career Tips"
    case training = "Training"
    case featuredEmployers = "Featured Employers"
    case successStories = "Success Stories"
    case jobHighlights = "Job Highlights"

    var icon: String {
        switch self {
        case .careerTips: return "lightbulb.fill"
        case .training: return "book.fill"
        case .featuredEmployers: return "building.2.fill"
        case .successStories: return "star.fill"
        case .jobHighlights: return "briefcase.fill"
        }
    }
}

struct CommunityPost: Identifiable {
    let id = UUID()
    let category: CommunityCategory
    let title: String
    let body: String
    let authorName: String
    let authorInitials: String
    let authorRole: String
    let avatarHue: Double
    let isVerified: Bool
    let timeAgo: String
    let readTime: String
    let primaryCTA: String
    let secondaryCTA: String
}

struct JobDetail {
    let jobTitle: String
    let company: String
    let companyInitials: String
    let companyAbout: String
    let location: String
    let postedTime: String
    let employmentType: String
    let salary: String
    let badges: [String]
    let isVerified: Bool
    let avatarHue: Double
    let description: String
    let requirements: [String]
    let benefits: [String]
    let openPositions: Int
}

enum ApplicationStatus: String, CaseIterable {
    case applied = "Applied"
    case inReview = "In Review"
    case interview = "Interview"
    case offer = "Offer"
    case closed = "Closed"
}

struct Application: Identifiable {
    let id = UUID()
    let jobTitle: String
    let company: String
    let companyInitials: String
    let location: String
    let salary: String
    let employmentType: String
    let isVerified: Bool
    let avatarHue: Double
    let dateApplied: String
    let status: ApplicationStatus

    func toJobDetail() -> JobDetail {
        JobDetail(
            jobTitle: jobTitle,
            company: company,
            companyInitials: companyInitials,
            companyAbout: "\(company) is a leading hospitality venue.",
            location: location,
            postedTime: dateApplied,
            employmentType: employmentType,
            salary: salary,
            badges: isVerified ? ["Verified Employer"] : [],
            isVerified: isVerified,
            avatarHue: avatarHue,
            description: "Join \(company) as a \(jobTitle).",
            requirements: ["Relevant experience in hospitality"],
            benefits: ["Competitive salary", "Career growth"],
            openPositions: 1
        )
    }
}

struct Conversation: Identifiable {
    let id = UUID()
    let employerName: String
    let employerInitials: String
    let isVerified: Bool
    let avatarHue: Double
    let jobTitle: String
    let lastMessage: String
    let time: String
    let isUnread: Bool
    let isOnline: Bool
}

struct RecommendedCandidate: Identifiable {
    let id = UUID()
    let name: String
    let role: String
    let location: String
    let initials: String
    let isVerified: Bool
    let availability: String
    let avatarHue: Double
}

struct BusinessFeedPost: Identifiable {
    let id = UUID()
    let type: String
    let title: String
    let body: String
    let timeAgo: String
    let icon: String
    let primaryCTA: String
    let secondaryCTA: String
}

enum ApplicantStatus: String, CaseIterable {
    case new = "New"
    case shortlisted = "Shortlisted"
    case interview = "Interview"
    case rejected = "Rejected"
}

struct Applicant: Identifiable {
    let id = UUID()
    let name: String
    let initials: String
    let role: String
    let location: String
    let availability: String
    let experience: String
    let summary: String
    let appliedDate: String
    let matchTag: String
    let isVerified: Bool
    let avatarHue: Double
    var status: ApplicantStatus
}

struct WorkExperience: Identifiable {
    let id = UUID()
    let role: String
    let company: String
    let location: String
    let period: String
    let description: String
}

struct NearbyCandidate: Identifiable {
    let id = UUID()
    let name: String
    let initials: String
    let role: String
    let distance: String
    let distanceKm: Double
    let eta: String
    let experience: String
    let availability: String
    let keySkill: String
    let isVerified: Bool
    let isAvailableNow: Bool
    let avatarHue: Double
}

struct NearbyJob: Identifiable {
    let id = UUID()
    let venueName: String
    let venueInitials: String
    let venueType: String
    let role: String
    let distance: String
    let distanceKm: Double
    let travelTime: String
    let salary: String
    let employmentType: String   // "Full-time" or "Part-time"
    let shiftStart: String
    let isImmediateStart: Bool
    let isVerified: Bool
    let avatarHue: Double
    let latitude: Double
    let longitude: Double

    var category: String {
        let r = role.lowercased()
        if r.contains("chef") || r.contains("cook") || r.contains("pastry") { return "Chef" }
        if r.contains("waiter") || r.contains("waitstaff") || r.contains("host") || r.contains("server") { return "Waiter" }
        if r.contains("bartender") || r.contains("bar staff") || r.contains("barista") || r.contains("sommelier") { return "Bartender" }
        if r.contains("reception") || r.contains("concierge") || r.contains("front desk") { return "Reception" }
        if r.contains("manager") || r.contains("supervisor") || r.contains("director") { return "Manager" }
        return "Waiter"
    }

    func toJobDetail() -> JobDetail {
        JobDetail(
            jobTitle: role,
            company: venueName,
            companyInitials: venueInitials,
            companyAbout: "\(venueName) is a leading \(venueType.lowercased()) offering exceptional hospitality experiences.",
            location: distance,
            postedTime: shiftStart,
            employmentType: employmentType,
            salary: salary,
            badges: isImmediateStart ? ["Immediate Start"] : [],
            isVerified: isVerified,
            avatarHue: avatarHue,
            description: "Join \(venueName) as a \(role). We're looking for talented individuals to deliver world-class hospitality.",
            requirements: ["Relevant experience in hospitality", "Strong communication skills", "Available for flexible shifts"],
            benefits: ["Competitive salary", "Career growth opportunities", "Team meals included"],
            openPositions: 1
        )
    }
}

enum OfferStatus: String, CaseIterable {
    case pending = "Pending"
    case accepted = "Accepted"
    case declined = "Declined"
    case withdrawn = "Withdrawn"
    case expired = "Expired"
}

struct Offer: Identifiable {
    let id = UUID()
    let jobTitle: String
    let company: String
    let companyInitials: String
    let location: String
    let salary: String
    let contractType: String
    let benefits: [String]
    let startDate: String
    let sentDate: String
    var status: OfferStatus
    let avatarHue: Double
    let message: String
}

enum InterviewStatus: String, CaseIterable {
    case scheduled = "Scheduled"
    case confirmed = "Confirmed"
    case completed = "Completed"
    case cancelled = "Cancelled"
}

struct Interview: Identifiable {
    let id = UUID()
    let candidateName: String
    let candidateInitials: String
    let candidateRole: String
    let isVerified: Bool
    let avatarHue: Double
    let jobTitle: String
    let date: String
    let time: String
    let timezone: String
    let interviewType: String
    let status: InterviewStatus
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let time: String
    let isFromRecruiter: Bool
}

struct ChatThread {
    let candidateName: String
    let candidateInitials: String
    let candidateRole: String
    let isVerified: Bool
    let isOnline: Bool
    let avatarHue: Double
    let jobTitle: String
    let jobStatus: String
    let messages: [ChatMessage]
}

struct BusinessConversation: Identifiable {
    let id = UUID()
    let candidateName: String
    let candidateInitials: String
    let candidateRole: String
    let isVerified: Bool
    let avatarHue: Double
    let jobTitle: String
    let lastMessage: String
    let time: String
    let isUnread: Bool
    let isOnline: Bool
}

struct ActiveJob {
    let jobTitle: String
    let company: String
    let companyInitials: String
    let location: String
    let salary: String
    let employmentType: String
    let status: String
    let avatarHue: Double
    let views: Int
    let applicants: Int
    let shortlisted: Int
    let messages: Int
    let description: String
    let requirements: [String]
    let benefits: [String]
    let postedDate: String
    let topCandidates: [RecommendedCandidate]
    let insights: [String]
}

struct CandidateProfile {
    let name: String
    let initials: String
    let role: String
    let location: String
    let availability: String
    let experience: String
    let matchTag: String
    let isVerified: Bool
    let avatarHue: Double
    let bio: String
    let skills: [String]
    let workHistory: [WorkExperience]
    let cvFileName: String
    let cvUpdated: String
}

// MARK: - Hiring State Manager (cross-flow sync)

class HiringStateManager: ObservableObject {
    static let shared = HiringStateManager()
    /// Key format: "CandidateName|JobTitle" e.g. "Elena Rossi|Senior Chef"
    @Published var applicantOverrides: [String: ApplicantStatus] = [:]
    @Published var candidateInterviews: [(candidateName: String, business: String, jobTitle: String, date: String, time: String, type: String)] = []

    private func key(_ candidateName: String, _ jobTitle: String) -> String {
        "\(candidateName)|\(jobTitle)"
    }

    func updateStatus(candidateName: String, jobTitle: String, to status: ApplicantStatus) {
        applicantOverrides[key(candidateName, jobTitle)] = status
        if status == .interview {
            if let idx = candidateInterviews.firstIndex(where: { $0.candidateName == candidateName && $0.jobTitle == jobTitle }) {
                candidateInterviews[idx] = (candidateName: candidateName, business: "Nobu Restaurant", jobTitle: jobTitle, date: "Thu, Mar 27", time: "3:00 PM", type: "Video Call")
            } else {
                candidateInterviews.append((candidateName: candidateName, business: "Nobu Restaurant", jobTitle: jobTitle, date: "Thu, Mar 27", time: "3:00 PM", type: "Video Call"))
            }
        }
    }

    func updateInterview(candidateName: String, jobTitle: String, date: String, time: String, type: String) {
        if let idx = candidateInterviews.firstIndex(where: { $0.candidateName == candidateName && $0.jobTitle == jobTitle }) {
            candidateInterviews[idx] = (candidateName: candidateName, business: candidateInterviews[idx].business, jobTitle: jobTitle, date: date, time: time, type: type)
        } else {
            candidateInterviews.append((candidateName: candidateName, business: "Nobu Restaurant", jobTitle: jobTitle, date: date, time: time, type: type))
        }
    }

    /// Business side: lookup by candidate name + job title
    func statusFor(candidateName: String, jobTitle: String) -> ApplicantStatus? {
        applicantOverrides[key(candidateName, jobTitle)]
    }

    /// Candidate side: the candidate is always "Elena Rossi" in this prototype
    func effectiveStatus(forJob jobTitle: String, at company: String, mock: ApplicationStatus) -> ApplicationStatus {
        // Try matching by candidate name (Elena Rossi) + job title
        if let override = applicantOverrides[key("Elena Rossi", jobTitle)] {
            switch override {
            case .new: return .applied
            case .shortlisted: return .inReview
            case .interview: return .interview
            case .rejected: return .closed
            }
        }
        return mock
    }
}

// MARK: - Sample Data

struct SampleData {
    static let recommendedJobs: [RecommendedJob] = [
        RecommendedJob(
            jobTitle: "Head Chef",
            company: "The Ritz",
            location: "London",
            initials: "TR",
            isVerified: true,
            employmentType: "Full-time",
            salary: "£45–55k",
            tag: "Immediate Start",
            avatarHue: 0.55
        ),
        RecommendedJob(
            jobTitle: "Bar Manager",
            company: "Nobu Dubai",
            location: "Dubai",
            initials: "ND",
            isVerified: true,
            employmentType: "Full-time",
            salary: "$60–75k",
            tag: "Urgent",
            avatarHue: 0.42
        ),
        RecommendedJob(
            jobTitle: "Sommelier",
            company: "Le Cinq",
            location: "Paris",
            initials: "LC",
            isVerified: false,
            employmentType: "Part-time",
            salary: "€35–40k",
            tag: "Visa Support",
            avatarHue: 0.65
        )
    ]

    static let feedPosts: [FeedPost] = [
        FeedPost(
            authorName: "The Grand Hotel",
            authorRole: "Hiring",
            authorCountry: "Stockholm",
            authorInitials: "GH",
            timeAgo: "3h ago",
            title: "Experienced bar staff needed",
            body: "Looking for reliable team members for busy weekend service. Competitive salary and tips.",
            likes: 24,
            comments: 8,
            views: 142,
            isVerified: true,
            isOnline: true,
            avatarHue: 0.48,
            salary: "€3,200/mo",
            badges: ["Urgent", "Immediate Start"],
            primaryCTA: "Apply Now",
            secondaryCTA: "Save",
            tertiaryCTA: "Message"
        ),
        FeedPost(
            authorName: "Nobu Restaurant",
            authorRole: "Hiring",
            authorCountry: "Dubai",
            authorInitials: "NR",
            timeAgo: "1h ago",
            title: "Senior Chef – Private dining and events",
            body: "Join our world-class team. 3+ years experience required. Premium benefits package.",
            likes: 56,
            comments: 12,
            views: 318,
            isVerified: true,
            isOnline: false,
            avatarHue: 0.55,
            salary: "$5,500/mo",
            badges: ["Visa Support", "Top Match"],
            primaryCTA: "Apply Now",
            secondaryCTA: "Save",
            tertiaryCTA: "Details"
        )
    ]

    static let communityPosts: [CommunityPost] = [
        CommunityPost(
            category: .careerTips,
            title: "5 Things Recruiters Notice First on Your CV",
            body: "Your CV is your first impression. Here's what hiring managers in hospitality look at before anything else — and how to make yours stand out.",
            authorName: "Plagit Team",
            authorInitials: "PT",
            authorRole: "Career Advice",
            avatarHue: 0.50,
            isVerified: true,
            timeAgo: "2h ago",
            readTime: "3 min read",
            primaryCTA: "Read",
            secondaryCTA: "Save"
        ),
        CommunityPost(
            category: .featuredEmployers,
            title: "Nobu Restaurant — Now Hiring in Dubai",
            body: "World-renowned Japanese cuisine meets premium hospitality. Nobu Dubai is expanding their team with 8 new positions across kitchen, front-of-house, and management.",
            authorName: "Nobu Restaurant",
            authorInitials: "NR",
            authorRole: "Featured Employer",
            avatarHue: 0.55,
            isVerified: true,
            timeAgo: "4h ago",
            readTime: "2 min read",
            primaryCTA: "View Jobs",
            secondaryCTA: "Follow"
        ),
        CommunityPost(
            category: .successStories,
            title: "From Line Cook to Executive Chef in 3 Years",
            body: "Elena Rossi shares how she went from a line cook at a small bistro to running the kitchen at a Michelin-starred restaurant — and the one decision that changed everything.",
            authorName: "Elena Rossi",
            authorInitials: "ER",
            authorRole: "Executive Chef",
            avatarHue: 0.52,
            isVerified: true,
            timeAgo: "1d ago",
            readTime: "5 min read",
            primaryCTA: "Read More",
            secondaryCTA: "Share"
        ),
        CommunityPost(
            category: .training,
            title: "Free Food Safety Certification — Level 2",
            body: "Boost your profile with an accredited food safety certificate. This free online course takes just 4 hours and is recognised by employers across the UK and UAE.",
            authorName: "Plagit Learning",
            authorInitials: "PL",
            authorRole: "Training",
            avatarHue: 0.62,
            isVerified: true,
            timeAgo: "6h ago",
            readTime: "1 min read",
            primaryCTA: "Learn More",
            secondaryCTA: "Save"
        ),
        CommunityPost(
            category: .careerTips,
            title: "How to Negotiate Your Salary in Hospitality",
            body: "Most candidates accept the first offer. Learn the proven framework top hospitality professionals use to negotiate 15-20% more — without burning bridges.",
            authorName: "Plagit Team",
            authorInitials: "PT",
            authorRole: "Career Advice",
            avatarHue: 0.50,
            isVerified: true,
            timeAgo: "8h ago",
            readTime: "4 min read",
            primaryCTA: "Read",
            secondaryCTA: "Save"
        ),
        CommunityPost(
            category: .featuredEmployers,
            title: "The Ritz London — Premium Hiring Event",
            body: "The Ritz is hosting an exclusive hiring day for experienced front-of-house staff. Walk-in interviews available. Competitive packages with accommodation support.",
            authorName: "The Ritz London",
            authorInitials: "TR",
            authorRole: "Featured Employer",
            avatarHue: 0.68,
            isVerified: true,
            timeAgo: "12h ago",
            readTime: "2 min read",
            primaryCTA: "View Jobs",
            secondaryCTA: "Follow"
        ),
        CommunityPost(
            category: .careerTips,
            title: "What to Wear to a Hospitality Interview",
            body: "First impressions matter. Here's a quick guide to dressing right for interviews at restaurants, hotels, and bars — from fine dining to casual venues.",
            authorName: "Plagit Team",
            authorInitials: "PT",
            authorRole: "Career Advice",
            avatarHue: 0.50,
            isVerified: true,
            timeAgo: "1d ago",
            readTime: "2 min read",
            primaryCTA: "Read",
            secondaryCTA: "Save"
        ),
        CommunityPost(
            category: .training,
            title: "WSET Level 1 — Wine Fundamentals",
            body: "Stand out as a sommelier or waiter with an internationally recognised wine qualification. Flexible online learning with exam at your own pace.",
            authorName: "Plagit Learning",
            authorInitials: "PL",
            authorRole: "Training",
            avatarHue: 0.62,
            isVerified: true,
            timeAgo: "2d ago",
            readTime: "1 min read",
            primaryCTA: "Learn More",
            secondaryCTA: "Save"
        ),
        CommunityPost(
            category: .successStories,
            title: "How I Landed My Dream Job at The Dorchester",
            body: "James Park moved from Seoul to London with no contacts. Within 6 months he was managing the bar at one of London's most iconic hotels. Here's his advice.",
            authorName: "James Park",
            authorInitials: "JP",
            authorRole: "Bar Manager",
            avatarHue: 0.38,
            isVerified: false,
            timeAgo: "3d ago",
            readTime: "4 min read",
            primaryCTA: "Read More",
            secondaryCTA: "Share"
        ),
        CommunityPost(
            category: .careerTips,
            title: "The Hidden Job Market in Hospitality",
            body: "Up to 60% of hospitality roles are filled before they're ever posted online. Learn how to tap into referral networks and get ahead of the competition.",
            authorName: "Plagit Team",
            authorInitials: "PT",
            authorRole: "Career Advice",
            avatarHue: 0.50,
            isVerified: true,
            timeAgo: "3d ago",
            readTime: "3 min read",
            primaryCTA: "Read",
            secondaryCTA: "Save"
        ),
        CommunityPost(
            category: .jobHighlights,
            title: "Senior Chef — Nobu Dubai (Immediate Start)",
            body: "Premium package including visa sponsorship, accommodation, and career progression. 3+ years fine dining experience required. Apply before positions fill.",
            authorName: "Nobu Restaurant",
            authorInitials: "NR",
            authorRole: "Featured Job",
            avatarHue: 0.55,
            isVerified: true,
            timeAgo: "5h ago",
            readTime: "1 min read",
            primaryCTA: "View Job",
            secondaryCTA: "Save"
        ),
        CommunityPost(
            category: .jobHighlights,
            title: "Bartender — The Ritz London (Premium Tips)",
            body: "Join one of London's most iconic hotels. Competitive hourly rate plus exceptional tips. Ideal for experienced bartenders with cocktail expertise.",
            authorName: "The Ritz London",
            authorInitials: "TR",
            authorRole: "Featured Job",
            avatarHue: 0.68,
            isVerified: true,
            timeAgo: "1d ago",
            readTime: "1 min read",
            primaryCTA: "View Job",
            secondaryCTA: "Save"
        )
    ]

    static let sampleJobDetail = JobDetail(
        jobTitle: "Senior Chef",
        company: "Nobu Restaurant",
        companyInitials: "NR",
        companyAbout: "Nobu is a world-renowned Japanese restaurant chain with locations in over 40 cities. We are committed to excellence in hospitality and creating unforgettable dining experiences.",
        location: "Dubai, UAE",
        postedTime: "2 days ago",
        employmentType: "Full-time",
        salary: "$5,500/mo",
        badges: ["Visa Support", "Immediate Start"],
        isVerified: true,
        avatarHue: 0.55,
        description: "We are looking for a talented and passionate Senior Chef to join our Dubai team. You will lead kitchen operations for private dining and premium events, working closely with our executive team to deliver world-class culinary experiences.\n\nThis is a unique opportunity to work in one of the most exciting hospitality markets in the world, with a brand that values creativity, precision, and excellence.",
        requirements: [
            "3+ years of experience in fine dining or luxury hospitality",
            "Strong background in Japanese or fusion cuisine",
            "Fluent in English, additional languages a plus",
            "Available for weekends and evening shifts",
            "Food safety certification required",
            "Team leadership experience preferred"
        ],
        benefits: [
            "Visa sponsorship and relocation support",
            "Staff accommodation provided",
            "Daily meals included during shifts",
            "Competitive salary with performance bonuses",
            "Career growth within a global brand",
            "Health insurance coverage"
        ],
        openPositions: 3
    )

    static let applications: [Application] = [
        Application(
            jobTitle: "Senior Chef",
            company: "Nobu Restaurant",
            companyInitials: "NR",
            location: "Dubai, UAE",
            salary: "$5,500/mo",
            employmentType: "Full-time",
            isVerified: true,
            avatarHue: 0.55,
            dateApplied: "Mar 22, 2026",
            status: .applied
        ),
        Application(
            jobTitle: "Head Chef",
            company: "The Ritz",
            companyInitials: "TR",
            location: "London, UK",
            salary: "£45–55k",
            employmentType: "Full-time",
            isVerified: true,
            avatarHue: 0.48,
            dateApplied: "Mar 20, 2026",
            status: .inReview
        ),
        Application(
            jobTitle: "Bar Manager",
            company: "Nobu Dubai",
            companyInitials: "ND",
            location: "Dubai, UAE",
            salary: "$60–75k",
            employmentType: "Full-time",
            isVerified: true,
            avatarHue: 0.42,
            dateApplied: "Mar 18, 2026",
            status: .interview
        ),
        Application(
            jobTitle: "Sous Chef",
            company: "Four Seasons",
            companyInitials: "FS",
            location: "Paris, FR",
            salary: "€3,800/mo",
            employmentType: "Full-time",
            isVerified: true,
            avatarHue: 0.60,
            dateApplied: "Mar 15, 2026",
            status: .applied
        ),
        Application(
            jobTitle: "Sommelier",
            company: "Le Cinq",
            companyInitials: "LC",
            location: "Paris, FR",
            salary: "€35–40k",
            employmentType: "Part-time",
            isVerified: false,
            avatarHue: 0.65,
            dateApplied: "Mar 10, 2026",
            status: .closed
        )
    ]

    static let conversations: [Conversation] = [
        Conversation(
            employerName: "Nobu Restaurant",
            employerInitials: "NR",
            isVerified: true,
            avatarHue: 0.55,
            jobTitle: "Senior Chef",
            lastMessage: "Hi Mirko, we'd love to schedule an interview with you this week.",
            time: "2m ago",
            isUnread: true,
            isOnline: true
        ),
        Conversation(
            employerName: "The Grand Hotel",
            employerInitials: "GH",
            isVerified: true,
            avatarHue: 0.48,
            jobTitle: "Bar Staff",
            lastMessage: "Thank you for your application. We are currently reviewing candidates.",
            time: "1h ago",
            isUnread: true,
            isOnline: false
        ),
        Conversation(
            employerName: "The Ritz",
            employerInitials: "TR",
            isVerified: true,
            avatarHue: 0.42,
            jobTitle: "Head Chef",
            lastMessage: "Your profile looks great. Can you share your availability?",
            time: "Yesterday",
            isUnread: false,
            isOnline: true
        ),
        Conversation(
            employerName: "Four Seasons",
            employerInitials: "FS",
            isVerified: true,
            avatarHue: 0.60,
            jobTitle: "Sous Chef",
            lastMessage: "We received your CV. We'll be in touch shortly.",
            time: "Mar 20",
            isUnread: false,
            isOnline: false
        ),
        Conversation(
            employerName: "Le Cinq",
            employerInitials: "LC",
            isVerified: false,
            avatarHue: 0.65,
            jobTitle: "Sommelier",
            lastMessage: "Thanks for applying! Unfortunately the position has been filled.",
            time: "Mar 15",
            isUnread: false,
            isOnline: false
        )
    ]

    // MARK: - Business Sample Data

    static let recommendedCandidates: [RecommendedCandidate] = [
        RecommendedCandidate(
            name: "Elena Rossi",
            role: "Executive Chef",
            location: "Milan",
            initials: "ER",
            isVerified: true,
            availability: "Immediate",
            avatarHue: 0.52
        ),
        RecommendedCandidate(
            name: "James Park",
            role: "Bar Manager",
            location: "London",
            initials: "JP",
            isVerified: false,
            availability: "2 weeks",
            avatarHue: 0.38
        ),
        RecommendedCandidate(
            name: "Sofia Blanc",
            role: "Sommelier",
            location: "Paris",
            initials: "SB",
            isVerified: true,
            availability: "Immediate",
            avatarHue: 0.62
        )
    ]

    static let businessFeed: [BusinessFeedPost] = [
        BusinessFeedPost(
            type: "New Applicant",
            title: "Elena Rossi applied for Senior Chef",
            body: "15 years experience in fine dining. Previously at The Dorchester and Nobu Milan. Available immediately.",
            timeAgo: "1h ago",
            icon: "person.crop.circle.badge.plus",
            primaryCTA: "Review",
            secondaryCTA: "Message"
        ),
        BusinessFeedPost(
            type: "Job Update",
            title: "Your 'Bar Manager' posting is trending",
            body: "28 views and 6 applicants in the last 24 hours. Consider boosting to reach more candidates.",
            timeAgo: "3h ago",
            icon: "chart.line.uptrend.xyaxis",
            primaryCTA: "View Stats",
            secondaryCTA: "Boost"
        ),
        BusinessFeedPost(
            type: "Candidate Match",
            title: "3 new candidates match your requirements",
            body: "Based on your active job postings, we found strong matches in Dubai and London.",
            timeAgo: "5h ago",
            icon: "sparkles",
            primaryCTA: "View Matches",
            secondaryCTA: "Dismiss"
        )
    ]

    static let applicants: [Applicant] = [
        Applicant(
            name: "Elena Rossi",
            initials: "ER",
            role: "Executive Chef",
            location: "Milan, IT",
            availability: "Available immediately",
            experience: "15 years experience",
            summary: "Michelin-starred chef with expertise in Italian fine dining and fusion cuisine. Previously at The Dorchester.",
            appliedDate: "Mar 22",
            matchTag: "Top Match",
            isVerified: true,
            avatarHue: 0.52,
            status: .new
        ),
        Applicant(
            name: "James Park",
            initials: "JP",
            role: "Bar Manager",
            location: "London, UK",
            availability: "Available in 2 weeks",
            experience: "8 years experience",
            summary: "Award-winning mixologist and bar operations leader. Strong team management background.",
            appliedDate: "Mar 21",
            matchTag: "Strong Match",
            isVerified: false,
            avatarHue: 0.38,
            status: .new
        ),
        Applicant(
            name: "Sofia Blanc",
            initials: "SB",
            role: "Sommelier",
            location: "Paris, FR",
            availability: "Available immediately",
            experience: "6 years experience",
            summary: "WSET Level 3 certified sommelier with luxury hotel experience. Fluent in 3 languages.",
            appliedDate: "Mar 20",
            matchTag: "Available Now",
            isVerified: true,
            avatarHue: 0.62,
            status: .shortlisted
        ),
        Applicant(
            name: "Marco Bianchi",
            initials: "MB",
            role: "Sous Chef",
            location: "Dubai, UAE",
            availability: "Available in 1 month",
            experience: "10 years experience",
            summary: "Specialized in Japanese and Mediterranean fusion. Current role at a 5-star resort.",
            appliedDate: "Mar 19",
            matchTag: "Strong Match",
            isVerified: true,
            avatarHue: 0.45,
            status: .shortlisted
        ),
        Applicant(
            name: "Anna Weber",
            initials: "AW",
            role: "Restaurant Manager",
            location: "Berlin, DE",
            availability: "Available immediately",
            experience: "12 years experience",
            summary: "Experienced in opening and scaling high-volume restaurants across Europe.",
            appliedDate: "Mar 18",
            matchTag: "Top Match",
            isVerified: true,
            avatarHue: 0.58,
            status: .interview
        ),
        Applicant(
            name: "Tom Chen",
            initials: "TC",
            role: "Line Cook",
            location: "Sydney, AU",
            availability: "Available in 3 weeks",
            experience: "3 years experience",
            summary: "Culinary school graduate with passion for Asian cuisine and fast-paced environments.",
            appliedDate: "Mar 15",
            matchTag: "",
            isVerified: false,
            avatarHue: 0.35,
            status: .rejected
        )
    ]

    static let sampleOffer = Offer(
        jobTitle: "Senior Chef",
        company: "Nobu Restaurant",
        companyInitials: "NR",
        location: "Dubai, UAE",
        salary: "$5,500/mo",
        contractType: "Full-time",
        benefits: ["Visa sponsorship", "Staff accommodation", "Daily meals", "Health insurance", "Performance bonuses", "Career growth"],
        startDate: "Apr 15, 2026",
        sentDate: "Mar 25, 2026",
        status: .pending,
        avatarHue: 0.55,
        message: "Dear Elena, we are pleased to offer you the position of Senior Chef at Nobu Restaurant Dubai. We were impressed by your experience and passion for Japanese fusion cuisine. We look forward to welcoming you to our team."
    )

    static let sampleCandidateProfile = CandidateProfile(
        name: "Elena Rossi",
        initials: "ER",
        role: "Executive Chef",
        location: "Milan, Italy",
        availability: "Available immediately",
        experience: "15 years experience",
        matchTag: "Top Match",
        isVerified: true,
        avatarHue: 0.52,
        bio: "Passionate and detail-driven Executive Chef with 15 years of experience in Michelin-starred fine dining. Specialized in Italian and fusion cuisine with a focus on seasonal, locally-sourced ingredients.\n\nI thrive in high-pressure environments and bring a strong leadership style rooted in mentorship and precision. Open to international relocation.",
        skills: [
            "Fine Dining",
            "Italian Cuisine",
            "Fusion & Innovation",
            "Kitchen Leadership",
            "Menu Development",
            "Guest Experience",
            "Michelin Standards",
            "Food Safety (HACCP)",
            "Team Training",
            "Cost Control"
        ],
        workHistory: [
            WorkExperience(
                role: "Executive Chef",
                company: "The Dorchester",
                location: "London, UK",
                period: "2020 – Present",
                description: "Leading a team of 24 across two restaurants. Achieved 1 Michelin star within 18 months of appointment."
            ),
            WorkExperience(
                role: "Head Chef",
                company: "Ristorante Cracco",
                location: "Milan, IT",
                period: "2016 – 2020",
                description: "Oversaw daily kitchen operations for a 2-star Michelin restaurant. Developed seasonal tasting menus."
            ),
            WorkExperience(
                role: "Sous Chef",
                company: "Four Seasons Hotel",
                location: "Florence, IT",
                period: "2012 – 2016",
                description: "Managed evening service for the hotel's signature Italian restaurant. Trained junior kitchen staff."
            )
        ],
        cvFileName: "Elena_Rossi_CV.pdf",
        cvUpdated: "Updated 1 week ago"
    )

    static let sampleActiveJob = ActiveJob(
        jobTitle: "Senior Chef",
        company: "Nobu Restaurant",
        companyInitials: "NR",
        location: "Dubai, UAE",
        salary: "$5,500/mo",
        employmentType: "Full-time",
        status: "Active",
        avatarHue: 0.55,
        views: 342,
        applicants: 12,
        shortlisted: 4,
        messages: 8,
        description: "We are looking for a talented and passionate Senior Chef to join our Dubai team. You will lead kitchen operations for private dining and premium events.",
        requirements: [
            "3+ years in fine dining or luxury hospitality",
            "Strong background in Japanese or fusion cuisine",
            "Fluent in English",
            "Available for weekends and evening shifts",
            "Food safety certification required"
        ],
        benefits: [
            "Visa sponsorship and relocation support",
            "Staff accommodation provided",
            "Daily meals included during shifts",
            "Competitive salary with performance bonuses",
            "Health insurance coverage"
        ],
        postedDate: "Posted Mar 18, 2026",
        topCandidates: [
            RecommendedCandidate(name: "Elena Rossi", role: "Executive Chef", location: "Milan", initials: "ER", isVerified: true, availability: "Immediate", avatarHue: 0.52),
            RecommendedCandidate(name: "James Park", role: "Head Chef", location: "London", initials: "JP", isVerified: false, availability: "2 weeks", avatarHue: 0.38),
            RecommendedCandidate(name: "Sofia Blanc", role: "Sous Chef", location: "Paris", initials: "SB", isVerified: true, availability: "Immediate", avatarHue: 0.62)
        ],
        insights: [
            "Your job is trending — 28% more views than similar roles",
            "3 new candidates matched your requirements today",
            "Response rate is high — 92% of messages answered"
        ]
    )

    static let businessJobs: [ActiveJob] = [
        sampleActiveJob,
        ActiveJob(jobTitle: "Bar Manager", company: "Nobu Restaurant", companyInitials: "NR", location: "Dubai, UAE", salary: "AED 18,000/mo", employmentType: "Full-time", status: "Active", avatarHue: 0.55, views: 34, applicants: 6, shortlisted: 2, messages: 3, description: "We are looking for an experienced Bar Manager to lead our cocktail bar team.", requirements: ["5+ years in bar management", "Mixology certification", "Team leadership"], benefits: ["Staff meals", "Health insurance", "Annual bonus"], postedDate: "Mar 20, 2026", topCandidates: [], insights: ["Strong interest from local candidates"]),
        ActiveJob(jobTitle: "Sommelier", company: "Nobu Restaurant", companyInitials: "NR", location: "Dubai, UAE", salary: "AED 15,000/mo", employmentType: "Full-time", status: "Paused", avatarHue: 0.55, views: 18, applicants: 4, shortlisted: 1, messages: 2, description: "Seeking a certified Sommelier for our fine dining restaurant.", requirements: ["WSET Level 3+", "3+ years experience", "English fluent"], benefits: ["Staff accommodation", "Training budget"], postedDate: "Mar 15, 2026", topCandidates: [], insights: ["Low response — consider boosting"]),
        ActiveJob(jobTitle: "Waitstaff", company: "Nobu Restaurant", companyInitials: "NR", location: "Dubai, UAE", salary: "AED 8,000/mo", employmentType: "Part-time", status: "Active", avatarHue: 0.55, views: 56, applicants: 0, shortlisted: 0, messages: 0, description: "Looking for professional waitstaff for our premium dining service.", requirements: ["Hospitality experience", "Presentable", "Weekend availability"], benefits: ["Tips included", "Staff meals"], postedDate: "Mar 24, 2026", topCandidates: [], insights: ["No applicants yet — consider sharing"]),
        ActiveJob(jobTitle: "Sous Chef", company: "Nobu Restaurant", companyInitials: "NR", location: "Dubai, UAE", salary: "AED 12,000/mo", employmentType: "Full-time", status: "Closed", avatarHue: 0.55, views: 89, applicants: 15, shortlisted: 4, messages: 8, description: "This position has been filled.", requirements: [], benefits: [], postedDate: "Feb 28, 2026", topCandidates: [], insights: [])
    ]

    static let businessConversations: [BusinessConversation] = [
        BusinessConversation(
            candidateName: "Elena Rossi",
            candidateInitials: "ER",
            candidateRole: "Executive Chef",
            isVerified: true,
            avatarHue: 0.52,
            jobTitle: "Senior Chef",
            lastMessage: "Thank you for considering me. I'm available for an interview anytime this week.",
            time: "5m ago",
            isUnread: true,
            isOnline: true
        ),
        BusinessConversation(
            candidateName: "James Park",
            candidateInitials: "JP",
            candidateRole: "Bar Manager",
            isVerified: false,
            avatarHue: 0.38,
            jobTitle: "Bar Manager",
            lastMessage: "I've attached my updated references as requested. Looking forward to hearing from you.",
            time: "2h ago",
            isUnread: true,
            isOnline: false
        ),
        BusinessConversation(
            candidateName: "Sofia Blanc",
            candidateInitials: "SB",
            candidateRole: "Sommelier",
            isVerified: true,
            avatarHue: 0.62,
            jobTitle: "Senior Chef",
            lastMessage: "Yes, I can start immediately. My notice period ended last week.",
            time: "Yesterday",
            isUnread: false,
            isOnline: true
        ),
        BusinessConversation(
            candidateName: "Marco Bianchi",
            candidateInitials: "MB",
            candidateRole: "Sous Chef",
            isVerified: true,
            avatarHue: 0.45,
            jobTitle: "Senior Chef",
            lastMessage: "I would need visa sponsorship. Is that something you offer?",
            time: "Mar 21",
            isUnread: false,
            isOnline: false
        ),
        BusinessConversation(
            candidateName: "Anna Weber",
            candidateInitials: "AW",
            candidateRole: "Restaurant Manager",
            isVerified: true,
            avatarHue: 0.58,
            jobTitle: "Bar Manager",
            lastMessage: "Thanks for the update. I'll prepare for the second round interview.",
            time: "Mar 19",
            isUnread: false,
            isOnline: false
        )
    ]

    static let sampleChatThread = ChatThread(
        candidateName: "Elena Rossi",
        candidateInitials: "ER",
        candidateRole: "Executive Chef",
        isVerified: true,
        isOnline: true,
        avatarHue: 0.52,
        jobTitle: "Senior Chef",
        jobStatus: "Interviewing",
        messages: [
            ChatMessage(text: "Hi Elena, thank you for applying to the Senior Chef position at Nobu Dubai. Your profile looks very impressive.", time: "10:15 AM", isFromRecruiter: true),
            ChatMessage(text: "Thank you so much! I'm very excited about this opportunity. Nobu has always been a dream workplace for me.", time: "10:22 AM", isFromRecruiter: false),
            ChatMessage(text: "We'd love to schedule an interview with you. Are you available this week for a video call?", time: "10:30 AM", isFromRecruiter: true),
            ChatMessage(text: "Absolutely! I'm available Wednesday or Thursday afternoon, Dubai time. Would either work for your team?", time: "10:45 AM", isFromRecruiter: false),
            ChatMessage(text: "Wednesday at 3pm Dubai time works perfectly. I'll send you the meeting link shortly.", time: "11:00 AM", isFromRecruiter: true),
            ChatMessage(text: "Perfect, I'll be ready. Should I prepare anything specific for the interview?", time: "11:08 AM", isFromRecruiter: false),
            ChatMessage(text: "Please prepare a brief overview of your signature dishes and your approach to kitchen management. We're also interested in your experience with Japanese fusion.", time: "11:15 AM", isFromRecruiter: true),
            ChatMessage(text: "Thank you for considering me. I'm available for an interview anytime this week.", time: "11:30 AM", isFromRecruiter: false)
        ]
    )

    static let interviews: [Interview] = [
        Interview(
            candidateName: "Elena Rossi",
            candidateInitials: "ER",
            candidateRole: "Executive Chef",
            isVerified: true,
            avatarHue: 0.52,
            jobTitle: "Senior Chef",
            date: "Wed, Mar 26",
            time: "3:00 PM",
            timezone: "GST",
            interviewType: "Video Call",
            status: .confirmed
        ),
        Interview(
            candidateName: "James Park",
            candidateInitials: "JP",
            candidateRole: "Bar Manager",
            isVerified: false,
            avatarHue: 0.38,
            jobTitle: "Bar Manager",
            date: "Thu, Mar 27",
            time: "10:00 AM",
            timezone: "GST",
            interviewType: "Phone",
            status: .scheduled
        ),
        Interview(
            candidateName: "Anna Weber",
            candidateInitials: "AW",
            candidateRole: "Restaurant Manager",
            isVerified: true,
            avatarHue: 0.58,
            jobTitle: "Senior Chef",
            date: "Mon, Mar 24",
            time: "2:00 PM",
            timezone: "GST",
            interviewType: "Video Call",
            status: .confirmed
        ),
        Interview(
            candidateName: "Sofia Blanc",
            candidateInitials: "SB",
            candidateRole: "Sommelier",
            isVerified: true,
            avatarHue: 0.62,
            jobTitle: "Senior Chef",
            date: "Fri, Mar 21",
            time: "11:00 AM",
            timezone: "CET",
            interviewType: "In Person",
            status: .completed
        ),
        Interview(
            candidateName: "Tom Chen",
            candidateInitials: "TC",
            candidateRole: "Line Cook",
            isVerified: false,
            avatarHue: 0.35,
            jobTitle: "Senior Chef",
            date: "Wed, Mar 19",
            time: "4:00 PM",
            timezone: "AEST",
            interviewType: "Video Call",
            status: .cancelled
        )
    ]

    static let nearbyJobs: [NearbyJob] = [
        NearbyJob(
            venueName: "Dishoom Soho",
            venueInitials: "DS",
            venueType: "Restaurant",
            role: "Bar Staff Needed",
            distance: "0.4 km",
            distanceKm: 0.4,
            travelTime: "5 min walk",
            salary: "£14/hr",
            employmentType: "Part-time",
            shiftStart: "Today 6 PM",
            isImmediateStart: true,
            isVerified: true,
            avatarHue: 0.55,
            latitude: 51.5135,
            longitude: -0.1345
        ),
        NearbyJob(
            venueName: "The Savoy",
            venueInitials: "TS",
            venueType: "Hotel",
            role: "Breakfast Chef",
            distance: "1.8 km",
            distanceKm: 1.8,
            travelTime: "8 min walk",
            salary: "£16/hr",
            employmentType: "Part-time",
            shiftStart: "Tomorrow 6 AM",
            isImmediateStart: false,
            isVerified: true,
            avatarHue: 0.42,
            latitude: 51.5105,
            longitude: -0.1195
        ),
        NearbyJob(
            venueName: "Nobu London",
            venueInitials: "NL",
            venueType: "Restaurant",
            role: "Waitstaff",
            distance: "2.1 km",
            distanceKm: 2.1,
            travelTime: "10 min walk",
            salary: "£13/hr + tips",
            employmentType: "Part-time",
            shiftStart: "Today 12 PM",
            isImmediateStart: true,
            isVerified: true,
            avatarHue: 0.48,
            latitude: 51.5030,
            longitude: -0.1520
        ),
        NearbyJob(
            venueName: "Fabric",
            venueInitials: "FB",
            venueType: "Club",
            role: "Bartender",
            distance: "3.5 km",
            distanceKm: 3.5,
            travelTime: "12 min tube",
            salary: "£15/hr + tips",
            employmentType: "Part-time",
            shiftStart: "Fri 10 PM",
            isImmediateStart: false,
            isVerified: false,
            avatarHue: 0.35,
            latitude: 51.5200,
            longitude: -0.1025
        ),
        NearbyJob(
            venueName: "The Dorchester",
            venueInitials: "TD",
            venueType: "Hotel",
            role: "Sous Chef",
            distance: "4.2 km",
            distanceKm: 4.2,
            travelTime: "15 min tube",
            salary: "£3,800/mo",
            employmentType: "Full-time",
            shiftStart: "Next Week",
            isImmediateStart: false,
            isVerified: true,
            avatarHue: 0.62,
            latitude: 51.5070,
            longitude: -0.1580
        ),
        NearbyJob(
            venueName: "Sketch London",
            venueInitials: "SK",
            venueType: "Restaurant",
            role: "Host / Hostess",
            distance: "1.1 km",
            distanceKm: 1.1,
            travelTime: "6 min walk",
            salary: "£12/hr",
            employmentType: "Part-time",
            shiftStart: "Today 11 AM",
            isImmediateStart: true,
            isVerified: true,
            avatarHue: 0.58,
            latitude: 51.5145,
            longitude: -0.1420
        ),
        NearbyJob(
            venueName: "The Ritz",
            venueInitials: "TR",
            venueType: "Hotel",
            role: "Reception Manager",
            distance: "0.8 km",
            distanceKm: 0.8,
            travelTime: "4 min walk",
            salary: "£4,200/mo",
            employmentType: "Full-time",
            shiftStart: "Monday",
            isImmediateStart: false,
            isVerified: true,
            avatarHue: 0.68,
            latitude: 51.5075,
            longitude: -0.1415
        ),
        NearbyJob(
            venueName: "Hakkasan Mayfair",
            venueInitials: "HM",
            venueType: "Restaurant",
            role: "Head Chef",
            distance: "1.4 km",
            distanceKm: 1.4,
            travelTime: "7 min walk",
            salary: "£5,500/mo",
            employmentType: "Full-time",
            shiftStart: "In 2 Weeks",
            isImmediateStart: false,
            isVerified: true,
            avatarHue: 0.30,
            latitude: 51.5120,
            longitude: -0.1480
        ),
        NearbyJob(
            venueName: "Claridge's",
            venueInitials: "CL",
            venueType: "Hotel",
            role: "Front Desk Concierge",
            distance: "2.8 km",
            distanceKm: 2.8,
            travelTime: "12 min walk",
            salary: "£14/hr",
            employmentType: "Part-time",
            shiftStart: "Tomorrow 7 AM",
            isImmediateStart: false,
            isVerified: true,
            avatarHue: 0.72,
            latitude: 51.5125,
            longitude: -0.1500
        ),
        NearbyJob(
            venueName: "Hawksmoor Seven Dials",
            venueInitials: "HS",
            venueType: "Restaurant",
            role: "Line Cook",
            distance: "0.6 km",
            distanceKm: 0.6,
            travelTime: "3 min walk",
            salary: "£13/hr",
            employmentType: "Part-time",
            shiftStart: "Today 5 PM",
            isImmediateStart: true,
            isVerified: false,
            avatarHue: 0.22,
            latitude: 51.5140,
            longitude: -0.1265
        ),
        NearbyJob(
            venueName: "Chiltern Firehouse",
            venueInitials: "CF",
            venueType: "Restaurant",
            role: "Restaurant Manager",
            distance: "5.1 km",
            distanceKm: 5.1,
            travelTime: "18 min tube",
            salary: "£4,800/mo",
            employmentType: "Full-time",
            shiftStart: "Next Week",
            isImmediateStart: false,
            isVerified: true,
            avatarHue: 0.15,
            latitude: 51.5195,
            longitude: -0.1535
        ),
        NearbyJob(
            venueName: "The Ivy",
            venueInitials: "TI",
            venueType: "Restaurant",
            role: "Senior Waiter",
            distance: "3.9 km",
            distanceKm: 3.9,
            travelTime: "14 min tube",
            salary: "£14/hr + tips",
            employmentType: "Part-time",
            shiftStart: "Tomorrow 11 AM",
            isImmediateStart: false,
            isVerified: true,
            avatarHue: 0.40,
            latitude: 51.5115,
            longitude: -0.1280
        ),
        NearbyJob(
            venueName: "Scarfes Bar",
            venueInitials: "SB",
            venueType: "Bar",
            role: "Sommelier",
            distance: "6.3 km",
            distanceKm: 6.3,
            travelTime: "20 min tube",
            salary: "£16/hr",
            employmentType: "Full-time",
            shiftStart: "Wed 6 PM",
            isImmediateStart: false,
            isVerified: true,
            avatarHue: 0.78,
            latitude: 51.5175,
            longitude: -0.1180
        ),
        NearbyJob(
            venueName: "Mandarin Oriental",
            venueInitials: "MO",
            venueType: "Hotel",
            role: "Pastry Chef",
            distance: "8.5 km",
            distanceKm: 8.5,
            travelTime: "25 min tube",
            salary: "£18/hr",
            employmentType: "Full-time",
            shiftStart: "Next Week",
            isImmediateStart: false,
            isVerified: true,
            avatarHue: 0.52,
            latitude: 51.5023,
            longitude: -0.1610
        ),
        NearbyJob(
            venueName: "Sexy Fish",
            venueInitials: "SF",
            venueType: "Restaurant",
            role: "Bartender",
            distance: "12.0 km",
            distanceKm: 12.0,
            travelTime: "35 min tube",
            salary: "£15/hr + tips",
            employmentType: "Part-time",
            shiftStart: "Sat 8 PM",
            isImmediateStart: false,
            isVerified: false,
            avatarHue: 0.25,
            latitude: 51.5085,
            longitude: -0.1465
        ),
        NearbyJob(
            venueName: "The Ned",
            venueInitials: "TN",
            venueType: "Hotel",
            role: "Night Reception",
            distance: "15.2 km",
            distanceKm: 15.2,
            travelTime: "40 min tube",
            salary: "£13/hr",
            employmentType: "Part-time",
            shiftStart: "Thu 10 PM",
            isImmediateStart: false,
            isVerified: true,
            avatarHue: 0.65,
            latitude: 51.5140,
            longitude: -0.0920
        )
    ]

    static let nearbyCandidates: [NearbyCandidate] = [
        NearbyCandidate(
            name: "Elena Rossi",
            initials: "ER",
            role: "Executive Chef",
            distance: "1.4 km",
            distanceKm: 1.4,
            eta: "8 min",
            experience: "15 years",
            availability: "Available now",
            keySkill: "Fine Dining",
            isVerified: true,
            isAvailableNow: true,
            avatarHue: 0.52
        ),
        NearbyCandidate(
            name: "James Park",
            initials: "JP",
            role: "Bar Manager",
            distance: "2.1 km",
            distanceKm: 2.1,
            eta: "12 min",
            experience: "8 years",
            availability: "From tomorrow",
            keySkill: "Mixology",
            isVerified: false,
            isAvailableNow: false,
            avatarHue: 0.38
        ),
        NearbyCandidate(
            name: "Sofia Blanc",
            initials: "SB",
            role: "Sommelier",
            distance: "3.2 km",
            distanceKm: 3.2,
            eta: "15 min",
            experience: "6 years",
            availability: "Available now",
            keySkill: "WSET Level 3",
            isVerified: true,
            isAvailableNow: true,
            avatarHue: 0.62
        ),
        NearbyCandidate(
            name: "Marco Bianchi",
            initials: "MB",
            role: "Sous Chef",
            distance: "4.8 km",
            distanceKm: 4.8,
            eta: "20 min",
            experience: "10 years",
            availability: "In 2 weeks",
            keySkill: "Japanese Fusion",
            isVerified: true,
            isAvailableNow: false,
            avatarHue: 0.45
        ),
        NearbyCandidate(
            name: "Anna Weber",
            initials: "AW",
            role: "Restaurant Manager",
            distance: "6.5 km",
            distanceKm: 6.5,
            eta: "25 min",
            experience: "12 years",
            availability: "Available now",
            keySkill: "Operations",
            isVerified: true,
            isAvailableNow: true,
            avatarHue: 0.58
        ),
        NearbyCandidate(
            name: "Tom Chen",
            initials: "TC",
            role: "Line Cook",
            distance: "8.1 km",
            distanceKm: 8.1,
            eta: "30 min",
            experience: "3 years",
            availability: "Available now",
            keySkill: "Asian Cuisine",
            isVerified: false,
            isAvailableNow: true,
            avatarHue: 0.35
        ),
        NearbyCandidate(
            name: "Luca Moretti",
            initials: "LM",
            role: "Pastry Chef",
            distance: "11.6 km",
            distanceKm: 11.6,
            eta: "35 min",
            experience: "7 years",
            availability: "In 1 week",
            keySkill: "French Pastry",
            isVerified: true,
            isAvailableNow: false,
            avatarHue: 0.48
        ),
        NearbyCandidate(
            name: "Priya Sharma",
            initials: "PS",
            role: "Waitstaff",
            distance: "14.3 km",
            distanceKm: 14.3,
            eta: "42 min",
            experience: "4 years",
            availability: "Available now",
            keySkill: "Fine Dining Service",
            isVerified: false,
            isAvailableNow: true,
            avatarHue: 0.65
        ),
        NearbyCandidate(
            name: "David Okafor",
            initials: "DO",
            role: "Bartender",
            distance: "17.4 km",
            distanceKm: 17.4,
            eta: "48 min",
            experience: "5 years",
            availability: "From next week",
            keySkill: "Cocktail Mixology",
            isVerified: true,
            isAvailableNow: false,
            avatarHue: 0.32
        ),
        NearbyCandidate(
            name: "Yuki Tanaka",
            initials: "YT",
            role: "Sushi Chef",
            distance: "19.1 km",
            distanceKm: 19.1,
            eta: "55 min",
            experience: "9 years",
            availability: "Available now",
            keySkill: "Japanese Cuisine",
            isVerified: true,
            isAvailableNow: true,
            avatarHue: 0.70
        ),
        NearbyCandidate(
            name: "Amira Hassan",
            initials: "AH",
            role: "Waitstaff",
            distance: "2.8 km",
            distanceKm: 2.8,
            eta: "10 min",
            experience: "3 years",
            availability: "Available now",
            keySkill: "Silver Service",
            isVerified: false,
            isAvailableNow: true,
            avatarHue: 0.57
        ),
        NearbyCandidate(
            name: "Carlos Rivera",
            initials: "CR",
            role: "Runner",
            distance: "3.9 km",
            distanceKm: 3.9,
            eta: "14 min",
            experience: "1 year",
            availability: "Available now",
            keySkill: "Fast Service",
            isVerified: false,
            isAvailableNow: true,
            avatarHue: 0.28
        ),
        NearbyCandidate(
            name: "Fatima Al-Rashid",
            initials: "FA",
            role: "Hostess",
            distance: "5.6 km",
            distanceKm: 5.6,
            eta: "18 min",
            experience: "4 years",
            availability: "From tomorrow",
            keySkill: "Guest Relations",
            isVerified: true,
            isAvailableNow: false,
            avatarHue: 0.42
        ),
        NearbyCandidate(
            name: "Leo Nguyen",
            initials: "LN",
            role: "Runner",
            distance: "9.3 km",
            distanceKm: 9.3,
            eta: "28 min",
            experience: "2 years",
            availability: "Available now",
            keySkill: "Event Service",
            isVerified: false,
            isAvailableNow: true,
            avatarHue: 0.55
        ),
        NearbyCandidate(
            name: "Sarah Mitchell",
            initials: "SM",
            role: "Hostess",
            distance: "12.7 km",
            distanceKm: 12.7,
            eta: "38 min",
            experience: "6 years",
            availability: "In 1 week",
            keySkill: "VIP Reception",
            isVerified: true,
            isAvailableNow: false,
            avatarHue: 0.60
        ),
        NearbyCandidate(
            name: "Kai Williams",
            initials: "KW",
            role: "Waitstaff",
            distance: "7.4 km",
            distanceKm: 7.4,
            eta: "22 min",
            experience: "5 years",
            availability: "Available now",
            keySkill: "Fine Dining Service",
            isVerified: true,
            isAvailableNow: true,
            avatarHue: 0.38
        ),
        NearbyCandidate(
            name: "Nina Petrova",
            initials: "NP",
            role: "Bartender",
            distance: "6.8 km",
            distanceKm: 6.8,
            eta: "21 min",
            experience: "7 years",
            availability: "From next week",
            keySkill: "Wine & Spirits",
            isVerified: true,
            isAvailableNow: false,
            avatarHue: 0.50
        )
    ]
}
