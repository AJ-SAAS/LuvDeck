import SwiftUI

struct ContentView: View {
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var onboardingViewModel = OnboardingViewModel()
    @State private var showSplash = true
    
    var body: some View {
        Group {
            if showSplash {
                SplashView()
            } else {
                // Step 1: Show onboarding only if not completed
                if !onboardingViewModel.onboardingCompleted {
                    OnboardingView()
                        .environmentObject(authViewModel)
                        .environmentObject(onboardingViewModel)
                }
                // Step 2: After onboarding, show auth if no user
                else if authViewModel.user == nil {
                    AuthView()
                        .environmentObject(authViewModel)
                        .environmentObject(onboardingViewModel)
                }
                // Step 3: User signed in and onboarding completed
                else {
                    TabBarView()
                        .environmentObject(authViewModel)
                        .environmentObject(onboardingViewModel)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation {
                    showSplash = false
                }
            }
        }
        .onChange(of: authViewModel.user) { _, newUser in
            // If the user just signed up, mark onboarding as complete if needed
            onboardingViewModel.checkOnboardingStatus(userId: newUser?.id, didJustSignUp: authViewModel.didJustSignUp)
            
            // Reset the flag
            authViewModel.didJustSignUp = false
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
        .environmentObject(OnboardingViewModel())
}
