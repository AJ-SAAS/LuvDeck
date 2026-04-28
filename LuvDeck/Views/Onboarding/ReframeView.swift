// ReframeView.swift
import SwiftUI

struct ReframeItem: Identifiable {
    let id = UUID()
    let icon: String
    let iconColor: Color
    let problem: String
    let solution: String
}

struct ReframeView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    let items: [ReframeItem] = [
        ReframeItem(icon: "bolt.fill",
                    iconColor: .pink,
                    problem: "No time to plan",
                    solution: "We make it instant — ready in seconds"),
        ReframeItem(icon: "sparkles",
                    iconColor: .purple,
                    problem: "Nothing feels new",
                    solution: "We bring fresh ideas every single week"),
        ReframeItem(icon: "bubble.left.and.bubble.right.fill",
                    iconColor: .orange,
                    problem: "Conversations feel flat",
                    solution: "We guide you both, naturally"),
    ]

    var body: some View {
        OnboardingQuestionBase(title: "This isn't about trying harder") {
            VStack(spacing: 10) {
                ForEach(items) { item in
                    ReframeCard(item: item)
                }

                TaglineCard()
                    .padding(.top, 8)
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Reframe Card

struct ReframeCard: View {
    let item: ReframeItem

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(item.iconColor.opacity(0.12))
                    .frame(width: 42, height: 42)
                Image(systemName: item.icon)
                    .font(.system(size: 18))
                    .foregroundColor(item.iconColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(item.problem)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                    .strikethrough(true, color: .secondary)

                Text(item.solution)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color(.systemGray5), lineWidth: 1)
        )
    }
}

// MARK: - Tagline Card

struct TaglineCard: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#e8427c"), Color(hex: "#a855f7")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            ShimmerOverlay()
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            VStack(spacing: 4) {
                Text("Small moments. Big difference.")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("Couples using LuvDeck connect 3x more often")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 20)
        }
    }
}
