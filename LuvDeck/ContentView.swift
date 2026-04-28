// ContentView.swift — Clean Onboarding + Paywall Flow (Fixed)

import SwiftUI
import RevenueCat
import Firebase
import FirebaseAuth

struct ContentView: View {

    @EnvironmentObject var purchaseVM: PurchaseViewModel
    @EnvironmentObject var savedIdeasVM: SavedIdeasViewModel
    @EnvironmentObject var homeVM: HomeViewModel

    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var onboardingViewModel = OnboardingViewModel()
    @StateObject private var addDatesViewModel = AddDatesViewModel()

    @State private var currentScreen: AppScreen = .splash
    @State private var isReady = false

    var body: some View {
        ZStack {
            if isReady {
                switch currentScreen {

                case .splash:
                    SplashView()

                case .congratulations:
                    CongratulationsView {
                        withAnimation {
                            currentScreen = .welcome
                        }
                    }

                // MARK: - Welcome (Value Screens)
                case .welcome:
                    WelcomeOnboardingView {
                        withAnimation {
                            currentScreen = .onboarding
                        }
                    }
                    .environmentObject(onboardingViewModel)

                // MARK: - Onboarding Flow
                case .onboarding:
                    OnboardingView()
                        .environmentObject(authViewModel)
                        .environmentObject(onboardingViewModel)
                        .environmentObject(purchaseVM)

                // MARK: - Home
                case .home:
                    TabBarView(purchaseVM: purchaseVM)
                        .environmentObject(authViewModel)
                        .environmentObject(onboardingViewModel)
                        .environmentObject(addDatesViewModel)
                        .environmentObject(purchaseVM)
                        .environmentObject(savedIdeasVM)
                        .environmentObject(homeVM)

                // Auth kept for future use
                case .auth:
                    AuthView()
                        .environmentObject(authViewModel)
                        .environmentObject(onboardingViewModel)
                        .environmentObject(purchaseVM)
                }
            } else {
                SplashView()
            }
        }

        // MARK: - Initial Load
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                loadInitialState()
            }
        }

        // MARK: - Auth Events
        .onReceive(NotificationCenter.default.publisher(for: .authDidCompleteSignUp)) { _ in
            withAnimation { currentScreen = .welcome }
        }

        .onReceive(NotificationCenter.default.publisher(for: .authDidSignIn)) { _ in
            withAnimation {
                currentScreen = onboardingViewModel.onboardingCompleted ? .home : .welcome
            }
        }

        .onReceive(NotificationCenter.default.publisher(for: .authDidSignOut)) { _ in
            withAnimation { currentScreen = .welcome }
        }

        // MARK: - Paywall Flow
        .fullScreenCover(isPresented: $purchaseVM.triggerPaywallAfterOnboarding) {
            PaywallView(
                isPresented: $purchaseVM.triggerPaywallAfterOnboarding,
                purchaseVM: purchaseVM
            )
            .onDisappear {
                // Mark onboarding complete after paywall closes
                purchaseVM.completeOnboardingForCurrentUser()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        currentScreen = .home
                    }
                }
            }
        }

        // Animations
        .animation(.easeInOut(duration: 0.5), value: isReady)
        .animation(.easeInOut(duration: 0.4), value: currentScreen)
    }

    // MARK: - Initial State Loader
    private func loadInitialState() {
        if Auth.auth().currentUser != nil {
            onboardingViewModel.checkOnboardingStatus(
                userId: authViewModel.user?.id ?? Auth.auth().currentUser?.uid
            ) {
                DispatchQueue.main.async {
                    finishLoading()
                }
            }
        } else {
            DispatchQueue.main.async {
                finishLoading()
            }
        }
    }

    // MARK: - Decide First Screen After Splash
    private func finishLoading() {
        if !UserDefaults.hasSeenCongratulations {
            currentScreen = .congratulations
            UserDefaults.hasSeenCongratulations = true
        }
        else if !onboardingViewModel.onboardingCompleted {
            currentScreen = .welcome
        }
        else {
            currentScreen = .home
        }

        withAnimation {
            isReady = true
        }
    }
}
