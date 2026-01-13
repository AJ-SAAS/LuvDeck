// AuthView.swift
// ULTRA CLEAN VERSION – Bigger, bolder logo + PERFECT KEYBOARD DISMISSAL + FORCED LIGHT MODE

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isSignUp = true
    @FocusState private var focusedField: Field?

    enum Field { case email, password, confirmPassword }

    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack(spacing: 28) {
                    // MARK: - Logo – BIGGER & BOLDER
                    Image("newlogosmile")
                        .resizable()
                        .scaledToFit()
                        .frame(width: min(geometry.size.width * 0.62, 260))
                        .padding(.top, geometry.size.height * 0.08)

                    // MARK: - Title & Fields
                    VStack(spacing: 16) {
                        Text(isSignUp ? "Get started" : "Welcome back")
                            .font(.system(size: min(geometry.size.width * 0.07, 28), weight: .bold))
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, min(geometry.size.width * 0.08, 32))

                        CustomTextField(
                            placeholder: "Email",
                            text: $email,
                            isSecure: false,
                            focusedField: $focusedField,
                            field: .email
                        )
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)

                        CustomTextField(
                            placeholder: "Password",
                            text: $password,
                            isSecure: true,
                            focusedField: $focusedField,
                            field: .password
                        )
                        .textContentType(.password)

                        if isSignUp {
                            CustomTextField(
                                placeholder: "Confirm Password",
                                text: $confirmPassword,
                                isSecure: true,
                                focusedField: $focusedField,
                                field: .confirmPassword
                            )
                            .textContentType(.newPassword)
                        }

                        if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundStyle(.red)
                                .font(.caption)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, min(geometry.size.width * 0.08, 32))
                                .padding(.top, 4)
                        }
                    }

                    // MARK: - Submit Button
                    Button(action: submit) {
                        Group {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text(isSignUp ? "Create Account" : "Sign In")
                                    .font(.system(size: min(geometry.size.width * 0.05, 22), weight: .semibold))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.black)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                        .padding(.horizontal, min(geometry.size.width * 0.08, 32))
                    }
                    .disabled(viewModel.isLoading || email.isEmpty || password.isEmpty ||
                              (isSignUp && confirmPassword.isEmpty))

                    // MARK: - Toggle Button
                    Button {
                        isSignUp.toggle()
                        email = ""
                        password = ""
                        confirmPassword = ""
                        viewModel.errorMessage = nil
                        focusedField = .email
                    } label: {
                        HStack(spacing: 4) {
                            Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                                .foregroundStyle(.primary)
                            Text(isSignUp ? "Sign in" : "Sign up")
                                .fontWeight(.semibold)
                                .foregroundStyle(.blue)
                        }
                        .font(.system(size: 15))
                    }
                    .padding(.top, 8)

                    Spacer()
                }
                .navigationBarHidden(true)
                .background(Color.white.ignoresSafeArea())
            }
        }
        .preferredColorScheme(.light)  // ← FORCES LIGHT MODE FOR ENTIRE AUTH SCREEN
    }

    private func submit() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        viewModel.errorMessage = nil

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
    }
}

// MARK: - Clean Text Field
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
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .font(.system(size: 18))
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
        )
        .focused($focusedField, equals: field)
        .padding(.horizontal, 32)
    }
}

#Preview("iPhone") {
    AuthView()
        .environmentObject(AuthViewModel())
        .preferredColorScheme(.dark)  // Preview will still show light mode!
}

#Preview("iPad") {
    AuthView()
        .environmentObject(AuthViewModel())
}
