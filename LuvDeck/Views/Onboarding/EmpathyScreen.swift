// EmpathyScreen.swift
import SwiftUI

struct EmpathyScreen: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Heart icon
            ZStack {
                Circle()
                    .fill(Color.pink.opacity(0.12))
                    .frame(width: 72, height: 72)
                Image(systemName: "heart.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.pink)
            }
            .padding(.bottom, 28)

            Text("You're not alone in this")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 14)

            Text("Most couples go through exactly what you're feeling. The fact that you're here means you care — that's already the hard part.")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, 36)
                .padding(.bottom, 36)

            // Stat cards
            HStack(spacing: 10) {
                StatCard(number: "87%", label: "of couples feel stuck at some point")
                StatCard(number: "3x",  label: "more connected after intentional dates")
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)

            // Testimonial
            TestimonialCard()
                .padding(.horizontal, 24)

            Spacer()
        }
    }
}
