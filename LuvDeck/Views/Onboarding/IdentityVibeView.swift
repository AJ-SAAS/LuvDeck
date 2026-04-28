import SwiftUI

struct IdentityVibeView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    
    let vibes = [
        "Effortless & natural",
        "Playful & fun",
        "Deep & emotionally connected",
        "Passionate & romantic",
        "Exciting & adventurous"
    ]
    
    var body: some View {
        OnboardingQuestionBase(title: "How do you want your relationship to feel?") {

            VStack(spacing: 20) {

                Text("Choose your vibe")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                ForEach(vibes, id: \.self) { vibe in
                    Button {
                        viewModel.desiredVibe = vibe
                    } label: {
                        Text(vibe)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(viewModel.desiredVibe == vibe ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                backgroundView(isSelected: viewModel.desiredVibe == vibe)
                            )
                            .cornerRadius(16)
                    }
                }
            }
            .padding(.horizontal, 32)
        }
    }

    @ViewBuilder
    private func backgroundView(isSelected: Bool) -> some View {
        if isSelected {
            LinearGradient(
                colors: [.pink, .purple],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            Color(.systemGray6)
        }
    }
}
