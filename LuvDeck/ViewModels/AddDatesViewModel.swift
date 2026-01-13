import Foundation
import SwiftUI

final class AddDatesViewModel: ObservableObject {
    @Published var events: [DateEvent] = []
    @Published var errorMessage: String?
    @Published var showConfetti = false

    /// When true the UI will present the Paywall
    @Published var showPaywall: Bool = false

    private let firebase = FirebaseManager.shared
    private let notifications = NotificationManager.shared
    private var userId: String?

    /// A provider closure that returns whether the current user has premium.
    /// This avoids a hard dependency on PurchaseViewModel and keeps the VM testable.
    private let isPremiumProvider: () -> Bool

    // MARK: - Initializer
    /// isPremiumProvider: pass a closure that returns PurchaseViewModel.isPremium
    init(userId: String? = nil, isPremiumProvider: @escaping () -> Bool = { false }) {
        self.userId = userId
        self.isPremiumProvider = isPremiumProvider
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

    /// All events, sorted by date (past, today, future)
    var upcomingEvents: [DateEvent] {
        events
            .sorted { $0.date < $1.date }           // Sort all events by date
    }

    /// Utility: whether the current user may create another event
    func canCreateEvent() -> Bool {
        if isPremiumProvider() { return true }
        return events.count < 3
    }

    func addEvent(title: String, date: Date, type: EventType, reminderOn: Bool) {
        guard let uid = userId else { errorMessage = "No user logged in"; return }

        // Enforce free-user limit: clients should also check before showing the Add sheet,
        // but this double-checks before saving to Firestore.
        if !isPremiumProvider() && events.count >= 3 {
            // trigger the paywall instead of creating
            DispatchQueue.main.async {
                self.showPaywall = true
            }
            return
        }

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
