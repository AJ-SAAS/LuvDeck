// LuvDeckApp.swift
import SwiftUI
import Firebase
import RevenueCat

@main
struct LuvDeckApp: App {
    @StateObject private var purchaseVM = PurchaseViewModel()
    @StateObject private var savedIdeasVM = SavedIdeasViewModel()   // ← ADD
    @StateObject private var homeVM = HomeViewModel(userId: nil)    // ← ADD

    init() {
        FirebaseApp.configure()
        Purchases.configure(withAPIKey: "appl_XepSOeJujoolVOmttwgpWTfVXrV")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(purchaseVM)
                .environmentObject(savedIdeasVM)   // ← INJECT
                .environmentObject(homeVM)         // ← INJECT
        }
    }
}
