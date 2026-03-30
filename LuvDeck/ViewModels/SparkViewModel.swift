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
    
    // MARK: - Fetch
    func fetchCurrentUserSparks() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        fetchUserSparks(userId: userId)
    }
    
    func fetchUserSparks(userId: String) {
        FirebaseManager.shared.fetchUserSparks(userId: userId) { [weak self] sparks in
            guard let self = self else { return }
            
            // ✅ TEMP DEBUG - remove after testing
            print("📦 Fetched \(sparks.count) sparks")
            sparks.prefix(3).forEach { print("  - \($0.title) | category: \($0.category)") }
            
            if sparks.isEmpty {
                self.seedUserSparksIfNeeded(userId: userId)
                return
            }

            let needsMigration = sparks.contains { spark in
                momentumDatabase.first(where: { $0.text == spark.title })?.category != spark.category
            }
            
            // ✅ TEMP DEBUG
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
        
        // ✅ TEMP DEBUG
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
