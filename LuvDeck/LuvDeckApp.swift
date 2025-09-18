import SwiftUI
import Firebase

@main
struct LuvDeckApp: App {
    init() {
        FirebaseApp.configure()
        // Removed: NotificationManager.shared.requestPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
