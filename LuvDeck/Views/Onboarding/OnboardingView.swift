// OnboardingView.swift
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
                    Spacer(minLength: geometry.size.height * 0.05)

                    Image(screen.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: min(geometry.size.width * 0.5, 240),
                               height: min(geometry.size.width * 0.5, 240))
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
                        .padding(.horizontal, 40)

                    Spacer(minLength: 32)

                    // Crossfade Text
                    VStack(spacing: 12) {
                        Text(screen.mainText)
                            .font(.system(size: min(geometry.size.width * 0.07, 28), weight: .bold))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .opacity(0)
                            .overlay(
                                Text(screen.mainText)
                                    .font(.system(size: min(geometry.size.width * 0.07, 28), weight: .bold))
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.4)))
                            )

                        Text(screen.subText)
                            .font(.system(size: min(geometry.size.width * 0.04, 17)))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .opacity(0)
                            .overlay(
                                Text(screen.subText)
                                    .font(.system(size: min(geometry.size.width * 0.04, 17)))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.4)))
                            )
                    }
                    .padding(.horizontal, min(geometry.size.width * 0.1, 40))
                    .frame(maxWidth: .infinity)
                    .animation(.easeInOut(duration: 0.4), value: safeStep)

                    Spacer()

                    // Fixed Button Area
                    VStack(spacing: 12) {
                        if isNotificationStep {
                            Button {
                                viewModel.requestNotificationPermission(userId: authViewModel.user?.id)
                            } label: {
                                Text("Allow Notifications")
                                    .font(.system(size: min(geometry.size.width * 0.05, 22), weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal, min(geometry.size.width * 0.1, 32))

                            Button("Skip") {
                                viewModel.nextStep(userId: authViewModel.user?.id)
                            }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.blue)

                        } else if isFinalStep {
                            Button {
                                viewModel.completeOnboarding(userId: authViewModel.user?.id)
                                NotificationCenter.default.post(name: .showPaywallAfterOnboarding, object: nil)
                            } label: {
                                Text("Let’s Go")
                                    .font(.system(size: min(geometry.size.width * 0.05, 22), weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal, min(geometry.size.width * 0.1, 32))

                        } else {
                            Button {
                                viewModel.nextStep(userId: authViewModel.user?.id)
                            } label: {
                                Text(screen.buttonText)
                                    .font(.system(size: min(geometry.size.width * 0.05, 22), weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal, min(geometry.size.width * 0.1, 32))
                        }
                    }
                    .frame(height: 80)
                    .animation(.easeInOut(duration: 0.3), value: safeStep)

                    Spacer(minLength: geometry.size.height * 0.05)
                }
            }
        }
    }
}

extension Notification.Name {
    static let showPaywallAfterOnboarding = Notification.Name("showPaywallAfterOnboarding")
}

#Preview {
    OnboardingView()
        .environmentObject(OnboardingViewModel())
        .environmentObject(AuthViewModel())
        .environmentObject(PurchaseViewModel())
}
