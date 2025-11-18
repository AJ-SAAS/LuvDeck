// PremiumTeaserBanner.swift
import SwiftUI

struct PremiumTeaserBanner: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var viewModel: HomeViewModel       // ← Fixed: comma was missing
    @EnvironmentObject var purchaseVM: PurchaseViewModel

    var body: some View {
        if isPresented {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                        .font(.title2)
                    
                    Text("Want more epic & legendary romance ideas?")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.spring()) {
                            isPresented = false
                            viewModel.dismissTeaserBanner()
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.secondary)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(Color.black.opacity(0.08)))
                    }
                }
                
                Button("Upgrade to LuvDeck Premium") {
                    purchaseVM.shouldPresentPaywall = true
                    withAnimation(.spring()) {
                        isPresented = false
                    }
                }
                .font(.title3.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(Color.red)
                .cornerRadius(14)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .zIndex(100)
        }
    }
}

#Preview {
    PremiumTeaserBanner(isPresented: .constant(true))
        .environmentObject(HomeViewModel(userId: nil))
        .environmentObject(PurchaseViewModel())
}
