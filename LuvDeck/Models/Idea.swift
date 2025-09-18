import Foundation

enum Level: String, Codable {
    case cute = "Cute"
    case spicy = "Spicy"
    case epic = "Epic"
    case legendary = "Legendary"
}

struct Idea: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let category: String
    let difficulty: Int
    let impressive: Int
    let imageName: String
    let level: Level
    
    var difficultyStars: String { String(repeating: "★", count: difficulty) }
    var impressiveStars: String { String(repeating: "★", count: impressive) }
    
    private enum CodingKeys: String, CodingKey {
        case title, description, imageName, level
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.imageName = try container.decode(String.self, forKey: .imageName)
        let levelStr = try container.decode(String.self, forKey: .level)
        if let level = Level(rawValue: levelStr) {
            self.level = level
        } else {
            print("Invalid level '\(levelStr)' for idea '\(title)', defaulting to Cute")
            self.level = .cute
        }
        
        self.category = "Random"
        self.difficulty = 3
        self.impressive = 3
    }
    
    init(id: UUID = UUID(), title: String, description: String, category: String, difficulty: Int, impressive: Int, imageName: String, level: Level) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.difficulty = difficulty
        self.impressive = impressive
        self.imageName = imageName
        self.level = level
    }
}
