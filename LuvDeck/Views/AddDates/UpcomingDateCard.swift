import SwiftUI

struct UpcomingDateCard: View {
    let event: DateEvent

    var body: some View {
        ZStack {
            Image("defaultIdeaImage")
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipped()
                .cornerRadius(20)

            LinearGradient(
                gradient: Gradient(colors: [.black.opacity(0.7), .clear]),
                startPoint: .bottom,
                endPoint: .top
            )
            .cornerRadius(20)

            VStack(alignment: .leading, spacing: 6) {
                Text(event.personName)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                Text("\(event.date, style: .date) at \(event.date, style: .time)")
                    .foregroundColor(.white.opacity(0.9))
                Text(event.eventType.rawValue)
                    .foregroundColor(.pink)
                    .bold()
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .shadow(radius: 5)
    }
}
