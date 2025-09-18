import Foundation

struct User: Identifiable, Equatable {
    let id: String // Firebase UID
    let email: String
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id && lhs.email == rhs.email
    }
}
