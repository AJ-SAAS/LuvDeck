import SwiftUI

struct PainView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    let options = [
        "Same routine",
        "Shallow talks",
        "No dates",
        "Too busy",
        "Not close",
        "No real connection"
    ]

    var body: some View {
        OnboardingQuestionBase(title: "What’s missing lately?") {

            VStack(spacing: 16) {

                Text("Be honest — this helps us personalize")
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

    private func toggle(_ option: String) {
        if viewModel.missingAspects.contains(option) {
            viewModel.missingAspects.remove(option)
        } else {
            viewModel.missingAspects.insert(option)
        }
    }

    private func isSelected(_ option: String) -> Bool {
        viewModel.missingAspects.contains(option)
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
