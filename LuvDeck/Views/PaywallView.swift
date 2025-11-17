// PaywallView.swift
// FINAL FIX – Guaranteed white card background, readable text

import SwiftUI

struct PaywallView: View {
    @Binding var isPresented: Bool

    @State private var selectedPlan: PaywallPlan = .yearly
    @State private var showCloseButton: Bool = false
    @State private var isProcessing: Bool = false
    @State private var showRestoreAlert: Bool = false

    private let accent = Color.red

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Close button
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
                        }
                        .transition(.opacity.combined(with: .scale))
                    } else {
                        Rectangle().foregroundColor(.clear).frame(width: 38, height: 38)
                    }
                }
                .padding([.horizontal, .top], 16)

                // Logo + Description
                VStack(spacing: 16) {
                    Image("luvdeckpremium")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 60)

                    Text("Unlock the full experience and become the person they can’t stop thinking about.")
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.black.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 32)
                }

                Spacer(minLength: 20)

                // Plan Cards
                VStack(spacing: 14) {
                    PlanCard(
                        planName: "Weekly – $3.99",
                        perWeekPrice: "$3.99 / week",
                        ribbon: nil,
                        isSelected: selectedPlan == .weekly
                    ) {
                        withAnimation { selectedPlan = .weekly }
                    }

                    PlanCard(
                        planName: "Yearly – $39.99",
                        perWeekPrice: "$0.77 / week",
                        ribbon: .bestValue,
                        isSelected: selectedPlan == .yearly
                    ) {
                        withAnimation { selectedPlan = .yearly }
                    }

                    PlanCard(
                        planName: "Lifetime – $89.99",
                        perWeekPrice: "One-time payment",
                        ribbon: nil,
                        isSelected: selectedPlan == .lifetime
                    ) {
                        withAnimation { selectedPlan = .lifetime }
                    }
                }
                .padding(.horizontal, 20)

                // Subscribe Button
                Button(action: continueTapped) {
                    HStack {
                        if isProcessing {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.9)
                        }
                        Text(isProcessing ? "Processing…" : "Subscribe & Continue >")
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(isProcessing ? Color.gray : accent)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: accent.opacity(0.3), radius: 12, x: 0, y: 8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .disabled(isProcessing)

                // Legal Links
                HStack(spacing: 20) {
                    Button("Terms") { openURL("https://www.luvdeck.com/r/terms") }
                    Text("|").foregroundColor(.black.opacity(0.3))
                    Button("Privacy") { openURL("https://www.luvdeck.com/r/privacy") }
                    Text("|").foregroundColor(.black.opacity(0.3))
                    Button("Restore") { showRestoreAlert = true }
                }
                .font(.system(.caption, design: .rounded))
                .foregroundColor(.black.opacity(0.68))
                .padding(.top, 10)

                Spacer(minLength: 20)
            }
            .padding(.bottom, safeAreaBottom() + 10)
            .alert("Restore Purchases", isPresented: $showRestoreAlert) {
                Button("OK") {}
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

    private func continueTapped() {
        print("Subscribe & Continue → \(selectedPlan.rawValue)")
        withAnimation { isProcessing = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
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
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Types
private enum PaywallPlan: String { case weekly, yearly, lifetime }
private enum Ribbon { case bestValue }

private struct PlanCard: View {
    let planName: String
    let perWeekPrice: String
    let ribbon: Ribbon?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                // Solid white background – forced at the root
                Color.white

                HStack(spacing: 12) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 28))
                        .foregroundColor(isSelected ? Color(#colorLiteral(red: 0.18, green: 0.8, blue: 0.45, alpha: 1)) : Color.black.opacity(0.4))

                    Text(planName)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.black)

                    Spacer()

                    VStack(alignment: .trailing, spacing: 6) {
                        if ribbon == .bestValue {
                            Text("BEST VALUE")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }

                        Text(perWeekPrice)
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(.black.opacity(0.9))
                    }
                }
                .padding(20)
            }
            .frame(maxWidth: .infinity)
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isSelected ? Color.red : Color.gray.opacity(0.3),
                            lineWidth: isSelected ? 3.5 : 1.5)
            )
            .shadow(color: isSelected ? Color.red.opacity(0.35) : Color.black.opacity(0.06),
                    radius: isSelected ? 16 : 6,
                    y: isSelected ? 10 : 4)
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 18)) // proper tap area
        .animation(.spring(response: 0.38, dampingFraction: 0.82), value: isSelected)
    }
}

// MARK: - Preview
struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView(isPresented: .constant(true))
    }
}
