// SparkItems.swift  ←  create/replace this file
import Foundation

struct SparkItem: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let category: SparkCategory
}

enum SparkCategory: String, CaseIterable {
    case conversation = "Conversation Starters"
    case deepQuestion = "Know Your Partner"
    case challenge    = "Romance Challenge"
    case miniAction   = "Mini Love Action"
}

// This combines your four separate arrays into one master list
let sparkDatabase: [SparkItem] = {
    var all: [SparkItem] = []
    
    conversationStarters.forEach { all.append(SparkItem(text: $0, category: .conversation)) }
    deepQuestions.forEach       { all.append(SparkItem(text: $0, category: .deepQuestion)) }
    romanceChallenges.forEach   { all.append(SparkItem(text: $0, category: .challenge)) }
    miniLoveActions.forEach     { all.append(SparkItem(text: $0, category: .miniAction)) }
    
    return all.shuffled()
}()
