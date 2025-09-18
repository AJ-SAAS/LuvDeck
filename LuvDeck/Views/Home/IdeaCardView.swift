import SwiftUI

struct IdeaCardView: View {
    let idea: Idea
    @EnvironmentObject var viewModel: HomeViewModel
    @State private var offset = CGSize.zero
    @State private var isDragging = false
    
    private let swipeThreshold: CGFloat = 150
    
    var body: some View {
        VStack(spacing: 0) {
            // Top half image
            Image(idea.imageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: UIScreen.main.bounds.height / 2)
                .clipped()
            
            // Content below image
            VStack(spacing: 24) { // slightly more space overall
                // Title
                Text(idea.title)
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)
                
                // Description
                Text(idea.description)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                
                // Stats row (more compact)
                HStack(spacing: 12) { // reduced spacing
                    statView(title: "Difficulty", value: "\(idea.difficulty)")
                    statView(title: "Category", value: idea.category)
                    statView(title: "Impressiveness", value: "\(idea.impressive)")
                }
                
                // Action icons
                HStack(spacing: 70) { // slightly more space between icons
                    Button {
                        viewModel.saveIdea(idea)
                    } label: {
                        Image(systemName: "bookmark.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                            .padding(14)
                            .background(Color.white.opacity(0.9))
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    
                    Button {
                        viewModel.likeIdea(idea)
                    } label: {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.title2)
                            .padding(14)
                            .background(Color.white.opacity(0.9))
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                }
                .padding(.top, 12)
            }
            .padding(.horizontal, 32) // more horizontal padding
            .padding(.top, 20)
            .padding(.bottom, 36)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
        .offset(y: offset.height)
        .rotationEffect(.degrees(Double(offset.height / 20)))
        .scaleEffect(isDragging ? 0.97 : 1.0)
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
        .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.75, blendDuration: 0.75), value: offset)
    }
    
    private func handleSwipe(value: DragGesture.Value) {
        if value.translation.height < -swipeThreshold { // Swipe up
            viewModel.nextIdea()
        } else if value.translation.height > swipeThreshold { // Swipe down
            viewModel.previousIdea()
        }
        offset = .zero
    }
    
    private func statView(title: String, value: String) -> some View {
        VStack(spacing: 2) { // reduced spacing inside each stat
            Text(value)
                .font(.headline)
                .bold()
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}
