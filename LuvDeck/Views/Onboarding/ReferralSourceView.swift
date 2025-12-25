import SwiftUI

struct ReferralSourceView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    @State private var showScrollHint = true

    private let options: [Option] = [
        .init(title: "App Store Search", systemIcon: "applelogo"),
        .init(title: "TikTok", systemIcon: "music.note"),
        .init(title: "Through a friend", systemIcon: "person.2.fill"),
        .init(title: "YouTube", systemIcon: "play.rectangle"),
        .init(title: "From your partner", systemIcon: "heart.fill"),
        .init(title: "Facebook", systemIcon: "f.circle.fill"),
        .init(title: "Google Search", systemIcon: "magnifyingglass"),
        .init(title: "X", systemIcon: "xmark"),
        .init(title: "Instagram", systemIcon: "camera"),
        .init(title: "Other", systemIcon: "ellipsis")
    ]

    struct Option: Identifiable {
        let id = UUID()
        let title: String
        let systemIcon: String
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                VStack(spacing: 0) {
                    ProgressView(value: Double(viewModel.currentStep + 1) / 8.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .pink))
                        .padding(.horizontal, 40)
                        .padding(.top, 12)

                    Text("Where did you hear about us?")
                        .font(.system(size: titleFontSize(for: geometry), weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 40)
                        .padding(.top, 20)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            ForEach(options) { option in
                                Button {
                                    withAnimation {
                                        viewModel.referralSource = option.title
                                    }
                                } label: {
                                    HStack(spacing: 16) {
                                        Image(systemName: option.systemIcon)
                                            .font(.title2)
                                            .foregroundColor(.pink)
                                            .frame(width: 32)

                                        Text(option.title)
                                            .font(.system(size: 18, weight: .medium, design: .rounded))
                                            .foregroundColor(.primary)

                                        Spacer()

                                        if viewModel.referralSource == option.title {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.pink)
                                                .font(.title3)
                                        }
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(viewModel.referralSource == option.title ? Color.pink.opacity(0.15) : Color(.systemGray6))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(viewModel.referralSource == option.title ? Color.pink : Color.clear, lineWidth: 2)
                                    )
                                    .shadow(color: .black.opacity(0.05), radius: 4)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 24)
                    }

                    if showScrollHint {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.secondary)
                            .padding()
                            .background(Color(.systemBackground).opacity(0.8))
                            .clipShape(Circle())
                            .shadow(radius: 2)
                            .animation(.easeInOut(duration: 0.8).repeatCount(3), value: showScrollHint)
                            .padding(.top, 8)
                    }

                    Spacer(minLength: 20)

                    Button {
                        viewModel.nextStep(userId: nil)
                    } label: {
                        Text("Continue")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(viewModel.referralSource == nil ? Color.gray.opacity(0.3) : Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .disabled(viewModel.referralSource == nil)
                    .padding(.horizontal, 32)

                    Spacer(minLength: geometry.safeAreaInsets.bottom + 20)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 0.6)) {
                    showScrollHint = false
                }
            }
        }
    }

    private func titleFontSize(for geometry: GeometryProxy) -> CGFloat {
        min(geometry.size.width * 0.078, 32)
    }
}
