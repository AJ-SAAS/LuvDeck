// SparkViewModel.swift
import Foundation
import SwiftUI
import UIKit

@MainActor
class SparkViewModel: ObservableObject {
    @Published var showingSheet = false
    @Published var selectedItem: SparkItem?

    // Soft paywall state
    @Published var showPaywall = false

    // Daily tap limit
    private let freeTapLimit = 5

    // Persisted daily tap state using @AppStorage
    @AppStorage("luvdeck_sparkTapCount") private var storedTapCount: Int = 0
    @AppStorage("luvdeck_lastReset") private var storedLastReset: Double = 0 // store startOfDay.timeIntervalSince1970

    // Global premium flag (can be updated from PurchaseViewModel)
    @AppStorage("luvdeck_isPremium") var isPremium: Bool = false

    private let allItems = sparkDatabase

    init() {
        ensureDailyResetIfNeeded()
    }

    // MARK: - Public helpers

    /// Number of taps consumed today (backed by AppStorage)
    var tapCount: Int {
        storedTapCount
    }

    /// Taps remaining today (0...freeTapLimit)
    var tapsRemaining: Int {
        max(0, freeTapLimit - storedTapCount)
    }

    /// Reset daily counters if a new day started
    private func ensureDailyResetIfNeeded() {
        let todayStart = Calendar.current.startOfDay(for: Date())
        let savedDate = Date(timeIntervalSince1970: storedLastReset)
        if !Calendar.current.isDate(savedDate, inSameDayAs: todayStart) {
            // reset for new day
            storedTapCount = 0
            storedLastReset = todayStart.timeIntervalSince1970
        }
    }

    // Call this to set premium from outside (e.g., when PurchaseViewModel changes)
    func setPremium(_ premium: Bool) {
        isPremium = premium
    }

    // MARK: - Haptic
    func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    // MARK: - Main action
    func showRandom(_ category: SparkCategory) {
        // ensure reset if needed (in case app was backgrounded)
        ensureDailyResetIfNeeded()

        // always give haptic feedback
        triggerHaptic()

        // If premium, bypass counters
        if isPremium {
            presentRandom(for: category)
            return
        }

        // If reached limit, show paywall
        if storedTapCount >= freeTapLimit {
            // show paywall
            showPaywall = true
            return
        }

        // consume one tap and persist
        storedTapCount += 1
        // present content
        presentRandom(for: category)

        // If we just used the last tap, also show paywall afterward (optional UX)
        if storedTapCount >= freeTapLimit {
            // small delay before showing paywall so user sees the last spark
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showPaywall = true
            }
        }
    }

    // Extracted to keep flow clear
    private func presentRandom(for category: SparkCategory) {
        let filtered = allItems.filter { $0.category == category }
        selectedItem = filtered.randomElement()
        showingSheet = true
    }
}
