// ContentView.swift
import SwiftUI
import RevenueCat

struct ContentView: View {
    @EnvironmentObject var purchaseVM: PurchaseViewModel

    @StateObject var authViewModel = AuthViewModel()
    @StateObject var onboardingViewModel = OnboardingViewModel()
    @StateObject var addDatesViewModel = AddDatesViewModel()

    @State private var currentScreen: AppScreen = .splash
    @State private var showPaywall = false
    @State private var isReady = false

    var body: some View {
        ZStack {
            if isReady {
                switch currentScreen {
                case .splash:
                    SplashView()

                case .congratulations:
                    CongratulationsView {
                        withAnimation { currentScreen = .auth }
                    }

                case .auth:
                    AuthView()
                        .environmentObject(authViewModel)
                        .environmentObject(onboardingViewModel)

                case .onboarding:
                    OnboardingView()
                        .environmentObject(authViewModel)
                        .environmentObject(onboardingViewModel)
                        .environmentObject(purchaseVM)
                        .onChange(of: onboardingViewModel.onboardingCompleted) { _, newValue in
                            if newValue && !purchaseVM.isPremium {
                                showPaywall = true
                            } else if newValue {
                                withAnimation { currentScreen = .home }
                            }
                        }

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

        // Fresh sign-up → straight to onboarding
        .onReceive(NotificationCenter.default.publisher(for: .authDidCompleteSignUp)) { _ in
            print("Fresh sign-up detected → going to onboarding")
            withAnimation {
                currentScreen = .onboarding
            }
        }

        // Paywall after onboarding (only if not premium)
        .onReceive(NotificationCenter.default.publisher(for: .showPaywallAfterOnboarding)) { _ in
            if !purchaseVM.isPremium {
                showPaywall = true
            }
        }

        // Full-screen paywall
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(isPresented: $showPaywall, purchaseVM: purchaseVM)
                .onDisappear {
                    withAnimation { currentScreen = .home }
                }
        }
    }

    // MARK: - Load Initial App State
    private func loadInitialState() {
        if authViewModel.user != nil {
            // Existing user → check onboarding status from Firestore
            onboardingViewModel.checkOnboardingStatus(
                userId: authViewModel.user?.id,
                didJustSignUp: false
            ) {
                DispatchQueue.main.async { finishLoading() }
            }
        } else {
            // No user → go to auth or congratulations
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
        } else if !purchaseVM.isPremium {
            showPaywall = true
        } else {
            currentScreen = .home
        }
        withAnimation { isReady = true }
    }
}
