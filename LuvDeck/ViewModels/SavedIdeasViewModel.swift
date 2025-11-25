// SavedIdeasViewModel.swift – FINAL FIXED VERSION 2025
// Fully working bookmark system, no private db access

import SwiftUI
import FirebaseAuth

class SavedIdeasViewModel: ObservableObject {
    @Published var savedIdeas: [Idea] = []

    private let firebase = FirebaseManager.shared

    init() {
        loadSavedIdeas()
    }

    // Check if idea is already bookmarked
    func isSaved(_ idea: Idea) -> Bool {
        savedIdeas.contains { $0.id == idea.id }
    }

    // Save / Bookmark an idea
    func save(_ idea: Idea) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard !isSaved(idea) else { return }

        savedIdeas.append(idea)
        firebase.saveBookmarkedIdea(idea, for: userId)
    }

    // Remove / Unbookmark an idea
    func remove(_ idea: Idea) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let index = savedIdeas.firstIndex(where: { $0.id == idea.id }) else { return }

        savedIdeas.remove(at: index)

        firebase.removeBookmarkedIdea(idea, for: userId) { [weak self] error in
            if let error = error {
                print("Failed to remove from Firestore: \(error.localizedDescription)")
                // Revert local removal if Firestore failed
                DispatchQueue.main.async {
                    self?.savedIdeas.insert(idea, at: index)
                    self?.savedIdeas.sort { $0.title < $1.title } // optional: keep sorted
                }
            }
        }
    }

    // Load all saved ideas from Firestore
    func loadSavedIdeas() {
        guard let userId = Auth.auth().currentUser?.uid else {
            savedIdeas = []
            return
        }

        firebase.fetchBookmarkedIdeas(for: userId) { [weak self] ideas in
            DispatchQueue.main.async {
                self?.savedIdeas = ideas
            }
        }
    }

    // Optional: Refresh manually (e.g. on appear or pull-to-refresh)
    func refresh() {
        loadSavedIdeas()
    }
}
