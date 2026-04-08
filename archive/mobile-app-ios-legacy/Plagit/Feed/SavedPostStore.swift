//
//  SavedPostStore.swift
//  Plagit
//
//  Local storage for saved post categories. Persists to UserDefaults.
//

import Foundation

// MARK: - Category

enum SavedPostCategory: String, CaseIterable, Codable {
    case restaurants = "restaurants"
    case cookingVideos = "cooking_videos"
    case jobsTips = "jobs_tips"
    case hospitalityNews = "hospitality_news"
    case recipes = "recipes"
    case other = "other"

    var label: String {
        switch self {
        case .restaurants: return "Restaurants"
        case .cookingVideos: return "Cooking Videos"
        case .jobsTips: return "Jobs Tips"
        case .hospitalityNews: return "Hospitality News"
        case .recipes: return "Recipes"
        case .other: return "Other"
        }
    }

    var icon: String {
        switch self {
        case .restaurants: return "fork.knife"
        case .cookingVideos: return "play.rectangle.fill"
        case .jobsTips: return "lightbulb.fill"
        case .hospitalityNews: return "newspaper.fill"
        case .recipes: return "book.fill"
        case .other: return "folder.fill"
        }
    }
}

// MARK: - Store

final class SavedPostStore {
    static let shared = SavedPostStore()
    private let key = "plagit_saved_post_categories"

    /// postId → category
    private(set) var map: [String: SavedPostCategory] = [:]

    private init() { loadFromDisk() }

    func save(postId: String, category: SavedPostCategory) {
        map[postId] = category
        persist()
    }

    func remove(postId: String) {
        map.removeValue(forKey: postId)
        persist()
    }

    func category(for postId: String) -> SavedPostCategory? {
        map[postId]
    }

    func updateCategory(postId: String, to category: SavedPostCategory) {
        map[postId] = category
        persist()
    }

    // MARK: - Persistence

    private func persist() {
        let encoded = map.mapValues(\.rawValue)
        UserDefaults.standard.set(encoded, forKey: key)
    }

    private func loadFromDisk() {
        guard let raw = UserDefaults.standard.dictionary(forKey: key) as? [String: String] else { return }
        map = raw.compactMapValues { SavedPostCategory(rawValue: $0) }
    }
}
