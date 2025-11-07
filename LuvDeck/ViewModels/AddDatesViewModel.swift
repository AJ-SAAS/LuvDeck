import Foundation
import SwiftUI

final class AddDatesViewModel: ObservableObject {
    @Published var events: [DateEvent] = []
    @Published var errorMessage: String?
    @Published var showConfetti = false

    private let firebase = FirebaseManager.shared
    private let notifications = NotificationManager.shared
    private var userId: String?

    // MARK: - Initializer
    init(userId: String? = nil) {
        self.userId = userId
        if let uid = userId, !uid.isEmpty {
            fetchEvents()
        }
    }

    // MARK: - Public API
    func setUserId(_ id: String?) {
        userId = id
        if id?.isEmpty == false { fetchEvents() }
        else { events = [] }
    }

    /// Upcoming events only, sorted by nearest date first
    var upcomingEvents: [DateEvent] {
        events
            .filter { $0.date >= Date() }           // Only future dates
            .sorted { $0.date < $1.date }           // Nearest first
    }

    func addEvent(title: String, date: Date, type: EventType, reminderOn: Bool) {
        guard let uid = userId else { errorMessage = "No user logged in"; return }

        let event = DateEvent(personName: title,
                              date: date,
                              eventType: type,
                              reminderOn: reminderOn)

        firebase.saveEvent(event.firebase, for: uid) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.events.append(event)
                    if event.reminderOn { self?.notifications.schedule(for: event) }
                    self?.showConfetti = true
                case .failure(let err):
                    self?.errorMessage = err.localizedDescription
                }
            }
        }
    }

    func updateEvent(_ event: DateEvent) {
        guard let uid = userId else { return }

        firebase.saveEvent(event.firebase, for: uid) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if let i = self?.events.firstIndex(where: { $0.id == event.id }) {
                        self?.events[i] = event
                        if event.reminderOn { self?.notifications.schedule(for: event) }
                        else { self?.notifications.remove(for: event) }
                    }
                case .failure(let err):
                    self?.errorMessage = err.localizedDescription
                }
            }
        }
    }

    func deleteEvents(at offsets: IndexSet) {
        guard let uid = userId else { return }
        let toDelete = offsets.map { events[$0] }

        for event in toDelete {
            firebase.deleteEvent(event.id.uuidString, for: uid) { [weak self] result in
                DispatchQueue.main.async {
                    if case .success = result {
                        self?.events.removeAll { $0.id == event.id }
                        self?.notifications.remove(for: event)
                    }
                }
            }
        }
    }

    func toggleReminder(for event: DateEvent) {
        let updated = DateEvent(id: event.id,
                                personName: event.personName,
                                date: event.date,
                                eventType: event.eventType,
                                reminderOn: !event.reminderOn,
                                rating: event.rating,
                                notes: event.notes,
                                reviewed: event.reviewed)
        updateEvent(updated)
    }

    func fetchEvents() {
        guard let uid = userId else { return }
        firebase.fetchEvents(for: uid) { [weak self] fbEvents in
            DispatchQueue.main.async {
                self?.events = fbEvents.map { DateEvent(from: $0) }
            }
        }
    }
}
