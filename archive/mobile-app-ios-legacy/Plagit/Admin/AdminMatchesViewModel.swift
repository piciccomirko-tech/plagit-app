//
//  AdminMatchesViewModel.swift
//  Plagit
//
//  ViewModel for admin matches management.
//

import Foundation

@Observable
final class AdminMatchesViewModel {
    var matches: [AdminMatchDTO] = []
    var feedback: [AdminFeedbackDTO] = []
    var notifications: [AdminMatchNotifDTO] = []
    var stats = AdminMatchStatsDTO(
        totalMatches: 0, pendingMatches: 0, acceptedMatches: 0, deniedMatches: 0,
        matchNotificationsSent: 0, totalFeedback: 0, positiveFeedback: 0,
        profiledCandidates: 0, profiledJobs: 0,
        interviewsRequested: 0, interviewsAccepted: 0, interviewsDeclined: 0, interviewsCompleted: 0
    )
    var isLoading = true
    var errorMessage: String?
    var selectedTab = "Matches"
    var searchText = ""
    var roleFilter = ""
    var jobTypeFilter = ""
    var statusFilter = ""

    let tabs = ["Matches", "Notifications", "Feedback", "Stats"]
    let roleFilters = ["All"] + PlagitRole.allCases.map(\.rawValue)
    let jobTypeFilters = ["All"] + PlagitJobType.allCases.map(\.rawValue)
    let statusFilters = ["All", "pending", "accepted", "denied"]

    var filteredMatches: [AdminMatchDTO] {
        var result = matches
        if !roleFilter.isEmpty && roleFilter != "All" {
            result = result.filter { ($0.candidateRole ?? "").localizedCaseInsensitiveContains(roleFilter) }
        }
        if !jobTypeFilter.isEmpty && jobTypeFilter != "All" {
            result = result.filter { ($0.candidateJobType ?? "").localizedCaseInsensitiveContains(jobTypeFilter) }
        }
        if !statusFilter.isEmpty && statusFilter != "All" {
            result = result.filter { ($0.matchStatus ?? "pending") == statusFilter }
        }
        if !searchText.isEmpty {
            result = result.filter {
                $0.candidateName.localizedCaseInsensitiveContains(searchText) ||
                $0.jobTitle.localizedCaseInsensitiveContains(searchText) ||
                ($0.businessName ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
        return result
    }

    @MainActor
    func loadAll() async {
        isLoading = true; errorMessage = nil
        do {
            async let m = AdminMatchesAPIService.shared.fetchMatches()
            async let s = AdminMatchesAPIService.shared.fetchStats()
            async let f = AdminMatchesAPIService.shared.fetchFeedback()
            async let n = AdminMatchesAPIService.shared.fetchMatchNotifications()
            (matches, stats, feedback, notifications) = try await (m, s, f, n)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
