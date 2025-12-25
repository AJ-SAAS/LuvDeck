// SettingsView.swift — FINAL DESIGN (2025) – Dark Mode Fixed
import SwiftUI
import FirebaseAuth
import RevenueCat

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var purchaseVM: PurchaseViewModel

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
    @State private var isRestoring = false

    var body: some View {
        List {
            // MARK: - Messages
            if let error = errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.caption)
                    .listRowBackground(Color.clear)
            }
            if let success = successMessage {
                Text(success)
                    .foregroundStyle(.green)
                    .font(.caption)
                    .listRowBackground(Color.clear)
            }

            // MARK: - Profile
            Section("Profile") {
                NavigationLink("Username") { updateUsernameView }
                    .foregroundStyle(.primary)  // ← Adapts to dark mode
            }

            // MARK: - Account
            Section("Account") {
                NavigationLink("Update Email") { updateEmailView }
                    .foregroundStyle(.primary)
                NavigationLink("Update Password") { updatePasswordView }
                    .foregroundStyle(.primary)
            }

            // MARK: - Premium
            Section("Premium") {
                Button {
                    showPaywall = true
                } label: {
                    Label("Get LuvDeck Premium", systemImage: "crown.fill")
                        .fontWeight(.bold)
                        .foregroundStyle(.red)           // Intentional red
                }

                Button {
                    Task { await restorePurchases() }
                } label: {
                    HStack {
                        Label("Restore Purchases", systemImage: "arrow.clockwise")
                        if isRestoring {
                            Spacer()
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                    .foregroundStyle(.primary)           // ← Now adapts
                }
                .disabled(isRestoring)

                Button {
                    openSubscriptionManagement()
                } label: {
                    Label("Manage Subscription", systemImage: "gear")
                        .foregroundStyle(.primary)       // ← Now adapts
                }
            }

            // MARK: - Support
            Section("Support") {
                Link(destination: URL(string: "mailto:helloluvdeck@gmail.com")!) {
                    Label("Contact Us", systemImage: "envelope.fill")
                        .foregroundStyle(.blue)
                }
                
                Button { sendFeedback() } label: {
                    Label("Share Your Feedback", systemImage: "message")
                        .foregroundStyle(.blue)
                }
                
                Button {
                    if let url = URL(string: "https://apps.apple.com/us/app/relationship-dates-luvdeck/id6755172208?action=write-review") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("Rate Us ⭐️", systemImage: "star.fill")
                        .foregroundStyle(.blue)
                }
            }

            // MARK: - Legal
            Section("Legal") {
                Link("Terms of Use", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                    .foregroundStyle(.primary)  // ← Adapts
                Link("Privacy Policy", destination: URL(string: "https://www.luvdeck.com/r/privacy")!)
                    .foregroundStyle(.primary)
                Link("Visit Website", destination: URL(string: "https://www.luvdeck.com")!)
                    .foregroundStyle(.primary)
            }

            // MARK: - Danger Zone
            Section {
                Button("Sign Out", role: .destructive) {
                    authViewModel.signOut()
                }

                Button("Delete Account", role: .destructive) {
                    showingAlert = true
                    alertMessage = "Are you sure you want to delete your account? This action cannot be undone."
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Account", isPresented: $showingAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) { deleteAccount() }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(isPresented: $showPaywall, purchaseVM: purchaseVM)
        }
        .task {
            await loadCurrentUserData()
        }
    }

    // MARK: - Load Current User Data
    private func loadCurrentUserData() async {
        guard let user = Auth.auth().currentUser else { return }
        await MainActor.run {
            username = user.displayName ?? ""
            email = user.email ?? ""
        }
    }

    // MARK: - Subviews
    private var updateUsernameView: some View {
        Form {
            TextField("New Username", text: $username)
                .autocapitalization(.words)
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
            DispatchQueue.main.async {
                switch result {
                case .success:
                    authViewModel.signOut()
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func updateUsername() { /* unchanged */ }
    private func updateEmail() { /* unchanged */ }
    private func updatePassword() { /* unchanged */ }

    private func restorePurchases() async { /* unchanged */ }
    private func openSubscriptionManagement() { /* unchanged */ }
}

// MARK: - Primary Button Style
private extension View {
    func buttonStylePrimary() -> some View {
        self.frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.black)
            .foregroundStyle(.white)
            .cornerRadius(10)
            .padding(.horizontal)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
        .environmentObject(PurchaseViewModel())
        .preferredColorScheme(.dark)  // Preview in dark mode
}
