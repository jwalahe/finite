//
//  WalkthroughService.swift
//  Finite
//
//  State machine for the interactive guided walkthrough
//  Philosophy: Learn by doing, not reading
//

import SwiftUI
import Combine

// MARK: - Walkthrough Step

enum WalkthroughStep: Int, CaseIterable, Identifiable {
    case gridIntro = 0          // Explain the grid (Focus view)
    case currentWeekIntro = 1   // Point out the pulsing current week (Focus view)
    case swipeToChapters = 2    // Swipe to Chapters view
    case explainChapters = 3    // Explain chapters concept (Chapters view)
    case addPhase = 4           // Add first chapter (Chapters view)
    case tapSpine = 5           // Tap the spine to see phase details (Chapters view)
    case swipeToQuality = 6     // Swipe to Quality view
    case markWeek = 7           // Long-press to mark a week (Quality view)
    case swipeToHorizons = 8    // Swipe to Horizons view
    case explainHorizons = 9    // Explain horizons concept (Horizons view)
    case complete = 10

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .gridIntro: return "Your Life in Weeks"
        case .currentWeekIntro: return "You Are Here"
        case .swipeToChapters: return "Life Chapters"
        case .explainChapters: return "Color Your Past"
        case .addPhase: return "Add Your First Chapter"
        case .tapSpine: return "The Timeline"
        case .swipeToQuality: return "Rate Your Weeks"
        case .markWeek: return "Try It Now"
        case .swipeToHorizons: return "Your Horizons"
        case .explainHorizons: return "Plan Your Future"
        case .complete: return "You're Ready"
        }
    }

    var message: String {
        switch self {
        case .gridIntro:
            return "Each dot is one week of your life.\nThe filled ones are behind you."
        case .currentWeekIntro:
            return "The glowing dot is this week."
        case .swipeToChapters:
            return "Swipe left to add color to your life."
        case .explainChapters:
            return "Chapters are phases of your life—school, career, adventures."
        case .addPhase:
            return "Tap the + button to add your first chapter."
        case .tapSpine:
            return "Tap a chapter to see its details.\nDouble-tap to edit."
        case .swipeToQuality:
            return "Swipe left once more to rate individual weeks."
        case .markWeek:
            return "Hold any filled week to rate it.\nA magnifier helps you find your spot."
        case .swipeToHorizons:
            return "Swipe left to see your future."
        case .explainHorizons:
            return "Pin life goals to future weeks.\nSee exactly how many weeks until you get there."
        case .complete:
            return "Take your time. Reflect weekly.\nYour life is finite—make it count."
        }
    }

    var requiresUserAction: Bool {
        switch self {
        case .gridIntro, .currentWeekIntro, .explainChapters, .tapSpine, .explainHorizons: return false  // Tap overlay
        case .swipeToChapters, .addPhase, .swipeToQuality, .markWeek, .swipeToHorizons: return true  // Grid handles action
        case .complete: return false  // Auto-dismiss
        }
    }

    var actionHint: String? {
        switch self {
        case .gridIntro: return "Tap to continue"
        case .currentWeekIntro: return "Tap to continue"
        case .swipeToChapters: return "Swipe left"
        case .explainChapters: return "Tap to continue"
        case .addPhase: return "Tap the + button"
        case .tapSpine: return "Tap to continue"
        case .swipeToQuality: return "Swipe left"
        case .markWeek: return "Hold any filled week"
        case .swipeToHorizons: return "Swipe left"
        case .explainHorizons: return "Tap to continue"
        case .complete: return nil
        }
    }

    // MARK: - Allowed Gestures (for blocking unintended actions)

    /// Whether swipe gestures are allowed at this step
    var allowsSwipe: Bool {
        switch self {
        case .swipeToChapters, .swipeToQuality, .swipeToHorizons:
            return true
        case .complete:
            return true  // Allow all gestures during completion screen
        default:
            return false
        }
    }

    /// Whether long-press/loupe gestures are allowed at this step
    var allowsLongPress: Bool {
        switch self {
        case .markWeek:
            return true
        case .complete:
            return true  // Allow all gestures during completion screen
        default:
            return false
        }
    }

    /// Whether tapping on grid elements (weeks, milestones) is allowed
    var allowsGridTap: Bool {
        switch self {
        case .markWeek:
            return true  // Allow tapping weeks to rate
        case .complete:
            return true  // Allow all gestures during completion screen
        default:
            return false
        }
    }

    /// Whether the add button tap is allowed (phases/horizons)
    var allowsAddButton: Bool {
        switch self {
        case .addPhase:
            return true
        case .complete:
            return true  // Allow all gestures during completion screen
        default:
            return false
        }
    }
}

// MARK: - Walkthrough Service

@MainActor
final class WalkthroughService: ObservableObject {
    // MARK: - Singleton
    static let shared = WalkthroughService()

    // MARK: - Published State
    @Published var currentStep: WalkthroughStep?
    @Published var isActive: Bool = false

    // MARK: - Frame References (set by GridView)
    @Published var gridFrame: CGRect = .zero
    @Published var currentWeekFrame: CGRect = .zero
    @Published var dotIndicatorFrame: CGRect = .zero
    @Published var spineFrame: CGRect = .zero
    @Published var addPhaseButtonFrame: CGRect = .zero

    // MARK: - Persistence
    @AppStorage("hasCompletedWalkthrough") private var hasCompleted: Bool = false
    @AppStorage("walkthroughSkipped") private var wasSkipped: Bool = false

    // MARK: - Computed

    var shouldShow: Bool {
        !hasCompleted && !wasSkipped
    }

    var canSkip: Bool {
        currentStep != .complete
    }

    var progress: Double {
        guard let step = currentStep else { return 0 }
        return Double(step.rawValue) / Double(WalkthroughStep.allCases.count - 1)
    }

    // MARK: - Gesture Blocking Helpers

    /// Check if swipe gestures should be allowed (false blocks the gesture)
    var allowsSwipe: Bool {
        guard isActive, let step = currentStep else { return true }
        return step.allowsSwipe
    }

    /// Check if long-press/loupe gestures should be allowed
    var allowsLongPress: Bool {
        guard isActive, let step = currentStep else { return true }
        return step.allowsLongPress
    }

    /// Check if grid taps (week selection) should be allowed
    var allowsGridTap: Bool {
        guard isActive, let step = currentStep else { return true }
        return step.allowsGridTap
    }

    /// Check if add button taps should be allowed
    var allowsAddButton: Bool {
        guard isActive, let step = currentStep else { return true }
        return step.allowsAddButton
    }

    // MARK: - Init

    private init() {}

    // MARK: - Lifecycle

    func startIfNeeded() {
        guard shouldShow else { return }

        // Delay start to let Reveal animation complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            self.isActive = true
            self.currentStep = .gridIntro
            HapticService.shared.light()
        }
    }

    func advance() {
        guard let current = currentStep else { return }

        // Find next step
        guard let currentIndex = WalkthroughStep.allCases.firstIndex(of: current) else { return }
        let nextIndex = WalkthroughStep.allCases.index(after: currentIndex)

        if nextIndex < WalkthroughStep.allCases.endIndex {
            let nextStep = WalkthroughStep.allCases[nextIndex]

            // Animate step change immediately (no delay to prevent gesture blocking)
            withAnimation(.easeOut(duration: 0.3)) {
                currentStep = nextStep
            }
            HapticService.shared.light()
        } else {
            complete()
        }
    }

    func skip() {
        wasSkipped = true
        isActive = false
        currentStep = nil
        HapticService.shared.medium()
    }

    func complete() {
        hasCompleted = true

        // Show completion state briefly
        withAnimation(.easeOut(duration: 0.3)) {
            currentStep = .complete
        }

        // Auto-dismiss after 2.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            withAnimation(.easeOut(duration: 0.5)) {
                self?.isActive = false
                self?.currentStep = nil
            }
            HapticService.shared.success()
        }
    }

    func reset() {
        // For testing: reset walkthrough state
        hasCompleted = false
        wasSkipped = false
        currentStep = nil
        isActive = false
    }

    // MARK: - Action Detection

    func handleViewModeChanged(to mode: ViewMode) {
        // Advance when user reaches the expected view
        if currentStep == .swipeToChapters && mode == .chapters {
            advance()
        } else if currentStep == .swipeToQuality && mode == .quality {
            advance()
        } else if currentStep == .swipeToHorizons && mode == .horizons {
            advance()
        }
    }

    func handlePhaseAdded() {
        if currentStep == .addPhase {
            advance()
        }
    }

    func handlePhaseSkipped() {
        if currentStep == .addPhase {
            advance()
        }
    }

    func handleWeekMarked() {
        if currentStep == .markWeek {
            advance()
        }
    }
}
