import SwiftUI

struct SplashView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                    .ignoresSafeArea()
                Image("luvdecklogo") // Ensure "luvdecklogo" is in the asset catalog
                    .resizable()
                    .scaledToFit()
                    .frame(width: min(geometry.size.width * 0.6, 240), height: min(geometry.size.width * 0.6, 240)) // Increased size
            }
        }
    }
}

#Preview {
    SplashView()
}
