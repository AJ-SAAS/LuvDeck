import Foundation
import StoreKit
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class PurchaseViewModel: ObservableObject {
    @Published var isSubscribed: Bool = false
    @Published var purchasedItems: [Product] = []
    @Published var allProducts: [Product] = []
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""

    @Published var shouldPresentPaywall: Bool = false
    @Published var triggerPaywallAfterOnboarding: Bool = false

    var isPremium: Bool { isSubscribed }

    private let entitlementID = "premium"
    private let userDefaultsKey = "isSubscribed"

    init() {
        Task {
            await fetchProducts()
            await updateSubscriptionStatus()
        }
    }

    // MARK: - Fetch Products (with retry)
    func fetchProducts() async {
        let productIDs: Set<String> = [
            "luvdeck_weekly_399",
            "luvdeck_annual_2999",
            "luvdeck_lifetime_8999"
        ]

        for attempt in 1...3 {
            do {
                let products = try await Product.products(for: productIDs)
                if !products.isEmpty {
                    DispatchQueue.main.async {
                        self.allProducts = products.sorted { $0.displayName < $1.displayName }
                    }
                    return
                }
            } catch {
                print("fetchProducts attempt \(attempt) failed: \(error)")
            }
            try? await Task.sleep(nanoseconds: 1_000_000_000)
        }
        print("⚠️ Could not load products after 3 attempts")
    }

    // MARK: - Purchase
    func purchase(product: Product) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    await updateSubscriptionStatus()
                case .unverified:
                    print("Unverified transaction")
                }
            case .userCancelled:
                break
            case .pending:
                break
            default:
                break
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            showError = true
        }
    }

    // MARK: - Restore Purchases
    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
        } catch {
            errorMessage = "Restore failed: \(error.localizedDescription)"
            showError = true
        }
    }

    // MARK: - Update Subscription Status
    func updateSubscriptionStatus() async {
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                if transaction.productID == "luvdeck_weekly_399" ||
                   transaction.productID == "luvdeck_annual_2999" ||
                   transaction.productID == "luvdeck_lifetime_8999" {
                    DispatchQueue.main.async {
                        self.isSubscribed = true
                        UserDefaults.standard.set(true, forKey: self.userDefaultsKey)
                    }
                    return
                }
            case .unverified:
                break
            }
        }

        DispatchQueue.main.async {
            self.isSubscribed = false
            UserDefaults.standard.set(false, forKey: self.userDefaultsKey)
        }
    }

    // MARK: - Complete Onboarding
    func completeOnboardingForCurrentUser() {
        UserDefaults.standard.set(true, forKey: "onboardingCompleted")

        if let userId = Auth.auth().currentUser?.uid {
            Firestore.firestore()
                .collection("users")
                .document(userId)
                .setData(["onboardingCompleted": true], merge: true)
        }

        triggerPaywallAfterOnboarding = false
    }
}
