import SwiftUI

struct TabBarView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var onboardingViewModel: OnboardingViewModel
    @StateObject private var homeVM = HomeViewModel(userId: nil)

    var body: some View {
        TabView {
            HomeView()
                .environmentObject(homeVM)
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            AddDatesView()
                .environmentObject(AddDatesViewModel(userId: authViewModel.user?.id))
                .tabItem {
                    Label("Dates", systemImage: "calendar")
                }

            SettingsView()
                .environmentObject(authViewModel)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .onAppear {
            if let uid = authViewModel.user?.id {
                homeVM.setUserId(uid) // Call the method to update userId
            }
        }
    }
}

#Preview("iPhone 14") {
    TabBarView()
        .environmentObject(AuthViewModel())
        .environmentObject(OnboardingViewModel())
}

#Preview("iPad Pro") {
    TabBarView()
        .environmentObject(AuthViewModel())
        .environmentObject(OnboardingViewModel())
}
