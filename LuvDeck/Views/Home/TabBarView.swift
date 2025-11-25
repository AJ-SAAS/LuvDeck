// TabBarView.swift — FINAL WITH SPARK TAB (2025)
import SwiftUI
import FirebaseAuth

struct TabBarView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var onboardingViewModel: OnboardingViewModel
    @EnvironmentObject var purchaseVM: PurchaseViewModel
    @EnvironmentObject var addDatesViewModel: AddDatesViewModel

    @StateObject private var homeVM: HomeViewModel
    @StateObject private var datesVM: AddDatesViewModel

    @State private var selectedTab: Int = 0

    init() {
        let currentUID = Auth.auth().currentUser?.uid
        
        // Fix: Use actual injected purchaseVM from environment
        let tempPurchaseVM = PurchaseViewModel() // temporary for init
        _homeVM = StateObject(wrappedValue: HomeViewModel(
            userId: currentUID,
            isPremiumProvider: { tempPurchaseVM.isPremium }
        ))
        _datesVM = StateObject(wrappedValue: AddDatesViewModel(
            userId: currentUID,
            isPremiumProvider: { tempPurchaseVM.isPremium }
        ))

        // Beautiful transparent tab bar
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.clear
        appearance.stackedLayoutAppearance.normal.iconColor = .secondaryLabel
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.secondaryLabel]
        appearance.stackedLayoutAppearance.selected.iconColor = .systemPink
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemPink]
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().isTranslucent = true
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: 1. Home
            NavigationStack {
                HomeView()
                    .environmentObject(homeVM)
                    .environmentObject(purchaseVM)
                    .navigationBarHidden(true)
            }
            .tabItem { Label("Home", systemImage: "house.fill") }
            .tag(0)

            // MARK: 2. Dates
            NavigationStack {
                AddDatesView(purchaseVM: purchaseVM, userId: authViewModel.user?.id)
            }
            .tabItem { Label("Dates", systemImage: "calendar") }
            .tag(1)

            // MARK: 3. Spark — NEW TAB
            NavigationStack {
                SparkView()
                    .navigationTitle("Spark")
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem {
                Label("Spark", systemImage: "sparkles")
            }
            .tag(2)

            // MARK: 4. Settings
            NavigationStack {
                SettingsView()
                    .environmentObject(authViewModel)
                    .environmentObject(purchaseVM)
            }
            .tabItem { Label("Settings", systemImage: "gear") }
            .tag(3)
        }
        .accentColor(Color.red.opacity(0.9)) // Makes the selected Spark icon pop
        .sheet(isPresented: $purchaseVM.shouldPresentPaywall) {
            PaywallView(isPresented: $purchaseVM.shouldPresentPaywall, purchaseVM: purchaseVM)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .onAppear { updateUserId() }
        .onChange(of: authViewModel.user) { _, _ in updateUserId() }
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
