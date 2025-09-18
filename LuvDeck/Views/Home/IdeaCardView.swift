import SwiftUI

struct IdeaCardView: View {
    let idea: Idea
    @EnvironmentObject var viewModel: HomeViewModel
    @State private var showConfetti = false
    
    var body: some View {
        ZStack {
            VStack {
                Text(idea.title)
                    .font(.title)
                    .padding()
                Text(idea.description)
                    .font(.body)
                    .padding()
                HStack {
                    Button(action: {
                        viewModel.likeIdea(idea)
                        showConfetti = true // Trigger confetti on like
                    }) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    Button(action: {
                        viewModel.shareIdea(idea)
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.blue)
                            .padding()
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding()
            
            ConfettiView(trigger: $showConfetti)
        }
    }
}
