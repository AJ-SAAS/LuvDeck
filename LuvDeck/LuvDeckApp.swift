import SwiftUI
import Firebase
import RevenueCat

@main
struct LuvDeckApp: App {
    @StateObject private var purchaseVM = PurchaseViewModel()

    init() {
        FirebaseApp.configure()
        Purchases.configure(withAPIKey: "appl_XepSOeJujoolVOmttwgpWTfVXrV")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(purchaseVM)   // SINGLE shared instance
        }
    }
}
