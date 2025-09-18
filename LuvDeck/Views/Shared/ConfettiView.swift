import SwiftUI

struct ConfettiView: View {
    @Binding var trigger: Bool
    let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple]
    let particleCount: Int = 50
    let duration: Double = 3.0
    
    struct Particle {
        let position: CGPoint
        let velocity: CGPoint
        let color: Color
        let rotation: Angle
        let rotationSpeed: Double
        let scale: CGFloat
        let opacity: Double
    }
    
    var body: some View {
        TimelineView(.animation) { timelineContext in
            Canvas { context, size in
                guard trigger else { return }
                
                let currentTime = timelineContext.date.timeIntervalSinceReferenceDate
                for i in 0..<particleCount {
                    let particle = createParticle(index: i, size: size, time: currentTime)
                    var path = Path()
                    path.addRect(CGRect(x: particle.position.x, y: particle.position.y, width: 10 * particle.scale, height: 10 * particle.scale))
                    
                    context.fill(
                        path,
                        with: .color(particle.color.opacity(particle.opacity))
                    )
                }
            }
        }
        .onChange(of: trigger) { _, newValue in
            if !newValue {
                // Reset trigger after duration
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    self.trigger = false
                }
            }
        }
    }
    
    private func createParticle(index: Int, size: CGSize, time: Double) -> Particle {
        let startY = -10.0
        let startX = CGFloat(index % 10) * size.width / 10 + CGFloat.random(in: -20...20)
        let velocityY = CGFloat.random(in: 100...300)
        let velocityX = CGFloat.random(in: -50...50)
        let elapsed = time.truncatingRemainder(dividingBy: duration)
        
        let position = CGPoint(
            x: startX + velocityX * elapsed,
            y: startY + velocityY * elapsed
        )
        
        return Particle(
            position: position,
            velocity: CGPoint(x: velocityX, y: velocityY),
            color: colors[index % colors.count],
            rotation: .degrees(Double.random(in: 0...360)),
            rotationSpeed: Double.random(in: -360...360),
            scale: CGFloat.random(in: 0.5...1.0),
            opacity: max(0, 1 - elapsed / duration)
        )
    }
}
