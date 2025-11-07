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

        // Simplified tab bar – no aggressive styling
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground  // Use system default

        // Standard colors (let iOS handle selected/unselected)
        appearance.stackedLayoutAppearance.normal.iconColor = .secondaryLabel
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.secondaryLabel]
        appearance.stackedLayoutAppearance.selected.iconColor = .systemRed
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemRed]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
                    .environmentObject(homeVM)
                    .navigationBarHidden(true)
            }
            .tabItem { Label("Home", systemImage: "house.fill") }
            .tag(0)

            NavigationStack {
                AddDatesView(viewModel: datesVM)
                    .navigationBarHidden(false)  // Ensure bar is visible
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
        .onAppear {
            updateUserId()
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
