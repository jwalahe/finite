//
//  ShareFlowController.swift
//  Finite
//
//  Central state machine for moment-based sharing
//  SST §19: Share triggers appear AFTER emotional peaks
//  Philosophy: "Sharing was treated as a feature to access, not a moment to experience"
//

import SwiftUI
import Combine

// MARK: - Share Sheet Types

enum ShareSheetType: Identifiable, Equatable {
    case firstWeek                    // After first rating
    case achievement(Milestone)       // After milestone completion
    case ghostReveal                  // First Ghost Number tap
    case yearTransition(Int)          // Birthday week (age)
    case quickShare                   // Long-press current week (secondary)

    var id: String {
        switch self {
        case .firstWeek:
            return "firstWeek"
        case .achievement(let milestone):
            return "achievement-\(milestone.id)"
        case .ghostReveal:
            return "ghostReveal"
        case .yearTransition(let age):
            return "yearTransition-\(age)"
        case .quickShare:
            return "quickShare"
        }
    }

    static func == (lhs: ShareSheetType, rhs: ShareSheetType) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Share Card Types

enum ShareCardType: String {
    case perspective    // Week + Position + Quote
    case achievement    // Milestone + Journey
    case yearTransition // Birthday week
    case wrapped        // Annual summary (Phase 6)
}

// MARK: - Share Flow Controller

@MainActor
final class ShareFlowController: ObservableObject {
    static let shared = ShareFlowController()

    // MARK: - Published State

    @Published var activeSheet: ShareSheetType?
    @Published var pendingMilestone: Milestone?

    // MARK: - UserDefaults Keys

    private enum Keys {
        static let hasShownFirstWeekPrompt = "finite.share.hasShownFirstWeekPrompt"
        static let hasShownGhostPrompt = "finite.share.hasShownGhostPrompt"
        static let lastBirthdayYearShown = "finite.share.lastBirthdayYearShown"
        static let totalSharesCompleted = "finite.share.totalSharesCompleted"
    }

    // MARK: - State Flags

    var hasShownFirstWeekPrompt: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.hasShownFirstWeekPrompt) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.hasShownFirstWeekPrompt) }
    }

    var hasShownGhostPrompt: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.hasShownGhostPrompt) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.hasShownGhostPrompt) }
    }

    var lastBirthdayYearShown: Int {
        get { UserDefaults.standard.integer(forKey: Keys.lastBirthdayYearShown) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.lastBirthdayYearShown) }
    }

    var totalSharesCompleted: Int {
        get { UserDefaults.standard.integer(forKey: Keys.totalSharesCompleted) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.totalSharesCompleted) }
    }

    // MARK: - Initialization

    private init() {}

    // MARK: - Trigger A: First Week Celebration

    /// Called after user completes their FIRST week rating ever
    /// SST §18.2: "Fresh Start Effect. Beginning = share trigger."
    func onFirstWeekRated() {
        guard !hasShownFirstWeekPrompt else { return }

        // SST: 1.5s delay to let moment land
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)

            await MainActor.run {
                self.hasShownFirstWeekPrompt = true
                self.activeSheet = .firstWeek
                HapticService.shared.light()
            }
        }
    }

    // MARK: - Trigger B: Milestone Completed

    /// Called after user marks any milestone as complete
    /// SST §18.3: "Achievement = natural share trigger"
    func onMilestoneCompleted(_ milestone: Milestone) {
        pendingMilestone = milestone

        // SST: 1.5s delay after completion animation
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)

            await MainActor.run {
                self.activeSheet = .achievement(milestone)
                HapticService.shared.light()
            }
        }
    }

    // MARK: - Trigger C: Ghost Number Reveal (First Time)

    /// Called after user taps Ghost Number for the first time
    /// SST §18.4: "Mortality salience at peak. Powerful share moment."
    func onGhostNumberRevealed() {
        guard !hasShownGhostPrompt else { return }

        // SST: 2.5s delay (after ghost fades back to 8%)
        Task {
            try? await Task.sleep(nanoseconds: 2_500_000_000)

            await MainActor.run {
                self.hasShownGhostPrompt = true
                self.activeSheet = .ghostReveal
                HapticService.shared.light()
            }
        }
    }

    // MARK: - Trigger D: Birthday Week

    /// Called when user opens app during their birthday week
    /// SST §18.5: "Temporal landmark. Birthday = natural reflection/share moment."
    func onBirthdayWeekDetected(age: Int) {
        guard lastBirthdayYearShown != age else { return }

        // SST: 1s delay after grid loads
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000)

            await MainActor.run {
                self.lastBirthdayYearShown = age
                self.activeSheet = .yearTransition(age)
                HapticService.shared.light()
            }
        }
    }

    // MARK: - Trigger E: Long-Press Current Week (Secondary)

    /// Called when user long-presses current week
    /// SST §18.6: "Preserved but de-prioritized. For power users."
    func onLongPressCurrentWeek() {
        HapticService.shared.medium()
        activeSheet = .quickShare
    }

    // MARK: - Birthday Week Detection

    /// Check if current week is user's birthday week
    /// SST §18.5 Detection logic
    static func isBirthdayWeek(birthDate: Date, currentWeekNumber: Int) -> Bool {
        let calendar = Calendar.current
        let birthWeekOfYear = calendar.component(.weekOfYear, from: birthDate)
        let currentWeekOfYear = currentWeekNumber % 52

        // Handle week 0 edge case
        let normalizedCurrentWeek = currentWeekOfYear == 0 ? 52 : currentWeekOfYear

        return birthWeekOfYear == normalizedCurrentWeek
    }

    /// Get user's current age (for year transition cards)
    static func currentAge(birthDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: birthDate, to: Date())
        return components.year ?? 0
    }

    // MARK: - Share Completion

    /// Called when user successfully shares (after native share sheet completes)
    func onShareCompleted(type: ShareCardType) {
        totalSharesCompleted += 1

        // Could add analytics here in the future
        // recordShareEvent(type: type)
    }

    // MARK: - Dismiss

    /// Dismiss current share sheet
    func dismiss() {
        activeSheet = nil
        pendingMilestone = nil
    }

    // MARK: - Reset (for testing)

    #if DEBUG
    func resetAllFlags() {
        hasShownFirstWeekPrompt = false
        hasShownGhostPrompt = false
        lastBirthdayYearShown = 0
        totalSharesCompleted = 0
        activeSheet = nil
        pendingMilestone = nil
    }
    #endif
}

// MARK: - Default Perspective Quotes

/// SST §17.6: "Transforms data-sharing into identity-expression"
enum PerspectiveQuotes {
    static let defaults: [String] = [
        "I'm learning to pay attention to my time.",
        "Every week is a decision.",
        "This is week one of the rest of my life.",
        "Mortality makes meaning.",
        "I'm not running out of time. I'm running in time.",
        "The future is a blank page I get to write.",
        "Time is the only thing I can't get back."
    ]

    static var random: String {
        defaults.randomElement() ?? defaults[0]
    }
}
