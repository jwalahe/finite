//
//  TimeSpine.swift
//  Finite
//
//  Vertical strip on left edge showing phase colors proportionally mapped to lifespan
//  CRAFT_SPEC: 12pt visual width, 44pt tap target, only in Chapters view
//
//  Interactions:
//  - Tap phase segment → Edit phase (opens sheet)
//  - Long-press phase segment → Show GhostPhase info
//  - Tap "+" button → Add new phase
//

import SwiftUI

struct TimeSpine: View {
    let user: User
    let phases: [LifePhase]
    let gridHeight: CGFloat

    // Callbacks
    let onPhaseEdit: ((LifePhase) -> Void)?       // Tap = Edit
    let onPhaseLongPress: ((LifePhase, CGFloat) -> Void)?  // Long-press = GhostPhase info
    let onAddPhase: (() -> Void)?                 // Tap + = Add

    // CRAFT_SPEC: 12pt visual, 44pt tap target
    private let visualWidth: CGFloat = 12
    private let tapTargetWidth: CGFloat = 44

    // For backward compatibility
    init(
        user: User,
        phases: [LifePhase],
        gridHeight: CGFloat,
        onPhaseTapped: @escaping (LifePhase, CGFloat) -> Void
    ) {
        self.user = user
        self.phases = phases
        self.gridHeight = gridHeight
        self.onPhaseEdit = nil
        self.onPhaseLongPress = onPhaseTapped
        self.onAddPhase = nil
    }

    // New initializer with all callbacks
    init(
        user: User,
        phases: [LifePhase],
        gridHeight: CGFloat,
        onPhaseEdit: ((LifePhase) -> Void)? = nil,
        onPhaseLongPress: ((LifePhase, CGFloat) -> Void)? = nil,
        onAddPhase: (() -> Void)? = nil
    ) {
        self.user = user
        self.phases = phases
        self.gridHeight = gridHeight
        self.onPhaseEdit = onPhaseEdit
        self.onPhaseLongPress = onPhaseLongPress
        self.onAddPhase = onAddPhase
    }

    var body: some View {
        VStack(spacing: 0) {
            spineVisual

            // Add button at bottom
            if onAddPhase != nil {
                addPhaseButton
                    .padding(.top, 12)
            }
        }
        .frame(width: tapTargetWidth)
    }

    // MARK: - Add Phase Button

    private var addPhaseButton: some View {
        Button {
            HapticService.shared.light()
            onAddPhase?()
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(Color.bgTertiary)
                        .frame(width: 32, height: 32)

                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.textSecondary)
                }

                Text("ADD")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundStyle(Color.textTertiary)
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .background(
            GeometryReader { geo in
                Color.clear.preference(
                    key: AddPhaseButtonFrameKey.self,
                    value: geo.frame(in: .global)
                )
            }
        )
    }

    // MARK: - Spine Visual

    private var spineVisual: some View {
        GeometryReader { geo in
            let totalWeeks = user.totalWeeks
            let currentWeek = user.currentWeekNumber

            Canvas { context, size in
                // Sort phases by start year
                let sortedPhases = phases.sorted { $0.startYear < $1.startYear }

                // Track which weeks are covered
                var coveredWeeks = Set<Int>()

                // Draw phases
                for phase in sortedPhases {
                    let startWeek = phase.startWeek(birthYear: user.birthYear)
                    let endWeek = min(phase.endWeek(birthYear: user.birthYear), currentWeek)

                    guard startWeek <= endWeek else { continue }

                    let startY = (CGFloat(startWeek - 1) / CGFloat(totalWeeks)) * size.height
                    let endY = (CGFloat(endWeek) / CGFloat(totalWeeks)) * size.height
                    let segmentHeight = endY - startY

                    let rect = CGRect(
                        x: (tapTargetWidth - visualWidth) / 2,
                        y: startY,
                        width: visualWidth,
                        height: segmentHeight
                    )

                    let color = Color.fromHex(phase.colorHex)
                    context.fill(Path(roundedRect: rect, cornerRadius: 2), with: .color(color))

                    // Mark weeks as covered
                    for week in startWeek...endWeek {
                        coveredWeeks.insert(week)
                    }
                }

                // Draw uncovered past weeks (subtle gray)
                for weekNumber in 1...currentWeek {
                    if !coveredWeeks.contains(weekNumber) {
                        let y = (CGFloat(weekNumber - 1) / CGFloat(totalWeeks)) * size.height
                        let segmentHeight = size.height / CGFloat(totalWeeks)

                        let rect = CGRect(
                            x: (tapTargetWidth - visualWidth) / 2,
                            y: y,
                            width: visualWidth,
                            height: segmentHeight
                        )

                        context.fill(Path(roundedRect: rect, cornerRadius: 1), with: .color(Color.gridFilled.opacity(0.3)))
                    }
                }

                // Draw future (empty) section
                let futureStartY = (CGFloat(currentWeek) / CGFloat(totalWeeks)) * size.height
                let futureRect = CGRect(
                    x: (tapTargetWidth - visualWidth) / 2,
                    y: futureStartY,
                    width: visualWidth,
                    height: size.height - futureStartY
                )
                context.fill(Path(roundedRect: futureRect, cornerRadius: 2), with: .color(Color.bgTertiary))

                // Current position marker (small notch)
                let currentY = (CGFloat(currentWeek - 1) / CGFloat(totalWeeks)) * size.height
                let markerRect = CGRect(
                    x: (tapTargetWidth - visualWidth) / 2 - 2,
                    y: currentY - 1,
                    width: visualWidth + 4,
                    height: 3
                )
                context.fill(Path(roundedRect: markerRect, cornerRadius: 1.5), with: .color(Color.weekCurrent))
            }
            .frame(width: tapTargetWidth, height: gridHeight)
            .contentShape(Rectangle())
            .gesture(
                // Tap = Edit phase
                SpatialTapGesture()
                    .onEnded { value in
                        handleTap(at: value.location.y, in: geo.size.height)
                    }
            )
            .gesture(
                // Long-press = GhostPhase info (uses sequenced gesture to get location)
                LongPressGesture(minimumDuration: 0.3)
                    .sequenced(before: DragGesture(minimumDistance: 0))
                    .onEnded { value in
                        switch value {
                        case .second(true, let drag):
                            if let location = drag?.location {
                                handleLongPress(at: location.y, in: geo.size.height)
                            }
                        default:
                            break
                        }
                    }
            )
        }
        .frame(width: tapTargetWidth, height: gridHeight)
    }

    // MARK: - Gesture Handling

    private func handleTap(at y: CGFloat, in height: CGFloat) {
        guard let phase = findPhase(at: y, in: height) else { return }

        HapticService.shared.light()

        // If edit callback exists, use it; otherwise fall back to long-press behavior
        if let onPhaseEdit = onPhaseEdit {
            onPhaseEdit(phase)
        } else {
            onPhaseLongPress?(phase, y)
        }
    }

    private func handleLongPress(at y: CGFloat, in height: CGFloat) {
        guard let phase = findPhase(at: y, in: height) else { return }

        HapticService.shared.medium()
        onPhaseLongPress?(phase, y)
    }

    private func findPhase(at y: CGFloat, in height: CGFloat) -> LifePhase? {
        let totalWeeks = user.totalWeeks
        let tappedWeek = Int((y / height) * CGFloat(totalWeeks)) + 1

        let birthYear = user.birthYear
        return phases.first { phase in
            let start = phase.startWeek(birthYear: birthYear)
            let end = phase.endWeek(birthYear: birthYear)
            return tappedWeek >= start && tappedWeek <= end
        }
    }
}

// MARK: - Preference Key for Add Button Frame

struct AddPhaseButtonFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

// MARK: - Floating Phase Label (rendered as overlay in parent)

struct SpinePhaseLabel: View {
    let phase: LifePhase
    let yPosition: CGFloat
    let gridHeight: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(phase.name)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.textPrimary)

            Text("\(String(phase.startYear))–\(String(phase.endYear))")
                .font(.caption)
                .foregroundStyle(Color.textSecondary)
        }
        .padding(8)
        .background(Color.bgSecondary)
        .cornerRadius(6)
        .shadow(color: .black.opacity(0.15), radius: 6, x: 2, y: 2)
        // Position: to the right of spine, clamped to visible area
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .offset(x: 68, y: max(0, min(yPosition - 20, gridHeight - 60)))
    }
}

#Preview {
    let user = User(birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!)

    let phase1 = LifePhase(name: "Childhood", startYear: 1995, endYear: 2007, colorHex: "#78716C")
    let phase2 = LifePhase(name: "College", startYear: 2013, endYear: 2017, colorHex: "#4F46E5")
    let phase3 = LifePhase(name: "Career", startYear: 2018, endYear: 2024, colorHex: "#059669")

    return HStack {
        TimeSpine(
            user: user,
            phases: [phase1, phase2, phase3],
            gridHeight: 600,
            onPhaseEdit: { phase in
                print("Edit: \(phase.name)")
            },
            onPhaseLongPress: { phase, y in
                print("Info: \(phase.name) at \(y)")
            },
            onAddPhase: {
                print("Add phase")
            }
        )
        Spacer()
    }
    .padding()
    .background(Color.bgPrimary)
}
