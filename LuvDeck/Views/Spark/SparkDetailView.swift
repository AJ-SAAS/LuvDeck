import SwiftUI

struct SparkDetailView: View {
    let spark: SparkItem          // Use SparkItem for quick sparks
    @Environment(\.dismiss) var dismiss
    
    private var backgroundColor: Color {
        switch spark.category {
        case .conversation: return .pink
        case .deepQuestion: return .purple
        case .challenge:    return .red
        case .miniAction:   return .orange
        }
    }
    
    private var categoryIcon: String {
        switch spark.category {
        case .conversation: return "message.fill"
        case .deepQuestion: return "heart.text.square.fill"
        case .challenge:    return "flame.fill"
        case .miniAction:   return "bolt.heart.fill"
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Image(systemName: categoryIcon)
                    .font(.system(size: 80))
                    .foregroundStyle(.white.opacity(0.9))
                
                Text(spark.text)
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
}
