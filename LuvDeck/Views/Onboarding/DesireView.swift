import SwiftUI

struct DesireView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    let options = [
        "Better talks",
        "More fun & laughing",
        "More love & closeness",
        "Surprise date nights",
        "Feeling understood",
        "Less boring routine, more excitement"
    ]

    var body: some View {
        OnboardingQuestionBase(title: "What do you want more of?") {
            
            VStack(spacing: 16) {

                Text("Pick what matters most")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                ForEach(options, id: \.self) { option in
                    Button {
                        toggle(option)
                    } label: {
                        HStack {
                            Text(option)
                                .font(.system(size: 17, weight: .medium))
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)

                            Spacer()

                            if isSelected(option) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.pink)
                            }
                        }
                        .foregroundColor(isSelected(option) ? .white : .primary)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 18)
                        .background(backgroundView(isSelected: isSelected(option)))
                        .cornerRadius(16)
                    }
                }
            }
            .padding(.horizontal, 32)
        }
    }

    // MARK: - Logic
    private func toggle(_ option: String) {
        if viewModel.desiredAspects.contains(option) {
            viewModel.desiredAspects.remove(option)
        } else {
            viewModel.desiredAspects.insert(option)
        }
    }

    private func isSelected(_ option: String) -> Bool {
        viewModel.desiredAspects.contains(option)
    }

    // MARK: - Background FIX
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
