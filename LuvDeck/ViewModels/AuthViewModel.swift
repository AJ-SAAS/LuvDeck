import SwiftUI
import Firebase
import FirebaseAuth
import UserNotifications

// MARK: - Notification Names
extension Notification.Name {
    static let authDidCompleteSignUp = Notification.Name("authDidCompleteSignUp")
    static let authDidSignOut = Notification.Name("authDidSignOut")
}

class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var errorMessage: String?
    @Published var didJustSignUp: Bool = false
    @Published var isLoading = false

    init() {
        if let authUser = Auth.auth().currentUser {
            self.user = User(id: authUser.uid, email: authUser.email ?? "")
            print("Initialized with existing user: \(authUser.uid)")
            checkAndRequestNotificationPermission()
        } else {
            print("No user signed in at initialization")
        }
    }

    private func checkAndRequestNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                print("Notification permission status: \(settings.authorizationStatus.rawValue)")
            }
        }
    }

    // MARK: - Sign In
    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = nil

        FirebaseManager.shared.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let user):
                    self.user = user
                    self.didJustSignUp = false
                    print("✅ Sign in successful for user: \(user.id)")
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("❌ Sign in error: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Sign Up
    func signUp(email: String, password: String) {
        isLoading = true
        errorMessage = nil

        FirebaseManager.shared.signUp(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let user):
                    self.user = user
                    self.didJustSignUp = true
                    print("✅ Sign up successful for user: \(user.id)")
                    NotificationCenter.default.post(name: .authDidCompleteSignUp, object: nil)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("❌ Sign up error: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Sign Out
    func signOut() {
        do {
            try FirebaseManager.shared.signOut()
            user = nil
            errorMessage = nil
            didJustSignUp = false
            isLoading = false
            print("👋 User signed out")
            NotificationCenter.default.post(name: .authDidSignOut, object: nil)
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Sign out error: \(error.localizedDescription)")
        }
    }
}
