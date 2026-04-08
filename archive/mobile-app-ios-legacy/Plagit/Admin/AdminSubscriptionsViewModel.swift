//
//  AdminSubscriptionsViewModel.swift
//  Plagit
//

import SwiftUI

@Observable
final class AdminSubscriptionsViewModel {
    private let service: any AdminSubscriptionServiceProtocol
    var subs: [AdminSubscription] = []
    var loadingState: LoadingState = .idle
    var selectedFilter = "All"
    var selectedSort = "Renewal Date"
    var searchText = ""

    var selectedUserType = "All"
    let userTypeFilters = ["All", "Candidate", "Biz Basic", "Biz Pro", "Biz Premium"]
    let filters = ["All", "Active", "Trial", "Expiring Soon", "Failed Payment", "Cancelled", "Grace Period", "Comp Access", "Auto-Renew Off", "Overdue"]
    let sortOptions = ["Renewal Date", "Failed First", "Highest Amount", "Newest", "Oldest", "Trial Ending", "A–Z", "Recently Paid"]

    init(service: any AdminSubscriptionServiceProtocol = AdminSubscriptionsAPIService()) { self.service = service }

    var failedSubs: [AdminSubscription] { subs.filter { $0.paymentState == "Failed" } }
    var expiringSubs: [AdminSubscription] { subs.filter { $0.status == "Expiring" || $0.renewalDate.contains("Mar") } }

    var filtered: [AdminSubscription] {
        var result = subs
        // User type / tier filter
        switch selectedUserType {
        case "Candidate": result = result.filter { $0.userType == "candidate" }
        case "Biz Basic": result = result.filter { $0.userType == "business" && $0.plan.lowercased().contains("basic") }
        case "Biz Pro": result = result.filter { $0.userType == "business" && $0.plan.lowercased().contains("pro") }
        case "Biz Premium": result = result.filter { $0.userType == "business" && $0.plan.lowercased().contains("premium") }
        default: break
        }
        switch selectedFilter {
        case "Active": result = result.filter { $0.status == "Active" }
        case "Trial": result = result.filter { $0.status == "Trial" }
        case "Expiring Soon": result = result.filter { $0.status == "Expiring" || $0.renewalDate.contains("Mar") }
        case "Failed Payment": result = result.filter { $0.paymentState == "Failed" }
        case "Cancelled": result = result.filter { $0.status == "Cancelled" }
        case "Grace Period": result = result.filter { $0.status == "Grace" }
        case "Comp Access": result = result.filter { $0.status == "Comp" }
        case "Auto-Renew Off": result = result.filter { !$0.autoRenew && $0.status != "Cancelled" }
        case "Overdue": result = result.filter { $0.paymentState == "Failed" || $0.status == "Grace" }
        default: break
        }
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            result = result.filter { $0.businessName.lowercased().contains(q) || $0.plan.lowercased().contains(q) || $0.amount.lowercased().contains(q) }
        }
        switch selectedSort {
        case "Failed First": result.sort { ($0.paymentState == "Failed" ? 0 : 1) < ($1.paymentState == "Failed" ? 0 : 1) }
        case "Highest Amount": result.sort { $0.amount > $1.amount }
        case "Trial Ending": result.sort { $0.trialDaysLeft < $1.trialDaysLeft }
        case "A–Z": result.sort { $0.businessName.localizedCaseInsensitiveCompare($1.businessName) == .orderedAscending }
        default: result.sort { $0.renewalDate < $1.renewalDate }
        }
        return result
    }

    func countFor(_ f: String) -> Int {
        switch f {
        case "All": return subs.count
        case "Active": return subs.filter { $0.status == "Active" }.count
        case "Trial": return subs.filter { $0.status == "Trial" }.count
        case "Expiring Soon": return subs.filter { $0.status == "Expiring" || $0.renewalDate.contains("Mar") }.count
        case "Failed Payment": return subs.filter { $0.paymentState == "Failed" }.count
        case "Cancelled": return subs.filter { $0.status == "Cancelled" }.count
        case "Grace Period": return subs.filter { $0.status == "Grace" }.count
        case "Comp Access": return subs.filter { $0.status == "Comp" }.count
        case "Auto-Renew Off": return subs.filter { !$0.autoRenew && $0.status != "Cancelled" }.count
        case "Overdue": return subs.filter { $0.paymentState == "Failed" || $0.status == "Grace" }.count
        default: return 0
        }
    }

    @MainActor func loadSubscriptions() async {
        guard loadingState != .loading else { return }; loadingState = .loading
        do { subs = try await service.fetchSubscriptions(); loadingState = .loaded } catch { loadingState = .error(error.localizedDescription) }
    }

    @MainActor func updateStatus(id: UUID, status: String) {
        Task { do { try await service.updateStatus(id: id, status: status); if let i = subs.firstIndex(where: { $0.id == id }) { subs[i].status = status } } catch { } }
    }

    @MainActor func cancelSubscription(id: UUID) {
        Task { do { try await service.cancelSubscription(id: id); if let i = subs.firstIndex(where: { $0.id == id }) { subs[i].status = "Cancelled"; subs[i].autoRenew = false } } catch { } }
    }
}
