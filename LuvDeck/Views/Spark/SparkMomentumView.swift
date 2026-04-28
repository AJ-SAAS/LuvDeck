// SparkMomentumView.swift

import SwiftUI

struct SparkMomentumView: View {
    @ObservedObject var vm: SparkViewModel
    @ObservedObject var purchaseVM: PurchaseViewModel
    @Environment(\.dismiss) var dismiss

    @State private var selectedChapter: MomentumCategory = .playfulness
    @State private var animatedTasks: Set<UUID> = []
    @State private var showPaywallLocal = false
    @State private var completedTitles: Set<String> = []

    private let allSparks: [Spark] = momentumDatabase
        .map { Spark(id: UUID(), title: $0.text, completed: false, category: $0.category) }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerSection
                chapterSelector.padding(.top, 16)
                taskList.padding(.top, 12)
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Momentum")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.pink)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.secondary)
                            .frame(width: 30, height: 30)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                }
            }
        }
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

    // MARK: - Header (progress bar only)
    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(Int(overallCompletionPercentage))% complete")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(completedCount) / \(totalCount) done")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 20)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray5))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [.pink, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geo.size.width * CGFloat(overallCompletionPercentage / 100),
                            height: 6
                        )
                }
            }
            .frame(height: 6)
            .padding(.horizontal, 20)
        }
        .padding(.top, 12)
        .padding(.bottom, 4)
    }

    // MARK: - Chapter Selector
    private var chapterSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(MomentumCategory.allCases, id: \.self) { chapter in
                    let isSelected = selectedChapter == chapter
                    let isLocked = !vm.isPremium && chapter != .playfulness
                    let progress = chapterProgress(chapter)
                    let colors = gradientColors(chapter)

                    Button {
                        if isLocked {
                            showPaywallLocal = true
                        } else {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                selectedChapter = chapter
                            }
                        }
                    } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                // Always show colored background circle for ALL chapters
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: colors,
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 52, height: 52)

                                // Progress ring (only for unlocked chapters)
                                if !isLocked {
                                    Circle()
                                        .trim(from: 0, to: progress)
                                        .stroke(
                                            LinearGradient(
                                                colors: [.white.opacity(0.9), .white],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            style: StrokeStyle(lineWidth: 3.5, lineCap: .round)
                                        )
                                        .frame(width: 52, height: 52)
                                        .rotationEffect(.degrees(-90))
                                }

                                // Icon in the center
                                if isLocked {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.white)
                                } else {
                                    Image(systemName: chapterIcon(chapter))
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                }
                            }

                            Text(chapterShortName(chapter))
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundStyle(isSelected ? .primary : .secondary)
                                .multilineTextAlignment(.center)
                                .frame(width: 68)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(isSelected ? Color(.systemGray6) : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(isSelected ? Color(.systemGray4) : Color.clear, lineWidth: 1.5)
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
        let sparks = allSparks.filter { $0.category == chapter }
        let completedInChapter = sparks.filter { isCompleted($0) }.count
        let colors = gradientColors(chapter)

        return ScrollView {
            VStack(spacing: 10) {

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(chapter.rawValue)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        Text("\(completedInChapter) of \(sparks.count) completed")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()

                    Image(systemName: chapterIcon(chapter))
                        .font(.system(size: 18))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 4)

                if isChapterLocked {
                    // Simple locked state - no teaser
                    VStack(spacing: 16) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        
                        Text("This chapter is locked")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                        
                        Text("Unlock Premium to access all chapters")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 80)
                } else {
                    ForEach(sparks) { spark in
                        taskRow(spark: spark, colors: colors)
                    }
                }

                Spacer(minLength: 40)
            }
            .padding(.top, 4)
        }
    }

    // MARK: - Task Row
    private func taskRow(spark: Spark, colors: [Color]) -> some View {
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
                        .stroke(Color(.systemGray4), lineWidth: 1.5)
                        .frame(width: 28, height: 28)

                    if completed {
                        Circle()
                            .fill(
                                LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .frame(width: 28, height: 28)

                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .scaleEffect(isAnimating ? 1.3 : 1.0)
                    }
                }

                Text(spark.title)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(completed ? .secondary : .primary)
                    .multilineTextAlignment(.leading)
                    .strikethrough(completed, color: .secondary)

                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(
                        completed ? Color(.systemGray5) : Color(.systemGray4),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
    }

    // MARK: - Helpers
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
        case .playfulness:       return "Play"
        case .emotionalDepth:    return "Depth"
        case .surpriseChemistry: return "Surprise"
        case .adventureMemory:   return "Adventure"
        case .legendaryPartner:  return "Legendary"
        }
    }

    private func chapterIcon(_ category: MomentumCategory) -> String {
        switch category {
        case .playfulness:       return "face.smiling.fill"
        case .emotionalDepth:    return "heart.text.square.fill"
        case .surpriseChemistry: return "sparkles"
        case .adventureMemory:   return "map.fill"
        case .legendaryPartner:  return "star.fill"
        }
    }

    private func gradientColors(_ category: MomentumCategory) -> [Color] {
        switch category {
        case .playfulness:       return [.pink, Color(red: 1, green: 0.4, blue: 0.6)]
        case .emotionalDepth:    return [.purple, .pink]
        case .surpriseChemistry: return [.pink, .red]
        case .adventureMemory:   return [.orange, .yellow]
        case .legendaryPartner:  return [Color(red: 0.9, green: 0.2, blue: 0.5), .purple]
        }
    }
}
