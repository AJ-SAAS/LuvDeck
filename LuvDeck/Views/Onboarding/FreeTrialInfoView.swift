import SwiftUI

// MARK: - Free Trial Info View
struct FreeTrialInfoView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 32) {

            Spacer(minLength: 24)

            Text("Your 3-day free trial")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            TrialTimelineView()
                .padding(.horizontal, 28)

            Spacer()

            Text("Allow emails and notifications to get a reminder.")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
        }
        .padding(.top, 16)
    }
}

// MARK: - Timeline View
struct TrialTimelineView: View {

    // MARK: Layout constants
    private let circleSize: CGFloat = 68
    private let verticalSpacing: CGFloat = 36
    private let lineWidth: CGFloat = 4

    @State private var animateLines = false
    @State private var pulse = false
    @State private var showCheckmark = false

    // MARK: Dynamic trial steps (3-day trial for LuvDeck)
    private var trialSteps: [TrialStep] {
        [
            TrialStep(
                icon: "checkmark",
                title: "Install the app",
                subtitle: "You've started your romantic journey.",
                state: .completed
            ),
            TrialStep(
                icon: "lock.fill",
                title: "Today: Start exploring",
                subtitle: "Enjoy full access to date ideas, reminders, and relationship tools.",
                state: .active
            ),
            TrialStep(
                icon: "bell",
                title: "Day 2: Get a reminder",
                subtitle: "You'll get an email or notification before your trial ends.",
                state: .upcoming
            ),
            TrialStep(
                icon: "star",
                title: "Day 3: Trial ends",
                subtitle: "Your paid subscription starts on \(trialEndDateString()), cancel anytime before.",
                state: .upcoming
            )
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            ForEach(trialSteps.indices, id: \.self) { index in
                HStack(alignment: .top, spacing: 20) {

                    // MARK: Timeline Column
                    VStack(spacing: 0) {

                        // Circle
                        ZStack {

                            // Pulse for active step
                            if trialSteps[index].state == .active {
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color.pink.opacity(0.45),
                                                Color.pink.opacity(0.15)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ),
                                        lineWidth: 3
                                    )
                                    .frame(width: circleSize + 15, height: circleSize + 15)
                                    .scaleEffect(pulse ? 1.25 : 0.95)
                                    .opacity(pulse ? 0 : 1)
                                    .animation(
                                        .easeOut(duration: 1.6)
                                            .repeatForever(autoreverses: false),
                                        value: pulse
                                    )
                            }

                            Circle()
                                .fill(circleGradient(for: trialSteps[index].state))
                                .frame(width: circleSize, height: circleSize)

                            if trialSteps[index].state == .completed {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .scaleEffect(showCheckmark ? 1 : 0.2)
                                    .opacity(showCheckmark ? 1 : 0)
                                    .animation(
                                        .spring(response: 0.45, dampingFraction: 0.6),
                                        value: showCheckmark
                                    )
                            } else {
                                Image(systemName: trialSteps[index].icon)
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(iconColor(for: trialSteps[index].state))
                            }
                        }

                        // Connector
                        if index < trialSteps.count - 1 {
                            ZStack(alignment: .top) {

                                Rectangle()
                                    .fill(Color.gray.opacity(0.35))
                                    .frame(width: lineWidth, height: verticalSpacing)

                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.pink,
                                                Color.pink.opacity(0.8)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(
                                        width: lineWidth,
                                        height: connectorFillHeight(for: index)
                                    )
                                    .animation(
                                        .interpolatingSpring(stiffness: 120, damping: 18),
                                        value: animateLines
                                    )
                            }
                            .frame(height: verticalSpacing)
                        }
                    }
                    .frame(width: circleSize)

                    // Text Column
                    VStack(alignment: .leading, spacing: 6) {
                        Text(trialSteps[index].title)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .strikethrough(trialSteps[index].state == .completed)

                        Text(trialSteps[index].subtitle)
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()
                }
            }
        }
        .onAppear {
            animateLines = true
            pulse = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showCheckmark = true
            }
        }
    }

    // MARK: Helpers
    func connectorFillHeight(for index: Int) -> CGFloat {
        switch index {
        case 0:
            return animateLines ? verticalSpacing : 0
        case 1:
            return animateLines ? verticalSpacing / 2 : 0
        default:
            return 0
        }
    }

    func circleGradient(for state: TrialStepState) -> LinearGradient {
        switch state {
        case .completed, .active:
            return LinearGradient(
                colors: [
                    Color.pink,
                    Color.pink.opacity(0.8)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .upcoming:
            return LinearGradient(
                colors: [
                    Color.gray.opacity(0.35),
                    Color.gray.opacity(0.25)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    func iconColor(for state: TrialStepState) -> Color {
        state == .upcoming ? .gray : .white
    }

    // MARK: Trial end date (TODAY counts as Day 1 → +2 days for 3-day trial)
    func trialEndDateString() -> String {
        let calendar = Calendar.current
        let today = Date()

        guard let endDate = calendar.date(byAdding: .day, value: 2, to: today) else {
            return ""
        }

        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "MMMM d"

        return formatter.string(from: endDate)
    }
}

// MARK: - Models
enum TrialStepState {
    case completed
    case active
    case upcoming
}

struct TrialStep {
    let icon: String
    let title: String
    let subtitle: String
    let state: TrialStepState
}
