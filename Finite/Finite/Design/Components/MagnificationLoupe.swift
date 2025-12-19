//
//  MagnificationLoupe.swift
//  Finite
//
//  Long-press magnification for precise week selection
//  CRAFT_SPEC: Quality view only, 80pt radius, 1.5x magnification
//

import SwiftUI

struct MagnificationLoupe: View {
    let position: CGPoint
    let highlightedWeek: Int?
    let cellSize: CGFloat
    let spacing: CGFloat
    let gridColors: [Color]
    let weeksPerRow: Int
    let totalWeeks: Int

    // CRAFT_SPEC: 80pt radius, 1.5x magnification
    private let loupeRadius: CGFloat = 80
    private let magnification: CGFloat = 1.5
    private let borderWidth: CGFloat = 2

    var body: some View {
        ZStack {
            // Magnified grid content
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)

                // Calculate which weeks are visible in the loupe
                let magCellSize = cellSize * magnification
                let magSpacing = spacing * magnification

                // Find the center week based on position
                let centerCol = Int(position.x / (cellSize + spacing))
                let centerRow = Int(position.y / (cellSize + spacing))

                // Draw weeks around the center
                let visibleRadius = Int(loupeRadius / (magCellSize + magSpacing)) + 2

                for rowOffset in -visibleRadius...visibleRadius {
                    for colOffset in -visibleRadius...visibleRadius {
                        let row = centerRow + rowOffset
                        let col = centerCol + colOffset

                        guard row >= 0 && col >= 0 && col < weeksPerRow else { continue }

                        let weekNumber = row * weeksPerRow + col + 1
                        guard weekNumber >= 1 && weekNumber <= totalWeeks else { continue }

                        // Calculate position relative to center
                        let originalX = CGFloat(col) * (cellSize + spacing) + cellSize / 2
                        let originalY = CGFloat(row) * (cellSize + spacing) + cellSize / 2

                        let offsetX = (originalX - position.x) * magnification
                        let offsetY = (originalY - position.y) * magnification

                        let x = center.x + offsetX
                        let y = center.y + offsetY

                        // Check if within loupe bounds
                        let distFromCenter = sqrt(pow(x - center.x, 2) + pow(y - center.y, 2))
                        guard distFromCenter < loupeRadius - magCellSize / 2 else { continue }

                        let rect = CGRect(
                            x: x - magCellSize / 2,
                            y: y - magCellSize / 2,
                            width: magCellSize,
                            height: magCellSize
                        )

                        let color = gridColors.indices.contains(weekNumber - 1)
                            ? gridColors[weekNumber - 1]
                            : Color.gridUnfilled

                        let circle = Path(ellipseIn: rect)
                        context.fill(circle, with: .color(color))

                        // Highlight the selected week
                        if weekNumber == highlightedWeek {
                            let highlightRect = rect.insetBy(dx: -2, dy: -2)
                            let highlightCircle = Path(ellipseIn: highlightRect)
                            context.stroke(highlightCircle, with: .color(Color.weekCurrent), lineWidth: 2)
                        }
                    }
                }
            }
            .frame(width: loupeRadius * 2, height: loupeRadius * 2)
            .clipShape(Circle())

            // Border
            Circle()
                .stroke(Color.bgSecondary, lineWidth: borderWidth)
                .frame(width: loupeRadius * 2, height: loupeRadius * 2)
        }
        .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 4)
        .position(x: position.x, y: position.y - loupeRadius - 20) // Position above finger
    }
}

// MARK: - Loupe State Manager

class LoupeState: ObservableObject {
    @Published var isActive: Bool = false
    @Published var position: CGPoint = .zero
    @Published var highlightedWeek: Int?
    @Published var currentWeekNumber: Int = 0  // For Horizons mode display

    private var activationTask: Task<Void, Never>?

    // CRAFT_SPEC: 300ms long-press to activate
    func startLongPress(at location: CGPoint) {
        activationTask?.cancel()

        activationTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms

            guard !Task.isCancelled else { return }

            await MainActor.run {
                withAnimation(.snappy(duration: 0.15, extraBounce: 0.1)) {
                    self.isActive = true
                    self.position = location
                }
                HapticService.shared.light()
            }
        }
    }

    func updatePosition(_ location: CGPoint, cellSize: CGFloat, spacing: CGFloat, weeksPerRow: Int, weeksLived: Int) {
        guard isActive else { return }

        position = location

        // Calculate highlighted week
        let col = Int(location.x / (cellSize + spacing))
        let row = Int(location.y / (cellSize + spacing))
        let weekNumber = row * weeksPerRow + col + 1

        let newHighlight = (weekNumber >= 1 && weekNumber <= weeksLived) ? weekNumber : nil

        if newHighlight != highlightedWeek {
            highlightedWeek = newHighlight
            if newHighlight != nil {
                HapticService.shared.selection()
            }
        }
    }

    func cancelLongPress() {
        activationTask?.cancel()
    }

    func endLongPress() -> Int? {
        activationTask?.cancel()

        let selectedWeek = highlightedWeek

        withAnimation(.easeOut(duration: 0.1)) {
            isActive = false
        }

        if selectedWeek != nil {
            HapticService.shared.medium()
        }

        highlightedWeek = nil
        return selectedWeek
    }
}

#Preview {
    ZStack {
        Color.bgPrimary

        // Sample grid colors
        let colors = (0..<4160).map { _ in Color.gridFilled }

        MagnificationLoupe(
            position: CGPoint(x: 200, y: 300),
            highlightedWeek: 1500,
            cellSize: 6,
            spacing: 1.5,
            gridColors: colors,
            weeksPerRow: 52,
            totalWeeks: 4160
        )
    }
}
