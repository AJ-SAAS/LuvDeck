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
    
    // MARK: - Data Loading
    func fetchIdeas() {
        guard let url = Bundle.main.url(forResource: "SwipeDeck", withExtension: "json") else {
            loadSampleIdeas()
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([Idea].self, from: data)
            
            // ✅ Separate all 4 levels with their own independent shuffle
            let cute      = decoded.filter { $0.level == .cute }.shuffled()
            let spicy     = decoded.filter { $0.level == .spicy }.shuffled()
            let epic      = decoded.filter { $0.level == .epic }.shuffled()
            let legendary = decoded.filter { $0.level == .legendary }.shuffled()
            
            var finalDeck: [Idea] = []
            
            if isPremiumProvider() {
                // ✅ Premium: heavy on legendary and spicy — that's what they paid for
                // Per 8 cards: spicy, legendary, spicy, epic, legendary, spicy, legendary, cute
                // = 3 spicy, 3 legendary, 1 epic, 1 cute per cycle
                var ci = 0; var si = 0; var ei = 0; var li = 0
                let pattern: [Int] = [1, 3, 1, 2, 3, 1, 3, 0] // 0=cute 1=spicy 2=epic 3=legendary
                
                while finalDeck.count < 120 {
                    let slot = pattern[finalDeck.count % pattern.count]
                    switch slot {
                    case 0 where !cute.isEmpty:
                        finalDeck.append(cute[ci % cute.count]); ci += 1
                    case 1 where !spicy.isEmpty:
                        finalDeck.append(spicy[si % spicy.count]); si += 1
                    case 2 where !epic.isEmpty:
                        finalDeck.append(epic[ei % epic.count]); ei += 1
                    case 3 where !legendary.isEmpty:
                        finalDeck.append(legendary[li % legendary.count]); li += 1
                    default:
                        if !spicy.isEmpty {
                            finalDeck.append(spicy[si % spicy.count]); si += 1
                        }
                    }
                }
                
            } else {
                // ✅ Free: first 10 are cute + spicy alternating — both are free, no lock screens
                // After that, epic teaser every 4th card, legendary every 10th
                var ci = 0; var si = 0; var ei = 0; var li = 0
                var csToggle = false

                // First 10 — cute and spicy alternating, zero lock screens
                for _ in 0..<10 {
                    if csToggle && !spicy.isEmpty {
                        finalDeck.append(spicy[si % spicy.count]); si += 1
                    } else if !cute.isEmpty {
                        finalDeck.append(cute[ci % cute.count]); ci += 1
                    }
                    csToggle.toggle()
                }

                // Next 90 — cute + spicy mix with paywalled teasers to drive upgrades
                for i in 0..<90 {
                    if (i + 1) % 10 == 0 && !legendary.isEmpty {
                        finalDeck.append(legendary[li % legendary.count]); li += 1
                    } else if (i + 1) % 4 == 0 && !epic.isEmpty {
                        finalDeck.append(epic[ei % epic.count]); ei += 1
                    } else {
                        if csToggle && !spicy.isEmpty {
                            finalDeck.append(spicy[si % spicy.count]); si += 1
                        } else if !cute.isEmpty {
                            finalDeck.append(cute[ci % cute.count]); ci += 1
                        }
                        csToggle.toggle()
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
            Idea(title: "Romantic Dinner",
                 description: "Candlelit home dinner.",
                 category: "Romantic",
                 difficulty: 2,
                 impressive: 4,
                 imageName: "romanticDinner",
                 level: .cute),
            Idea(title: "Sunset Hike",
                 description: "Watch sunset from a hilltop.",
                 category: "Adventure",
                 difficulty: 3,
                 impressive: 3,
                 imageName: "sunsetHike",
                 level: .epic),
            Idea(title: "DIY Spa Day",
                 description: "Relaxing spa night at home.",
                 category: "Relaxation",
                 difficulty: 1,
                 impressive: 2,
                 imageName: "spaDay",
                 level: .spicy),
            Idea(title: "Private Yacht Night",
                 description: "Sail under the stars with champagne.",
                 category: "Luxury",
                 difficulty: 5,
                 impressive: 5,
                 imageName: "yachtNight",
                 level: .legendary)
        ]
        self.ideas = sample.shuffled()
        self.currentIndex = 0
        self.isLoading = false
    }
    
    // MARK: - Navigation
    func nextIdea() {
        guard !ideas.isEmpty else { return }
        currentIndex = (currentIndex + 1) % ideas.count
    }
    
    func previousIdea() {
        guard !ideas.isEmpty else { return }
        currentIndex = (currentIndex - 1 + ideas.count) % ideas.count
    }
    
    // MARK: - Actions
    func likeIdea(_ idea: Idea) {
        guard let userId = userId,
              !userId.isEmpty,
              !UserDefaults.standard.bool(forKey: "guestMode")
        else {
            print("Guest user — like disabled")
            return
        }
        FirebaseManager.shared.saveLikedIdea(idea, for: userId)
    }
    
    func saveIdea(_ idea: Idea) {
        guard let userId = userId,
              !userId.isEmpty,
              !UserDefaults.standard.bool(forKey: "guestMode")
        else {
            print("Guest user — save disabled")
            return
        }
        FirebaseManager.shared.saveBookmarkedIdea(idea, for: userId)
    }
    
    func shareIdea(_ idea: Idea) {
        let text = "\(idea.title): \(idea.description)"
        let avc = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        UIApplication.shared.windows.first?.rootViewController?.present(avc, animated: true)
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
