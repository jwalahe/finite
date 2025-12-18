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
    case swipeToQuality = 5     // Swipe to Quality view
    case markWeek = 6           // Long-press to mark a week (Quality view)
    case complete = 7

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .gridIntro: return "Your Life in Weeks"
        case .currentWeekIntro: return "You Are Here"
        case .swipeToChapters: return "Life Chapters"
        case .explainChapters: return "Color Your Past"
        case .addPhase: return "Add Your First Chapter"
        case .swipeToQuality: return "Rate Your Weeks"
        case .markWeek: return "Try It Now"
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
            return "Tap anywhere to add your first chapter."
        case .swipeToQuality:
            return "Swipe left once more to rate individual weeks."
        case .markWeek:
            return "Hold any filled week to rate it.\nA magnifier helps you find your spot."
        case .complete:
            return "Take your time. Reflect weekly.\nYour life is finite—make it count."
        }
    }

    var requiresUserAction: Bool {
        switch self {
        case .gridIntro, .currentWeekIntro, .explainChapters, .addPhase: return false  // Tap overlay
        case .swipeToChapters, .swipeToQuality, .markWeek: return true  // Grid handles action
        case .complete: return false  // Auto-dismiss
        }
    }

    var actionHint: String? {
        switch self {
        case .gridIntro: return "Tap to continue"
        case .currentWeekIntro: return "Tap to continue"
        case .swipeToChapters: return "Swipe left"
        case .explainChapters: return "Tap to continue"
        case .addPhase: return "Tap to add"
        case .swipeToQuality: return "Swipe left"
        case .markWeek: return "Hold any filled week"
        case .complete: return nil
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

            // Slight delay between steps for breathing room
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                withAnimation(.easeOut(duration: 0.3)) {
                    self?.currentStep = nextStep
                }
                HapticService.shared.light()
            }
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
