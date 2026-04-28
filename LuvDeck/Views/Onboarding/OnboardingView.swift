// OnboardingView.swift

import SwiftUI

struct OnboardingView: View {
    
    @EnvironmentObject var viewModel: OnboardingViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var purchaseVM: PurchaseViewModel

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {

                ProgressView(value: viewModel.progress)
                    .tint(.pink)
                    .padding(.horizontal, 40)
                    .padding(.top, 60)

                Spacer()

                Group {
                    switch viewModel.currentStep {
                    case 0: DesireView().environmentObject(viewModel)
                    case 1: PainView().environmentObject(viewModel)
                    case 2: EmpathyScreen().environmentObject(viewModel)
                    case 3: ReframeView().environmentObject(viewModel)
                    case 4: IdentityVibeView().environmentObject(viewModel)
                    case 5: ContextView()
                            .environmentObject(viewModel)
                            .environmentObject(authViewModel)
                    case 6: FreeTrialToggleView()
                            .environmentObject(viewModel)
                    case 7: FreeTrialInfoView()
                            .environmentObject(viewModel)
                    default: EmptyView()
                    }
                }
                .id("step-\(viewModel.currentStep)")

                Spacer()

                // Black button - Hide on FreeTrialToggleView (step 6)
                if viewModel.currentStep != 6 {
                    Button {
                        triggerHaptic()
                        
                        withAnimation(.easeInOut(duration: 0.4)) {
                            if viewModel.currentStep == viewModel.lastStep {
                                purchaseVM.triggerPaywallAfterOnboarding = true
                            } else {
                                viewModel.nextStep()
                            }
                        }
                    } label: {
                        Text(viewModel.currentStep == viewModel.lastStep ? "Continue to Trial" : "Next")
                            .font(.system(size: 20, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
            }
        }
    }
    
    // MARK: - Haptics
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}
