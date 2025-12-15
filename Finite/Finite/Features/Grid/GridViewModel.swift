//
//  GridViewModel.swift
//  Finite
//
//  Created by Jwala Kompalli on 12/15/25.
//

import Foundation
import SwiftUI

@Observable
final class GridViewModel {
    let user: User

    // Reveal animation state
    var revealedWeekCount: Int = 0
    var isRevealing: Bool = false
    var hasRevealCompleted: Bool = false

    // Grid configuration
    let weeksPerRow: Int = 52  // One year per row

    init(user: User, shouldReveal: Bool = false) {
        self.user = user

        if !shouldReveal {
            // Skip animation, show all lived weeks immediately
            self.revealedWeekCount = user.weeksLived
            self.hasRevealCompleted = true
        }
    }

    var totalRows: Int {
        return user.lifeExpectancy  // 80 rows for 80 years
    }

    var totalWeeks: Int {
        return user.totalWeeks
    }

    var currentWeekNumber: Int {
        return user.currentWeekNumber
    }

    func isWeekLived(_ weekNumber: Int) -> Bool {
        return weekNumber <= user.weeksLived
    }

    func isCurrentWeek(_ weekNumber: Int) -> Bool {
        return weekNumber == user.currentWeekNumber
    }

    func isWeekRevealed(_ weekNumber: Int) -> Bool {
        return weekNumber <= revealedWeekCount
    }

    // MARK: - Reveal Animation

    func startReveal() {
        guard !isRevealing && !hasRevealCompleted else { return }

        isRevealing = true
        revealedWeekCount = 0

        let weeksToReveal = user.weeksLived

        Task { @MainActor in
            // Brief initial pause
            try? await Task.sleep(nanoseconds: 200_000_000) // 200ms

            // Animation: exactly 1.5 seconds, 50 steps
            let steps = 50
            let stepDurationNs: UInt64 = 30_000_000 // 30ms per step = 1.5 sec total

            var yearsPassed = 0

            for step in 1...steps {
                // Linear interpolation: what week should we be at for this step?
                let progress = Double(step) / Double(steps)
                let targetWeek = Int(Double(weeksToReveal) * progress)
                revealedWeekCount = targetWeek

                // Haptic at year boundaries
                let currentYear = targetWeek / 52
                if currentYear > yearsPassed {
                    yearsPassed = currentYear
                    HapticService.shared.light()
                }

                try? await Task.sleep(nanoseconds: stepDurationNs)
            }

            // Ensure final state
            revealedWeekCount = weeksToReveal

            // Final haptic
            HapticService.shared.heavy()

            isRevealing = false
            hasRevealCompleted = true
        }
    }
}
