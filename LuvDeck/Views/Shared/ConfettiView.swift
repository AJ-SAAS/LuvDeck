import SwiftUI

struct ConfettiView: View {
    @Binding var isAnimating: Bool
    @State private var particles: [Particle] = []
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: 10, height: 10)
                    .position(particle.position)
                    .offset(y: particle.offset)
                    .animation(.easeOut(duration: 2.0), value: particle.offset)
            }
        }
        .onChange(of: isAnimating) { oldValue, newValue in
            if newValue {
                particles = generateParticles()
                print("Confetti animation triggered")
            } else {
                particles = []
                print("Confetti animation stopped")
            }
        }
    }
    
    private func generateParticles() -> [Particle] {
        (0..<20).map { _ in
            Particle(
                position: CGPoint(x: CGFloat.random(in: 0...UIScreen.main.bounds.width), y: 0),
                offset: CGFloat.random(in: 100...500),
                color: [Color.red, .blue, .yellow, .pink, .green].randomElement() ?? .red
            )
        }
    }
}

struct Particle: Identifiable {
    let id = UUID()
    let position: CGPoint
    let offset: CGFloat
    let color: Color
}

struct ConfettiView_Previews: PreviewProvider {
    static var previews: some View {
        ConfettiView(isAnimating: .constant(true))
    }
}
