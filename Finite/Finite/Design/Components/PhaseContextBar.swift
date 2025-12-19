//
//  PhaseContextBar.swift
//  Finite
//
//  Tappable bar showing current phase info with edit affordance
//  Tap to edit current phase, or add if no phase exists
//

import SwiftUI

struct PhaseContextBar: View {
    let user: User
    let phases: [LifePhase]
    let highlightedPhase: LifePhase?  // Phase from spine long-press
    let onTap: (() -> Void)?          // Edit/add callback

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

    var body: some View {
        Group {
            if let phase = displayPhase {
                // Has a phase to display
                phaseButton(for: phase)
            } else if phases.isEmpty {
                // No phases at all - prompt to add
                emptyStateButton
            } else {
                // Has phases but not in one currently
                betweenPhasesView
            }
        }
        .animation(.easeOut(duration: 0.2), value: displayPhase?.id)
    }

    // MARK: - Phase Button (tappable)

    private func phaseButton(for phase: LifePhase) -> some View {
        Button {
            HapticService.shared.light()
            onTap?()
        } label: {
            HStack(spacing: 12) {
                // Color indicator
                Circle()
                    .fill(Color.fromHex(phase.colorHex))
                    .frame(width: 10, height: 10)

                // Phase info (use String() to avoid locale number formatting like "2,001")
                Text("\(phase.name) • \(String(phase.startYear))–\(String(phase.endYear)) • \(weeksInPhase(phase)) weeks")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.fromHex(phase.colorHex))

                Spacer()

                // Edit affordance
                if onTap != nil && highlightedPhase == nil {
                    Image(systemName: "pencil")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.textTertiary)
                        .padding(6)
                        .background(Circle().fill(Color.bgTertiary))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.bgSecondary.opacity(0.8))
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(onTap == nil)
    }

    // MARK: - Empty State (no phases)

    private var emptyStateButton: some View {
        Button {
            HapticService.shared.light()
            onTap?()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textTertiary)

                Text("Add a chapter for this period")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.textTertiary)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                    .foregroundStyle(Color.textTertiary.opacity(0.5))
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(onTap == nil)
    }

    // MARK: - Between Phases (has phases but not in one)

    private var betweenPhasesView: some View {
        Button {
            HapticService.shared.light()
            onTap?()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.textTertiary)

                Text("Between chapters")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.textTertiary)

                Spacer()

                if onTap != nil {
                    Text("Add")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.textSecondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule().fill(Color.bgTertiary)
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.bgSecondary.opacity(0.5))
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(onTap == nil)
    }
}

#Preview {
    let user = User(birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!)
    let phase = LifePhase(name: "Career", startYear: 2018, endYear: 2030, colorHex: "#059669")

    return VStack(spacing: 32) {
        // With phase (tappable)
        PhaseContextBar(user: user, phases: [phase], highlightedPhase: nil) {
            print("Edit current phase")
        }

        // Highlighted phase (from spine tap)
        PhaseContextBar(user: user, phases: [phase], highlightedPhase: phase) {
            print("Edit highlighted phase")
        }

        // Empty state
        PhaseContextBar(user: user, phases: [], highlightedPhase: nil) {
            print("Add first phase")
        }

        // Between phases
        let oldPhase = LifePhase(name: "School", startYear: 2000, endYear: 2010, colorHex: "#4F46E5")
        PhaseContextBar(user: user, phases: [oldPhase], highlightedPhase: nil) {
            print("Add phase for gap")
        }
    }
    .padding()
    .background(Color.bgPrimary)
}
