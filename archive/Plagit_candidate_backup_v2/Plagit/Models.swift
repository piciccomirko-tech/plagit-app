//
//  Models.swift
//  Plagit
//
//  Data Models
//

import Foundation

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
}
