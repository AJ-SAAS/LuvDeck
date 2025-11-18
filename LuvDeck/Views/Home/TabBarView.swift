// TabBarView.swift
import SwiftUI
import FirebaseAuth

struct TabBarView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var onboardingViewModel: OnboardingViewModel
    @EnvironmentObject var purchaseVM: PurchaseViewModel        // ← Use injected one
    @EnvironmentObject var addDatesViewModel: AddDatesViewModel

    @StateObject private var homeVM: HomeViewModel
    @StateObject private var datesVM: AddDatesViewModel

    @State private var selectedTab: Int = 0

    init() {
        let currentUID = Auth.auth().currentUser?.uid
        
        // Use the injected purchaseVM for isPremium
        let injectedPurchaseVM = PurchaseViewModel() // temporary for closure
        _homeVM = StateObject(wrappedValue: HomeViewModel(
            userId: currentUID,
            isPremiumProvider: { injectedPurchaseVM.isPremium }
        ))
        _datesVM = StateObject(wrappedValue: AddDatesViewModel(
            userId: currentUID,
            isPremiumProvider: { injectedPurchaseVM.isPremium }
        ))

        // Tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.stackedLayoutAppearance.normal.iconColor = .secondaryLabel
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.secondaryLabel]
        appearance.stackedLayoutAppearance.selected.iconColor = .systemRed
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemRed]
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().isTranslucent = true
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
                    .environmentObject(homeVM)
                    .environmentObject(purchaseVM)
                    .navigationBarHidden(true)
            }
            .tabItem { Label("Home", systemImage: "house.fill") }
            .tag(0)

            NavigationStack {
                AddDatesView(purchaseVM: purchaseVM, userId: authViewModel.user?.id)
            }
            .tabItem { Label("Dates", systemImage: "calendar") }
            .tag(1)

            NavigationStack {
                SettingsView()
                    .environmentObject(authViewModel)
                    .environmentObject(purchaseVM)
            }
            .tabItem { Label("Settings", systemImage: "gear") }
            .tag(2)
        }
        .sheet(isPresented: $purchaseVM.shouldPresentPaywall) {
            PaywallView(isPresented: $purchaseVM.shouldPresentPaywall, purchaseVM: purchaseVM)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .onAppear { updateUserId() }
        .onChange(of: authViewModel.user) { _, _ in updateUserId() }
        
        // THIS IS WHAT SHOWS THE PAYWALL AFTER ONBOARDING
        .onChange(of: purchaseVM.triggerPaywallAfterOnboarding) { newValue in
            if newValue {
                purchaseVM.shouldPresentPaywall = true
                purchaseVM.triggerPaywallAfterOnboarding = false
            }
        }
    }

    private func updateUserId() {
        let uid = authViewModel.user?.id
        homeVM.setUserId(uid)
        datesVM.setUserId(uid)
    }
}
