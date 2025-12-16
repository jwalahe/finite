//
//  GridView.swift
//  Finite
//
//  Created by Jwala Kompalli on 12/15/25.
//

import SwiftUI
import SwiftData

struct GridView: View {
    let user: User
    let shouldReveal: Bool

    @State private var animationStartTime: Date?
    @State private var hasRevealCompleted: Bool = false
    @State private var showPulse: Bool = false

    private let weeksPerRow: Int = 52
    private let revealDuration: Double = 2.0  // 2 seconds total
    private let horizontalMargin: CGFloat = 24  // CRAFT_SPEC: 24pt screen margins

    init(user: User, shouldReveal: Bool = false) {
        self.user = user
        self.shouldReveal = shouldReveal
    }

    private var totalWeeks: Int { user.totalWeeks }
    private var weeksLived: Int { user.weeksLived }
    private var currentWeekNumber: Int { user.currentWeekNumber }

    // Calculate cell size to fit screen width
    private func calculateCellSize(for screenWidth: CGFloat) -> CGFloat {
        let availableWidth = screenWidth - (horizontalMargin * 2)
        // 52 cells + 51 gaps. We want cellSize + spacing ratio ~= 4:1
        // Total = 52 * cellSize + 51 * spacing
        // If spacing = cellSize * 0.25, then: 52c + 51 * 0.25c = 52c + 12.75c = 64.75c
        // cellSize = availableWidth / 64.75
        let size = availableWidth / 64.75
        return floor(size * 2) / 2  // Round to nearest 0.5pt
    }

    private func calculateSpacing(for cellSize: CGFloat) -> CGFloat {
        return cellSize * 0.25  // Spacing is 25% of cell size
    }

    var body: some View {
        GeometryReader { geometry in
            let cellSize = calculateCellSize(for: geometry.size.width)
            let spacing = calculateSpacing(for: cellSize)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    headerView
                        .padding(.bottom, 24) // 8pt multiple

                    ZStack(alignment: .topLeading) {
                        if shouldReveal && !hasRevealCompleted {
                            // Animated grid using TimelineView
                            animatedGridContent(cellSize: cellSize, spacing: spacing)
                        } else {
                            // Static grid
                            staticGridContent(revealedCount: weeksLived, cellSize: cellSize, spacing: spacing)
                        }

                        if showPulse {
                            currentWeekPulseOverlay(cellSize: cellSize, spacing: spacing)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    footerView
                        .padding(.top, 32) // 8pt multiple (was 24)
                        .padding(.bottom, 48) // 8pt multiple
                }
                .padding(.top, 24) // CRAFT_SPEC: 24pt margins (was 16)
                .padding(.horizontal, horizontalMargin)
            }
        }
        .background(Color.bgPrimary)
        .onAppear {
            if shouldReveal {
                startRevealAnimation()
            } else {
                hasRevealCompleted = true
                showPulse = true
            }
        }
    }

    // MARK: - Reveal Animation

    private func startRevealAnimation() {
        animationStartTime = Date()

        // Schedule SFX ticks throughout animation (spread evenly, ~20 ticks total)
        let totalTicks = 20
        for tick in 1...totalTicks {
            let delay = revealDuration * Double(tick) / Double(totalTicks)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                AudioService.shared.playPencilTick()
            }
        }

        // Schedule haptics at year milestones
        let yearsToReveal = max(1, user.yearsLived)
        for year in 1...yearsToReveal {
            let delay = revealDuration * Double(year) / Double(yearsToReveal)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                HapticService.shared.light()
            }
        }

        // Schedule completion
        DispatchQueue.main.asyncAfter(deadline: .now() + revealDuration + 0.1) {
            hasRevealCompleted = true
            HapticService.shared.heavy()
            AudioService.shared.playTap()
            showPulse = true
        }
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 8) { // 8pt multiple
            Text("Finite")
                .font(.system(size: 24, weight: .light))
                .tracking(2)
                .foregroundStyle(Color.textPrimary)

            if hasRevealCompleted {
                Text("\(user.weeksRemaining.formatted()) weeks remaining")
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
                    .transition(.opacity)
            }
        }
        .animation(.easeIn(duration: 0.5), value: hasRevealCompleted)
    }

    // MARK: - Animated Grid (TimelineView driven)

    private func animatedGridContent(cellSize: CGFloat, spacing: CGFloat) -> some View {
        TimelineView(.animation) { timeline in
            let elapsed = animationStartTime.map { timeline.date.timeIntervalSince($0) } ?? 0
            let progress = min(1.0, elapsed / revealDuration)
            // Ease-out curve for more dramatic start
            let easedProgress = 1 - pow(1 - progress, 2)
            let revealedCount = Int(Double(weeksLived) * easedProgress)

            staticGridContent(revealedCount: revealedCount, cellSize: cellSize, spacing: spacing)
        }
    }

    // MARK: - Static Grid (Canvas)

    private func staticGridContent(revealedCount: Int, cellSize: CGFloat, spacing: CGFloat) -> some View {
        Canvas { context, size in
            for weekNumber in 1...totalWeeks {
                let row = (weekNumber - 1) / weeksPerRow
                let col = (weekNumber - 1) % weeksPerRow
                let x = CGFloat(col) * (cellSize + spacing)
                let y = CGFloat(row) * (cellSize + spacing)
                let rect = CGRect(x: x, y: y, width: cellSize, height: cellSize)
                let circle = Path(ellipseIn: rect)

                let isLived = weekNumber <= weeksLived
                let isRevealed = weekNumber <= revealedCount

                let color: Color = (isLived && isRevealed) ? .gridFilled : .gridUnfilled
                context.fill(circle, with: .color(color))
            }
        }
        .frame(
            width: CGFloat(weeksPerRow) * (cellSize + spacing) - spacing,
            height: CGFloat(user.lifeExpectancy) * (cellSize + spacing) - spacing
        )
    }

    // MARK: - Current Week Pulse Overlay

    private func currentWeekPulseOverlay(cellSize: CGFloat, spacing: CGFloat) -> some View {
        let row = (currentWeekNumber - 1) / weeksPerRow
        let col = (currentWeekNumber - 1) % weeksPerRow

        let x = CGFloat(col) * (cellSize + spacing) + cellSize / 2
        let y = CGFloat(row) * (cellSize + spacing) + cellSize / 2

        let gridWidth = CGFloat(weeksPerRow) * (cellSize + spacing) - spacing
        let gridHeight = CGFloat(user.lifeExpectancy) * (cellSize + spacing) - spacing

        return Canvas { context, size in
            // Empty canvas just to set the frame
        }
        .frame(width: gridWidth, height: gridHeight)
        .overlay {
            PulsingDot(cellSize: cellSize)
                .position(x: x, y: y)
        }
    }

    // MARK: - Footer

    private var footerView: some View {
        HStack(spacing: 32) { // 8pt multiple
            VStack(spacing: 4) { // 8pt multiple (was 2)
                Text("\(user.weeksLived.formatted())")
                    .font(.system(size: 28, weight: .light, design: .rounded))
                    .foregroundStyle(Color.textPrimary)
                Text("lived")
                    .font(.caption2)
                    .foregroundStyle(Color.textTertiary)
            }

            VStack(spacing: 4) { // 8pt multiple (was 2)
                Text("\(user.weeksRemaining.formatted())")
                    .font(.system(size: 28, weight: .light, design: .rounded))
                    .foregroundStyle(Color.textSecondary)
                Text("remaining")
                    .font(.caption2)
                    .foregroundStyle(Color.textTertiary)
            }
        }
        .opacity(hasRevealCompleted ? 1 : 0)
        .animation(.easeIn(duration: 0.5).delay(0.3), value: hasRevealCompleted)
    }

}

// MARK: - Pulsing Dot View

struct PulsingDot: View {
    let cellSize: CGFloat
    @State private var scale: CGFloat = 1.0

    var body: some View {
        Circle()
            .fill(Color.weekCurrent)
            .frame(width: cellSize, height: cellSize)
            .scaleEffect(scale)
            .onAppear {
                // Play SFX when current week pulse appears
                AudioService.shared.playTap()

                withAnimation(
                    .easeInOut(duration: 2.0)
                    .repeatForever(autoreverses: true)
                ) {
                    scale = 1.08
                }
            }
    }
}

#Preview("Grid - No Reveal") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, Week.self, configurations: config)

    let user = User(birthDate: Calendar.current.date(byAdding: .year, value: -30, to: Date())!)
    container.mainContext.insert(user)

    return GridView(user: user, shouldReveal: false)
        .modelContainer(container)
}

#Preview("Grid - With Reveal") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, Week.self, configurations: config)

    let user = User(birthDate: Calendar.current.date(byAdding: .year, value: -25, to: Date())!)
    container.mainContext.insert(user)

    return GridView(user: user, shouldReveal: true)
        .modelContainer(container)
}
