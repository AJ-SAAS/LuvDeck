import SwiftUI

struct CongratulationsView: View {
    // This closure is called when the user taps “Get Started”
    var onGetStarted: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Image("luvdecklogo")
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160) // ↑ increased size

            Text("Congratulations!")
                .font(.largeTitle).bold()

            Text("You're on your way to unforgettable romantic dates.")
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                onGetStarted()               // <-- go to Auth
            } label: {
                Text("Get Started")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
}
