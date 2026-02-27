import SwiftUI

struct SparkView: View {

    @ObservedObject var vm: SparkViewModel
    @ObservedObject var purchaseVM: PurchaseViewModel

    @State private var showHowItWorks = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // HERO SECTION
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

                    // SPARK GRID (4 cards — tap shows a random prompt sheet)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        sparkCard(
                            title: "Conversation\nStarters",
                            icon: "message.fill",
                            color: Color.pink.opacity(0.85),
                            category: .conversation
                        )
                        sparkCard(
                            title: "Know Your\nPartner",
                            icon: "heart.text.square.fill",
                            color: Color.purple.opacity(0.85),
                            category: .deepQuestion
                        )
                        sparkCard(
                            title: "Romance\nChallenge",
                            icon: "flame.fill",
                            color: Color.red.opacity(0.9),
                            category: .challenge
                        )
                        sparkCard(
                            title: "Mini Love\nAction",
                            icon: "bolt.heart.fill",
                            color: Color.orange.opacity(0.9),
                            category: .miniAction
                        )
                    }
                    .padding(.horizontal)

                    // MOMENTUM CARD (full width, opens full-page sheet)
                    momentumCard
                        .padding(.horizontal)

                    Spacer(minLength: 100)
                }
                .padding(.horizontal)
            }

            // NAV BAR
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Color.clear.frame(width: 24, height: 24)
                }
                ToolbarItem(placement: .principal) {
                    Image("luvdeckclean")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140, height: 48)
                        .padding(.vertical, 6)
                }
            }

            // SPARK DETAIL SHEET (random prompt cards)
            .sheet(isPresented: $vm.showingSheet) {
                if let item = vm.selectedItem {
                    SparkDetailView(spark: Spark(id: UUID(), title: item.text, completed: false))
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                }
            }

            // MOMENTUM FULL-PAGE SHEET
            .sheet(isPresented: $vm.showMomentumSheet) {
                SparkMomentumView(vm: vm, purchaseVM: purchaseVM)
            }

            // PAYWALL SHEET
            .sheet(isPresented: $vm.showPaywall) {
                PaywallView(isPresented: $vm.showPaywall, purchaseVM: purchaseVM)
            }

            // Sync premium from purchaseVM → vm
            .onChange(of: purchaseVM.isSubscribed) { _, newValue in
                vm.isPremium = newValue
            }

            // HOW IT WORKS overlay
            .overlay(alignment: .bottom) {
                howItWorksCard
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .animation(.spring(response: 0.4), value: showHowItWorks)
            }
            .onDisappear {
                showHowItWorks = false
            }
        }
    }

    // MARK: - Spark Card
    private func sparkCard(title: String, icon: String, color: Color, category: SparkCategory) -> some View {
        Button {
            // Pick a random item from this category and show the sheet
            if let item = sparkDatabase.filter({ $0.category == category }).randomElement() {
                if vm.isPremium || category == .conversation {
                    vm.selectedItem = item
                    vm.showingSheet = true
                } else {
                    vm.showPaywall = true
                }
            }
        } label: {
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

    // MARK: - Momentum Card
    private var momentumCard: some View {
        Button {
            vm.showMomentumSheet = true
        } label: {
            ZStack(alignment: .topTrailing) {
                HStack(spacing: 20) {
                    Image(systemName: "bolt.heart.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.white)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Momentum")
                            .font(.title2.bold())
                            .foregroundStyle(.white)

                        Text("50 romance challenges to build your love")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.85))
                            .multilineTextAlignment(.leading)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 28)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.6, green: 0.1, blue: 0.9), Color(red: 0.9, green: 0.2, blue: 0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(20)
                .shadow(color: Color.purple.opacity(0.4), radius: 12, y: 8)

                // Progress badge — only shows once user has started
                let pct = Int(vm.completionPercentage)
                if pct > 0 {
                    Text("\(pct)% done")
                        .font(.caption2.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.white.opacity(0.25))
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                        .padding(10)
                }
            }
        }
        .buttonStyle(SparkButtonStyle())
    }

    // MARK: - How It Works
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
                .foregroundStyle(.primary)
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
