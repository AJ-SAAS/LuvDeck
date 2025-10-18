import SwiftUI
import FirebaseAuth

struct TabBarView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var onboardingViewModel: OnboardingViewModel
    @StateObject private var homeVM: HomeViewModel
    @StateObject private var datesVM: AddDatesViewModel
    @State private var selectedTab: Int = 1

    init() {
        let userId = Auth.auth().currentUser?.uid
        _homeVM = StateObject(wrappedValue: HomeViewModel(userId: userId))
        _datesVM = StateObject(wrappedValue: AddDatesViewModel(userId: userId))
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
                    .environmentObject(homeVM)
                    .navigationTitle("Home")
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(0)
            .onAppear { print("Home tab selected") }

            NavigationStack {
                AddDatesView()
                    .environmentObject(datesVM)
                    .navigationTitle("Dates")
            }
            .tabItem {
                Label("Dates", systemImage: "calendar")
            }
            .tag(1)
            .onAppear { print("Dates tab selected") }

            NavigationStack {
                SettingsView()
                    .environmentObject(authViewModel)
                    .navigationTitle("Settings")
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(2)
            .onAppear { print("Settings tab selected") }
        }
        .onChange(of: selectedTab) { _, newTab in
            print("Tab changed to: \(newTab)")
        }
        .onAppear {
            if let uid = authViewModel.user?.id {
                homeVM.setUserId(uid)
                datesVM.setUserId(uid)
                print("TabBarView onAppear: Set userId \(uid) for homeVM and datesVM")
            } else {
                print("TabBarView onAppear: No userId available")
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
