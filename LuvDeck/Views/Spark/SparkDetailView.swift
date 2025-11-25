// SparkDetailView.swift
import SwiftUI

struct SparkDetailView: View {
    let item: SparkItem?
    @Environment(\.dismiss) var dismiss
    
    private var backgroundColor: Color {
        switch item?.category {
        case .conversation: return .pink
        case .deepQuestion: return .purple
        case .challenge:    return .red
        case .miniAction:   return .orange
        case nil:           return .gray
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Image(systemName: categoryIcon)
                    .font(.system(size: 80))
                    .foregroundStyle(.white.opacity(0.9))
                
                Text(item?.text ?? "No spark today")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                Spacer()
                
                Button("Done") { dismiss() }
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                    .frame(maxWidth: 200)
                    .padding(.vertical, 16)
                    .background(.white.opacity(0.3))
                    .cornerRadius(12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundColor.gradient)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                }
            }
        }
    }
    
    private var categoryIcon: String {
        switch item?.category {
        case .conversation: return "message.fill"
        case .deepQuestion: return "heart.text.square.fill"
        case .challenge:    return "flame.fill"
        case .miniAction:   return "bolt.heart.fill"
        default:            return "sparkles"
        }
    }
}
