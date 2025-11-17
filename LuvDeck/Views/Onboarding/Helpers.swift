// Helpers.swift
import Foundation

extension UserDefaults {
    private static let hasSeenCongratulationsKey = "hasSeenCongratulations"
    
    static var hasSeenCongratulations: Bool {
        get { standard.bool(forKey: hasSeenCongratulationsKey) }
        set { standard.set(newValue, forKey: hasSeenCongratulationsKey) }
    }
}
