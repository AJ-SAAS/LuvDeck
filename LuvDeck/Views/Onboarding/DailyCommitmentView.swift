import SwiftUI

struct DailyCommitmentView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    let options = [3, 5, 10, 15]

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
                        Text("How much time will you give your relationship daily?")
                            .font(.system(size: titleFontSize(for: geometry), weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("A few minutes makes a big difference")
                            .font(.system(size: subtitleFontSize(for: geometry), weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20) // Same reduced gap

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            ForEach(options, id: \.self) { minutes in
                                Button {
                                    withAnimation {
                                        viewModel.dailyCommitment = minutes
                                    }
                                } label: {
                                    Text("\(minutes) minutes / day")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(.primary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 18)
                                        .background(
                                            RoundedRectangle(cornerRadius: 14)
                                                .fill(viewModel.dailyCommitment == minutes ? Color.pink.opacity(0.15) : Color(.systemGray6))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(viewModel.dailyCommitment == minutes ? Color.pink : Color.clear, lineWidth: 2)
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
                        Text("I'm Committed")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(viewModel.dailyCommitment == nil ? Color.gray.opacity(0.3) : Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .disabled(viewModel.dailyCommitment == nil)
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
