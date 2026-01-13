import SwiftUI

struct AddDateSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: AddDatesViewModel

    @State private var title = ""
    @State private var date = Date()
    @State private var eventType: EventType = .birthday
    @State private var reminderOn = true
    @State private var showDeleteAlert = false   // <-- For delete confirmation

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

                    // ===============================
                    // Updated DatePicker: allow any date & highlight today
                    // ===============================
                    DatePicker(
                        "Date",
                        selection: $date,
                        in: ...Date.distantFuture,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .accentColor(.pink)
                    .background(todayBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.vertical, 4)

                    Picker("Type", selection: $eventType) {
                        ForEach(EventType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.sfSymbolName)
                        }
                    }
                    Toggle("Reminder", isOn: $reminderOn)
                }

                // DELETE BUTTON SECTION — only for editing
                if editingEvent != nil {
                    Section {
                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            Text("Delete Event")
                                .bold()
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .alert("Delete Event?", isPresented: $showDeleteAlert) {
                            Button("Cancel", role: .cancel) {}
                            Button("Delete", role: .destructive) {
                                if let ev = editingEvent,
                                   let index = viewModel.events.firstIndex(where: { $0.id == ev.id }) {
                                    viewModel.deleteEvents(at: IndexSet([index]))
                                    dismiss()
                                }
                            }
                        } message: {
                            Text("This will permanently delete the event.")
                        }
                    }
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
                            let updated = DateEvent(
                                id: ev.id,
                                personName: title,
                                date: date,
                                eventType: eventType,
                                reminderOn: reminderOn,
                                rating: ev.rating,
                                notes: ev.notes,
                                reviewed: ev.reviewed
                            )
                            viewModel.updateEvent(updated)
                            dismiss()
                        } else {
                            if viewModel.canCreateEvent() {
                                viewModel.addEvent(
                                    title: title,
                                    date: date,
                                    type: eventType,
                                    reminderOn: reminderOn
                                )
                                dismiss()
                            } else {
                                viewModel.showPaywall = true
                            }
                        }
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }

    // MARK: - Subtle background for today
    private var todayBackground: some View {
        GeometryReader { geo in
            let today = Calendar.current.startOfDay(for: Date())
            let selectedDay = Calendar.current.startOfDay(for: date)

            if today == selectedDay {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.pink.opacity(0.2))
                    .frame(width: geo.size.width, height: geo.size.height)
                    .allowsHitTesting(false)
            } else {
                EmptyView()
            }
        }
    }
}
