import SwiftUI

struct CongratulationsView: View {
    // This closure is called when the user taps “Get Started”
    var onGetStarted: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Image("newlogosmile")
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))

            Text("Congratulations!")
                .font(.largeTitle.bold())

            Text("You're on your way to unforgettable romantic dates.")
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                onGetStarted()
            } label: {
                Text("Get Started")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)  // ← Now red — visible in dark mode!
                    .foregroundStyle(.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.2), radius: 8, y: 4)  // Subtle lift
            }
            .padding(.horizontal, 40)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).ignoresSafeArea())  // Keeps system dark mode support
    }
}
