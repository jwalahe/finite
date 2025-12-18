//
//  GhostPhase.swift
//  Finite
//
//  Phase info at 8% opacity, summoned when spine is tapped
//  Mirrors GhostNumber's calm, intentional reveal pattern
//
//  Philosophy: Information appears only when sought, then gracefully recedes
//

import SwiftUI

struct GhostPhase: View {
    let user: User
    let phases: [LifePhase]

    // Externally controlled - summoned by spine tap
    @Binding var summonedPhase: LifePhase?

    // CRAFT_SPEC: 8% opacity default, summon brings to 100%
    @State private var contentOpacity: Double = 0.08
    @State private var dismissTask: Task<Void, Never>?

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

    // Which phase to display
    private var displayPhase: LifePhase? {
        summonedPhase ?? currentPhase
    }

    // Calculate weeks spent in the phase
    private func weeksInPhase(_ phase: LifePhase) -> Int {
        let birthYear = user.birthYear
        let startWeek = phase.startWeek(birthYear: birthYear)
        let endWeek = phase.endWeek(birthYear: birthYear)
        let currentWeek = user.currentWeekNumber
        let effectiveEnd = min(endWeek, currentWeek)
        return max(0, effectiveEnd - startWeek + 1)
    }

    var body: some View {
        VStack(spacing: 4) {
            if let phase = displayPhase {
                // Phase name - large, prominent
                Text(phase.name)
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.fromHex(phase.colorHex).opacity(contentOpacity))

                // Years and weeks - subtle detail (use String to avoid comma formatting)
                Text("\(String(phase.startYear))–\(String(phase.endYear)) · \(weeksInPhase(phase)) weeks")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.textSecondary.opacity(contentOpacity))
            } else if phases.isEmpty {
                // No phases yet - ghost hint
                Text("Add chapters")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.textTertiary.opacity(contentOpacity))
            } else {
                // Between phases
                Text("Between chapters")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.textTertiary.opacity(contentOpacity))
            }
        }
        .onChange(of: summonedPhase) { oldValue, newValue in
            if newValue != nil {
                summonPhase()
            }
        }
        .onDisappear {
            dismissTask?.cancel()
            contentOpacity = 0.08
        }
    }

    // Summon animation - mirrors GhostNumber
    private func summonPhase() {
        dismissTask?.cancel()

        // Rise to full opacity
        withAnimation(.easeOut(duration: 0.2)) {
            contentOpacity = 1.0
        }

        // Auto-fade after 2.5 seconds
        dismissTask = Task {
            try? await Task.sleep(nanoseconds: 2_500_000_000)

            guard !Task.isCancelled else { return }

            await MainActor.run {
                withAnimation(.easeOut(duration: 0.3)) {
                    contentOpacity = 0.08
                    summonedPhase = nil
                }
            }
        }
    }
}

#Preview {
    let user = User(birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!)
    let phase = LifePhase(name: "Career", startYear: 2018, endYear: 2030, colorHex: "#059669")

    return ZStack {
        Color.bgPrimary
            .ignoresSafeArea()

        VStack {
            Text("Tap spine to summon phase info")
                .foregroundStyle(Color.textSecondary)

            Spacer()

            GhostPhase(
                user: user,
                phases: [phase],
                summonedPhase: .constant(phase)
            )

            Spacer()
        }
    }
}
