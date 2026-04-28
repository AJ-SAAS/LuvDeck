import SwiftUI

struct MainGoalView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    let goals = [
        "Improve communication",
        "Rebuild connection",
        "Add more romance",
        "Have more fun together",
        "Fix ongoing issues"
    ]

    var body: some View {
        OnboardingQuestionBase(title: "What is your main goal?") {
            VStack(spacing: 16) {

                Text("Pick one that fits best")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                ForEach(goals, id: \.self) { goal in
                    goalButton(goal)
                }
            }
            .padding(.horizontal, 32)
        }
    }

    // MARK: - CLEAN SEPARATED BUTTON (FIXES COMPILER)
    private func goalButton(_ goal: String) -> some View {

        let isSelected = viewModel.mainGoal == goal

        return Button {
            viewModel.mainGoal = goal
        } label: {
            HStack {
                Text(goal)
                    .font(.system(size: 18, weight: .semibold))

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.pink)
                }
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.vertical, 18)
            .padding(.horizontal, 24)
            .background(background(isSelected))
            .cornerRadius(16)
        }
    }

    // MARK: - SEPARATED BACKGROUND (IMPORTANT FIX)
    private func background(_ selected: Bool) -> some View {
        Group {
            if selected {
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
}
