// ContentView.swift — FINAL FIXED VERSION (100% stable)
import SwiftUI
import RevenueCat

struct ContentView: View {
    @StateObject private var purchaseVM = PurchaseViewModel()
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var onboardingViewModel = OnboardingViewModel()
    @StateObject private var addDatesViewModel = AddDatesViewModel()

    @State private var currentScreen: AppScreen = .splash
    @State private var isReady = false

    var body: some View {
        ZStack {
            if isReady {
                switch currentScreen {
                case .splash: SplashView()
                case .congratulations:
                    CongratulationsView { withAnimation { currentScreen = .auth } }
                case .auth:
                    AuthView()
                        .environmentObject(authViewModel)
                        .environmentObject(onboardingViewModel)
                        .environmentObject(purchaseVM)
                case .onboarding:
                    OnboardingView()
                        .environmentObject(authViewModel)
                        .environmentObject(onboardingViewModel)
                        .environmentObject(purchaseVM)
                case .home:
                    TabBarView()
                        .environmentObject(authViewModel)
                        .environmentObject(onboardingViewModel)
                        .environmentObject(addDatesViewModel)
                        .environmentObject(purchaseVM)
                }
            } else {
                SplashView()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                loadInitialState()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .authDidCompleteSignUp)) { _ in
            withAnimation { currentScreen = .onboarding }
        }
        .onReceive(NotificationCenter.default.publisher(for: .authDidSignOut)) { _ in
            withAnimation { currentScreen = .auth }
        }

        // PERFECT PAYWALL FLOW — NO FLASH, NO CRASH
        .fullScreenCover(isPresented: $purchaseVM.triggerPaywallAfterOnboarding) {
            PaywallView(
                isPresented: $purchaseVM.triggerPaywallAfterOnboarding,
                purchaseVM: purchaseVM
            )
            .onDisappear {
                // This is the ONLY place onboarding is marked complete
                purchaseVM.completeOnboardingForCurrentUser()
                
                withAnimation(.easeInOut(duration: 0.35)) {
                    currentScreen = .home
                }
            }
        }
        .animation(.easeInOut(duration: 0.5), value: isReady)
        .animation(.easeInOut(duration: 0.35), value: currentScreen)
    }

    private func loadInitialState() {
        if authViewModel.user != nil {
            onboardingViewModel.checkOnboardingStatus(
                userId: authViewModel.user?.id,
                didJustSignUp: false
            ) {
                DispatchQueue.main.async { finishLoading() }
            }
        } else {
            DispatchQueue.main.async { finishLoading() }
        }
    }

    private func finishLoading() {
        if !UserDefaults.hasSeenCongratulations {
            currentScreen = .congratulations
            UserDefaults.hasSeenCongratulations = true
        } else if authViewModel.user == nil {
            currentScreen = .auth
        } else if !onboardingViewModel.onboardingCompleted {
            currentScreen = .onboarding
        } else {
            currentScreen = .home
        }
        
        withAnimation { isReady = true }
    }
}
