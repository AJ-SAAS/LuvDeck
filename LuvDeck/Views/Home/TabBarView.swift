import SwiftUI
import FirebaseAuth

struct TabBarView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var onboardingViewModel: OnboardingViewModel
    @StateObject private var homeVM: HomeViewModel
    @StateObject private var datesVM: AddDatesViewModel
    @State private var selectedTab: Int = 0

    init() {
        let currentUID = Auth.auth().currentUser?.uid
        _homeVM = StateObject(wrappedValue: HomeViewModel(userId: currentUID))
        _datesVM = StateObject(wrappedValue: AddDatesViewModel(userId: currentUID))

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
                    .navigationBarHidden(true)
                    .toolbarBackground(.hidden, for: .tabBar)  // ← FIX: No tab bar interference
            }
            .tabItem { Label("Home", systemImage: "house.fill") }
            .tag(0)

            NavigationStack {
                AddDatesView(viewModel: datesVM)
                    .navigationBarHidden(false)
            }
            .tabItem { Label("Dates", systemImage: "calendar") }
            .tag(1)

            NavigationStack {
                SettingsView()
                    .environmentObject(authViewModel)
                    .navigationBarHidden(true)
            }
            .tabItem { Label("Settings", systemImage: "gear") }
            .tag(2)
        }
        .background(Color.clear)
        .ignoresSafeArea(edges: .all)
        .onAppear {
            updateUserId()
            UITabBar.appearance().backgroundColor = .clear
            UITabBar.appearance().isTranslucent = true
        }
        .onChange(of: authViewModel.user) { _, _ in
            updateUserId()
        }
    }

    private func updateUserId() {
        let uid = authViewModel.user?.id
        homeVM.setUserId(uid)
        datesVM.setUserId(uid)
    }
}

#Preview {
    TabBarView()
        .environmentObject(AuthViewModel())
        .environmentObject(OnboardingViewModel())
}
