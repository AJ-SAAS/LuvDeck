import Foundation
import FirebaseFirestore

struct FirebaseEvent: Codable, Identifiable {
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

    init(dateEvent: DateEvent) {
        self.id = dateEvent.id.uuidString
        self.title = dateEvent.personName
        self.date = Timestamp(date: dateEvent.date)
        self.type = dateEvent.eventType.rawValue
        self.reminderOn = dateEvent.reminderOn
        self.rating = dateEvent.rating
        self.notes = dateEvent.notes
        self.reviewed = dateEvent.reviewed
    }
}
