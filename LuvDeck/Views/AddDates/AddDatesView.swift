import SwiftUI

struct AddDatesView: View {
    @EnvironmentObject var viewModel: AddDatesViewModel
    @State private var title = ""
    @State private var date = Date()
    @State private var showConfetti = false
    
    var body: some View {
        ZStack {
            VStack {
                Text("Add Special Dates")
                    .font(.largeTitle)
                    .padding()
                
                TextField("Event Title", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                DatePicker("Select Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    .padding()
                
                Button(action: {
                    if !title.isEmpty {
                        viewModel.addEvent(title: title, date: date)
                        title = ""
                        showConfetti = true // Trigger confetti on event add
                    }
                }) {
                    Text("Add Event")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                List(viewModel.events) { event in
                    Text("\(event.title) - \(event.date, style: .date)")
                }
            }
            
            ConfettiView(trigger: $showConfetti)
        }
    }
}
