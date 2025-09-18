import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading ideas...")
                        .padding()
                } else if viewModel.ideas.isEmpty {
                    Text("No ideas available")
                        .font(.title)
                        .foregroundColor(.secondary)
                } else {
                    VStack {
                        Text(viewModel.ideas[viewModel.currentIndex].title)
                            .font(.title)
                        Text(viewModel.ideas[viewModel.currentIndex].description)
                            .font(.body)
                            .padding(.bottom, 20)
                        HStack(spacing: 10) {
                            Button("Previous") { viewModel.previousIdea() }
                                .disabled(viewModel.currentIndex == 0)
                            Button("Like") { viewModel.likeIdea(viewModel.ideas[viewModel.currentIndex]) }
                            Button("Share") { viewModel.shareIdea(viewModel.ideas[viewModel.currentIndex]) }
                            Button("Next") { viewModel.nextIdea() }
                                .disabled(viewModel.currentIndex >= viewModel.ideas.count - 1)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                }
            }
            .navigationTitle("LuvDeck")
        }
        .onAppear {
            print("HomeView appeared with isLoading=\(viewModel.isLoading), ideas=\(viewModel.ideas.count)")
        }
    }
}

#Preview("iPhone 14") {
    HomeView()
        .environmentObject(HomeViewModel(userId: "testUser"))
}

#Preview("iPad Pro") {
    HomeView()
        .environmentObject(HomeViewModel(userId: "testUser"))
}
