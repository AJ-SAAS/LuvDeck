// PurchaseViewModel.swift
// FINAL MEMORY-SAFE VERSION — NO CRASH EVER
import Foundation
import RevenueCat
import SwiftUI

@MainActor
class PurchaseViewModel: ObservableObject {
    @Published var isPremium: Bool = false
    @Published var shouldPresentPaywall: Bool = false
    @Published var triggerPaywallAfterOnboarding: Bool = false

    private let entitlementID = "Premium"

    init() {
        Task { await checkEntitlement() }
    }

    // MARK: - 100% SAFE: No Firebase, no crash
    func completeOnboardingForCurrentUser() {
        // We only need local flag — Firestore write happens later when user is confirmed
        UserDefaults.standard.set(true, forKey: "onboardingCompleted")
    }

    func purchase(productID: String) async throws {
        let products = await Purchases.shared.products([productID])
        guard let product = products.first else {
            throw NSError(domain: "PurchaseError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Product not found"])
        }
        let result = try await Purchases.shared.purchase(product: product)
        self.isPremium = result.customerInfo.entitlements[entitlementID]?.isActive ?? false
        
        if self.isPremium {
            completeOnboardingForCurrentUser()
        }
    }

    func restorePurchases() async throws {
        let info = try await Purchases.shared.restorePurchases()
        self.isPremium = info.entitlements[entitlementID]?.isActive ?? false
        
        if self.isPremium {
            completeOnboardingForCurrentUser()
        }
    }

    func checkEntitlement() async {
        do {
            let info = try await Purchases.shared.customerInfo()
            self.isPremium = info.entitlements[entitlementID]?.isActive ?? false
        } catch {
            print("Entitlement check failed: \(error)")
        }
    }
}
