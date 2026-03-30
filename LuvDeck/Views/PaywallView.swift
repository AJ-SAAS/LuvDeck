import SwiftUI
import RevenueCat

struct PaywallView: View {
    @Binding var isPresented: Bool
    @ObservedObject var purchaseVM: PurchaseViewModel

    @State private var showCloseButton = false
    @State private var isProcessing = false
    @State private var restoreMessage = ""

    private let accent = Color.white
    private let tickColor = Color.green
    private let lightBlack = Color.black.opacity(0.2)

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {

                // ── SCROLLABLE TOP SECTION ──
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {

                        // Top-left close button
                        HStack {
                            if showCloseButton {
                                Button(action: { completePaywall() }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white.opacity(0.7))
                                        .frame(width: 38, height: 38)
                                        .background(Color.white.opacity(0.08))
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle().stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                                        )
                                }
                                .transition(.scale.combined(with: .opacity))
                            } else {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white.opacity(0.4)))
                                    .scaleEffect(0.9)
                                    .frame(width: 38, height: 38)
                            }

                            Spacer()
                        }
                        .padding(.leading, 16)
                        .padding(.top, 18)

                        // Header
                        VStack(spacing: 12) {
                            Text("Better Dates.\nDeeper Connection.")
                                .font(.system(size: 31, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 28)

                            // Bullet points with light black background
                            bulletPointsContainer

                            // Social Proof Quote with gradient background
                            socialProofQuote
                        }

                        Spacer(minLength: 16)
                    }
                }

                // ── FIXED BOTTOM SECTION ──
                VStack(spacing: 12) {

                    VStack(spacing: 12) {
                        ZStack(alignment: .top) {
                            PlanCard(
                                planName: "Save on Annual",
                                price: "$19.99 / year",
                                subtitle: "3-day free trial, then $19.99 / year",
                                isSelected: purchaseVM.selectedPackageIndex == 0,
                                lightBlack: lightBlack,
                                tickColor: tickColor
                            ) {
                                withAnimation { purchaseVM.selectedPackageIndex = 0 }
                            }

                            HStack {
                                Spacer()
                                Text("$1.66 / month")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.green)
                                    .cornerRadius(20)
                                    .offset(y: -12)
                                    .padding(.trailing, 16)
                            }
                        }

                        PlanCard(
                            planName: "Lifetime",
                            price: "$29.99",
                            subtitle: "Pay once, access forever",
                            isSelected: purchaseVM.selectedPackageIndex == 1,
                            lightBlack: lightBlack,
                            tickColor: tickColor
                        ) {
                            withAnimation { purchaseVM.selectedPackageIndex = 1 }
                        }
                    }
                    .padding(.horizontal, 20)

                    Text(purchaseVM.selectedPackageIndex == 0 ? "No Payment Due Now" : "Pay once, access forever")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Button {
                        Task { await purchaseTapped() }
                    } label: {
                        HStack {
                            if isProcessing {
                                ProgressView().tint(.black).scaleEffect(0.8)
                            }
                            Text(isProcessing ? "Processing…" : purchaseVM.selectedPackageIndex == 0 ? "Try Free for 3 Days" : "Start Now")
                                .font(.system(size: 22, weight: .semibold, design: .rounded))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(isProcessing ? Color.gray : accent)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .shadow(color: accent.opacity(0.25), radius: 6, y: 3)
                    }
                    .padding(.horizontal, 20)
                    .disabled(isProcessing)

                    paywallFooter
                }
                .padding(.top, 12)
                .padding(.bottom, safeAreaBottom() + 6)
                .background(Color.black)
            }
        }
        .onChange(of: purchaseVM.isSubscribed) { _, newValue in
            if newValue { completePaywall() }
        }
        .task {
            try? await Task.sleep(nanoseconds: 2_200_000_000)
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { showCloseButton = true }
        }
    }

    // MARK: - Bullet Points Container
    private var bulletPointsContainer: some View {
        VStack(alignment: .leading, spacing: 12) {
            bulletPoint("365+ ready-to-use date ideas")
            bulletPoint("All conversation starters & deep questions")
            bulletPoint("Unlock all romance challenges")
            bulletPoint("Unlimited 5 relationship modes")
            bulletPoint("All Your Dates Saved: Organized + Reminders")
            bulletPoint("Full access to the Momentum*")
        }
        .padding(16)
        .background(lightBlack)
        .cornerRadius(14)
        .padding(.horizontal, 28)
    }

    // MARK: - Social Proof Quote with Gradient
    private var socialProofQuote: some View {
        Text("\"Best thing we've done for our relationship\"")
            .font(.system(size: 14, weight: .regular, design: .rounded).italic())
            .foregroundColor(.white)
            .padding(12)
            .background(
                LinearGradient(
                    colors: [
                        Color(hex: "#fd0093"),
                        Color(hex: "#ff0400")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .padding(.horizontal, 28)
    }

    // MARK: - Footer
    private var paywallFooter: some View {
        VStack(spacing: 6) {
            HStack(spacing: 20) {
                Button("Terms of use") { openURL("https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") }
                Text("|").foregroundColor(.white.opacity(0.3))
                Button("Privacy") { openURL("https://www.luvdeck.com/r/privacy") }
                Text("|").foregroundColor(.white.opacity(0.3))
                Button("Restore") { Task { await restoreTapped() } }
            }
            .font(.system(size: 11.5, weight: .medium, design: .rounded))
            .foregroundColor(.white.opacity(0.6))
            .padding(.top, 8)

            if !restoreMessage.isEmpty {
                Text(restoreMessage)
                    .font(.caption)
                    .foregroundColor(
                        restoreMessage.contains("success") ? .green : .red
                    )
                    .padding(.top, 4)
            }
        }
    }

    // MARK: - Helpers
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(tickColor)
                .font(.system(size: 20))
            Text(text)
                .foregroundColor(.white)
                .font(.system(size: 20, weight: .regular, design: .rounded))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func completePaywall() { isPresented = false }

    private func purchaseTapped() async {
        guard !purchaseVM.allPackages.isEmpty else {
            restoreMessage = "Still loading products, please try again."
            return
        }

        isProcessing = true
        restoreMessage = ""
        let package = purchaseVM.allPackages[purchaseVM.selectedPackageIndex]
        await purchaseVM.purchase(package: package)
        isProcessing = false
    }

    private func restoreTapped() async {
        isProcessing = true
        restoreMessage = ""
        await purchaseVM.restorePurchases()
        restoreMessage = "Purchases restored successfully!"
        isProcessing = false
    }

    private func safeAreaBottom() -> CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first?.safeAreaInsets.bottom ?? 20
    }

    private func openURL(_ urlString: String) {
        if let url = URL(string: urlString) { UIApplication.shared.open(url) }
    }
}

// MARK: - PlanCard
private struct PlanCard: View {
    let planName: String
    let price: String
    let subtitle: String?
    let isSelected: Bool
    let lightBlack: Color
    let tickColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(planName)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(.white)

                    Text(price)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(.white)
                    }
                }

                Spacer()

                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        .frame(width: 26, height: 26)

                    if isSelected {
                        Circle()
                            .fill(tickColor)
                            .frame(width: 26, height: 26)

                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.white.opacity(0.12) : Color.white.opacity(0.04))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.white.opacity(0.5) : Color.white.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
