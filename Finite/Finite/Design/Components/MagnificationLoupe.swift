//
//  MagnificationLoupe.swift
//  Finite
//
//  Long-press magnification for precise week selection
//  CRAFT_SPEC: Quality view only, 80pt radius, 1.5x magnification
//

import SwiftUI

// BUG-003.3: Lightweight struct for milestone info in loupe
struct MilestoneDisplayInfo {
    let name: String
    let categoryName: String?
    let targetAge: Int
    let createdAt: Date
}

struct MagnificationLoupe: View {
    let position: CGPoint
    let highlightedWeek: Int?
    let cellSize: CGFloat
    let spacing: CGFloat
    let gridColors: [Color]
    let weeksPerRow: Int
    let totalWeeks: Int

    // Horizons mode: milestone data for proper coloring
    var milestoneWeeks: Set<Int> = []
    var milestoneColors: [Int: Color] = [:]

    // BUG-003.3: Loupe Depth - milestone info display
    // Contains info for each milestone week: (name, category, targetAge)
    var milestoneInfo: [Int: MilestoneDisplayInfo] = [:]
    var userBirthYear: Int = 0

    // CRAFT_SPEC: 80pt radius, 1.5x magnification
    private let loupeRadius: CGFloat = 80
    private let magnification: CGFloat = 1.5
    private let borderWidth: CGFloat = 2

    var body: some View {
        ZStack {
            // Loupe glass
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

                            // Check if this week has a milestone (Horizons mode)
                            // BUG-003.2: Milestone depth effect in loupe (consistent with grid)
                            if milestoneWeeks.contains(weekNumber) {
                                let milestoneColor = milestoneColors[weekNumber] ?? Color.textPrimary

                                // Depth effect: 15% larger with shadow
                                let depthScale: CGFloat = 1.15
                                let depthSize = magCellSize * depthScale
                                let depthRect = CGRect(
                                    x: x - depthSize / 2,
                                    y: y - depthSize / 2,
                                    width: depthSize,
                                    height: depthSize
                                )

                                // Shadow for depth cue
                                let shadowOffset: CGFloat = 2 * magnification
                                let shadowRect = depthRect.offsetBy(dx: shadowOffset, dy: shadowOffset)
                                let shadowHex = hexagonPath(in: shadowRect)
                                context.fill(shadowHex, with: .color(Color.black.opacity(0.12)))

                                // Draw hexagon for milestone
                                let hexPath = hexagonPath(in: depthRect)
                                context.fill(hexPath, with: .color(milestoneColor))
                            } else {
                                // Draw regular week circle
                                let color = gridColors.indices.contains(weekNumber - 1)
                                    ? gridColors[weekNumber - 1]
                                    : Color.gridUnfilled

                                let circle = Path(ellipseIn: rect)
                                context.fill(circle, with: .color(color))
                            }

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

            // BUG-003.3: Loupe Depth - show milestone info when hovering EXACTLY on a milestone
            // No hints for nearby milestones - rewards curiosity, doesn't guide
            if let week = highlightedWeek, let info = milestoneInfo[week] {
                milestoneInfoBadge(info: info, color: milestoneColors[week] ?? .textPrimary)
                    .position(x: position.x, y: position.y - loupeRadius * 2 - 60)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
    }

    // MARK: - Milestone Info Badge
    // Shows milestone details when loupe is on a milestone week
    @ViewBuilder
    private func milestoneInfoBadge(info: MilestoneDisplayInfo, color: Color) -> some View {
        VStack(spacing: 4) {
            // Milestone name
            Text(info.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.textPrimary)

            // Category and age
            HStack(spacing: 8) {
                if let category = info.categoryName {
                    Text(category)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(color)
                }

                Text("Age \(info.targetAge)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.textSecondary)
            }

            // When set (relative time)
            Text("Set \(relativeTimeString(from: info.createdAt))")
                .font(.system(size: 10))
                .foregroundStyle(Color.textTertiary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.bgSecondary.opacity(0.95))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 2)
    }

    // Helper to format relative time
    private func relativeTimeString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    // Helper to create hexagon path for milestone markers
    private func hexagonPath(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3 - .pi / 2
            let point = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
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

    func updatePosition(_ location: CGPoint, cellSize: CGFloat, spacing: CGFloat, weeksPerRow: Int, weeksLived: Int, totalWeeks: Int, allowFutureWeeks: Bool = false) {
        guard isActive else { return }

        position = location

        // Calculate highlighted week
        let col = Int(location.x / (cellSize + spacing))
        let row = Int(location.y / (cellSize + spacing))
        let weekNumber = row * weeksPerRow + col + 1

        // In Horizons mode (allowFutureWeeks), allow selecting future weeks up to totalWeeks
        // In Quality mode, only allow selecting lived weeks
        let maxWeek = allowFutureWeeks ? totalWeeks : weeksLived
        let newHighlight = (weekNumber >= 1 && weekNumber <= maxWeek) ? weekNumber : nil

        if newHighlight != highlightedWeek {
            highlightedWeek = newHighlight
            currentWeekNumber = weekNumber  // Store for display purposes
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
