import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    private let screens: [(icon: String, mainText: String, subText: String, buttonText: String)] = [
        ("luvdeck1", "Fresh romantic ideas at your fingertips.", "Confidently plan special moments that make your partner smile, without the stress of coming up with them yourself.", "Continue"),
        ("luvdeck2", "Celebrate love with confidence.", "From birthdays to anniversaries, you’ll always be prepared to make the day feel special.", "Continue"),
        ("luvdeck3", "Level up your romance game.", "LuvDeck grows with your relationship, giving you the tools to be the partner they dream about.", "Continue"),
        ("luvdeck4", "Stay in the loop.", "Enable notifications to get timely reminders for your special moments and new date ideas.", "Allow Notifications"),
        ("luvdeck5", "Your romance journey starts here.", "You now have the inspiration, reminders, and tools to become the most thoughtful partner they’ve ever had.", "Let’s Go")
    ]
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                let safeStep = min(max(0, viewModel.currentStep), screens.count - 1)
                let screen = screens[safeStep]
                
                VStack {
                    Spacer(minLength: geometry.size.height * 0.05) // small top padding
                    
                    // MARK: - Image
                    Image(screen.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: min(geometry.size.width * 0.5, 240),
                               height: min(geometry.size.width * 0.5, 240))
                    
                    Spacer(minLength: 20) // space between image and title
                    
                    // MARK: - Title & Description
                    VStack(spacing: 12) {
                        Text(screen.mainText)
                            .font(.system(size: min(geometry.size.width * 0.07, 28), weight: .bold))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, min(geometry.size.width * 0.1, 32))
                        
                        Text(screen.subText)
                            .font(.system(size: min(geometry.size.width * 0.04, 17)))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, min(geometry.size.width * 0.1, 32))
                    }
                    
                    Spacer() // pushes button toward bottom
                    
                    // MARK: - Button
                    if safeStep < screens.count - 2 {
                        Button(action: {
                            viewModel.nextStep(userId: authViewModel.user?.id)
                        }) {
                            Text(screen.buttonText)
                                .font(.system(size: min(geometry.size.width * 0.05, 22), weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .padding(.horizontal, min(geometry.size.width * 0.1, 32))
                        }
                    } else if safeStep == screens.count - 2 {
                        VStack(spacing: 10) {
                            Button(action: {
                                viewModel.requestNotificationPermission(userId: authViewModel.user?.id)
                            }) {
                                Text("Allow Notifications")
                                    .font(.system(size: min(geometry.size.width * 0.05, 22), weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.black)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                    .padding(.horizontal, min(geometry.size.width * 0.1, 32))
                            }
                            
                            Button(action: {
                                viewModel.nextStep(userId: authViewModel.user?.id)
                            }) {
                                Text("Skip")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.blue)
                            }
                        }
                    } else {
                        Button(action: {
                            viewModel.completeOnboarding(userId: authViewModel.user?.id)
                        }) {
                            Text(screen.buttonText)
                                .font(.system(size: min(geometry.size.width * 0.05, 22), weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .padding(.horizontal, min(geometry.size.width * 0.1, 32))
                        }
                    }
                    
                    Spacer(minLength: geometry.size.height * 0.05) // small bottom padding
                }
                .animation(.easeInOut(duration: 0.3), value: safeStep)
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
