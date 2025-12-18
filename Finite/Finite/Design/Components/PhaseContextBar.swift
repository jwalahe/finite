//
//  PhaseContextBar.swift
//  Finite
//
//  Simple text label showing phase info with weeks count
//  Shows tapped phase when spine is tapped, otherwise shows current phase
//

import SwiftUI

struct PhaseContextBar: View {
    let user: User
    let phases: [LifePhase]
    let highlightedPhase: LifePhase?  // Phase from spine tap

    // Current phase (where user is now)
    private var currentPhase: LifePhase? {
        let birthYear = user.birthYear
        let currentWeek = user.currentWeekNumber

        return phases.first { phase in
            let start = phase.startWeek(birthYear: birthYear)
            let end = phase.endWeek(birthYear: birthYear)
            return currentWeek >= start && currentWeek <= end
        }
    }

    // Which phase to display - highlighted takes priority
    private var displayPhase: LifePhase? {
        highlightedPhase ?? currentPhase
    }

    // Calculate weeks spent in the phase (capped at current week if ongoing)
    private func weeksInPhase(_ phase: LifePhase) -> Int {
        let birthYear = user.birthYear
        let startWeek = phase.startWeek(birthYear: birthYear)
        let endWeek = phase.endWeek(birthYear: birthYear)
        let currentWeek = user.currentWeekNumber

        // If phase ends before current week, count all weeks in phase
        // Otherwise count up to current week
        let effectiveEnd = min(endWeek, currentWeek)
        return max(0, effectiveEnd - startWeek + 1)
    }

    // Format: "Phase Name • 2014–2018 • 208 weeks"
    private var phaseText: String? {
        guard let phase = displayPhase else { return nil }
        let weeks = weeksInPhase(phase)
        return "\(phase.name) • \(phase.startYear)–\(phase.endYear) • \(weeks) weeks"
    }

    var body: some View {
        Group {
            if let text = phaseText, let phase = displayPhase {
                Text(text)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.fromHex(phase.colorHex))
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else if phases.isEmpty {
                Text("Tap + to add chapters")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.textTertiary)
            } else {
                // Has phases but not currently in one
                Text("Between chapters")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.textTertiary)
            }
        }
        .animation(.easeOut(duration: 0.2), value: displayPhase?.id)
    }
}

#Preview {
    let user = User(birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!)
    let phase = LifePhase(name: "Career", startYear: 2018, endYear: 2030, colorHex: "#059669")

    return VStack(spacing: 32) {
        PhaseContextBar(user: user, phases: [phase], highlightedPhase: nil)

        PhaseContextBar(user: user, phases: [phase], highlightedPhase: phase)

        PhaseContextBar(user: user, phases: [], highlightedPhase: nil)
    }
    .padding()
    .background(Color.bgPrimary)
}
