import Foundation
import RevenueCat
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class PurchaseViewModel: ObservableObject {

    @Published var isSubscribed: Bool = false
    @Published var allPackages: [Package] = []
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""

    @Published var shouldPresentPaywall: Bool = false
    @Published var triggerPaywallAfterOnboarding: Bool = false

    @Published var selectedPackageIndex: Int = 0

    var isPremium: Bool { isSubscribed }

    private let entitlementID = "premium"
    private let userDefaultsKey = "isSubscribed"

    init() {
        Task {
            await fetchProducts()
            await updateSubscriptionStatus()
        }
    }

    // MARK: - Products
    func fetchProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let offerings = try await Purchases.shared.offerings()

            if let packages = offerings.current?.availablePackages {
                self.allPackages = packages.filter {
                    $0.packageType == .annual || $0.packageType == .lifetime
                }
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    // MARK: - Purchase
    func purchase(package: Package) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await Purchases.shared.purchase(package: package)

            let active = result.customerInfo.entitlements[entitlementID]?.isActive == true
            isSubscribed = active

            UserDefaults.standard.set(active, forKey: userDefaultsKey)

        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    // MARK: - Restore
    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let info = try await Purchases.shared.restorePurchases()

            let active = info.entitlements[entitlementID]?.isActive == true
            isSubscribed = active

            UserDefaults.standard.set(active, forKey: userDefaultsKey)

        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    // MARK: - Sync subscription state
    func updateSubscriptionStatus() async {
        do {
            let info = try await Purchases.shared.customerInfo()

            let active = info.entitlements[entitlementID]?.isActive ?? false
            isSubscribed = active

            UserDefaults.standard.set(active, forKey: userDefaultsKey)

        } catch {
            isSubscribed = false
            UserDefaults.standard.set(false, forKey: userDefaultsKey)
        }
    }

    // MARK: - Paywall trigger reset ONLY (safe)
    func resetPaywallTrigger() {
        triggerPaywallAfterOnboarding = false
        shouldPresentPaywall = false
    }

    // MARK: - Onboarding completion (IMPORTANT FIX)
    func completeOnboardingForCurrentUser() {

        // ⚠️ ONLY mark onboarding complete AFTER paywall closes
        UserDefaults.standard.set(true, forKey: "onboardingCompleted")

        guard let userId = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore()
            .collection("users")
            .document(userId)
            .setData([
                "onboardingCompleted": true,
                "onboardingCompletedAt": Date()
            ], merge: true)

        // Reset paywall state safely
        resetPaywallTrigger()
    }
}
