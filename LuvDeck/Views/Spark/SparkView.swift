import SwiftUI

struct SparkView: View {
    @StateObject private var vm = SparkViewModel()
    @State private var showHowItWorks = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // MARK: - Hero Tagline
                    VStack(spacing: 12) {
                        Text("One tap. More love today.")
                            .font(.title2.bold())
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Text("Daily sparks to keep the flame alive — conversation, intimacy, play, and tiny acts of love.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)

                    // MARK: - 4 Spark Cards (2×2 Grid)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        sparkCard(
                            title: "Conversation\nStarters",
                            icon: "message.fill",
                            color: Color.pink.opacity(0.85),
                            action: { vm.showRandom(.conversation) }
                        )

                        sparkCard(
                            title: "Know Your\nPartner",
                            icon: "heart.text.square.fill",
                            color: Color.purple.opacity(0.85),
                            action: { vm.showRandom(.deepQuestion) }
                        )

                        sparkCard(
                            title: "Romance\nChallenge",
                            icon: "flame.fill",
                            color: Color.red.opacity(0.9),
                            action: { vm.showRandom(.challenge) }
                        )

                        sparkCard(
                            title: "Mini Love\nAction",
                            icon: "bolt.heart.fill",
                            color: Color.orange.opacity(0.9),
                            action: { vm.showRandom(.miniAction) }
                        )
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 100)
                }
                .padding(.horizontal)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                // MARK: - PERFECTLY CENTERED LOGO
                ToolbarItem(placement: .principal) {
                    HStack {
                        Spacer()
                        Image("luvdecksmall")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140, height: 48)
                            .padding(.vertical, 6)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            // MARK: - Spark Detail Sheet
            .sheet(isPresented: $vm.showingSheet) {
                SparkDetailView(item: vm.selectedItem)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }

            // MARK: - Floating "How Spark Works" Card
            .overlay(alignment: .bottom) {
                howItWorksCard
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .animation(.spring(response: 0.4), value: showHowItWorks)
            }
        }
    }

    // MARK: - Reusable Spark Card
    private func sparkCard(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 44))
                    .foregroundStyle(.white)

                Text(title)
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .frame(height: 160)
            .frame(maxWidth: .infinity)
            .background(color.gradient)
            .cornerRadius(20)
            .shadow(color: color.opacity(0.4), radius: 12, y: 8)
        }
        .buttonStyle(SparkButtonStyle())
    }

    // MARK: - How Spark Works Card
    private var howItWorksCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation { showHowItWorks.toggle() }
            } label: {
                HStack {
                    Text("How Spark Works")
                        .font(.headline)
                        .foregroundStyle(.pink)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Image(systemName: showHowItWorks ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, -8)
            }

            if showHowItWorks {
                VStack(alignment: .leading, spacing: 12) {
                    bulletPoint("One tap → instant spark of connection")
                    bulletPoint("4 categories: talk, feel, act, play")
                    bulletPoint("New ideas every day — never repeats too soon")
                    bulletPoint("Built for daily use: 10 seconds = more love")
                    bulletPoint("Science-backed: small actions create big bonds")
                }
                .font(.subheadline)
                .foregroundStyle(.black)
                .multilineTextAlignment(.leading)
                .transition(.opacity.combined(with: .scale))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        )
    }

    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(.pink)
                .frame(width: 6, height: 6)
                .offset(y: 8)
            Text(text)
            Spacer()
        }
    }
}

// MARK: - Button Style
struct SparkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}
