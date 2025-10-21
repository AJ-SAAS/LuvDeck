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
            ZStack {
                // MARK: - Background Image
                Group {
                    if let image = loadedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width,
                                   height: geometry.size.height + geometry.safeAreaInsets.bottom)
                            .clipped()
                    } else {
                        Image("defaultIdeaImage")
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width,
                                   height: geometry.size.height + geometry.safeAreaInsets.bottom)
                            .clipped()
                    }
                }
                .ignoresSafeArea(edges: .all)
                .onAppear {
                    let targetSize = CGSize(width: UIScreen.main.bounds.width * UIScreen.main.scale,
                                            height: UIScreen.main.bounds.height * UIScreen.main.scale)
                    loadImage(downsampleTo: targetSize)
                }

                // MARK: - Bottom Overlay (Raised higher)
                VStack {
                    Spacer() // pushes overlay higher

                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.65),
                                Color.black.opacity(0.3),
                                Color.clear
                            ]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                        .frame(height: 180)
                        .cornerRadius(30)
                        .blur(radius: 10)

                        VStack(alignment: .leading, spacing: 12) {
                            Text(idea.title)
                                .font(.system(size: 28, weight: .bold))
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.white)
                                .shadow(radius: 4)

                            Text(idea.description)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                                .shadow(radius: 3)
                                .padding(.trailing, 80)

                            HStack(spacing: 20) {
                                statView(title: "Difficulty", value: idea.difficultyStars, icon: "star.fill")
                                statView(title: "Category", value: idea.category, icon: "tag.fill")
                                statView(title: "Level", value: idea.level.rawValue, icon: "sparkles")
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 80) // ⬅️ raised above TabBar
                }
                .zIndex(1)

                // MARK: - Floating Heart Burst
                if showHeartBurst {
                    ForEach(0..<10, id: \.self) { index in
                        HeartParticleView()
                            .frame(width: 20, height: 20)
                            .position(
                                x: geometry.size.width - 50 + CGFloat.random(in: -30...30),
                                y: geometry.size.height * 0.65 + CGFloat.random(in: -40...40)
                            )
                            .opacity(Double.random(in: 0.6...1))
                    }
                }

                // MARK: - Right Side Buttons
                VStack(spacing: 22) {
                    Spacer()

                    // LIKE BUTTON
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                            animateLike = true
                            isLiked.toggle()
                            viewModel.likeIdea(idea)
                            if isLiked { showHeartBurst = true }
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            animateLike = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            showHeartBurst = false
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .font(.system(size: 32))
                                .foregroundColor(isLiked ? .red : .white)
                                .shadow(radius: 6)
                                .scaleEffect(animateLike ? 1.4 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.4), value: animateLike)

                            Text("Like")
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                        }
                    }

                    // SHARE BUTTON
                    Button {
                        viewModel.shareIdea(idea)
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "arrowshape.turn.up.right.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                                .shadow(radius: 6)
                            Text("Share")
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                        }
                    }

                    Spacer().frame(height: 300)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 20)
                .zIndex(3)
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }

    // MARK: - Lazy Image Loader
    private func loadImage(downsampleTo targetPixelSize: CGSize) {
        if loadedImage != nil { return }

        DispatchQueue.global(qos: .userInitiated).async {
            autoreleasepool {
                if let fullImage = UIImage(named: idea.imageName) {
                    let scale = UIScreen.main.scale
                    let targetW = max(1, Int(targetPixelSize.width))
                    let targetH = max(1, Int(targetPixelSize.height))
                    let targetSize = CGSize(width: targetW, height: targetH)

                    let renderer = UIGraphicsImageRenderer(size: CGSize(width: targetSize.width / scale,
                                                                        height: targetSize.height / scale))
                    let downsampled = renderer.image { _ in
                        fullImage.draw(in: CGRect(origin: .zero, size: CGSize(width: targetSize.width / scale,
                                                                              height: targetSize.height / scale)))
                    }

                    DispatchQueue.main.async {
                        withAnimation { self.loadedImage = downsampled }
                    }
                } else {
                    DispatchQueue.main.async { self.loadedImage = nil }
                }
            }
        }
    }

    // MARK: - Stat View
    private func statView(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(.pink)
                .font(.system(size: 14))
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.pink)
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Floating Heart Particle
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
