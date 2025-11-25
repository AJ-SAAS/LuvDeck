// ContentView.swift — FINAL FIXED & CRASH-FREE (2025)
// → Bookmark button works instantly after Paywall → Close

import SwiftUI
import RevenueCat
import Firebase
import FirebaseAuth

struct ContentView: View {
    // MARK: - Shared Global ViewModels (from LuvDeckApp.swift)
    @EnvironmentObject var purchaseVM: PurchaseViewModel        // ← Now from App
    @EnvironmentObject var savedIdeasVM: SavedIdeasViewModel    // ← ADDED: Fixes crash!
    @EnvironmentObject var homeVM: HomeViewModel                // ← ADDED: For HomeView

    // MARK: - Local ViewModels (still created here)
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
                        withAnimation { currentScreen = .auth }
                    }

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
                        .environmentObject(savedIdeasVM)   // ← CRITICAL: Bookmark works!
                        .environmentObject(homeVM)         // ← HomeViewModel available
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

        // NEW USER SIGNS UP → always onboarding
        .onReceive(NotificationCenter.default.publisher(for: .authDidCompleteSignUp)) { _ in
            withAnimation { currentScreen = .onboarding }
        }

        // EXISTING USER SIGNS IN → onboarding or home
        .onReceive(NotificationCenter.default.publisher(for: .authDidSignIn)) { _ in
            if onboardingViewModel.onboardingCompleted {
                withAnimation { currentScreen = .home }
            } else {
                withAnimation { currentScreen = .onboarding }
            }
        }

        // USER SIGNS OUT
        .onReceive(NotificationCenter.default.publisher(for: .authDidSignOut)) { _ in
            withAnimation { currentScreen = .auth }
        }

        // PAYWALL AFTER ONBOARDING → Close → Home (NOW WORKS WITHOUT CRASH)
        .fullScreenCover(isPresented: $purchaseVM.triggerPaywallAfterOnboarding) {
            PaywallView(
                isPresented: $purchaseVM.triggerPaywallAfterOnboarding,
                purchaseVM: purchaseVM
            )
            .onDisappear {
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
        if Auth.auth().currentUser != nil {
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
