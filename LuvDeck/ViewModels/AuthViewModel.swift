import SwiftUI
import Firebase
import FirebaseAuth
import UserNotifications

class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var errorMessage: String?
    @Published var didJustSignUp: Bool = false
    
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
    
    func signIn(email: String, password: String) {
        print("Attempting sign in with email: \(email)")
        FirebaseManager.shared.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    print("Sign in successful: \(user.id)")
                    self?.user = user
                    self?.errorMessage = nil
                    self?.didJustSignUp = false
                case .failure(let error):
                    print("Sign in failed: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func signUp(email: String, password: String) {
        print("Attempting sign up with email: \(email)")
        FirebaseManager.shared.signUp(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    print("Sign up successful: \(user.id)")
                    self?.user = user
                    self?.errorMessage = nil
                    self?.didJustSignUp = true
                case .failure(let error):
                    print("Sign up failed: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func signOut() {
        print("Attempting sign out")
        do {
            try FirebaseManager.shared.signOut()
            user = nil
            errorMessage = nil
            didJustSignUp = false
            print("Sign out successful")
        } catch {
            print("Sign out failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }
}
