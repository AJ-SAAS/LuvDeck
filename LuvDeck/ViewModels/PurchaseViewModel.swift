// PurchaseViewModel.swift
import Foundation
import RevenueCat
import SwiftUI

@MainActor
class PurchaseViewModel: ObservableObject {
    @Published var isPremium: Bool = false
    
    private let entitlementID = "Premium"  // Must match your RevenueCat dashboard

    init() {
        Task { await checkEntitlement() }
    }

    // STRING-BASED PURCHASE – No Package, no offerings needed
    func purchase(productID: String) async throws {
        let products = await Purchases.shared.products([productID])
        guard let product = products.first else {
            throw NSError(domain: "PurchaseError", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Product not found: \(productID)"
            ])
        }
        
        let result = try await Purchases.shared.purchase(product: product)
        let active = result.customerInfo.entitlements[entitlementID]?.isActive ?? false
        self.isPremium = active
    }

    // Standard name – matches what everyone expects
    func restorePurchases() async throws {
        let customerInfo = try await Purchases.shared.restorePurchases()
        self.isPremium = customerInfo.entitlements[entitlementID]?.isActive ?? false
    }

    func checkEntitlement() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            self.isPremium = customerInfo.entitlements[entitlementID]?.isActive ?? false
        } catch {
            print("Entitlement check failed: \(error)")
        }
    }
}
