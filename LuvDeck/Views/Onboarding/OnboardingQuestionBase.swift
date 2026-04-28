// OnboardingQuestionBase.swift

import SwiftUI

struct OnboardingQuestionBase<Content: View>: View {
    
    let title: String
    let subtitle: String?           // Optional subtitle
    let hideGlobalButton: Bool
    let content: Content
    
    init(
        title: String,
        subtitle: String? = nil,
        hideGlobalButton: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.hideGlobalButton = hideGlobalButton
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            
            // Title Area
            VStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)
                    .padding(.horizontal, 24)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 32)
            
            // Main Content Area (Centered)
            ScrollView {
                content
                    .padding(.horizontal, 8)
            }
            .scrollDisabled(true)        // Disable scrolling unless needed
            
            Spacer(minLength: 40)        // Helps with vertical centering
        }
        .ignoresSafeArea(.keyboard)
    }
}
