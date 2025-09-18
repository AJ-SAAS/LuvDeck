import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    
    var body: some View {
        ZStack {
            Color(.systemGray6).edgesIgnoringSafeArea(.all)
            
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
                        if index >= viewModel.currentIndex {
                            IdeaCardView(idea: viewModel.ideas[index])
                                .zIndex(Double(viewModel.ideas.count - index))
                        }
                    }
                }
                
                // Top progress dots
                VStack {
                    HStack(spacing: 6) {
                        ForEach(0..<viewModel.ideas.count, id: \.self) { idx in
                            Circle()
                                .fill(idx == viewModel.currentIndex ? Color.pink : Color.gray.opacity(0.4))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.top, 50)
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            print("HomeView appeared with \(viewModel.ideas.count) ideas, currentIndex=\(viewModel.currentIndex)")
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
