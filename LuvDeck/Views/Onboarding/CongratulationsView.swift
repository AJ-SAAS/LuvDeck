import SwiftUI

struct CongratulationsView: View {
    var onContinue: () -> Void   // Closure to trigger when user taps Continue

    @State private var showConfetti = false
    @State private var logoPulse = false

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            ShapeConfettiView(isAnimating: $showConfetti).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 80)

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
                    Text("Congratulations!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)

                    Text("You're all set to start your journey with LuvDeck.")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 50)
                }
                .padding(.horizontal, 40)

                Spacer()

                Button(action: onContinue) {
                    Text("Continue")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 32)

                Spacer(minLength: 40)
            }
        }
        .onAppear { showConfetti = true }
    }
}

// MARK: - Shape Confetti (reuse)
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { emitter.birthRate = 0 }
    }
}
