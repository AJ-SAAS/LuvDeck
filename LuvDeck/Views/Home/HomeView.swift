import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    @GestureState private var dragOffset: CGFloat = 0
    @State private var animatingIndex: Int = 0

    private func rubberBandOffset(_ offset: CGFloat, screenHeight: CGFloat) -> CGFloat {
        let resistance: CGFloat = 0.3
        return offset > screenHeight || offset < -screenHeight ? offset * resistance : offset
    }

    var body: some View {
        ZStack(alignment: .top) {

            // MARK: - Scrollable Idea Cards
            GeometryReader { geometry in
                let screenHeight = geometry.size.height

                ZStack {
                    if viewModel.isLoading {
                        ProgressView("Loading ideas...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .pink))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if viewModel.ideas.isEmpty {
                        Text("No ideas available")
                            .font(.title)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ZStack {
                            ForEach(Array(viewModel.ideas.enumerated()), id: \.element.id) { index, idea in
                                IdeaCardView(idea: idea)
                                    .frame(width: geometry.size.width, height: screenHeight)
                                    .offset(
                                        y: CGFloat(index - animatingIndex) * screenHeight
                                            + rubberBandOffset(dragOffset, screenHeight: screenHeight)
                                    )
                                    .animation(.interactiveSpring(response: 0.4, dampingFraction: 0.8),
                                               value: animatingIndex)
                            }
                        }
                        .clipped()
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .updating($dragOffset) { value, state, _ in
                                    state = value.translation.height
                                }
                                .onEnded { value in
                                    let threshold: CGFloat = 100
                                    let count = viewModel.ideas.count
                                    var newIndex = viewModel.currentIndex

                                    if value.translation.height < -threshold {
                                        newIndex = (viewModel.currentIndex + 1) % count
                                    } else if value.translation.height > threshold {
                                        newIndex = (viewModel.currentIndex - 1 + count) % count
                                    }

                                    animatingIndex = newIndex
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                        viewModel.currentIndex = newIndex
                                    }
                                }
                        )
                    }
                }
                .edgesIgnoringSafeArea(.top) // Image covers the top safe area
            }

            // MARK: - Top Logo Bar
            HStack {
                Spacer()
                Image("luvdecksmall")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 48)
                    .padding(.vertical, 6)
                Spacer()
            }
            .background(Color.white.opacity(0.95)) // slight transparency so top of image can peek
            .shadow(color: .black.opacity(0.05), radius: 3, y: 1)
            .zIndex(2)
        }
        .onAppear {
            animatingIndex = viewModel.currentIndex
        }
    }
}
