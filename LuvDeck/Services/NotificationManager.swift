import UserNotifications
import Foundation

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                DispatchQueue.main.async {
                    completion(granted && error == nil)
                }
            }
    }

    func schedule(for event: DateEvent) {
        guard event.reminderOn, event.date > Date() else {
            remove(for: event)
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "\(event.eventType.rawValue) Reminder"

        // Use DateFormatter (works on iOS 13+)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        content.body = "\(event.personName)’s \(event.eventType.rawValue.lowercased()) is on \(formatter.string(from: event.date))"

        content.sound = .default

        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: event.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

        let request = UNNotificationRequest(identifier: event.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { err in
            if let err = err {
                print("Notification error: \(err)")
            }
        }
    }

    func remove(for event: DateEvent) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [event.id.uuidString])
    }
}
