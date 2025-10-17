import SwiftUI

struct AuthView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isSignUp = true
    @FocusState private var focusedField: Field?
    @State private var animateLogo = false // for fade + scale animation

    enum Field {
        case email, password, confirmPassword
    }

    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack(spacing: 24) {
                    // MARK: - App Logo (larger + animated)
                    Image("luvdecklogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: min(geometry.size.width * 0.45, 180))
                        .padding(.top, geometry.size.height * 0.04)
                        .scaleEffect(animateLogo ? 1.0 : 0.85)
                        .opacity(animateLogo ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.6), value: animateLogo)

                    // MARK: - Title & Fields
                    VStack(spacing: 14) {
                        Text(isSignUp ? "Get started" : "Welcome back")
                            .font(.system(size: min(geometry.size.width * 0.07, 28), weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, min(geometry.size.width * 0.08, 32))

                        // MARK: - Email Field
                        CustomTextField(
                            placeholder: "Email",
                            text: $email,
                            isSecure: false,
                            focusedField: $focusedField,
                            field: .email
                        )
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)

                        // MARK: - Password Field
                        CustomTextField(
                            placeholder: "Password",
                            text: $password,
                            isSecure: true,
                            focusedField: $focusedField,
                            field: .password
                        )
                        .textContentType(.password)

                        // MARK: - Confirm Password (if signup)
                        if isSignUp {
                            CustomTextField(
                                placeholder: "Confirm Password",
                                text: $confirmPassword,
                                isSecure: true,
                                focusedField: $focusedField,
                                field: .confirmPassword
                            )
                            .textContentType(.password)
                        }

                        // MARK: - Error Message
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, min(geometry.size.width * 0.08, 32))
                                .padding(.top, 4)
                        }
                    }

                    // MARK: - Submit Button
                    Button(action: {
                        guard !email.isEmpty, !password.isEmpty else {
                            viewModel.errorMessage = "Please enter email and password"
                            return
                        }
                        guard password.count >= 6 else {
                            viewModel.errorMessage = "Password must be at least 6 characters"
                            return
                        }
                        if isSignUp {
                            guard confirmPassword == password else {
                                viewModel.errorMessage = "Passwords do not match"
                                return
                            }
                            viewModel.signUp(email: email, password: password)
                        } else {
                            viewModel.signIn(email: email, password: password)
                        }
                    }) {
                        Text(isSignUp ? "Create Account" : "Sign In")
                            .font(.system(size: min(geometry.size.width * 0.05, 22), weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.horizontal, min(geometry.size.width * 0.08, 32))
                            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                    }

                    // MARK: - Toggle Auth Mode
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isSignUp.toggle()
                            email = ""
                            password = ""
                            confirmPassword = ""
                            viewModel.errorMessage = nil
                        }
                    }) {
                        HStack(spacing: 4) {
                            Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                                .foregroundColor(.primary)
                            Text(isSignUp ? "Sign in" : "Sign up")
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                        .font(.system(size: 14))
                    }
                    .padding(.top, 4)

                    Spacer()
                }
                .navigationBarHidden(true)
                .background(Color(.systemBackground).ignoresSafeArea())
                .onAppear {
                    focusedField = .email
                    animateLogo = true
                }
            }
        }
    }
}

// MARK: - Custom Text Field Component
struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool
    @FocusState.Binding var focusedField: AuthView.Field?
    let field: AuthView.Field

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.secondarySystemBackground))
                )
        )
        .font(.system(size: 18))
        .focused($focusedField, equals: field)
        .padding(.horizontal, 32)
    }
}

#Preview("iPhone 14") {
    AuthView()
        .environmentObject(AuthViewModel())
}

#Preview("iPad Pro") {
    AuthView()
        .environmentObject(AuthViewModel())
}
