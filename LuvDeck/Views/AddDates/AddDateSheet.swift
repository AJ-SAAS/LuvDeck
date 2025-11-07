import SwiftUI

struct AddDateSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: AddDatesViewModel

    @State private var title = ""
    @State private var date = Date()
    @State private var eventType: EventType = .birthday
    @State private var reminderOn = true

    private let editingEvent: DateEvent?

    init(viewModel: AddDatesViewModel, event: DateEvent? = nil) {
        self.viewModel = viewModel
        self.editingEvent = event
        self._title = State(initialValue: event?.personName ?? "")
        self._date = State(initialValue: event?.date ?? Date())
        self._eventType = State(initialValue: event?.eventType ?? .birthday)
        self._reminderOn = State(initialValue: event?.reminderOn ?? true)
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Name", text: $title)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    Picker("Type", selection: $eventType) {
                        ForEach(EventType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.sfSymbolName)
                        }
                    }
                    Toggle("Reminder", isOn: $reminderOn)
                }
            }
            .navigationTitle(editingEvent == nil ? "Add Event" : "Edit Event")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let ev = editingEvent {
                            let updated = DateEvent(id: ev.id,
                                                    personName: title,
                                                    date: date,
                                                    eventType: eventType,
                                                    reminderOn: reminderOn,
                                                    rating: ev.rating,
                                                    notes: ev.notes,
                                                    reviewed: ev.reviewed)
                            viewModel.updateEvent(updated)
                        } else {
                            viewModel.addEvent(title: title,
                                               date: date,
                                               type: eventType,
                                               reminderOn: reminderOn)
                        }
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}
