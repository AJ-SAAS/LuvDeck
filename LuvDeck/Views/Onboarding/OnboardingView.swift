import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    private let screens: [(icon: String, color: Color, mainText: String, subText: String)] = [
        ("heart.fill", .red, "Fresh ideas at your fingertips.", "Confidently plan moments that make your partner smile, without the stress of coming up with them yourself."),
        ("calendar.badge.heart", .primary, "Celebrate with confidence.", "From birthdays to anniversaries, you’ll always be prepared to make the day feel special."),
        ("sparkles", .yellow, "Level up your romance game.", "LuvDeck grows with your relationship, giving you the tools to be the partner they dream about."),
        ("bell.fill", .blue, "Stay in the loop.", "Enable notifications to get timely reminders for your special moments and new date ideas."),
        ("hands.sparkles", .purple, "Your journey starts here.", "You now have the inspiration, reminders, and tools to become the most thoughtful partner they’ve ever had.")
    ]

    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                // Clamp so index is always safe
                let safeStep = min(max(0, viewModel.currentStep), screens.count - 1)

                VStack(spacing: 20) {
                    Image(systemName: screens[safeStep].icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: min(geometry.size.width * 0.2, 80),
                               height: min(geometry.size.width * 0.2, 80))
                        .foregroundColor(screens[safeStep].color)
                        .padding(.top, geometry.size.height * 0.1)

                    Text(screens[safeStep].mainText)
                        .font(.system(size: min(geometry.size.width * 0.07, 28), weight: .bold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, min(geometry.size.width * 0.1, 32))
                        .padding(.top, 16)

                    Text(screens[safeStep].subText)
                        .font(.system(size: min(geometry.size.width * 0.04, 16)))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, min(geometry.size.width * 0.1, 32))

                    HStack(spacing: 8) {
                        ForEach(0..<screens.count, id: \.self) { index in
                            Circle()
                                .frame(width: 8, height: 8)
                                .foregroundColor(index == safeStep ? .blue : .gray)
                        }
                    }
                    .padding(.top, 16)

                    Spacer()

                    // Buttons
                    if viewModel.currentStep < 3 {
                        Button(action: {
                            print("Continue tapped step \(viewModel.currentStep)")
                            viewModel.nextStep(userId: authViewModel.user?.id)
                        }) {
                            Text("Continue")
                                .font(.system(size: min(geometry.size.width * 0.045, 18), weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, min(geometry.size.height * 0.02, 14))
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, min(geometry.size.width * 0.1, 32))
                        .padding(.bottom, geometry.size.height * 0.05)

                    } else if viewModel.currentStep == 3 {
                        VStack(spacing: 10) {
                            Button(action: {
                                print("Allow Notifications tapped")
                                viewModel.requestNotificationPermission(userId: authViewModel.user?.id)
                            }) {
                                Text("Allow Notifications")
                                    .font(.system(size: min(geometry.size.width * 0.045, 18), weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, min(geometry.size.height * 0.02, 14))
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            Button(action: {
                                print("Skip tapped")
                                viewModel.nextStep(userId: authViewModel.user?.id)
                            }) {
                                Text("Skip")
                                    .font(.system(size: min(geometry.size.width * 0.035, 14), weight: .semibold))
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal, min(geometry.size.width * 0.1, 32))
                        .padding(.bottom, geometry.size.height * 0.05)

                    } else {
                        Button(action: {
                            print("Let’s Go tapped")
                            viewModel.completeOnboarding(userId: authViewModel.user?.id)
                        }) {
                            Text("Let’s Go")
                                .font(.system(size: min(geometry.size.width * 0.045, 18), weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, min(geometry.size.height * 0.02, 14))
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, min(geometry.size.width * 0.1, 32))
                        .padding(.bottom, geometry.size.height * 0.05)
                    }
                }
                .navigationBarHidden(true)
                .background(Color(.systemBackground).ignoresSafeArea())
            }
        }
    }
}

#Preview("iPhone 14") {
    OnboardingView()
        .environmentObject(OnboardingViewModel())
        .environmentObject(AuthViewModel())
}

#Preview("iPad Pro") {
    OnboardingView()
        .environmentObject(OnboardingViewModel())
        .environmentObject(AuthViewModel())
}
