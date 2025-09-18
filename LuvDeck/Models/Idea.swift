import Foundation

struct Idea: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let category: String // e.g., "Date", "Anniversary", "Random Act"
}
