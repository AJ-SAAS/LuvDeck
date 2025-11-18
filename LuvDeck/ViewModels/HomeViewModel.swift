// HomeViewModel.swift
// FINAL VERSION – Legendary cards appear every 12th position
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class HomeViewModel: ObservableObject {
    @Published var ideas: [Idea] = []
    @Published var currentIndex: Int = 0
    @Published var isLoading: Bool = true
    
    // Premium Teaser Banner — appears once every 70 swipes
    @Published var showTeaserBanner: Bool = false
    
    private var swipeCount: Int = 0
    private var hasShownTeaserThisSession = false
    private let teaserInterval: Int = 70
    private var userId: String?
    private let isPremiumProvider: () -> Bool
    
    init(userId: String?, isPremiumProvider: @escaping () -> Bool = { false }) {
        self.userId = userId
        self.isPremiumProvider = isPremiumProvider
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.fetchIdeas()
        }
    }
    
    func setUserId(_ userId: String?) {
        self.userId = userId
        fetchIdeas()
    }
    
    // Called every time user successfully swipes to a new card
    func didSwipe() {
        guard !isPremiumProvider() else { return }
        guard !hasShownTeaserThisSession else { return }
        
        swipeCount += 1
        
        if swipeCount >= teaserInterval {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showTeaserBanner = true
            }
            hasShownTeaserThisSession = true
        }
    }
    
    func dismissTeaserBanner() {
        withAnimation(.spring()) {
            showTeaserBanner = false
        }
    }
    
    func resetTeaserSession() {
        hasShownTeaserThisSession = false
        swipeCount = 0
    }
    
    // MARK: - Data Loading – Legendary every 12th card
    func fetchIdeas() {
        guard let url = Bundle.main.url(forResource: "SwipeDeck", withExtension: "json") else {
            loadSampleIdeas()
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([Idea].self, from: data)
            
            // Separate Legendary from regular ideas
            let legendaryIdeas = decoded.filter { $0.level == .legendary }
            let regularIdeas = decoded.filter { $0.level != .legendary }
            
            // Shuffle only the regular ideas
            let shuffledRegular = regularIdeas.shuffled()
            
            var finalDeck: [Idea] = []
            var regularIndex = 0
            
            // Build infinite deck: 11 regular → 1 Legendary → repeat
            for position in 0..<1000 {  // 1000+ cards = feels infinite
                if (position + 1) % 12 == 0 && !legendaryIdeas.isEmpty {
                    // Insert Legendary (cycle through all of them fairly)
                    let legendaryIndex = (position / 12) % legendaryIdeas.count
                    finalDeck.append(legendaryIdeas[legendaryIndex])
                } else if regularIndex < shuffledRegular.count {
                    finalDeck.append(shuffledRegular[regularIndex])
                    regularIndex += 1
                    if regularIndex >= shuffledRegular.count {
                        regularIndex = 0  // loop regular ideas forever
                    }
                }
            }
            
            self.ideas = finalDeck
            self.currentIndex = 0
            self.isLoading = false
            
        } catch {
            print("JSON load error: \(error)")
            loadSampleIdeas()
        }
    }
    
    private func loadSampleIdeas() {
        // For testing — includes one Legendary
        let sample = [
            Idea(title: "Romantic Dinner", description: "Candlelit home dinner.", category: "Romantic", difficulty: 2, impressive: 4, imageName: "romanticDinner", level: .cute),
            Idea(title: "Sunset Hike", description: "Watch sunset from a hilltop.", category: "Adventure", difficulty: 3, impressive: 3, imageName: "sunsetHike", level: .epic),
            Idea(title: "DIY Spa Day", description: "Relaxing spa night at home.", category: "Relaxation", difficulty: 1, impressive: 2, imageName: "spaDay", level: .spicy),
            Idea(title: "Private Yacht Night", description: "Sail under the stars with champagne.", category: "Luxury", difficulty: 5, impressive: 5, imageName: "yachtNight", level: .legendary)
        ]
        self.ideas = sample.shuffled()
        self.currentIndex = 0
        self.isLoading = false
    }
    
    // MARK: - Actions
    func nextIdea() {
        guard !ideas.isEmpty else { return }
        currentIndex = (currentIndex + 1) % ideas.count
    }
    
    func previousIdea() {
        guard !ideas.isEmpty else { return }
        currentIndex = (currentIndex - 1 + ideas.count) % ideas.count
    }
    
    func likeIdea(_ idea: Idea) {
        FirebaseManager.shared.saveLikedIdea(idea, for: userId ?? "")
    }
    
    func saveIdea(_ idea: Idea) {
        FirebaseManager.shared.saveBookmarkedIdea(idea, for: userId ?? "")
    }
    
    func shareIdea(_ idea: Idea) {
        let text = "\(idea.title): \(idea.description)"
        let avc = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(avc, animated: true)
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
