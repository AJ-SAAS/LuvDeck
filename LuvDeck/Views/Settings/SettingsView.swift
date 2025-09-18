import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var username = ""
    @State private var email = ""
    @State private var currentPassword = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                List {
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal)
                    }
                    if let successMessage = successMessage {
                        Text(successMessage)
                            .foregroundColor(.green)
                            .font(.caption)
                            .padding(.horizontal)
                    }
                    
                    Section(header: Text("Profile")) {
                        NavigationLink {
                            VStack(spacing: 20) {
                                Text("Update Username")
                                    .font(.system(size: min(geometry.size.width * 0.07, 28), weight: .bold))
                                TextField("New Username", text: $username)
                                    .textFieldStyle(.roundedBorder)
                                    .padding(.horizontal, min(geometry.size.width * 0.05, 24))
                                Button(action: {
                                    updateUsername()
                                }) {
                                    Text("Save")
                                        .font(.system(size: min(geometry.size.width * 0.045, 18), weight: .semibold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, min(geometry.size.height * 0.02, 14))
                                        .background(Color.black)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .padding(.horizontal, min(geometry.size.width * 0.05, 24))
                                Spacer()
                            }
                            .padding(.top, geometry.size.height * 0.05)
                            .navigationTitle("Update Username")
                        } label: {
                            Text("Username")
                        }
                    }
                    
                    Section(header: Text("Account")) {
                        NavigationLink {
                            VStack(spacing: 20) {
                                Text("Update Email")
                                    .font(.system(size: min(geometry.size.width * 0.07, 28), weight: .bold))
                                TextField("New Email", text: $email)
                                    .textFieldStyle(.roundedBorder)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                                    .padding(.horizontal, min(geometry.size.width * 0.05, 24))
                                SecureField("Current Password", text: $currentPassword)
                                    .textFieldStyle(.roundedBorder)
                                    .padding(.horizontal, min(geometry.size.width * 0.05, 24))
                                Button(action: {
                                    updateEmail()
                                }) {
                                    Text("Save")
                                        .font(.system(size: min(geometry.size.width * 0.045, 18), weight: .semibold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, min(geometry.size.height * 0.02, 14))
                                        .background(Color.black)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .padding(.horizontal, min(geometry.size.width * 0.05, 24))
                                Spacer()
                            }
                            .padding(.top, geometry.size.height * 0.05)
                            .navigationTitle("Update Email")
                        } label: {
                            Text("Update Email")
                        }
                        
                        NavigationLink {
                            VStack(spacing: 20) {
                                Text("Update Password")
                                    .font(.system(size: min(geometry.size.width * 0.07, 28), weight: .bold))
                                SecureField("Current Password", text: $currentPassword)
                                    .textFieldStyle(.roundedBorder)
                                    .padding(.horizontal, min(geometry.size.width * 0.05, 24))
                                SecureField("New Password", text: $password)
                                    .textFieldStyle(.roundedBorder)
                                    .padding(.horizontal, min(geometry.size.width * 0.05, 24))
                                SecureField("Confirm Password", text: $confirmPassword)
                                    .textFieldStyle(.roundedBorder)
                                    .padding(.horizontal, min(geometry.size.width * 0.05, 24))
                                Button(action: {
                                    updatePassword()
                                }) {
                                    Text("Save")
                                        .font(.system(size: min(geometry.size.width * 0.045, 18), weight: .semibold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, min(geometry.size.height * 0.02, 14))
                                        .background(Color.black)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .padding(.horizontal, min(geometry.size.width * 0.05, 24))
                                Spacer()
                            }
                            .padding(.top, geometry.size.height * 0.05)
                            .navigationTitle("Update Password")
                        } label: {
                            Text("Update Password")
                        }
                    }
                    
                    Section(header: Text("Legal")) {
                        Link("Terms of Use", destination: URL(string: "https://yourapp.com/terms")!)
                        Link("Privacy Policy", destination: URL(string: "https://yourapp.com/privacy")!)
                        Link("Visit Website", destination: URL(string: "https://yourapp.com")!)
                    }
                    
                    Section {
                        Button(action: {
                            authViewModel.signOut()
                        }) {
                            Text("Sign Out")
                                .foregroundColor(.red)
                        }
                        Button(action: {
                            showingAlert = true
                            alertMessage = "Are you sure you want to delete your account? This action cannot be undone."
                        }) {
                            Text("Delete Account")
                                .foregroundColor(.red)
                        }
                    }
                }
                .navigationTitle("Settings")
                .alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text("Delete Account"),
                        message: Text(alertMessage),
                        primaryButton: .destructive(Text("Delete")) {
                            deleteAccount()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
        .onAppear {
            if let user = Auth.auth().currentUser {
                username = user.displayName ?? ""
                email = user.email ?? ""
            }
        }
    }
    
    private func updateUsername() {
        guard !username.isEmpty else {
            errorMessage = "Username cannot be empty"
            successMessage = nil
            return
        }
        FirebaseManager.shared.updateUsername(username) { result in
            switch result {
            case .success:
                self.errorMessage = nil
                self.successMessage = "Username updated successfully"
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.successMessage = nil
            }
        }
    }
    
    private func updateEmail() {
        guard !email.isEmpty, email.contains("@") else {
            errorMessage = "Please enter a valid email"
            successMessage = nil
            return
        }
        guard !currentPassword.isEmpty else {
            errorMessage = "Please enter your current password"
            successMessage = nil
            return
        }
        FirebaseManager.shared.reauthenticate(currentPassword: currentPassword) { result in
            switch result {
            case .success:
                FirebaseManager.shared.updateEmail(email) { result in
                    switch result {
                    case .success:
                        self.errorMessage = nil
                        self.successMessage = "Verification email sent. Please check your inbox to confirm."
                        self.currentPassword = ""
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                        self.successMessage = nil
                    }
                }
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.successMessage = nil
            }
        }
    }
    
    private func updatePassword() {
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            successMessage = nil
            return
        }
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            successMessage = nil
            return
        }
        guard !currentPassword.isEmpty else {
            errorMessage = "Please enter your current password"
            successMessage = nil
            return
        }
        FirebaseManager.shared.reauthenticate(currentPassword: currentPassword) { result in
            switch result {
            case .success:
                FirebaseManager.shared.updatePassword(password) { result in
                    switch result {
                    case .success:
                        self.errorMessage = nil
                        self.successMessage = "Password updated successfully"
                        self.password = ""
                        self.confirmPassword = ""
                        self.currentPassword = ""
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                        self.successMessage = nil
                    }
                }
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.successMessage = nil
            }
        }
    }
    
    private func deleteAccount() {
        guard !currentPassword.isEmpty else {
            errorMessage = "Please enter your current password in the Update Password section to delete your account"
            successMessage = nil
            showingAlert = false
            return
        }
        FirebaseManager.shared.reauthenticate(currentPassword: currentPassword) { result in
            switch result {
            case .success:
                FirebaseManager.shared.deleteAccount { result in
                    switch result {
                    case .success:
                        self.errorMessage = nil
                        self.successMessage = nil
                        self.authViewModel.signOut()
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                        self.successMessage = nil
                    }
                }
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.successMessage = nil
            }
        }
    }
}

#Preview("iPhone 14") {
    SettingsView()
        .environmentObject(AuthViewModel())
}

#Preview("iPad Pro") {
    SettingsView()
        .environmentObject(AuthViewModel())
}
