import SwiftUI

struct SparkMomentumView: View {
    @ObservedObject var vm: SparkViewModel
    @ObservedObject var purchaseVM: PurchaseViewModel
    @Environment(\.dismiss) var dismiss

    @State private var selectedChapter: MomentumCategory = .playfulness
    @State private var animatedTasks: Set<UUID> = []
    @State private var showPaywallLocal = false

    // ✅ Local completed state saved to UserDefaults by task title
    @State private var completedTitles: Set<String> = []

    private let bgTop    = Color(red: 0.28, green: 0.08, blue: 0.45)
    private let bgBottom = Color(red: 0.48, green: 0.10, blue: 0.30)

    // ✅ All tasks hardcoded from momentumDatabase — no Firebase dependency
    private let allSparks: [Spark] = momentumDatabase
        .map { Spark(id: UUID(), title: $0.text, completed: false, category: $0.category) }

    var body: some View {
        ZStack {
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
        .sheet(isPresented: $showPaywallLocal) {
            PaywallView(isPresented: $showPaywallLocal, purchaseVM: purchaseVM)
        }
        .onChange(of: purchaseVM.isSubscribed) { _, newValue in
            vm.isPremium = newValue
        }
        .onAppear {
            loadCompletedTitles()
        }
    }

    // MARK: - Load / Save
    private func loadCompletedTitles() {
        let saved = UserDefaults.standard.stringArray(forKey: "completedMomentumTitles") ?? []
        completedTitles = Set(saved)
    }

    private func saveCompletedTitles() {
        UserDefaults.standard.set(Array(completedTitles), forKey: "completedMomentumTitles")
    }

    private func toggleCompleted(for spark: Spark) {
        if completedTitles.contains(spark.title) {
            completedTitles.remove(spark.title)
        } else {
            completedTitles.insert(spark.title)
        }
        saveCompletedTitles()
    }

    private func isCompleted(_ spark: Spark) -> Bool {
        completedTitles.contains(spark.title)
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
                    Text("\(Int(overallCompletionPercentage))% complete")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                    Spacer()
                    Text("\(completedCount) / \(totalCount) done")
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
                                width: geo.size.width * CGFloat(overallCompletionPercentage / 100),
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
        // ✅ All chapters now use hardcoded allSparks — no Firebase needed
        let sparks = allSparks.filter { $0.category == chapter }
        let completedInChapter = sparks.filter { isCompleted($0) }.count

        return ScrollView {
            VStack(spacing: 10) {

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(chapter.rawValue)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("\(completedInChapter) of \(sparks.count) completed")
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
        let completed = isCompleted(spark)
        let isAnimating = animatedTasks.contains(spark.id)

        return Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                toggleCompleted(for: spark)
                if !completed {
                    animatedTasks.insert(spark.id)
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                animatedTasks.remove(spark.id)
            }
            triggerHaptic()
        } label: {
            HStack(spacing: 14) {

                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.35), lineWidth: 1.5)
                        .frame(width: 28, height: 28)

                    if completed {
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
                    .foregroundStyle(completed ? .white.opacity(0.5) : .white)
                    .multilineTextAlignment(.leading)
                    .strikethrough(completed, color: .white.opacity(0.4))

                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(.white.opacity(completed ? 0.10 : 0.18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(.white.opacity(completed ? 0.1 : 0.25), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
    }

    // MARK: - Paywall Teaser
    private var paywallTeaser: some View {
        ZStack {
            VStack(spacing: 10) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.white.opacity(0.18))
                        .frame(height: 58)
                        .padding(.horizontal, 20)
                }
            }
            .blur(radius: 5)

            VStack(spacing: 14) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(.white)

                Text("Unlock with Premium")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                // ✅ Updated copy to reflect new task count
                Text("Get all 5 chapters and 90 challenges")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.65))

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
    private var completedCount: Int {
        momentumDatabase.filter { completedTitles.contains($0.text) }.count
    }

    private var totalCount: Int {
        momentumDatabase.count
    }

    private var overallCompletionPercentage: Double {
        guard totalCount > 0 else { return 0 }
        return (Double(completedCount) / Double(totalCount)) * 100
    }

    private func chapterProgress(_ category: MomentumCategory) -> CGFloat {
        let all = momentumDatabase.filter { $0.category == category }
        guard !all.isEmpty else { return 0 }
        let done = all.filter { completedTitles.contains($0.text) }.count
        return CGFloat(done) / CGFloat(all.count)
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
