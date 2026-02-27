import SwiftUI

struct SparkDetailView: View {
    let spark: Spark
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Determine category from title
    private var category: Any? {  // ✅ Fixed: Any? instead of Any
        if let item = momentumDatabase.first(where: { $0.text == spark.title }) {
            return item.category
        }
        if let item = sparkDatabase.first(where: { $0.text == spark.title }) {
            return item.category
        }
        return nil
    }
    
    private var backgroundColor: Color {
        switch category {
        case let c as SparkCategory:
            switch c {
            case .conversation: return .pink
            case .deepQuestion: return .purple
            case .challenge: return .red
            case .miniAction: return .orange
            }
        case let c as MomentumCategory:
            switch c {
            case .playfulness: return .blue
            case .emotionalDepth: return .purple
            case .surpriseChemistry: return .pink
            case .adventureMemory: return .orange
            case .legendaryPartner: return .red
            }
        default:
            return .gray
        }
    }
    
    private var categoryIcon: String {
        switch category {
        case let c as SparkCategory:
            switch c {
            case .conversation: return "message.fill"
            case .deepQuestion: return "heart.text.square.fill"
            case .challenge: return "flame.fill"
            case .miniAction: return "bolt.heart.fill"
            }
        case let c as MomentumCategory:
            switch c {
            case .playfulness: return "face.smiling.fill"
            case .emotionalDepth: return "heart.text.square.fill"
            case .surpriseChemistry: return "sparkles"
            case .adventureMemory: return "map.fill"
            case .legendaryPartner: return "star.fill"
            }
        default:
            return "sparkles"
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Image(systemName: categoryIcon)
                    .font(.system(size: 80))
                    .foregroundStyle(.white.opacity(0.9))
                
                Text(spark.title)
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
