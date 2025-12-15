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

    private let cellSize: CGFloat = 6
    private let cellSpacing: CGFloat = 2
    private let weeksPerRow: Int = 52
    private let revealDuration: Double = 2.0  // 2 seconds total

    init(user: User, shouldReveal: Bool = false) {
        self.user = user
        self.shouldReveal = shouldReveal
    }

    private var totalWeeks: Int { user.totalWeeks }
    private var weeksLived: Int { user.weeksLived }
    private var currentWeekNumber: Int { user.currentWeekNumber }

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    headerView
                        .padding(.bottom, 24)

                    ZStack(alignment: .topLeading) {
                        if shouldReveal && !hasRevealCompleted {
                            // Animated grid using TimelineView
                            animatedGridContent
                        } else {
                            // Static grid
                            staticGridContent(revealedCount: weeksLived)
                        }

                        if showPulse {
                            currentWeekPulseOverlay
                        }
                    }
                    .padding(.horizontal, gridHorizontalPadding(for: geometry.size.width))

                    footerView
                        .padding(.top, 24)
                        .padding(.bottom, 48)
                }
                .padding(.top, 16)
            }
        }
        .background(Color.finiteBackground)
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

        // Schedule haptics during animation
        let yearsToReveal = max(1, user.yearsLived)
        for year in 1...yearsToReveal {
            let delay = revealDuration * Double(year) / Double(yearsToReveal)
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                HapticService.shared.light()
            }
        }

        // Schedule completion
        DispatchQueue.main.asyncAfter(deadline: .now() + revealDuration) {
            hasRevealCompleted = true
            HapticService.shared.heavy()
            withAnimation(.easeIn(duration: 0.3)) {
                showPulse = true
            }
        }
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 4) {
            Text("Finite")
                .font(.system(size: 24, weight: .light))
                .tracking(2)

            if hasRevealCompleted {
                Text("\(user.weeksRemaining.formatted()) weeks remaining")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .transition(.opacity)
            }
        }
        .animation(.easeIn(duration: 0.5), value: hasRevealCompleted)
    }

    // MARK: - Animated Grid (TimelineView driven)

    private var animatedGridContent: some View {
        TimelineView(.animation) { timeline in
            let elapsed = animationStartTime.map { timeline.date.timeIntervalSince($0) } ?? 0
            let progress = min(1.0, elapsed / revealDuration)
            // Ease-out curve for more dramatic start
            let easedProgress = 1 - pow(1 - progress, 2)
            let revealedCount = Int(Double(weeksLived) * easedProgress)

            staticGridContent(revealedCount: revealedCount)
        }
    }

    // MARK: - Static Grid (Canvas)

    private func staticGridContent(revealedCount: Int) -> some View {
        Canvas { context, size in
            for weekNumber in 1...totalWeeks {
                let row = (weekNumber - 1) / weeksPerRow
                let col = (weekNumber - 1) % weeksPerRow

                let x = CGFloat(col) * (cellSize + cellSpacing)
                let y = CGFloat(row) * (cellSize + cellSpacing)

                let rect = CGRect(x: x, y: y, width: cellSize, height: cellSize)
                let circle = Path(ellipseIn: rect)

                let isLived = weekNumber <= weeksLived
                let isRevealed = weekNumber <= revealedCount

                let color: Color
                if isLived && isRevealed {
                    color = .gridFilled
                } else {
                    color = .gridUnfilled
                }

                context.fill(circle, with: .color(color))
            }
        }
        .frame(
            width: CGFloat(weeksPerRow) * (cellSize + cellSpacing) - cellSpacing,
            height: CGFloat(user.lifeExpectancy) * (cellSize + cellSpacing) - cellSpacing
        )
    }

    // MARK: - Current Week Pulse Overlay

    private var currentWeekPulseOverlay: some View {
        let row = (currentWeekNumber - 1) / weeksPerRow
        let col = (currentWeekNumber - 1) % weeksPerRow

        let x = CGFloat(col) * (cellSize + cellSpacing) + cellSize / 2
        let y = CGFloat(row) * (cellSize + cellSpacing) + cellSize / 2

        return PulsingCurrentWeekOverlay(cellSize: cellSize, position: CGPoint(x: x, y: y))
    }

    // MARK: - Footer

    private var footerView: some View {
        HStack(spacing: 32) {
            VStack(spacing: 2) {
                Text("\(user.weeksLived.formatted())")
                    .font(.system(size: 28, weight: .light, design: .rounded))
                Text("lived")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            VStack(spacing: 2) {
                Text("\(user.weeksRemaining.formatted())")
                    .font(.system(size: 28, weight: .light, design: .rounded))
                    .foregroundStyle(.secondary)
                Text("remaining")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .opacity(hasRevealCompleted ? 1 : 0)
        .animation(.easeIn(duration: 0.5).delay(0.3), value: hasRevealCompleted)
    }

    // MARK: - Layout Helpers

    private func gridHorizontalPadding(for width: CGFloat) -> CGFloat {
        let gridWidth = CGFloat(weeksPerRow) * cellSize + CGFloat(weeksPerRow - 1) * cellSpacing
        let padding = (width - gridWidth) / 2
        return max(8, padding)
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
