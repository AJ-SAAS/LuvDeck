import Foundation

// MARK: - Momentum Spark (Saved to Firestore)
struct Spark: Identifiable, Codable {
    let id: UUID
    let title: String
    var completed: Bool
    var category: MomentumCategory

    // Fallback for existing Firestore docs that don't have category saved yet
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        completed = try container.decode(Bool.self, forKey: .completed)
        category = try container.decodeIfPresent(MomentumCategory.self, forKey: .category) ?? .playfulness
    }

    init(id: UUID, title: String, completed: Bool, category: MomentumCategory) {
        self.id = id
        self.title = title
        self.completed = completed
        self.category = category
    }
}
