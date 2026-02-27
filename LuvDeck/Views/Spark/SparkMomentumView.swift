import SwiftUI

struct SparkMomentumView: View {
    @ObservedObject var vm: SparkViewModel
    @ObservedObject var purchaseVM: PurchaseViewModel
    @Environment(\.dismiss) var dismiss

    @State private var selectedChapter: MomentumCategory = .playfulness
    @State private var animatedTasks: Set<UUID> = []
    @State private var showPaywallLocal = false  // ✅ local paywall trigger

    // Deep plum that matches the Momentum card gradient
    private let bgTop    = Color(red: 0.28, green: 0.08, blue: 0.45)
    private let bgBottom = Color(red: 0.48, green: 0.10, blue: 0.30)

    var body: some View {
        ZStack {
            // Background gradient matching the Momentum card
            LinearGradient(
                colors: [bgTop, bgBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection
                chapterSelector.padding(.top, 20)
                taskList.padding(.top, 16)
            }
        }
        .preferredColorScheme(.dark)
        // ✅ Paywall presented directly from this view
        .sheet(isPresented: $showPaywallLocal) {
            PaywallView(isPresented: $showPaywallLocal, purchaseVM: purchaseVM)
        }
        // ✅ Instantly unlock chapters if purchase completes while sheet is open
        .onChange(of: purchaseVM.isSubscribed) { _, newValue in
            vm.isPremium = newValue
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 14) {

            HStack {
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(width: 32, height: 32)
                        .background(.white.opacity(0.15))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            VStack(spacing: 4) {
                Text("Momentum")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Build your love, one spark at a time")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }

            VStack(spacing: 8) {
                HStack {
                    Text("\(Int(vm.completionPercentage))% complete")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                    Spacer()
                    Text("\(completedCount) / \(vm.userSparks.count) done")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.horizontal, 20)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.white.opacity(0.2))
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: [.white, .white.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geo.size.width * CGFloat(vm.completionPercentage / 100),
                                height: 6
                            )
                            .shadow(color: .white.opacity(0.5), radius: 4)
                    }
                }
                .frame(height: 6)
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 8)
    }

    // MARK: - Chapter Selector
    private var chapterSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(MomentumCategory.allCases, id: \.self) { chapter in
                    let isSelected = selectedChapter == chapter
                    let isLocked = !vm.isPremium && chapter != .playfulness
                    let progress = chapterProgress(chapter)
                    let colors = gradientColors(chapter)

                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            selectedChapter = chapter
                        }
                    } label: {
                        VStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .stroke(.white.opacity(0.2), lineWidth: 3)
                                    .frame(width: 52, height: 52)

                                Circle()
                                    .trim(from: 0, to: progress)
                                    .stroke(
                                        LinearGradient(colors: [.white, .white.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing),
                                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                                    )
                                    .frame(width: 52, height: 52)
                                    .rotationEffect(.degrees(-90))
                                    .shadow(color: .white.opacity(0.4), radius: 4)

                                if isLocked {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(.white.opacity(0.5))
                                } else {
                                    Image(systemName: chapterIcon(chapter))
                                        .font(.system(size: 20))
                                        .foregroundStyle(.white.opacity(isSelected ? 1.0 : 0.5))
                                }
                            }

                            Text(chapterShortName(chapter))
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white.opacity(isSelected ? 1.0 : 0.5))
                                .multilineTextAlignment(.center)
                                .frame(width: 72)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(isSelected ? .white.opacity(0.15) : .clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.white.opacity(isSelected ? 0.4 : 0.0), lineWidth: 1.5)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Task List
    private var taskList: some View {
        let chapter = selectedChapter
        let isChapterLocked = !vm.isPremium && chapter != .playfulness
        let sparks = vm.userSparks.filter { sparkToMomentumItem($0)?.category == chapter }

        return ScrollView {
            VStack(spacing: 10) {

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(chapter.rawValue)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("\(sparks.filter(\.completed).count) of \(sparks.count) completed")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 4)

                if isChapterLocked {
                    paywallTeaser
                } else {
                    ForEach(sparks) { spark in
                        taskRow(spark: spark)
                    }
                }

                Spacer(minLength: 40)
            }
            .padding(.top, 4)
        }
    }

    // MARK: - Task Row
    private func taskRow(spark: Spark) -> some View {
        let isCompleted = spark.completed
        let isAnimating = animatedTasks.contains(spark.id)

        return Button {
            vm.toggleSpark(spark)
            if !isCompleted {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    animatedTasks.insert(spark.id)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    animatedTasks.remove(spark.id)
                }
            }
            triggerHaptic()
        } label: {
            HStack(spacing: 14) {

                // Checkbox
                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.35), lineWidth: 1.5)
                        .frame(width: 28, height: 28)

                    if isCompleted {
                        Circle()
                            .fill(.white)
                            .frame(width: 28, height: 28)

                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(bgTop)
                            .scaleEffect(isAnimating ? 1.3 : 1.0)
                    }
                }

                Text(spark.title)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(isCompleted ? .white.opacity(0.5) : .white)
                    .multilineTextAlignment(.leading)
                    .strikethrough(isCompleted, color: .white.opacity(0.4))

                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    // ✅ Lighter frosted white card
                    .fill(.white.opacity(isCompleted ? 0.10 : 0.18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(.white.opacity(isCompleted ? 0.1 : 0.25), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
    }

    // MARK: - Paywall Teaser
    private var paywallTeaser: some View {
        ZStack {
            // Ghost rows behind blur
            VStack(spacing: 10) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.white.opacity(0.18))
                        .frame(height: 58)
                        .padding(.horizontal, 20)
                }
            }
            .blur(radius: 5)

            // Lock overlay
            VStack(spacing: 14) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.white)

                Text("Unlock with Premium")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Get all 5 chapters and 50 challenges")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.65))

                // ✅ Now triggers local sheet which works from within this view
                Button {
                    showPaywallLocal = true
                } label: {
                    Text("Unlock Now")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(bgTop)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 13)
                        .background(.white)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                }
            }
            .padding(.vertical, 40)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Helpers
    private var completedCount: Int { vm.userSparks.filter(\.completed).count }

    private func chapterProgress(_ category: MomentumCategory) -> CGFloat {
        let all = vm.userSparks.filter { sparkToMomentumItem($0)?.category == category }
        guard !all.isEmpty else { return 0 }
        return CGFloat(all.filter(\.completed).count) / CGFloat(all.count)
    }

    private func sparkToMomentumItem(_ spark: Spark) -> MomentumItem? {
        momentumDatabase.first { $0.text == spark.title }
    }

    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    private func chapterShortName(_ category: MomentumCategory) -> String {
        switch category {
        case .playfulness:        return "Play"
        case .emotionalDepth:    return "Depth"
        case .surpriseChemistry: return "Surprise"
        case .adventureMemory:   return "Adventure"
        case .legendaryPartner:  return "Legendary"
        }
    }

    private func chapterIcon(_ category: MomentumCategory) -> String {
        switch category {
        case .playfulness:        return "face.smiling.fill"
        case .emotionalDepth:    return "heart.text.square.fill"
        case .surpriseChemistry: return "sparkles"
        case .adventureMemory:   return "map.fill"
        case .legendaryPartner:  return "star.fill"
        }
    }

    private func gradientColors(_ category: MomentumCategory) -> [Color] {
        switch category {
        case .playfulness:        return [.blue, .cyan]
        case .emotionalDepth:    return [.purple, .pink]
        case .surpriseChemistry: return [.pink, .red]
        case .adventureMemory:   return [.orange, .yellow]
        case .legendaryPartner:  return [.red, .purple]
        }
    }
}
