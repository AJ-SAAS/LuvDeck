import SwiftUI

struct ReviewPopupView: View {
    var event: DateEvent
    var onSubmit: (_ rating: Int, _ notes: String?) -> Void

    @State private var rating: Int = 0
    @State private var notes: String = ""

    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()

            VStack(spacing: 20) {
                Text("How did it go?")
                    .font(.title2.bold())
                Text(event.personName)
                    .font(.headline)
                HStack(spacing: 10) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= rating ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .font(.title)
                            .onTapGesture { rating = star }
                    }
                }

                TextField("Leave a note (optional)", text: $notes)
                    .textFieldStyle(.roundedBorder)

                Button(action: {
                    onSubmit(rating, notes.isEmpty ? nil : notes)
                }) {
                    Text("Submit")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .padding(32)
            .shadow(radius: 10)
        }
    }
}
