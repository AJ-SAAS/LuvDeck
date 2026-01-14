import SwiftUI

struct WelcomeView: View {
    @Binding var currentScreen: AppScreen     // ← Added: binding to control navigation
    
    @State private var showConfetti = false
    @State private var logoPulse = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                // Confetti
                ShapeConfettiView(isAnimating: $showConfetti).ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer(minLength: geometry.size.height * 0.1)

                    // Pulsing logo with glow
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
                            .scaleEffect(logoPulse ? 1.08 : 1.0)
                            .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: logoPulse)
                            .onAppear { logoPulse = true }
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
                        print("✅ Get Started → going to Home")
                        withAnimation {
                            currentScreen = .home
                        }
                    } label: {
                        Text("Get Started")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 32)

                    Spacer(minLength: geometry.size.height * 0.07)
                }
            }
        }
        .onAppear { showConfetti = true }
    }

    // MARK: - Helpers
    private func titleFontSize(for geometry: GeometryProxy) -> CGFloat {
        min(geometry.size.width * 0.078, 32)
    }

    private func subtitleFontSize(for geometry: GeometryProxy) -> CGFloat {
        min(geometry.size.width * 0.045, 18)
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(currentScreen: .constant(.welcome))
            .environmentObject(OnboardingViewModel())
    }
}
