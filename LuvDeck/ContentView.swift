// ContentView.swift
import SwiftUI
import RevenueCat

struct ContentView: View {
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var onboardingViewModel = OnboardingViewModel()
    @StateObject var addDatesViewModel: AddDatesViewModel
    
    @State private var currentScreen: AppScreen = .splash
    @State private var showPaywall = false
    @State private var isReady = false

    init() {
        _addDatesViewModel = StateObject(wrappedValue: AddDatesViewModel())
    }

    var body: some View {
        ZStack {
            if isReady {
                switch currentScreen {
                case .splash: EmptyView()
                case .congratulations:
                    CongratulationsView {
                        withAnimation { currentScreen = .auth }
                    }
                    .transition(.opacity)
                case .auth:
                    AuthView()
                        .environmentObject(authViewModel)
                        .environmentObject(onboardingViewModel)
                        .transition(.move(edge: .leading))
                case .onboarding:
                    OnboardingView()
                        .environmentObject(authViewModel)
                        .environmentObject(onboardingViewModel)
                        .environmentObject(PurchaseViewModel())
                        .onChange(of: onboardingViewModel.onboardingCompleted) { newValue in
                            if newValue && authViewModel.didJustSignUp {
                                showPaywall = true
                            } else if newValue {
                                withAnimation { currentScreen = .home }
                            }
                        }
                        .transition(.move(edge: .leading))
                case .home:
                    TabBarView()
                        .environmentObject(authViewModel)
                        .environmentObject(onboardingViewModel)
                        .environmentObject(addDatesViewModel)
                        .transition(.move(edge: .leading))
                }
            } else {
                SplashView()
                    .transition(.opacity)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                loadInitialState()
            }
        }
        .onChange(of: authViewModel.user) { newValue in
            if let uid = newValue?.id {
                addDatesViewModel.setUserId(uid)
            } else {
                addDatesViewModel.setUserId("")
                addDatesViewModel.events = []
            }

            onboardingViewModel.checkOnboardingStatus(
                userId: newValue?.id,
                didJustSignUp: authViewModel.didJustSignUp
            ) { }

            authViewModel.didJustSignUp = false
        }
        .onReceive(NotificationCenter.default.publisher(for: .authDidCompleteSignUp)) { _ in
            withAnimation { currentScreen = .onboarding }
        }
        .onReceive(NotificationCenter.default.publisher(for: .authDidSignOut)) { _ in
            withAnimation { currentScreen = .auth }
        }
        .onReceive(NotificationCenter.default.publisher(for: .showPaywallAfterOnboarding)) { _ in
            showPaywall = true
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(isPresented: $showPaywall)
                .environmentObject(PurchaseViewModel())
                .onDisappear {
                    withAnimation { currentScreen = .home }
                }
        }
    }

    private func loadInitialState() {
        if authViewModel.user != nil {
            onboardingViewModel.checkOnboardingStatus(
                userId: authViewModel.user?.id,
                didJustSignUp: false
            ) {
                DispatchQueue.main.async { self.finishLoading() }
            }
        } else {
            DispatchQueue.main.async { self.finishLoading() }
        }
    }

    private func finishLoading() {
        if !UserDefaults.hasSeenCongratulations {
            currentScreen = .congratulations
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
