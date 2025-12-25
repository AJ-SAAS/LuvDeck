import SwiftUI

struct SplashView: View {
    @State private var showAnimation = false
    
    var body: some View {
        ZStack {
            // Adaptive background: white in light mode, black in dark mode
            Color(.systemBackground)
                .ignoresSafeArea()
            
            // Animated Logo with Heartbeat Pulse (no confetti)
            ZStack {
                // Subtle heartbeat glow pulse
                Circle()
                    .fill(Color.pink.opacity(0.3))
                    .frame(width: 180, height: 180)
                    .scaleEffect(showAnimation ? 1.8 : 1.0)
                    .opacity(showAnimation ? 0 : 0.8)
                    .animation(
                        .easeOut(duration: 1.2).delay(0.6),
                        value: showAnimation
                    )
                    .blur(radius: 15)
                    .blendMode(.screen)
                
                // Main logo with bounce animation
                Image("newlogosmile")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                    .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)
                    .scaleEffect(showAnimation ? 1.0 : 0.8)
                    .rotationEffect(showAnimation ? .degrees(0) : .degrees(-12))
                    .offset(y: showAnimation ? 0 : 40)
                    .animation(
                        .spring(response: 0.8, dampingFraction: 0.6, blendDuration: 0.3)
                        .delay(0.2),
                        value: showAnimation
                    )
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6)) {
                    showAnimation = true
                }
            }
        }
    }
}

#Preview("Light Mode") {
    SplashView()
}

#Preview("Dark Mode") {
    SplashView()
        .preferredColorScheme(.dark)
}
