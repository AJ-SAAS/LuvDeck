import SwiftUI

struct ContentView: View {
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var onboardingViewModel = OnboardingViewModel()
    @StateObject var addDatesViewModel: AddDatesViewModel
    @State private var showSplash = true

    init() {
        _addDatesViewModel = StateObject(wrappedValue: AddDatesViewModel())
    }

    var body: some View {
        Group {
            if showSplash {
                SplashView()
            } else {
                if !onboardingViewModel.onboardingCompleted {
                    OnboardingView()
                        .environmentObject(authViewModel)
                        .environmentObject(onboardingViewModel)
                } else if authViewModel.user == nil {
                    AuthView()
                        .environmentObject(authViewModel)
                        .environmentObject(onboardingViewModel)
                } else {
                    TabBarView()
                        .environmentObject(authViewModel)
                        .environmentObject(onboardingViewModel)
                        .environmentObject(addDatesViewModel)
                }
            }
        }
        .onAppear {
            // Show splash briefly before loading content
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    showSplash = false
                }
            }
        }
        .onChange(of: authViewModel.user) { _, newUser in
            if let userId = newUser?.id {
                addDatesViewModel.setUserId(userId)
            } else {
                addDatesViewModel.setUserId("")
                addDatesViewModel.events = []
            }
            onboardingViewModel.checkOnboardingStatus(
                userId: newUser?.id,
                didJustSignUp: authViewModel.didJustSignUp
            )
            authViewModel.didJustSignUp = false
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
        .environmentObject(OnboardingViewModel())
}
