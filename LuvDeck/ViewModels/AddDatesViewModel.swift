import SwiftUI

class AddDatesViewModel: ObservableObject {
    @Published var events: [Event] = []
    private var userId: String?
    
    init(userId: String?) {
        self.userId = userId
        fetchEvents()
    }
    
    func addEvent(title: String, date: Date) {
        guard let userId = userId else {
            print("No user ID available for saving event")
            return
        }
        let event = Event(id: UUID(), title: title, date: date)
        events.append(event)
        FirebaseManager.shared.saveEvent(event, for: userId)
        NotificationManager.shared.scheduleNotification(for: event)
    }
    
    func fetchEvents() {
        guard let userId = userId else {
            print("No user ID available for fetching events")
            return
        }
        FirebaseManager.shared.fetchEvents(for: userId) { [weak self] events in
            DispatchQueue.main.async {
                self?.events = events
            }
        }
    }
}
