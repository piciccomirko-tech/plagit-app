//
//  AdminUsersViewModel.swift
//  Plagit
//
//  ViewModel for AdminUsersView. Delegates to AdminUserServiceProtocol.
//

import SwiftUI

// MARK: - ViewModel

@Observable
final class AdminUsersViewModel {
    private let service: any AdminUserServiceProtocol

    var users: [AdminUser] = []
    var loadingState: LoadingState = .idle
    var selectedFilter = "All"
    var selectedSort = "Newest"
    var searchText = ""

    let filters = ["All", "Candidates", "Businesses", "Admins", "Verified", "Unverified", "Suspended", "Banned", "Incomplete"]
    let sortOptions = ["Newest", "Oldest", "Last Active", "Flagged First", "Profile Strength", "A–Z"]

    init(service: any AdminUserServiceProtocol = AdminUsersAPIService()) {
        self.service = service
    }

    // MARK: - Computed

    var filteredUsers: [AdminUser] {
        var result = users
        switch selectedFilter {
        case "Candidates": result = result.filter { $0.userType == "Candidate" }
        case "Businesses": result = result.filter { $0.userType == "Business" }
        case "Admins": result = result.filter { $0.userType == "Admin" }
        case "Verified": result = result.filter(\.isVerified)
        case "Unverified": result = result.filter { !$0.isVerified && $0.status == "Active" }
        case "Suspended": result = result.filter { $0.status == "Suspended" }
        case "Banned": result = result.filter { $0.status == "Banned" }
        case "Incomplete": result = result.filter { $0.profileStrength < 70 }
        default: break
        }
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            result = result.filter {
                $0.name.lowercased().contains(q) ||
                $0.email.lowercased().contains(q) ||
                $0.role.lowercased().contains(q) ||
                $0.location.lowercased().contains(q) ||
                $0.phone.lowercased().contains(q)
            }
        }
        switch selectedSort {
        case "Oldest": result.sort { $0.joinedDate < $1.joinedDate }
        case "Last Active": break
        case "Flagged First": result.sort { $0.flagCount > $1.flagCount }
        case "Profile Strength": result.sort { $0.profileStrength > $1.profileStrength }
        case "A–Z": result.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        default: result.sort { $0.joinedDate > $1.joinedDate }
        }
        return result
    }

    func countFor(_ filter: String) -> Int {
        switch filter {
        case "All": return users.count
        case "Candidates": return users.filter { $0.userType == "Candidate" }.count
        case "Businesses": return users.filter { $0.userType == "Business" }.count
        case "Admins": return users.filter { $0.userType == "Admin" }.count
        case "Verified": return users.filter(\.isVerified).count
        case "Unverified": return users.filter { !$0.isVerified && $0.status == "Active" }.count
        case "Suspended": return users.filter { $0.status == "Suspended" }.count
        case "Banned": return users.filter { $0.status == "Banned" }.count
        case "Incomplete": return users.filter { $0.profileStrength < 70 }.count
        default: return 0
        }
    }

    var banAlertTitle: String {
        "Ban User?"
    }

    var deleteAlertTitle: String {
        "Delete User?"
    }

    func alertTitle(action: String, for userId: UUID?) -> String {
        if let id = userId, let user = users.first(where: { $0.id == id }) {
            return "\(action) \(user.name)?"
        }
        return "\(action) User?"
    }

    // MARK: - Data Loading

    @MainActor
    func loadUsers() async {
        guard loadingState != .loading else { return }
        loadingState = .loading
        do {
            users = try await service.fetchUsers()
            loadingState = .loaded
        } catch {
            loadingState = .error(error.localizedDescription)
        }
    }

    // MARK: - Actions

    @MainActor
    func verifyUser(id: UUID) {
        Task {
            do {
                try await service.setVerified(id: id, verified: true)
                if let i = users.firstIndex(where: { $0.id == id }) {
                    users[i].isVerified = true
                    if users[i].status != "Banned" { users[i].status = "Active" }
                }
            } catch {
            }
        }
    }

    @MainActor
    func unverifyUser(id: UUID) {
        Task {
            do {
                try await service.setVerified(id: id, verified: false)
                if let i = users.firstIndex(where: { $0.id == id }) {
                    users[i].isVerified = false
                }
            } catch {
            }
        }
    }

    @MainActor
    func suspendUser(id: UUID) {
        Task {
            do {
                try await service.updateUserStatus(id: id, status: "Suspended")
                if let i = users.firstIndex(where: { $0.id == id }) {
                    users[i].status = "Suspended"
                }
            } catch {
            }
        }
    }

    @MainActor
    func unsuspendUser(id: UUID) {
        Task {
            do {
                try await service.updateUserStatus(id: id, status: "Active")
                if let i = users.firstIndex(where: { $0.id == id }) {
                    users[i].status = "Active"
                }
            } catch {
            }
        }
    }

    @MainActor
    func banUser(id: UUID) {
        Task {
            do {
                try await service.updateUserStatus(id: id, status: "Banned")
                if let i = users.firstIndex(where: { $0.id == id }) {
                    users[i].status = "Banned"
                }
            } catch {
            }
        }
    }

    @MainActor
    func unbanUser(id: UUID) {
        Task {
            do {
                try await service.updateUserStatus(id: id, status: "Active")
                if let i = users.firstIndex(where: { $0.id == id }) {
                    users[i].status = "Active"
                }
            } catch {
            }
        }
    }

    @MainActor
    func deleteUser(id: UUID) {
        Task {
            do {
                try await service.deleteUser(id: id)
                users.removeAll { $0.id == id }
            } catch {
            }
        }
    }

    @MainActor
    func updateUser(_ user: AdminUser) {
        Task {
            do {
                let updated = try await service.updateUser(user)
                if let i = users.firstIndex(where: { $0.id == updated.id }) {
                    users[i] = updated
                }
            } catch {
            }
        }
    }

    @MainActor
    func sendMessage(to userId: UUID, subject: String, body: String) {
        Task {
            do {
                try await service.sendMessage(to: userId, subject: subject, body: body)
            } catch {
            }
        }
    }
}
