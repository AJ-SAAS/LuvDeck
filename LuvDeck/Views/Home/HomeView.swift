import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                    .ignoresSafeArea(.all)
                
                if viewModel.isLoading {
                    ProgressView("Loading ideas...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .pink))
                } else if viewModel.ideas.isEmpty {
                    Text("No ideas available")
                        .font(.title)
                        .foregroundColor(.secondary)
                } else {
                    SwipeableCardView()
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height - geometry.safeAreaInsets.bottom - 10
                        )
                        .ignoresSafeArea(edges: .top) // Fixed: Use edges: .top
                }
            }
            .onAppear {
                print("HomeView appeared with \(viewModel.ideas.count) ideas, currentIndex=\(viewModel.currentIndex), titles: \(viewModel.ideas.map { $0.title }.prefix(10))")
            }
        }
    }
}

#Preview("iPhone 14") {
    HomeView()
        .environmentObject(HomeViewModel(userId: nil))
        .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
}

#Preview("iPad Pro") {
    HomeView()
        .environmentObject(HomeViewModel(userId: nil))
        .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch) (6th generation)"))
}
