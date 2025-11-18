// IdeaCardView.swift – TIKTOK SMOOTH • ZERO FLASH • PERFECT SCROLL
// November 18, 2025 – 100% Clean Build

import SwiftUI

struct IdeaCardView: View {
    let idea: Idea
    @EnvironmentObject var viewModel: HomeViewModel
    @EnvironmentObject var purchaseVM: PurchaseViewModel

    @State private var isLiked = false
    @State private var animateLike = false
    @State private var showHeartBurst = false

    private var isLegendaryPaywalled: Bool {
        idea.level == .legendary && !purchaseVM.isPremium
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                CachedDownsampledImage(imageName: idea.imageName, size: geometry.size)
                    .brightness(isLegendaryPaywalled ? -0.12 : 0)
                    .offset(y: -geometry.safeAreaInsets.top * 0.3)

                if !isLegendaryPaywalled {
                    bottomOverlay(geometry: geometry)
                    rightSideButtons(geometry: geometry)
                    heartBurst(geometry: geometry)
                }

                if isLegendaryPaywalled {
                    legendaryOverlay
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 12)
            .ignoresSafeArea(edges: .all)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Bottom Overlay
    @ViewBuilder
    private func bottomOverlay(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.015) {
            Text(idea.title)
                .font(.system(size: geometry.size.height * 0.04, weight: .bold))
                .foregroundColor(.white)
                .shadow(radius: 4)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .layoutPriority(3)

            Text(idea.description)
                .font(.system(size: min(geometry.size.height * 0.019, 17), weight: .medium))
                .foregroundColor(.white.opacity(0.95))
                .multilineTextAlignment(.leading)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            levelBadge(geometry: geometry)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, geometry.size.width * 0.05)
        .padding(.bottom, geometry.safeAreaInsets.bottom + geometry.size.height * 0.135)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.black.opacity(0.78), .black.opacity(0.35), .clear]),
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: geometry.size.height * 0.55)
            .blur(radius: 14)
            .allowsHitTesting(false)
        )
        .zIndex(2)
    }

    private func levelBadge(geometry: GeometryProxy) -> some View {
        let bgColor: Color = switch idea.level {
        case .cute:      .pink
        case .spicy: .orange
        case .epic:  .purple
        case .legendary: .yellow
        }

        return Text(idea.level.rawValue.capitalized)
            .font(.system(size: geometry.size.height * 0.020, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(
                Capsule(style: .continuous)
                    .fill(bgColor.opacity(0.85))
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
    }

    private var legendaryOverlay: some View {
        ZStack {
            Color.white.opacity(0.82).blur(radius: 6)
            VStack(spacing: 20) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.yellow)
                    .shadow(color: .black.opacity(0.3), radius: 8)
                Text("LEGENDARY")
                    .font(.system(size: 34, weight: .black, design: .serif))
                    .foregroundColor(.black.opacity(0.95))
                Text("Premium Only")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black.opacity(0.85))
                Text("Tap to unlock this masterpiece")
                    .font(.system(size: 16))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 50)
                    .foregroundColor(.black.opacity(0.78))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { purchaseVM.shouldPresentPaywall = true }
    }

    @ViewBuilder
    private func rightSideButtons(geometry: GeometryProxy) -> some View {
        VStack(spacing: geometry.size.height * 0.035) {
            Spacer()

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
                    Text("Like")
                        .font(.system(size: geometry.size.height * 0.018))
                        .foregroundColor(.white)
                }
            }

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
}

// MARK: - Ultra-Fast Cached Image (TikTok/Instagram tech)
struct CachedDownsampledImage: View {
    let imageName: String
    let size: CGSize
    
    @StateObject private var loader = ImageLoader()
    
    var body: some View {
        ZStack {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color(white: 0.15) // instant placeholder — no flash ever
            }
        }
        .frame(width: size.width, height: size.height)
        .clipped()
        .onAppear {
            loader.load(imageName: imageName, targetSize: size)
        }
        .onChange(of: size) { newSize in
            loader.load(imageName: imageName, targetSize: newSize)
        }
    }
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    
    private static let cache = NSCache<NSString, UIImage>()
    
    func load(imageName: String, targetSize: CGSize) {
        let key = NSString(string: "\(imageName)_\(Int(targetSize.width))x\(Int(targetSize.height))")
        
        if let cached = Self.cache.object(forKey: key) {
            self.image = cached
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let original = UIImage(named: imageName) ?? UIImage(named: "defaultIdeaImage") else { return }
            
            let renderer = UIGraphicsImageRenderer(size: targetSize)
            let downsampled = renderer.image { _ in
                original.draw(in: CGRect(origin: .zero, size: targetSize))
            }
            
            Self.cache.setObject(downsampled, forKey: key)
            
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.2)) {
                    self?.image = downsampled
                }
            }
        }
    }
}

// MARK: - Heart Particle
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
