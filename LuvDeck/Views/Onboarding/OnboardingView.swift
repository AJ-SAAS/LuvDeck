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
            "You’re equipped to lead, surprise, and keep the spark alive — with total confidence.",
            "Continue"
        )
    ]

    @State private var showConfetti = false

    var body: some View {

        // ============================
        // PRE-ONBOARDING QUESTIONS
        // ============================
        if viewModel.currentStep == 0 {
            ReferralSourceView()
        }
        else if viewModel.currentStep == 1 {
            RelationshipFocusView()
        }
        else if viewModel.currentStep == 2 {
            DailyCommitmentView()
        }

        // ============================
        // ILLUSTRATED SCREENS (3–7)
        // ============================
        else if viewModel.currentStep >= 3 && viewModel.currentStep < 8 {
            GeometryReader { geometry in
                let adjustedStep = viewModel.currentStep - 3
                let safeStep = min(max(0, adjustedStep), screens.count - 1)
                let screen = screens[safeStep]

                let isNotificationStep = safeStep == 3
                let isOldFinalStep = safeStep == screens.count - 1

                ZStack {
                    Color(.systemBackground).ignoresSafeArea()

                    VStack(spacing: 0) {
                        Spacer(minLength: geometry.size.height * 0.07)

                        Image(screen.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(
                                width: min(geometry.size.width * 0.5, 240),
                                height: min(geometry.size.width * 0.5, 240)
                            )
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
                                    viewModel.requestNotificationPermission(userId: authViewModel.user?.id)
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

                                Button("Skip") {
                                    viewModel.nextStep(userId: authViewModel.user?.id)
                                }
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.blue)

                            }
                            else if isOldFinalStep {
                                Button {
                                    viewModel.nextStep(userId: authViewModel.user?.id)
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
                            }
                            else {
                                Button {
                                    viewModel.nextStep(userId: authViewModel.user?.id)
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

        // ============================
        // FINAL WELCOME SCREEN (step 8) — ENHANCED CONFETTI
        // ============================
        else if viewModel.currentStep == 8 {
            GeometryReader { geometry in
                ZStack {
                    Color(.systemBackground).ignoresSafeArea()

                    // Confetti overlay
                    ShapeConfettiView(isAnimating: $showConfetti)
                        .ignoresSafeArea()

                    VStack(spacing: 0) {
                        Spacer(minLength: geometry.size.height * 0.1)

                        ZStack {
                            Circle()
                                .fill(Color.pink.opacity(0.3))
                                .frame(width: 140, height: 140)
                                .scaleEffect(1.6)
                                .opacity(0.8)
                                .blur(radius: 10)
                                .blendMode(.screen)

                            Image("newlogosmile")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
                        }

                        Spacer(minLength: 48)

                        VStack(spacing: 16) {
                            Text("Welcome to LuvDeck!")
                                .font(.system(size: titleFontSize(for: geometry), weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)

                            Text("All personal information will remain private and secure.")
                                .font(.system(size: subtitleFontSize(for: geometry), weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 50)
                        }
                        .padding(.horizontal, 40)

                        Spacer()

                        Button {
                            viewModel.completeOnboarding(userId: authViewModel.user?.id)
                            purchaseVM.triggerPaywallAfterOnboarding = true
                        } label: {
                            Text("Let’s Go")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                        }
                        .padding(.horizontal, 32)

                        Spacer(minLength: geometry.size.height * 0.07)
                    }
                }
            }
            .onAppear {
                showConfetti = true
            }
        }

        else {
            EmptyView()
        }
    }

    private func titleFontSize(for geometry: GeometryProxy) -> CGFloat {
        min(geometry.size.width * 0.078, 32)
    }

    private func subtitleFontSize(for geometry: GeometryProxy) -> CGFloat {
        min(geometry.size.width * 0.045, 18)
    }
}

// MARK: - Shape Confetti (Triangles & Stars)
struct ShapeConfettiView: UIViewRepresentable {
    @Binding var isAnimating: Bool

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        guard isAnimating else { return }

        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: -10)
        emitter.emitterShape = .line
        emitter.emitterSize = CGSize(width: UIScreen.main.bounds.width, height: 1)

        let colors: [UIColor] = [.systemRed, .systemPink, .systemYellow, .systemGreen, .systemBlue, .systemOrange]
        let symbols = ["triangle.fill", "star.fill"]

        var cells: [CAEmitterCell] = []

        for color in colors {
            for symbol in symbols {
                let cell = CAEmitterCell()
                cell.birthRate = 8
                cell.lifetime = 5.0
                cell.lifetimeRange = 2
                cell.velocity = 250
                cell.velocityRange = 150
                cell.emissionLongitude = .pi
                cell.emissionRange = .pi / 3
                cell.spin = CGFloat.random(in: -3...3)
                cell.spinRange = CGFloat.random(in: 2...5)
                cell.scale = 0.07
                cell.scaleRange = 0.03
                cell.color = color.cgColor
                cell.contents = UIImage(systemName: symbol)?.cgImage
                cells.append(cell)
            }
        }

        emitter.emitterCells = cells
        uiView.layer.addSublayer(emitter)

        // Stop emitter after 5 seconds without affecting SwiftUI UI
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            emitter.birthRate = 0
        }
    }
}
