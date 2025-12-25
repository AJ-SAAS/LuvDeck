import SwiftUI

struct RelationshipFocusView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    let options = [
        "Communication",
        "Intimacy",
        "Fun & Creativity",
        "Mutual Growth",
        "Nothing, just have fun"
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                VStack(spacing: 0) {
                    ProgressView(value: Double(viewModel.currentStep + 1) / 8.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .pink))
                        .padding(.horizontal, 40)
                        .padding(.top, 12)

                    VStack(spacing: 12) {
                        Text("What areas of the relationship do you want to nurture most?")
                            .font(.system(size: titleFontSize(for: geometry), weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("You can choose more than one")
                            .font(.system(size: subtitleFontSize(for: geometry), weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20) // Reduced gap

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            ForEach(options, id: \.self) { option in
                                Button {
                                    withAnimation {
                                        if viewModel.relationshipFocus.contains(option) {
                                            viewModel.relationshipFocus.remove(option)
                                        } else {
                                            viewModel.relationshipFocus.insert(option)
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(option)
                                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                                            .foregroundColor(.primary)

                                        Spacer()

                                        if viewModel.relationshipFocus.contains(option) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.pink)
                                                .font(.title2)
                                        }
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(viewModel.relationshipFocus.contains(option) ? Color.pink.opacity(0.15) : Color(.systemGray6))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(viewModel.relationshipFocus.contains(option) ? Color.pink : Color.clear, lineWidth: 2)
                                    )
                                    .shadow(color: .black.opacity(0.05), radius: 4)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 24)
                    }

                    Spacer(minLength: 20)

                    Button {
                        viewModel.nextStep(userId: nil)
                    } label: {
                        Text("Next")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(viewModel.relationshipFocus.isEmpty ? Color.gray.opacity(0.3) : Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .disabled(viewModel.relationshipFocus.isEmpty)
                    .padding(.horizontal, 32)

                    Spacer(minLength: geometry.safeAreaInsets.bottom + 20)
                }
            }
        }
    }

    private func titleFontSize(for geometry: GeometryProxy) -> CGFloat {
        min(geometry.size.width * 0.078, 32)
    }

    private func subtitleFontSize(for geometry: GeometryProxy) -> CGFloat {
        min(geometry.size.width * 0.045, 18)
    }
}
