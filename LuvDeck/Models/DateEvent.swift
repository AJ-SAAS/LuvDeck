import Foundation
import FirebaseFirestore

enum EventType: String, Codable, CaseIterable {
    case birthday = "Birthday"
    case anniversary = "Anniversary"
    case date = "Date"
    case other = "Other"
}

struct DateEvent: Identifiable, Codable {
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

    init(from firebaseEvent: FirebaseEvent) {
        self.id = UUID(uuidString: firebaseEvent.id) ?? UUID()
        self.personName = firebaseEvent.title
        self.date = firebaseEvent.date.dateValue()
        self.eventType = EventType(rawValue: firebaseEvent.type) ?? .other
        self.reminderOn = firebaseEvent.reminderOn
        self.rating = firebaseEvent.rating
        self.notes = firebaseEvent.notes
        self.reviewed = firebaseEvent.reviewed
    }
}
