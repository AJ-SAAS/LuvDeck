import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            Image("AppIcon") // Ensure "AppIcon" is the name of your app icon in the asset catalog
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100) // Adjust size as needed
        }
    }
}

#Preview {
    SplashView()
}
