import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .edgesIgnoringSafeArea(.all)
            
            if viewModel.isLoading {
                ProgressView("Loading ideas...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .pink))
            } else if viewModel.ideas.isEmpty {
                Text("No ideas available")
                    .font(.title)
                    .foregroundColor(.secondary)
            } else {
                ZStack {
                    ForEach(viewModel.ideas.indices.reversed(), id: \.self) { index in
                        if index >= viewModel.currentIndex && index < viewModel.ideas.count {
                            IdeaCardView(idea: viewModel.ideas[index])
                                .zIndex(Double(viewModel.ideas.count - index))
                        }
                    }
                }
            }
        }
        .onAppear {
            print("HomeView appeared with \(viewModel.ideas.count) ideas, currentIndex=\(viewModel.currentIndex), titles: \(viewModel.ideas.map { $0.title }.prefix(10))")
        }
    }
}

#Preview("iPhone 14") {
    HomeView()
        .environmentObject(HomeViewModel(userId: nil))
}

#Preview("iPad Pro") {
    HomeView()
        .environmentObject(HomeViewModel(userId: nil))
}
