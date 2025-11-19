// AuthViewModel.swift – FINAL FIXED + SIGN-IN NAVIGATION SUPPORT
import SwiftUI
import Firebase
import FirebaseAuth
import UserNotifications

extension Notification.Name {
    static let authDidCompleteSignUp = Notification.Name("authDidCompleteSignUp")
    static let authDidSignIn = Notification.Name("authDidSignIn")           // ← NEW
    static let authDidSignOut = Notification.Name("authDidSignOut")
}

class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var errorMessage: String?
    @Published var didJustSignUp: Bool = false
    @Published var isLoading = false

    init() {
        self.user = nil
        print("AuthViewModel initialized — clean state")
    }

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
                    print("Sign in successful: \(user.id)")
                    
                    // THIS IS THE KEY LINE — tells ContentView to navigate
                    NotificationCenter.default.post(name: .authDidSignIn, object: nil)
                    
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("Sign in failed: \(error.localizedDescription)")
                }
            }
        }
    }

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
                    print("Sign up successful: \(user.id)")
                    NotificationCenter.default.post(name: .authDidCompleteSignUp, object: nil)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("Sign up failed: \(error.localizedDescription)")
                }
            }
        }
    }

    func signOut() {
        do {
            try FirebaseManager.shared.signOut()
            user = nil
            errorMessage = nil
            didJustSignUp = false
            isLoading = false
            print("Signed out cleanly")
            NotificationCenter.default.post(name: .authDidSignOut, object: nil)
        } catch {
            errorMessage = "Sign out failed"
            print("Sign out error: \(error.localizedDescription)")
        }
    }
}
