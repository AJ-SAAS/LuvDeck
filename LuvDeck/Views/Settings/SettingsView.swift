// SettingsView.swift
import SwiftUI
import FirebaseAuth
import RevenueCat

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var purchaseVM: PurchaseViewModel   // Added for Paywall

    @State private var username = ""
    @State private var email = ""
    @State private var currentPassword = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showPaywall = false

    var body: some View {
        NavigationView {
            List {
                // MARK: - Error & Success
                if let error = errorMessage {
                    Text(error).foregroundColor(.red).font(.caption)
                }
                if let success = successMessage {
                    Text(success).foregroundColor(.green).font(.caption)
                }

                // MARK: - Profile
                Section("Profile") {
                    NavigationLink("Username") { updateUsernameView }
                }

                // MARK: - Account
                Section("Account") {
                    NavigationLink("Update Email") { updateEmailView }
                    NavigationLink("Update Password") { updatePasswordView }
                }

                // MARK: - Premium (RevenueCat)
                Section("Premium") {
                    Button {
                        showPaywall = true
                    } label: {
                        Label("Get LuvDeck Premium", systemImage: "crown.fill")
                            .foregroundColor(.primary)
                    }

                    Button {
                        restorePurchases()
                    } label: {
                        Label("Restore Purchases", systemImage: "arrow.clockwise")
                            .foregroundColor(.primary)
                    }

                    Button {
                        openSubscriptionManagement()
                    } label: {
                        Label("Manage Subscription", systemImage: "gear")
                            .foregroundColor(.primary)
                    }
                }

                // MARK: - Support
                Section("Support") {
                    Link("Contact Us", destination: URL(string: "mailto:helloluvdeck@gmail.com")!)
                    Button { sendFeedback() } label: {
                        Label("Share Your Feedback", systemImage: "message")
                            .foregroundColor(.blue)
                    }
                }

                // MARK: - Legal
                Section("Legal") {
                    Link("Terms of Use", destination: URL(string: "https://www.luvdeck.com/r/terms")!)
                    Link("Privacy Policy", destination: URL(string: "https://www.luvdeck.com/r/privacy")!)
                    Link("Visit Website", destination: URL(string: "https://www.luvdeck.com")!)
                }

                // MARK: - Danger Zone
                Section {
                    Button("Sign Out", role: .destructive) { authViewModel.signOut() }
                    Button("Delete Account", role: .destructive) {
                        showingAlert = true
                        alertMessage = "Are you sure you want to delete your account? This action cannot be undone."
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text("Delete Account"),
                    message: Text(alertMessage),
                    primaryButton: .destructive(Text("Delete"), action: deleteAccount),
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(isPresented: $showPaywall, purchaseVM: purchaseVM)
            }
            .onAppear {
                if let user = Auth.auth().currentUser {
                    username = user.displayName ?? ""
                    email = user.email ?? ""
                }
            }
        }
    }

    // MARK: - Subviews
    private var updateUsernameView: some View {
        Form {
            TextField("New Username", text: $username)
            Button("Save", action: updateUsername)
                .buttonStylePrimary()
        }
        .navigationTitle("Username")
    }

    private var updateEmailView: some View {
        Form {
            TextField("New Email", text: $email)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            SecureField("Current Password", text: $currentPassword)
            Button("Save", action: updateEmail)
                .buttonStylePrimary()
        }
        .navigationTitle("Email")
    }

    private var updatePasswordView: some View {
        Form {
            SecureField("Current Password", text: $currentPassword)
            SecureField("New Password", text: $password)
            SecureField("Confirm Password", text: $confirmPassword)
            Button("Save", action: updatePassword)
                .buttonStylePrimary()
        }
        .navigationTitle("Password")
    }

    // MARK: - Actions
    private func sendFeedback() {
        let subject = "Feedback%20on%20LuvDeck%20App"
        if let url = URL(string: "mailto:helloluvdeck@gmail.com?subject=\(subject)") {
            UIApplication.shared.open(url)
        }
    }

    private func deleteAccount() {
        FirebaseManager.shared.deleteAccount { result in
            switch result {
            case .success:
                authViewModel.signOut()
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }

    private func updateUsername() {
        guard !username.isEmpty else {
            errorMessage = "Username cannot be empty"; return
        }
        FirebaseManager.shared.updateUsername(username) { result in
            switch result {
            case .success: successMessage = "Username updated"
            case .failure(let error): errorMessage = error.localizedDescription
            }
        }
    }

    private func updateEmail() {
        guard email.contains("@") else {
            errorMessage = "Invalid email"; return
        }
        guard !currentPassword.isEmpty else {
            errorMessage = "Enter current password"; return
        }
        FirebaseManager.shared.reauthenticate(currentPassword: currentPassword) { result in
            switch result {
            case .success:
                FirebaseManager.shared.updateEmail(email) { result in
                    switch result {
                    case .success: successMessage = "Verification email sent"
                    case .failure(let error): errorMessage = error.localizedDescription
                    }
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }

    private func updatePassword() {
        guard password.count >= 6 else {
            errorMessage = "Password too short"; return
        }
        guard password == confirmPassword else {
            errorMessage = "Passwords don't match"; return
        }
        guard !currentPassword.isEmpty else {
            errorMessage = "Enter current password"; return
        }
        FirebaseManager.shared.reauthenticate(currentPassword: currentPassword) { result in
            switch result {
            case .success:
                FirebaseManager.shared.updatePassword(password) { result in
                    switch result {
                    case .success: successMessage = "Password updated"
                    case .failure(let error): errorMessage = error.localizedDescription
                    }
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - RevenueCat Actions
    private func restorePurchases() {
        Purchases.shared.restorePurchases { customerInfo, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else if customerInfo?.entitlements["premium"]?.isActive == true {
                successMessage = "Premium restored!"
                purchaseVM.isPremium = true
            } else {
                errorMessage = "No active subscription"
            }
        }
    }

    private func openSubscriptionManagement() {
        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Button Style
private extension Button {
    func buttonStylePrimary() -> some View {
        self.frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
        .environmentObject(PurchaseViewModel())
}
