// SavedIdeasView.swift — FINAL UX (Long-press to remove)
import SwiftUI

struct SavedIdeasView: View {
    @EnvironmentObject var savedVM: SavedIdeasViewModel
    @Environment(\.dismiss) private var dismiss

    private let pinkRed = Color.red.opacity(0.9)

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                if savedVM.savedIdeas.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "bookmark.slash")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                        Text("No saved ideas yet")
                            .font(.title2.bold())
                        Text("Tap the bookmark on any idea to save it here ❤️")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(savedVM.savedIdeas) { idea in
                                SavedIdeaCard(idea: idea)
                                    .onLongPressGesture {
                                        confirmRemove(idea: idea)
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Saved Ideas ❤️")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundStyle(pinkRed)
                }
            }
            .tint(pinkRed)
        }
    }

    private func confirmRemove(idea: Idea) {
        let alert = UIAlertController(
            title: "Remove from Saved?",
            message: "“\(idea.title)” will be removed from your saved ideas.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { _ in
            withAnimation {
                savedVM.remove(idea)
            }
        })
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
    }
}
