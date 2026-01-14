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

    // MARK: - Paywall & onboarding flags
    @Published var shouldPresentPaywall: Bool = false
    @Published var triggerPaywallAfterOnboarding: Bool = false

    // MARK: - Premium shortcut
    var isPremium: Bool { isSubscribed }

    private let entitlementID = "premium"
    private let userDefaultsKey = "isSubscribed"

    init() {
        Task {
            await fetchProducts()
            await updateSubscriptionStatus()
        }
    }

    // MARK: - Fetch Products
    func fetchProducts() async {
        do {
            let productIDs: Set<String> = [
                "luvdeck_weekly_399",
                "luvdeck_lifetime_8999"
            ]
            let products = try await Product.products(for: productIDs)
            DispatchQueue.main.async {
                self.allProducts = products.sorted { $0.displayName < $1.displayName }
            }
        } catch {
            print("Error fetching products: \(error)")
        }
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
                // Pending, but we still let .onDisappear handle navigation
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
                   transaction.productID == "luvdeck_lifetime_8999" {
                    DispatchQueue.main.async {
                        self.isSubscribed = true
                        UserDefaults.standard.set(true, forKey: self.userDefaultsKey)
                    }
                    return
                }
            case .unverified: break
            }
        }

        DispatchQueue.main.async {
            self.isSubscribed = false
            UserDefaults.standard.set(false, forKey: self.userDefaultsKey)
        }
    }

    // MARK: - Complete Onboarding Helper
    func completeOnboardingForCurrentUser() {
        UserDefaults.standard.set(true, forKey: "onboardingCompleted")
        
        // Sync to Firestore if user is logged in
        if let userId = Auth.auth().currentUser?.uid {
            Firestore.firestore()
                .collection("users")
                .document(userId)
                .setData(["onboardingCompleted": true], merge: true)
        }
        
        triggerPaywallAfterOnboarding = false
    }
}
