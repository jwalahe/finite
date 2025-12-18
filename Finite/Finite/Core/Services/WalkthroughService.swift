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
    case gridIntro = 0
    case currentWeek = 1
    case viewModesIntro = 2
    case chaptersExplanation = 3
    case addPhase = 4
    case markWeek = 5
    case complete = 6

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .gridIntro: return "Your Life in Weeks"
        case .currentWeek: return "You Are Here"
        case .viewModesIntro: return "Three Perspectives"
        case .chaptersExplanation: return "Life Chapters"
        case .addPhase: return "Add Your First Chapter"
        case .markWeek: return "Reflect on a Week"
        case .complete: return "You're Ready"
        }
    }

    var message: String {
        switch self {
        case .gridIntro:
            return "Each dot is one week of your life.\nThe filled ones are behind you."
        case .currentWeek:
            return "This glowing dot is today.\nTap it."
        case .viewModesIntro:
            return "See your life through different lenses.\nSwipe left to try."
        case .chaptersExplanation:
            return "Color your past by adding life chapters—school, career, adventures."
        case .addPhase:
            return "Let's add your first chapter."
        case .markWeek:
            return "Long-press any past week to record how it felt."
        case .complete:
            return "Take your time. Reflect weekly.\nYour life is finite—make it count."
        }
    }

    var requiresUserAction: Bool {
        switch self {
        case .gridIntro, .chaptersExplanation: return false  // Tap anywhere
        case .currentWeek, .viewModesIntro, .addPhase, .markWeek: return true  // Specific action
        case .complete: return false  // Auto-dismiss
        }
    }

    var actionHint: String? {
        switch self {
        case .gridIntro: return "Tap anywhere to continue"
        case .currentWeek: return "Tap the glowing week"
        case .viewModesIntro: return "Swipe left on the grid"
        case .chaptersExplanation: return "Tap to continue"
        case .addPhase: return nil  // Modal handles this
        case .markWeek: return "Long-press any filled week"
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
    @Published var showCelebration: Bool = false

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

        // Show celebration for action-based steps
        if current.requiresUserAction {
            triggerCelebration()
        }

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

    func handleCurrentWeekTapped() {
        if currentStep == .currentWeek {
            advance()
        }
    }

    func handleViewModeChanged(to mode: ViewMode) {
        if currentStep == .viewModesIntro && mode == .chapters {
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

    // MARK: - Private

    private func triggerCelebration() {
        showCelebration = true
        HapticService.shared.success()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.showCelebration = false
        }
    }
}
