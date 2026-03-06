import SwiftUI
import FirebaseAuth

struct TabBarView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var onboardingViewModel: OnboardingViewModel
    @EnvironmentObject var purchaseVM: PurchaseViewModel
    @EnvironmentObject var addDatesViewModel: AddDatesViewModel

    @StateObject private var homeVM: HomeViewModel
    @StateObject private var datesVM: AddDatesViewModel
    @StateObject private var sparkVM = SparkViewModel()
    @State private var selectedTab: Int = 0

    init(purchaseVM: PurchaseViewModel) {
        let currentUID = Auth.auth().currentUser?.uid

        _homeVM = StateObject(wrappedValue: HomeViewModel(
            userId: currentUID,
            isPremiumProvider: { purchaseVM.isPremium }
        ))
        _datesVM = StateObject(wrappedValue: AddDatesViewModel(
            userId: currentUID,
            isPremiumProvider: { purchaseVM.isPremium }
        ))

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

            // 1) Home
            NavigationStack {
                HomeView()
                    .environmentObject(homeVM)
                    .environmentObject(purchaseVM)
                    .navigationBarHidden(true)
            }
            .tabItem { Label("Home", systemImage: "house.fill") }
            .tag(0)

            // 2) Spark
            NavigationStack {
                SparkView(vm: sparkVM, purchaseVM: purchaseVM)
                    .navigationTitle("Spark")
                    .navigationBarTitleDisplayMode(.large)
            }
            .tabItem { Label("Spark", systemImage: "sparkles") }
            .tag(1)

            // 3) Dates
            NavigationStack {
                AddDatesView(purchaseVM: purchaseVM, userId: authViewModel.user?.id)
            }
            .tabItem { Label("Dates", systemImage: "calendar") }
            .tag(2)

            // 4) Settings
            NavigationStack {
                SettingsView()
                    .environmentObject(authViewModel)
                    .environmentObject(purchaseVM)
            }
            .tabItem { Label("Settings", systemImage: "gear") }
            .tag(3)
        }
        .accentColor(Color.red.opacity(0.9))
        .sheet(isPresented: $purchaseVM.shouldPresentPaywall) {
            PaywallView(isPresented: $purchaseVM.shouldPresentPaywall, purchaseVM: purchaseVM)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .onAppear { updateUserId() }
        .onChange(of: authViewModel.user) { _, _ in updateUserId() }
        .onChange(of: purchaseVM.triggerPaywallAfterOnboarding) { _, newValue in
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
