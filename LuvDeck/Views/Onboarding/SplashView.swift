import SwiftUI

struct SplashView: View {
    var body: some View {
        GeometryReader { geometry in
            Image("Splashscreen")
                .resizable()
                .ignoresSafeArea()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .aspectRatio(nil, contentMode: .fill) // Ignore aspect ratio, stretch to fill
        }
    }
}

#Preview {
    SplashView()
}
