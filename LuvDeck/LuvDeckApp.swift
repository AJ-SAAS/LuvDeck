import SwiftUI
import Firebase
import RevenueCat

@main
struct LuvDeckApp: App {
    init() {
        // Initialize Firebase
        FirebaseApp.configure()
        
        // Initialize RevenueCat
        Purchases.configure(withAPIKey: "appl_XepSOeJujoolVOmttwgpWTfVXrV")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(PurchaseViewModel()) // Inject Purchase ViewModel
        }
    }
}
