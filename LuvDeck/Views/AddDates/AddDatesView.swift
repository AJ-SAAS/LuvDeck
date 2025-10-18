import SwiftUI

struct AddDatesView: View {
    @EnvironmentObject var viewModel: AddDatesViewModel
    @State private var showingModal = false
    @State private var editingEvent: DateEvent?

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.events.isEmpty {
                    Spacer()
                    Text("No events yet.\nTap + to add your first special date!")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding()
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.events) { event in
                            Button(action: {
                                print("Tapped event: \(event.personName), ID: \(event.id)")
                                editingEvent = event
                                DispatchQueue.main.async {
                                    showingModal = true
                                }
                            }) {
                                VStack(alignment: .leading) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(event.personName)
                                                .font(.headline)
                                            Text(event.eventType.rawValue.capitalized)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        Text(event.date, style: .date)
                                    }
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                Text("showingModal: \(showingModal.description), editingEvent: \(editingEvent?.personName ?? "none")")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .navigationTitle("Dates")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        print("Plus button tapped")
                        editingEvent = nil
                        showingModal = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(.pink)
                            .padding(12)
                            .frame(width: 60, height: 60)
                            .background(Circle().fill(Color(.systemBackground)).shadow(radius: 4))
                    }
                }
            }
            .sheet(isPresented: $showingModal) {
                AddDateSheet(eventToEdit: editingEvent)
                    .onDisappear {
                        print("Modal dismissed, resetting editingEvent")
                        editingEvent = nil
                    }
            }
        }
        .onAppear {
            print("AddDatesView appeared, userId: \(viewModel.userId ?? "nil"), events: \(viewModel.events.map { $0.personName })")
        }
    }
}

#Preview {
    AddDatesView()
        .environmentObject(AddDatesViewModel(userId: "test-uid"))
        .environmentObject(AuthViewModel())
}
