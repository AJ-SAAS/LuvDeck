// HomeView.swift — FINAL MEMORY-SAFE VERSION (NO MORE CRASHES)
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    @EnvironmentObject var purchaseVM: PurchaseViewModel
    
    @GestureState private var dragOffset: CGFloat = 0
    @State private var animatingIndex: Int = 0

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
                        // THIS IS THE FIX — only 3 cards exist at once!
                        let visibleIndices = visibleCardIndices(current: viewModel.currentIndex, total: viewModel.ideas.count)
                        
                        ForEach(visibleIndices, id: \.self) { index in
                            let idea = viewModel.ideas[index]
                            IdeaCardView(idea: idea)
                                .frame(width: geometry.size.width, height: screenHeight)
                                .offset(y: offsetForIndex(index, current: viewModel.currentIndex, animating: animatingIndex, screenHeight: screenHeight))
                                .zIndex(zIndexForIndex(index, current: viewModel.currentIndex))
                                .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.8), value: animatingIndex)
                        }
                    }
                }
                .clipped()
                .contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in state = value.translation.height }
                        .onEnded { value in
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

            // Premium Teaser Banner
            PremiumTeaserBanner(isPresented: $viewModel.showTeaserBanner)
                .zIndex(100)
        }
        .onAppear {
            animatingIndex = viewModel.currentIndex
        }
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
