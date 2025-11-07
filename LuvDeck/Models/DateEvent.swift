import Foundation
import FirebaseFirestore

// MARK: - Event Type
enum EventType: String, Codable, CaseIterable {
    case birthday = "Birthday"
    case anniversary = "Anniversary"
    case date = "Date"
    case other = "Other"

    var sfSymbolName: String {
        switch self {
        case .birthday: return "gift.fill"
        case .anniversary: return "heart.circle.fill"
        case .date: return "calendar"
        case .other: return "sparkles"
        }
    }
}

// MARK: - UI Model
struct DateEvent: Identifiable, Codable, Equatable {
    var id: UUID
    var personName: String
    var date: Date
    var eventType: EventType
    var reminderOn: Bool
    var rating: Int?
    var notes: String?
    var reviewed: Bool

    init(id: UUID = UUID(),
         personName: String,
         date: Date,
         eventType: EventType,
         reminderOn: Bool,
         rating: Int? = nil,
         notes: String? = nil,
         reviewed: Bool = false) {
        self.id = id
        self.personName = personName
        self.date = date
        self.eventType = eventType
        self.reminderOn = reminderOn
        self.rating = rating
        self.notes = notes
        self.reviewed = reviewed
    }
}

// MARK: - Firebase Bridge
extension DateEvent {
    var firebase: FirebaseEvent {
        FirebaseEvent(
            id: id.uuidString,
            title: personName,
            date: Timestamp(date: date),
            type: eventType.rawValue,
            reminderOn: reminderOn,
            rating: rating,
            notes: notes,
            reviewed: reviewed
        )
    }

    init(from firebase: FirebaseEvent) {
        self.id = UUID(uuidString: firebase.id) ?? UUID()
        self.personName = firebase.title
        self.date = firebase.date.dateValue()
        self.eventType = EventType(rawValue: firebase.type) ?? .other
        self.reminderOn = firebase.reminderOn
        self.rating = firebase.rating
        self.notes = firebase.notes
        self.reviewed = firebase.reviewed
    }
}

// MARK: - Firestore Model (kept only for encoding)
struct FirebaseEvent: Codable {
    var id: String
    var title: String
    var date: Timestamp
    var type: String
    var reminderOn: Bool
    var rating: Int?
    var notes: String?
    var reviewed: Bool

    init(id: String = UUID().uuidString,
         title: String,
         date: Timestamp,
         type: String,
         reminderOn: Bool,
         rating: Int? = nil,
         notes: String? = nil,
         reviewed: Bool = false) {
        self.id = id
        self.title = title
        self.date = date
        self.type = type
        self.reminderOn = reminderOn
        self.rating = rating
        self.notes = notes
        self.reviewed = reviewed
    }
}
