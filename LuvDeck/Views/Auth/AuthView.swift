import SwiftUI

struct AuthView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isSignUp = true
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email
        case password
        case confirmPassword
    }
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack(spacing: 20) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: geometry.size.width * 0.8)
                        .frame(height: min(geometry.size.height * 0.25, 200))
                        .padding(.top, geometry.size.height * 0.05)
                    
                    VStack(spacing: 16) {
                        Text(isSignUp ? "Get started" : "Welcome back")
                            .font(.system(size: min(geometry.size.width * 0.07, 28), weight: .bold))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        TextField("Email", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .focused($focusedField, equals: .email)
                            .padding(.horizontal, min(geometry.size.width * 0.05, 24))
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.password)
                            .disableAutocorrection(true)
                            .focused($focusedField, equals: .password)
                            .padding(.horizontal, min(geometry.size.width * 0.05, 24))
                        
                        if isSignUp {
                            SecureField("Confirm Password", text: $confirmPassword)
                                .textFieldStyle(.roundedBorder)
                                .textContentType(.password)
                                .disableAutocorrection(true)
                                .focused($focusedField, equals: .confirmPassword)
                                .padding(.horizontal, min(geometry.size.width * 0.05, 24))
                        }
                        
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 4)
                                .padding(.horizontal, min(geometry.size.width * 0.05, 24))
                        }
                    }
                    .padding(.horizontal, min(geometry.size.width * 0.05, 24))
                    
                    Button(action: {
                        guard !email.isEmpty, !password.isEmpty else {
                            viewModel.errorMessage = "Please enter email and password"
                            print("Input validation failed: Empty email or password")
                            return
                        }
                        guard password.count >= 6 else {
                            viewModel.errorMessage = "Password must be at least 6 characters"
                            print("Input validation failed: Password too short")
                            return
                        }
                        if isSignUp {
                            guard confirmPassword == password else {
                                viewModel.errorMessage = "Passwords do not match"
                                print("Input validation failed: Passwords do not match")
                                return
                            }
                            print("Button tapped: Sign Up with email: \(email)")
                            viewModel.signUp(email: email, password: password)
                        } else {
                            print("Button tapped: Sign In with email: \(email)")
                            viewModel.signIn(email: email, password: password)
                        }
                    }) {
                        Text(isSignUp ? "Create Account" : "Sign In")
                            .font(.system(size: min(geometry.size.width * 0.045, 18), weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, min(geometry.size.height * 0.02, 14))
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, min(geometry.size.width * 0.05, 24))
                    .padding(.top, 8)
                    
                    Button(action: {
                        isSignUp.toggle()
                        email = ""
                        password = ""
                        confirmPassword = ""
                        viewModel.errorMessage = nil
                        print("Toggled to: \(isSignUp ? "Sign Up" : "Sign In")")
                    }) {
                        HStack {
                            Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                                .font(.system(size: min(geometry.size.width * 0.035, 14)))
                                .foregroundColor(.primary)
                            Text(isSignUp ? "Sign in" : "Sign up")
                                .font(.system(size: min(geometry.size.width * 0.035, 14), weight: .semibold))
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.top, 8)
                    
                    Spacer()
                }
                .navigationBarHidden(true)
                .background(Color(.systemBackground).ignoresSafeArea())
                .onAppear {
                    focusedField = .email
                }
                .onChange(of: focusedField) { oldValue, newValue in
                    print("Focused field: \(String(describing: newValue))")
                }
            }
        }
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
