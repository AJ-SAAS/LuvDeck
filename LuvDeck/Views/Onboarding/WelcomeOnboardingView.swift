import SwiftUI

// MARK: - Page Model
struct LuvDeckOnboardingPage {
    let headline: String
    let body: String
    let illustration: String
    let quote: String?
    let trustLine: String?
    let trustAvatar: String?
    let isFinal: String?
}

struct WelcomeOnboardingView: View {
    
    @State private var currentPage = 0
    @State private var animateIn = false
    
    private let pages: [LuvDeckOnboardingPage] = [
        
        // SCREEN 1
        LuvDeckOnboardingPage(
            headline: "Relationships don’t fail overnight",
            body: """
They drift into routines, same conversations, same “what do you want to do?” every night. Until something feels off.
""",
            illustration: "clock.badge.exclamationmark",
            quote: nil,
            trustLine: "We didn’t realise how disconnected we had become",
            trustAvatar: "couple1",
            isFinal: nil
        ),
        
        // SCREEN 2
        LuvDeckOnboardingPage(
            headline: "Some couples never lose that spark",
            body: """
They laugh more, talk deeper, and still get butterflies when they see each other. People notice it. It’s not luck.
""",
            illustration: "sparkles",
            quote: nil,
            trustLine: "It feels like we’re dating again, even after years together",
            trustAvatar: "couple2",
            isFinal: nil
        ),
        
        // SCREEN 3
        LuvDeckOnboardingPage(
            headline: "One tap a day is all it takes.",
            body: """
A date idea you’ll actually do. A question that sparks something real. A small moment that brings you closer. No planning. No pressure.
""",
            illustration: "calendar.badge.clock",
            quote: nil,
            trustLine: "It’s shockingly easy. We actually stick to it",
            trustAvatar: "couple3",
            isFinal: nil
        ),
        
        // SCREEN 4
        LuvDeckOnboardingPage(
            headline: "Built for real relationships",
            body: """
Whether you’ve been together 3 months or 13 years, the spark is worth protecting. Start in seconds. No pressure.
""",
            illustration: "heart.fill",
            quote: nil,
            trustLine: "Perfect for busy couples who still want connection",
            trustAvatar: "couple4",
            isFinal: "Start Connecting ❤️"
        )
    ]
    
    var onContinue: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // Progress
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Capsule()
                                .fill(index == currentPage ? Color.black : Color.black.opacity(0.2))
                                .frame(width: index == currentPage ? 32 : 8, height: 6)
                        }
                    }
                    .padding(.top, 20)
                    
                    TabView(selection: $currentPage) {
                        ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                            pageContent(page: page, index: index, geo: geo)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.4), value: currentPage)
                    
                    VStack(spacing: 20) {
                        
                        Button {
                            if currentPage < pages.count - 1 {
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    currentPage += 1
                                }
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            } else {
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                                onContinue()
                            }
                        } label: {
                            Text(buttonTitle(for: currentPage))
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 58)
                                .background(
                                    LinearGradient(
                                        colors: [Color.pink, Color.red],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 32)
                        
                        // TESTIMONIAL WITH SHIMMER - Now works on all screens
                        if let trustLine = pages[currentPage].trustLine,
                           let trustAvatar = pages[currentPage].trustAvatar {
                            
                            HStack(spacing: 12) {
                                ShimmerImage(imageName: trustAvatar, pageIndex: currentPage)
                                
                                Text("\"\(trustLine)\"")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.black.opacity(0.7))
                                    .italic()
                            }
                            .padding(.horizontal, 32)
                        }
                    }
                    .padding(.bottom, geo.safeAreaInsets.bottom + 30)
                }
            }
        }
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 30)
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) {
                animateIn = true
            }
        }
    }
    
    // MARK: - Buttons
    private func buttonTitle(for index: Int) -> String {
        switch index {
        case 0: return "That’s true"
        case 1: return "I want this"
        case 2: return "Show me how"
        case 3: return "Start connecting"
        default: return "Continue"
        }
    }
    
    // MARK: - Styled Text Engine (Updated per your latest requests)
    private func styledText(_ text: String, screen: Int) -> AttributedString {
        var attributed = AttributedString(text)
        
        switch screen {
            
        case 0:  // Screen 1
            if let r = attributed.range(of: "what do you want to do?") {
                attributed[r].font = .system(size: 17, weight: .bold)
                attributed[r].foregroundColor = .pink
            }
            
        case 1:  // Screen 2
            ["laugh more", "talk deeper"].forEach {
                if let r = attributed.range(of: $0) {
                    attributed[r].font = .system(size: 17, weight: .bold)
                    attributed[r].foregroundColor = .black
                }
            }
            if let r = attributed.range(of: "still get butterflies") {
                attributed[r].font = .system(size: 17, weight: .bold)
                attributed[r].foregroundColor = .pink
            }
            
        case 2:  // Screen 3
            if let r = attributed.range(of: "sparks something real") {
                attributed[r].font = .system(size: 17, weight: .bold)
                attributed[r].foregroundColor = .black
            }
            if let r = attributed.range(of: "A small moment that brings you closer") {
                attributed[r].font = .system(size: 17, weight: .bold)
                attributed[r].foregroundColor = .pink
            }
            
        case 3:  // Screen 4
            if let r = attributed.range(of: "3 months or 13 years") {
                attributed[r].font = .system(size: 17, weight: .bold)
                attributed[r].foregroundColor = .pink
            }
            if let r = attributed.range(of: "Start in seconds") {
                attributed[r].font = .system(size: 17, weight: .bold)
                attributed[r].foregroundColor = .black
            }
            
        default:
            break
        }
        
        return attributed
    }
    
    @ViewBuilder
    private func pageContent(page: LuvDeckOnboardingPage, index: Int, geo: GeometryProxy) -> some View {
        
        let imageSize = min(geo.size.width * 0.36, 180)
        
        VStack(spacing: 20) {
            Spacer(minLength: 30)
            
            VStack(spacing: 14) {
                
                Text(page.headline)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                
                Text(styledText(page.body, screen: index))
                    .font(.system(size: 17))
                    .foregroundColor(.black.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .lineSpacing(4)
            }
            
            Spacer()
            
            Image(systemName: page.illustration)
                .resizable()
                .scaledToFit()
                .frame(width: imageSize, height: imageSize)
                .foregroundColor(.pink.opacity(0.9))
            
            Spacer(minLength: 60)
        }
        .opacity(currentPage == index ? 1 : 0)
        .animation(.easeInOut(duration: 0.3), value: currentPage)
    }
}

// MARK: - SHIMMER IMAGE (Fixed - now works on all screens, slower & smoother)
struct ShimmerImage: View {
    
    let imageName: String
    let pageIndex: Int      // Used to restart shimmer when page changes
    
    @State private var animate = false
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(width: 48, height: 48)
            .clipShape(Circle())
            .overlay(
                LinearGradient(
                    colors: [.clear, .white.opacity(0.85), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(35))
                .offset(x: animate ? 130 : -130)
            )
            .clipped()
            .onAppear {
                startShimmer()
            }
            .onChange(of: pageIndex) { _ in
                // Restart shimmer cleanly when swiping to a new page
                animate = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    startShimmer()
                }
            }
    }
    
    private func startShimmer() {
        withAnimation(.linear(duration: 2.8).repeatForever(autoreverses: false)) {
            animate = true
        }
    }
}
