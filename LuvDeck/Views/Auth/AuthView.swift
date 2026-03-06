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
                
                VStack(spacing: 28) {
                    
                    Image("newlogosmile")
                        .resizable()
                        .scaledToFit()
                        .frame(width: min(geometry.size.width * 0.62, 260))
                        .padding(.top, geometry.size.height * 0.08)
                    
                    
                    VStack(spacing: 16) {
                        
                        Text(isSignUp ? "Get started" : "Welcome back")
                            .font(.system(size: min(geometry.size.width * 0.07, 28), weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, min(geometry.size.width * 0.08, 32))
                        
                        
                        TextField("Email", text: $email)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .focused($focusedField, equals: .email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding(.horizontal, 32)
                        
                        
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .focused($focusedField, equals: .password)
                            .padding(.horizontal, 32)
                        
                        
                        if isSignUp {
                            
                            SecureField("Confirm Password", text: $confirmPassword)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .focused($focusedField, equals: .confirmPassword)
                                .padding(.horizontal, 32)
                        }
                        
                        
                        if let error = viewModel.errorMessage {
                            
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.horizontal, 32)
                        }
                    }
                    
                    
                    Button(action: submit) {
                        
                        if viewModel.isLoading {
                            
                            ProgressView()
                        } else {
                            
                            Text(isSignUp ? "Create Account" : "Sign In")
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 32)
                    
                    
                    Button {
                        
                        isSignUp.toggle()
                        
                        email = ""
                        password = ""
                        confirmPassword = ""
                        viewModel.errorMessage = nil
                        
                    } label: {
                        
                        HStack {
                            
                            Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                            
                            Text(isSignUp ? "Sign In" : "Sign Up")
                                .fontWeight(.bold)
                        }
                    }
                    
                    
                    // IMPORTANT — Apple review requirement
                    Button {
                        
                        viewModel.continueAsGuest()
                        
                    } label: {
                        
                        Text("Continue without account >")
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 6)
                    
                    
                    Spacer()
                }
                .navigationBarHidden(true)
            }
        }
    }
    
    
    func submit() {
        
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
        
        guard !email.isEmpty else {
            viewModel.errorMessage = "Please enter email"
            return
        }
        
        guard !password.isEmpty else {
            viewModel.errorMessage = "Please enter password"
            return
        }
        
        guard password.count >= 6 else {
            viewModel.errorMessage = "Password must be at least 6 characters"
            return
        }
        
        
        if isSignUp {
            
            guard password == confirmPassword else {
                
                viewModel.errorMessage = "Passwords do not match"
                return
            }
            
            viewModel.signUp(email: email, password: password)
            
        } else {
            
            viewModel.signIn(email: email, password: password)
        }
    }
}
