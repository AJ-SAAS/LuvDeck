import Foundation
import RevenueCat
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class PurchaseViewModel: ObservableObject {
    @Published var isSubscribed: Bool = false
    @Published var allPackages: [Package] = []       // <- Updated to Package
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""

    @Published var shouldPresentPaywall: Bool = false
    @Published var triggerPaywallAfterOnboarding: Bool = false
    @Published var selectedPackageIndex: Int = 0     // <- Track which plan is selected

    var isPremium: Bool { isSubscribed }

    private let entitlementID = "premium"
    private let userDefaultsKey = "isSubscribed"

    init() {
        Task {
            await fetchProducts()
            await updateSubscriptionStatus()
        }
    }

    // MARK: - Fetch RevenueCat Products (Annual + Lifetime only)
    func fetchProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let offerings = try await Purchases.shared.offerings()
            if let availablePackages = offerings.current?.availablePackages {
                // Only include Annual + Lifetime packages
                self.allPackages = availablePackages.filter { $0.packageType == .annual || $0.packageType == .lifetime }
            }
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            showError = true
        }
    }

    // MARK: - Purchase a package
    func purchase(package: Package) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await Purchases.shared.purchase(package: package)
            
            // Check if entitlement is active after purchase
            if result.customerInfo.entitlements[entitlementID]?.isActive == true {
                isSubscribed = true
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
            let customerInfo = try await Purchases.shared.restorePurchases()
            isSubscribed = customerInfo.entitlements[entitlementID]?.isActive == true
        } catch {
            errorMessage = "Restore failed: \(error.localizedDescription)"
            showError = true
        }
    }

    // MARK: - Check Subscription Status
    func updateSubscriptionStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            let isActive = customerInfo.entitlements[entitlementID]?.isActive ?? false
            self.isSubscribed = isActive
            UserDefaults.standard.set(isActive, forKey: userDefaultsKey)
        } catch {
            print("Failed to fetch customer info: \(error)")
            self.isSubscribed = false
            UserDefaults.standard.set(false, forKey: userDefaultsKey)
        }
    }

    // MARK: - Onboarding
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
