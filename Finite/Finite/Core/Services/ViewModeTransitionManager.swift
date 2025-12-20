//
//  ViewModeTransitionManager.swift
//  Finite
//
//  Orchestrates signature view mode transitions
//  SST Section 7.1: "Switching views isn't a filter change — it's a recontextualization"
//

import SwiftUI

/// Manages the multi-stage view mode transitions
/// Each transition is a choreographed sequence per SST specifications
@MainActor
class ViewModeTransitionManager: ObservableObject {

    // MARK: - Published State

    /// Current transition phase (nil when no transition in progress)
    @Published private(set) var currentPhase: TransitionPhase?

    /// Progress of color bloom animation (0.0 to 1.0)
    @Published var bloomProgress: CGFloat = 0.0

    /// Week number from which bloom radiates (usually current week)
    @Published var bloomOriginWeek: Int = 0

    /// Desaturation amount for transition (0.0 = full color, 1.0 = grayscale)
    @Published var desaturation: CGFloat = 0.0

    /// Screen dim overlay opacity (for Focus mode entry)
    @Published var dimOverlay: CGFloat = 0.0

    /// Whether a transition is currently running
    var isTransitioning: Bool { currentPhase != nil }

    // MARK: - Transition Phases

    enum TransitionPhase {
        case pause           // Initial pause before transition
        case desaturate      // Colors fade to grayscale
        case stillness       // Beat of stillness between desaturate and bloom
        case bloom           // New colors bloom outward from current week
        case drain           // Colors drain toward edges (for Focus entry)
        case dim             // Screen dims (Focus mode)
        case sequencePulse   // Markers pulse in sequence (Horizons entry)
        case complete        // Transition finishing
    }

    // MARK: - Timing Constants (from SST 7.1)

    private enum Timing {
        static let pauseDuration: Double = 0.05        // 50ms initial pause
        static let desaturateDuration: Double = 0.15  // 150ms desaturation
        static let stillnessDuration: Double = 0.10   // 100ms beat
        static let bloomDuration: Double = 0.30       // 300ms spring bloom
        static let drainDuration: Double = 0.20       // 200ms color drain
        static let dimDuration: Double = 0.20         // 200ms dim
        static let sequencePulseInterval: Double = 0.05 // 50ms per marker
    }

    // MARK: - Public Methods

    /// Execute transition between view modes
    /// Returns immediately; animation happens asynchronously
    func transition(from: ViewMode, to: ViewMode, currentWeek: Int, completion: @escaping () -> Void) {
        // Set bloom origin to current week
        bloomOriginWeek = currentWeek

        // Choose transition sequence based on mode pair
        switch (from, to) {
        case (.chapters, .quality), (.quality, .chapters):
            executeBloomTransition(completion: completion)

        case (.chapters, .focus), (.quality, .focus):
            executeFocusEntryTransition(completion: completion)

        case (.focus, .chapters), (.focus, .quality):
            executeFocusExitTransition(completion: completion)

        case (.focus, .horizons), (.horizons, .focus):
            executeHorizonTransition(isEntering: to == .horizons, completion: completion)

        case (.chapters, .horizons), (.horizons, .chapters):
            executeHorizonTransition(isEntering: to == .horizons, completion: completion)

        case (.quality, .horizons), (.horizons, .quality):
            executeHorizonTransition(isEntering: to == .horizons, completion: completion)

        default:
            // Same mode or unhandled - just complete
            completion()
        }
    }

    /// Reset all transition state
    func reset() {
        currentPhase = nil
        bloomProgress = 0.0
        desaturation = 0.0
        dimOverlay = 0.0
    }

    // MARK: - Transition Sequences

    /// Chapters ↔ Quality: Desaturate, pause, bloom from current week
    private func executeBloomTransition(completion: @escaping () -> Void) {
        Task { @MainActor in
            // Phase 1: Pause
            currentPhase = .pause
            try? await Task.sleep(for: .seconds(Timing.pauseDuration))

            // Phase 2: Desaturate
            currentPhase = .desaturate
            withAnimation(.easeOut(duration: Timing.desaturateDuration)) {
                desaturation = 1.0
            }
            try? await Task.sleep(for: .seconds(Timing.desaturateDuration))

            // Phase 3: Stillness
            currentPhase = .stillness
            try? await Task.sleep(for: .seconds(Timing.stillnessDuration))

            // Phase 4: Bloom (spring animation)
            currentPhase = .bloom
            HapticService.shared.light()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                bloomProgress = 1.0
                desaturation = 0.0
            }
            try? await Task.sleep(for: .seconds(Timing.bloomDuration))

            // Complete
            currentPhase = .complete
            reset()
            completion()
        }
    }

    /// Entry to Focus: Colors drain, screen dims
    /// Note: Does NOT reset dimOverlay - Focus mode keeps the dim while active
    private func executeFocusEntryTransition(completion: @escaping () -> Void) {
        Task { @MainActor in
            // Phase 1: Drain colors toward edges
            currentPhase = .drain
            withAnimation(.easeOut(duration: Timing.drainDuration)) {
                desaturation = 1.0
            }
            try? await Task.sleep(for: .seconds(Timing.drainDuration))

            // Phase 2: Dim screen (stays dimmed while in Focus mode)
            currentPhase = .dim
            HapticService.shared.heavy()
            withAnimation(.easeInOut(duration: Timing.dimDuration)) {
                dimOverlay = 0.10  // 10% darker per SST
            }
            try? await Task.sleep(for: .seconds(Timing.dimDuration))

            // Complete - but keep dimOverlay active for Focus mode
            currentPhase = nil
            bloomProgress = 0.0
            desaturation = 0.0
            // dimOverlay stays at 0.10
            completion()
        }
    }

    /// Exit from Focus: Reverse of entry
    private func executeFocusExitTransition(completion: @escaping () -> Void) {
        Task { @MainActor in
            // Brighten (remove Focus dim)
            currentPhase = .dim
            withAnimation(.easeOut(duration: Timing.dimDuration)) {
                dimOverlay = 0.0
            }
            try? await Task.sleep(for: .seconds(Timing.dimDuration))

            // Restore colors
            currentPhase = .bloom
            HapticService.shared.light()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                desaturation = 0.0
                bloomProgress = 1.0
            }
            try? await Task.sleep(for: .seconds(Timing.bloomDuration))

            // Complete
            currentPhase = nil
            bloomProgress = 0.0
            completion()
        }
    }

    /// Horizons entry/exit: Sequential marker pulses
    private func executeHorizonTransition(isEntering: Bool, completion: @escaping () -> Void) {
        Task { @MainActor in
            if isEntering {
                // Entering Horizons: dim past, then pulse markers
                currentPhase = .dim
                withAnimation(.easeOut(duration: 0.25)) {
                    // Past weeks will be dimmed in GridView based on mode
                }
                try? await Task.sleep(for: .seconds(0.25))

                // Sequential haptics for "ascending sequence of 3 soft taps"
                currentPhase = .sequencePulse
                for _ in 0..<3 {
                    HapticService.shared.selection()
                    try? await Task.sleep(for: .seconds(0.1))
                }
            } else {
                // Exiting Horizons: simple fade
                currentPhase = .bloom
                HapticService.shared.light()
                withAnimation(.easeOut(duration: 0.25)) {
                    bloomProgress = 1.0
                }
                try? await Task.sleep(for: .seconds(0.25))
            }

            // Complete
            currentPhase = .complete
            reset()
            completion()
        }
    }

    // MARK: - Bloom Calculation Helper

    /// Calculate if a week should be colored based on bloom progress
    /// Returns 1.0 if fully colored, 0.0 if still grayscale, or intermediate value
    func bloomMultiplier(for weekNumber: Int, totalWeeks: Int, weeksPerRow: Int) -> CGFloat {
        guard bloomProgress > 0, bloomProgress < 1 else {
            return bloomProgress > 0.5 ? 1.0 : 0.0
        }

        // Calculate distance from bloom origin (in grid cells)
        let originRow = (bloomOriginWeek - 1) / weeksPerRow
        let originCol = (bloomOriginWeek - 1) % weeksPerRow
        let weekRow = (weekNumber - 1) / weeksPerRow
        let weekCol = (weekNumber - 1) % weeksPerRow

        let rowDist = abs(weekRow - originRow)
        let colDist = abs(weekCol - originCol)
        let distance = sqrt(CGFloat(rowDist * rowDist + colDist * colDist))

        // Normalize distance (max possible is roughly diagonal of grid)
        let maxDistance = sqrt(CGFloat(totalWeeks / weeksPerRow * totalWeeks / weeksPerRow + weeksPerRow * weeksPerRow))
        let normalizedDistance = distance / maxDistance

        // Compare to bloom progress
        // Week colors when bloom wave reaches it
        let threshold = bloomProgress * 1.2  // Slight overreach for smoother effect
        if normalizedDistance <= threshold {
            // Smooth transition at wave edge
            let edgeWidth: CGFloat = 0.15
            let edgeProgress = (threshold - normalizedDistance) / edgeWidth
            return min(1.0, edgeProgress)
        }

        return 0.0
    }
}
