import SwiftUI

struct ConfettiView: View {
    @Binding var trigger: Bool

    var body: some View {
        ZStack {
            ForEach(0..<20, id: \.self) { i in
                Text("🎉")
                    .font(.system(size: CGFloat.random(in: 20...40)))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height / 2)
                    )
                    .opacity(trigger ? 1 : 0)
                    .animation(.easeOut(duration: 1), value: trigger)
            }
        }
        .onChange(of: trigger) { newValue in
            guard newValue else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                trigger = false
            }
        }
    }
}
