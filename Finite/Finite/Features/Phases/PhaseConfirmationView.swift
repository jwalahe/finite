//
//  PhaseConfirmationView.swift
//  Finite
//
//  Confirmation screen shown after adding a phase
//  CRAFT_SPEC: Timeline visualization with gap indicators
//

import SwiftUI
import SwiftData

struct PhaseConfirmationView: View {
    @Environment(\.dismiss) private var dismiss

    let user: User
    let addedPhase: LifePhase
    let allPhases: [LifePhase]
    let onAddAnother: () -> Void
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Success indicator
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.fromHex(addedPhase.colorHex))

                Text("Added \"\(addedPhase.name)\"")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.textPrimary)

                Text("\(addedPhase.startYear) – \(addedPhase.endYear)")
                    .font(.body)
                    .foregroundStyle(Color.textSecondary)
            }

            // Timeline visualization
            PhaseTimelineBar(
                user: user,
                phases: allPhases,
                highlightedPhase: addedPhase
            )
            .padding(.horizontal, 24)

            // Gap context
            gapContextText
                .font(.body)
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Spacer()

            // Action buttons
            VStack(spacing: 12) {
                Button {
                    HapticService.shared.light()
                    onAddAnother()
                } label: {
                    Text("Add another")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.bgPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.textPrimary)
                        .cornerRadius(12)
                }
                .buttonStyle(ScaleButtonStyle())

                Button {
                    HapticService.shared.light()
                    onDone()
                } label: {
                    Text("Done for now")
                        .font(.body)
                        .foregroundStyle(Color.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color.bgPrimary)
    }

    private var gapContextText: Text {
        let birthYear = user.birthYear
        let currentYear = user.currentYear

        // Calculate years before first phase
        let sortedPhases = allPhases.sorted { $0.startYear < $1.startYear }
        let firstPhaseStart = sortedPhases.first?.startYear ?? currentYear
        let yearsBefore = max(0, firstPhaseStart - birthYear)

        // Calculate years after last phase
        let lastPhaseEnd = sortedPhases.last?.endYear ?? birthYear
        let yearsAfter = max(0, currentYear - lastPhaseEnd)

        var parts: [String] = []
        if yearsBefore > 0 {
            parts.append("\(yearsBefore) year\(yearsBefore == 1 ? "" : "s") before")
        }
        if yearsAfter > 0 {
            parts.append("\(yearsAfter) year\(yearsAfter == 1 ? "" : "s") after")
        }

        if parts.isEmpty {
            return Text("Your life is fully covered!")
        } else {
            return Text(parts.joined(separator: ". ") + ".")
        }
    }
}

// MARK: - Phase Timeline Bar

struct PhaseTimelineBar: View {
    let user: User
    let phases: [LifePhase]
    let highlightedPhase: LifePhase?

    private let barHeight: CGFloat = 8

    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geo in
                let totalYears = user.currentYear - user.birthYear
                guard totalYears > 0 else { return AnyView(EmptyView()) }

                let yearWidth = geo.size.width / CGFloat(totalYears)

                return AnyView(
                    ZStack(alignment: .leading) {
                        // Background (unfilled)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.bgTertiary)
                            .frame(height: barHeight)

                        // Phase segments
                        ForEach(phases) { phase in
                            let startOffset = CGFloat(phase.startYear - user.birthYear) * yearWidth
                            let phaseWidth = CGFloat(phase.endYear - phase.startYear + 1) * yearWidth

                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.fromHex(phase.colorHex))
                                .frame(width: max(phaseWidth, 4), height: barHeight)
                                .offset(x: startOffset)
                                .opacity(highlightedPhase?.id == phase.id ? 1.0 : 0.6)
                        }
                    }
                )
            }
            .frame(height: barHeight)

            // Year labels
            HStack {
                Text(String(user.birthYear))
                    .font(.caption2)
                    .foregroundStyle(Color.textTertiary)
                Spacer()
                Text(String(user.currentYear))
                    .font(.caption2)
                    .foregroundStyle(Color.textTertiary)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, LifePhase.self, configurations: config)

    let user = User(birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!)
    container.mainContext.insert(user)

    let phase = LifePhase(name: "College", startYear: 2012, endYear: 2016)
    phase.colorHex = "#4F46E5"
    container.mainContext.insert(phase)

    return PhaseConfirmationView(
        user: user,
        addedPhase: phase,
        allPhases: [phase],
        onAddAnother: {},
        onDone: {}
    )
    .modelContainer(container)
}
