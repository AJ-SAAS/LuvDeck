// PaywallView.swift
// Final version: white bg, red button, left checkmarks, real links, restore placeholder

import SwiftUI

struct PaywallView: View {
    @Binding var isPresented: Bool

    // UI state
    @State private var selectedPlan: PaywallPlan = .yearly
    @State private var showCloseButton: Bool = false
    @State private var isProcessing: Bool = false
    @State private var showRestoreAlert: Bool = false
    @Environment(\.dismiss) private var dismiss

    // Visual tokens
    private let cardCorner: CGFloat = 16
    private let accent = Color.red

    var body: some View {
        ZStack {
            // Full-screen white background
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 18) {
                // Close button row (top-right)
                HStack {
                    Spacer()
                    if showCloseButton {
                        Button(action: closeTapped) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black.opacity(0.7))
                                .frame(width: 38, height: 38)
                                .background(Color.black.opacity(0.08))
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.black.opacity(0.12), lineWidth: 0.5))
                                .accessibilityLabel("Close paywall")
                        }
                        .transition(.opacity.combined(with: .scale))
                    } else {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 38, height: 38)
                    }
                }
                .padding([.horizontal, .top], 16)

                Spacer(minLength: 4)

                // Header
                paywallHeader

                // Plan cards
                VStack(spacing: 14) {
                    PlanCard(
                        title: "Weekly",
                        subtitle: "Billed weekly",
                        price: "$3.99",
                        isSelected: selectedPlan == .weekly,
                        ribbon: nil
                    ) {
                        withAnimation { selectedPlan = .weekly }
                    }

                    PlanCard(
                        title: "Yearly",
                        subtitle: "Billed annually",
                        price: "$39.99",
                        isSelected: selectedPlan == .yearly,
                        ribbon: .mostPopular
                    ) {
                        withAnimation { selectedPlan = .yearly }
                    }

                    PlanCard(
                        title: "Lifetime",
                        subtitle: "One-time purchase",
                        price: "$89.99",
                        isSelected: selectedPlan == .lifetime,
                        ribbon: nil
                    ) {
                        withAnimation { selectedPlan = .lifetime }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 6)

                // CTA Button (Red)
                Button(action: continueTapped) {
                    HStack {
                        if isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.9)
                                .padding(.trailing, 6)
                        }
                        Text(isProcessing ? "Processing…" : "Get LuvDeck Premium")
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(isProcessing ? Color.gray : accent)
                    .foregroundColor(.white)
                    .cornerRadius(cardCorner)
                    .shadow(color: accent.opacity(isProcessing ? 0 : 0.3), radius: 8, x: 0, y: 6)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .disabled(isProcessing)

                // Legal Links + Restore (single line)
                HStack(spacing: 16) {
                    Button("Terms") {
                        openURL("https://www.luvdeck.com/r/terms")
                    }
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.black.opacity(0.68))

                    Text("|")
                        .foregroundColor(.black.opacity(0.3))
                        .font(.caption)

                    Button("Privacy") {
                        openURL("https://www.luvdeck.com/r/privacy")
                    }
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.black.opacity(0.68))

                    Text("|")
                        .foregroundColor(.black.opacity(0.3))
                        .font(.caption)

                    Button("Restore") {
                        showRestoreAlert = true
                    }
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.black.opacity(0.68))
                }
                .padding(.top, 8)

                Spacer(minLength: 20)
            }
            .padding(.bottom, safeAreaBottom() + 8)
            .foregroundColor(.black)
            .animation(.easeInOut, value: showCloseButton)
            .alert("Restore Purchases", isPresented: $showRestoreAlert) {
                Button("OK") { }
            } message: {
                Text("Restore functionality is coming soon.")
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                        showCloseButton = true
                    }
                }
            }
        }
    }

    // MARK: - Subviews & Helpers

    private var paywallHeader: some View {
        VStack(spacing: 10) {
            Text("LuvDeck Premium")
                .font(.system(.largeTitle, design: .rounded).weight(.bold))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)
                .lineLimit(2)
                .padding(.horizontal, 24)
                .foregroundColor(.black)

            Text("Unlock the full experience and become the person they can’t stop thinking about.")
                .font(.system(.body, design: .rounded))
                .foregroundColor(.black.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
                .fixedSize(horizontal: false, vertical: true)
                .minimumScaleFactor(0.5)
        }
        .padding(.bottom, 6)
    }

    private func continueTapped() {
        print("Continue tapped — selectedPlan: \(selectedPlan.rawValue)")
        withAnimation { isProcessing = true }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation {
                isProcessing = false
                isPresented = false
            }
        }
    }

    private func closeTapped() {
        withAnimation { isPresented = false }
    }

    private func safeAreaBottom() -> CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first?.safeAreaInsets.bottom ?? 20
    }

    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - Plan Components

private enum PaywallPlan: String {
    case weekly, yearly, lifetime
}

private enum Ribbon { case mostPopular }

private struct PlanCard: View {
    let title: String
    let subtitle: String
    let price: String
    let isSelected: Bool
    let ribbon: Ribbon?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Checkmark on LEFT
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 26))
                    .foregroundColor(isSelected ? Color(#colorLiteral(red: 0.180, green: 0.8, blue: 0.447, alpha: 1)) : Color.black.opacity(0.4))
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.system(.headline, design: .rounded).bold())
                            .foregroundColor(.black)

                        if ribbon == .mostPopular {
                            Text("MOST POPULAR")
                                .font(.system(.caption2, design: .rounded).bold())
                                .padding(.horizontal, 8).padding(.vertical, 5)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(6)
                        }
                    }

                    Text(subtitle)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.black.opacity(0.7))
                }

                Spacer()

                Text(price)
                    .font(.system(.title3, design: .rounded).bold())
                    .foregroundColor(.black)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.black.opacity(0.08) : Color.black.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isSelected ? Color.black.opacity(0.2) : Color.black.opacity(0.08), lineWidth: isSelected ? 1.5 : 1.0)
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title). \(subtitle). Price \(price).")
    }
}

// MARK: - Preview
struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView(isPresented: .constant(true))
    }
}
