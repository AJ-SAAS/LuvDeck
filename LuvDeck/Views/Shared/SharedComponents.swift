// SharedComponents.swift

import SwiftUI

// MARK: - Shimmer Overlay
struct ShimmerOverlay: View {
    @State private var move = false
    
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            
            Rectangle()
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: .clear,               location: 0.2),
                            .init(color: .white.opacity(0.20), location: 0.4),
                            .init(color: .white.opacity(0.35), location: 0.5),
                            .init(color: .white.opacity(0.20), location: 0.6),
                            .init(color: .clear,               location: 0.8),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: w * 0.58)
                .offset(x: move ? w * 1.45 : -w * 0.65)
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: 2.25)
                        .repeatForever(autoreverses: false)
                        .delay(1.3)                    // ← Delay you wanted
                    ) {
                        move = true
                    }
                }
        }
    }
}

// MARK: - Testimonial Card
struct TestimonialCard: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#e8427c"), Color(hex: "#c0375f"), Color(hex: "#a855f7")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            ShimmerOverlay()
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            VStack(alignment: .leading, spacing: 10) {
                Text("\"We were roommates for a year. LuvDeck gave us something to actually look forward to together.\"")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.95))
                    .italic()
                    .lineSpacing(3)

                Text("— Emma & Jake, together 4 years")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.65))
            }
            .padding(20)
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let number: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(number)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.pink)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color(.systemGray5), lineWidth: 1)
        )
    }
}
