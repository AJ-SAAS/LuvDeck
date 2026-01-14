// HomeViewModel.swift
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import StoreKit

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
    
    // MARK: - Review Prompt Settings
    private let reviewSwipeThreshold = 8
    private let reviewCooldownDays: Double = 30
    private let lastReviewKey = "lastReviewRequestDate"
    private let lastVersionKey = "lastVersionReviewed"
    
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
        
        swipeCount += 1
        checkTeaserBanner()
        checkReviewPrompt()
    }
    
    private func checkTeaserBanner() {
        guard !hasShownTeaserThisSession else { return }
        if swipeCount >= teaserInterval {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showTeaserBanner = true
            }
            hasShownTeaserThisSession = true
        }
    }
    
    // MARK: - Review Prompt Logic
    private func checkReviewPrompt() {
        guard swipeCount >= reviewSwipeThreshold else { return }
        
        let now = Date()
        let lastRequest = UserDefaults.standard.object(forKey: lastReviewKey) as? Date ?? .distantPast
        let lastVersion = UserDefaults.standard.string(forKey: lastVersionKey)
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
        
        // Only prompt if 30+ days passed OR app version changed
        if now.timeIntervalSince(lastRequest) > reviewCooldownDays * 86400 || lastVersion != currentVersion {
            requestReview()
            UserDefaults.standard.set(now, forKey: lastReviewKey)
            UserDefaults.standard.set(currentVersion, forKey: lastVersionKey)
        }
    }
    
    private func requestReview() {
        DispatchQueue.main.async {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
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
    
    // MARK: - Data Loading – First 12 free ideas are cute + spicy only
    func fetchIdeas() {
        guard let url = Bundle.main.url(forResource: "SwipeDeck", withExtension: "json") else {
            loadSampleIdeas()
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([Idea].self, from: data)
            
            // Separate by level
            let cuteSpicyIdeas = decoded.filter { $0.level == .cute || $0.level == .spicy }
            let epicIdeas = decoded.filter { $0.level == .epic }
            let legendaryIdeas = decoded.filter { $0.level == .legendary }
            
            // Shuffle each group
            let shuffledCuteSpicy = cuteSpicyIdeas.shuffled()
            let shuffledEpic = epicIdeas.shuffled()
            let shuffledLegendary = legendaryIdeas.shuffled()
            
            var finalDeck: [Idea] = []
            var cuteSpicyIndex = 0
            var epicIndex = 0
            var legendaryIndex = 0
            
            // If user is premium → full mix from start
            if isPremiumProvider() {
                // Same as your original logic (every 12th legendary)
                for position in 0..<1000 {
                    if (position + 1) % 12 == 0 && !shuffledLegendary.isEmpty {
                        let idx = (position / 12) % shuffledLegendary.count
                        finalDeck.append(shuffledLegendary[idx])
                    } else if !shuffledCuteSpicy.isEmpty {
                        finalDeck.append(shuffledCuteSpicy[cuteSpicyIndex % shuffledCuteSpicy.count])
                        cuteSpicyIndex += 1
                    }
                }
            }
            // Free user → first 12 cute/spicy only, then mix with premium
            else {
                // First 12: only cute + spicy
                for _ in 0..<12 {
                    if !shuffledCuteSpicy.isEmpty {
                        finalDeck.append(shuffledCuteSpicy[cuteSpicyIndex % shuffledCuteSpicy.count])
                        cuteSpicyIndex += 1
                    }
                }
                
                // After that: normal mix (epic + legendary every 12th)
                for position in 12..<1000 {
                    let realPosition = position - 12  // for legendary timing
                    
                    if (realPosition + 1) % 12 == 0 && !shuffledLegendary.isEmpty {
                        let idx = (realPosition / 12) % shuffledLegendary.count
                        finalDeck.append(shuffledLegendary[idx])
                    } else if (realPosition + 1) % 6 == 0 && !shuffledEpic.isEmpty {
                        // Optional: add epic more frequently (every 6th after intro)
                        let idx = (realPosition / 6) % shuffledEpic.count
                        finalDeck.append(shuffledEpic[idx])
                    } else if !shuffledCuteSpicy.isEmpty {
                        finalDeck.append(shuffledCuteSpicy[cuteSpicyIndex % shuffledCuteSpicy.count])
                        cuteSpicyIndex += 1
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
