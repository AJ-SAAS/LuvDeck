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
                    Spacer(minLength: geometry.size.height * 0.2)

                    // Title above toggle
                    Text("3-Day Free Trial Enabled")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    // Big toggle animation
                    ZStack(alignment: isEnabled ? .trailing : .leading) {
                        RoundedRectangle(cornerRadius: 30)
                            .fill(isEnabled ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: 200, height: 80)
                            .animation(.easeInOut(duration: 0.5), value: isEnabled)

                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 72, height: 72)
                                .shadow(radius: 4)
                                .scaleEffect(isEnabled ? 1.1 : 1.0)
                                .animation(.interpolatingSpring(stiffness: 300, damping: 15), value: isEnabled)

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
                    .onAppear {
                        // Animate toggle to "on" state with bounce
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

                        // Automatically go to next page after short delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            viewModel.nextStep(userId: nil)
                        }
                    }

                    Spacer()

                    // Continue button at the bottom
                    Button {
                        viewModel.nextStep(userId: nil)
                    } label: {
                        Text("Continue")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.pink)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
                }
            }
        }
    }
}

#Preview {
    FreeTrialToggleView()
        .environmentObject(OnboardingViewModel())
}
