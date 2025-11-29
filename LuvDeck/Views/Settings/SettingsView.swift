// SettingsView.swift — FINAL DESIGN (2025)
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
                    .foregroundColor(.red)
                    .font(.caption)
                    .listRowBackground(Color.clear)
            }
            if let success = successMessage {
                Text(success)
                    .foregroundColor(.green)
                    .font(.caption)
                    .listRowBackground(Color.clear)
            }

            // MARK: - Profile → Black text
            Section("Profile") {
                NavigationLink("Username") { updateUsernameView }
                    .foregroundColor(.black)
            }

            // MARK: - Account → Black text
            Section("Account") {
                NavigationLink("Update Email") { updateEmailView }
                    .foregroundColor(.black)
                NavigationLink("Update Password") { updatePasswordView }
                    .foregroundColor(.black)
            }

            // MARK: - Premium → "Get Premium" red bold, others black
            Section("Premium") {
                Button {
                    showPaywall = true
                } label: {
                    Label("Get LuvDeck Premium", systemImage: "crown.fill")
                        .fontWeight(.bold)
                        .foregroundColor(.red)           // RED + BOLD
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
                    .foregroundColor(.black)             // Black
                }
                .disabled(isRestoring)

                Button {
                    openSubscriptionManagement()
                } label: {
                    Label("Manage Subscription", systemImage: "gear")
                        .foregroundColor(.black)         // Black
                }
            }

            // MARK: - Support → Blue + icon on Contact Us
            Section("Support") {
                Link(destination: URL(string: "mailto:helloluvdeck@gmail.com")!) {
                    Label("Contact Us", systemImage: "envelope.fill")
                        .foregroundColor(.blue)
                }
                
                Button { sendFeedback() } label: {
                    Label("Share Your Feedback", systemImage: "message")
                        .foregroundColor(.blue)
                }
                
                // MARK: - Rate Us Button (new)
                Button {
                    if let url = URL(string: "https://apps.apple.com/us/app/relationship-dates-luvdeck/id6755172208?action=write-review") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("Rate Us ⭐️", systemImage: "star.fill")
                        .foregroundColor(.blue)
                }
            }

            // MARK: - Legal → Black
            Section("Legal") {
                Link("Terms of Use", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                    .foregroundColor(.black)
                Link("Privacy Policy", destination: URL(string: "https://www.luvdeck.com/r/privacy")!)
                    .foregroundColor(.black)
                Link("Visit Website", destination: URL(string: "https://www.luvdeck.com")!)
                    .foregroundColor(.black)
            }

            // MARK: - Danger Zone → Red
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

    // MARK: - Subviews (unchanged)
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

    // MARK: - Actions (unchanged)
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
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
        .environmentObject(PurchaseViewModel())
}
