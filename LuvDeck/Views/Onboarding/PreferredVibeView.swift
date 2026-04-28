import SwiftUI

struct PreferredVibeView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    let vibes = ["Cozy", "Fun", "Adventurous", "Unforgettable"]

    var body: some View {
        OnboardingQuestionBase(title: "What kind of dates excite you most?") {
            VStack(spacing: 14) {

                ForEach(vibes, id: \.self) { vibe in
                    vibeButton(vibe)
                }

                Text("Select all that apply")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)

                Spacer()

                continueButton
            }
            .padding(.horizontal, 32)
        }
    }

    // MARK: - VIBE BUTTON (FIXES COMPILER ISSUES)
    private func vibeButton(_ vibe: String) -> some View {

        let isSelected = viewModel.preferredVibes.contains(vibe)

        return Button {
            if isSelected {
                viewModel.preferredVibes.remove(vibe)
            } else {
                viewModel.preferredVibes.insert(vibe)
            }
        } label: {
            HStack {
                Text(vibe)
                    .font(.system(size: 18, weight: .semibold))

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.pink)
                }
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
            .background(background(isSelected))
            .cornerRadius(16)
        }
    }

    // MARK: - BACKGROUND (REMOVES TYPE INFERENCE ERROR)
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

    // MARK: - CONTINUE BUTTON (SEPARATED FOR SAFETY)
    private var continueButton: some View {

        let canContinue = !viewModel.preferredVibes.isEmpty

        return Button {
            if canContinue {
                withAnimation {
                    viewModel.nextStep()
                }
            }
        } label: {
            Text("Continue")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(
                    LinearGradient(
                        colors: [.pink, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .opacity(canContinue ? 1.0 : 0.6)
        }
        .disabled(!canContinue)
        .padding(.top, 10)
    }
}
