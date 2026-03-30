// SettingsView.swift — Updated with Premium Gradient Card

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
        VStack(spacing: 0) {
            // MARK: - Premium Promotion Card (Top)
            premiumStatusCard
            
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
                        .foregroundStyle(.primary)
                }

                // MARK: - Account
                Section("Account") {
                    NavigationLink("Update Email") { updateEmailView }
                        .foregroundStyle(.primary)
                    NavigationLink("Update Password") { updatePasswordView }
                        .foregroundStyle(.primary)
                }

                // MARK: - Premium Section (Old button removed)
                Section("Premium") {
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
                        .foregroundStyle(.primary)
                    }
                    .disabled(isRestoring)

                    Button {
                        openSubscriptionManagement()
                    } label: {
                        Label("Manage Subscription", systemImage: "gear")
                            .foregroundStyle(.primary)
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
                    Link(
                        "Terms of Use",
                        destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
                    )
                    .foregroundStyle(.primary)

                    Link(
                        "Privacy Policy",
                        destination: URL(string: "https://www.luvdeck.com/r/privacy")!
                    )
                    .foregroundStyle(.primary)

                    Link(
                        "Visit Website",
                        destination: URL(string: "https://www.luvdeck.com")!
                    )
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
            .listStyle(.insetGrouped)
        }
        // ✅ FORCE WHITE TAB BAR BACKGROUND (Settings ONLY)
        .toolbarBackground(Color.white, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)

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

    // MARK: - Premium Status Card with Custom Gradient
    private var premiumStatusCard: some View {
        let isPremium = purchaseVM.isPremium

        return VStack(alignment: .leading, spacing: 10) {
            if isPremium {
                // Subscribed state
                HStack(spacing: 12) {
                    Text("LuvDeck Premium")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Image(systemName: "checkmark.seal.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
                
                Text("Unlocked ✨ All 365+ date ideas, couple q's, momentum prompts, and features.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.95))
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                // Upgrade state - matches your request
                Text("Upgrade to LuvDeck Premium")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                
                Text("Unlocks all 365+ date ideas, couple q's, momentum prompts, and features")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    Color(hex: "#fd0093"),
                    Color(hex: "#ff0400")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 6)
        .onTapGesture {
            if !isPremium {
                showPaywall = true
            }
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

    private func updateUsername() { /* implement your logic */ }
    private func updateEmail() { /* implement your logic */ }
    private func updatePassword() { /* implement your logic */ }
    private func restorePurchases() async { /* implement your logic */ }
    private func openSubscriptionManagement() { /* implement your logic */ }
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

// MARK: - Hex Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
        .environmentObject(PurchaseViewModel())
        .preferredColorScheme(.dark)
}
