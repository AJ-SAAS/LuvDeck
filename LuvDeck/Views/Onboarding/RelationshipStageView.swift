import SwiftUI

struct RelationshipStageView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    let stages = [
        "New Couple (0-6 months)",
        "Dating 6 months - 2 years",
        "Together 2+ years",
        "Married / Long-term"
    ]
    
    var body: some View {
        OnboardingQuestionBase(title: "Where are you in your relationship?") {
            VStack(spacing: 14) {
                ForEach(stages, id: \.self) { stage in
                    Button {
                        viewModel.relationshipStage = stage
                        withAnimation {
                            viewModel.nextStep()
                        }
                    } label: {
                        Text(stage)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(viewModel.relationshipStage == stage ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                Group {
                                    if viewModel.relationshipStage == stage {
                                        LinearGradient(colors: [.pink, .purple],
                                                       startPoint: .leading,
                                                       endPoint: .trailing)
                                    } else {
                                        Color(.systemGray6)
                                    }
                                }
                            )
                            .cornerRadius(16)
                    }
                }
            }
            .padding(.horizontal, 32)
        }
    }
}
