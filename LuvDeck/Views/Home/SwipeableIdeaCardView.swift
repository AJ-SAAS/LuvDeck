import SwiftUI

struct SwipeableCardView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    @State private var offset = CGSize.zero
    @State private var isDragging = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if !viewModel.ideas.isEmpty {
                    IdeaCardView(idea: viewModel.ideas[viewModel.currentIndex])
                        .frame(
                            width: geometry.size.width * 0.95, // Increased from 0.9 to 0.95
                            height: geometry.size.height
                        )
                        .offset(offset)
                        .scaleEffect(isDragging ? 0.97 : 1.0)
                        .rotationEffect(.degrees(Double(offset.height / 20)))
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    offset = value.translation
                                    isDragging = true
                                }
                                .onEnded { value in
                                    handleSwipe(value: value)
                                    isDragging = false
                                }
                        )
                        .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.75), value: offset)
                } else {
                    Text("No ideas available")
                        .font(.title)
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
    
    private func handleSwipe(value: DragGesture.Value) {
        let swipeThreshold: CGFloat = 150
        if value.translation.height < -swipeThreshold {
            viewModel.nextIdea()
            offset = .zero
        } else if value.translation.height > swipeThreshold {
            viewModel.previousIdea()
            offset = .zero
        } else {
            offset = .zero
        }
    }
}
