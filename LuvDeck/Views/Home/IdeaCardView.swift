import SwiftUI

struct IdeaCardView: View {
    let idea: Idea
    let isFirstCard: Bool  // Still here for future use if needed
    
    @EnvironmentObject var viewModel: HomeViewModel
    @EnvironmentObject var purchaseVM: PurchaseViewModel
    @EnvironmentObject var savedVM: SavedIdeasViewModel

    @State private var isLiked = false
    @State private var animateLike = false
    @State private var showHeartBurst = false
    @State private var isSaved = false
    @State private var showPaywall = false
    @State private var overlayPulse = false
    
    @State private var microAnimationOffset: CGFloat = 0  // Keep micro slide on first card

    // MARK: - Premium Only (Epic + Legendary)
    private var isPremiumPaywalled: Bool {
        (idea.level == .legendary || idea.level == .epic) && !purchaseVM.isSubscribed
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                Image(idea.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .brightness(isPremiumPaywalled ? -0.12 : 0)
                    .blur(radius: isPremiumPaywalled ? 3 : 0)
                    .offset(y: -geometry.safeAreaInsets.top * 0.3 + microAnimationOffset)

                if !isPremiumPaywalled {
                    bottomOverlay(geometry: geometry)
                    rightSideButtons(geometry: geometry)
                    heartBurst(geometry: geometry)
                }

                if isPremiumPaywalled {
                    premiumOverlay
                        .scaleEffect(overlayPulse ? 1.02 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true),
                            value: overlayPulse
                        )
                        .onAppear { overlayPulse = true }
                        .onTapGesture { showPaywall = true }
                        .sheet(isPresented: $showPaywall) {
                            PaywallView(isPresented: $showPaywall, purchaseVM: purchaseVM)
                        }
                }

                // NO inline swipe hint anymore — only the pop-up in HomeView handles guidance
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 12)
            .ignoresSafeArea(edges: .all)
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear { isSaved = savedVM.isSaved(idea) }
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

    // MARK: - Level Badge (Epic + Legendary Premium)
    private func levelBadge(geometry: GeometryProxy) -> some View {
        let bgColor: Color
        switch idea.level {
        case .cute: bgColor = .pink
        case .spicy: bgColor = .orange
        case .epic: bgColor = .purple
        case .legendary: bgColor = .yellow
        }

        return HStack(spacing: 4) {
            if idea.level == .epic || idea.level == .legendary {
                Image(systemName: "crown.fill")
                    .font(.system(size: geometry.size.height * 0.018))
                    .foregroundColor(.white)
                    .shadow(color: .white.opacity(0.6), radius: 2)
            }

            Text(idea.level.rawValue.capitalized)
                .font(.system(size: geometry.size.height * 0.020, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(
            Capsule(style: .continuous)
                .fill(bgColor.opacity((idea.level == .epic || idea.level == .legendary) ? 0.95 : 0.85))
                .shadow(color: (idea.level == .epic || idea.level == .legendary) ? .white.opacity(0.2) : .clear, radius: 4)
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        )
    }

    // MARK: - Premium Overlay (Pulse)
    private var premiumOverlay: some View {
        ZStack {
            Color.black.opacity(0.45)
            VStack(spacing: 20) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.yellow)
                    .shadow(color: .black.opacity(0.3), radius: 8)
                Text(idea.level.rawValue.uppercased())
                    .font(.system(size: 34, weight: .black, design: .serif))
                    .foregroundColor(.white.opacity(0.95))
                Text("Premium Only")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white.opacity(0.85))
                Text("Tap to unlock this masterpiece")
                    .font(.system(size: 16))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 50)
                    .foregroundColor(.white.opacity(0.78))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(radius: 12)
    }

    // MARK: - Right Side Buttons
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
                    Text("Like")
                        .font(.system(size: geometry.size.height * 0.018))
                        .foregroundColor(.white)
                }
            }

            // Save / Bookmark Button
            Button {
                isSaved.toggle()
                if isSaved {
                    savedVM.save(idea)
                } else {
                    savedVM.remove(idea)
                }
            } label: {
                VStack(spacing: 6) {
                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                        .font(.system(size: geometry.size.height * 0.045))
                        .foregroundColor(.white)
                        .shadow(radius: 6)
                    Text("Save")
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

    // MARK: - Heart Burst
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

// MARK: - HeartParticleView
struct HeartParticleView: View {
    var body: some View {
        Image(systemName: "heart.fill")
            .foregroundColor(.red)
            .scaleEffect(Double.random(in: 0.5...1.0))
            .opacity(Double.random(in: 0.3...0.9))
    }
}
