import SwiftUI

struct QuestionLongTermGoalsView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    
    let goalOptions = [
        "💍 Build a lasting relationship",
        "👨‍👩‍👧 Strengthen family bonds",
        "🌟 Become her dream partner",
        "🤔 Not sure yet"
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // Progress bar
                    ProgressView(value: viewModel.progress)
                        .progressViewStyle(
                            LinearProgressViewStyle(tint: .pink)
                        )
                        .padding(.horizontal, 40)
                        .padding(.top, 12)
                    
                    Spacer().frame(height: 30)
                    
                    // Title
                    Text("What are your long-term relationship goals?")
                        .font(
                            .system(
                                size: titleFontSize(for: geometry),
                                weight: .bold,
                                design: .rounded
                            )
                        )
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Options – now matches ReferralSourceView style perfectly
                    VStack(spacing: 14) {
                        ForEach(goalOptions, id: \.self) { goal in
                            Button {
                                withAnimation {
                                    viewModel.longTermGoal = goal
                                }
                            } label: {
                                HStack(spacing: 16) {
                                    Text(goal)
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primary)  // ← FIXED: always primary (black)
                                    
                                    Spacer()
                                    
                                    if viewModel.longTermGoal == goal {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.pink)
                                    }
                                }
                                .padding(.vertical, 18)
                                .padding(.horizontal, 20)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(viewModel.longTermGoal == goal ? Color.pink.opacity(0.15) : Color(.systemGray6))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(viewModel.longTermGoal == goal ? Color.pink : Color.clear, lineWidth: 2)
                                )
                                .shadow(color: .black.opacity(0.05), radius: 4)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 24)
                    
                    Spacer() // pushes content up
                }
                
                // ✅ FIXED BOTTOM CTA
                VStack {
                    Spacer()
                    
                    Button {
                        withAnimation {
                            viewModel.nextStep(userId: nil)
                        }
                    } label: {
                        Text("Continue")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                viewModel.longTermGoal == nil
                                ? Color.gray.opacity(0.3)
                                : Color.black
                            )
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .disabled(viewModel.longTermGoal == nil)
                    .padding(.horizontal, 32)
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 16)
                }
            }
        }
    }
    
    private func titleFontSize(for geometry: GeometryProxy) -> CGFloat {
        min(geometry.size.width * 0.078, 32)
    }
}
