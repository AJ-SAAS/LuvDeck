import SwiftUI

struct DateRow: View {
    let event: DateEvent
    let toggleReminder: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(event.personName)
                    .font(.headline)
                Text(event.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(event.eventType.rawValue)
                    .font(.caption)
                    .foregroundColor(.pink)          // <-- fixed
            }
            Spacer()
            Toggle("", isOn: Binding(
                get: { event.reminderOn },
                set: { _ in toggleReminder() }
            ))
            .labelsHidden()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
} 
