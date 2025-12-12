import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var purchaseVM: PurchaseViewModel

    private let screens: [(icon: String, mainText: String, subText: String, buttonText: String)] = [
        ("onboard1", "Unlock effortless romance.", "Never run out of ways to make your partner light up — even on the busiest day.", "Continue"),
        ("onboard2", "Always know how to make them feel special.", "From birthdays to anniversaries, LuvDeck helps you show up like the partner every woman secretly hopes for.", "Continue"),
        ("onboard3", "Grow stronger together.", "Each week, LuvDeck helps you build habits that deepen connection and attraction — without forcing it.", "Continue"),
        ("onboard4", "Stay ahead of every special moment.", "Turn on reminders so you’ll never forget an anniversary, milestone, or date idea again.", "Allow Notifications"),
        ("onboard5", "Make romance your secret advantage.", "You now have everything you need to surprise, connect, and lead your relationship with confidence.", "Let’s Go")
    ]

    var body: some View {
        GeometryReader { geometry in
            let safeStep = min(max(0, viewModel.currentStep), screens.count - 1)
            let screen = screens[safeStep]
            let isNotificationStep = safeStep == 3
            let isFinalStep = safeStep == screens.count - 1

            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                VStack(spacing: 0) {
                    Spacer(minLength: geometry.size.height * 0.07)

                    Image(screen.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: min(geometry.size.width * 0.5, 240),
                               height: min(geometry.size.width * 0.5, 240))
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
                        .padding(.horizontal, 40)

                    Spacer(minLength: 48)

                    VStack(spacing: 16) {
                        Text(screen.mainText)
                            .font(.system(size: titleFontSize(for: geometry), weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.7)

                        Text(screen.subText)
                            .font(.system(size: subtitleFontSize(for: geometry), weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.8)
                    }
                    .padding(.horizontal, 40)

                    Spacer()

                    VStack(spacing: 12) {
                        if isNotificationStep {
                            Button { viewModel.requestNotificationPermission(userId: authViewModel.user?.id) } label: {
                                Text("Allow Notifications")
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .cornerRadius(14)
                            }
                            .padding(.horizontal, 32)

                            Button("Skip") { viewModel.nextStep(userId: authViewModel.user?.id) }
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.blue)

                        } else if isFinalStep {
                            Button {
                                purchaseVM.triggerPaywallAfterOnboarding = true
                            } label: {
                                Text("Let’s Go")
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .cornerRadius(14)
                            }
                            .padding(.horizontal, 32)

                        } else {
                            Button { viewModel.nextStep(userId: authViewModel.user?.id) } label: {
                                Text(screen.buttonText)
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .cornerRadius(14)
                            }
                            .padding(.horizontal, 32)
                        }
                    }
                    .frame(maxHeight: 100)

                    Spacer(minLength: geometry.size.height * 0.07)
                }
            }
        }
    }

    private func titleFontSize(for geometry: GeometryProxy) -> CGFloat {
        min(geometry.size.width * 0.078, 32)
    }

    private func subtitleFontSize(for geometry: GeometryProxy) -> CGFloat {
        min(geometry.size.width * 0.045, 18)
    }
}
