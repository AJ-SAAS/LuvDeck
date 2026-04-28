// FreeTrialToggleView.swift
import SwiftUI

struct FreeTrialToggleView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    
    @State private var isEnabled = false
    @State private var showCheckmark = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                VStack {
                    Spacer(minLength: geometry.size.height * 0.22)

                    Text("3-Day Free Trial Enabled")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    // Big toggle animation
                    ZStack(alignment: isEnabled ? .trailing : .leading) {
                        RoundedRectangle(cornerRadius: 30)
                            .fill(isEnabled ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: 200, height: 80)

                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 72, height: 72)
                                .shadow(radius: 4)
                                .scaleEffect(isEnabled ? 1.1 : 1.0)

                            if showCheckmark {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.green)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(4)
                    }
                    .padding(.top, 20)

                    Spacer()
                }
            }
            .onAppear {
                // Auto animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        isEnabled = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        withAnimation(.easeIn(duration: 0.3)) {
                            showCheckmark = true
                        }
                    }
                }

                // Auto advance to next screen (FreeTrialInfoView)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation {
                        viewModel.nextStep()
                    }
                }
            }
        }
    }
}

#Preview {
    FreeTrialToggleView()
        .environmentObject(OnboardingViewModel())
}
