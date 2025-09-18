import SwiftUI

struct SwipeableCardView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    @State private var offset = CGSize.zero
    
    var body: some View {
        ZStack {
            if !viewModel.ideas.isEmpty {
                IdeaCardView(idea: viewModel.ideas[viewModel.currentIndex])
                    .offset(offset)
                    .animation(.spring(), value: offset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                offset = value.translation
                            }
                            .onEnded { value in
                                if value.translation.height < -100 { // Swipe up
                                    viewModel.nextIdea()
                                    offset = .zero
                                } else if value.translation.height > 100 { // Swipe down
                                    viewModel.previousIdea()
                                    offset = .zero
                                } else {
                                    offset = .zero
                                }
                            }
                    )
            } else {
                Text("No ideas available")
                    .font(.title)
                    .foregroundColor(.gray)
            }
        }
    }
}
