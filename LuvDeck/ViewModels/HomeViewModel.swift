import SwiftUI
import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

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
    
    func setUserId(_ userId: String?) {
        self.userId = userId
        print("HomeViewModel userId updated to: \(userId ?? "nil")")
        fetchIdeas()
    }
    
    func fetchIdeas() {
        print("Loading ideas from JSON (bypassing Firestore)")
        loadIdeasFromJSON()
    }
    
    private func loadIdeasFromJSON() {
        guard let url = Bundle.main.url(forResource: "SwipeDeck", withExtension: "json") else {
            print("SwipeDeck.json not found in bundle. Using sample ideas")
            self.ideas = sampleIdeas()
            self.isLoading = false
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let decodedIdeas = try decoder.decode([Idea].self, from: data)
            self.ideas = decodedIdeas
            self.isLoading = false
            self.currentIndex = 0
            print("Loaded \(decodedIdeas.count) ideas from JSON")
        } catch {
            print("Error decoding SwipeDeck.json: \(error)")
            self.ideas = sampleIdeas()
            self.isLoading = false
        }
    }
    
    private func sampleIdeas() -> [Idea] {
        return [
            Idea(
                title: "Romantic Dinner",
                description: "Plan a candlelit dinner at home with your partner’s favorite meal.",
                category: "Random",
                difficulty: 2,
                impressive: 4,
                imageName: "romanticDinner",
                level: .cute
            ),
            Idea(
                title: "Sunset Hike",
                description: "Take a scenic hike and watch the sunset from a hilltop.",
                category: "Random",
                difficulty: 3,
                impressive: 3,
                imageName: "sunsetHike",
                level: .epic
            ),
            Idea(
                title: "DIY Spa Day",
                description: "Create a relaxing spa experience at home with candles and bath bombs.",
                category: "Random",
                difficulty: 1,
                impressive: 2,
                imageName: "spaDay",
                level: .spicy
            )
        ]
    }
    
    // MARK: - Controlled Scrolling
    func nextIdea() {
        guard !ideas.isEmpty else { return }
        if currentIndex < ideas.count - 1 {
            currentIndex += 1
            print("Moved to next idea: index=\(currentIndex), title=\(ideas[currentIndex].title)")
        }
    }
    
    func previousIdea() {
        guard !ideas.isEmpty else { return }
        if currentIndex > 0 {
            currentIndex -= 1
            print("Moved to previous idea: index=\(currentIndex), title=\(ideas[currentIndex].title)")
        }
    }
    
    // MARK: - Other actions
    func likeIdea(_ idea: Idea) {
        guard let userId = userId else { return }
        FirebaseManager.shared.saveLikedIdea(idea, for: userId)
        print("Liked idea: \(idea.title)")
    }
    
    func saveIdea(_ idea: Idea) {
        guard let userId = userId else { return }
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
        }
    }
}
