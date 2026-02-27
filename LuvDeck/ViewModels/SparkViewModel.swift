import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class SparkViewModel: ObservableObject {
    
    // MARK: - Spark UI (Original Spark Cards)
    @Published var showingSheet = false
    @Published var selectedItem: SparkItem?
    
    @Published var showPaywall = false
    
    @AppStorage("luvdeck_isPremium") var isPremium: Bool = false
    
    // ==========================
    // 🔥 Momentum
    // ==========================
    @Published var showMomentumSheet = false
    @Published var userSparks: [Spark] = []
    
    init() {
        fetchCurrentUserSparks()
    }
    
    // ==========================
    // 🔥 Momentum Fetch
    // ==========================
    
    func fetchCurrentUserSparks() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        fetchUserSparks(userId: userId)
    }
    
    func fetchUserSparks(userId: String) {
        FirebaseManager.shared.fetchUserSparks(userId: userId) { sparks in
            DispatchQueue.main.async {
                if sparks.isEmpty {
                    self.seedUserSparksIfNeeded(userId: userId)
                } else {
                    self.userSparks = sparks
                }
            }
        }
    }
    
    // ==========================
    // 🔥 Seed Momentum From momentumDatabase
    // ==========================
    
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
            Spark(id: UUID(), title: item.text, completed: false)
        }
        
        self.userSparks = newSparks
        
        newSparks.forEach {
            FirebaseManager.shared.saveSpark(userId: userId, spark: $0)
        }
    }
    
    // ==========================
    // 🔥 Toggle Momentum Spark
    // ==========================
    
    func toggleSpark(_ spark: Spark) {
        guard let index = userSparks.firstIndex(where: { $0.id == spark.id }) else { return }
        
        if isPremium || sparkIsFree(spark) {
            withAnimation(.easeInOut(duration: 0.25)) {
                userSparks[index].completed.toggle()
            }
            
            if let userId = Auth.auth().currentUser?.uid {
                FirebaseManager.shared.saveSpark(userId: userId, spark: userSparks[index])
            }
        } else {
            showPaywall = true
        }
    }
    
    private func sparkIsFree(_ spark: Spark) -> Bool {
        if let item = momentumDatabase.first(where: { $0.text == spark.title }) {
            return item.category == .playfulness
        }
        return false
    }
    
    // ==========================
    // 🔥 Progress
    // ==========================
    
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
