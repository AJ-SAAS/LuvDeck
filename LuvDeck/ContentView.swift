import SwiftUI

struct ContentView: View {
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var onboardingViewModel = OnboardingViewModel()
    
    var body: some View {
        Group {
            if authViewModel.user == nil {
                AuthView()
                    .environmentObject(authViewModel)
                    .onAppear {
                        print("Rendering AuthView: user is nil")
                    }
            } else if !onboardingViewModel.onboardingCompleted {
                OnboardingView()
                    .environmentObject(authViewModel)
                    .environmentObject(onboardingViewModel)
                    .onAppear {
                        print("Rendering OnboardingView: onboardingCompleted=\(onboardingViewModel.onboardingCompleted), currentStep=\(onboardingViewModel.currentStep)")
                    }
            } else {
                TabBarView()
                    .environmentObject(authViewModel)
                    .environmentObject(onboardingViewModel)
                    .onAppear {
                        print("Rendering TabBarView: onboardingCompleted=\(onboardingViewModel.onboardingCompleted)")
                    }
            }
        }
        .onChange(of: authViewModel.user) { _, newUser in
            print("User changed: \(newUser?.id ?? "nil")")
            onboardingViewModel.checkOnboardingStatus(userId: newUser?.id, didJustSignUp: authViewModel.didJustSignUp)
        }
        .onChange(of: onboardingViewModel.onboardingCompleted) { _, completed in
            print("Onboarding completed changed: \(completed)")
        }
        .onChange(of: onboardingViewModel.currentStep) { _, step in
            print("Current step changed: \(step)")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
        .environmentObject(OnboardingViewModel())
}
