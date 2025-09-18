import SwiftUI

struct AddDatesView: View {
    @EnvironmentObject var viewModel: AddDatesViewModel
    @State private var title = ""
    @State private var date = Date()
    @State private var showConfetti = false
    @FocusState private var isTitleFocused: Bool // Add focus state for TextField
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack(spacing: 20) {
                    Text("Add Special Dates")
                        .font(.system(size: min(geometry.size.width * 0.07, 28), weight: .bold))
                        .padding(.top, geometry.size.height * 0.05)
                    
                    TextField("Who's that special someone?", text: $title)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal, min(geometry.size.width * 0.1, 32))
                        .focused($isTitleFocused)
                        .onTapGesture {
                            isTitleFocused = true // Ensure keyboard opens
                        }
                    
                    DatePicker("Select Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.wheel) // Use wheel style for consistent interaction
                        .padding(.horizontal, min(geometry.size.width * 0.1, 32))
                    
                    Button(action: {
                        if !title.isEmpty {
                            print("Adding event with title: \(title), date: \(date)")
                            viewModel.addEvent(title: title, date: date)
                            title = ""
                            date = Date()
                            showConfetti = true
                            isTitleFocused = false // Dismiss keyboard
                        } else {
                            print("Cannot add event: Title is empty")
                        }
                    }) {
                        Text("Add Event")
                            .font(.system(size: min(geometry.size.width * 0.045, 18), weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, min(geometry.size.height * 0.02, 14))
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, min(geometry.size.width * 0.1, 32))
                    
                    List(viewModel.events) { event in
                        Text("\(event.title) - \(event.date, style: .date)")
                            .font(.system(size: min(geometry.size.width * 0.04, 16)))
                    }
                    .padding(.horizontal, min(geometry.size.width * 0.1, 32))
                    
                    Spacer()
                }
                .navigationTitle("Dates")
                .overlay {
                    if showConfetti {
                        ConfettiView(trigger: $showConfetti)
                    }
                }
                .background(Color(.systemBackground).ignoresSafeArea())
            }
        }
    }
}

#Preview("iPhone 14") {
    AddDatesView()
        .environmentObject(AddDatesViewModel(userId: "testUser"))
}

#Preview("iPad Pro") {
    AddDatesView()
        .environmentObject(AddDatesViewModel(userId: "testUser"))
}
