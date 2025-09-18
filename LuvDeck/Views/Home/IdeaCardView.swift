import SwiftUI

struct IdeaCardView: View {
    let idea: Idea
    @EnvironmentObject var viewModel: HomeViewModel
    @State private var offset = CGSize.zero
    @State private var isDragging = false
    private let swipeThreshold: CGFloat = 150
    
    var body: some View {
        VStack(spacing: 0) {
            if UIImage(named: idea.imageName) != nil {
                Image(idea.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.height / 2)
                    .clipped()
                    .cornerRadius(10)
            } else {
                Image("defaultIdeaImage")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: UIScreen.main.bounds.height / 2)
                    .clipped()
                    .cornerRadius(10)
            }
            
            VStack(spacing: 16) {
                Text(idea.title)
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                
                Text(idea.description)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                
                HStack(spacing: 16) {
                    statView(title: "Difficulty", value: idea.difficultyStars)
                    statView(title: "Category", value: idea.category)
                    statView(title: "Level", value: idea.level.rawValue)
                }
                .padding(.horizontal, 16)
                
                HStack(spacing: 70) {
                    Button { viewModel.saveIdea(idea) } label: {
                        Image(systemName: "bookmark.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                            .padding(14)
                            .background(Color.white.opacity(0.9))
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    
                    Button { viewModel.likeIdea(idea) } label: {
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
            .padding(.horizontal, 32)
            .padding(.top, 20)
            .padding(.bottom, 36)
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
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
        if value.translation.height < -swipeThreshold { viewModel.nextIdea() }
        else if value.translation.height > swipeThreshold { viewModel.previousIdea() }
        offset = .zero
    }
    
    private func statView(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.caption)
                .foregroundColor(.pink)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    IdeaCardView(idea: Idea(
        id: UUID(),
        title: "Love Note Attack",
        description: "Hide sticky notes with little compliments in their bag, mirror, or car.",
        category: "Random",
        difficulty: 3,
        impressive: 3,
        imageName: "placeholder_1",
        level: .cute
    ))
    .environmentObject(HomeViewModel(userId: nil))
    .previewLayout(.sizeThatFits)
    .padding()
    .background(Color(.systemGray6))
}
