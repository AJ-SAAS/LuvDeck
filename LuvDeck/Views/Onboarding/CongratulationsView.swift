import SwiftUI
import UIKit

struct CongratulationsView: View {
    var onGetStarted: () -> Void
    
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 32) {
            
            // MARK: - Pulsing Image
            Image("newlogosmile")
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                .scaleEffect(pulse ? 1.08 : 1.0)
                .animation(
                    .easeInOut(duration: 0.9)
                    .repeatForever(autoreverses: true),
                    value: pulse
                )
                .onAppear {
                    pulse = true
                }

            Text("Congratulations!")
                .font(.largeTitle.bold())

            Text("You're on your way to unforgettable romantic dates.")
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // MARK: - Get Started Button
            Button {
                // Haptic feedback
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                
                onGetStarted()
            } label: {
                Text("Get Started")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundStyle(.white)
                    .cornerRadius(14)
                    .shadow(color: .black.opacity(0.25), radius: 10, y: 6)
            }
            .padding(.horizontal, 40)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}
