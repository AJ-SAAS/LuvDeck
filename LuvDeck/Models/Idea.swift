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
    
    var difficultyStars: String { String(repeating: "★", count: max(1, min(difficulty, 5))) }
    var impressiveStars: String { String(repeating: "★", count: max(1, min(impressive, 5))) }
    
    private enum CodingKeys: String, CodingKey {
        case title, description, imageName, level, category, difficulty, impressive
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.imageName = try container.decode(String.self, forKey: .imageName)
        
        // Decode level and handle invalid cases without capturing self
        let levelStr = try container.decode(String.self, forKey: .level)
        if let level = Level(rawValue: levelStr) {
            self.level = level
        } else {
            print("Invalid level '\(levelStr)' for idea '\(self.title)', defaulting to Cute")
            self.level = .cute
        }
        
        // Decode optional fields with defaults based on level
        self.category = try container.decodeIfPresent(String.self, forKey: .category) ?? "Romantic"
        switch self.level {
        case .cute:
            self.difficulty = try container.decodeIfPresent(Int.self, forKey: .difficulty) ?? 1
            self.impressive = try container.decodeIfPresent(Int.self, forKey: .impressive) ?? 1
        case .spicy:
            self.difficulty = try container.decodeIfPresent(Int.self, forKey: .difficulty) ?? 2
            self.impressive = try container.decodeIfPresent(Int.self, forKey: .impressive) ?? 2
        case .epic:
            self.difficulty = try container.decodeIfPresent(Int.self, forKey: .difficulty) ?? 3
            self.impressive = try container.decodeIfPresent(Int.self, forKey: .impressive) ?? 3
        case .legendary:
            self.difficulty = try container.decodeIfPresent(Int.self, forKey: .difficulty) ?? 4
            self.impressive = try container.decodeIfPresent(Int.self, forKey: .impressive) ?? 4
        }
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
