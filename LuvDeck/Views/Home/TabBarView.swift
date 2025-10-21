import SwiftUI
import FirebaseAuth

struct TabBarView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var onboardingViewModel: OnboardingViewModel
    @StateObject private var homeVM: HomeViewModel
    @StateObject private var datesVM: AddDatesViewModel
    @State private var selectedTab: Int = 0
    @State private var didAppear: Bool = false // For lazy logo rendering if needed

    init() {
        let userId = Auth.auth().currentUser?.uid
        _homeVM = StateObject(wrappedValue: HomeViewModel(userId: userId))
        _datesVM = StateObject(wrappedValue: AddDatesViewModel(userId: userId))
    }

    var body: some View {
        TabView(selection: $selectedTab) {

            // MARK: - Home Tab
            NavigationStack {
                VStack(spacing: 0) {

                    // Preloaded logo (top-left)
                    HStack {
                        Image("luvdecksmall")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 260, height: 260) // Big logo
                            .padding(.leading, 2)  // flush with left edge
                            .padding(.top, -6)     // lift slightly to reduce gap
                        
                        Spacer()
                    }
                    .frame(height: 70) // reduces space below logo

                    // Main content (Idea cards)
                    HomeView()
                        .environmentObject(homeVM)
                        .navigationBarHidden(true)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .ignoresSafeArea(edges: .bottom)
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(0)
            .onAppear {
                print("Home tab selected")
                
                // Prevent initial layout/animation glitch
                UIView.setAnimationsEnabled(false)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    UIView.setAnimationsEnabled(true)
                }
            }

            // MARK: - Dates Tab
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

            // MARK: - Settings Tab
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
            // Preload logo to eliminate white flash / lag
            _ = UIImage(named: "luvdecksmall")
            
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
