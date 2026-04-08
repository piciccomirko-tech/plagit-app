//
//  SubscriptionManager.swift
//  Plagit
//
//  StoreKit 2 subscription manager — handles purchases, restore, and status.
//

import Foundation
import StoreKit

// MARK: - Subscription Plan

enum SubscriptionPlan: String, Codable {
    case free
    // Candidate
    case candidateMonthly = "candidate_monthly"
    case candidateAnnual = "candidate_annual"
    // Business tiers
    case businessBasicMonthly = "business_basic_monthly"
    case businessBasicAnnual = "business_basic_annual"
    case businessProMonthly = "business_pro_monthly"
    case businessProAnnual = "business_pro_annual"
    case businessPremiumMonthly = "business_premium_monthly"
    case businessPremiumAnnual = "business_premium_annual"
    // Service provider tiers
    case serviceBasicMonthly = "service_basic_monthly"
    case serviceBasicAnnual = "service_basic_annual"
    case serviceProMonthly = "service_pro_monthly"
    case serviceProAnnual = "service_pro_annual"
    case servicePremiumMonthly = "service_premium_monthly"
    case servicePremiumAnnual = "service_premium_annual"

    var isPremium: Bool { self != .free }
    var isCandidatePremium: Bool { self == .candidateMonthly || self == .candidateAnnual }

    var isBusinessAny: Bool { businessTier != .none }
    var isBusinessBasic: Bool { businessTier == .basic }
    var isBusinessPro: Bool { businessTier == .pro }
    var isBusinessPremium: Bool { businessTier == .premium }

    // For backward compat
    var isBusinessPaid: Bool { isBusinessAny }

    enum BusinessTier: Int, Comparable {
        case none = 0, basic = 1, pro = 2, premium = 3
        static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }
    }

    var businessTier: BusinessTier {
        switch self {
        case .businessBasicMonthly, .businessBasicAnnual: return .basic
        case .businessProMonthly, .businessProAnnual: return .pro
        case .businessPremiumMonthly, .businessPremiumAnnual: return .premium
        default: return .none
        }
    }

    // Service tier
    enum ServiceTier: Int, Comparable {
        case none = 0, basic = 1, pro = 2, premium = 3
        static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }
    }

    var serviceTier: ServiceTier {
        switch self {
        case .serviceBasicMonthly, .serviceBasicAnnual: return .basic
        case .serviceProMonthly, .serviceProAnnual: return .pro
        case .servicePremiumMonthly, .servicePremiumAnnual: return .premium
        default: return .none
        }
    }

    var isServiceAny: Bool { serviceTier != .none }

    var displayName: String {
        switch self {
        case .free: return "Free"
        case .candidateMonthly, .candidateAnnual: return "Candidate Premium"
        case .businessBasicMonthly, .businessBasicAnnual: return "Business Basic"
        case .businessProMonthly, .businessProAnnual: return "Business Pro"
        case .businessPremiumMonthly, .businessPremiumAnnual: return "Business Premium"
        case .serviceBasicMonthly, .serviceBasicAnnual: return "Service Basic"
        case .serviceProMonthly, .serviceProAnnual: return "Service Pro"
        case .servicePremiumMonthly, .servicePremiumAnnual: return "Service Premium"
        }
    }
}

// MARK: - Product IDs

enum PlagitProductID {
    // Candidate
    static let candidateMonthly = "com.plagit.candidate.monthly"
    static let candidateAnnual  = "com.plagit.candidate.annual"
    // Business Basic
    static let businessBasicMonthly  = "com.plagit.business.basic.monthly"
    static let businessBasicAnnual   = "com.plagit.business.basic.annual"
    // Business Pro
    static let businessProMonthly    = "com.plagit.business.pro.monthly"
    static let businessProAnnual     = "com.plagit.business.pro.annual"
    // Business Premium
    static let businessPremiumMonthly = "com.plagit.business.premium.monthly"
    static let businessPremiumAnnual  = "com.plagit.business.premium.annual"
    // Service Basic
    static let serviceBasicMonthly  = "com.plagit.service.basic.monthly"
    static let serviceBasicAnnual   = "com.plagit.service.basic.annual"
    // Service Pro
    static let serviceProMonthly    = "com.plagit.service.pro.monthly"
    static let serviceProAnnual     = "com.plagit.service.pro.annual"
    // Service Premium
    static let servicePremiumMonthly = "com.plagit.service.premium.monthly"
    static let servicePremiumAnnual  = "com.plagit.service.premium.annual"

    static let candidateIDs: Set<String> = [candidateMonthly, candidateAnnual]
    static let businessIDs: Set<String> = [
        businessBasicMonthly, businessBasicAnnual,
        businessProMonthly, businessProAnnual,
        businessPremiumMonthly, businessPremiumAnnual,
    ]
    static let serviceIDs: Set<String> = [
        serviceBasicMonthly, serviceBasicAnnual,
        serviceProMonthly, serviceProAnnual,
        servicePremiumMonthly, servicePremiumAnnual,
    ]
    static let allIDs: Set<String> = candidateIDs.union(businessIDs).union(serviceIDs)
}

// MARK: - Manager

@Observable
final class SubscriptionManager {
    static let shared = SubscriptionManager()

    // State
    var currentPlan: SubscriptionPlan = .free
    var expiryDate: Date?
    var products: [Product] = []
    var purchaseInProgress = false
    var errorMessage: String?
    var purchaseSuccess = false
    var restoreInProgress = false
    var restoreResult: RestoreResult?

    enum RestoreResult { case success, nothingToRestore, error(String) }

    var isSubscribed: Bool { currentPlan.isPremium }
    var isCandidatePremium: Bool { currentPlan.isCandidatePremium }
    var isBusinessPaid: Bool { currentPlan.isBusinessAny }
    // Keep old name for backward compat
    var isBusinessPremium: Bool { currentPlan.isBusinessPremium }
    var businessTier: SubscriptionPlan.BusinessTier { currentPlan.businessTier }

    private var updateListenerTask: Task<Void, Never>?
    private let client = APIClient.shared

    private init() {}

    // MARK: - Start Listening

    func startListening() {
        updateListenerTask?.cancel()
        updateListenerTask = Task(priority: .background) { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                if case .verified(let transaction) = result {
                    await self.handleVerified(transaction)
                    await transaction.finish()
                }
            }
        }
        // Refresh entitlements on launch so persisted subscriptions are recognized
        Task { @MainActor in
            await refreshFromStoreKit()
        }
    }

    // MARK: - Load Products

    @MainActor
    func loadProducts(for userType: String) async {
        errorMessage = nil
        let ids: Set<String>
        switch userType {
        case "business": ids = PlagitProductID.businessIDs
        case "service":  ids = PlagitProductID.serviceIDs
        default:         ids = PlagitProductID.candidateIDs
        }

        // Test 1: Try requested IDs
        do {
            let storeProducts = try await Product.products(for: ids)
            products = storeProducts.sorted { $0.price < $1.price }
        } catch {
            errorMessage = error.localizedDescription
        }

        // Test 2: If empty, try ALL IDs to see if any work
        if products.isEmpty {
            do {
                let allProducts = try await Product.products(for: PlagitProductID.allIDs)
                if !allProducts.isEmpty {
                    products = allProducts.filter { ids.contains($0.id) }.sorted { $0.price < $1.price }
                }
            } catch {
            }
        }

        // Test 3: If still empty, try a single hardcoded ID
        if products.isEmpty {
            do {
                _ = try await Product.products(for: ["com.plagit.candidate.monthly"])
            } catch {
            }
        }
    }

    // MARK: - Purchase

    @MainActor
    func purchase(_ product: Product) async {
        purchaseInProgress = true
        errorMessage = nil
        purchaseSuccess = false
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await handleVerified(transaction)
                    await transaction.finish()
                    purchaseSuccess = true
                } else {
                    errorMessage = L10n.t("purchase_failed")
                }
            case .userCancelled:
                break
            case .pending:
                errorMessage = L10n.t("purchase_pending")
            @unknown default:
                break
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        purchaseInProgress = false
    }

    // MARK: - Restore

    @MainActor
    func restorePurchases() async {
        restoreInProgress = true
        restoreResult = nil
        errorMessage = nil

        do {
            try await AppStore.sync()
        } catch is CancellationError {
            restoreInProgress = false
            return
        } catch {
            // StoreKit throws StoreKitError.userCancelled when user dismisses the sign-in
            let desc = String(describing: error)
            if desc.contains("userCancelled") || desc.contains("canceled") {
                restoreInProgress = false
                return
            }
            errorMessage = error.localizedDescription
            restoreResult = .error(error.localizedDescription)
            restoreInProgress = false
            return
        }

        await refreshFromStoreKit()

        if currentPlan.isPremium {
            restoreResult = .success
        } else {
            restoreResult = .nothingToRestore
        }
        restoreInProgress = false
    }

    // MARK: - Refresh from StoreKit

    @MainActor
    func refreshFromStoreKit() async {
        var foundPlan: SubscriptionPlan = .free
        var foundExpiry: Date?
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if let plan = planFromProductID(transaction.productID),
                   transaction.revocationDate == nil {
                    // For auto-renewable subscriptions, StoreKit only returns active ones
                    // in currentEntitlements, so no manual expiry check needed
                    if plan.businessTier > foundPlan.businessTier || (plan.isCandidatePremium && !foundPlan.isCandidatePremium) {
                        foundPlan = plan
                        foundExpiry = transaction.expirationDate
                    }
                }
            }
        }
        currentPlan = foundPlan
        expiryDate = foundExpiry
    }

    // MARK: - Refresh from Backend

    @MainActor
    func refreshStatus() async {
        do {
            struct StatusResponse: Decodable {
                let subscriptionPlan: String
                let subscriptionStatus: String
                let subscriptionExpires: String?
            }
            struct Wrapper: Decodable { let success: Bool; let data: StatusResponse }
            let w: Wrapper = try await client.request(.GET, path: "/subscription/status")
            currentPlan = SubscriptionPlan(rawValue: w.data.subscriptionPlan) ?? .free
            if let exp = w.data.subscriptionExpires {
                let f = ISO8601DateFormatter()
                f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                expiryDate = f.date(from: exp) ?? ISO8601DateFormatter().date(from: exp)
            }
        } catch {
            await refreshFromStoreKit()
        }
    }

    // MARK: - Handle Verified Transaction

    @MainActor
    private func handleVerified(_ transaction: Transaction) async {
        if let plan = planFromProductID(transaction.productID) {
            currentPlan = plan
            expiryDate = transaction.expirationDate
        }
        do {
            let base64 = transaction.jsonRepresentation.base64EncodedString()
            struct Body: Encodable { let signedTransaction: String; let productId: String }
            struct Wrapper: Decodable { let success: Bool }
            let _: Wrapper = try await client.request(.POST, path: "/subscription/verify",
                body: Body(signedTransaction: base64, productId: transaction.productID))
        } catch {
        }
    }

    // MARK: - Reset

    @MainActor
    func reset() {
        currentPlan = .free
        expiryDate = nil
        products = []
        purchaseSuccess = false
        errorMessage = nil
        restoreInProgress = false
        restoreResult = nil
    }

    // MARK: - Helpers

    private func planFromProductID(_ id: String) -> SubscriptionPlan? {
        switch id {
        case PlagitProductID.candidateMonthly:       return .candidateMonthly
        case PlagitProductID.candidateAnnual:        return .candidateAnnual
        case PlagitProductID.businessBasicMonthly:   return .businessBasicMonthly
        case PlagitProductID.businessBasicAnnual:    return .businessBasicAnnual
        case PlagitProductID.businessProMonthly:     return .businessProMonthly
        case PlagitProductID.businessProAnnual:      return .businessProAnnual
        case PlagitProductID.businessPremiumMonthly: return .businessPremiumMonthly
        case PlagitProductID.businessPremiumAnnual:  return .businessPremiumAnnual
        case PlagitProductID.serviceBasicMonthly:    return .serviceBasicMonthly
        case PlagitProductID.serviceBasicAnnual:     return .serviceBasicAnnual
        case PlagitProductID.serviceProMonthly:      return .serviceProMonthly
        case PlagitProductID.serviceProAnnual:       return .serviceProAnnual
        case PlagitProductID.servicePremiumMonthly:  return .servicePremiumMonthly
        case PlagitProductID.servicePremiumAnnual:   return .servicePremiumAnnual
        default: return nil
        }
    }
}
