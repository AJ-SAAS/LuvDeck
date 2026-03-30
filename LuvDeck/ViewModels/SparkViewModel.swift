import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class SparkViewModel: ObservableObject {
    
    // MARK: - Spark UI
    @Published var showingSheet = false
    @Published var selectedItem: SparkItem?
    @Published var showPaywall = false
    @Published var isPremium: Bool = false
    
    // MARK: - Momentum
    @Published var showMomentumSheet = false
    @Published var userSparks: [Spark] = []
    
    // ✅ Holds the auth listener so it doesn't get deallocated
    private var authListener: AuthStateDidChangeListenerHandle?
    
    // MARK: - Free User Usage Tracking (per category)
    @AppStorage("conversationUsed") private var conversationUsed: Int = 0
    @AppStorage("deepQuestionUsed") private var deepQuestionUsed: Int = 0
    @AppStorage("challengeUsed") private var challengeUsed: Int = 0
    @AppStorage("miniActionUsed") private var miniActionUsed: Int = 0

    // Prevent immediate repeat of the same prompt
    @AppStorage("lastConversation") private var lastConversation: String = ""
    @AppStorage("lastDeepQuestion") private var lastDeepQuestion: String = ""
    @AppStorage("lastChallenge") private var lastChallenge: String = ""
    @AppStorage("lastMiniAction") private var lastMiniAction: String = ""

    init() {
        // ✅ Wait for Firebase Auth to restore session, then fetch
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self, let userId = user?.uid else { return }
            self.fetchUserSparks(userId: userId)
        }
    }
    
    deinit {
        if let listener = authListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
    
    // MARK: - New: Get Random Spark (Main Function)
    func getRandomSpark(for category: SparkCategory) -> SparkItem? {
        if isPremium {
            return getPremiumRandom(for: category)
        } else {
            return getFreeRandom(for: category)
        }
    }

    private func getFreeRandom(for category: SparkCategory) -> SparkItem? {
        let used = usedCount(for: category)
        if used >= 3 {
            return nil  // Trigger paywall
        }

        if let prompt = getUniqueRandomPrompt(for: category) {
            incrementUsed(for: category)
            saveLastShown(prompt, for: category)
            return SparkItem(text: prompt, category: category)
        }
        return nil
    }

    private func getPremiumRandom(for category: SparkCategory) -> SparkItem? {
        if let prompt = getUniqueRandomPrompt(for: category) {
            saveLastShown(prompt, for: category)
            return SparkItem(text: prompt, category: category)
        }
        return nil
    }

    private func getUniqueRandomPrompt(for category: SparkCategory) -> String? {
        let array = arrayFor(category)
        let last = lastShown(for: category)

        var candidates = array
        if !last.isEmpty {
            candidates = candidates.filter { $0 != last }
        }

        return candidates.randomElement()
    }

    // MARK: - Helpers for Random Logic
    private func arrayFor(_ category: SparkCategory) -> [String] {
        switch category {
        case .conversation: return conversationStarters
        case .deepQuestion: return deepQuestions
        case .challenge:    return romanceChallenges
        case .miniAction:   return miniLoveActions
        }
    }

    private func usedCount(for category: SparkCategory) -> Int {
        switch category {
        case .conversation: return conversationUsed
        case .deepQuestion: return deepQuestionUsed
        case .challenge:    return challengeUsed
        case .miniAction:   return miniActionUsed
        }
    }

    private func incrementUsed(for category: SparkCategory) {
        switch category {
        case .conversation: conversationUsed += 1
        case .deepQuestion: deepQuestionUsed += 1
        case .challenge:    challengeUsed += 1
        case .miniAction:   miniActionUsed += 1
        }
    }

    private func lastShown(for category: SparkCategory) -> String {
        switch category {
        case .conversation: return lastConversation
        case .deepQuestion: return lastDeepQuestion
        case .challenge:    return lastChallenge
        case .miniAction:   return lastMiniAction
        }
    }

    private func saveLastShown(_ text: String, for category: SparkCategory) {
        switch category {
        case .conversation: lastConversation = text
        case .deepQuestion: lastDeepQuestion = text
        case .challenge:    lastChallenge = text
        case .miniAction:   lastMiniAction = text
        }
    }

    // MARK: - Reset Free Usage (useful for testing)
    func resetFreeUsage() {
        conversationUsed = 0
        deepQuestionUsed = 0
        challengeUsed = 0
        miniActionUsed = 0
    }

    // MARK: - Fetch
    func fetchCurrentUserSparks() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        fetchUserSparks(userId: userId)
    }
    
    func fetchUserSparks(userId: String) {
        FirebaseManager.shared.fetchUserSparks(userId: userId) { [weak self] sparks in
            guard let self = self else { return }
            
            print("📦 Fetched \(sparks.count) sparks")
            sparks.prefix(3).forEach { print("  - \($0.title) | category: \($0.category)") }
            
            if sparks.isEmpty {
                self.seedUserSparksIfNeeded(userId: userId)
                return
            }

            let needsMigration = sparks.contains { spark in
                momentumDatabase.first(where: { $0.text == spark.title })?.category != spark.category
            }
            
            print("🔄 Needs migration: \(needsMigration)")

            if needsMigration {
                let migratedSparks: [Spark] = sparks.map { spark in
                    if let match = momentumDatabase.first(where: { $0.text == spark.title }) {
                        return Spark(id: spark.id, title: spark.title, completed: spark.completed, category: match.category)
                    }
                    return spark
                }
                DispatchQueue.main.async {
                    self.userSparks = migratedSparks
                }
                DispatchQueue.global(qos: .background).async {
                    migratedSparks.forEach {
                        FirebaseManager.shared.saveSpark(userId: userId, spark: $0)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.userSparks = sparks
                }
            }
        }
    }
    
    // MARK: - Seed Momentum
    private func seedUserSparksIfNeeded(userId: String) {
        let categoryOrder: [MomentumCategory] = [
            .playfulness,
            .emotionalDepth,
            .surpriseChemistry,
            .adventureMemory,
            .legendaryPartner
        ]
        
        let sortedItems = momentumDatabase.sorted {
            guard let firstIndex = categoryOrder.firstIndex(of: $0.category),
                  let secondIndex = categoryOrder.firstIndex(of: $1.category) else { return false }
            return firstIndex < secondIndex
        }
        
        let newSparks: [Spark] = sortedItems.map { item in
            Spark(id: UUID(), title: item.text, completed: false, category: item.category)
        }
        
        print("🌱 Seeding \(newSparks.count) sparks")
        newSparks.prefix(3).forEach { print("  - \($0.title) | category: \($0.category)") }
        
        DispatchQueue.main.async {
            self.userSparks = newSparks
        }
        
        DispatchQueue.global(qos: .background).async {
            newSparks.forEach {
                FirebaseManager.shared.saveSpark(userId: userId, spark: $0)
            }
        }
    }
    
    // MARK: - Toggle Momentum Spark
    func toggleSpark(_ spark: Spark) {
        guard let index = userSparks.firstIndex(where: { $0.id == spark.id }) else { return }
        
        if isPremium || sparkIsFree(spark) {
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.25)) {
                    self.userSparks[index].completed.toggle()
                }
            }
            if let userId = Auth.auth().currentUser?.uid {
                FirebaseManager.shared.saveSpark(userId: userId, spark: userSparks[index])
            }
        } else {
            DispatchQueue.main.async {
                self.showPaywall = true
            }
        }
    }
    
    private func sparkIsFree(_ spark: Spark) -> Bool {
        spark.category == .playfulness
    }
    
    // MARK: - Progress
    var completedSparksCount: Double {
        Double(userSparks.filter { $0.completed }.count)
    }
    
    var totalSparksCount: Double {
        Double(userSparks.count)
    }
    
    var completionPercentage: Double {
        guard totalSparksCount > 0 else { return 0 }
        return (completedSparksCount / totalSparksCount) * 100
    }
}
