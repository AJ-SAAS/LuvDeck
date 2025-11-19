// LuvDeckApp.swift
import SwiftUI
import Firebase
import RevenueCat

@main
struct LuvDeckApp: App {
    @StateObject private var purchaseVM = PurchaseViewModel()

    init() {
        FirebaseApp.configure()
        Purchases.configure(withAPIKey: "appl_XepSOeJujoolVOmttwgpWTfVXrV")
        // Removed setPersistence — no longer needed or available
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(purchaseVM)
        }
    }
}
