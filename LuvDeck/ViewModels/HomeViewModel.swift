import SwiftUI
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
            self.ideas = sampleIdeas().shuffled()
            self.isLoading = false
            self.currentIndex = self.ideas.isEmpty ? 0 : Int.random(in: 0..<self.ideas.count)
            print("Loaded and shuffled \(self.ideas.count) sample ideas, starting at index: \(self.currentIndex), title: \(self.ideas[safe: self.currentIndex]?.title ?? "none")")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let decodedIdeas = try decoder.decode([Idea].self, from: data)
            self.ideas = decodedIdeas.shuffled()
            self.isLoading = false
            self.currentIndex = decodedIdeas.isEmpty ? 0 : Int.random(in: 0..<decodedIdeas.count)
            print("Loaded and shuffled \(decodedIdeas.count) ideas from JSON, starting at index: \(self.currentIndex), title: \(self.ideas[safe: self.currentIndex]?.title ?? "none")")
        } catch {
            print("Error decoding SwipeDeck.json: \(error)")
            self.ideas = sampleIdeas().shuffled()
            self.isLoading = false
            self.currentIndex = self.ideas.isEmpty ? 0 : Int.random(in: 0..<self.ideas.count)
            print("Loaded and shuffled \(self.ideas.count) sample ideas due to JSON error, starting at index: \(self.currentIndex), title: \(self.ideas[safe: self.currentIndex]?.title ?? "none")")
        }
    }
    
    private func sampleIdeas() -> [Idea] {
        return [
            Idea(
                id: UUID(),
                title: "Romantic Dinner",
                description: "Plan a candlelit dinner at home with your partner’s favorite meal.",
                category: "Romantic",
                difficulty: 2,
                impressive: 4,
                imageName: "romanticDinner",
                level: .cute
            ),
            Idea(
                id: UUID(),
                title: "Sunset Hike",
                description: "Take a scenic hike and watch the sunset from a hilltop.",
                category: "Adventure",
                difficulty: 3,
                impressive: 3,
                imageName: "sunsetHike",
                level: .epic
            ),
            Idea(
                id: UUID(),
                title: "DIY Spa Day",
                description: "Create a relaxing spa experience at home with candles and bath bombs.",
                category: "Relaxation",
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
        currentIndex = (currentIndex + 1) % ideas.count // Loop to start
        print("Moved to next idea: index=\(currentIndex), title=\(ideas[safe: currentIndex]?.title ?? "none")")
    }
    
    func previousIdea() {
        guard !ideas.isEmpty else { return }
        currentIndex = (currentIndex - 1 + ideas.count) % ideas.count // Loop to end
        print("Moved to previous idea: index=\(currentIndex), title=\(ideas[safe: currentIndex]?.title ?? "none")")
    }
    
    // MARK: - Other actions
    func likeIdea(_ idea: Idea) {
        guard let userId = userId else {
            print("No userId for liking idea")
            return
        }
        FirebaseManager.shared.saveLikedIdea(idea, for: userId)
        print("Liked idea: \(idea.title)")
    }
    
    func saveIdea(_ idea: Idea) {
        guard let userId = userId else {
            print("No userId for saving idea")
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
        }
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
