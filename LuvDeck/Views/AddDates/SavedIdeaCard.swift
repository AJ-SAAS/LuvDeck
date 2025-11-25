// SavedIdeaCard.swift — FINAL: Auto-shrinking text (never cut off!)
import SwiftUI

struct SavedIdeaCard: View {
    let idea: Idea
    private let pinkRed = Color.red.opacity(0.9)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // TITLE — auto-shrinks if too long
            Text(idea.title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(pinkRed)
                .lineLimit(3)                     // Allow up to 3 lines
                .minimumScaleFactor(0.65)         // Shrink down to 65% if needed
                .multilineTextAlignment(.leading)

            // DESCRIPTION — auto-shrinks and allows multiple lines
            Text(idea.description)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineLimit(5)                     // Max 5 lines (adjust as needed)
                .minimumScaleFactor(0.75)         // Shrink gracefully
                .multilineTextAlignment(.leading)

            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }
}
