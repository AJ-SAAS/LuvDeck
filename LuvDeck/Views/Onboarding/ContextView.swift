// ContextView.swift

import SwiftUI

struct ContextView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    let stages: [RelationshipStage] = [
        RelationshipStage(title: "Just started dating", imageName: "stage_new",      emoji: "🌱"),
        RelationshipStage(title: "In a relationship",   imageName: "stage_together", emoji: "💑"),
        RelationshipStage(title: "Married",             imageName: "stage_married",  emoji: "💍"),
        RelationshipStage(title: "Long-distance",       imageName: "stage_distance", emoji: "✈️")
    ]

    let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        OnboardingQuestionBase(
            title: "Where are you in your relationship?",
            subtitle: "This helps us suggest dates and questions that match your current stage"
        ) {
            LazyVGrid(columns: columns, spacing: 16) {     // Increased spacing between cards
                ForEach(stages) { stage in
                    StageCard(
                        stage: stage,
                        isSelected: viewModel.relationshipStage == stage.title
                    ) {
                        triggerSelectionHaptic()
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            viewModel.relationshipStage = stage.title
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 12)        // ← Added top padding to prevent border cutoff
        }
    }
    
    // MARK: - Haptics
    private func triggerSelectionHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

// MARK: - StageCard
struct StageCard: View {
    let stage: RelationshipStage
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: isSelected ? Color.pink.opacity(0.25) : Color.black.opacity(0.08),
                        radius: isSelected ? 12 : 6,
                        y: isSelected ? 6 : 3
                    )

                VStack(spacing: 12) {
                    Text(stage.emoji)
                        .font(.system(size: 48))
                    
                    Text(stage.title)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 8)
                }
                .padding(.vertical, 20)
            }
            .frame(height: 164)                    // Slightly taller card
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        isSelected ? Color.pink : Color(.systemGray4),
                        lineWidth: isSelected ? 3.5 : 1.5
                    )
            )
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white, .pink)
                        .padding(10)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .scaleEffect(isSelected ? 1.04 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Model
struct RelationshipStage: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String
    let emoji: String
}
