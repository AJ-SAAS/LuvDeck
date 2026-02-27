import Foundation

struct Spark: Identifiable, Codable {
    let id: UUID
    let title: String
    var completed: Bool
}
