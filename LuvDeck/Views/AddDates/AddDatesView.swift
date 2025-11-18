import SwiftUI

struct AddDatesView: View {
    @StateObject var viewModel: AddDatesViewModel
    @ObservedObject var purchaseVM: PurchaseViewModel

    @State private var showAddSheet = false
    @State private var selectedEvent: DateEvent?
    @State private var showHowItWorks = false

    // MARK: - Custom initializer to wire the isPremium provider into the ViewModel
    init(purchaseVM: PurchaseViewModel, userId: String? = nil) {
        // Create the StateObject with the correct provider closure
        _viewModel = StateObject(wrappedValue: AddDatesViewModel(userId: userId, isPremiumProvider: { purchaseVM.isPremium }))
        self.purchaseVM = purchaseVM
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Hero Tagline
                    VStack(spacing: 12) {
                        Text("Never forget what matters.")
                            .font(.title2.bold())
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Text("Anniversaries, birthdays, weekly dates — keep love alive with gentle nudges.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)

                    // MARK: - Event Cards (Upcoming only)
                    if viewModel.upcomingEvents.isEmpty {
                        emptyStateCard
                    } else {
                        eventCards
                    }

                    Spacer(minLength: 80)
                }
                .padding(.horizontal)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // MARK: - Centered Logo (Exact Match with HomeView)
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
                    .background(Color.white.opacity(0.95))
                    .shadow(color: .black.opacity(0.05), radius: 3, y: 1)
                    .padding(.trailing, 44)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Check limit BEFORE opening the Add sheet
                        if viewModel.canCreateEvent() {
                            selectedEvent = nil
                            showAddSheet = true
                        } else {
                            // show paywall instead of the add sheet
                            viewModel.showPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.pink)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddDateSheet(viewModel: viewModel, event: selectedEvent)
            }
            // Present the Paywall when the viewModel toggles it
            .sheet(isPresented: Binding(get: { viewModel.showPaywall }, set: { viewModel.showPaywall = $0 })) {
                PaywallView(isPresented: Binding(get: { viewModel.showPaywall }, set: { viewModel.showPaywall = $0 }), purchaseVM: purchaseVM)
            }
            .alert(item: errorBinding) { err in
                Alert(title: Text("Error"), message: Text(err.message), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                viewModel.fetchEvents()
            }

            // MARK: - Floating "How It Works" Card
            .overlay(alignment: .bottom) {
                howItWorksCard
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .animation(.spring(response: 0.4), value: showHowItWorks)
            }
        }
    }

    // MARK: - Empty State Card
    private var emptyStateCard: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 70))
                .foregroundStyle(.pink.opacity(0.6))

            Text("No special dates yet")
                .font(.title3.bold())

            Text("Tap the pink + to add an anniversary, birthday, or weekly date night.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 10, y: 5)
        )
    }

    // MARK: - Event Cards (Upcoming only)
    private var eventCards: some View {
        ForEach(viewModel.upcomingEvents) { event in
            EventCard(event: event, viewModel: viewModel)
                .onTapGesture {
                    selectedEvent = event
                    showAddSheet = true
                }
        }
    }

    // MARK: - How It Works Card (Collapsible) — CENTERED + PINK
    private var howItWorksCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation { showHowItWorks.toggle() }
            } label: {
                HStack {
                    Text("How LuvDeck Dates Works")
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
                    bulletPoint("Never miss an anniversary, birthday, or weekly check-in")
                    bulletPoint("Get gentle reminders to send flowers, write a note, or plan a surprise")
                    bulletPoint("Review past dates — reflect on what made them special")
                    bulletPoint("Build rituals that keep love growing, week after week")
                }
                .font(.subheadline)
                .foregroundStyle(.pink.opacity(0.9))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
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

    // MARK: - Helpers
    private var errorBinding: Binding<IdentifiableError?> {
        Binding(
            get: { viewModel.errorMessage.map { IdentifiableError(message: $0) } },
            set: { _ in viewModel.errorMessage = nil }
        )
    }
}

// MARK: - Event Card (Tinder-style)
struct EventCard: View {
    let event: DateEvent
    let viewModel: AddDatesViewModel

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // Icon
            Image(systemName: event.eventType.sfSymbolName)
                .font(.title)
                .foregroundStyle(eventTypeColor)
                .frame(width: 50, height: 50)
                .background(Circle().fill(eventTypeColor.opacity(0.15)))

            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(event.personName)
                    .font(.headline)
                    .foregroundStyle(.primary)

                HStack {
                    Text(event.eventType.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(event.date, format: .dateTime.month(.abbreviated).day())
                        .font(.caption.bold())
                        .foregroundStyle(event.date < Date() ? .secondary : .primary)
                }
            }

            Spacer()

            // Reminder Toggle
            Image(systemName: event.reminderOn ? "bell.fill" : "bell.slash")
                .foregroundStyle(event.reminderOn ? .pink : .secondary)
                .onTapGesture {
                    viewModel.toggleReminder(for: event)
                }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
        )
        .padding(.vertical, 4)
    }

    private var eventTypeColor: Color {
        switch event.eventType {
        case .birthday: return .orange
        case .anniversary: return .red
        case .date: return .pink
        case .other: return .purple
        }
    }
}

// MARK: - Identifiable Error for Alerts
struct IdentifiableError: Identifiable {
    let id = UUID()
    let message: String
}

// MARK: - Previews
struct AddDatesView_Previews: PreviewProvider {
    static var previews: some View {
        AddDatesView(purchaseVM: PurchaseViewModel(), userId: nil)
    }
}
