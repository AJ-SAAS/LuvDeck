import SwiftUI
import FirebaseAuth

struct TabBarView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var onboardingViewModel: OnboardingViewModel
    @StateObject private var homeVM: HomeViewModel
    @StateObject private var datesVM: AddDatesViewModel
    @State private var selectedTab: Int = 0

    init() {
        let userId = Auth.auth().currentUser?.uid
        _homeVM = StateObject(wrappedValue: HomeViewModel(userId: userId))
        _datesVM = StateObject(wrappedValue: AddDatesViewModel(userId: userId))

        // Configure tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white

        // Unselected = black
        appearance.stackedLayoutAppearance.normal.iconColor = .black
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.black]

        // Selected = red
        appearance.stackedLayoutAppearance.selected.iconColor = .systemRed
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemRed]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {

            // MARK: Home Tab
            NavigationStack {
                HomeView()
                    .environmentObject(homeVM)
                    .navigationBarHidden(true)
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)

            // MARK: Dates Tab
            NavigationStack {
                AddDatesView()
                    .environmentObject(datesVM)
                    .navigationBarHidden(true)
            }
            .tabItem {
                Label("Dates", systemImage: "calendar")
            }
            .tag(1)

            // MARK: Settings Tab
            NavigationStack {
                SettingsView()
                    .environmentObject(authViewModel)
                    .navigationBarHidden(true)
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(2)
        }
        .onAppear {
            if let uid = authViewModel.user?.id {
                homeVM.setUserId(uid)
                datesVM.setUserId(uid)
            }
        }
    }
}
