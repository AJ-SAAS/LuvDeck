import Foundation

struct Idea: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let category: String // e.g., "Date", "Anniversary", "Random Act"
    let difficulty: Int  // 1–5 scale
    let impressive: Int  // 1–5 scale
    let imageName: String
}
