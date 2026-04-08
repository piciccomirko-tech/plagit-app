//
//  AdminNotificationsViewModel.swift
//  Plagit
//

import SwiftUI

@Observable
final class AdminNotificationsViewModel {
    private let service: any AdminNotificationServiceProtocol
    var notifs: [AdminNotification] = []
    var loadingState: LoadingState = .idle
    var selectedFilter = "All"
    var selectedSort = "Newest"
    var searchText = ""

    let filters = ["All", "Sent", "Read", "Unread", "Failed", "Candidate", "Business", "System"]
    let sortOptions = ["Newest", "Oldest", "Failed First", "Unread First", "Retried First", "Recipient A–Z", "Type"]

    init(service: any AdminNotificationServiceProtocol = AdminNotificationsAPIService()) { self.service = service }

    var filtered: [AdminNotification] {
        var result = notifs
        switch selectedFilter {
        case "Sent": result = result.filter { $0.deliveryState == "Delivered" || $0.deliveryState == "Sent" }
        case "Read": result = result.filter(\.isRead)
        case "Unread": result = result.filter { !$0.isRead }
        case "Failed": result = result.filter { $0.deliveryState == "Failed" }
        case "Candidate": result = result.filter { $0.recipientType == "Candidate" }
        case "Business": result = result.filter { $0.recipientType == "Business" }
        case "System": result = result.filter { $0.recipientType == "System" }
        default: break
        }
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            result = result.filter { $0.recipientName.lowercased().contains(q) || $0.title.lowercased().contains(q) || $0.notificationType.lowercased().contains(q) || $0.linkedEntity.lowercased().contains(q) }
        }
        switch selectedSort {
        case "Oldest": result.reverse()
        case "Failed First": result.sort { ($0.deliveryState == "Failed" ? 0 : 1) < ($1.deliveryState == "Failed" ? 0 : 1) }
        case "Unread First": result.sort { (!$0.isRead ? 0 : 1) < (!$1.isRead ? 0 : 1) }
        case "Retried First": result.sort { $0.retryCount > $1.retryCount }
        case "Recipient A–Z": result.sort { $0.recipientName.localizedCaseInsensitiveCompare($1.recipientName) == .orderedAscending }
        case "Type": result.sort { $0.notificationType < $1.notificationType }
        default: break
        }
        return result
    }

    func countFor(_ f: String) -> Int {
        switch f {
        case "All": return notifs.count
        case "Sent": return notifs.filter { $0.deliveryState == "Delivered" || $0.deliveryState == "Sent" }.count
        case "Read": return notifs.filter(\.isRead).count
        case "Unread": return notifs.filter { !$0.isRead }.count
        case "Failed": return notifs.filter { $0.deliveryState == "Failed" }.count
        case "Candidate": return notifs.filter { $0.recipientType == "Candidate" }.count
        case "Business": return notifs.filter { $0.recipientType == "Business" }.count
        case "System": return notifs.filter { $0.recipientType == "System" }.count
        default: return 0
        }
    }

    @MainActor func loadNotifications() async {
        guard loadingState != .loading else { return }; loadingState = .loading
        do { notifs = try await service.fetchNotifications(); loadingState = .loaded } catch { loadingState = .error(error.localizedDescription) }
    }

    @MainActor func resend(id: UUID) {
        Task { do { try await service.updateDeliveryState(id: id, state: "Delivered"); if let i = notifs.firstIndex(where: { $0.id == id }) { notifs[i].deliveryState = "Delivered" } } catch { } }
    }

    @MainActor func forceSend(id: UUID) {
        Task { do { try await service.updateDeliveryState(id: id, state: "Delivered"); if let i = notifs.firstIndex(where: { $0.id == id }) { notifs[i].deliveryState = "Delivered" } } catch { } }
    }
}
