import SwiftUI
import UIKit

struct IdeaCardView: View {
    let idea: Idea
    @EnvironmentObject var viewModel: HomeViewModel

    @State private var loadedImage: UIImage? = nil
    @State private var isLiked: Bool = false
    @State private var animateLike: Bool = false
    @State private var showHeartBurst: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {

                // MARK: - Background Image (fills full screen)
                backgroundImage(geometry: geometry)

                // MARK: - Bottom Gradient & Text Overlay
                bottomOverlay(geometry: geometry)

                // MARK: - Right Side Floating Buttons
                rightSideButtons(geometry: geometry)

                // MARK: - Heart Burst Animation
                heartBurst(geometry: geometry)
            }
            .ignoresSafeArea(edges: .all)
        }
    }

    // MARK: - Background Image
    @ViewBuilder
    private func backgroundImage(geometry: GeometryProxy) -> some View {
        let screenWidth = geometry.size.width
        // Extend height slightly to eliminate bottom gap
        let screenHeight = geometry.size.height + geometry.safeAreaInsets.bottom

        ZStack {
            Color.black.opacity(0.1)

            Image(uiImage: loadedImage ?? UIImage(named: "defaultIdeaImage") ?? UIImage())
                .resizable()
                .scaledToFill()
                .frame(width: screenWidth, height: screenHeight)
                .clipped()
                .offset(y: -geometry.safeAreaInsets.top * 0.3) // closes top gap under logo
        }
        .onAppear { loadImageForSize(geometry: geometry) }
        .ignoresSafeArea(edges: .all)
    }

    private func loadImageForSize(geometry: GeometryProxy) {
        let targetSize = CGSize(
            width: geometry.size.width * UIScreen.main.scale,
            height: geometry.size.height * UIScreen.main.scale
        )
        loadImage(downsampleTo: targetSize)
    }

    // MARK: - Bottom Gradient & Text Overlay
    @ViewBuilder
    private func bottomOverlay(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.02) {

            // Title
            Text(idea.title)
                .font(.system(size: geometry.size.height * 0.04, weight: .bold))
                .foregroundColor(.white)
                .shadow(radius: 4)
                .multilineTextAlignment(.leading)

            // Description
            Text(idea.description)
                .font(.system(size: geometry.size.height * 0.022))
                .foregroundColor(.white.opacity(0.95))
                .multilineTextAlignment(.leading)
                .lineLimit(3)

            // 3 Stats in One Row
            HStack(spacing: geometry.size.width * 0.05) {
                statView(title: "Difficulty", value: idea.difficultyStars, icon: "star.fill")
                statView(title: "Category", value: idea.category, icon: "tag.fill")
                statView(title: "Level", value: idea.level.rawValue, icon: "sparkles")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, geometry.size.width * 0.05)
        .padding(.bottom, geometry.safeAreaInsets.bottom + geometry.size.height * 0.07) // adjusted for comfort above tab bar
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    .black.opacity(0.65),
                    .black.opacity(0.25),
                    .clear
                ]),
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: geometry.size.height * 0.38)
            .blur(radius: 10)
            .allowsHitTesting(false)
        )
        .zIndex(2)
    }

    // MARK: - Right Side Floating Buttons
    @ViewBuilder
    private func rightSideButtons(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.035) {
            Spacer()

            // Like Button
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                    animateLike = true
                    isLiked.toggle()
                    viewModel.likeIdea(idea)
                    if isLiked { showHeartBurst = true }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { animateLike = false }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { showHeartBurst = false }
            } label: {
                VStack(spacing: 6) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.system(size: geometry.size.height * 0.045))
                        .foregroundColor(isLiked ? .red : .white)
                        .shadow(radius: 6)
                        .scaleEffect(animateLike ? 1.4 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.4), value: animateLike)
                    Text("Like")
                        .font(.system(size: geometry.size.height * 0.018))
                        .foregroundColor(.white)
                }
            }

            // Share Button
            Button {
                viewModel.shareIdea(idea)
            } label: {
                VStack(spacing: 6) {
                    Image(systemName: "arrowshape.turn.up.right.fill")
                        .font(.system(size: geometry.size.height * 0.045))
                        .foregroundColor(.white)
                        .shadow(radius: 6)
                    Text("Share")
                        .font(.system(size: geometry.size.height * 0.018))
                        .foregroundColor(.white)
                }
            }

            Spacer().frame(height: geometry.size.height * 0.35)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.trailing, geometry.size.width * 0.06)
        .zIndex(3)
    }

    // MARK: - Heart Burst Animation
    @ViewBuilder
    private func heartBurst(geometry: GeometryProxy) -> some View {
        if showHeartBurst {
            ForEach(0..<10, id: \.self) { _ in
                HeartParticleView()
                    .frame(width: 20, height: 20)
                    .position(
                        x: geometry.size.width - 60 + CGFloat.random(in: -40...40),
                        y: geometry.size.height * 0.65 + CGFloat.random(in: -50...50)
                    )
                    .opacity(Double.random(in: 0.6...1))
            }
        }
    }

    // MARK: - Lazy Image Loader
    private func loadImage(downsampleTo targetPixelSize: CGSize) {
        if loadedImage != nil { return }
        DispatchQueue.global(qos: .userInitiated).async {
            autoreleasepool {
                if let fullImage = UIImage(named: idea.imageName) {
                    let scale = UIScreen.main.scale
                    let targetSize = CGSize(width: max(1, targetPixelSize.width / scale),
                                            height: max(1, targetPixelSize.height / scale))
                    let renderer = UIGraphicsImageRenderer(size: targetSize)
                    let downsampled = renderer.image { _ in
                        fullImage.draw(in: CGRect(origin: .zero, size: targetSize))
                    }
                    DispatchQueue.main.async {
                        withAnimation { self.loadedImage = downsampled }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.loadedImage = UIImage(named: "defaultIdeaImage") ?? UIImage()
                    }
                }
            }
        }
    }

    // MARK: - Stat View
    private func statView(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(.pink)
                .font(.system(size: 14))
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.pink)
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Heart Particle Animation
struct HeartParticleView: View {
    @State private var randomX: CGFloat = CGFloat.random(in: -20...20)
    @State private var randomY: CGFloat = CGFloat.random(in: -150 ... -50)
    @State private var opacity: Double = 1
    @State private var scale: CGFloat = 1

    var body: some View {
        Image(systemName: "heart.fill")
            .foregroundColor(.red)
            .opacity(opacity)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) {
                    opacity = 0
                    scale = 1.4
                }
            }
            .offset(x: randomX, y: randomY)
    }
}
