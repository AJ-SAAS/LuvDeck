import SwiftUI

struct ConfettiView: View {
    @Binding var isAnimating: Bool
    @State private var particles: [ConfettiParticle] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Rectangle()
                        .fill(particle.color)
                        .frame(
                            width: particle.width,
                            height: particle.height
                        )
                        .cornerRadius(4)
                        .rotationEffect(
                            particle.isFalling ? particle.finalRotation : .zero
                        )
                        .scaleEffect(particle.scale)
                        .offset(
                            x: particle.drift,
                            y: particle.isFalling
                                ? geometry.size.height + 150
                                : -80
                        )
                        .opacity(particle.isFalling ? 0.0 : 1.0)
                        .animation(
                            .easeOut(duration: particle.duration)
                                .delay(particle.delay),
                            value: particle.isFalling
                        )
                }
            }
            .onChange(of: isAnimating) { _, newValue in
                if newValue {
                    triggerConfetti()
                } else {
                    particles.removeAll()
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    // MARK: - Confetti Trigger
    private func triggerConfetti() {
        let particleCount = 80

        particles = (0..<particleCount).map { _ in
            ConfettiParticle(
                color: [
                    .red, .pink, .orange, .yellow,
                    .green, .blue, .purple
                ].randomElement()!,
                drift: CGFloat.random(in: -180...180),
                duration: Double.random(in: 2.5...4.0),
                delay: Double.random(in: 0...0.3),
                finalRotation: .degrees(Double.random(in: 360...1440)),
                scale: CGFloat.random(in: 1.0...1.6),
                width: CGFloat.random(in: 12...24),
                height: CGFloat.random(in: 28...56),
                isFalling: false
            )
        }

        // Explosive initial burst effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0)) {
                for index in particles.indices {
                    particles[index].isFalling = true
                }
            }
        }
    }
}

// MARK: - Particle Struct
struct ConfettiParticle: Identifiable {
    let id = UUID()
    let color: Color
    let drift: CGFloat
    let duration: Double
    let delay: Double
    let finalRotation: Angle
    let scale: CGFloat
    let width: CGFloat
    let height: CGFloat
    var isFalling: Bool = false
}

// MARK: - Preview
struct ConfettiView_Previews: PreviewProvider {
    static var previews: some View {
        ConfettiView(isAnimating: .constant(true))
            .background(Color.white)
    }
}
