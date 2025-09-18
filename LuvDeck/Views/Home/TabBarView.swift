import SwiftUI

struct TabBarView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var onboardingViewModel: OnboardingViewModel
    
    var body: some View {
        TabView {
            HomeView()
                .environmentObject(authViewModel)
                .environmentObject(HomeViewModel(userId: authViewModel.user?.id))
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            SettingsView()
                .environmentObject(authViewModel)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .onAppear {
            print("TabBarView appeared with userId: \(authViewModel.user?.id ?? "nil")")
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
