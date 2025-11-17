// PurchaseViewModel.swift
// Modern PurchaseViewModel for RevenueCat (supports completion handlers + simple state)

import Foundation
import RevenueCat
import SwiftUI

@MainActor
class PurchaseViewModel: ObservableObject {
    @Published var offerings: Offerings?
    @Published var isSubscribed: Bool = false
    @Published var purchaseError: String?
    @Published var isPremium: Bool = false

    // Use your entitlement id here
    private let entitlementID = "premium"

    init() {
        Task {
            await fetchOfferings()
            await checkEntitlement()
        }
    }

    // MARK: - Offerings
    func fetchOfferings() async {
        Purchases.shared.getOfferings { [weak self] offerings, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.purchaseError = error.localizedDescription
                    print("Failed to fetch offerings: \(error.localizedDescription)")
                } else {
                    self?.offerings = offerings
                }
            }
        }
    }

    // Backwards-compatible synchronous facade
    func fetchOfferings() {
        Task { await fetchOfferings() }
    }

    // MARK: - Purchase
    /// Purchase a package; returns via completion Result
    func purchase(package: Package, completion: @escaping (Result<Void, Error>) -> Void) {
        Purchases.shared.purchase(package: package) { [weak self] _, customerInfo, error, userCancelled in
            DispatchQueue.main.async {
                if let error = error {
                    self?.purchaseError = error.localizedDescription
                    completion(.failure(error))
                    return
                }

                if userCancelled {
                    let err = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Purchase cancelled"])
                    completion(.failure(err))
                    return
                }

                let active = customerInfo?.entitlements[self?.entitlementID ?? "premium"]?.isActive ?? false
                self?.isSubscribed = active
                self?.isPremium = active

                if active {
                    completion(.success(()))
                } else {
                    let err = NSError(domain: "", code: -2, userInfo: [NSLocalizedDescriptionKey: "Purchase did not unlock entitlement"])
                    completion(.failure(err))
                }
            }
        }
    }

    // Convenience: purchase by product identifier
    func purchase(productID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let pkg = offerings?.all
            .flatMap({ $0.value.availablePackages })
            .first(where: { $0.storeProduct.productIdentifier == productID }) else {
            let err = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Product not found"])
            completion(.failure(err))
            return
        }
        purchase(package: pkg, completion: completion)
    }

    // MARK: - Restore
    /// Restores purchases via RevenueCat and returns success / error
    func restorePurchases(completion: @escaping (Bool, Error?) -> Void) {
        Purchases.shared.restorePurchases { [weak self] customerInfo, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.purchaseError = error.localizedDescription
                    completion(false, error)
                    return
                }
                let active = customerInfo?.entitlements[self?.entitlementID ?? "premium"]?.isActive ?? false
                self?.isSubscribed = active
                self?.isPremium = active
                completion(active, nil)
            }
        }
    }

    // MARK: - Entitlement check
    func checkEntitlement() async {
        Purchases.shared.getCustomerInfo { [weak self] customerInfo, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching customer info: \(error.localizedDescription)")
                    self?.purchaseError = error.localizedDescription
                } else {
                    let active = customerInfo?.entitlements[self?.entitlementID ?? "premium"]?.isActive ?? false
                    self?.isSubscribed = active
                    self?.isPremium = active
                }
            }
        }
    }

    // Backwards-compatible facade
    func checkEntitlement() {
        Task { await checkEntitlement() }
    }
}
