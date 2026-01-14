import Foundation

enum AppScreen: Hashable {
    case splash
    case congratulations
    case auth
    case onboarding
    case welcome    // ← NEW: Welcome screen after onboarding/paywall
    case home
}
