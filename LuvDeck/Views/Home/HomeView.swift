// HomeView.swift — FINAL MEMORY-SAFE VERSION (NO MORE CRASHES)
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    @EnvironmentObject var purchaseVM: PurchaseViewModel
    
    @GestureState private var dragOffset: CGFloat = 0
    @State private var animatingIndex: Int = 0
    @State private var isDragging = false
    
    // Tutorial pop-up control
    @State private var showSwipeTutorial = !UserDefaults.standard.bool(forKey: "hasSeenSwipeTutorial")
    @State private var countdown: Int = 5
    @State private var tutorialTimer: Timer? = nil

    private func rubberBandOffset(_ offset: CGFloat, screenHeight: CGFloat) -> CGFloat {
        offset > screenHeight || offset < -screenHeight ? offset * 0.3 : offset
    }

    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { geometry in
                let screenHeight = geometry.size.height

                ZStack {
                    if viewModel.isLoading {
                        ProgressView("Loading ideas...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .pink))
                    } else if viewModel.ideas.isEmpty {
                        Text("No ideas available")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    } else {
                        let visibleIndices = visibleCardIndices(current: viewModel.currentIndex, total: viewModel.ideas.count)
                        
                        ForEach(visibleIndices, id: \.self) { index in
                            let idea = viewModel.ideas[index]
                            IdeaCardView(
                                idea: idea,
                                isFirstCard: index == viewModel.currentIndex && viewModel.currentIndex == 0
                            )
                            .frame(width: geometry.size.width, height: screenHeight)
                            .offset(y: offsetForIndex(index, current: viewModel.currentIndex, animating: animatingIndex, screenHeight: screenHeight))
                            .zIndex(zIndexForIndex(index, current: viewModel.currentIndex))
                            .clipShape(RoundedRectangle(cornerRadius: isDragging ? 0 : 20, style: .continuous))
                            .shadow(color: isDragging ? .clear : .black.opacity(0.3), radius: isDragging ? 0 : 20, x: 0, y: 12)
                            .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.8), value: animatingIndex)
                        }
                    }
                }
                .clipped()
                .contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in state = value.translation.height }
                        .onChanged { value in
                            isDragging = true
                            if showSwipeTutorial && abs(value.translation.height) > 20 {
                                hideTutorial()
                            }
                        }
                        .onEnded { value in
                            isDragging = false
                            
                            let threshold: CGFloat = 100
                            let count = viewModel.ideas.count
                            var newIndex = viewModel.currentIndex

                            if value.translation.height < -threshold {
                                newIndex = (viewModel.currentIndex + 1) % count
                            } else if value.translation.height > threshold {
                                newIndex = (viewModel.currentIndex - 1 + count) % count
                            }

                            if newIndex != viewModel.currentIndex {
                                viewModel.didSwipe()
                            }

                            animatingIndex = newIndex
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                viewModel.currentIndex = newIndex
                            }
                        }
                )
            }

            // Top Logo
            HStack {
                Spacer()
                Image("luvdeckclean")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 48)
                Spacer()
            }
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.95))
            .shadow(color: .black.opacity(0.05), radius: 3, y: 1)
            .zIndex(2)

            // Clean, minimal swipe tutorial pop-up
            if showSwipeTutorial {
                ZStack {
                    Color.black.opacity(0.25)
                        .ignoresSafeArea()
                        .onTapGesture { hideTutorial() }

                    VStack(spacing: 32) {
                        // Animated up/down motion gesture
                        VStack(spacing: 20) {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 60, weight: .bold))
                                .foregroundColor(.pink)
                                .offset(y: countdown % 2 == 0 ? -15 : 15)
                                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: countdown)

                            Image(systemName: "arrow.down")
                                .font(.system(size: 60, weight: .bold))
                                .foregroundColor(.pink)
                                .offset(y: countdown % 2 == 0 ? 15 : -15)
                                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: countdown)
                        }

                        VStack(spacing: 12) {
                            Text("Swipe up or down")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)

                            Text("to discover new date ideas")
                                .font(.system(size: 20, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }

                        // Minimal countdown dots
                        HStack(spacing: 12) {
                            ForEach(1...5, id: \.self) { step in
                                Circle()
                                    .frame(width: 10, height: 10)
                                    .foregroundColor(countdown >= step ? .pink : .gray.opacity(0.3))
                            }
                        }

                        Button("Got it") {
                            hideTutorial()
                        }
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.black)
                        .cornerRadius(20)
                    }
                    .padding(40)
                    .frame(maxWidth: 340)
                    .background(Color(.systemBackground))
                    .cornerRadius(36)
                    .shadow(color: .black.opacity(0.15), radius: 24, x: 0, y: 12)
                    .scaleEffect(showSwipeTutorial ? 1.0 : 0.95)
                    .opacity(showSwipeTutorial ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5), value: showSwipeTutorial)
                }
                .onAppear {
                    startCountdown()
                }
                .onDisappear {
                    tutorialTimer?.invalidate()
                }
            }

            // Premium Teaser Banner
            PremiumTeaserBanner(isPresented: $viewModel.showTeaserBanner)
                .zIndex(100)
        }
        .onAppear {
            animatingIndex = viewModel.currentIndex
        }
    }

    private func startCountdown() {
        countdown = 5
        tutorialTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 1 {
                countdown -= 1
            } else {
                hideTutorial()
                timer.invalidate()
            }
        }
    }

    private func hideTutorial() {
        withAnimation(.easeInOut(duration: 0.5)) {
            showSwipeTutorial = false
        }
        UserDefaults.standard.set(true, forKey: "hasSeenSwipeTutorial")
        tutorialTimer?.invalidate()
    }

    // MARK: - Only show current, previous, and next card → 3 max alive
    private func visibleCardIndices(current: Int, total: Int) -> [Int] {
        guard total > 0 else { return [] }
        let prev = (current - 1 + total) % total
        let next = (current + 1) % total
        return [prev, current, next]
    }

    private func offsetForIndex(_ index: Int, current: Int, animating: Int, screenHeight: CGFloat) -> CGFloat {
        let baseOffset = CGFloat(index - animating) * screenHeight
        if index == current {
            return rubberBandOffset(dragOffset, screenHeight: screenHeight)
        }
        return baseOffset
    }

    private func zIndexForIndex(_ index: Int, current: Int) -> Double {
        index == current ? 10 : 0
    }
}
