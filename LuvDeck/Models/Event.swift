import Foundation

struct Event: Identifiable, Codable {
    let id: UUID
    let title: String
    let date: Date
}
