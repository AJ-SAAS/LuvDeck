import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var purchaseVM: PurchaseViewModel

    private let screens: [(icon: String, mainText: String, subText: String, buttonText: String)] = [
        (
            "onboard1",
            "Never run out of romance ideas.",
            "Even on your busiest days, spark that smile with effortless, proven date ideas.",
            "Continue"
        ),
        (
            "onboard2",
            "Be the partner she brags about.",
            "From birthdays to random Tuesdays — always know exactly how to make her feel chosen and adored.",
            "Continue"
        ),
        (
            "onboard3",
            "Build unbreakable attraction.",
            "Small weekly habits that deepen connection, reignite desire, and make her fall harder — naturally.",
            "Continue"
        ),
        (
            "onboard4",
            "Never miss what matters.",
            "Get smart reminders for anniversaries, birthdays, and perfect moments to surprise her.",
            "Allow Notifications"
        ),
        (
            "onboard5",
            "Romance is now your unfair advantage.",
            "You're equipped to lead, surprise, and keep the spark alive — with total confidence.",
            "Continue"
        )
    ]

    var body: some View {
        ZStack {
            mainContent

            // Back button overlay (currently disabled)
            if false && viewModel.currentStep > 0 && viewModel.currentStep < 10 {
                VStack {
                    HStack {
                        Button {
                            withAnimation {
                                viewModel.previousStep()
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Back")
                                    .font(.system(size: 17, weight: .medium))
                            }
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray6))
                            .cornerRadius(20)
                        }
                        .padding(.leading, 20)
                        .padding(.top, 50)
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        // ============================
        // PRE-ONBOARDING QUESTIONS (0-4)
        // ============================
        if viewModel.currentStep == 0 {
            ReferralSourceView()
        }
        else if viewModel.currentStep == 1 {
            QuestionShortTermGoalsView()
        }
        else if viewModel.currentStep == 2 {
            QuestionLongTermGoalsView()
        }
        else if viewModel.currentStep == 3 {
            RelationshipFocusView()
        }
        else if viewModel.currentStep == 4 {
            DailyCommitmentView()
        }

        // ============================
        // ILLUSTRATED SCREENS (5–9)
        // ============================
        else if viewModel.currentStep >= 5 && viewModel.currentStep < 10 {
            illustratedScreen(step: viewModel.currentStep - 5)
        }

        // ============================
        // FREE TRIAL TOGGLE (step 10)
        // ============================
        else if viewModel.currentStep == 10 {
            FreeTrialToggleView()
        }

        // ============================
        // FREE TRIAL INFO / PAYWALL TRIGGER (step 11)
        // ============================
        else if viewModel.currentStep == 11 {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer(minLength: 20)
                    
                    FreeTrialInfoView()
                        .environmentObject(viewModel)
                    
                    Spacer(minLength: 20)
                    
                    Button {
                        purchaseVM.triggerPaywallAfterOnboarding = true
                        // No closure needed anymore — handled in ContentView .onDisappear
                    } label: {
                        Text("Start Free Trial")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.pink)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
            }
        }

        else {
            EmptyView()
        }
    }

    // MARK: - Helpers
    @ViewBuilder
    private func illustratedScreen(step: Int) -> some View {
        GeometryReader { geometry in
            let safeStep = min(max(0, step), screens.count - 1)
            let screen = screens[safeStep]
            let isNotificationStep = safeStep == 3

            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer(minLength: geometry.size.height * 0.07)

                    Image(screen.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: min(geometry.size.width * 0.5, 240), height: min(geometry.size.width * 0.5, 240))
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
                            Button {
                                viewModel.requestNotificationPermission(userId: authViewModel.user?.id) {
                                    withAnimation { viewModel.nextStep(userId: authViewModel.user?.id) }
                                }
                            } label: {
                                Text("Allow Notifications")
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(Color.pink)
                                    .foregroundColor(.white)
                                    .cornerRadius(14)
                            }
                            .padding(.horizontal, 32)

                            Button {
                                withAnimation { viewModel.nextStep(userId: authViewModel.user?.id) }
                            } label: {
                                Text("Skip")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.blue)
                            }
                        } else {
                            Button {
                                withAnimation { viewModel.nextStep(userId: authViewModel.user?.id) }
                            } label: {
                                Text(screen.buttonText)
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(Color.pink)
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
