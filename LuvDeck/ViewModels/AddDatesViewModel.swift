import SwiftUI
import Foundation

class AddDatesViewModel: ObservableObject {
    @Published var events: [DateEvent] = []
    @Published var errorMessage: String?
    @Published var showConfetti: Bool = false
    @Published var userId: String? // Public, as fixed previously

    init(userId: String? = nil) {
        self.userId = userId
        print("AddDatesViewModel initialized with userId: \(userId ?? "nil")")
        if let uid = userId { fetchEvents(for: uid) }
    }

    func setUserId(_ id: String) {
        self.userId = id
        print("AddDatesViewModel setUserId: \(id)")
        fetchEvents(for: id)
    }

    func addEvent(title: String, date: Date, type: EventType, reminderOn: Bool) {
        guard let uid = userId else {
            errorMessage = "Please log in to save events"
            print("No userId for saving event")
            return
        }
        guard !title.isEmpty else {
            errorMessage = "Please enter a title"
            print("Empty title for event")
            return
        }
        let event = DateEvent(
            id: UUID(),
            personName: title,
            date: date,
            eventType: type,
            reminderOn: reminderOn,
            rating: nil,
            notes: nil,
            reviewed: false
        )
        let firebaseEvent = FirebaseEvent(dateEvent: event)
        FirebaseManager.shared.saveEvent(firebaseEvent, for: uid) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.events.append(event)
                    self?.errorMessage = nil
                    self?.showConfetti = true
                    print("Event added to local events: \(event.personName)")
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("Failed to save event: \(error.localizedDescription)")
                }
            }
        }
    }

    func updateEvent(id: UUID, title: String, date: Date, type: EventType, reminderOn: Bool, rating: Int?, notes: String?, reviewed: Bool) {
        guard let uid = userId else {
            errorMessage = "Please log in to update events"
            print("No userId for updating event")
            return
        }
        guard !title.isEmpty else {
            errorMessage = "Please enter a title"
            print("Empty title for event update")
            return
        }
        guard let index = events.firstIndex(where: { $0.id == id }) else {
            errorMessage = "Event not found"
            print("Event not found for id: \(id)")
            return
        }
        let updatedEvent = DateEvent(
            id: id,
            personName: title,
            date: date,
            eventType: type,
            reminderOn: reminderOn,
            rating: rating,
            notes: notes,
            reviewed: reviewed
        )
        let firebaseEvent = FirebaseEvent(dateEvent: updatedEvent)
        FirebaseManager.shared.saveEvent(firebaseEvent, for: uid) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.events[index] = updatedEvent
                    self?.errorMessage = nil
                    print("Event updated: \(updatedEvent.personName)")
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("Failed to update event: \(error.localizedDescription)")
                }
            }
        }
    }

    func fetchEvents(for userId: String) {
        FirebaseManager.shared.fetchEvents(for: userId) { [weak self] events in
            DispatchQueue.main.async {
                self?.events = events.map { DateEvent(from: $0) } // Fixed label to 'from:'
                print("Updated events in view model: \(self?.events.map { $0.personName } ?? [])")
            }
        }
    }
}
