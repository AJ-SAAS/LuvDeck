import SwiftUI

struct AddEditEventModal: View {
    @EnvironmentObject var viewModel: AddDatesViewModel
    @Environment(\.dismiss) var dismiss
    let eventToEdit: DateEvent?
    @State private var title: String = ""
    @State private var date: Date = Date()
    @State private var type: EventType = .other
    @State private var reminderOn: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                DatePicker("Date", selection: $date, displayedComponents: [.date])
                Picker("Type", selection: $type) {
                    ForEach(EventType.allCases, id: \.self) { type in
                        Text(type.rawValue.capitalized).tag(type)
                    }
                }
                Toggle("Reminder", isOn: $reminderOn)
            }
            .navigationTitle(eventToEdit == nil ? "Add Event" : "Edit Event")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let event = eventToEdit {
                            // Update existing event
                            viewModel.updateEvent(
                                id: event.id,
                                title: title,
                                date: date,
                                type: type,
                                reminderOn: reminderOn,
                                rating: event.rating, // Preserve existing values
                                notes: event.notes,
                                reviewed: event.reviewed
                            )
                        } else {
                            // Add new event
                            viewModel.addEvent(title: title, date: date, type: type, reminderOn: reminderOn)
                        }
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let event = eventToEdit {
                    print("Editing event: \(event.personName)")
                    title = event.personName
                    date = event.date
                    type = event.eventType
                    reminderOn = event.reminderOn
                }
            }
        }
    }
}

#Preview {
    AddEditEventModal(eventToEdit: nil)
        .environmentObject(AddDatesViewModel(userId: "test-uid"))
}
