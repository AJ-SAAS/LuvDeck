import SwiftUI

struct IdeaCardView: View {
    let idea: Idea
    @EnvironmentObject var viewModel: HomeViewModel
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top: Image (65% of card height)
                Group {
                    if UIImage(named: idea.imageName) != nil {
                        Image(idea.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(
                                width: geometry.size.width,
                                height: geometry.size.height * 0.65
                            )
                            .clipped()
                            // Optional: Adjust to focus on top of 1440x2560 image
                            // .offset(y: -geometry.size.height * 0.05)
                    } else {
                        Image("defaultIdeaImage")
                            .resizable()
                            .scaledToFill()
                            .frame(
                                width: geometry.size.width,
                                height: geometry.size.height * 0.65
                            )
                            .clipped()
                            // Optional: Adjust to focus on top of default image
                            // .offset(y: -geometry.size.height * 0.05)
                    }
                }
                .frame(height: geometry.size.height * 0.65)
                
                // Bottom: Content (35% of card height)
                VStack(spacing: 8) {
                    Text(idea.title)
                        .font(.system(size: 24, weight: .bold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .lineLimit(2)
                    
                    Text(idea.description)
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack(spacing: 16) {
                        statView(title: "Difficulty", value: idea.difficultyStars, icon: "star.fill")
                        statView(title: "Category", value: idea.category, icon: "tag.fill")
                        statView(title: "Level", value: idea.level.rawValue, icon: "sparkles")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    
                    HStack(spacing: 50) {
                        Button { viewModel.shareIdea(idea) } label: {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.purple)
                                .font(.system(size: 19.8))
                                .padding(11)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        }
                        
                        Button { viewModel.likeIdea(idea) } label: {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 19.8))
                                .padding(11)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        }
                    }
                    .padding(.top, 6)
                    .padding(.bottom, 12)
                }
                .frame(height: geometry.size.height * 0.35)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 30))
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .shadow(radius: 5)
            .ignoresSafeArea(edges: .top)
        }
    }
    
    private func statView(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(.pink)
                .font(.system(size: 14))
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.pink)
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("IdeaCardView") {
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
    .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
    .background(Color.white)
}
