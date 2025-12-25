import SwiftUI
import StoreKit

struct PaywallView: View {
    @Binding var isPresented: Bool
    @ObservedObject var purchaseVM: PurchaseViewModel

    @State private var selectedPlan: PaywallPlan = .lifetime
    @State private var showCloseButton = false
    @State private var showMaybeLater = false
    @State private var isProcessing = false
    @State private var restoreMessage = ""

    private let accent = Color.red

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 18) {

                // Top-right: delayed X button – now properly positioned
                HStack {
                    Spacer()
                    ZStack {
                        if showCloseButton {
                            Button(action: { isPresented = false }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black.opacity(0.7))
                                    .frame(width: 38, height: 38)
                                    .background(Color.black.opacity(0.08))
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.black.opacity(0.12), lineWidth: 0.5))
                            }
                            .transition(.scale.combined(with: .opacity))
                        } else {
                            ProgressView()
                                .progressViewStyle(
                                    CircularProgressViewStyle(tint: .black.opacity(0.4))
                                )
                                .scaleEffect(0.9)
                                .frame(width: 38, height: 38)
                        }
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 50)  // Increased to avoid notch/status bar overlap
                }

                // Header
                VStack(spacing: 16) {
                    Image("luvdeckpremium")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 60)

                    Text("PREMIUM ACCESS")
                        .font(.system(size: 29, weight: .bold, design: .rounded))
                        .foregroundColor(.black.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    VStack(alignment: .leading, spacing: 14) {
                        Text("• 100+ Expert-backed questions")
                        Text("• Get Unlimited Date Ideas")
                        Text("• Unlock Unlimited Date Reminders")
                        Text("• Full Access to All Spark Deck")
                        Text("• Remove Boring Dates Forever")
                    }
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(.black.opacity(0.75))
                    .padding(.horizontal, 32)
                }

                // Reduced gap here – no extra Spacer
                // Plan Cards
                VStack(spacing: 14) {

                    PlanCard(
                        planName: "Lifetime Plan",
                        price: "$17.99",
                        subtitle: "One-time payment",
                        rightText: "BEST VALUE",
                        isSelected: selectedPlan == .lifetime,
                        isPremium: true  // Reduced padding inside PlanCard below
                    ) { withAnimation { selectedPlan = .lifetime } }

                    PlanCard(
                        planName: "3-Day Trial",
                        price: "$4.99 per week",
                        subtitle: nil,
                        rightText: "Short Term",
                        isSelected: selectedPlan == .weekly
                    ) { withAnimation { selectedPlan = .weekly } }

                    Text("NO PAYMENT REQUIRED TODAY")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.black.opacity(0.6))
                        .padding(.top, 2)
                }
                .padding(.horizontal, 20)

                // Subscribe button – even larger text (+3pt → 23pt)
                Button {
                    Task { await purchaseTapped() }
                } label: {
                    HStack {
                        if isProcessing {
                            ProgressView().tint(.white).scaleEffect(0.9)
                        }
                        Text(isProcessing ? "Processing…" : "Subscribe & Start now")
                            .font(.system(size: 23, weight: .semibold, design: .rounded))  // ← +3pt
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isProcessing ? Color.gray : accent)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: accent.opacity(0.3), radius: 12, y: 8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
                .disabled(isProcessing)

                // "Cancel anytime" – closer to button
                Text("Cancel anytime, no commitment")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.black.opacity(0.8))
                    .padding(.top, 4)  // Even tighter
                    .padding(.horizontal, 20)

                // Maybe later (delayed 6 seconds)
                if showMaybeLater {
                    Button { isPresented = false } label: {
                        Text("Maybe later.. >")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(.black.opacity(0.65))
                    }
                    .padding(.top, 10)
                    .transition(.opacity.combined(with: .scale))
                } else {
                    Spacer().frame(height: 40)
                }

                // Legal + Restore
                HStack(spacing: 20) {
                    Button("Terms of use") { openURL("https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") }
                    Text("|").foregroundColor(.black.opacity(0.3))
                    Button("Privacy") { openURL("https://www.luvdeck.com/r/privacy") }
                    Text("|").foregroundColor(.black.opacity(0.3))
                    Button("Restore") { Task { await restoreTapped() } }
                }
                .font(.system(.caption, design: .rounded))
                .foregroundColor(.black.opacity(0.68))
                .padding(.top, 10)

                if !restoreMessage.isEmpty {
                    Text(restoreMessage)
                        .font(.caption)
                        .foregroundColor(restoreMessage.contains("success") ? .green : .red)
                        .padding(.top, 8)
                }

                Spacer(minLength: 20)
            }
            .padding(.bottom, safeAreaBottom() + 10)
        }
        .onChange(of: purchaseVM.isSubscribed) { _, newValue in
            if newValue { isPresented = false }
        }
        .task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showCloseButton = true
            }

            try? await Task.sleep(nanoseconds: 3_000_000_000)
            withAnimation(.easeOut(duration: 0.4)) {
                showMaybeLater = true
            }
        }
    }

    // MARK: Logic
    private func purchaseTapped() async {
        isProcessing = true
        restoreMessage = ""

        let productID = selectedPlan == .weekly
            ? "luvdeck_weekly_399"
            : "luvdeck_lifetime_8999"

        guard let product = purchaseVM.allProducts.first(where: { $0.id == productID }) else {
            isProcessing = false
            return
        }

        await purchaseVM.purchase(product: product)
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

// MARK: - Supporting Types
private enum PaywallPlan: String { case weekly, lifetime }

private struct PlanCard: View {

    let planName: String
    let price: String
    let subtitle: String?
    let rightText: String?
    let isSelected: Bool
    var isPremium: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Color.white

                HStack(spacing: 16) {

                    VStack(alignment: .leading, spacing: 4) {
                        Text(planName)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.black)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(price)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.black)

                            if let subtitle = subtitle {
                                Text(subtitle)
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                                    .foregroundColor(.black.opacity(0.8))
                            }
                        }
                    }

                    Spacer()

                    if let right = rightText {
                        HStack(spacing: 10) {

                            Text(right)
                                .font(.system(size: right == "Short Term" ? 15 : 15, weight: .bold, design: .rounded))  // ← BEST VALUE +3pt
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(right == "BEST VALUE" ? Color.red : Color.clear)
                                .foregroundColor(right == "BEST VALUE" ? .white : .black)
                                .cornerRadius(6)

                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                                    .frame(width: 26, height: 26)

                                if isSelected {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 26, height: 26)

                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                }
                .padding(isPremium ? 18 : 20)  // ← Reduced padding for Lifetime card
            }
            .frame(maxWidth: .infinity)
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isSelected ? Color.red : Color.gray.opacity(0.3),
                            lineWidth: isSelected ? 3 : 1.5)
            )
            .shadow(
                color: isSelected ? Color.red.opacity(0.35) : Color.black.opacity(0.06),
                radius: isSelected ? 14 : 6,
                y: isSelected ? 10 : 4
            )
        }
        .buttonStyle(.plain)
    }
}

struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView(isPresented: .constant(true), purchaseVM: PurchaseViewModel())
    }
}
