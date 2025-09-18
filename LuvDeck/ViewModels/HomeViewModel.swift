import SwiftUI
import UIKit

class HomeViewModel: ObservableObject {
    @Published var ideas: [Idea] = []
    @Published var currentIndex: Int = 0
    @Published var isLoading: Bool = true
    private var userId: String?
    
    init(userId: String?) {
        self.userId = userId
        print("HomeViewModel initialized with userId: \(userId ?? "nil")")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.fetchIdeas()
        }
    }
    
    func fetchIdeas() {
        guard let userId = userId else {
            print("Cannot fetch ideas: userId is nil")
            DispatchQueue.main.async {
                self.ideas = self.sampleIdeas()
                self.isLoading = false
            }
            return
        }
        
        print("Fetching ideas for userId: \(userId)")
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        FirebaseManager.shared.fetchIdeas { [weak self] ideas in
            DispatchQueue.main.async {
                if ideas.isEmpty {
                    // Fallback to sample ideas if Firestore returns nothing
                    self?.ideas = self?.sampleIdeas() ?? []
                    print("No ideas fetched from Firestore, using 3 sample ideas")
                } else {
                    self?.ideas = ideas
                    print("Fetched \(ideas.count) ideas from Firestore")
                }
                self?.isLoading = false
                self?.currentIndex = 0
            }
        }
    }
    
    private func sampleIdeas() -> [Idea] {
        return [
            Idea(
                id: UUID(),
                title: "Romantic Dinner",
                description: "Plan a candlelit dinner at home with your partner’s favorite meal.",
                category: "Date",
                difficulty: 2,
                impressive: 4,
                imageName: "romanticDinner" // Placeholder name
            ),
            Idea(
                id: UUID(),
                title: "Sunset Hike",
                description: "Take a scenic hike and watch the sunset from a hilltop.",
                category: "Adventure",
                difficulty: 3,
                impressive: 3,
                imageName: "sunsetHike" // Placeholder name
            ),
            Idea(
                id: UUID(),
                title: "DIY Spa Day",
                description: "Create a relaxing spa experience at home with candles and bath bombs.",
                category: "Relaxation",
                difficulty: 1,
                impressive: 2,
                imageName: "spaDay" // Placeholder name
            )
        ]
    }
    
    func nextIdea() {
        if currentIndex < ideas.count - 1 {
            currentIndex += 1
            print("Moved to next idea: index=\(currentIndex)")
        }
    }
    
    func previousIdea() {
        if currentIndex > 0 {
            currentIndex -= 1
            print("Moved to previous idea: index=\(currentIndex)")
        }
    }
    
    func likeIdea(_ idea: Idea) {
        guard let userId = userId else {
            print("Cannot like idea: userId is nil")
            return
        }
        FirebaseManager.shared.saveLikedIdea(idea, for: userId)
        print("Liked idea: \(idea.title)")
    }
    
    func saveIdea(_ idea: Idea) {
        guard let userId = userId else {
            print("Cannot save idea: userId is nil")
            return
        }
        FirebaseManager.shared.saveBookmarkedIdea(idea, for: userId)
        print("Saved idea: \(idea.title)")
    }
    
    func shareIdea(_ idea: Idea) {
        let shareText = "\(idea.title): \(idea.description)"
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first,
           let rootVC = windowScene.windows.first?.rootViewController {
            DispatchQueue.main.async {
                rootVC.present(activityVC, animated: true)
                print("Sharing idea: \(idea.title)")
            }
        } else {
            print("Failed to find root view controller for sharing")
        }
    }
}
